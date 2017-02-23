#!/usr/bin/env bash
# Copyright 2015 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================


set -e

function cp_external() {
  local src_dir=$1
  local dest_dir=$2
  for f in `find "$src_dir" -maxdepth 1 -mindepth 1 ! -name '*local_config_cuda*'`; do
    cp -R "$f" "$dest_dir"
  done
}

PLATFORM="$(uname -s | tr 'A-Z' 'a-z')"
function is_windows() {
  # On windows, the shell script is actually running in msys
  if [[ "${PLATFORM}" =~ msys_nt* ]]; then
    true
  else
    false
  fi
}

function main() {
  if [ $# -lt 1 ] ; then
    echo "No destination dir provided"
    exit 1
  fi

  DEST=$1
  TMPDIR=$(mktemp -d -t tmp.XXXXXXXXXX)
  TMPDIR_INCLUDE=${TMPDIR}/include
  TMPDIR_LIB=${TMPDIR}/lib
  mkdir -p ${TMPDIR_INCLUDE}
  mkdir -p ${TMPDIR_LIB}

  GPU_FLAG=""
  while true; do
    if [[ "$1" == "--gpu" ]]; then
      GPU_FLAG="--project_name tensorflow_gpu"
    fi
    shift

    if [[ -z "$1" ]]; then
      break
    fi
  done

  echo $(date) : "=== Using tmpdir: ${TMPDIR}"

  if [ ! -d bazel-bin/tensorflow ]; then
    echo "Could not find bazel-bin.  Did you run from the root of the build tree?"
    exit 1
  fi

  if [ -d bazel-bin/tensorflow/tools/build-atg/build_cc_package.runfiles/org_tensorflow/external ]; then
    # Old-style runfiles structure (--legacy_external_runfiles).
    cp -R \
      bazel-bin/tensorflow/tools/build-atg/build_cc_package.runfiles/org_tensorflow/tensorflow \
      "${TMPDIR_INCLUDE}"
    mkdir "${TMPDIR_INCLUDE}/external"
    cp_external \
      bazel-bin/tensorflow/tools/build-atg/build_cc_package.runfiles/org_tensorflow/external \
      "${TMPDIR_INCLUDE}/external"
  else
    # New-style runfiles structure (--nolegacy_external_runfiles).
    cp -R \
      bazel-bin/tensorflow/tools/build-atg/build_cc_package.runfiles/org_tensorflow/tensorflow \
      "${TMPDIR_INCLUDE}"
    mkdir "${TMPDIR_INCLUDE}/external"
    # Note: this makes an extra copy of org_tensorflow.
    cp_external \
      bazel-bin/tensorflow/tools/build-atg/build_cc_package.runfiles \
      "${TMPDIR_INCLUDE}/external"
  fi
  RUNFILES=bazel-bin/tensorflow/tools/build-atg/build_cc_package.runfiles/org_tensorflow

  # protobuf pip package doesn't ship with header files. Copy the headers
  # over so user defined ops can be compiled.
  mkdir -p ${TMPDIR_INCLUDE}/google
  mkdir -p ${TMPDIR_INCLUDE}/third_party
  pushd ${RUNFILES%org_tensorflow}/protobuf/src/google
  for header in $(find . -name \*.h); do
    mkdir -p "${TMPDIR_INCLUDE}/google/$(dirname ${header})"
    cp "$header" "${TMPDIR_INCLUDE}/google/$(dirname ${header})/"
  done
  popd

  cp -R $RUNFILES/third_party/eigen3 ${TMPDIR_INCLUDE}/third_party

  pushd ${TMPDIR_INCLUDE}
  mv external/eigen_archive/* .
  echo Current:
  pwd
  # exit
  mv tensorflow/libtensorflow.so ../lib/
  popd

  pushd ${TMPDIR}
  echo $(date) : "=== Building c++ package"
  mkdir -p ${DEST}
  cp -rL ${TMPDIR}/* ${DEST}
  popd
  rm -rf ${TMPDIR}
  echo $(date) : "=== Output c++ package is in: ${DEST}"
}

main "$@"

1. Run:
     tensorflow/tools/build-atg/configure-atg.sh 
2. Build c++ package:
    bazel build --config=cuda -c opt //tensorflow/tools/build-atg:build_cc_package
3. Create a directory with required include and lib files (will be written to /tmp/atg-tensorflow-package):
    bazel-bin/tensorflow/tools/build-atg/build_cc_package /tmp/atg-tensorflow-package

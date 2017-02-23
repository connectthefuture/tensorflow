# Description:
#  Tools for building the TensorFlow c++ package.

package(default_visibility = ["//visibility:private"])

load("//tensorflow:tensorflow.bzl", "transitive_hdrs")

# This returns a list of headers of all public header libraries (e.g.,
# framework, lib), and all of the transitive dependencies of those
# public headers needed by a inference client.  
# Not all of the headers returned by the filegroup
# are public (e.g., internal headers that are included by public
# headers), but the internal headers need to be packaged in the
# cc_package for the public headers to be properly included.
#
transitive_hdrs(
    name = "basic_headers",
    deps = [
        "//tensorflow/core:core_cpu",
        "//tensorflow/core:protos_all_cc",
        "//third_party/eigen3",
    ],
)

sh_binary(
    name = "build_cc_package",
    srcs = ["build_cc_package.sh"],
    data = [
        ":basic_headers",
        "//tensorflow:libtensorflow.so"
    ],
)

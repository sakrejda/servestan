## The following relative paths are relative to the 'servestan'
## directory.

# Cloning grpc, then 'make'
git clone https://github.com/grpc/grpc.git
cd grpc
git checkout release-0_12   ## The master branch a.t.m. is missing grpc++.h
git submodule update --init
make  ## the grpc plugin ends up in bins/opt

# Use the protobuf compiler to produce the service interface
# code, requires a 'grpc' directory clone from github parallel
# to the servestan directory.
../grpc/bins/opt/protobuf/protoc \
  --grpc_out=src  \
  --plugin=protoc-gen-grpc=../grpc/bins/opt/grpc_cpp_plugin \
  ./proto/stanc.proto

# Use the protobuf compiler to produce message interface
# code:
../grpc/bins/opt/protobuf/protoc --cpp_out=src ./proto/stanc.proto

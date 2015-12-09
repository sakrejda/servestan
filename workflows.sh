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
lib/grpc/bins/opt/protobuf/protoc \
  --grpc_out=src  \
  --plugin=protoc-gen-grpc=lib/grpc/bins/opt/grpc_cpp_plugin \
  ./proto/stanc.proto

# Use the protobuf compiler to produce message interface
# code:
lib/grpc/bins/opt/protobuf/protoc --cpp_out=src ./proto/stanc.proto

# Oy, where are all the pieces hiding:
g++ -std=c++11 -I src/ -I lib/grpc/include/ \
  -I lib/grpc/third_party/protobuf/src/ -I lib/stan/src/ \
  -I lib/math/lib/boost_1.58.0/ -L lib/grpc/libs/opt/ \
  -lgrpc++_unsecure -lgrpc -lgpr -lprotobuf -lpthread \
  -ldl -o servestan src/servestan/stanc_server.cpp 




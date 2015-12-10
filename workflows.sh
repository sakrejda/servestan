# Originally adding links to the sub-modules:
git submodule add https://github.com/stan-dev/stan.git lib/stan
git submodule add https://github.com/grpc/grpc.git lib/grpc


## Now the structure is:
##    $ROOT/servestan
##    $ROOT/servestan/lib/grpc
##    $ROOT/servestan/lib/stan
## grpc and stan are submodules so to clone this mess:
git clone https://github.com/sakrejda/servestan.git
cd servestan.git
git submodule update --init --recursive

# To generate the protoc compiler:
cd lib/grpc
make  ## the grpc plugin ends up in bins/opt

# Generate libstanc.a:
cd ../lib/stan
make bin/libstanc.a

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
g++ -std=c++11 -O3 -v \
  -I src/ \
  -I lib/grpc/include/ \
  -I lib/grpc/third_party/protobuf/src/ \
  -I lib/stan/src/ \
  -I lib/stan/lib/stan_math_2.9.0/lib/boost_1.58.0/ \
  -o servestan \
  src/servestan/servestan.cpp \
  -L lib/grpc/libs/opt/ \
  -L lib/stan/bin/stan \
  -L lib/stan/bin/ \
  -lgrpc++_unsecure -lgrpc -lgpr -lprotobuf -lpthread -ldl \
  -lstanc 


g++ -std=c++11 -O3 -v \
  -I src/ \
  -I lib/grpc/include/ \
  -I lib/grpc/third_party/protobuf/src/ \
  -I lib/stan/src/ \
  -I lib/stan/lib/stan_math_2.9.0/lib/boost_1.58.0/ \
  -o servestan \
  src/servestan/servestan.cpp \
  src/proto/stanc.grpc.pb.cc \
  src/proto/stanc.pb.cc \
  lib/grpc/libs/opt/libgrpc++_unsecure.so \
  lib/grpc/libs/opt/libgrpc_unsecure.so \
  lib/grpc/libs/opt/libgrpc.so \
  lib/grpc/libs/opt/libgpr.so \
  lib/stan/bin/libstanc.a \
  lib/grpc/third_party/protobuf/src/.libs/libprotobuf.a \
  -lpthread -ldl -lboost




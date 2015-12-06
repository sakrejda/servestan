#include <iostream>
#include <sstream>
#include <memory>
#include <string>
#include <grpc++/grpc++.h>
#include <proto/stanc.grpc.pb.h>
#include <proto/stanc.pb.h>
#include <stan/lang/compiler.hpp>

namespace stan {
  namespace serve {

    class CompileServiceImpl final : public CompileService {
      grpc::Status CompileProgram(grpc::ServerContext* context,
        const stan::serve::StanCompileRequest* request, 
              stan::serve::StanCompileResponse* reply ) override {
    
        // Protobuf carries strings and stan::lang::compile needs strings...
        std::ostringstream err_stream;
        std::istringstream stan_stream(request->model_code());
        std::ostringstream cpp_stream;
        
        bool valid_model = stan::lang::compile(err_stream, 
          stan_stream, cpp_stream, 
          request->model_name(), request->model_file_name());
        reply->set_messages(err_stream.str());
        reply->set_cpp_code(cpp_stream.str());
        if (valid_model) {
          if (err_stream.tellp() == 0) 
            reply->set_state(stan::serve::StanCompileResponse::State::SUCCESS);
          else 
            reply->set_state(stan::serve::StanCompileResponse::State::WARN);
        } else {
          reply->set_state(stan::serve::StanCompileResponse::State::ERROR);
        }
          return grpc::Status::OK;
      }
    };

  }
}

void RunServer() {
  std::string server_address("127.0.0.1:6666");
  stan::serve::CompileServiceImpl service;

  grpc::ServerBuilder builder;
  builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
  builder.RegisterService(&service);
  std::unique_ptr<grpc::Server> server(builder.BuildAndStart());

  server->Wait();
}

int main(int argc, char** argv) {
  grpc::RunServer();
  return 0;
}
    



#include <iostream>
#include <sstream>
#include <memory>
#include <string>
#include <grpc++/grpc++.h>
#include <proto/stanc.grpc.pb.h>

namespace stan {
  namespace serve {

    class StancServiceImpl final : public stanc::CompileService {
      grpc::Status CompileProgram(grpc::ServerContext* context,
        const stanc::StanCompileRequest* request, 
              stanc::StanCompileResponse* reply ) override {
    
        // Protobuf carries strings and stan::lang::compile needs strings...
        std::ostringstream err_stream;
        std::istringstream stan_stream(request->model_code);
        std::ostringstream cpp_stream;
        
        bool valid_model = stan::lang::compile(err_stream, 
          stan_stream, cpp_stream, 
          request->model_name, request->model_file_name);
        reply->set_messages(err_stream.str());
        reply->set_cpp_code(cpp_stream.str());
        if (valid_model) {
          if (err_stream.tellp() == 0) 
            reply->set_State(StanCompileResponse::State::SUCCESS);
          else 
            reply->set_State(StanCompileResponse::State::WARN);
        } else {
          reply->set_State(StanCompileResponse::State::ERROR);
        }
          return grpc::Status::OK;
      }
    };

  }
}

void RunServer() {
  std::string server_address("127.0.0.1:6666");
  StancServiceImpl service;

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
    



/* Copyright 2016 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#include "tensorflow/core/distributed_runtime/server_lib.h"

#include <unordered_map>

#include "tensorflow/core/lib/core/errors.h"
#include "tensorflow/core/platform/mutex.h"


namespace tensorflow {

namespace {
mutex* get_server_factory_lock() {
  static mutex server_factory_lock(LINKER_INITIALIZED);
  return &server_factory_lock;
}

typedef std::unordered_map<string, ServerFactory*> ServerFactories;
ServerFactories* server_factories() {
  static ServerFactories* factories = new ServerFactories;
  return factories;
}

// Key is requested port, as specified in the server def
static std::unordered_map<int, ServerInterface*> active_servers;

}  // namespace

/* static */
void ServerFactory::Register(const string& server_type,
                             ServerFactory* factory) {
  mutex_lock l(*get_server_factory_lock());
  if (!server_factories()->insert({server_type, factory}).second) {
    LOG(ERROR) << "Two server factories are being registered under "
               << server_type;
  }
}

/* static */
Status ServerFactory::GetFactory(const ServerDef& server_def,
                                 ServerFactory** out_factory) {
  mutex_lock l(*get_server_factory_lock());
  for (const auto& server_factory : *server_factories()) {
    if (server_factory.second->AcceptsOptions(server_def)) {
      *out_factory = server_factory.second;
      return Status::OK();
    }
  }

  std::vector<string> server_names;
  for (const auto& server_factory : *server_factories()) {
    server_names.push_back(server_factory.first);
  }

  return errors::NotFound(
      "No server factory registered for the given ServerDef: ",
      server_def.DebugString(), "\nThe available server factories are: [ ",
      absl::StrJoin(server_names, ", "), " ]");
}

Status GetServerDefPort(const ServerDef& server_def_, int* port) {
  *port = -1;
  for (const auto& job : server_def_.cluster().job()) {
    if (job.name() == server_def_.job_name()) {
      auto iter = job.tasks().find(server_def_.task_index());
      if (iter == job.tasks().end()) {
        return errors::InvalidArgument("Task ", server_def_.task_index(),
                                       " was not defined in job \"",
                                       server_def_.job_name(), "\"");
      }
      auto colon_index = iter->second.find_last_of(':');
      if (!strings::safe_strto32(iter->second.substr(colon_index + 1), port)) {
        return errors::InvalidArgument(
            "Could not parse port for local server from \"", iter->second,
            "\".");
      }
      break;
    }
  }
  if (*port == -1) {
    return errors::Internal("Job \"", server_def_.job_name(),
                            "\" was not defined in cluster");
  }
  return Status::OK();
}

// Creates a server based on the given `server_def`, and stores it in
// `*out_server`. Returns OK on success, otherwise returns an error.
Status NewServer(const ServerDef& server_def,
                 std::unique_ptr<ServerInterface>* out_server) {
  ServerFactory* factory;
  TF_RETURN_IF_ERROR(ServerFactory::GetFactory(server_def, &factory));
  // If a server with the same requested port already exists, destroy it first
  int requested_port;
  TF_RETURN_IF_ERROR(tensorflow::GetServerDefPort(server_def, &requested_port));
  auto existing_server = active_servers.find(requested_port);
  if (existing_server != active_servers.end()) {
    LOG(INFO) << "Found existing server bound to port " << requested_port << ", destroying it first.";
    existing_server->second->Destroy();
  }
  Status status = factory->NewServer(server_def, out_server);
  LOG(INFO) << "Created new server, binding to port " << requested_port;
  // Keep track of this new server, overwriting existing ones with the same server def, if any
  active_servers[requested_port] = out_server->get();
  return status;
}

}  // namespace tensorflow

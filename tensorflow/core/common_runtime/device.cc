/* Copyright 2015 The TensorFlow Authors. All Rights Reserved.

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

#include "tensorflow/core/common_runtime/device.h"

#include <unordered_map>

#include "tensorflow/core/common_runtime/device_mgr.h"
#include "tensorflow/core/framework/op_segment.h"
#include "tensorflow/core/lib/core/errors.h"
#include "tensorflow/core/lib/random/random.h"
#include "tensorflow/core/platform/logging.h"
#include "tensorflow/core/platform/types.h"

namespace tensorflow {

std::unordered_map<string, long> Device::incarnation_map = {};

Device::Device(Env* env, const DeviceAttributes& device_attributes)
    : DeviceBase(env), device_attributes_(device_attributes) {
  CHECK(DeviceNameUtils::ParseFullName(name(), &parsed_name_))
      << "Invalid device name: " << name();
  rmgr_ = new ResourceMgr(parsed_name_.job);
}

Device::~Device() {
  if (rmgr_ != nullptr) {
    DeleteResourceMgr();
  }
}

// static
DeviceAttributes Device::BuildDeviceAttributes(
    const string& name, DeviceType device, Bytes memory_limit,
    const DeviceLocality& locality, const string& physical_device_desc) {
  DeviceAttributes da;
  da.set_name(name);
  //do {
  //  da.set_incarnation(random::New64());
  //} while (da.incarnation() == 0);  // This proto field must not be zero
  LOG(INFO) << "I am building device attributes for " << name;
  if (Device::incarnation_map.find(name) == Device::incarnation_map.end()) {
    LOG(INFO) << "FIRST TIME SEEING " << name;
    do {
      Device::incarnation_map[name] = random::New64();
    } while (Device::incarnation_map[name] == 0);  // This proto field must not be zero
  } else {
    LOG(INFO) << "SECOND TIME SEEING " << name << ", just using old value " << Device::incarnation_map[name];
  }
  da.set_incarnation(Device::incarnation_map[name]);
  LOG(INFO) << "BUILDING DEVICE " << name << "... incarnation = " << da.incarnation();
  da.set_device_type(device.type());
  da.set_memory_limit(memory_limit.value());
  *da.mutable_locality() = locality;
  da.set_physical_device_desc(physical_device_desc);
  return da;
}

}  // namespace tensorflow

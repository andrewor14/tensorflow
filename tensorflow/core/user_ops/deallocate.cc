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

#include "tensorflow/core/framework/op.h"
#include "tensorflow/core/framework/op_kernel.h"

using namespace tensorflow;

REGISTER_OP("Deallocate")
    .Attr("T: {int32, float16, float32}")
    .Input("deallocate: T");

class DeallocateOp : public tensorflow::OpKernel {
 public:
  explicit DeallocateOp(tensorflow::OpKernelConstruction* context)
      : OpKernel(context) {}

  void Compute(tensorflow::OpKernelContext* context) override {
    const Tensor& input_tensor = context->input(0);
    input_tensor.DeallocateBuffer();
  }
};

REGISTER_KERNEL_BUILDER(Name("Deallocate").Device(tensorflow::DEVICE_GPU), DeallocateOp);


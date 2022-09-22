#include <ATen/ATen.h>
#include <ATen/native/TensorIterator.h>
#include <ATen/native/cuda/Loops.cuh>
#include <ATen/cpu/vec/vec.h>

namespace at {
namespace native {

Tensor& relu_quantized_cuda_(Tensor& self) {
  const auto zero_point = self.q_zero_point();
  AT_DISPATCH_QINT_TYPES(
    self.scalar_type(), "qrelu_cuda", [&]() {
      using Vec = vec::Vectorized<scalar_t>;
      auto iter = TensorIterator::unary_op(self, self);
      gpu_kernel(iter, [zero_point] GPU_LAMBDA(scalar_t value) -> scalar_t {
        return scalar_t(std::max<underlying_t>(value.val_, zero_point));
        });
  });
  return self;
}

}  // namespace at::native
}  // namespace at

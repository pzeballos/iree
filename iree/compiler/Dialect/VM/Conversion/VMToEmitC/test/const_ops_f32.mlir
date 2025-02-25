// RUN: iree-opt -split-input-file -pass-pipeline='vm.module(iree-convert-vm-to-emitc)' %s | IreeFileCheck %s

vm.module @my_module {
  // CHECK-LABEL: vm.func @const_f32_zero
  vm.func @const_f32_zero() -> f32 {
    // CHECK: %[[ZERO:.+]] = "emitc.const"() {value = 0.000000e+00 : f32} : () -> f32
    %zero = vm.const.f32.zero : f32
    vm.return %zero : f32
  }
}

// -----

vm.module @my_module {
  // CHECK-LABEL: vm.func @const_f32
  vm.func @const_f32() {
    // CHECK-NEXT: %0 = "emitc.const"() {value = 5.000000e-01 : f32} : () -> f32
    %0 = vm.const.f32 0.5 : f32
    // CHECK-NEXT: %1 = "emitc.const"() {value = 2.500000e+00 : f32} : () -> f32
    %1 = vm.const.f32 2.5 : f32
    // CHECK-NEXT: %2 = "emitc.const"() {value = -2.500000e+00 : f32} : () -> f32
    %2 = vm.const.f32 -2.5 : f32
    vm.return
  }
}

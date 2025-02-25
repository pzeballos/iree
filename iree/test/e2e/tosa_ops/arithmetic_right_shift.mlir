func @no_round() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[5, 8, -1, 7]> : tensor<4xi32>
  %1 = iree.unfoldable_constant dense<[0, 1, 3, 1]> : tensor<4xi32>
  %result = "tosa.arithmetic_right_shift"(%0, %1) {round = 0 : i1} : (tensor<4xi32>, tensor<4xi32>) -> tensor<4xi32>
  check.expect_eq_const(%result, dense<[5, 4, -1, 3]> : tensor<4xi32>) : tensor<4xi32>
  return
}

func @with_round() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[5, 8, -1, 7]> : tensor<4xi32>
  %1 = iree.unfoldable_constant dense<[0, 1, 3, 1]> : tensor<4xi32>
  %result = "tosa.arithmetic_right_shift"(%0, %1) {round = 1 : i1} : (tensor<4xi32>, tensor<4xi32>) -> tensor<4xi32>
  check.expect_eq_const(%result, dense<[5, 4, 0, 4]> : tensor<4xi32>) : tensor<4xi32>
  return
}

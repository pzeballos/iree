// Int sum values from [1, 10]
func @reduce_sum_1x10xi32() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]]> : tensor<1x10xi32>
  %1 = iree.unfoldable_constant dense<0> : tensor<i32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<i32>, %arg1: tensor<i32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<i32>, tensor<i32>) -> tensor<i32>
    "mhlo.return"(%3) : (tensor<i32>) -> ()
  }) {dimensions = dense<1> : tensor<1xi64>} : (tensor<1x10xi32>, tensor<i32>) -> tensor<1xi32>
  check.expect_eq_const(%res, dense<55> : tensor<1xi32>) : tensor<1xi32>
  return
}

// Int max values from [1, 10]
func @reduce_max_1x10xi32() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]]> : tensor<1x10xi32>
  %1 = iree.unfoldable_constant dense<0> : tensor<i32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<i32>, %arg1: tensor<i32>):   // no predecessors
    %3 = "mhlo.maximum"(%arg0, %arg1) : (tensor<i32>, tensor<i32>) -> tensor<i32>
    "mhlo.return"(%3) : (tensor<i32>) -> ()
  }) {dimensions = dense<1> : tensor<1xi64>} : (tensor<1x10xi32>, tensor<i32>) -> tensor<1xi32>
  check.expect_eq_const(%res, dense<10> : tensor<1xi32>) : tensor<1xi32>
  return
}

// Int min values, along multiple dimensions. Expected to just be a reshape in this case.
func @reduce_min_5x1x1xi32() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[[[1]],[[2]],[[3]],[[4]],[[5]]]> : tensor<5x1x1xi32>
  %1 = iree.unfoldable_constant dense<999> : tensor<i32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<i32>, %arg1: tensor<i32>):   // no predecessors
    %3 = "mhlo.minimum"(%arg0, %arg1) : (tensor<i32>, tensor<i32>) -> tensor<i32>
    "mhlo.return"(%3) : (tensor<i32>) -> ()
  }) {dimensions = dense<[1, 2]> : tensor<2xi64>} : (tensor<5x1x1xi32>, tensor<i32>) -> tensor<5xi32>
  check.expect_eq_const(%res, dense<[1, 2, 3, 4, 5]> : tensor<5xi32>) : tensor<5xi32>
  return
}


// The following cases match the examples presented at
// https://www.tensorflow.org/xla/operation_semantics#reduce

func @reduce_sum_2x3xi32_dim0() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[
      [1, 2, 3],
      [4, 5, 6]]> : tensor<2x3xi32>
  %1 = iree.unfoldable_constant dense<0> : tensor<i32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<i32>, %arg1: tensor<i32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<i32>, tensor<i32>) -> tensor<i32>
    "mhlo.return"(%3) : (tensor<i32>) -> ()
  }) {dimensions = dense<0> : tensor<1xi64>} : (tensor<2x3xi32>, tensor<i32>) -> tensor<3xi32>
  check.expect_eq_const(%res, dense<[5, 7, 9]> : tensor<3xi32>) : tensor<3xi32>
  return
}

func @reduce_sum_2x3xi32_dim1() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[
      [1, 2, 3],
      [4, 5, 6]]> : tensor<2x3xi32>
  %1 = iree.unfoldable_constant dense<0> : tensor<i32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<i32>, %arg1: tensor<i32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<i32>, tensor<i32>) -> tensor<i32>
    "mhlo.return"(%3) : (tensor<i32>) -> ()
  }) {dimensions = dense<1> : tensor<1xi64>} : (tensor<2x3xi32>, tensor<i32>) -> tensor<2xi32>
  check.expect_eq_const(%res, dense<[6, 15]> : tensor<2xi32>) : tensor<2xi32>
  return
}

func @reduce_sum_4x2x3xi32_dim0() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[
      [[1, 2, 3], [4, 5, 6]],
      [[1, 2, 3], [4, 5, 6]],
      [[1, 2, 3], [4, 5, 6]],
      [[1, 2, 3], [4, 5, 6]]]> : tensor<4x2x3xi32>
  %1 = iree.unfoldable_constant dense<0> : tensor<i32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<i32>, %arg1: tensor<i32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<i32>, tensor<i32>) -> tensor<i32>
    "mhlo.return"(%3) : (tensor<i32>) -> ()
  }) {dimensions = dense<0> : tensor<1xi64>} : (tensor<4x2x3xi32>, tensor<i32>) -> tensor<2x3xi32>
  check.expect_eq_const(%res, dense<[[4, 8, 12],[16, 20, 24]]> : tensor<2x3xi32>) : tensor<2x3xi32>
  return
}

func @reduce_sum_4x2x3xi32_dim2() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[
    [[1, 2, 3], [4, 5, 6]],
    [[1, 2, 3], [4, 5, 6]],
    [[1, 2, 3], [4, 5, 6]],
    [[1, 2, 3], [4, 5, 6]]]> : tensor<4x2x3xi32>
  %1 = iree.unfoldable_constant dense<0> : tensor<i32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<i32>, %arg1: tensor<i32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<i32>, tensor<i32>) -> tensor<i32>
    "mhlo.return"(%3) : (tensor<i32>) -> ()
  }) {dimensions = dense<2> : tensor<1xi64>} : (tensor<4x2x3xi32>, tensor<i32>) -> tensor<4x2xi32>
  check.expect_eq_const(%res, dense<[[6, 15],[6, 15],[6, 15],[6, 15]]> : tensor<4x2xi32>) : tensor<4x2xi32>
  return
}

func @reduce_sum_4x2x3xi32_dims_0_1() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[
      [[1, 2, 3], [4, 5, 6]],
      [[1, 2, 3], [4, 5, 6]],
      [[1, 2, 3], [4, 5, 6]],
      [[1, 2, 3], [4, 5, 6]]]> : tensor<4x2x3xi32>
  %1 = iree.unfoldable_constant dense<0> : tensor<i32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<i32>, %arg1: tensor<i32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<i32>, tensor<i32>) -> tensor<i32>
    "mhlo.return"(%3) : (tensor<i32>) -> ()
  }) {dimensions = dense<[0, 1]> : tensor<2xi64>} : (tensor<4x2x3xi32>, tensor<i32>) -> tensor<3xi32>
  check.expect_eq_const(%res, dense<[20, 28, 36]> : tensor<3xi32>) : tensor<3xi32>
  return
}

func @reduce_sum_4x2x3xi32_dims_0_1_2() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[
      [[1, 2, 3], [4, 5, 6]],
      [[1, 2, 3], [4, 5, 6]],
      [[1, 2, 3], [4, 5, 6]],
      [[1, 2, 3], [4, 5, 6]]]> : tensor<4x2x3xi32>
  %1 = iree.unfoldable_constant dense<0> : tensor<i32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<i32>, %arg1: tensor<i32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<i32>, tensor<i32>) -> tensor<i32>
    "mhlo.return"(%3) : (tensor<i32>) -> ()
  }) {dimensions = dense<[0, 1, 2]> : tensor<3xi64>} : (tensor<4x2x3xi32>, tensor<i32>) -> tensor<i32>
  check.expect_eq_const(%res, dense<84> : tensor<i32>) : tensor<i32>
  return
}

// Float sum values from [1.0, 10.0]
func @reduce_sum_1x10xf32() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]]> : tensor<1x10xf32>
  %1 = iree.unfoldable_constant dense<0.0> : tensor<f32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<f32>, tensor<f32>) -> tensor<f32>
    "mhlo.return"(%3) : (tensor<f32>) -> ()
  }) {dimensions = dense<1> : tensor<1xi64>} : (tensor<1x10xf32>, tensor<f32>) -> tensor<1xf32>
  check.expect_almost_eq_const(%res, dense<55.0> : tensor<1xf32>) : tensor<1xf32>
  return
}

// Float max values from [1.0, 10.0]
func @reduce_max_1x10xf32() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]]> : tensor<1x10xf32>
  %1 = iree.unfoldable_constant dense<0.0> : tensor<f32>
  %res = "mhlo.reduce"(%0, %1)
  ( {
  ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):   // no predecessors
      %3 = "mhlo.maximum"(%arg0, %arg1) : (tensor<f32>, tensor<f32>) -> tensor<f32>
      "mhlo.return"(%3) : (tensor<f32>) -> ()
  })
  {dimensions = dense<1> : tensor<1xi64>} : (tensor<1x10xf32>, tensor<f32>) -> tensor<1xf32>
  check.expect_almost_eq_const(%res, dense<10.0> : tensor<1xf32>) : tensor<1xf32>
  return
}

// Float min values, along multiple dimensions. Expected to just be a reshape in this case.
func @reduce_min_5x1x1xf32() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[[[1.0]],[[2.0]],[[3.0]],[[4.0]],[[5.0]]]> : tensor<5x1x1xf32>
  %1 = iree.unfoldable_constant dense<999.0> : tensor<f32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):   // no predecessors
      %3 = "mhlo.minimum"(%arg0, %arg1) : (tensor<f32>, tensor<f32>) -> tensor<f32>
      "mhlo.return"(%3) : (tensor<f32>) -> ()
  }) {dimensions = dense<[1, 2]> : tensor<2xi64>} : (tensor<5x1x1xf32>, tensor<f32>) -> tensor<5xf32>
  check.expect_almost_eq_const(%res, dense<[1.0, 2.0, 3.0, 4.0, 5.0]> : tensor<5xf32>) : tensor<5xf32>
  return
}

// The following cases match the examples presented at
// https://www.tensorflow.org/xla/operation_semantics#reduce

func @reduce_sum_2x3xf32_dim0() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]> : tensor<2x3xf32>
  %1 = iree.unfoldable_constant dense<0.0> : tensor<f32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<f32>, tensor<f32>) -> tensor<f32>
    "mhlo.return"(%3) : (tensor<f32>) -> ()
  }) {dimensions = dense<0> : tensor<1xi64>} : (tensor<2x3xf32>, tensor<f32>) -> tensor<3xf32>
  check.expect_almost_eq_const(%res, dense<[5.0, 7.0, 9.0]> : tensor<3xf32>) : tensor<3xf32>
  return
}

func @reduce_sum_2x3xf32_dim1() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]> : tensor<2x3xf32>
  %1 = iree.unfoldable_constant dense<0.0> : tensor<f32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<f32>, tensor<f32>) -> tensor<f32>
    "mhlo.return"(%3) : (tensor<f32>) -> ()
  }) {dimensions = dense<1> : tensor<1xi64>} : (tensor<2x3xf32>, tensor<f32>) -> tensor<2xf32>
  check.expect_almost_eq_const(%res, dense<[6.0, 15.0]> : tensor<2xf32>) : tensor<2xf32>
  return
}

func @reduce_sum_4x2x3xf32_dim0() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]]> : tensor<4x2x3xf32>
  %1 = iree.unfoldable_constant dense<0.0> : tensor<f32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<f32>, tensor<f32>) -> tensor<f32>
    "mhlo.return"(%3) : (tensor<f32>) -> ()
  }) {dimensions = dense<0> : tensor<1xi64>} : (tensor<4x2x3xf32>, tensor<f32>) -> tensor<2x3xf32>
  check.expect_almost_eq_const(%res, dense<[[4.0, 8.0, 12.0],[16.0, 20.0, 24.0]]> : tensor<2x3xf32>) : tensor<2x3xf32>
  return
}

func @reduce_sum_4x2x3xf32_dim1() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]]> : tensor<4x2x3xf32>
  %1 = iree.unfoldable_constant dense<0.0> : tensor<f32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<f32>, tensor<f32>) -> tensor<f32>
    "mhlo.return"(%3) : (tensor<f32>) -> ()
  }) {dimensions = dense<1> : tensor<1xi64>} : (tensor<4x2x3xf32>, tensor<f32>) -> tensor<4x3xf32>
  check.expect_almost_eq_const(%res, dense<[
      [5.0, 7.0, 9.0],
      [5.0, 7.0, 9.0],
      [5.0, 7.0, 9.0],
      [5.0, 7.0, 9.0]]> : tensor<4x3xf32>) : tensor<4x3xf32>
  return
}

func @reduce_sum_4x2x3xf32_dim2() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]]> : tensor<4x2x3xf32>
  %1 = iree.unfoldable_constant dense<0.0> : tensor<f32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<f32>, tensor<f32>) -> tensor<f32>
    "mhlo.return"(%3) : (tensor<f32>) -> ()
  }) {dimensions = dense<2> : tensor<1xi64>} : (tensor<4x2x3xf32>, tensor<f32>) -> tensor<4x2xf32>
  check.expect_almost_eq_const(%res, dense<[
      [6.0, 15.0],
      [6.0, 15.0],
      [6.0, 15.0],
      [6.0, 15.0]]> : tensor<4x2xf32>) : tensor<4x2xf32>
  return
}

func @reduce_sum_4x2x3xf32_dims_0_1() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]]> : tensor<4x2x3xf32>
  %1 = iree.unfoldable_constant dense<0.0> : tensor<f32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<f32>, tensor<f32>) -> tensor<f32>
    "mhlo.return"(%3) : (tensor<f32>) -> ()
  }) {dimensions = dense<[0, 1]> : tensor<2xi64>} : (tensor<4x2x3xf32>, tensor<f32>) -> tensor<3xf32>
  check.expect_almost_eq_const(%res, dense<[20.0, 28.0, 36.0]> : tensor<3xf32>) : tensor<3xf32>
  return
}

func @reduce_sum_4x2x3xf32_dims_0_1_2() attributes { iree.module.export } {
  %0 = iree.unfoldable_constant dense<[
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]],
      [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]]> : tensor<4x2x3xf32>
  %1 = iree.unfoldable_constant dense<0.0> : tensor<f32>
  %res = "mhlo.reduce"(%0, %1) ( {
  ^bb0(%arg0: tensor<f32>, %arg1: tensor<f32>):   // no predecessors
    %3 = "mhlo.add"(%arg0, %arg1) : (tensor<f32>, tensor<f32>) -> tensor<f32>
    "mhlo.return"(%3) : (tensor<f32>) -> ()
  }) {dimensions = dense<[0, 1, 2]> : tensor<3xi64>} : (tensor<4x2x3xf32>, tensor<f32>) -> tensor<f32>
  check.expect_almost_eq_const(%res, dense<84.0> : tensor<f32>) : tensor<f32>
  return
}

func @reducemulti_result() attributes { iree.module.export } {
  %cst0 = mhlo.constant dense<-2147483648> : tensor<i32>
  %cst1 = mhlo.constant dense<0> : tensor<i32>
  %arg0 = iree.unfoldable_constant dense<[[1, 2], [3, 4], [5, 6], [7, 8], [9, 10], [11, 12], [13, 14], [15, 16], [17, 18]]> : tensor<9x2xi32>
  %arg1 = iree.unfoldable_constant dense<[[0, 1], [2, 3], [4, 5], [6, 7], [8, 9], [10, 11], [12, 13], [14, 15], [16, 17]]> : tensor<9x2xi32>
  %res0, %res1 = "mhlo.reduce"(%arg0, %arg1, %cst0, %cst1) ( {
  ^bb0(%arg2: tensor<i32>, %arg3: tensor<i32>, %arg4: tensor<i32>, %arg5: tensor<i32>):  // no predecessors
    %0 = "mhlo.compare"(%arg2, %arg4) {comparison_direction = "GE"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
    %1 = "mhlo.select"(%0, %arg2, %arg4) : (tensor<i1>, tensor<i32>, tensor<i32>) -> tensor<i32>
    %2 = "mhlo.compare"(%arg2, %arg4) {comparison_direction = "EQ"} : (tensor<i32>, tensor<i32>) -> tensor<i1>
    %3 = mhlo.minimum %arg3, %arg5 : tensor<i32>
    %4 = "mhlo.select"(%0, %arg3, %arg5) : (tensor<i1>, tensor<i32>, tensor<i32>) -> tensor<i32>
    %5 = "mhlo.select"(%2, %3, %4) : (tensor<i1>, tensor<i32>, tensor<i32>) -> tensor<i32>
    "mhlo.return"(%1, %5) : (tensor<i32>, tensor<i32>) -> ()
  }) {dimensions = dense<0> : tensor<1xi64>} : (tensor<9x2xi32>, tensor<9x2xi32>, tensor<i32>, tensor<i32>) -> (tensor<2xi32>, tensor<2xi32>)
  check.expect_eq_const(%res0, dense<[17, 18]> : tensor<2xi32>) : tensor<2xi32>
  check.expect_eq_const(%res1, dense<[16, 17]> : tensor<2xi32>) : tensor<2xi32>
  return
}

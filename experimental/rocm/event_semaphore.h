// Copyright 2021 The IREE Authors
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

#ifndef IREE_HAL_ROCM_SEMAPHORE_H_
#define IREE_HAL_ROCM_SEMAPHORE_H_

#include "experimental/rocm/context_wrapper.h"
#include "experimental/rocm/status_util.h"
#include "iree/hal/api.h"

#ifdef __cplusplus
extern "C" {
#endif  // __cplusplus

// Create a rocm allocator.
iree_status_t iree_hal_rocm_semaphore_create(
    iree_hal_rocm_context_wrapper_t *context, uint64_t initial_value,
    iree_hal_semaphore_t **out_semaphore);

#ifdef __cplusplus
}  // extern "C"
#endif  // __cplusplus

#endif  // IREE_HAL_ROCM_SEMAPHORE_H_

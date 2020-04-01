__kernel void litmus_test(
  __global atomic_uint *ga /* global, atomic locations */,
  __global int *gn /* global, non-atomic locations */,
  __global int *out /* output */,
  __global int *shuffled_ids,
  volatile __global int *scratchpad,
  __global int *bar,
  __global int *scratch_locations, // increment by 2
  int x_loc,
  int y_loc,
  int dwarp_size
) {
  int lid = get_local_id(0);
  int wgid = get_group_id(0);

  if (TEST_THREAD(0,0) || TEST_THREAD(0,1) || TESTING_WARP(0,0) || TESTING_WARP(0,1)) {
    if (PRE_STRESS) {
      // Stress
      for (int i = 0; i < PRE_STRESS_ITERATIONS; i++ ) {
	PRE_STRESS_ITER;
      }
    }
    if (TEST_THREAD(0,0)) {
      // Work-item 0 in workgroup 0:
      test_barrier(&(bar[0]), 2);
      //atomic_fetch_add(&out[0], 1);
      atomic_store_explicit(&ga[x_loc], 2, memory_order_seq_cst, memory_scope_device);
      atomic_store_explicit(&ga[y_loc], 1, memory_order_seq_cst, memory_scope_device);
    } else if (TEST_THREAD(0,1)) {
      // Work-item 0 in workgroup 1:
      test_barrier(&(bar[0]), 2);
      //atomic_fetch_add(&out[1], 1);
      atomic_store_explicit(&ga[y_loc], 2, memory_order_seq_cst, memory_scope_device);
      atomic_store_explicit(&ga[x_loc], 1, memory_order_seq_cst, memory_scope_device);
    }
  }
  else if (MEM_STRESS) {
    // Stress
    for (int i = 0; i < STRESS_ITERATIONS; i++ ) {
      MEM_STRESS_ITER;
    }
  } 
}

__kernel void check_outputs(__global int *output, __global int *result, __global int* ga, int x_loc, int y_loc) {
  
  if (get_global_id(0) == 0) {
    int x = ga[x_loc];
    int y = ga[y_loc];
    if (x == 1 && y == 2) {
      *result = 0;
    }
    else if (x == 2 && y == 1) {
      *result = 1;
    }
    else if (x == 1 && y == 1) {
      *result = 2;
    }
    else if (x == 2 && y == 2) {
      *result = 3;
    }
    else {
      *result = 4;
    }
  }
}

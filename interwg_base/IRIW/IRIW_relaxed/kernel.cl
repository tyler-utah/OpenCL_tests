__kernel void litmus_test(
  __global atomic_uint *ga /* global, atomic locations */,
  __global int *gn /* global, non-atomic locations */,
  __global int *out /* output */,
  __global int *shuffled_ids,
  volatile __global int *scratchpad,
  __global int *bar,
  __global int *scratch_locations,
  int x_loc,
  int y_loc,
  int dwarp_size
) {
  int lid = get_local_id(0);
  int wgid = get_group_id(0);

  if (TEST_THREAD(0,0) || TEST_THREAD(0,1) || TESTING_WARP(0,0) || TESTING_WARP(0,1) ||
      TEST_THREAD(0,3) || TEST_THREAD(0,2) || TESTING_WARP(0,3) || TESTING_WARP(0,2)) {
    if (PRE_STRESS) {
      // Stress
      for (int i = 0; i < PRE_STRESS_ITERATIONS; i++ ) {
	PRE_STRESS_ITER;
      }
    }

    if (TEST_THREAD(0,0)) {
      test_barrier(&(bar[0]),4);
      int tmp1 = atomic_load_explicit(&ga[y_loc], memory_order_relaxed, memory_scope_device);
      int tmp2 = atomic_load_explicit(&ga[x_loc], memory_order_relaxed, memory_scope_device);
      out[0] = tmp1;
      out[1] = tmp2;
    }
    else if (TEST_THREAD(0,1)) {
      test_barrier(&(bar[0]),4);
      int tmp3 = atomic_load_explicit(&ga[x_loc], memory_order_relaxed, memory_scope_device);
      int tmp4 = atomic_load_explicit(&ga[y_loc], memory_order_relaxed, memory_scope_device);
      out[2] = tmp3;
      out[3] = tmp4;
      
    } else if (TEST_THREAD(0,2)) {
      test_barrier(&(bar[0]), 4);
      atomic_store_explicit(&ga[x_loc], 1, memory_order_relaxed, memory_scope_device);
    } else if (TEST_THREAD(0,3)) {
      test_barrier(&(bar[0]), 4);
      atomic_store_explicit(&ga[y_loc], 1, memory_order_relaxed, memory_scope_device);
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
    int r1 = output[0];
    int r2 = output[1];
    int r3 = output[2];
    int r4 = output[3];
    int y = ga[y_loc];    
    if (r1 == 1 && r2 == 0 && r3 == 1 & r4 == 0) {
      *result = 3;
    }
    else {
      *result = 0;
    }
  }
}

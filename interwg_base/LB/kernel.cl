 #include "testing_common.h"

__kernel void litmus_test(
  __global atomic_uint *ga /* global, atomic locations */,
  __global int *gn /* global, non-atomic locations */,
  __global int *out /* output */,
  __global int *shuffled_ids,
  volatile __global int *scratchpad,
  int scratch_location, // increment by 2
  int x_y_distance, // incremented by 2
  int dwarp_size
) {
  int lid = get_local_id(0);
  int wgid = get_group_id(0);
  
  if (TEST_THREAD_0 || TEST_THREAD_1 || TEST_THREAD_2 || TESTING_WARP) {
     if (TEST_THREAD_0) {
       // Work-item 0 in workgroup 0:
	     test_barrier(&(ga[1023]));
       int tmp1 = atomic_load_explicit(&ga[x_y_distance], memory_order_relaxed, memory_scope_device);
       atomic_store_explicit(&ga[0], 1, memory_order_relaxed, memory_scope_device);
       out[0] = tmp1;   
    } else if (TEST_THREAD_1) {
      // Work-item 0 in workgroup 1:               
      test_barrier(&(ga[1023]));
      int tmp2 = atomic_load_explicit(&ga[0], memory_order_relaxed, memory_scope_device);
      atomic_store_explicit(&ga[x_y_distance], 1, memory_order_relaxed, memory_scope_device);
      out[1] = tmp2;
      }
  } 
  else {
   // Stress
    for (int i = 0; i < STRESS_ITERATIONS; i++ ) {
      if (STRESS_STORE_1) {
        scratchpad[scratch_location] = i;
      }
      if (STRESS_LOAD_1) {
	int tmp = scratchpad[scratch_location];
      }
      if (STRESS_STORE_2) {

      if (tmp < 0)
         break;
    }
  }
}



__kernel void check_outputs(__global int *output, __global int *result) {
  
  if (get_global_id(0) == 0) {
    int r1 = output[0];
    int r2 = output[1];
    if (r1 == 0 && r2 == 0) {
      *result = 0;
    }
    else if (r1 == 0 && r2 == 0) {
      *result = 0;
    }
    else if (r1 == 1 && r2 == 0) {
      *result = 1;
    }
    else if (r1 == 0 && r2 == 1) {
      *result = 2;
    }
    else if (r1 == 1 && r2 == 1) {
      *result = 3;
    }
    else {
      *result = 4;
    }
  }
}

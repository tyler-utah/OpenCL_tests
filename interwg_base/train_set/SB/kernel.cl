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
	switch(PRE_STRESS_PATTERN){
	  // st st
	case 0:
	  {
	    scratchpad[SCRATCH_LOC + lid] = i;
	    scratchpad[SCRATCH_LOC + lid] = i + 1;
	    break;
	  }
	//ld ld
	case 1:
	  {
	    int tmp3 = scratchpad[SCRATCH_LOC + lid];
	    int tmp4 = scratchpad[SCRATCH_LOC + lid];
	    if (tmp3 < 0) {
	    }
	    if (tmp4 < 0) {
	    }
	    break;
	  }
	case 2:
	  {
	    int tmp1 = scratchpad[SCRATCH_LOC + lid];
	    scratchpad[SCRATCH_LOC + lid] = i;
	    if (tmp1 < 0) {
	    }
	    break;
	  }
	  // st ld
	default:
	  {
	    scratchpad[SCRATCH_LOC + lid] = i;
	    int tmp = scratchpad[SCRATCH_LOC + lid];
	    if (tmp < 0)
	      break;
	  }   
	}   
      }
    }
    if (TEST_THREAD(0,0)) {
      // Work-item 0 in workgroup 0:
      test_barrier(&(bar[0]), 2);
      //atomic_fetch_add(&out[0], 1);
      atomic_store_explicit(&ga[x_loc], 1, memory_order_relaxed, memory_scope_device);
      int tmp1 = atomic_load_explicit(&ga[y_loc], memory_order_relaxed, memory_scope_device);
      out[0] = tmp1;
    } else if (TEST_THREAD(0,1)) {
      // Work-item 0 in workgroup 1:
      test_barrier(&(bar[0]), 2);
      //atomic_fetch_add(&out[1], 1);
      atomic_store_explicit(&ga[y_loc], 1, memory_order_relaxed, memory_scope_device);
      int tmp2 = atomic_load_explicit(&ga[x_loc], memory_order_relaxed, memory_scope_device);
      out[1] = tmp2;
    }
  }
  else if (MEM_STRESS) {
    // Stress
    for (int i = 0; i < STRESS_ITERATIONS; i++ ) {
      switch(STRESS_PATTERN){
	// st st
      case 0:
	{
	scratchpad[SCRATCH_LOC + lid] = i;
	scratchpad[SCRATCH_LOC + lid] = i + 1;
	break;
	}
	//ld ld
      case 1:
	{
	int tmp3 = scratchpad[SCRATCH_LOC + lid];
	int tmp4 = scratchpad[SCRATCH_LOC + lid];
	if (tmp3 < 0) {
	}
	if (tmp4 < 0) {
	}
	break;
	}
      case 2:
	{
	int tmp1 = scratchpad[SCRATCH_LOC + lid];
	scratchpad[SCRATCH_LOC + lid] = i;
	if (tmp1 < 0) {
	}
	break;
	}
	// st ld
      default:
	{
	scratchpad[SCRATCH_LOC + lid] = i;
	int tmp = scratchpad[SCRATCH_LOC + lid];
	if (tmp < 0)
	  break;
	}   
      }   
    }
  } 
}

__kernel void check_outputs(__global int *output, __global int *result, __global int* ga, int x_loc, int y_loc) {
  
  if (get_global_id(0) == 0) {
    int r1 = output[0];
    int r2 = output[1];
    if (r1 == 0 && r2 == 1) {
      *result = 0;
    }
    else if (r1 == 1 && r2 == 0) {
      *result = 1;
    }
    else if (r1 == 1 && r2 == 1) {
      *result = 2;
    }
    else if (r1 == 0 && r2 == 0) {
      *result = 3;
    }
    else {
      *result = 4;
    }
  }
}
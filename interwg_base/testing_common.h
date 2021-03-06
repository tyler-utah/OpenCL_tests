#ifdef BARRIER
  void test_barrier(__global atomic_int *x, int num_threads) {
    if (BARRIER == 1) {
      int max_iters = 1000;
      int iters = 0;
      int val = atomic_fetch_add_explicit(x, 1, memory_order_relaxed, memory_scope_device);
      while (iters < max_iters && val != num_threads) {
	val = atomic_load_explicit(x, memory_order_relaxed, memory_scope_device);
	iters += 1;
      }
      return;
    }
  }
#else
void test_barrier(__global atomic_int *x, int num_threads) {
  return;
}
#endif

#ifdef ID_SHUFFLE
#if ID_SHUFFLE == 1
#define TEST_THREAD(l,w) (shuffled_ids[get_global_id(0)] == get_local_size(0) * w + (l * dwarp_size))
#define SHUFFLED_WIG (shuffled_ids[get_global_id(0)]/get_local_size(0))
#define SHUFFLED_LID (shuffled_ids[get_global_id(0)] % get_local_size(0))
#define TESTING_WARP(l,w) ((SHUFFLED_WIG == w) && (SHUFFLED_LID/dwarp_size == l/dwarp_size))

#define TEST_THREAD_0 (shuffled_ids[get_global_id(0)] == get_local_size(0) * 0) 
#define TEST_THREAD_1 (shuffled_ids[get_global_id(0)] == get_local_size(0) * 1)
#define TEST_THREAD_2 (shuffled_ids[get_global_id(0)] == get_local_size(0) * 2)
#define TEST_THREAD_3 (shuffled_ids[get_global_id(0)] == get_local_size(0) * 3)

#else
#define TEST_THREAD(l, w) (lid == l && wgid == w)
#define TESTING_WARP(l, w) (wgid == w && (lid/dwarp_size == l/dwarp_size))
#endif

#else
#define TEST_THREAD(l, w) (lid == l && wgid == w)
#define TESTING_WARP(l, w) (wgid == w && (lid/dwarp_size == l/dwarp_size))
#endif

#ifndef SCRATCH_LOC
#define SCRATCH_LOC (scratch_locations[get_global_id(0)])
#endif

#ifndef MEM_STRESS
#define MEM_STRESS 0
#endif

#ifndef PRE_STRESS
#define PRE_STRESS 0
#endif

#ifndef PRE_STRESS_ITERATIONS
#define PRE_STRESS_ITERATIONS 100
#endif

// Case 0 is st st
// Case 1 is ld ld
// Case 2 is ld st
// Case 3 is st ld

#define PRE_STRESS_ITER \
  	switch(PRE_STRESS_PATTERN){ \
	case 0:\
	  { \
	    scratchpad[SCRATCH_LOC + lid] = i; \
	    scratchpad[SCRATCH_LOC + lid] = i + 1; \
	    break; \
	  } \
	case 1: \
	  { \
	    int tmp3 = scratchpad[SCRATCH_LOC + lid]; \
	    int tmp4 = scratchpad[SCRATCH_LOC + lid]; \
	    if (tmp3 < 0 && tmp4 < 0) { \
	      scratchpad[SCRATCH_LOC + lid] = lid; \
	    } \
	    break; \
	  } \
	case 2: \
	  { \
	    int tmp1 = scratchpad[SCRATCH_LOC + lid]; \
	    scratchpad[SCRATCH_LOC + lid] = i; \
	    if (tmp1 < 0) { \
	      scratchpad[SCRATCH_LOC + lid] = lid; \
	    } \
	    break; \
	  } \
	default: \
	  { \
	    scratchpad[SCRATCH_LOC + lid] = i; \
	    int tmp = scratchpad[SCRATCH_LOC + lid]; \
	    if (tmp < 0) {\
	      scratchpad[SCRATCH_LOC + lid] = lid; \
	    } \
	      break; \
	  } \
	  }


#ifndef PRE_STRESS_PATTERN
#define PRE_STRESS_PATTERN 3
#endif

#ifndef STRESS_ITERATIONS
#define STRESS_ITERATIONS 512
#endif

// Case 0 is st st
// Case 1 is ld ld
// Case 2 is ld st
// Case 3 is st ld

#define MEM_STRESS_ITER  \
 switch(STRESS_PATTERN){\
      case 0: \
	{ \
	scratchpad[SCRATCH_LOC + lid] = i; \
	scratchpad[SCRATCH_LOC + lid] = i + 1; \
	break; \
	} \
      case 1: \
	{ \
	int tmp3 = scratchpad[SCRATCH_LOC + lid]; \
	int tmp4 = scratchpad[SCRATCH_LOC + lid]; \
	if (tmp3 < 0 && tmp4 < 0) { \
	  scratchpad[SCRATCH_LOC + lid] = lid; \
	} \
	break; \
	}      \
      case 2: \
	{ \
	int tmp1 = scratchpad[SCRATCH_LOC + lid]; \
	scratchpad[SCRATCH_LOC + lid] = i; \
	if (tmp1 < 0) { \
	  scratchpad[SCRATCH_LOC + lid] = lid; \
	} \
	break; \
	} \
      default: \
	{ \
	scratchpad[SCRATCH_LOC + lid] = i; \
	int tmp = scratchpad[SCRATCH_LOC + lid]; \
	if (tmp < 0) { \
	  scratchpad[SCRATCH_LOC + lid] = lid; \
	}\
	  break; \
	}\
      }

#ifndef STRESS_PATTERN
#define STRESS_PATTERN 3
#endif

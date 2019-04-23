
#ifdef BARRIER
  void test_barrier(__global atomic_int *x, int num_threads) {
    int max_iters = 1000;
    int iters = 0;
    int val = atomic_fetch_add_explicit(x, 1, memory_order_relaxed, memory_scope_device);
    while (iters < max_iters && val != num_threads) {
      val = atomic_load_explicit(x, memory_order_relaxed, memory_scope_device);
      iters += 1;
    }
    return;
  }
#else
  void test_barrier(__global atomic_int *x, int num_threads) {
    return;
  }
#endif

#ifdef ID_SHUFFLE
#define TEST_THREAD(l,w) (shuffled_ids[get_global_id(0)] == get_local_size(0) * w + (l * dwarp_size))
#define SHUFFLED_WIG (shuffled_ids[get_global_id(0)]/get_local_size(0))
#define SHUFFLED_LID (shuffled_ids[get_global_id(0)] % get_local_size(0))
#define TESTING_WARP(l,w) ((SHUFFLED_WIG == w) && (SHUFFLED_LID/dwarp_size == l/dwarp_size))

#define TEST_THREAD_0 (shuffled_ids[get_global_id(0)] == get_local_size(0) * 0) 
#define TEST_THREAD_1 (shuffled_ids[get_global_id(0)] == get_local_size(0) * 1)
#define TEST_THREAD_2 (shuffled_ids[get_global_id(0)] == get_local_size(0) * 2)
#define TEST_THREAD_3 (shuffled_ids[get_global_id(0)] == get_local_size(0) * 3)
#define TESTING_WARP ((shuffled_ids[get_global_id(0)] > get_local_size(0) * 0) && (shuffled_ids[get_global_id(0)] < get_local_size(0) * 0 + dwarp_size)) || ((shuffled_ids[get_global_id(0)] > get_local_size(0) * 1) && (shuffled_ids[get_global_id(0)] < get_local_size(0) * 1 + dwarp_size))
#else
#define TEST_THREAD(l, w) (lid == l && wgid == w)
#define TESTING_WARP(l, w) (wgid == w && (lid/dwarp_size == l/dwarp_size))
#endif 

#ifndef MEM_STRESS
#define MEM_STRESS 0
#endif

#ifndef STRESS_ITERATIONS
#define STRESS_ITERATIONS 512
#endif

#ifndef STRESS_PATTERN
#define STRESS_PATTERN 0
#endif

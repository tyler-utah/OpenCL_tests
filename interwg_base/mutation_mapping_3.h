
inline int atomic_load_explicit_seq_cst(__global atomic_uint *a) {
#if defined(NVIDIA)
  return nv_atomic_load_explicit_seq_cst(a);
#else
  return atomic_load_explicit(a, memory_order_seq_cst, memory_scope_device);
#endif
}

inline int atomic_load_explicit_acquire(__global atomic_uint *a) {
#if defined(NVIDIA)
    return nv_atomic_load_explicit_acquire(a);
#else
    return atomic_load_explicit(a, memory_order_acquire, memory_scope_device);
#endif   
}

inline int atomic_load_explicit_relaxed(__global atomic_uint *a) {
#if defined(NVIDIA)
  return nv_atomic_load_explicit_relaxed(a);
#else
    return atomic_load_explicit(a, memory_order_relaxed, memory_scope_device);
#endif
}

//relaxing store seq cst to store release in this mutant
inline void atomic_store_explicit_seq_cst(__global atomic_uint *a, uint v) {
#if defined(NVIDIA)
  nv_atomic_store_explicit_release(a,v);
#else
  atomic_store_explicit(a, v, memory_order_release, memory_scope_device);
#endif
}

inline void atomic_store_explicit_release(__global atomic_uint *a, uint v) {
#if defined(NVIDIA)
  nv_atomic_store_explicit_release(a,v);
#else
  atomic_store_explicit(a, v, memory_order_release, memory_scope_device);
#endif
}

inline void atomic_store_explicit_relaxed(__global atomic_uint *a, uint v) {
#if defined(NVIDIA)
  nv_atomic_store_explicit_relaxed(a,v);
#else
  atomic_store_explicit(a, v, memory_order_relaxed, memory_scope_device);
#endif
}



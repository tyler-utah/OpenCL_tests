#if !(__OPENCL_C_VERSION__ >= 200) && !(defined(NVIDIA))
#pragma once

//A (very small) subset of the opencl 2.0  atomics for OpenCL 1.x devices. 
//WARNING: This is best effort attempt and is not guaranteed to work for
//any device. It seems to work for ARM Mali-T628, but experimentally it has
//not worked for pre CL 2.0 AMD or Intel devices. Use at your own risk.

//Only one variant of each instruction is supported!! Please Check

typedef volatile int atomic_int;
typedef volatile uint atomic_uint;


// Added sub_group scope, but don't check for anywhere (relaxed accesses don't have fences anyways)
typedef enum {memory_scope_device, memory_scope_sub_group, memory_scope_work_group} memory_scope;
typedef enum {memory_order_relaxed, memory_order_release, memory_order_acquire, memory_order_acq_rel} memory_order;

//This is atomic_fetch_add_explicit(v,o, memory_order_acq_rel, memory_scope_device)
int atomic_fetch_add_explicit(__global volatile atomic_int* target, int operand, memory_order mo, memory_scope ms) {  
  int ret = 0;

  //mem_fence(CLK_GLOBAL_MEM_FENCE | CLK_LOCAL_MEM_FENCE);

  ret =  atomic_add(target, operand);

  //mem_fence(CLK_GLOBAL_MEM_FENCE | CLK_LOCAL_MEM_FENCE);

  return ret;  
}

//This is atomic_store_explicit(v,v, memory_order_release, memory_scope_device
void atomic_store_explicit(__global volatile atomic_int* target, int val, const memory_order mo, const memory_scope ms) {

  //mem_fence(CLK_GLOBAL_MEM_FENCE | CLK_LOCAL_MEM_FENCE);

  // On ARM mali-t628 this seems to be required (otherwise mutexes deadlock). I know its sketchy, but really running
  // this code on a non-Nvidia and non-OpenCL 2.0 device is just going to be sketchy regardless.
  //atomic_xchg(target, val);
  *target = val;

  //mem_fence(CLK_GLOBAL_MEM_FENCE | CLK_LOCAL_MEM_FENCE);
}

//This is atomic_load_explict(v, memory_order_relaxed, memory_scope_device)
int atomic_load_explicit(__global volatile atomic_int* target, const memory_order mo, const memory_scope ms) {
  int ret = 0;
  
  ret = *target;

  return ret;
}

//This is atomic_work_item_fence(memory_order_acquire, memory_scope_device)
void atomic_work_item_fence(const cl_mem_fence_flags flags, const memory_order mo, const memory_scope ms) {
  mem_fence(CLK_GLOBAL_MEM_FENCE | CLK_LOCAL_MEM_FENCE);
}

//This is atomic_exchange_explicit(v, v, v, memory_order_acquire, memory_scope_device)
int atomic_exchange_explicit(__global volatile atomic_int* target, const int desired, const memory_order mo, const memory_scope ms) {
  int old = 0;

  // (not so) fun fact. If you remove this fence, on ARM Mali-T628, mutexes will deadlock, i.e. threads will spin
  // waiting for the lock indefinitely even after the lock is free. This means that the fence is required to propogate
  // the value through the cache. 
  //
  // The big take away is that memory has nasty temporal properties which can be effected by fences. GPUs are weird.
  //mem_fence(CLK_GLOBAL_MEM_FENCE | CLK_LOCAL_MEM_FENCE);

  old = atomic_xchg(target, desired);
    
  //mem_fence(CLK_GLOBAL_MEM_FENCE | CLK_LOCAL_MEM_FENCE);

  return old;
}
#endif

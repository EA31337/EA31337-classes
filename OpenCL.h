#ifndef __MQL__
#pragma once
#endif

#include "DictStruct.mqh"

// Defines.
#define OPENCL_PROGRAM_MAX_ARGS 8

// Forward declarations;
class OpenCLProgram;

/**
 * Memory buffer.
 */
class OpenCLBuffer : public Dynamic {
  // Handle to memory buffer.
  int buffer_handle;

  // Allocated buffer size.
  int buffer_size;

  // Buffer version. Should be incremented after each change.
  long version;

 public:
  /**
   * Constructor.
   */
  OpenCLBuffer(int _size, unsigned int _flags = CL_MEM_READ_WRITE);

  /**
   * Writes/uploads data into buffer if needed.
   */
  void Write(const ARRAY_REF(double, _arr), long _arr_version = -1) {
    if (ArraySize(_arr) > buffer_size) {
      Alert("Array passed is too large for the allocated buffer. Tries to pass ", ArraySize(_arr),
            " elements into buffer of size ", buffer_size, ".");
      DebugBreak();
      return;
    }

    // Do we need to reupload data into GPU?
    if (_arr_version != -1 && _arr_version <= version) {
      // Buffer has already up-to-date data.
      return;
    }

    CLBufferWrite(buffer_handle, _arr);

    version = (_arr_version != -1) ? _arr_version : (version + 1);
  }

  /**
   * Reads data from buffer.
   */
  void Read(ARRAY_REF(double, _arr)) {
    if (!ArrayIsDynamic(_arr) && ArraySize(_arr) < buffer_size) {
      Alert("Array passed is too small to be the target. Buffer has size ", buffer_size,
            " and you tried to read it into buffer of size ", ArraySize(_arr), ".");
      DebugBreak();
      return;
    }
    ArrayResize(_arr, buffer_size);
    CLBufferRead(buffer_handle, _arr);
  }

  /**
   * Returns buffer size in bytes.
   */
  int GetSizeBytes() { return buffer_size * sizeof(double); }

  /**
   * Returns buffer size in items.
   */
  int GetSizeItems() { return buffer_size; }

  /**
   * Returns data version.
   */
  long GetVersion() { return version; }

  /**
   * Returns handle to buffer.
   */
  int GetHandle() { return buffer_handle; }

  /**
   * Destructor.
   */
  ~OpenCLBuffer() {
    if (buffer_handle != INVALID_HANDLE) {
      CLBufferFree(buffer_handle);
    }
  }
};

/**
 * Single program (code) + kernel (function name) to be invoked.
 */
class OpenCLProgram : public Dynamic {
  // Handle to program.
  int program_handle;

  // Handle to kernel.
  int kernel_handle;

  // Buffer handles previously passed as arguments. Used to check if buffer needs to be reuploaded.
  int arg_handles[OPENCL_PROGRAM_MAX_ARGS];

  // Version of argument data. Used to check if buffer needs to be reuploaded.
  long arg_versions[OPENCL_PROGRAM_MAX_ARGS];

 public:
  /**
   * Constructor.
   */
  OpenCLProgram() : program_handle(INVALID_HANDLE), kernel_handle(INVALID_HANDLE) {
    for (int i = 0; i < OPENCL_PROGRAM_MAX_ARGS; ++i) {
      arg_handles[i] = INVALID_HANDLE;
      arg_versions[i] = -1;
    }
  }

  /**
   * Destructor.
   */
  ~OpenCLProgram() {
    if (kernel_handle != INVALID_HANDLE) {
      CLKernelFree(kernel_handle);
    }

    if (program_handle != INVALID_HANDLE) {
      CLProgramFree(program_handle);
    }
  }

  /**
   * Passes local memory size argument to the kernel.
   */
  void SetArgLocalMem(int _index, unsigned long _mem_size) { CLSetKernelArgMemLocal(kernel_handle, _index, _mem_size); }

  /**
   * Passes argument to the kernel. Will not set kernel argument if not needed.
   *
   * Note that buffer reuploading is to be done via OpenCLBuffer::Write() in
   * which you can pass version of your data, so no reupload will take place if
   * your version isn't greater that the one already set in the buffer.
   */
  void SetArg(int _index, double value) { CLSetKernelArg(kernel_handle, _index, value); }
  void SetArg(int _index, int value) { CLSetKernelArg(kernel_handle, _index, value); }

  /**
   * Passes argument to the kernel. Will not set kernel argument if not needed.
   *
   * Note that buffer reuploading is to be done via OpenCLBuffer::Write() in
   * which you can pass version of your data, so no reupload will take place if
   * your version isn't greater that the one already set in the buffer.
   */
  void SetArg(int _index, OpenCLBuffer* _buffer) {
    if (_buffer PTR_DEREF GetHandle() == arg_handles[_index] &&
        _buffer PTR_DEREF GetVersion() >= arg_versions[_index]) {
      // Already uploaded recent version.
      return;
    }

    CLSetKernelArgMem(kernel_handle, _index, _buffer PTR_DEREF GetHandle());

    // Buffer will occupy argument slot.
    arg_handles[_index] = _buffer PTR_DEREF GetHandle();

    // Storing buffer version in the argument slot.
    arg_versions[_index] = _buffer PTR_DEREF GetVersion();
  }

  /**
   * Executes a single kernel.
   */
  bool Run() {
    if (!CLExecute(kernel_handle)) {
      Alert("OpenCL error occured when tried to run kernel: ", GetLastError(), "!");
      return false;
    }

    return true;
  }

  /**
   * Executes a single kernel. Allows passing arugments to kernel.
   */
  template <typename A>
  bool Run(A a) {
    SetArg(0, a);
    return Run();
  }

  /**
   * Executes a single kernel. Allows passing arugments to kernel.
   */
  template <typename A, typename B>
  bool Run(A a, B b) {
    SetArg(0, a);
    SetArg(1, b);
    return Run();
  }

  /**
   * Executes a single kernel. Allows passing arugments to kernel.
   */
  template <typename A, typename B, typename C>
  bool Run(A a, B b, C c) {
    SetArg(0, a);
    SetArg(1, b);
    SetArg(2, c);
    return Run();
  }

  /**
   * Executes a single kernel. Allows passing arugments to kernel.
   */
  template <typename A, typename B, typename C, typename D>
  bool Run(A a, B b, C c, D d) {
    SetArg(0, a);
    SetArg(1, b);
    SetArg(2, c);
    SetArg(3, d);
    return Run();
  }

  /**
   * Executes a single kernel. Allows passing arugments to kernel.
   */
  template <typename A, typename B, typename C, typename D, typename E>
  bool Run(A a, B b, C c, D d, E e) {
    SetArg(0, a);
    SetArg(1, b);
    SetArg(2, c);
    SetArg(3, d);
    SetArg(4, e);
    return Run();
  }

  /**
   * Executes a single kernel. Allows passing arugments to kernel.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F>
  bool Run(A a, B b, C c, D d, E e, F f) {
    SetArg(0, a);
    SetArg(1, b);
    SetArg(2, c);
    SetArg(3, d);
    SetArg(4, e);
    SetArg(5, f);
    return Run();
  }

  /**
   * Executes a single kernel. Allows passing arugments to kernel.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G>
  bool Run(A a, B b, C c, D d, E e, F f, G g) {
    SetArg(0, a);
    SetArg(1, b);
    SetArg(2, c);
    SetArg(3, d);
    SetArg(4, e);
    SetArg(5, f);
    SetArg(6, g);
    return Run();
  }

  /**
   * Executes a single kernel. Allows passing arugments to kernel.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H>
  bool Run(A a, B b, C c, D d, E e, F f, G g, H h) {
    SetArg(0, a);
    SetArg(1, b);
    SetArg(2, c);
    SetArg(3, d);
    SetArg(4, e);
    SetArg(5, f);
    SetArg(6, g);
    SetArg(7, h);
    return Run();
  }

  /**
   * Executes multiple kernels where work is subdivided among kernels.
   */
  bool RunMany(unsigned int _dimension, const ARRAY_REF(unsigned int, _global_work_offset),
               const ARRAY_REF(unsigned int, _global_work_size), const ARRAY_REF(unsigned int, _local_work_size)) {
    if (!CLExecute(kernel_handle, _dimension, _global_work_offset, _global_work_size, _local_work_size)) {
      Alert("OpenCL error occured when tried to run kernel: ", GetLastError(), "!");
      return false;
    }

    return true;
  }

  /**
   * Executes multiple kernels where work is subdivided among kernels. Allows passing arugments to kernels.
   */
  template <typename A>
  bool RunMany(unsigned int _dimension, const ARRAY_REF(unsigned int, _global_work_offset),
               const ARRAY_REF(unsigned int, _global_work_size), const ARRAY_REF(unsigned int, _local_work_size), A a) {
    SetArg(0, a);
    return RunMany(_dimension, _global_work_offset, _global_work_size, _local_work_size);
  }

  /**
   * Executes multiple kernels where work is subdivided among kernels. Allows passing arugments to kernels.
   */
  template <typename A, typename B>
  bool RunMany(unsigned int _dimension, const ARRAY_REF(unsigned int, _global_work_offset),
               const ARRAY_REF(unsigned int, _global_work_size), const ARRAY_REF(unsigned int, _local_work_size), A a,
               B b) {
    SetArg(0, a);
    SetArg(1, b);
    return RunMany(_dimension, _global_work_offset, _global_work_size, _local_work_size);
  }

  /**
   * Executes multiple kernels where work is subdivided among kernels. Allows passing arugments to kernels.
   */
  template <typename A, typename B, typename C>
  bool RunMany(unsigned int _dimension, const ARRAY_REF(unsigned int, _global_work_offset),
               const ARRAY_REF(unsigned int, _global_work_size), const ARRAY_REF(unsigned int, _local_work_size), A a,
               B b, C c) {
    SetArg(0, a);
    SetArg(1, b);
    SetArg(2, c);
    return RunMany(_dimension, _global_work_offset, _global_work_size, _local_work_size);
  }

  /**
   * Executes multiple kernels where work is subdivided among kernels. Allows passing arugments to kernels.
   */
  template <typename A, typename B, typename C, typename D>
  bool RunMany(unsigned int _dimension, const ARRAY_REF(unsigned int, _global_work_offset),
               const ARRAY_REF(unsigned int, _global_work_size), const ARRAY_REF(unsigned int, _local_work_size), A a,
               B b, C c, D d) {
    SetArg(0, a);
    SetArg(1, b);
    SetArg(2, c);
    SetArg(3, d);
    return RunMany(_dimension, _global_work_offset, _global_work_size, _local_work_size);
  }

  /**
   * Executes multiple kernels where work is subdivided among kernels. Allows passing arugments to kernels.
   */
  template <typename A, typename B, typename C, typename D, typename E>
  bool RunMany(unsigned int _dimension, const ARRAY_REF(unsigned int, _global_work_offset),
               const ARRAY_REF(unsigned int, _global_work_size), const ARRAY_REF(unsigned int, _local_work_size), A a,
               B b, C c, D d, E e) {
    SetArg(0, a);
    SetArg(1, b);
    SetArg(2, c);
    SetArg(3, d);
    SetArg(4, e);
    return RunMany(_dimension, _global_work_offset, _global_work_size, _local_work_size);
  }

  /**
   * Executes multiple kernels where work is subdivided among kernels. Allows passing arugments to kernels.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F>
  bool RunMany(unsigned int _dimension, const ARRAY_REF(unsigned int, _global_work_offset),
               const ARRAY_REF(unsigned int, _global_work_size), const ARRAY_REF(unsigned int, _local_work_size), A a,
               B b, C c, D d, E e, F f) {
    SetArg(0, a);
    SetArg(1, b);
    SetArg(2, c);
    SetArg(3, d);
    SetArg(4, e);
    SetArg(5, f);
    return RunMany(_dimension, _global_work_offset, _global_work_size, _local_work_size);
  }

  /**
   * Executes multiple kernels where work is subdivided among kernels. Allows passing arugments to kernels.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G>
  bool RunMany(unsigned int _dimension, const ARRAY_REF(unsigned int, _global_work_offset),
               const ARRAY_REF(unsigned int, _global_work_size), const ARRAY_REF(unsigned int, _local_work_size), A a,
               B b, C c, D d, E e, F f, G g) {
    SetArg(0, a);
    SetArg(1, b);
    SetArg(2, c);
    SetArg(3, d);
    SetArg(4, e);
    SetArg(5, f);
    SetArg(6, g);
    return RunMany(_dimension, _global_work_offset, _global_work_size, _local_work_size);
  }

  /**
   * Executes multiple kernels where work is subdivided among kernels. Allows passing arugments to kernels.
   */
  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H>
  bool RunMany(unsigned int _dimension, const ARRAY_REF(unsigned int, _global_work_offset),
               const ARRAY_REF(unsigned int, _global_work_size), const ARRAY_REF(unsigned int, _local_work_size), A a,
               B b, C c, D d, E e, F f, G g, H h) {
    SetArg(0, a);
    SetArg(1, b);
    SetArg(2, c);
    SetArg(3, d);
    SetArg(4, e);
    SetArg(5, f);
    SetArg(6, g);
    SetArg(7, h);
    return RunMany(_dimension, _global_work_offset, _global_work_size, _local_work_size);
  }

  /**
   * Returns handle to OpenCL program.
   */
  int GetProgramHandle() { return program_handle; }

  /**
   * Sets handle to OpenCL program.
   */
  void SetProgramHandle(int _handle) {
    if (program_handle != -1) {
      Alert("Cannot change program handle!");
      DebugBreak();
      return;
    }
    program_handle = _handle;
  }

  /**
   * Returns handle to OpenCL kernel.
   */
  int GetKernelHandle() { return kernel_handle; }

  /**
   * Sets handle to OpenCL kernel.
   */
  void SetKernelHandle(int _handle) {
    if (kernel_handle != -1) {
      Alert("Cannot change kernel handle!");
      DebugBreak();
      return;
    }
    kernel_handle = _handle;
  }
};

/**
 * Wrapper for OpenCL.
 */
class OpenCL {
  // OpenCL handles.
  static int context_handle;

  // OpenCL memory handles.
  static int cl_mem_0, cl_mem_1, cl_mem_2;

  DictStruct<int, Ref<OpenCLProgram>> programs;

 public:
  /**
   * Initializes CL contexts. Called automatically by OpenCLLifetimeManager.
   */
  static void Initialize() {
    context_handle = CLContextCreate();
    if (context_handle == INVALID_HANDLE) {
      Alert("Could not create OpenCL context. Error code: ", GetLastError(), ".");
      DebugBreak();
      return;
    }
  }

  /**
   * Frees CL contexts. Called automatically by OpenCLLifetimeManager.
   */
  static void Deinitialize() { CLContextFree(context_handle); }

  /**
   * Allocates memory to be later passed to OpenCLProgram.
   */
  static OpenCLBuffer* Alloc(int _size, unsigned int _flags) { return new OpenCLBuffer(_size, _flags); }

  /**
   * Compiles given program and returns its id or -1 in case of error.
   */
  static OpenCLProgram* Compile(string _source, string _fn_name) {
    OpenCLProgram* _program = new OpenCLProgram();

    // Log of CLProgramCreate().
    string _compilation_log;

    _program PTR_DEREF SetProgramHandle(CLProgramCreate(context_handle, _source, _compilation_log));

    if (_program PTR_DEREF GetProgramHandle() == INVALID_HANDLE) {
      Alert("Could not create OpenCL program. Error code: ", GetLastError(), ". Compilation log: ", _compilation_log,
            ".");
      DebugBreak();
      return nullptr;
    }

    _program PTR_DEREF SetKernelHandle(CLKernelCreate(_program PTR_DEREF GetProgramHandle(), _fn_name));

    if (_program PTR_DEREF GetKernelHandle() == INVALID_HANDLE) {
      Alert("Could not create OpenCL kernel. Error code: ", GetLastError(), ".");
      DebugBreak();
      return nullptr;
    }

    return _program;
  }

  /**
   * Returns handle to OpenCL context.
   */
  static int GetContextHandle() { return context_handle; }
};

static int OpenCL::context_handle;

/**
 * Manages initialization and deinitialization of static variables for OpenCL class.
 */
class OpenCLLifetimeManager {
 public:
  OpenCLLifetimeManager() { OpenCL::Initialize(); }

  ~OpenCLLifetimeManager() { OpenCL::Deinitialize(); }
};

OpenCLLifetimeManager __opencl_lifetime_manager;

/**
 * OpenCLBuffer constructor.
 */
OpenCLBuffer::OpenCLBuffer(int _size, unsigned int _flags) {
  buffer_handle = CLBufferCreate(OpenCL::GetContextHandle(), _size * sizeof(double), _flags);
  if (buffer_handle == INVALID_HANDLE) {
    Alert("Could not create OpenCL buffer. Error code: ", GetLastError(), ".");
    DebugBreak();
  }
  buffer_size = _size;
  version = 0;
}

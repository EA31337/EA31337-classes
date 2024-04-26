#ifndef __MQL__
#pragma once
#endif

#include "DictStruct.mqh"

// Defines.
#define OPENCL_PROGRAM_MAX_ARGS 8

// Forward declarations;
class OpenCLProgram;
template <typename X>
class Matrix;

// Type of the matrix passed as argument to the OpenCLProgram.
enum ENUM_OPENCL_MATRIX_ARG { OPENCL_MATRIX_ARG_IN_1, OPENCL_MATRIX_ARG_IN_2, OPENCL_MATRIX_ARG_OUT };

/**
 * Memory buffer.
 */
class OpenCLBuffer : public Dynamic {
  // Handle to memory buffer.
  int buffer_handle;

  // Allocated buffer size.
  int buffer_size;

  // Version of the data. The same one that was passed to the Write() method.
  unsigned long version;

 public:
  /**
   * Constructor.
   */
  OpenCLBuffer(int _size, unsigned int _flags = CL_MEM_READ_WRITE);

  /**
   * Checks whether stored data version differs from the passed version.
   */
  bool RequiresReupload(unsigned long _data_version) { return _data_version == ULONG_MAX || version != _data_version; }

  /**
   * Writes/uploads data into buffer if needed.
   */
  void Write(const ARRAY_REF(double, _arr), unsigned long _data_version = ULONG_MAX) {
    if (ArraySize(_arr) > buffer_size) {
      Alert("Array passed is too large for the allocated buffer. Tries to pass ", ArraySize(_arr),
            " elements into buffer of size ", buffer_size, ".");
      DebugBreak();
      return;
    }

    if (!RequiresReupload(_data_version)) {
      return;
    }

    CLBufferWrite(buffer_handle, _arr);

    version = _data_version;
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
  unsigned long GetVersion() { return version; }

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
  unsigned long arg_versions[OPENCL_PROGRAM_MAX_ARGS];

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
   * Checks whether given argument requires reupload of the buffer into GPU.
   */
  bool RequiresReupload(int _index, OpenCLBuffer* _buffer, unsigned long _data_version) {
    return _buffer PTR_DEREF GetHandle() != arg_handles[_index] || _data_version != arg_versions[_index];
  }

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
  void SetArg(int _index, OpenCLBuffer* _buffer, unsigned long _data_version) {
    if (!RequiresReupload(_index, _buffer, _data_version)) {
      // Buffer is already set via CLSetKernelArgMem() and argument's version
      // is the same as _data_version.
      return;
    }

    CLSetKernelArgMem(kernel_handle, _index, _buffer PTR_DEREF GetHandle());

    // Buffer will occupy argument slot.
    arg_handles[_index] = _buffer PTR_DEREF GetHandle();

    // Storing buffer version in the argument slot.
    arg_versions[_index] = _buffer PTR_DEREF GetVersion();
  }

  /**
   * Passes matrix argument to the kernel. Will not upload data if not needed.
   *
   * The idea is to retrieve existing buffer that matches matrix size and its
   * purpose. If such buffer already exists in the same version in the argument
   * slot then no reupload will take place.
   */
  template <typename X>
  void SetArg(int _index, Matrix<X>& _matrix, ENUM_OPENCL_MATRIX_ARG _matrix_type) {
    unsigned long _matrix_data_version = _matrix.GetVersion();
    OpenCLBuffer* _buffer = nullptr;

    switch (_matrix_type) {
      case OPENCL_MATRIX_ARG_IN_1:
        _buffer = GetCLBufferInArg0(_matrix.GetSize());
        break;

      case OPENCL_MATRIX_ARG_IN_2:
        _buffer = GetCLBufferInArg1(_matrix.GetSize());
        break;

      case OPENCL_MATRIX_ARG_OUT:
        _buffer = GetCLBufferOutArg(_matrix.GetSize());
        break;
    }

    if (RequiresReupload(_index, _buffer, _matrix_data_version)) {
      // Flattening matrix data in order to upload it into GPU.
      double _flattened_data[];
      _matrix.GetRawArray(_flattened_data);

      _buffer PTR_DEREF Write(_flattened_data)

          // Do we need to reupload the data?
          SetArg(_index, _buffer, _matrix_data_version);
    }
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
  // Ensuring there won't be initial version clash when checking if buffer data
  // need to be reuploaded.
  version = ULONG_MAX;
}

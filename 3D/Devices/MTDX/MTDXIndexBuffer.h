#include "../../IndexBuffer.h"

class MTDXIndexBuffer : public IndexBuffer {
public:

  MTDXIndexBuffer(Device* _device) : IndexBuffer(_device) {}
  
protected:
  
  int handle;

  /**
   * Creates index buffer.
   */
  virtual bool Create(void*& _data[]) {
    //handle = DXBufferCreate(Device().Context(), DX_BUFFER_INDEX, &_data);
    return handle != INVALID_HANDLE;
  }

  /**
   * Destructor;
   */  
  ~MTDXIndexBuffer() {
    DXRelease(handle);
  }
  
  /**
   * Fills index buffer with indices.
   */
  virtual void Fill(unsigned int& _indices[]) {
    handle = DXBufferCreate(GetDevice().Context(), DX_BUFFER_INDEX, _indices);
  }
  
  /**
   * Activates index buffer for rendering.
   */
  virtual void Select() {
    Print("Selecting indices ", handle);
    DXBufferSet(GetDevice().Context(), handle);
    Print("Select: LastError: ", GetLastError());
  }
};
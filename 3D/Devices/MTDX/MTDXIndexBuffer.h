#include "../../IndexBuffer.h"

class MTDXIndexBuffer : public IndexBuffer {
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
  
  ~MTDXIndexBuffer() {
    //DXRelease()
  }
};
#include "../../IndexBuffer.h"

class MTDXIndexBuffer : public IndexBuffer {
  MTDXIndexBuffer(Device* _device) : IndexBuffer(_device) {}

  /**
   * Creates index buffer.
   */
  virtual bool Create(void*& _data[]) {
    // DXBufferCreate(((MTDXDevice*)Device()).Context(), DX_BUFFER_INDEX, &_data);
    return true;
  }
};
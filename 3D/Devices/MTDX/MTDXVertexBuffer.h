#include "../../VertexBuffer.h"

class MTDXVertexBuffer : public VertexBuffer {
 public:
  /**
   * Creates vertex buffer.
   */
  virtual bool Create(void*& _data[]) {
    DXBufferCreate(((MTDXDevice*)GetDevice()).Context(), DX_BUFFER_VERTEX, _data);
    return true;
  }
};
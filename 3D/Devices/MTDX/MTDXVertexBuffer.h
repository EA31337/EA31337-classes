#include "../../VertexBuffer.h"

class MTDXVertexBuffer : public VertexBuffer {

  int handle;

 public:
 
  MTDXVertexBuffer(Device *_device) : VertexBuffer(_device) {}
  
  ~MTDXVertexBuffer() {
    DXRelease(handle);
  }
  
public:
  
  /**
   * Creates vertex buffer.
   */
  template<typename X>
  bool Fill(X& _data[]) {
    handle = DXBufferCreate(GetDevice().Context(), DX_BUFFER_VERTEX, _data);
    Print("Created vb ", handle);
    Print("Fill: LastError: ", GetLastError());
    return true;
  }
  
  virtual void Select() {
    Print("Selecting vb ", handle);
    DXBufferSet(GetDevice().Context(), handle);
    Print("Select: LastError: ", GetLastError());
  }
};
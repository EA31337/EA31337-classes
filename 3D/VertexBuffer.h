#include "../Refs.mqh"

class VertexBuffer : public Dynamic {
  WeakRef<Device> device;

 public:
  /**
   * Constructor.
   */
  VertexBuffer(Device* _device) { device = _device; }

  /**
   * Returns base graphics device.
   */
  Device* GetDevice() { return device.Ptr(); }
  
  virtual void Select() = NULL;
};
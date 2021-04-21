#include "../Refs.mqh"

class Device;

/**
 * Vertices' index buffer.
 */
class IndexBuffer : public Dynamic {
  WeakRef<Device> device;

 public:
  /**
   * Constructor.
   */
  IndexBuffer(Device* _device) { device = _device; }

  /**
   * Returns base graphics device.
   */
  Device* GetDevice() { return device.Ptr(); }

  /**
   * Creates index buffer.
   */
  virtual bool Create(void*& _data[]) = NULL;
  
  /**
   * Fills index buffer with indices.
   */
  virtual void Fill(unsigned int& _indices[]) = NULL;
  
  /**
   * Activates index buffer for rendering.
   */
  virtual void Select() = NULL;
};
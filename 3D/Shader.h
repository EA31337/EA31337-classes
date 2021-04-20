#include "../Refs.mqh"

enum ENUM_SHADER_TYPE {
  SHADER_TYPE_VS,
  SHADER_TYPE_PS,
};

class Device;

enum ENUM_GFX_VAR_TYPE_FLOAT { GFX_VAR_TYPE_INT32, GFX_VAR_TYPE_FLOAT };

struct ShaderVertexLayout {
  string name;
  unsigned int index;
  ENUM_GFX_VAR_TYPE_FLOAT type;
  unsigned int num_components;
  bool clamped;
  unsigned int stride;
  unsigned int offset;
};

/**
 * Unified vertex/pixel shader.
 */
class Shader : public Dynamic {
  WeakRef<Device> device;

 public:
  /**
   * Constructor.
   */
  Shader(Device* _device) { device = _device; }

  /**
   * Returns base graphics device.
   */
  Device* GetDevice() { return device.Ptr(); }
  
  virtual void Select() = NULL;
};
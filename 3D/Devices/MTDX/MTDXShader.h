#include "../../Shader.h"

class MTDXShader : public Shader {
  int handle;

 public:
  MTDXShader(Device *_device) : Shader(_device) {}

  bool Create(ENUM_SHADER_TYPE _type, string _source_code, string _entry_point = "main") {
    string error_text;

    handle = DXShaderCreate(((MTDXDevice *)GetDevice()).Context(),
                            _type == SHADER_TYPE_VS ? DX_SHADER_VERTEX : DX_SHADER_PIXEL, _source_code, _entry_point,
                            error_text);

    return true;
  }

  /**
   * Sets vertex/pixel data layout to be used by shader.
   */
  virtual void SetDataLayout(const ShaderVertexLayout &_layout[]) {
    // DXShaderSetLayout(handle, _layout);
  }
};
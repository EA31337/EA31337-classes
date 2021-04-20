#include "../../Shader.h"

class MTDXShader : public Shader {
  int handle;

 public:
  MTDXShader(Device *_device) : Shader(_device) {}

  bool Create(ENUM_SHADER_TYPE _type, string _source_code, string _entry_point = "main") {
    string error_text;

    handle = DXShaderCreate(GetDevice().Context(),
                            _type == SHADER_TYPE_VS ? DX_SHADER_VERTEX : DX_SHADER_PIXEL, _source_code, _entry_point,
                            error_text);

    return true;
  }

  /**
   * Sets vertex/pixel data layout to be used by shader.
   */
  virtual void SetDataLayout(const ShaderVertexLayout &_layout[]) {
    // Converting generic layout into MT5 DX's one.
    
    DXVertexLayout _target_layout[];    
    ArrayResize(_target_layout, ArraySize(_layout));
    
    for (int i = 0; i < ArraySize(_layout); ++i) {
      _target_layout[i].semantic_name = _layout[i].name;
      _target_layout[i].semantic_index = _layout[i].index;
      _target_layout[i].format = ParseFormat(_layout[i]);
    }
  
    DXShaderSetLayout(handle, _target_layout);
    Print("DXShaderSetLayout: LastError: ", GetLastError());
  }
  
  ENUM_DX_FORMAT ParseFormat(const ShaderVertexLayout& _layout) {
    if (_layout.type == GFX_VAR_TYPE_FLOAT) {
      switch (_layout.num_components) {
        case 1: return DX_FORMAT_R32_FLOAT;
        case 2: return DX_FORMAT_R32G32_FLOAT;
        case 3: return DX_FORMAT_R32G32B32_FLOAT;
        case 4: return DX_FORMAT_R32G32B32A32_FLOAT;
        default:
          Alert("Too many components in vertex layout!");
      }
    }

    Alert("Wrong vertex layout!");
    return (ENUM_DX_FORMAT)0;
  }
  
  virtual void Select() {
    DXShaderSet(GetDevice().Context(), handle);
  }
};
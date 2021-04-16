#include "../../Device.h"

class MTDXDevice : public Device {
 protected:
  int context;

 public:
  /**
   * Initializes graphics device.
   */
  bool Init(Frontend* _frontend) {
    context = DXContextCreate(_frontend.Width(), _frontend.Height());

    return true;
  }

  /**
   * Deinitializes graphics device.
   */
  bool Deinit() { return true; }

  /**
   * Starts rendering loop.
   */
  virtual bool RenderBegin() { return true; }

  /**
   * Ends rendering loop.
   */
  virtual bool RenderEnd() { return true; }

  /**
   * Returns DX context's id.
   */
  int Context() { return context; }

  /**
   * Clears color buffer.
   */
  /**
   * Clears color buffer.
   */
  virtual void ClearBuffer(ENUM_CLEAR_BUFFER_TYPE _type, unsigned int _color = 0x000000) {
    if (_type == CLEAR_BUFFER_TYPE_COLOR) {
      DXVector _dx_color;
      _dx_color.x = 1;
      DXContextClearColors(context, _dx_color);
    } else if (_type == CLEAR_BUFFER_TYPE_DEPTH) {
      DXContextClearDepth(context);
    }
  }

  /**
   * Creates index buffer to be used by current graphics device.
   */
  IndexBuffer* IndexBuffer() { return NULL; }

  /**
   * Creates vertex shader to be used by current graphics device.
   */
  virtual Shader* VertexShader(string _source_code, const ShaderVertexLayout& _layout[], string _entry_point = "main") {
    MTDXShader* _shader = new MTDXShader(&this);
    _shader.Create(SHADER_TYPE_VS, _source_code, _entry_point);
    _shader.SetDataLayout(_layout);
    return _shader;
  }

  /**
   * Creates pixel shader to be used by current graphics device.
   */
  virtual Shader* PixelShader(string _source_code, string _entry_point = "main") {
    MTDXShader* _shader = new MTDXShader(&this);
    _shader.Create(SHADER_TYPE_PS, _source_code, _entry_point);
    return _shader;
  }

  /**
   * Creates vertex buffer to be used by current graphics device.
   */
  VertexBuffer* VertexBuffer() { return NULL; }
};
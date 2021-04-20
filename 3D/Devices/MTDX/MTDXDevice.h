#include "../../Device.h"

class MTDXDevice : public Device {
 public:
  /**
   * Initializes graphics device.
   */
  bool Init(Frontend* _frontend) {
    Print("MTDXDevice: DXContextCreate: width = ", _frontend.Width(), ", height = ", _frontend.Height());
    context = DXContextCreate(_frontend.Width(), _frontend.Height());
    Print("LastError: ", GetLastError());
    Print("MTDXDevice: context = ", context);
    _frontend.Init();
    return true;
  }

  /**
   * Deinitializes graphics device.
   */
  bool Deinit() {
    DXRelease(context);
    return true;
  }

  /**
   * Starts rendering loop.
   */
  virtual bool RenderBegin() {
    return true;
  }

  /**
   * Ends rendering loop.
   */
  virtual bool RenderEnd() {
    return true;
  }
  
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
      _dx_color.x = 1.0f / 255.0f * ((_color & 0x00FF0000) >> 16);
      _dx_color.y = 1.0f / 255.0f * ((_color & 0x0000FF00) >> 8);
      _dx_color.z = 1.0f / 255.0f * ((_color & 0x000000FF) >> 0);
      _dx_color.w = 1.0f / 255.0f * ((_color & 0xFF000000) >> 24);
      DXContextClearColors(context, _dx_color);
      Print("LastError: ", GetLastError());
    } else if (_type == CLEAR_BUFFER_TYPE_DEPTH) {
      DXContextClearDepth(context);
      Print("LastError: ", GetLastError());
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
  VertexBuffer* VertexBuffer() {
    return new MTDXVertexBuffer(&this);
  }
  
  virtual void Render(VertexBuffer* _vertices, IndexBuffer* _indices = NULL) {
    _vertices.Select();
    DXPrimiveTopologySet(context, DX_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    if (_indices == NULL) {
      if (!DXDraw(context)) {
        Print("Can't draw!");
      }
      Print("DXDraw: LastError: ", GetLastError());
    }
    else {
      //_indices.Select();
      DXDrawIndexed(context);
    }
    
  }
};
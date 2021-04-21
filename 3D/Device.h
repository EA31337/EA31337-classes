#include "../Refs.mqh"
#include "Frontend.h"
#include "IndexBuffer.h"
#include "Shader.h"
#include "VertexBuffer.h"

enum ENUM_CLEAR_BUFFER_TYPE { CLEAR_BUFFER_TYPE_COLOR, CLEAR_BUFFER_TYPE_DEPTH };

/**
 * Graphics device.
 */
class Device : public Dynamic {
protected:

  int context;
  Ref<Frontend> frontend; 
  
 public:
 
  bool Start(Frontend* _frontend) {
    frontend = _frontend;
    return Init(_frontend);
  }

  Device* Begin(unsigned int clear_color = 0) {
    frontend.Ptr().RenderBegin(context);
    ClearDepth();
    Clear(clear_color);
    RenderBegin();
    return &this;
  }

  Device* End() {
    RenderEnd();
    frontend.Ptr().RenderEnd(context);
    return &this;
  }

  Device* Stop() {
    Deinit();
    return &this;
  }

  Device* Clear(unsigned int _color = 0xFF000000) {
    ClearBuffer(CLEAR_BUFFER_TYPE_COLOR, _color);
    return &this;
  }

  Device* ClearDepth() {
    ClearBuffer(CLEAR_BUFFER_TYPE_DEPTH, 0);
    return &this;
  }
  
  /**
   * Returns graphics device context as integer.
   */
  int Context() { return context; }

  /**
   * Creates vertex shader to be used by current graphics device.
   */
  virtual Shader* VertexShader(string _source_code, const ShaderVertexLayout& _layout[],
                               string _entry_point = "main") = NULL;

  /**
   * Creates pixel shader to be used by current graphics device.
   */
  virtual Shader* PixelShader(string _source_code, string _entry_point = "main") = NULL;

  /**
   * Creates vertex buffer to be used by current graphics device.
   */
  template<typename T>
  VertexBuffer* VertexBuffer(T& data[]) {
    VertexBuffer* _buff = VertexBuffer();
    // Unfortunately we can't make this method virtual.
    if (dynamic_cast<MTDXVertexBuffer*>(_buff) != NULL) {
      // MT5's DirectX.
      Print("Filling vertex buffer via MTDXVertexBuffer");
      ((MTDXVertexBuffer*)_buff).Fill<T>(data);
    }
    else {
      Alert("Unsupported vertex buffer device target");
    }
    return _buff;
  }

  /**
   * Creates vertex buffer to be used by current graphics device.
   */
  virtual VertexBuffer* VertexBuffer() = NULL;

  /**
   * Creates index buffer to be used by current graphics device.
   */
  virtual IndexBuffer* IndexBuffer(unsigned int& _indices[]) = NULL;
  
  /**
   * Renders vertex buffer with optional point indices.
   */
  virtual void Render(VertexBuffer* _vertices, IndexBuffer* _indices = NULL) = NULL;
  
  /**
   * Activates shader for rendering.
   */
  void SetShader(Shader *_shader) {
    _shader.Select();
  }

  /**
   * Activates shaders for rendering.
   */
  void SetShader(Shader *_shader1, Shader *_shader2) {
    _shader1.Select();
    _shader2.Select();
  }

 protected:
 
  /**
   * Initializes graphics device.
   */
  virtual bool Init(Frontend*) = NULL;

  /**
   * Deinitializes graphics device.
   */
  virtual bool Deinit() = NULL;

  /**
   * Starts rendering loop.
   */
  virtual bool RenderBegin() = NULL;

  /**
   * Ends rendering loop.
   */
  virtual bool RenderEnd() = NULL;

  /**
   * Clears color buffer.
   */
  virtual void ClearBuffer(ENUM_CLEAR_BUFFER_TYPE _type, unsigned int _color) = NULL;
};
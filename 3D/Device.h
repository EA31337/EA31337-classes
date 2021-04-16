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
 public:
  bool Start(Frontend* _frontend) { return Init(_frontend); }

  Device* Begin() {
    Clear(0x000000);
    RenderBegin();
    return &this;
  }

  Device* End() {
    RenderEnd();
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
   * Creates index buffer to be used by current graphics device.
   */
  virtual IndexBuffer* IndexBuffer() = NULL;

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
  virtual VertexBuffer* VertexBuffer() = NULL;

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
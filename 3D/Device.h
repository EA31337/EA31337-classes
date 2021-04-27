//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Generic graphics device.
 */

#include "../Refs.mqh"
#include "Frontend.h"
#include "IndexBuffer.h"
#include "Math.h"
#include "Mesh.h"
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
  /**
   * Initializes graphics device.
   */
  bool Start(Frontend* _frontend) {
    frontend = _frontend;
    return Init(_frontend);
  }

  /**
   * Begins render loop.
   */
  Device* Begin(unsigned int clear_color = 0) {
    frontend.Ptr().RenderBegin(context);
    ClearDepth();
    Clear(clear_color);
    RenderBegin();
    return &this;
  }

  /**
   * Ends render loop.
   */
  Device* End() {
    RenderEnd();
    frontend.Ptr().RenderEnd(context);
    return &this;
  }

  /**
   * Deinitializes graphics device.
   */
  Device* Stop() {
    Deinit();
    return &this;
  }

  /**
   * Clears scene's color buffer.
   */
  Device* Clear(unsigned int _color = 0xFF000000) {
    ClearBuffer(CLEAR_BUFFER_TYPE_COLOR, _color);
    return &this;
  }

  /**
   * Begins scene's depth buffer.
   */
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
  template <typename T>
  VertexBuffer* VertexBuffer(T& data[]) {
    VertexBuffer* _buff = VertexBuffer();
    // Unfortunately we can't make this method virtual.
    if (dynamic_cast<MTDXVertexBuffer*>(_buff) != NULL) {
      // MT5's DirectX.
      Print("Filling vertex buffer via MTDXVertexBuffer");
      ((MTDXVertexBuffer*)_buff).Fill<T>(data);
    } else {
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
   * Renders given mesh.
   */
  template <typename T>
  void Render(Mesh<T>* _mesh) {
    Print("Rendering mesh");
    VertexBuffer* _vertices;
    IndexBuffer* _indices;
    _mesh.GetBuffers(&this, _vertices, _indices);
    Render(_vertices, _indices);
  }

  /**
   * Activates shader for rendering.
   */
  void SetShader(Shader* _shader) { _shader.Select(); }

  /**
   * Activates shaders for rendering.
   */
  void SetShader(Shader* _shader1, Shader* _shader2) {
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
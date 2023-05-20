//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
#include "../Util.h"
#include "Frontend.h"
#include "IndexBuffer.h"
#include "Material.h"
#include "Math.h"
#include "Mesh.h"
#include "Shader.h"
#include "VertexBuffer.h"

enum GFX_DRAW_TEXT_FLAGS { GFX_DRAW_TEXT_FLAG_NONE, GFX_DRAW_TEXT_FLAG_2D_COORD_X, GFX_DRAW_TEXT_FLAG_2D_COORD_Y };

enum ENUM_CLEAR_BUFFER_TYPE { CLEAR_BUFFER_TYPE_COLOR, CLEAR_BUFFER_TYPE_DEPTH };

/**
 * Graphics device.
 */
class Device : public Dynamic {
 protected:
  int context;
  Ref<Frontend> frontend;
  DXMatrix mtx_stack[];
  DXMatrix mtx_world;
  DXMatrix mtx_view;
  DXMatrix mtx_projection;
  DXVector3 lightdir;
  Material material;

 public:
  /**
   * Initializes graphics device.
   */
  bool Start(Frontend* _frontend) {
    frontend = _frontend;
    DXMatrixIdentity(mtx_world);
    DXMatrixIdentity(mtx_view);
    DXMatrixIdentity(mtx_projection);
    TSR _identity;
    PushTransform(_identity);
    lightdir = DXVector3(-0.2f, 0.2f, 1.0f);
    return Init(_frontend);
  }

  void PushTransform(const TSR& tsr) {
    Util::ArrayPush(mtx_stack, mtx_world);
    DXMatrixMultiply(mtx_world, tsr.ToMatrix(), mtx_world);
  }

  void PopTransform() { mtx_world = Util::ArrayPop(mtx_stack); }

  /**
   * Begins render loop.
   */
  Device* Begin(unsigned int clear_color = 0) {
    frontend.Ptr().RenderBegin(context);
    Clear(clear_color);
    ClearDepth();
    RenderBegin();
    return &this;
  }

  /**
   * Ends render loop.
   */
  Device* End() {
    RenderEnd();
    frontend.Ptr().RenderEnd(context);
    frontend.Ptr().ProcessDrawText();
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
   * Returns current material.
   */
  Material GetMaterial() { return material; }

  /**
   * Assigns material for later rendering.
   */
  void SetMaterial(Material& _material) { material = _material; }

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
#ifdef __debug__
      Print("Filling vertex buffer via MTDXVertexBuffer");
#endif
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
  void Render(VertexBuffer* _vertices, IndexBuffer* _indices = NULL) { RenderBuffers(_vertices, _indices); }

  /**
   * Renders vertex buffer with optional point indices.
   */
  virtual void RenderBuffers(VertexBuffer* _vertices, IndexBuffer* _indices = NULL) = NULL;

  /**
   * Renders given mesh.
   */
  template <typename T>
  void Render(Mesh<T>* _mesh, Shader* _vs = NULL, Shader* _ps = NULL) {
#ifdef __debug__
    Print("Rendering mesh");
#endif
    VertexBuffer* _vertices;
    IndexBuffer* _indices;
    _mesh.GetBuffers(&this, _vertices, _indices);

    SetMaterial(_mesh.GetMaterial());

    PushTransform(_mesh.GetTSR());

    SetShader(_vs != NULL ? _vs : _mesh.GetShaderVS());
    SetShader(_ps != NULL ? _ps : _mesh.GetShaderPS());

    Render(_vertices, _indices);

    PopTransform();
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

  /**
   * Returns front-end's viewport width.
   */
  int Width() { return frontend.Ptr().Width(); }

  /**
   * Returns front-end's viewport height.
   */
  int Height() { return frontend.Ptr().Height(); }

  void SetCameraOrtho3D(float _pos_x = 0.0f, float _pos_y = 0.0f, float _pos_z = 0.0f) {
    DXMatrixOrthoLH(mtx_projection, 1.0f * _pos_z, 1.0f / Width() * Height() * _pos_z, -10000, 10000);
  }

  DXMatrix GetWorldMatrix() { return mtx_world; }

  void SetWorldMatrix(DXMatrix& _matrix) { mtx_world = _matrix; }

  DXMatrix GetViewMatrix() { return mtx_view; }

  void SetViewMatrix(DXMatrix& _matrix) { mtx_view = _matrix; }

  DXMatrix GetProjectionMatrix() { return mtx_projection; }

  void SetProjectionMatrix(DXMatrix& _matrix) { mtx_projection = _matrix; }

  DXVector3 GetLightDirection() { return lightdir; }

  void SetLightDirection(float x, float y, float z) {
    lightdir.x = x;
    lightdir.y = y;
    lightdir.z = z;
  }

  /**
   * Enqueues text to be drawn directly into the pixel buffer. Queue will be processed in the Device::End() method.
   */
  void DrawText(float _x, float _y, string _text, unsigned int _color = 0xFFFFFFFF, unsigned int _align = 0,
                unsigned int _flags = 0) {
    DViewport _viewport;
    _viewport.x = 0;
    _viewport.y = 0;
    _viewport.width = frontend.Ptr().Width();
    _viewport.height = frontend.Ptr().Height();
    _viewport.minz = -10000.0f;
    _viewport.maxz = 10000.0f;

    DXVector3 _vec3_in(_x, _y, 0.0f);
    DXVector3 _vec3_out;
    DXVec3Project(_vec3_out, _vec3_in, _viewport, GetProjectionMatrix(), GetViewMatrix(), GetWorldMatrix());

    if ((_flags & GFX_DRAW_TEXT_FLAG_2D_COORD_X) == GFX_DRAW_TEXT_FLAG_2D_COORD_X) {
      _vec3_out.x = _x;
    }

    if ((_flags & GFX_DRAW_TEXT_FLAG_2D_COORD_Y) == GFX_DRAW_TEXT_FLAG_2D_COORD_Y) {
      _vec3_out.y = _y;
    }

    frontend.Ptr().DrawText(_vec3_out.x, _vec3_out.y, _text, _color, _align);
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

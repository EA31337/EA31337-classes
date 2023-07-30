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
 * MetaTrader DX-targeted graphics device.
 */

#include "../../Device.h"

class MTDXDevice : public Device {
 public:
  /**
   * Initializes graphics device.
   */
  bool Init(Frontend* _frontend) {
#ifdef __debug__
    Print("MTDXDevice: DXContextCreate: width = ", _frontend.Width(), ", height = ", _frontend.Height());
#endif
    context = DXContextCreate(_frontend.Width(), _frontend.Height());
#ifdef __debug__
    Print("LastError: ", GetLastError());
    Print("MTDXDevice: context = ", context);
#endif
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
      _dx_color.x = 1.0f / 255.0f * ((_color & 0x00FF0000) >> 16);
      _dx_color.y = 1.0f / 255.0f * ((_color & 0x0000FF00) >> 8);
      _dx_color.z = 1.0f / 255.0f * ((_color & 0x000000FF) >> 0);
      _dx_color.w = 1.0f / 255.0f * ((_color & 0xFF000000) >> 24);
      DXContextClearColors(context, _dx_color);
#ifdef __debug__
      Print("DXContextClearColors: LastError: ", GetLastError());
#endif
    } else if (_type == CLEAR_BUFFER_TYPE_DEPTH) {
      DXContextClearDepth(context);
#ifdef __debug__
      Print("DXContextClearDepth: LastError: ", GetLastError());
#endif
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
  VertexBuffer* VertexBuffer() { return new MTDXVertexBuffer(&this); }

  /**
   * Creates index buffer to be used by current graphics device.
   */
  virtual IndexBuffer* IndexBuffer(unsigned int& _indices[]) {
    IndexBuffer* _buffer = new MTDXIndexBuffer(&this);
    _buffer.Fill(_indices);
    return _buffer;
  }

  /**
   *
   */
  virtual void RenderBuffers(VertexBuffer* _vertices, IndexBuffer* _indices = NULL) {
    DXPrimiveTopologySet(context, DX_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
    _vertices.Select();
    if (_indices == NULL) {
      if (!DXDraw(context)) {
#ifdef __debug__
        Print("Can't draw!");
#endif
      }
#ifdef __debug__
      Print("DXDraw: LastError: ", GetLastError());
#endif
    } else {
      _indices.Select();
      DXDrawIndexed(context);
#ifdef __debug__
      Print("DXDrawIndexed: LastError: ", GetLastError());
#endif
    }
  }
};

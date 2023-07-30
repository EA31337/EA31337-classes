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
 * MetaTrader DX-targeted unversal graphics shader.
 */

#include "../../Shader.h"

class MTDXShader : public Shader {
  // DX context handle.
  int handle;

  // DX MVP's C-Buffer handle (register b0).
  int cbuffer_mvp_handle;

  MVPBuffer mvp_buffer;

  // DX C-Buffer handle. (register b1).
  int cbuffer_handle;

 public:
  /**
   * Constructor.
   */
  MTDXShader(Device* _device) : Shader(_device) {}

  /**
   * Destructor.
   */
  ~MTDXShader() {
    DXRelease(cbuffer_handle);
    DXRelease(cbuffer_mvp_handle);
    DXRelease(handle);
  }

  /**
   * Creates a shader.
   */
  bool Create(ENUM_SHADER_TYPE _type, string _source_code, string _entry_point = "main") {
    string error_text;

    handle = DXShaderCreate(GetDevice().Context(), _type == SHADER_TYPE_VS ? DX_SHADER_VERTEX : DX_SHADER_PIXEL,
                            _source_code, _entry_point, error_text);

#ifdef __debug__
    Print("DXShaderCreate: LastError: ", GetLastError(), ", ErrorText: ", error_text);
#endif

    cbuffer_handle = 0;

    // Creating MVP buffer.
    cbuffer_mvp_handle = DXInputCreate(GetDevice().Context(), sizeof(MVPBuffer));
#ifdef __debug__
    Print("DXInputCreate (mvp): LastError: ", GetLastError());
#endif

    return true;
  }

  /**
   * Sets vertex/pixel data layout to be used by shader.
   */
  virtual void SetDataLayout(const ShaderVertexLayout& _layout[]) {
    // Converting generic layout into MT5 DX's one.

    DXVertexLayout _target_layout[];
    ArrayResize(_target_layout, ArraySize(_layout));

#ifdef __debug__
    Print("ArrayResize: LastError: ", GetLastError());
#endif

    int i;

    for (i = 0; i < ArraySize(_layout); ++i) {
      _target_layout[i].semantic_name = _layout[i].name;
      _target_layout[i].semantic_index = _layout[i].index;
      _target_layout[i].format = ParseFormat(_layout[i]);
    }

#ifdef __debug__
    for (i = 0; i < ArraySize(_target_layout); ++i) {
      Print(_target_layout[i].semantic_name, ", ", _target_layout[i].semantic_index, ", ",
            EnumToString(_target_layout[i].format));
    }

    Print("before DXShaderSetLayout: LastError: ", GetLastError());
#endif

    DXShaderSetLayout(handle, _target_layout);

#ifdef __debug__
    Print("DXShaderSetLayout: LastError: ", GetLastError());
#endif

    ResetLastError();
  }

#ifdef __MQL5__
  /**
   * Converts vertex layout's item into required DX's color format.
   */
  ENUM_DX_FORMAT ParseFormat(const ShaderVertexLayout& _layout) {
    if (_layout.type == GFX_VAR_TYPE_FLOAT) {
      switch (_layout.num_components) {
        case 1:
          return DX_FORMAT_R32_FLOAT;
        case 2:
          return DX_FORMAT_R32G32_FLOAT;
        case 3:
          return DX_FORMAT_R32G32B32_FLOAT;
        case 4:
          return DX_FORMAT_R32G32B32A32_FLOAT;
        default:
          Alert("Too many components in vertex layout!");
      }
    }

    Alert("Wrong vertex layout!");
    return (ENUM_DX_FORMAT)0;
  }
#endif

  /**
   * Sets custom input buffer for shader.
   */
  template <typename X>
  void SetCBuffer(const X& data) {
    if (cbuffer_handle == 0) {
      cbuffer_handle = DXInputCreate(GetDevice().Context(), sizeof(X));
#ifdef __debug__
      Print("DXInputCreate: LastError: ", GetLastError());
#endif

      int _input_handles[1];
      _input_handles[0] = cbuffer_handle;

      DXShaderInputsSet(handle, _input_handles);
#ifdef __debug__
      Print("DXShaderInputsSet: LastError: ", GetLastError());
#endif
    }

    DXInputSet(cbuffer_handle, data);
#ifdef __debug__
    Print("DXInputSet: LastError: ", GetLastError());
#endif
  }

  /**
   * Selectes shader to be used by graphics device for rendering.
   */
  virtual void Select() {
    // Setting MVP transform and material information.

    DXMatrixTranspose(mvp_buffer.world, GetDevice().GetWorldMatrix());
    DXMatrixTranspose(mvp_buffer.view, GetDevice().GetViewMatrix());
    DXMatrixTranspose(mvp_buffer.projection, GetDevice().GetProjectionMatrix());
    mvp_buffer.lightdir = GetDevice().GetLightDirection();
    mvp_buffer.mat_color = GetDevice().GetMaterial().Color;

    if (cbuffer_handle == 0) {
      int _input_handles[1];
      _input_handles[0] = cbuffer_mvp_handle;
      DXShaderInputsSet(handle, _input_handles);
    } else {
      int _input_handles[2];
      _input_handles[0] = cbuffer_mvp_handle;
      _input_handles[1] = cbuffer_handle;
      DXShaderInputsSet(handle, _input_handles);
    }

#ifdef __debug__
    Print("DXShaderInputsSet: LastError: ", GetLastError());
#endif

    DXInputSet(cbuffer_mvp_handle, mvp_buffer);
    DXShaderSet(GetDevice().Context(), handle);
  }
};

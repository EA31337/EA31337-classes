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
 * Generic graphics shader.
 */

#include "../Refs.mqh"

// Shader type.
enum ENUM_SHADER_TYPE {
  SHADER_TYPE_VS,
  SHADER_TYPE_PS,
};

class Device;
class MTDXShader;

enum ENUM_GFX_VAR_TYPE_FLOAT { GFX_VAR_TYPE_INT32, GFX_VAR_TYPE_FLOAT };

// Note that shader buffers's size must be multiple of 4!
struct MVPBuffer {
  DXMatrix world;
  DXMatrix view;
  DXMatrix projection;
  DXVector3 lightdir;

 private:
  float _unused1;

 public:
  DXColor mat_color;

 private:
  // char _unused2[1];
};

// Vertex layout used for Vertex Shaders.
struct ShaderVertexLayout {
  string name;
  unsigned int index;
  ENUM_GFX_VAR_TYPE_FLOAT type;
  unsigned int num_components;
  bool clamped;
  unsigned int stride;
  unsigned int offset;
};

/**
 * Unified vertex/pixel shader.
 */
class Shader : public Dynamic {
  // Reference to graphics device.
  WeakRef<Device> device;

 public:
  /**
   * Constructor.
   */
  Shader(Device* _device) { device = _device; }

  /**
   * Returns base graphics device.
   */
  Device* GetDevice() { return device.Ptr(); }

  /**
   * Sets custom input buffer for shader.
   */
  template <typename X>
  void SetCBuffer(const X& data) {
    // Unfortunately we can't make this method virtual.
    if (dynamic_cast<MTDXShader*>(&this) != NULL) {
// MT5's DirectX.
#ifdef __debug__
      Print("Setting CBuffer data for MT5");
#endif
      ((MTDXShader*)&this).SetCBuffer(data);
    } else {
      Alert("Unsupported cbuffer device target");
    }
  }

  /**
   * Selectes shader to be used by graphics device for rendering.
   */
  virtual void Select() = NULL;
};

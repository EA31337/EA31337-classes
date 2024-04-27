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
 * Generic graphics index buffer.
 */

#include "../Refs.mqh"

class Device;

/**
 * Vertices' index buffer.
 */
class IndexBuffer : public Dynamic {
  WeakRef<Device> device;

 public:
  /**
   * Constructor.
   */
  IndexBuffer(Device* _device) { device = _device; }

  /**
   * Returns base graphics device.
   */
  Device* GetDevice() { return device.Ptr(); }

  /**
   * Creates index buffer.
   */
  virtual bool Create(void*& _data[]) = NULL;

  /**
   * Fills index buffer with indices.
   */
  virtual void Fill(unsigned int& _indices[]) = NULL;

  /**
   * Activates index buffer for rendering.
   */
  virtual void Select() = NULL;
};

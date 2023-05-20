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
 * MetaTrader DX-targeted graphics device's index buffer.
 */

#include "../../IndexBuffer.h"

class MTDXIndexBuffer : public IndexBuffer {
 public:
  MTDXIndexBuffer(Device* _device) : IndexBuffer(_device) {}

 protected:
  int handle;

  /**
   * Creates index buffer.
   */
  virtual bool Create(void*& _data[]) {
    // handle = DXBufferCreate(Device().Context(), DX_BUFFER_INDEX, &_data);
    return handle != INVALID_HANDLE;
  }

  /**
   * Destructor;
   */
  ~MTDXIndexBuffer() { DXRelease(handle); }

  /**
   * Fills index buffer with indices.
   */
  virtual void Fill(unsigned int& _indices[]) {
    handle = DXBufferCreate(GetDevice().Context(), DX_BUFFER_INDEX, _indices);
  }

  /**
   * Activates index buffer for rendering.
   */
  virtual void Select() {
#ifdef __debug__
    Print("Selecting indices ", handle);
#endif
    DXBufferSet(GetDevice().Context(), handle);
#ifdef __debug__
    Print("Select: LastError: ", GetLastError());
#endif
  }
};

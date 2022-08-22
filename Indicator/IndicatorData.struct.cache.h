//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
 * IndicatorBufferValueStorage class.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Refs.mqh"
#include "../Storage/ValueStorage.h"

/**
 * Holds buffers used to cache values calculated via OnCalculate methods.
 */
template <typename C>
class IndicatorCalculateCache : public Dynamic {
 public:
  // Total number of calculated values.
  int prev_calculated;

  // Number of prices to use.
  int total;

  // Whether cache was initialized with price buffer.
  bool initialized;

  // Buffer to store input prices. Won't be deleted!
  ValueStorage<C> *price_buffer;

  // Buffer to store input open prices. Won't be deleted!
  ValueStorage<C> *price_open_buffer;

  // Buffer to store input high prices. Won't be deleted!
  ValueStorage<C> *price_high_buffer;

  // Buffer to store input low prices. Won't be deleted!
  ValueStorage<C> *price_low_buffer;

  // Buffer to store input close prices. Won't be deleted!
  ValueStorage<C> *price_close_buffer;

  // Buffers used for OnCalculate calculations.
  ARRAY(IValueStorage *, buffers);

  // Auxiliary caches related to this one.
  ARRAY(IndicatorCalculateCache<C> *, subcaches);

  /**
   * Constructor.
   */
  IndicatorCalculateCache(int _buffers_size = 0) {
    prev_calculated = 0;
    total = 0;
    initialized = false;
    Resize(_buffers_size);
  }

  /**
   * Destructor.
   */
  ~IndicatorCalculateCache() {
    int i;

    for (i = 0; i < ArraySize(buffers); ++i) {
      if (buffers[i] != NULL) {
        delete buffers[i];
      }
    }

    for (i = 0; i < ArraySize(subcaches); ++i) {
      if (subcaches[i] != NULL) {
        delete subcaches[i];
      }
    }
  }

  /**
   * Returns size of the current price buffer.
   */
  int GetTotal() { return price_buffer != NULL ? ArraySize(price_buffer) : ArraySize(price_open_buffer); }

  /**
   * Returns number of already calculated prices (bars).
   */
  int GetPrevCalculated() { return prev_calculated; }

  /**
   * Whether cache have any buffer.
   */
  bool HasBuffers() { return ArraySize(buffers) != 0; }

  /**
   * Returns number of added buffers.
   */
  int NumBuffers() { return ArraySize(buffers); }

  /**
   * Returns existing or new cache as a child of current one. Useful when indicator uses other indicators and requires
   * unique caches for them.
   */
  IndicatorCalculateCache<C> *GetSubCache(int index) {
    if (index >= ArraySize(subcaches)) {
      ArrayResize(subcaches, index + 1, 10);
    }

    if (subcaches[index] == NULL) {
      subcaches[index] = new IndicatorCalculateCache();
    }

    return subcaches[index];
  }

  /**
   * Add buffer of the given type. Usage: AddBuffer<NativeBuffer>()
   */
  template <typename T>
  int AddBuffer(int _num_buffers = 1) {
    IValueStorage *_ptr;

    while (_num_buffers-- > 0) {
      _ptr = new T();
      ArrayPushObject(buffers, _ptr);
    }

    return ArraySize(buffers) - 1;
  }

  /**
   * Returns given calculation buffer.
   */
  template <typename D>
  ValueStorage<D> *GetBuffer(int _index) {
    return (ValueStorage<D> *)buffers[_index];
  }

  /**
   * Returns main price buffer.
   */
  ValueStorage<C> *GetPriceBuffer() { return price_buffer; }

  /**
   * Returns given price buffer.
   */
  ValueStorage<C> *GetPriceBuffer(ENUM_APPLIED_PRICE _applied_price) {
    switch (_applied_price) {
      case PRICE_OPEN:
        return price_open_buffer;
      case PRICE_HIGH:
        return price_high_buffer;
      case PRICE_LOW:
        return price_low_buffer;
      case PRICE_CLOSE:
        return price_close_buffer;
    }
    return NULL;
  }

  /**
   * Sets price buffer for later use.
   */
  void SetPriceBuffer(ValueStorage<C> &_price, int _total = 0) {
    price_buffer = &_price;

    if (_total == 0) {
      _total = _price.Size();
    }

    total = _total;

    // Cache is ready to be used.
    initialized = true;
  }

  /**
   * Sets price buffers for later use.
   */
  void SetPriceBuffer(ValueStorage<C> &_price_open, ValueStorage<C> &_price_high, ValueStorage<C> &_price_low,
                      ValueStorage<C> &_price_close, int _total = 0) {
    price_open_buffer = &_price_open;
    price_high_buffer = &_price_high;
    price_low_buffer = &_price_low;
    price_close_buffer = &_price_close;

    if (_total == 0) {
      _total = _price_open.Size();
    }

    total = _total;

    // Cache is ready to be used.
    initialized = true;
  }

  /**
   * Resizes all buffers.
   */
  void Resize(int _buffers_size) {
    for (int i = 0; i < ArraySize(buffers); ++i) {
      buffers[i].Resize(_buffers_size, 65535);
    }
  }

  /**
   * Retrieves cached value from the given buffer.
   */
  template <typename D>
  D GetValue(int _buffer_index, int _shift) {
    return GetBuffer<D>(_buffer_index).Fetch(_shift).Get();
  }

  /**
   *
   */
  template <typename D>
  D GetTailValue(int _buffer_index, int _shift) {
    ValueStorage<D> *_buff = GetBuffer<D>(_buffer_index);
    int _index = _buff.IsSeries() ? _shift : (ArraySize(_buff) - _shift - 1);
    return _buff[_index].Get();
  }

  /**
   * Updates prev_calculated value used by indicator's OnCalculate method.
   */
  void SetPrevCalculated(int _prev_calculated) {
    if (_prev_calculated == 0) {
      ResetPrevCalculated();
    } else {
      prev_calculated = _prev_calculated;
    }
  }

  /**
   * Resets prev_calculated value used by indicator's OnCalculate method.
   */
  void ResetPrevCalculated() { prev_calculated = 0; }

  /**
   * Returns prev_calculated value used by indicator's OnCalculate method.
   */
  int GetPrevCalculated(int _prev_calculated) { return prev_calculated; }
};

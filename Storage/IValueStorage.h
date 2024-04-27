//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Value storage interface.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

class IValueStorage {
 public:
  /**
   * Destructor.
   */
  virtual ~IValueStorage() {}

  /**
   * Returns number of values available to fetch (size of the values buffer).
   */
  virtual int Size() const {
    Alert(__FUNCSIG__, " does not implement Size()!");
    DebugBreak();
    return 0;
  }

  /**
   * Resizes storage to given size.
   */
  virtual void Resize(int _size, int _reserve) {
    Alert(__FUNCSIG__, " does not implement Resize()!");
    DebugBreak();
  }

  /**
   * Checks whether storage operates in as-series mode.
   */
  virtual bool IsSeries() const {
    Alert(__FUNCSIG__, " does not implement IsSeries()!");
    DebugBreak();
    return false;
  }

  /**
   * Sets storage's as-series mode on or off.
   */
  virtual bool SetSeries(bool _value) {
    Alert(__FUNCSIG__, " does not implement SetSeries()!");
    DebugBreak();
    return false;
  }
};

/**
 * ValueStorage-compatible wrapper for ArrayGetAsSeries.
 */
bool ArrayGetAsSeries(const IValueStorage& _storage) { return _storage.IsSeries(); }

/**
 * ValueStorage-compatible wrapper for ArraySetAsSeries.
 */
bool ArraySetAsSeries(IValueStorage& _storage, bool _value) { return _storage.SetSeries(_value); }

/**
 * ValueStorage-compatible wrapper for ArrayResize.
 */
int ArrayResize(IValueStorage& _storage, int _size, int _reserve = 100) {
  _storage.Resize(_size, _reserve);
  return _size;
}

/**
 * ValueStorage-compatible wrapper for ArraySize.
 */
int ArraySize(const IValueStorage& _storage) { return _storage.Size(); }

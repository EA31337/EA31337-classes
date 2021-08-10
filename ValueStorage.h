//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
 * Stores values fetchable and storeable in native arrays or custom data storages.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Prevents processing this includes file for the second time.
#ifndef VALUE_STORAGE_H
#define VALUE_STORAGE_H

// Includes.
#include "Array.mqh"

template<typename C>
class ValueStorage;

template<typename C>
class ValueStorageAccessor {
  ValueStorage<C>* storage;
  int index;
public:
  
  ValueStorageAccessor(const ValueStorageAccessor<C>& _r) : storage(_r.storage), index(_r.index) {}
  
  ValueStorageAccessor(ValueStorage<C>* _storage, int _index) : storage(_storage), index(_index) {}
  
  ValueStorageAccessor(C _value) {
    THIS_REF = _value;
  }
  
  void operator=(C _value) {
    storage.Store(index, _value);
  }
};

template<typename C>
class ValueStorage {
public:

  /**
   * We don't user to accidentally copy whole buffer.
   */
  void operator=(const ValueStorage<C>&) = delete;
  
  /**
   * Fetches value for a given shift.
   */
  virtual C Fetch(int _shift) = NULL;
  
  /**
   * Stores value in a given shift.
   */
  virtual void Store(int _shift, C _value) = NULL;
  
  /**
   * Returns current size of the buffer.
   */   
  virtual int Size() = NULL;
  
  ValueStorageAccessor<C> operator[] (int _index) {
    return ValueStorageAccessor<C>(THIS_PTR, _index);
  }
};

template<typename C>
class NativeValueStorage : ValueStorage<C> {

  C _values[];

public:

  NativeValueStorage() {
    ArraySetAsSeries(_values, true);
  }
  
  C Fetch(int _shift) {
    return _values[0];
  }
  
  void Store(int _shift, C _value) {
    Array::ArrayStore(_values, _shift, _value);
  }
  
  int Size() {
  }
};

#endif  // End: VALUE_STORAGE_H

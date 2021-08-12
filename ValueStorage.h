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
#include "Refs.mqh"

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

  void operator =(const ValueStorageAccessor& _accessor) { Set(_accessor.Get()); }
    
  const C Get() const { return storage.Fetch(index); }
  
  void Set(C value) { storage.Store(index, value); }
  
  #define VALUE_STORAGE_ACCESSOR_OP(TYPE, OP) \
    TYPE operator OP(const ValueStorageAccessor& _accessor) const { return Get() OP _accessor.Get(); } \
    TYPE operator OP(C _value) const { return Get() OP _value; }
  
  VALUE_STORAGE_ACCESSOR_OP(C, +)
  VALUE_STORAGE_ACCESSOR_OP(C, -)
  VALUE_STORAGE_ACCESSOR_OP(C, *)
  VALUE_STORAGE_ACCESSOR_OP(C, /)
  VALUE_STORAGE_ACCESSOR_OP(bool, ==)
  VALUE_STORAGE_ACCESSOR_OP(bool, !=)
  VALUE_STORAGE_ACCESSOR_OP(bool, >)
  VALUE_STORAGE_ACCESSOR_OP(bool, >=)
  VALUE_STORAGE_ACCESSOR_OP(bool, <)
  VALUE_STORAGE_ACCESSOR_OP(bool, <=)
  
  #undef VALUE_STORAGE_ACCESSOR_OP_A_V

  #define VALUE_STORAGE_ACCESSOR_INP_OP(OP, OP2) \
    void operator OP(const ValueStorageAccessor& _accessor) { Set(Get() OP2 _accessor.Get()); } \
    void operator OP(C _value) { Set(Get() OP2 _value); }
  
  VALUE_STORAGE_ACCESSOR_INP_OP(+=, +)
  VALUE_STORAGE_ACCESSOR_INP_OP(-=, -)
  VALUE_STORAGE_ACCESSOR_INP_OP(*=, *)
  VALUE_STORAGE_ACCESSOR_INP_OP(/=, /)
  
  #undef VALUE_STORAGE_ACCESSOR_INP_OP

};

template<typename C>
class ValueStorage : public Dynamic {
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
  
  virtual void Initialize(C _value) = NULL;
  
  virtual void Resize(int _size, int _reserve) = NULL;
  
  virtual bool IsSeries() const = NULL;
  
  virtual bool SetSeries(bool _value) = NULL;
  
  ValueStorageAccessor<C> operator[] (int _index) {
    return ValueStorageAccessor<C>(THIS_PTR, _index);
  }
};

template<typename C>
bool ArrayGetAsSeries(const ValueStorage<C>& _storage) {
  return _storage.IsSeries();
}

template<typename C>
bool ArraySetAsSeries(ValueStorage<C>& _storage, bool _value) {
  return _storage.SetSeries(_value);
}

template<typename C>
void ArrayInitialize(ValueStorage<C>& _storage, C _value) {
  _storage.Initialize(_value);
}

template<typename C>
int ArrayResize(ValueStorage<C>& _storage, int _size, int _reserve = 100) {
  _storage.Resize(_size, _reserve);
  return _size;
}

template<typename C>
int ArraySize(ValueStorage<C>& _storage) {
  return _storage.Size();
}

template<typename C, typename D>
int ArrayCopy(D &_target[], ValueStorage<C>& _source, int _dst_start = 0, int _src_start = 0, int count = WHOLE_ARRAY) {
  int _dst_required_size = _dst_start + count;
  
  if (ArraySize(_target) < _dst_required_size) {
    ArrayResize(_target, _dst_required_size, 32);
  }
  
  int _num_copied, t, s;
  
  for (_num_copied = 0, t = _dst_start, s = _src_start; _num_copied < count; ++_num_copied, ++t, ++s) {
    if (s >= ArraySize(_source)) {
      // No more data to copy.
      break;
    }
    _target[t] = _source[s].Get();
  }

  return _num_copied;
}

template<typename C>
class NativeValueStorage : ValueStorage<C> {

  C _values[];

public:

  NativeValueStorage() {
  }

  NativeValueStorage(ARRAY_REF(C, _arr)) {
    ArrayCopy(_values, _arr);
  }
  
  virtual C Fetch(int _shift) {
    return _values[0];
  }
  
  virtual void Store(int _shift, C _value) {
    Array::ArrayStore(_values, _shift, _value);
  }
  
  virtual int Size() {
    return ArraySize(_values);
  }
  
  virtual void Initialize(C _value) {
    ArrayInitialize(_values, _value);
  }

  virtual void Resize(int _size, int _reserve) {
    ArrayResize(_values, _size, _reserve);
  }
  
  virtual bool IsSeries() const {
    return ArrayGetAsSeries(_values);
  }
  
  virtual bool SetSeries(bool _value) {
    ArraySetAsSeries(_values, _value);
    return true;
  }
};

#endif  // End: VALUE_STORAGE_H

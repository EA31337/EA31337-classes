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
 * ValueStorage value accessor.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward declarations.
template <typename C>
class ValueStorage;

template <typename C>
class ValueStorageAccessor {
  // Target storage to access data from.
  ValueStorage<C>* storage;

  // Index of storage value to store/fetch.
  int index;

 public:
  /**
   * Constructor.
   */
  ValueStorageAccessor(const ValueStorageAccessor<C>& _r) : storage(_r.storage), index(_r.index) {}

  /**
   * Constructor.
   */
  ValueStorageAccessor(ValueStorage<C>* _storage, int _index) : storage(_storage), index(_index) {}

  /**
   * Constructor.
   */
  ValueStorageAccessor(C _value) { THIS_REF = _value; }

  /**
   * Assignment operator.
   */
  void operator=(C _value) { Set(_value); }

  /**
   * Assignment operator.
   */
  void operator=(const ValueStorageAccessor& _accessor) { Set(_accessor.Get()); }

  /**
   * Fetches value from the storage.
   */
  const C Get() const { return storage.Fetch(index); }

  /**
   * Stores value in the storage.
   */
  void Set(C value) { storage.Store(index, value); }

#define VALUE_STORAGE_ACCESSOR_OP(TYPE, OP)                                                          \
  TYPE operator OP(const ValueStorageAccessor& _accessor) const { return Get() OP _accessor.Get(); } \
  TYPE operator OP(C _value) const { return Get() OP _value; }

  /**
   * Operators.
   */
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

#define VALUE_STORAGE_ACCESSOR_INP_OP(OP, OP2)                                                \
  void operator OP(const ValueStorageAccessor& _accessor) { Set(Get() OP2 _accessor.Get()); } \
  void operator OP(C _value) { Set(Get() OP2 _value); }

  /**
   * In-place operators.
   */
  VALUE_STORAGE_ACCESSOR_INP_OP(+=, +)
  VALUE_STORAGE_ACCESSOR_INP_OP(-=, -)
  VALUE_STORAGE_ACCESSOR_INP_OP(*=, *)
  VALUE_STORAGE_ACCESSOR_INP_OP(/=, /)

#undef VALUE_STORAGE_ACCESSOR_INP_OP
};

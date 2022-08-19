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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward class declaration.
template <typename K, typename V>
class DictBase;

#include "DictBase.mqh"
#include "DictSlotsRef.h"
#include "Serializer/SerializerConversions.h"

template <typename K, typename V>
class DictIteratorBase {
 protected:
  DictBase<K, V>* _dict;
  int _hash;
  int _slotIdx;
  int _index;
  bool _invalid_until_incremented;

 public:
  /**
   * Constructor.
   */
  DictIteratorBase() : _dict(NULL) { _invalid_until_incremented = false; }

  /**
   * Constructor.
   */
  DictIteratorBase(DictBase<K, V>& dict, int slotIdx)
      : _dict(&dict), _hash(dict.GetHash()), _slotIdx(slotIdx), _index(0) {
    _invalid_until_incremented = false;
  }

  /**
   * Copy constructor.
   */
  DictIteratorBase(const DictIteratorBase& right)
      : _dict(right._dict),
        _hash(right._dict ? right._dict PTR_DEREF GetHash() : 0),
        _slotIdx(right._slotIdx),
        _index(right._index) {
    _invalid_until_incremented = false;
  }

  /**
   * Iterator incrementation operator.
   */
  void operator++(void) {
    // Going to the next slot.
    ++_slotIdx;
    ++_index;
    _invalid_until_incremented = false;

    DictSlot<K, V>* slot = _dict PTR_DEREF GetSlot(_slotIdx);

    // Iterating until we find valid, used slot.
    while (slot != NULL && !slot PTR_DEREF IsUsed()) {
      slot = _dict PTR_DEREF GetSlot(++_slotIdx);
    }

    if (!slot || !slot PTR_DEREF IsValid()) {
      // Invalidating iterator.
      _dict = NULL;
    }
  }

  bool HasKey() { return _dict PTR_DEREF GetSlot(_slotIdx) PTR_DEREF HasKey(); }

  K Key() {
    CheckValidity();
    return PTR_ATTRIB(_dict, GetMode()) == DictModeList ? (K)_slotIdx : _dict PTR_DEREF GetSlot(_slotIdx) PTR_DEREF key;
  }

  string KeyAsString(bool includeQuotes = false) {
    return HasKey() ? SerializerConversions::ValueToString(Key(), includeQuotes) : "";
  }

  int Index() {
    CheckValidity();
    return _index;
  }

  V Value() {
    CheckValidity();
    return _dict PTR_DEREF GetSlot(_slotIdx) PTR_DEREF value;
  }

  void CheckValidity() {
    if (_invalid_until_incremented) {
      Alert("Iterator must be incremented before using it again!");
      DebugBreak();
    }
  }

  bool IsValid() { return _dict != NULL; }

  bool IsLast() {
    if (!IsValid()) return true;

    if (_dict PTR_DEREF GetMode() == DictModeUnknown || _dict PTR_DEREF Size() == 0) {
      return false;
    }

    if (_dict PTR_DEREF GetMode() != DictModeList) {
      Alert("Dict iterator's IsLast() method may be used only when elements are added via Push() method.");
    }

    return _index == _dict PTR_DEREF Size() - 1;
  }

  void ShiftPosition(int shift, bool invalid_until_incremented = false) {
    _slotIdx += shift;
    _index += shift;
    _invalid_until_incremented |= invalid_until_incremented;
  }
};

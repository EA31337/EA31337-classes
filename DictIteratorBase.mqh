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

// Prevents processing this includes file for the second time.
#ifndef DICT_ITERATOR_BASE_MQH
#define DICT_ITERATOR_BASE_MQH

#include "DictBase.mqh"

template <typename K, typename V>
class DictIteratorBase {
 protected:
  DictBase<K, V>* _dict;
  int _hash;
  unsigned int _slotIdx;
  unsigned int _index;

 public:
  /**
   * Constructor.
   */
  DictIteratorBase() : _dict(NULL) {}

  /**
   * Constructor.
   */
  DictIteratorBase(DictBase<K, V>& dict, unsigned int slotIdx)
      : _dict(&dict), _hash(dict.GetHash()), _slotIdx(slotIdx), _index(0) {}

  /**
   * Copy constructor.
   */
  DictIteratorBase(const DictIteratorBase& right)
      : _dict(right._dict),
        _hash(right._dict ? right._dict.GetHash() : 0),
        _slotIdx(right._slotIdx),
        _index(right._index) {}

  /**
   * Iterator incrementation operator.
   */
  void operator++(void) {
    // Going to the next slot.
    ++_slotIdx;
    ++_index;

    DictSlot<K, V>* slot = _dict.GetSlot(_slotIdx);

    // Iterating until we find valid, used slot.
    while (slot != NULL && !slot.IsUsed()) {
      slot = _dict.GetSlot(++_slotIdx);
    }

    if (!slot || !slot.IsValid()) {
      // Invalidating iterator.
      _dict = NULL;
    }
  }

  bool HasKey() { return _dict.GetSlot(_slotIdx).HasKey(); }

  K Key() { return _dict.GetMode() == DictModeList ? (K)_slotIdx : _dict.GetSlot(_slotIdx).key; }

  string KeyAsString(bool includeQuotes = false) {
    return HasKey() ? Serializer::ValueToString(Key(), includeQuotes) : "";
  }

  unsigned int Index() { return _index; }

  V Value() { return _dict.GetSlot(_slotIdx).value; }

  bool IsValid() { return _dict != NULL; }

  bool IsLast() {
    if (!IsValid()) return true;

    if (_dict.GetMode() == DictModeUnknown || _dict.Size() == 0) {
      return false;
    }

    if (_dict.GetMode() != DictModeList) {
      Alert("Dict iterator's IsLast() method may be used only when elements are added via Push() method.");
    }

    return _index == _dict.Size() - 1;
  }
};

template <typename K, typename V>
struct DictSlotsRef {
  DictSlot<K, V> DictSlots[];

  // Incremental index for dict operating in list mode.
  unsigned int _list_index;

  unsigned int _num_used;

  DictSlotsRef() {
    _list_index = 0;
    _num_used = 0;
  }
};

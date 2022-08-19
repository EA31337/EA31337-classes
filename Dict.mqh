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
#ifndef DICT_MQH
#define DICT_MQH

#include "Convert.mqh"
#include "DictBase.mqh"
#include "Matrix.mqh"
#include "Serializer/Serializer.h"
#include "Serializer/SerializerNodeIterator.h"

template <typename K, typename V>
class DictIterator : public DictIteratorBase<K, V> {
 public:
  /**
   * Constructor.
   */
  DictIterator() {}

  /**
   * Constructor.
   */
  DictIterator(DictBase<K, V>& dict, unsigned int slotIdx) : DictIteratorBase(dict, slotIdx) {}

  /**
   * Copy constructor.
   */
  DictIterator(const DictIterator& right) : DictIteratorBase(right) {}
};

/**
 * Hash-table based dictionary.
 */
template <typename K, typename V>
class Dict : public DictBase<K, V> {
 protected:
 public:
  /**
   * Constructor.
   */
  Dict() {}

  Dict(string _data, string _dlm = "\n") {}

  /**
   * Copy constructor.
   */
  Dict(const Dict<K, V>& right) {
    Clear();
    Resize(right.GetSlotCount());
    for (unsigned int i = 0; i < (unsigned int)ArraySize(right._DictSlots_ref.DictSlots); ++i) {
      _DictSlots_ref.DictSlots[i] = right._DictSlots_ref.DictSlots[i];
    }
    _DictSlots_ref._num_used = right._DictSlots_ref._num_used;
    _current_id = right._current_id;
    _mode = right._mode;
  }

  void operator=(const Dict<K, V>& right) {
    Clear();
    Resize(right.GetSlotCount());
    for (unsigned int i = 0; i < (unsigned int)ArraySize(right._DictSlots_ref.DictSlots); ++i) {
      _DictSlots_ref.DictSlots[i] = right._DictSlots_ref.DictSlots[i];
    }
    _DictSlots_ref._num_used = right._DictSlots_ref._num_used;
    _current_id = right._current_id;
    _mode = right._mode;
  }

  void Clear() {
    for (unsigned int i = 0; i < (unsigned int)ArraySize(_DictSlots_ref.DictSlots); ++i) {
      if (_DictSlots_ref.DictSlots[i].IsUsed()) _DictSlots_ref.DictSlots[i].SetFlags(0);
    }

    _DictSlots_ref._num_used = 0;
  }

  /**
   * Inserts value using hashless key.
   */
  bool Push(V value) {
    if (!InsertInto(_DictSlots_ref, value)) return false;
    return true;
  }

  /**
   * Inserts value using hashless key.
   */
  bool operator+=(V value) { return Push(value); }

  /**
   * Inserts or replaces value for a given key.
   */
  bool Set(K key, V value) {
    if (!InsertInto(_DictSlots_ref, key, value, true)) return false;
    return true;
  }

  V operator[](K key) {
    if (_mode == DictModeList) return GetSlot((unsigned int)key).value;

    int position;
    DictSlot<K, V>* slot = GetSlotByKey(_DictSlots_ref, key, position);

    if (!slot) return (V)NULL;

    return slot.value;
  }

  /**
   * Returns value for a given key.
   *
   * @return
   *   Returns value for a given key, otherwise the default value.
   */
  V GetByKey(const K _key, V _default = NULL) {
    unsigned int position;
    DictSlot<K, V>* slot = GetSlotByKey(_DictSlots_ref, _key, position);

    if (!slot) {
      return _default;
    }

    return slot.value;
  }

  /**
   * Returns value for a given position.
   */
  V GetByPos(unsigned int _position) {
    DictSlot<K, V>* slot = GetSlotByPos(_DictSlots_ref, _position);

    if (!slot) {
      Alert("Invalid DictStruct position \"", _position, "\" (called by GetByPos()). Returning empty structure.");
      DebugBreak();
      static V _empty;
      return _empty;
    }

    return slot.value;
  }

  /**
   * Checks whether dictionary contains given key => value pair.
   */
  template <>
  bool Contains(const K key, const V value) {
    unsigned int position;
    DictSlot<K, V>* slot = GetSlotByKey(_DictSlots_ref, key, position);

    if (!slot) return false;

    return slot.value == value;
  }

  /**
   * Returns index of dictionary's value or -1 if value doesn't exist.
   */
  template <>
  int IndexOf(V& value) {
    for (DictIteratorBase<K, V> i(Begin()); i.IsValid(); ++i) {
      if (i.Value() == value) {
        return (int)i.Index();
      }
    }

    return -1;
  }

  /**
   * Checks whether dictionary contains given value.
   */
  bool Contains(const V value) {
    for (DictIterator<K, V> i = Begin(); i.IsValid(); ++i) {
      if (i.Value() == value) {
        return true;
      }
    }

    return false;
  }

 protected:
  /**
   * Inserts value into given array of DictSlots.
   */
  bool InsertInto(DictSlotsRef<K, V>& dictSlotsRef, const K key, V value, bool allow_resize) {
    if (_mode == DictModeUnknown)
      _mode = DictModeDict;
    else if (_mode != DictModeDict) {
      Alert("Warning: Dict already operates as a list, not a dictionary!");
      return false;
    }

    unsigned int position;
    DictSlot<K, V>* keySlot = GetSlotByKey(dictSlotsRef, key, position);

    if (keySlot == NULL && !IsGrowUpAllowed()) {
      // Resize is prohibited, so we will just overwrite some slot.
      allow_resize = false;
    }

    if (allow_resize) {
      // Will resize dict if there were performance problems before or there is no slots.
      if (IsGrowUpAllowed() && !dictSlotsRef.IsPerformant()) {
        if (!GrowUp()) {
          return false;
        }
        // We now have new positions of slots, so we have to take the corrent slot again.
        keySlot = GetSlotByKey(dictSlotsRef, key, position);
      }

      if (keySlot == NULL && dictSlotsRef._num_used == ArraySize(dictSlotsRef.DictSlots)) {
        // No DictSlotsRef.DictSlots available.
        if (overflow_listener != NULL) {
          if (!overflow_listener(DICT_OVERFLOW_REASON_FULL, dictSlotsRef._num_used, 0)) {
            // Overwriting slot pointed exactly by key's position in the hash table (we don't check for possible
            // conflicts).
            keySlot = &dictSlotsRef.DictSlots[Hash(key) % ArraySize(dictSlotsRef.DictSlots)];
          }
        }

        if (keySlot == NULL) {
          // We need to expand array of DictSlotsRef.DictSlots (by 25% by default).
          if (!GrowUp()) return false;
        }
      }
    }

    if (keySlot == NULL) {
      position = Hash(key) % ArraySize(dictSlotsRef.DictSlots);

      unsigned int _starting_position = position;
      int _num_conflicts = 0;
      bool _overwrite_slot = false;

      // Searching for empty DictSlot<K, V> or used one with the matching key. It skips used, hashless DictSlots.
      while (dictSlotsRef.DictSlots[position].IsUsed() &&
             (!dictSlotsRef.DictSlots[position].HasKey() || dictSlotsRef.DictSlots[position].key != key)) {
        if (overflow_listener_max_conflicts != 0 && ++_num_conflicts == overflow_listener_max_conflicts) {
          if (overflow_listener != NULL) {
            if (!overflow_listener(DICT_OVERFLOW_REASON_TOO_MANY_CONFLICTS, dictSlotsRef._num_used, _num_conflicts)) {
              // Overflow listener returned false so we won't search for further empty slot.
              _overwrite_slot = true;
              break;
            }
          } else {
            // Even if there is no overflow listener function, we stop searching for further empty slot as maximum
            // number of conflicts has been reached.
            _overwrite_slot = true;
            break;
          }
        }

        // Position may overflow, so we will start from the beginning.
        position = (position + 1) % ArraySize(dictSlotsRef.DictSlots);
      }

      if (_overwrite_slot) {
        // Overwriting starting position for faster further lookup.
        position = _starting_position;
      } else if (!dictSlotsRef.DictSlots[position].IsUsed()) {
        // If slot isn't already used then we increment number of used slots.
        ++dictSlotsRef._num_used;
      }

      dictSlotsRef.AddConflicts(_num_conflicts);
    }

    dictSlotsRef.DictSlots[position].key = key;
    dictSlotsRef.DictSlots[position].value = value;
    dictSlotsRef.DictSlots[position].SetFlags(DICT_SLOT_HAS_KEY | DICT_SLOT_IS_USED | DICT_SLOT_WAS_USED);
    return true;
  }

  /**
   * Inserts hashless value into given array of DictSlots.
   */
  bool InsertInto(DictSlotsRef<K, V>& dictSlotsRef, V value) {
    if (_mode == DictModeUnknown)
      _mode = DictModeList;
    else if (_mode != DictModeList) {
      Alert("Warning: Dict already operates as a dictionary, not a list!");
      DebugBreak();
      return false;
    }

    if (dictSlotsRef._num_used == ArraySize(dictSlotsRef.DictSlots)) {
      // No DictSlotsRef.DictSlots available, we need to expand array of DictSlotsRef.DictSlots.
      if (!GrowUp()) return false;
    }

    unsigned int position = Hash((unsigned int)dictSlotsRef._list_index) % ArraySize(dictSlotsRef.DictSlots);

    // Searching for empty DictSlot<K, V>.
    while (dictSlotsRef.DictSlots[position].IsUsed()) {
      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(dictSlotsRef.DictSlots);
    }

    dictSlotsRef.DictSlots[position].value = value;
    dictSlotsRef.DictSlots[position].SetFlags(DICT_SLOT_IS_USED | DICT_SLOT_WAS_USED);

    ++dictSlotsRef._list_index;
    ++dictSlotsRef._num_used;
    return true;
  }

  /**
   * Expands array of DictSlots by given percentage value.
   */
  bool GrowUp(int percent = DICT_GROW_UP_PERCENT_DEFAULT) {
    return Resize(MathMax(10, (int)((float)ArraySize(_DictSlots_ref.DictSlots) * ((float)(percent + 100) / 100.0f))));
  }

  /**
   * Shrinks or expands array of DictSlots.
   */
  bool Resize(int new_size) {
    if (new_size <= MathMin(_DictSlots_ref._num_used, ArraySize(_DictSlots_ref.DictSlots))) {
      // We already use minimum number of slots possible.
      return true;
    }

    DictSlotsRef<K, V> new_DictSlots;

    if (ArrayResize(new_DictSlots.DictSlots, new_size) == -1) return false;

    int i;

    for (i = 0; i < new_size; ++i) {
      new_DictSlots.DictSlots[i].SetFlags(0);
    }

    new_DictSlots._num_used = 0;

    // Copies entire array of DictSlots into new array of DictSlots. Hashes will be rehashed.
    for (i = 0; i < ArraySize(_DictSlots_ref.DictSlots); ++i) {
      if (!_DictSlots_ref.DictSlots[i].IsUsed()) continue;

      if (_DictSlots_ref.DictSlots[i].HasKey()) {
        if (!InsertInto(new_DictSlots, _DictSlots_ref.DictSlots[i].key, _DictSlots_ref.DictSlots[i].value, false))
          return false;
      } else {
        if (!InsertInto(new_DictSlots, _DictSlots_ref.DictSlots[i].value)) return false;
      }
    }
    // Freeing old DictSlots array.
    ArrayFree(_DictSlots_ref.DictSlots);

    _DictSlots_ref = new_DictSlots;

    return true;
  }

 public:
#ifdef __cplusplus
  template <>
#endif
  SerializerNodeType Serialize(Serializer& s) {
    if (s.IsWriting()) {
      for (DictIteratorBase<K, V> i(Begin()); i.IsValid(); ++i) {
        V value = i.Value();
        s.Pass(THIS_REF, GetMode() == DictModeDict ? i.KeyAsString() : "", value);
      }

      return (GetMode() == DictModeDict) ? SerializerNodeObject : SerializerNodeArray;
    } else {
      SerializerIterator<V> i;

      for (i = s.Begin<V>(); i.IsValid(); ++i) {
        if (i.HasKey()) {
          // Converting key to a string.
          K key;
          Convert::StringToType(i.Key(), key);

          // Note that we're retrieving value by a key (as we are in an
          // object!).
          Set(key, s.Value<V>(i.Key()));
        } else {
          Push(s.Value<V>());
        }
      }
      return i.ParentNodeType();
    }
  }

  /**
   * Initializes object with given number of elements. Could be skipped for non-containers.
   */
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {
    V _child = (V)NULL;
    while (_n1-- > 0) {
      Push(_child);
    }
  }

  /**
   * Converts values into 1D matrix.
   */
  template <typename X>
  Matrix<X>* ToMatrix() {
    Matrix<X>* result = new Matrix<X>(Size());

    for (DictIterator<K, V> i = Begin(); i.IsValid(); ++i) result[i.Index()] = (X)i.Value();

    return result;
  }
};

#endif

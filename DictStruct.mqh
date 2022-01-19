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
#ifndef DICT_STRUCT_MQH
#define DICT_STRUCT_MQH

// Forward declarations.
class Dynamic;
class Log;

#include "DictBase.mqh"
#include "DictIteratorBase.mqh"
#include "Serializer.mqh"

// DictIterator could be used as DictStruct iterator.
#define DictStructIterator DictIteratorBase

/**
 * Hash-table based dictionary.
 */
template <typename K, typename V>
class DictStruct : public DictBase<K, V> {
 public:
  /**
   * Constructor. You may specifiy intial number of DictSlots that holds values or just leave it as it is.
   */
  DictStruct(unsigned int _initial_size = 0) {
    if (_initial_size > 0) {
      Resize(_initial_size);
    }
  }

  /**
   * Copy constructor.
   */
  DictStruct(const DictStruct<K, V>& right) {
    Clear();
    Resize(right.GetSlotCount());
    for (unsigned int i = 0; i < (unsigned int)ArraySize(right._DictSlots_ref.DictSlots); ++i) {
      _DictSlots_ref.DictSlots[i] = right._DictSlots_ref.DictSlots[i];
    }
    _DictSlots_ref._num_used = right._DictSlots_ref._num_used;
    _current_id = right._current_id;
    _mode = right._mode;
  }

  void operator=(const DictStruct<K, V>& right) {
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
      _DictSlots_ref.DictSlots[i].SetFlags(0);
    }

    _DictSlots_ref._num_used = 0;
  }

  DictStructIterator<K, V> Begin() {
    // Searching for first item index.
    for (unsigned int i = 0; i < (unsigned int)ArraySize(_DictSlots_ref.DictSlots); ++i) {
      if (_DictSlots_ref.DictSlots[i].IsValid() && _DictSlots_ref.DictSlots[i].IsUsed()) {
        DictStructIterator<K, V> iter(this, i);
        return iter;
      }
    }
    // No items found.
    DictStructIterator<K, V> invalid;
    return invalid;
  }

  /**
   * Inserts value using hashless key.
   */
  bool Push(V& value) {
    if (!InsertInto(_DictSlots_ref, value)) return false;
    return true;
  }

  /**
   * Inserts value using hashless key.
   */
  bool operator+=(V& value) { return Push(value); }

/**
 * Inserts value using hashless key.
 */
#ifdef __MQL__
  template <>
#endif
  bool Push(Dynamic* value) {
    V ptr = value;

    if (!InsertInto(_DictSlots_ref, ptr)) return false;
    return true;
  }

  /**
   * Inserts or replaces value for a given key.
   */
  bool Set(K key, V& value) {
    if (!InsertInto(_DictSlots_ref, key, value, true)) return false;
    return true;
  }

  /**
   * Index operator. Returns value for a given key.
   */
  V operator[](K key) {
    DictSlot<K, V>* slot;

    int position;

    if (_mode == DictModeList)
      slot = GetSlot((unsigned int)key);
    else
      slot = GetSlotByKey(_DictSlots_ref, key, position);

    if (slot == NULL || !slot.IsUsed()) {
      Alert("Invalid DictStruct key \"", key, "\" (called by [] operator). Returning empty structure.");
      DebugBreak();
      static V _empty;
      return _empty;
    }

    return slot.value;
  }

  /**
   * Returns value for a given key.
   */
  V GetByKey(const K _key) {
    unsigned int position;
    DictSlot<K, V>* slot = GetSlotByKey(_DictSlots_ref, _key, position);

    if (!slot) {
      static V _empty;
      return _empty;
    }

    return slot.value;
  }

  /**
   * Returns value for a given key.
   *
   * @return
   *   Returns value for a given key, otherwise the default value.
   */
  V GetByKey(const K _key, V& _default) {
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
#ifdef __MQL__
  template <>
#endif
  /**
   * Checks whether dictionary contains given value.
   */
  bool Contains(const V& value) {
    for (DictStructIterator<K, V> i = Begin(); i.IsValid(); ++i) {
      if (i.Value() == value) {
        return true;
      }
    }

    return false;
  }

  /**
   * Checks whether dictionary contains given key and value.
   */
  template <>
  bool Contains(const K key, const V& value) {
    unsigned int position;
    DictSlot<K, V>* slot = GetSlotByKey(_DictSlots_ref, key, position);

    if (!slot) return false;

    return slot.value == value;
  }

  /**
   * Returns index of dictionary's value or -1 if value doesn't exist.
   */
  template <>
  int IndexOf(const V& value) {
    for (DictIteratorBase<K, V> i(Begin()); i.IsValid(); ++i) {
      if (i.Value() == value) {
        return (int)i.Index();
      }
    }

    return -1;
  }

 protected:
  /**
   * Inserts value into given array of DictSlots.
   */
  bool InsertInto(DictSlotsRef<K, V>& dictSlotsRef, const K key, V& value, bool allow_resize) {
    if (_mode == DictModeUnknown)
      _mode = DictModeDict;
    else if (_mode != DictModeDict) {
      Alert("Warning: Dict already operates as a list, not a dictionary!");
      return false;
    }

    unsigned int position;
    DictSlot<K, V>* keySlot = GetSlotByKey(dictSlotsRef, key, position);

    if (keySlot == NULL && !IsGrowUpAllowed()) {
      // Resize is prohibited.
      return false;
    }

    // Will resize dict if there were performance problems before.
    if (allow_resize && IsGrowUpAllowed() && !dictSlotsRef.IsPerformant()) {
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
        // We need to expand array of DictSlotsRef.DictSlots.
        if (!GrowUp()) return false;
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
      } else {
        // Slot overwrite is not needed. Using empty slot.
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
  bool InsertInto(DictSlotsRef<K, V>& dictSlotsRef, V& value) {
    if (_mode == DictModeUnknown)
      _mode = DictModeList;
    else if (_mode != DictModeList) {
      Alert("Warning: Dict already operates as a dictionary, not a list!");
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
#ifdef __MQL__
  template <>
#endif
  SerializerNodeType Serialize(Serializer& s) {
    if (s.IsWriting()) {
      for (DictIteratorBase<K, V> i(Begin()); i.IsValid(); ++i)
        s.PassObject(this, GetMode() == DictModeDict ? i.KeyAsString() : "", i.Value());

      return (GetMode() == DictModeDict) ? SerializerNodeObject : SerializerNodeArray;
    } else {
      if (s.IsArray()) {
        unsigned int num_items = s.NumArrayItems();
        // Entering only if Dict has items.
        if (num_items > 0) {
          s.Enter();

          while (num_items-- != 0) {
            V child;
            child.Serialize(s);
            Push(child);
            s.Next();
          }

          s.Leave();
        }
        return SerializerNodeArray;
      } else {
        SerializerIterator<V> i;

        for (i = s.Begin<V>(); i.IsValid(); ++i) {
          if (i.HasKey()) {
            // Converting key to a string.
            K key;
            Convert::StringToType(i.Key(), key);

            // Note that we're retrieving value by a key (as we are in an
            // object!).
            Set(key, i.Struct(i.Key()));
          } else {
            Push(i.Struct());
          }
        }
        return i.ParentNodeType();
      }
    }
  }

/**
 * Initializes object with given number of elements. Could be skipped for non-containers.
 */
#ifdef __MQL__
  template <>
#endif
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {
    V _child;

    _child.SerializeStub(_n2, _n3, _n4, _n5);

    while (_n1-- > 0) {
      Push(_child);
    }
  }
};

#endif

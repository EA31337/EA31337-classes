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
#ifndef DICT_OBJECT_MQH
#define DICT_OBJECT_MQH

#include "Convert.mqh"
#include "DictBase.mqh"
#include "Serializer/Serializer.h"
#include "Serializer/SerializerNodeIterator.h"

template <typename K, typename V>
class DictObjectIterator : public DictIteratorBase<K, V> {
 public:
  /**
   * Constructor.
   */
  DictObjectIterator() {}

  /**
   * Constructor.
   */
  DictObjectIterator(DictBase<K, V>& dict, unsigned int slotIdx) : DictIteratorBase<K, V>(dict, slotIdx) {}

  /**
   * Copy constructor.
   */
  DictObjectIterator(const DictObjectIterator& right) : DictIteratorBase<K, V>(right) {}

  V* Value() { return &(this PTR_DEREF _dict PTR_DEREF GetSlot(this PTR_DEREF _slotIdx) PTR_DEREF value); }
};

/**
 * Hash-table based dictionary.
 */
template <typename K, typename V>
class DictObject : public DictBase<K, V> {
 public:
  /**
   * Constructor. You may specifiy intial number of DictSlots that holds values or just leave it as it is.
   */
  DictObject(unsigned int _initial_size = 0) {
    if (_initial_size > 0) {
      Resize(_initial_size);
    }
  }

  /**
   * Copy constructor.
   */
  DictObject(const DictObject<K, V>& right) {
    Clear();
    Resize(right.GetSlotCount());
    for (unsigned int i = 0; i < (unsigned int)ArraySize(right._DictSlots_ref.DictSlots); ++i) {
      this PTR_DEREF _DictSlots_ref.DictSlots[i] = right._DictSlots_ref.DictSlots[i];
    }
    this PTR_DEREF _DictSlots_ref._num_used = right._DictSlots_ref._num_used;
    this PTR_DEREF _current_id = right._current_id;
    this PTR_DEREF _mode = right._mode;
  }

  DictObjectIterator<K, V> Begin() {
    // Searching for first item index.
    for (unsigned int i = 0; i < (unsigned int)ArraySize(this PTR_DEREF _DictSlots_ref.DictSlots); ++i) {
      if (this PTR_DEREF _DictSlots_ref.DictSlots[i].IsValid() && this PTR_DEREF _DictSlots_ref.DictSlots[i].IsUsed()) {
        DictObjectIterator<K, V> iter(THIS_REF, i);
        return iter;
      }
    }
    // No items found.
    DictObjectIterator<K, V> invalid;
    return invalid;
  }

  void operator=(const DictObject<K, V>& right) {
    Clear();
    Resize(right.GetSlotCount());
    for (unsigned int i = 0; i < (unsigned int)ArraySize(right._DictSlots_ref.DictSlots); ++i) {
      this PTR_DEREF _DictSlots_ref.DictSlots[i] = right._DictSlots_ref.DictSlots[i];
    }
    this PTR_DEREF _DictSlots_ref._num_used = right._DictSlots_ref._num_used;
    this PTR_DEREF _current_id = right._current_id;
    this PTR_DEREF _mode = right._mode;
  }

  void Clear() {
    for (unsigned int i = 0; i < (unsigned int)ArraySize(this PTR_DEREF _DictSlots_ref.DictSlots); ++i) {
      this PTR_DEREF _DictSlots_ref.DictSlots[i].SetFlags(0);
    }

    this PTR_DEREF _DictSlots_ref._num_used = 0;
  }

  /**
   * Inserts value using hashless key.
   */
  bool Push(V& value) {
    if (!InsertInto(this PTR_DEREF _DictSlots_ref, value)) return false;
    return true;
  }

  /**
   * Inserts value using hashless key.
   */
  bool operator+=(V& value) { return Push(value); }

  /**
   * Inserts or replaces value for a given key.
   */
  bool Set(K key, V& value) {
    if (!InsertInto(this PTR_DEREF _DictSlots_ref, key, value, true)) return false;
    return true;
  }

  V* operator[](K key) {
    DictSlot<K, V>* slot;

    unsigned int position;

    if (this PTR_DEREF _mode == DictModeList)
      slot = this PTR_DEREF GetSlot((unsigned int)key);
    else
      slot = GetSlotByKey(this PTR_DEREF _DictSlots_ref, key, position);

    if (slot == NULL || !slot PTR_DEREF IsUsed()) return NULL;

    return &slot PTR_DEREF value;
  }

  /**
   * Returns value for a given key.
   */
  V* GetByKey(const K _key) {
    unsigned int position;
    DictSlot<K, V>* slot = GetSlotByKey(this PTR_DEREF _DictSlots_ref, _key, position);

    if (!slot) return NULL;

    return &slot PTR_DEREF value;
  }

  /**
   * Returns value for a given position.
   */
  V* GetByPos(unsigned int _position) {
    DictSlot<K, V>* slot = this PTR_DEREF GetSlotByPos(this PTR_DEREF _DictSlots_ref, _position);

    if (!slot) {
      Alert("Invalid DictStruct position \"", _position, "\" (called by GetByPos()). Returning empty structure.");
      DebugBreak();
      return NULL;
    }

    return &slot PTR_DEREF value;
  }

  /**
   * Checks whether dictionary contains given key => value pair.
   */
#ifdef __MQL__
  template <>
#endif
  bool Contains(const K key, const V& value) {
    unsigned int position;
    DictSlot<K, V>* slot = GetSlotByKey(this PTR_DEREF _DictSlots_ref, key, position);

    if (!slot) return false;

    return slot PTR_DEREF value == value;
  }

  /**
   * Returns index of dictionary's value or -1 if value doesn't exist.
   */
#ifdef __MQL__
  template <>
#endif
  int IndexOf(V& value) {
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
    if (this PTR_DEREF _mode == DictModeUnknown)
      this PTR_DEREF _mode = DictModeDict;
    else if (this PTR_DEREF _mode != DictModeDict) {
      Alert("Warning: Dict already operates as a list, not a dictionary!");
      return false;
    }

    unsigned int position;
    DictSlot<K, V>* keySlot = this PTR_DEREF GetSlotByKey(dictSlotsRef, key, position);

    if (keySlot == NULL && !this PTR_DEREF IsGrowUpAllowed()) {
      // Resize is prohibited, so we will just overwrite some slot.
      allow_resize = false;
    }

    if (allow_resize) {
      // Will resize dict if there were performance problems before or there is no slots.
      if (this PTR_DEREF IsGrowUpAllowed() && !dictSlotsRef.IsPerformant()) {
        if (!GrowUp()) {
          return false;
        }
        // We now have new positions of slots, so we have to take the corrent slot again.
        keySlot = this PTR_DEREF GetSlotByKey(dictSlotsRef, key, position);
      }

      if (keySlot == NULL && dictSlotsRef._num_used == ArraySize(dictSlotsRef.DictSlots)) {
        // No DictSlotsRef.DictSlots available.
        if (this PTR_DEREF overflow_listener != NULL) {
          if (!this PTR_DEREF overflow_listener(DICT_OVERFLOW_REASON_FULL, dictSlotsRef._num_used, 0)) {
            // Overwriting slot pointed exactly by key's position in the hash table (we don't check for possible
            // conflicts).
            keySlot = &dictSlotsRef.DictSlots[this PTR_DEREF Hash(key) % ArraySize(dictSlotsRef.DictSlots)];
          }
        }

        if (keySlot == NULL) {
          // We need to expand array of DictSlotsRef.DictSlots.
          if (!GrowUp()) return false;
        }
      }
    }

    if (keySlot == NULL) {
      position = this PTR_DEREF Hash(key) % ArraySize(dictSlotsRef.DictSlots);

      unsigned int _starting_position = position;
      unsigned int _num_conflicts = 0;
      bool _overwrite_slot = false;

      // Searching for empty DictSlot<K, V> or used one with the matching key. It skips used, hashless DictSlots.
      while (dictSlotsRef.DictSlots[position].IsUsed() &&
             (!dictSlotsRef.DictSlots[position].HasKey() || dictSlotsRef.DictSlots[position].key != key)) {
        if (this PTR_DEREF overflow_listener_max_conflicts != 0 &&
            ++_num_conflicts == this PTR_DEREF overflow_listener_max_conflicts) {
          if (this PTR_DEREF overflow_listener != NULL) {
            if (!this PTR_DEREF overflow_listener(DICT_OVERFLOW_REASON_TOO_MANY_CONFLICTS, dictSlotsRef._num_used,
                                                  _num_conflicts)) {
              // Overflow listener returned false so we won't search for further empty slot PTR_DEREF
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
  bool InsertInto(DictSlotsRef<K, V>& dictSlotsRef, V& value) {
    if (this PTR_DEREF _mode == DictModeUnknown)
      this PTR_DEREF _mode = DictModeList;
    else if (this PTR_DEREF _mode != DictModeList) {
      Alert("Warning: Dict already operates as a dictionary, not a list!");
      DebugBreak();
      return false;
    }

    if (dictSlotsRef._num_used == ArraySize(dictSlotsRef.DictSlots)) {
      // No DictSlotsRef.DictSlots available, we need to expand array of DictSlotsRef.DictSlots.
      if (!GrowUp()) return false;
    }

    unsigned int position =
        this PTR_DEREF Hash((unsigned int)dictSlotsRef._list_index) % ArraySize(dictSlotsRef.DictSlots);

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
    return Resize(MathMax(
        10, (int)((float)ArraySize(this PTR_DEREF _DictSlots_ref.DictSlots) * ((float)(percent + 100) / 100.0f))));
  }

  /**
   * Shrinks or expands array of DictSlots.
   */
  bool Resize(int new_size) {
    if (new_size <=
        MathMin(this PTR_DEREF _DictSlots_ref._num_used, ArraySize(this PTR_DEREF _DictSlots_ref.DictSlots))) {
      // We already use minimum number of slots possible.
      return true;
    }

    DictSlotsRef<K, V> new_DictSlots;

    int i;

    if (ArrayResize(new_DictSlots.DictSlots, new_size) == -1) return false;

    for (i = 0; i < new_size; ++i) {
      new_DictSlots.DictSlots[i].SetFlags(0);
    }

    // Copies entire array of DictSlots into new array of DictSlots. Hashes will be rehashed.
    for (i = 0; i < ArraySize(this PTR_DEREF _DictSlots_ref.DictSlots); ++i) {
      if (!this PTR_DEREF _DictSlots_ref.DictSlots[i].IsUsed()) continue;

      if (this PTR_DEREF _DictSlots_ref.DictSlots[i].HasKey()) {
        if (!InsertInto(new_DictSlots, this PTR_DEREF _DictSlots_ref.DictSlots[i].key,
                        this PTR_DEREF _DictSlots_ref.DictSlots[i].value, false))
          return false;
      } else {
        if (!InsertInto(new_DictSlots, this PTR_DEREF _DictSlots_ref.DictSlots[i].value)) return false;
      }
    }
    // Freeing old DictSlots array.
    ArrayFree(this PTR_DEREF _DictSlots_ref.DictSlots);

    this PTR_DEREF _DictSlots_ref = new_DictSlots;

    return true;
  }

 public:
#ifdef __MQL__
  template <>
#endif
  SerializerNodeType Serialize(Serializer& s) {
    if (s.IsWriting()) {
      for (DictObjectIterator<K, V> i(Begin()); i.IsValid(); ++i) {
        V* _value = i.Value();
        s.PassObject(THIS_REF, this PTR_DEREF GetMode() == DictModeDict ? i.KeyAsString() : "", PTR_TO_REF(_value));
      }

      return (this PTR_DEREF GetMode() == DictModeDict) ? SerializerNodeObject : SerializerNodeArray;
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
            V _prop = s.Struct<V>(i.Key());
            Set(key, _prop);
          } else {
            V _prop = s.Struct<V>();
            Push(_prop);
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

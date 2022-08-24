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

#include "DictBase.mqh"
#include "DictIteratorBase.mqh"
#include "Serializer/Serializer.h"
#include "Serializer/SerializerNodeIterator.h"

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
      this PTR_DEREF _DictSlots_ref PTR_DEREF DictSlots[i] = right._DictSlots_ref.DictSlots[i];
    }
    THIS_ATTR _DictSlots_ref._num_used = right._DictSlots_ref._num_used;
    THIS_ATTR _current_id = right._current_id;
    THIS_ATTR _mode = right._mode;
  }

  /**
   * Copy constructor.
   */
  DictStruct(DictStruct<K, V>& right) {
    Clear();
    Resize(right.GetSlotCount());
    for (unsigned int i = 0; i < (unsigned int)ArraySize(right._DictSlots_ref.DictSlots); ++i) {
      this PTR_DEREF _DictSlots_ref PTR_DEREF DictSlots[i] = right._DictSlots_ref.DictSlots[i];
    }
    THIS_ATTR _DictSlots_ref._num_used = right._DictSlots_ref._num_used;
    THIS_ATTR _current_id = right._current_id;
    THIS_ATTR _mode = right._mode;
  }

  void operator=(const DictStruct<K, V>& right) {
    Clear();
    Resize(right.GetSlotCount());
    for (unsigned int i = 0; i < (unsigned int)ArraySize(right._DictSlots_ref.DictSlots); ++i) {
      THIS_ATTR _DictSlots_ref.DictSlots[i] = right._DictSlots_ref.DictSlots[i];
    }
    THIS_ATTR _DictSlots_ref._num_used = right._DictSlots_ref._num_used;
    THIS_ATTR _current_id = right._current_id;
    THIS_ATTR _mode = right._mode;
  }

  void operator=(DictStruct<K, V>& right) {
    Clear();
    Resize(right.GetSlotCount());
    for (unsigned int i = 0; i < (unsigned int)ArraySize(right._DictSlots_ref.DictSlots); ++i) {
      THIS_ATTR _DictSlots_ref.DictSlots[i] = right._DictSlots_ref.DictSlots[i];
    }
    THIS_ATTR _DictSlots_ref._num_used = right._DictSlots_ref._num_used;
    THIS_ATTR _current_id = right._current_id;
    THIS_ATTR _mode = right._mode;
  }

  void Clear() {
    for (unsigned int i = 0; i < (unsigned int)ArraySize(THIS_ATTR _DictSlots_ref.DictSlots); ++i) {
      THIS_ATTR _DictSlots_ref.DictSlots[i].SetFlags(0);
    }

    THIS_ATTR _DictSlots_ref._num_used = 0;
  }

  DictStructIterator<K, V> Begin() {
    // Searching for first item index.
    for (unsigned int i = 0; i < (unsigned int)ArraySize(THIS_ATTR _DictSlots_ref.DictSlots); ++i) {
      if (THIS_ATTR _DictSlots_ref.DictSlots[i].IsValid() && THIS_ATTR _DictSlots_ref.DictSlots[i].IsUsed()) {
        DictStructIterator<K, V> iter(THIS_REF, i);
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
    if (!InsertInto(THIS_ATTR _DictSlots_ref, value)) return false;
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

    if (!InsertInto(THIS_ATTR _DictSlots_ref, ptr)) return false;
    return true;
  }

  /**
   * Inserts or replaces value for a given key.
   */
  bool Set(K key, V& value) {
    if (!InsertInto(THIS_ATTR _DictSlots_ref, key, value, true)) return false;
    return true;
  }

  /**
   * Index operator. Returns value for a given key.
   */
  V operator[](K key) {
    DictSlot<K, V>* slot;

    int position;

    if (THIS_ATTR _mode == DictModeList)
      slot = THIS_ATTR GetSlot((unsigned int)key);
    else
      slot = GetSlotByKey(THIS_ATTR _DictSlots_ref, key, position);

    if (slot == NULL || !slot PTR_DEREF IsUsed()) {
      Alert("Invalid DictStruct key \"", key, "\" (called by [] operator). Returning empty structure.");
      DebugBreak();
      static V _empty;
      return _empty;
    }

    return slot PTR_DEREF value;
  }

  /**
   * Returns value for a given key.
   */
  V GetByKey(const K _key) {
    unsigned int position;
    DictSlot<K, V>* slot = GetSlotByKey(THIS_ATTR _DictSlots_ref, _key, position);

    if (!slot) {
      static V _empty;
      return _empty;
    }

    return slot PTR_DEREF value;
  }

  /**
   * Returns value for a given key.
   *
   * @return
   *   Returns value for a given key, otherwise the default value.
   */
  V GetByKey(const K _key, V& _default) {
    unsigned int position;
    DictSlot<K, V>* slot = GetSlotByKey(THIS_ATTR _DictSlots_ref, _key, position);

    if (!slot) {
      return _default;
    }

    return slot PTR_DEREF value;
  }

  /**
   * Returns value for a given position.
   */
  V GetByPos(unsigned int _position) {
    DictSlot<K, V>* slot = THIS_ATTR GetSlotByPos(THIS_ATTR _DictSlots_ref, _position);

    if (!slot) {
      Alert("Invalid DictStruct position \"", _position, "\" (called by GetByPos()). Returning empty structure.");
      DebugBreak();
      static V _empty;
      return _empty;
    }

    return slot PTR_DEREF value;
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
#ifdef __MQL__
  template <>
#endif
  bool Contains(const K key, const V& value) {
    unsigned int position;
    DictSlot<K, V>* slot = GetSlotByKey(THIS_ATTR _DictSlots_ref, key, position);

    if (!slot) return false;

    return slot PTR_DEREF value == value;
  }

  /**
   * Returns index of dictionary's value or -1 if value doesn't exist.
   */
#ifdef __MQL__
  template <>
#endif
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
    if (THIS_ATTR _mode == DictModeUnknown)
      THIS_ATTR _mode = DictModeDict;
    else if (THIS_ATTR _mode != DictModeDict) {
      Alert("Warning: Dict already operates as a list, not a dictionary!");
      return false;
    }

    unsigned int position;
    DictSlot<K, V>* _slot = THIS_ATTR GetSlotByKey(dictSlotsRef, key, position);

    // If we have a slot then we can overwrite it.
    if (_slot != NULL) {
      WriteSlot(_slot, key, value, DICT_SLOT_HAS_KEY | DICT_SLOT_IS_USED | DICT_SLOT_WAS_USED);
      // We're done, we don't have to increment number of slots used.
      return true;
    }

    // If we don't have a slot then we should consider growing up number of slots or overwrite some existing slot.

    bool _is_performant = dictSlotsRef.IsPerformant();  // Whether there is no performance problems.
    bool _is_full =
        dictSlotsRef._num_used == ArraySize(dictSlotsRef.DictSlots);  // Whether we don't have empty slots to use.

    if ((_is_full || !_is_performant) && allow_resize) {
      // We have to resize the dict as it is either full or have perfomance problems due to massive number of conflicts
      // when inserting new values.
      if (overflow_listener == NULL) {
        // There is no overflow listener so we can freely grow up the dict.
        if (!GrowUp()) {
          // Can't resize the dict. Error happened.
          return false;
        }
      } else {
        // Overflow listener will decide if we can grow up the dict.
        if (overflow_listener(_is_full ? DICT_LISTENER_FULL_CAN_RESIZE : DICT_LISTENER_NOT_PERFORMANT_CAN_RESIZE,
                              dictSlotsRef._num_used, 0)) {
          // We can freely grow up the dict.
          if (!GrowUp()) {
            // Can't resize the dict. Error happened.
            return false;
          }
        }
      }
    }

    // At this point we have at least one free slot and we won't be doing any dict's grow up in the loop where we search
    // for an empty slot.

    // Position we will start from in order to search free slot.
    position = THIS_ATTR Hash(key) % ArraySize(dictSlotsRef.DictSlots);

    // Saving position for further, possible overwrite.
    unsigned int _starting_position = position;

    // How many times we had to skip slot as it was already occupied.
    unsigned int _num_conflicts = 0;

    // Searching for empty DictSlot<K, V> or used one with the matching key. It skips used, hashless DictSlots.
    while (dictSlotsRef.DictSlots[position].IsUsed() &&
           (!dictSlotsRef.DictSlots[position].HasKey() || dictSlotsRef.DictSlots[position].key != key)) {
      ++_num_conflicts;

      if (overflow_listener == NULL) {
        // There is no overflow listener, so we can't overwrite a slot. We will be looping until we find empty slot.
        continue;
      }

      // We had to skip slot as it is already occupied. Now we are checking if
      // there is too many conflicts/skips and thus we can overwrite slot in
      // the starting position.
      if (overflow_listener(DICT_LISTENER_CONFLICTS_CAN_OVERWRITE, dictSlotsRef._num_used, _num_conflicts)) {
        // Looks like dict is working as buffer and we can overwrite slot in the starting position.
        position = _starting_position;
        break;
      }

      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(dictSlotsRef.DictSlots);
    }

    // Acknowledging slots array about number of conflicts as it calculates average number of conflicts per insert.
    dictSlotsRef.AddConflicts(_num_conflicts);

    // Incrementing number of slots used only if we're writing into empty slot.
    if (!dictSlotsRef.DictSlots[position].IsUsed()) {
      ++dictSlotsRef._num_used;
    }

    // Writing slot in the position of empty slot or, when overwriting, in starting position.
    WriteSlot(dictSlotsRef.DictSlots[position], key, value, DICT_SLOT_HAS_KEY | DICT_SLOT_IS_USED | DICT_SLOT_WAS_USED);
    return true;
  }

  /***
   * Writes slot with given key, value and flags.
   */
  void WriteSlot(DictSlot<K, V>& _slot, const K _key, V& _value, unsigned char _slot_flags) {
    _slot.key = _key;
    _slot.value = _value;
    _slot.SetFlags(_slot_flags);
  }

  /**
   * Inserts hashless value into given array of DictSlots.
   */
  bool InsertInto(DictSlotsRef<K, V>& dictSlotsRef, V& value) {
    if (THIS_ATTR _mode == DictModeUnknown)
      THIS_ATTR _mode = DictModeList;
    else if (THIS_ATTR _mode != DictModeList) {
      Alert("Warning: Dict already operates as a dictionary, not a list!");
      return false;
    }

    if (dictSlotsRef._num_used == ArraySize(dictSlotsRef.DictSlots)) {
      // No DictSlotsRef.DictSlots available, we need to expand array of DictSlotsRef.DictSlots.
      if (!GrowUp()) return false;
    }

    unsigned int position = THIS_ATTR Hash((unsigned int)dictSlotsRef._list_index) % ArraySize(dictSlotsRef.DictSlots);

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
    return Resize(
        MathMax(10, (int)((float)ArraySize(THIS_ATTR _DictSlots_ref.DictSlots) * ((float)(percent + 100) / 100.0f))));
  }

  /**
   * Shrinks or expands array of DictSlots.
   */
  bool Resize(int new_size) {
    if (new_size <= MathMin(THIS_ATTR _DictSlots_ref._num_used, ArraySize(THIS_ATTR _DictSlots_ref.DictSlots))) {
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
    for (i = 0; i < ArraySize(THIS_ATTR _DictSlots_ref.DictSlots); ++i) {
      if (!THIS_ATTR _DictSlots_ref.DictSlots[i].IsUsed()) continue;

      if (THIS_ATTR _DictSlots_ref.DictSlots[i].HasKey()) {
        if (!InsertInto(new_DictSlots, THIS_ATTR _DictSlots_ref.DictSlots[i].key,
                        THIS_ATTR _DictSlots_ref.DictSlots[i].value, false))
          return false;
      } else {
        if (!InsertInto(new_DictSlots, THIS_ATTR _DictSlots_ref.DictSlots[i].value)) return false;
      }
    }
    // Freeing old DictSlots array.
    ArrayFree(THIS_ATTR _DictSlots_ref.DictSlots);

    THIS_ATTR _DictSlots_ref = new_DictSlots;

    return true;
  }

 public:
#ifdef __MQL__
  template <>
#endif
  SerializerNodeType Serialize(Serializer& s) {
    if (s.IsWriting()) {
      for (DictIteratorBase<K, V> i(Begin()); i.IsValid(); ++i)
        s.PassObject(this, THIS_ATTR GetMode() == DictModeDict ? i.KeyAsString() : "", i.Value());

      return (THIS_ATTR GetMode() == DictModeDict) ? SerializerNodeObject : SerializerNodeArray;
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
            Set(key, s.Struct<V>(i.Key()));
          } else {
            Push(s.Struct<V>());
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

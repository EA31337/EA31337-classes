//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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

#include "DictBase.mqh"
#include "Convert.mqh"

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

  Dict(const Dict<K, V>& right) {
    Resize(right.GetSlotCount());
    for (unsigned int i = 0; i < (unsigned int)ArraySize(right._DictSlots_ref.DictSlots); ++i) {
      _DictSlots_ref.DictSlots[i] = right._DictSlots_ref.DictSlots[i];
    }
  }

  /**
   * Inserts value using hashless key.
   */
  bool Push(V value) {
    if (!InsertInto(_DictSlots_ref, value)) return false;
    ++_num_used;
    return true;
  }

  /**
   * Inserts or replaces value for a given key.
   */
  bool Set(K key, V value) {
    if (!InsertInto(_DictSlots_ref, key, value)) return false;
    ++_num_used;
    return true;
  }

  V operator[](K key) {
    if (_mode == DictModeList) return GetSlot((unsigned int)key).value;

    DictSlot<K, V>* slot = GetSlotByKey(key);

    if (!slot) return (V)NULL;

    return slot.value;
  }

  /**
   * Returns value for a given key.
   */
  V GetByKey(const K _key, V _default = NULL) {
    DictSlot<K, V>* slot = GetSlotByKey(_key);

    if (!slot) return _default;

    return slot.value;
  }

  /**
   * Checks whether dictionary contains given key => value pair.
   */
  bool Contains(const K key, const V value) {
    DictSlot<K, V>* slot = GetSlotByKey(key);

    if (!slot) return false;

    return slot.value == value;
  }

 protected:
  /**
   * Inserts value into given array of DictSlots.
   */
  bool InsertInto(DictSlotsRef<K, V>& dictSlotsRef, const K key, V value) {
    if (_mode == DictModeUnknown)
      _mode = DictModeDict;
    else if (_mode != DictModeDict) {
      Alert("Warning: Dict already operates as a list, not a dictionary!");
      return false;
    }

    if (_num_used == ArraySize(dictSlotsRef.DictSlots)) {
      // No DictSlotsRef.DictSlots available, we need to expand array of DictSlotsRef.DictSlots (by 25%).
      if (!Resize(MathMax(10, (int)((float)ArraySize(dictSlotsRef.DictSlots) * 1.25)))) return false;
    }

    unsigned int position = Hash(key) % ArraySize(dictSlotsRef.DictSlots);

    // Searching for empty DictSlot<K, V> or used one with the matching key. It skips used, hashless DictSlots.
    while (dictSlotsRef.DictSlots[position].IsUsed() &&
           (!dictSlotsRef.DictSlots[position].HasKey() || dictSlotsRef.DictSlots[position].key != key)) {
      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(dictSlotsRef.DictSlots);
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
      return false;
    }

    if (_num_used == ArraySize(dictSlotsRef.DictSlots)) {
      // No DictSlotsRef.DictSlots available, we need to expand array of DictSlotsRef.DictSlots (by 25%).
      if (!Resize(MathMax(10, (int)((float)ArraySize(dictSlotsRef.DictSlots) * 1.25)))) return false;
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
    return true;
  }

  /**
   * Shrinks or expands array of DictSlots.
   */
  bool Resize(unsigned int new_size) {
    if (new_size < _num_used) {
      // We can't shrink to less than number of already used DictSlots.
      // It is okay to return true.
      return true;
    }

    DictSlotsRef<K, V> new_DictSlots;

    if (ArrayResize(new_DictSlots.DictSlots, new_size) == -1) return false;

    // Copies entire array of DictSlots into new array of DictSlots. Hashes will be rehashed.
    for (unsigned int i = 0; i < (unsigned int)ArraySize(_DictSlots_ref.DictSlots); ++i) {
      if (!_DictSlots_ref.DictSlots[i].IsUsed()) continue;

      if (_DictSlots_ref.DictSlots[i].HasKey()) {
        if (!InsertInto(new_DictSlots, _DictSlots_ref.DictSlots[i].key, _DictSlots_ref.DictSlots[i].value))
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

  JsonNodeType Serialize(JsonSerializer& s)
  {
    if (s.IsWriting())
    {
      for (DictIteratorBase<K, V> i = Begin(); i.IsValid(); ++i) {
        // As we can't retrieve reference to the Dict's value, we need to
        // use temporary variable.
        V value = i.Value();
        
        s.Pass(this, i.KeyAsString(), value);
      }
      
      return (GetMode() == DictModeDict) ? JsonNodeObject : JsonNodeArray;
    }
    else
    {
      JsonIterator<V> i;
      
      for (i = s.Begin<V>(); i.IsValid(); ++i)
        if (i.HasKey()) {
          // Converting key to a string.
          K key;
          Convert::StringToType(i.Key(), key);

          // Note that we're retrieving value by a key (as we are in an
          // object!).
          Set(key, i.Value(i.Key()));
        }
        else
          Push(i.Value());
      
      return i.ParentNodeType();
    }
  }
};

#endif

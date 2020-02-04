//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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

#include "DictBase.mqh"

/**
 * Hash-table based dictionary.
 */
template<typename K, typename V>
class DictObject : public DictBase<K, V> {
public:

  /**
   * Constructor. You may specifiy intial number of slots that holds values or just leave it as it is.
   */
  DictObject(unsigned int _initial_size = 0)
  {
    if (_initial_size > 0) {
      Resize(_initial_size);
    }
  }

  /**
   * Inserts value using hashless key.
   */
  void Push(V& value)
  {
    InsertInto(_slots_ref.slots, value);
    ++_num_used;
  }

  /**
   * Inserts or replaces value for a given key.
   */
  void Set(K key, V& value)
  {
    InsertInto(_slots_ref.slots, key, value);
    ++_num_used;
  }
  
  /**
   * Returns value for a given key.
   */
  V* GetByKey(const K _key)
  {
    unsigned int position   = Hash(_key) % ArraySize(_slots_ref.slots);
    unsigned int tries_left = ArraySize(_slots_ref.slots);

    while (tries_left-- > 0)
    {
      if (_slots_ref.slots[position].was_used == false) {
        // We stop searching now.
        return NULL;
      }

      if (_slots_ref.slots[position].is_used && _slots_ref.slots[position].has_key && _slots_ref.slots[position].key == _key) {
        // _key matches, returing value from the slot.
        return &_slots_ref.slots[position].value;
      }

      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(_slots_ref.slots);
    }

    // Not found.
    return NULL;
  }

protected:
  
  /**
   * Inserts value into given array of slots.
   */
  void InsertInto(Slot& slots[], const K key, V& value)
  {
    if (_num_used == ArraySize(slots)) {
      // No slots available, we need to expand array of slots (by 25%).
      Resize(MathMax(10, (int) ((float) ArraySize(slots) * 1.25)));
    }

    unsigned int position = Hash(key) % ArraySize(slots);

    // Searching for empty slot or used one with the matching key. It skips used, hashless slots.
    while (slots[position].is_used && (!slots[position].has_key || slots[position].key != key)) {
      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(slots);
    }

    slots[position].key      = key;
    slots[position].value    = value;
    slots[position].has_key  = true;
    slots[position].is_used  = true;
    slots[position].was_used = true;
  }

  /**
   * Inserts hashless value into given array of slots.
   */
  void InsertInto(Slot& slots[], V& value)
  {
    if (_num_used == ArraySize(slots)) {
      // No slots available, we need to expand array of slots (by 25%).
      Resize(MathMax(10, (int) ((float) ArraySize(slots) * 1.25)));
    }

    unsigned int position = Hash((unsigned int) MathRand()) % ArraySize(slots);

    // Searching for empty slot.
    while (slots[position].is_used) {
      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(slots);
    }

    slots[position].value    = value;
    slots[position].has_key  = false;
    slots[position].is_used  = true;
    slots[position].was_used = true;
  }
  

  /**
   * Shrinks or expands array of slots.
   */
  void Resize(unsigned int new_size)
  {
    if (new_size < _num_used) {
    // We can't shrink to less than number of already used slots.
      return;
    }

    SlotsRef new_slots;

    ArrayResize(new_slots.slots, new_size);

    // Copies entire array of slots into new array of slots. Hashes will be rehashed.
    for (unsigned int i = 0; i < (unsigned int) ArraySize(_slots_ref.slots); ++i) {
      if (_slots_ref.slots[i].has_key) {
        InsertInto(new_slots.slots, _slots_ref.slots[i].key, _slots_ref.slots[i].value);
      }
      else {
        InsertInto(new_slots.slots, _slots_ref.slots[i].value);
      }
    }
    // Freeing old slots array.
    ArrayFree(_slots_ref.slots);

    _slots_ref = new_slots;
  }


};

#endif
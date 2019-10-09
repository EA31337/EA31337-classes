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

// Properties.
#property strict

// Prevents processing this includes file for the second time.
#ifndef DICT_MQH
#define DICT_MQH

/**
* Represents a single item in the hash table.
*/
template<typename K, typename V>
struct Slot
{
  bool has_key;  // Whether slot has key (false if slot is hashless).
  bool is_used;  // Whether slot is currently in use.
  bool was_used; // Whether slots was in use and now is in use or was emptied.
  K    key;      // Key used to store value.
  V    value;    // Value stored.

  Slot ()
  {
    is_used = was_used = has_key = false;
  }
};


/**
 * Helper to store slots for faster array switching in MQL4.
 */
template<typename K, typename V>
struct SlotsRef
{
   Slot<K, V> slots[];
};


/**
 * Hash-table based dictionary.
 */
template<typename K, typename V>
class Dict {

public:

  /**
   * Constructor. You may specifiy intial number of slots that holds values or just leave it as it is.
   */
  Dict(uint initial_size = 0)
  {
    _current_id = 0;
    _num_used   = 0;

    if (initial_size != 0) {
      Resize(initial_size);
    }
  }

  /**
   * Inserts value using hashless key.
   */
  void Push(const V value)
  {
    InsertInto(_slots_ref.slots, value);
    ++_num_used;
  }

  /**
   * Inserts or replaces value for a given key.
   */
  void Set(const K key, V value)
  {
    InsertInto(_slots_ref.slots, key, value);
    ++_num_used;
  }

  /**
   * Removes value from the dictionary by the given key (if exists).
   */
  void Unset(const K key)
  {
    uint position   = Hash(key) % ArraySize(_slots_ref.slots);
    uint tries_left = ArraySize(_slots_ref.slots);

    while (tries_left-- > 0)
    {
      if (_slots_ref.slots[position].was_used == false) {
        // We stop searching now.
        return;
      }

      if (_slots_ref.slots[position].is_used && _slots_ref.slots[position].has_key && _slots_ref.slots[position].key == key) {
        // Key perfectly matches, it indicates key exists in the dictionary.
        _slots_ref.slots[position].is_used = false;
        --_num_used;
        return;
      }

      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(_slots_ref.slots);
    }

    // No key found.
  }

  /**
   * Returns number of used slots.
   */
  uint Size()
  {
    return _num_used;
  }

  /**
   * Checks whether given key exists in the dictionary.
   */
  bool KeyExists(const K key)
  {
    uint position   = Hash(key) % ArraySize(_slots_ref.slots);
    uint tries_left = ArraySize(_slots_ref.slots);

    while (tries_left-- > 0)
    {
      if (_slots_ref.slots[position].was_used == false) {
        // We stop searching now.
        return false;
      }

      if (_slots_ref.slots[position].is_used && _slots_ref.slots[position].has_key && _slots_ref.slots[position].key == key) {
        // Key perfectly matches, it indicates key exists in the dictionary.
        return true;
      }

      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(_slots_ref.slots);
    }

    // No key found.
    return false;
  }

  /**
   * Returns value for a given key.
   */
  V GetByKey(const K key)
  {
    uint position   = Hash(key) % ArraySize(_slots_ref.slots);
    uint tries_left = ArraySize(_slots_ref.slots);

    while (tries_left-- > 0)
    {
      if (_slots_ref.slots[position].was_used == false) {
        // We stop searching now.
        return V();
      }

      if (_slots_ref.slots[position].is_used && _slots_ref.slots[position].has_key && _slots_ref.slots[position].key == key) {
        // Key matches, returing value from the slot.
        return _slots_ref.slots[position].value;
      }

      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(_slots_ref.slots);
    }

    // Not found.
    return V();
  }

protected:

  /**
   * Shrinks or expands array of slots.
   */
  void Resize(uint new_size)
  {
    if (new_size < _num_used) {
    // We can't shrink to less than number of already used slots.
      return;
    }

    SlotsRef<K, V> new_slots;

    ArrayResize(new_slots.slots, new_size);

    // Copies entire array of slots into new array of slots. Hashes will be rehashed.
    for (uint i = 0; i < (uint) ArraySize(_slots_ref.slots); ++i) {
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

  /**
   * Inserts value into given array of slots.
   */
  void InsertInto(Slot<K, V>& slots[], const K key, const V value)
  {
    if (_num_used == ArraySize(slots)) {
      // No slots available, we need to expand array of slots (by 25%).
      Resize(MathMax(10, (int) ((float) ArraySize(slots) * 1.25)));
    }

    uint position = Hash(key) % ArraySize(slots);

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
  void InsertInto(Slot<K, V>& slots[], const V value)
  {
    if (_num_used == ArraySize(slots)) {
      // No slots available, we need to expand array of slots (by 25%).
      Resize(MathMax(10, (int) ((float) ArraySize(slots) * 1.25)));
    }

    uint position = Hash((uint) MathRand()) % ArraySize(slots);

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
   * Array of slots.
   */
  SlotsRef<K, V> _slots_ref;

private:

  /**
   * Incremental id used by Push() method.
   */
  uint _current_id;

  /**
   * Number of used slots.
   */
  uint _num_used;

  /* Hash methods */

  /**
   * General hashing function for custom types.
   */
  template<typename X>
  uint Hash(const X& x) {
    return x.hash();
  }

  /**
   * Specialization of hashing function.
   */
  uint Hash(string x) {
    return StringLen(x);
  }

  /**
   * Specialization of hashing function.
   */
  uint Hash(uint x) {
    return x;
  }

  /**
   * Specialization of hashing function.
   */
  uint Hash(int x) {
    return (uint)x;
  }

  /**
   * Specialization of hashing function.
   */
  uint Hash(float x) {
    return (uint) ((ulong) x * 10000 % 10000);
  }

};
#endif

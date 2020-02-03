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

private:

  // Incremental id used by Push() method.
  unsigned int _current_id;

  // Number of used slots.
  unsigned int _num_used;

public:

  /**
   * Constructor. You may specifiy intial number of slots that holds values or just leave it as it is.
   */
  Dict(unsigned int _initial_size = 0)
    : _current_id(0), _num_used(0)
  {
    if (_initial_size > 0) {
      Resize(_initial_size);
    }
  }
  Dict(string _data, string _dlm = "\n")
    : _current_id(0), _num_used(0)
  {
    string _rows[], _row[];
    int _rows_count = StringSplit(_data, StringGetCharacter(_dlm, 0), _rows);
    int _i;
    if (_rows_count > 0) {
      Resize(_rows_count);
      for (_i = 0; _i < _rows_count; _i++) {
        int _row_count = StringSplit(_rows[_i], StringGetCharacter("=", 0), _row);
        if (_row_count >= 2) {
          Set((K) _row[0], (V) _row[1]);
        }
      }
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
    unsigned int position   = Hash(key) % ArraySize(_slots_ref.slots);
    unsigned int tries_left = ArraySize(_slots_ref.slots);

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
  unsigned int Size()
  {
    return _num_used;
  }

  /**
   * Checks whether given key exists in the dictionary.
   */
  bool KeyExists(const K key)
  {
    unsigned int position   = Hash(key) % ArraySize(_slots_ref.slots);
    unsigned int tries_left = ArraySize(_slots_ref.slots);

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
  V GetByKey(const K _key, const V _default = V())
  {
    unsigned int position   = Hash(_key) % ArraySize(_slots_ref.slots);
    unsigned int tries_left = ArraySize(_slots_ref.slots);

    while (tries_left-- > 0)
    {
      if (_slots_ref.slots[position].was_used == false) {
        // We stop searching now.
        return _default;
      }

      if (_slots_ref.slots[position].is_used && _slots_ref.slots[position].has_key && _slots_ref.slots[position].key == _key) {
        // _key matches, returing value from the slot.
        return _slots_ref.slots[position].value;
      }

      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(_slots_ref.slots);
    }

    // Not found.
    return _default;
  }

protected:

  /**
   * Shrinks or expands array of slots.
   */
  void Resize(unsigned int new_size)
  {
    if (new_size < _num_used) {
    // We can't shrink to less than number of already used slots.
      return;
    }

    SlotsRef<K, V> new_slots;

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

  /**
   * Inserts value into given array of slots.
   */
  void InsertInto(Slot<K, V>& slots[], const K key, const V value)
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
  void InsertInto(Slot<K, V>& slots[], const V value)
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
   * Array of slots.
   */
  SlotsRef<K, V> _slots_ref;

  /* Hash methods */

  /**
   * General hashing function for custom types.
   */
  template<typename X>
  unsigned int Hash(const X& x) {
    return x.hash();
  }

  /**
   * Specialization of hashing function.
   */
  unsigned int Hash(string x) {
    return StringLen(x);
  }

  /**
   * Specialization of hashing function.
   */
  unsigned int Hash(unsigned int x) {
    return x;
  }

  /**
   * Specialization of hashing function.
   */
  unsigned int Hash(int x) {
    return (unsigned int)x;
  }

  /**
   * Specialization of hashing function.
   */
  unsigned int Hash(float x) {
    return (unsigned int) ((unsigned long) x * 10000 % 10000);
  }

};
#endif

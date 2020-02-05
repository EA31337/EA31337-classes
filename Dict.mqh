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

#include "DictBase.mqh"

/**
 * Hash-table based dictionary.
 */
template <typename K, typename V>
class Dict : public DictBase<K, V> {
 public:
  Dict() {}

  /**
   * Constructor. You may specifiy intial number of DictSlots that holds values or just leave it as it is.
   */
  Dict(unsigned int _initial_size) {
    if (_initial_size > 0) {
      Resize(_initial_size);
    }
  }

  Dict(string _data, string _dlm = "\n") {}

  /**
   * Inserts value using hashless key.
   */
  void Push(V value) {
    InsertInto(_DictSlots_ref, value);
    ++_num_used;
  }

  /**
   * Inserts or replaces value for a given key.
   */
  void Set(K key, V value) {
    InsertInto(_DictSlots_ref, key, value);
    ++_num_used;
  }

  /**
   * Returns value for a given key.
   */
  V GetByKey(const K _key, V _default = NULL) {
    unsigned int position = Hash(_key) % ArraySize(_DictSlots_ref.DictSlots);
    unsigned int tries_left = ArraySize(_DictSlots_ref.DictSlots);

    while (tries_left-- > 0) {
      if (_DictSlots_ref.DictSlots[position].was_used == false) {
        // We stop searching now.
        return _default;
      }

      if (_DictSlots_ref.DictSlots[position].is_used && _DictSlots_ref.DictSlots[position].has_key &&
          _DictSlots_ref.DictSlots[position].key == _key) {
        // _key matches, returing value from the DictSlot.
        return _DictSlots_ref.DictSlots[position].value;
      }

      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(_DictSlots_ref.DictSlots);
    }

    // Not found.
    return _default;
  }

 protected:
  /**
   * Inserts value into given array of DictSlots.
   */
  void InsertInto(DictSlotsRef<K, V>& dictSlotsRef, const K key, V value) {
    if (_mode == DictMode::UNKNOWN)
      _mode = DictMode::DICT;
    else if (_mode != DictMode::DICT)
      Alert("Warning: Dict already operates as a list, not a dictionary!");

    if (_num_used == ArraySize(dictSlotsRef.DictSlots)) {
      // No DictSlotsRef.DictSlots available, we need to expand array of DictSlotsRef.DictSlots (by 25%).
      Resize(MathMax(10, (int)((float)ArraySize(dictSlotsRef.DictSlots) * 1.25)));
    }

    unsigned int position = Hash(key) % ArraySize(dictSlotsRef.DictSlots);

    // Searching for empty DictSlot<K, V> or used one with the matching key. It skips used, hashless DictSlots.
    while (dictSlotsRef.DictSlots[position].is_used &&
           (!dictSlotsRef.DictSlots[position].has_key || dictSlotsRef.DictSlots[position].key != key)) {
      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(dictSlotsRef.DictSlots);
    }

    dictSlotsRef.DictSlots[position].key = key;
    dictSlotsRef.DictSlots[position].value = value;
    dictSlotsRef.DictSlots[position].has_key = true;
    dictSlotsRef.DictSlots[position].is_used = true;
    dictSlotsRef.DictSlots[position].was_used = true;
  }

  /**
   * Inserts hashless value into given array of DictSlots.
   */
  void InsertInto(DictSlotsRef<K, V>& dictSlotsRef, V value) {
    if (_mode == DictMode::UNKNOWN)
      _mode = DictMode::LIST;
    else if (_mode != DictMode::LIST)
      Alert("Warning: Dict already operates as a dictionary, not a list!");

    if (_num_used == ArraySize(dictSlotsRef.DictSlots)) {
      // No DictSlotsRef.DictSlots available, we need to expand array of DictSlotsRef.DictSlots (by 25%).
      Resize(MathMax(10, (int)((float)ArraySize(dictSlotsRef.DictSlots) * 1.25)));
    }

    unsigned int position = Hash((unsigned int)dictSlotsRef._list_index) % ArraySize(dictSlotsRef.DictSlots);

    // Searching for empty DictSlot<K, V>.
    while (dictSlotsRef.DictSlots[position].is_used) {
      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(dictSlotsRef.DictSlots);
    }

    dictSlotsRef.DictSlots[position].value = value;
    dictSlotsRef.DictSlots[position].has_key = false;
    dictSlotsRef.DictSlots[position].is_used = true;
    dictSlotsRef.DictSlots[position].was_used = true;

    ++dictSlotsRef._list_index;
  }

  /**
   * Shrinks or expands array of DictSlots.
   */
  void Resize(unsigned int new_size) {
    if (new_size < _num_used) {
      // We can't shrink to less than number of already used DictSlots.
      return;
    }

    DictSlotsRef<K, V> new_DictSlots;

    ArrayResize(new_DictSlots.DictSlots, new_size);

    // Copies entire array of DictSlots into new array of DictSlots. Hashes will be rehashed.
    for (unsigned int i = 0; i < (unsigned int)ArraySize(_DictSlots_ref.DictSlots); ++i) {
      if (_DictSlots_ref.DictSlots[i].has_key) {
        InsertInto(new_DictSlots, _DictSlots_ref.DictSlots[i].key, _DictSlots_ref.DictSlots[i].value);
      } else {
        InsertInto(new_DictSlots, _DictSlots_ref.DictSlots[i].value);
      }
    }
    // Freeing old DictSlots array.
    ArrayFree(_DictSlots_ref.DictSlots);

    _DictSlots_ref = new_DictSlots;
  }
};

#endif
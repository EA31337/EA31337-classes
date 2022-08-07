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
#ifndef DICT_BASE_MQH
#define DICT_BASE_MQH

// Includes.
#include "Convert.mqh"
#include "Dict.enum.h"
#include "DictIteratorBase.mqh"
#include "DictSlot.mqh"

/**
 * Dictionary overflow listener. arguments are:
 * - ENUM_DICT_OVERFLOW_REASON overflow_reason
 * - int current_dict_size
 * - int number_of_conflicts
 */
typedef bool (*DictOverflowListener)(ENUM_DICT_OVERFLOW_REASON, int, int);

/**
 * Hash-table based dictionary.
 */
template <typename K, typename V>
class DictBase {
 protected:
  int _hash;

  // Incremental id used by Push() method.
  unsigned int _current_id;

  // Whether Dict operates in yet uknown mode, as dict or as list.
  DictMode _mode;

  // Dictionary flags.
  int _flags;

 public:
  DictBase() {
    _hash = rand();
    _current_id = 0;
    _mode = DictModeUnknown;
    _flags = 0;
  }

  /**
   * Destructor.
   */
  ~DictBase() {}

  DictIteratorBase<K, V> Begin() {
    // Searching for first item index.
    for (unsigned int i = 0; i < (unsigned int)ArraySize(_DictSlots_ref.DictSlots); ++i) {
      if (_DictSlots_ref.DictSlots[i].IsValid() && _DictSlots_ref.DictSlots[i].IsUsed()) {
        DictIteratorBase<K, V> iter(this, i);
        return iter;
      }
    }
    // No items found.
    DictIteratorBase<K, V> invalid;
    return invalid;
  }

  const unsigned int GetSlotCount() const { return ArraySize(_DictSlots_ref.DictSlots); }

  /**
   * Adds flags to dict.
   */
  void AddFlags(int flags) { _flags |= flags; }

  /**
   * Checks whether dict have all given flags.
   */
  bool HasFlags(int flags) { return (_flags & flags) == flags; }

  DictSlot<K, V>* GetSlot(const unsigned int index) {
    if (index >= GetSlotCount()) {
      // Index of out bounds.
      return NULL;
    }

    return &_DictSlots_ref.DictSlots[index];
  }

  /**
   * Returns slot by key.
   */
  DictSlot<K, V>* GetSlotByKey(DictSlotsRef<K, V>& dictSlotsRef, const K _key, unsigned int& position) {
    unsigned int numSlots = ArraySize(dictSlotsRef.DictSlots);

    if (numSlots == 0) return NULL;

    position = Hash(_key) % numSlots;

    unsigned int tries_left = numSlots;

    while (tries_left-- > 0) {
      if (dictSlotsRef.DictSlots[position].WasUsed() == false) {
        // We stop searching now.
        return NULL;
      }

      if (dictSlotsRef.DictSlots[position].IsUsed() && dictSlotsRef.DictSlots[position].HasKey() &&
          dictSlotsRef.DictSlots[position].key == _key) {
        // _key matches, returing value from the DictSlot.
        return &dictSlotsRef.DictSlots[position];
      }

      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(dictSlotsRef.DictSlots);
    }

    return NULL;
  }

  /**
   * Returns slot by position.
   */
  DictSlot<K, V>* GetSlotByPos(DictSlotsRef<K, V>& dictSlotsRef, const unsigned int position) {
    return dictSlotsRef.DictSlots[position].IsUsed() ? &dictSlotsRef.DictSlots[position] : NULL;
  }

  /**
   * Returns hash currently used by Dict. It is used to invalidate iterators after Resize().
   */
  int GetHash() { return _hash; }

  int GetMode() { return _mode; }

  /**
   * Removes value from the dictionary by the given iterator. Could be used to remove value on Dict with
   * DICT_FLAG_FILL_HOLES_UNSORTED flag.
   */
  void Unset(DictIteratorBase<K, V>& iter) {
    InternalUnset(iter.Key());
    if (HasFlags(DICT_FLAG_FILL_HOLES_UNSORTED)) {
      // After incrementing, iterator will use moved slot.
      iter.ShiftPosition(-1, true);
    }
  }

  /**
   * Removes value from the dictionary by the given key (if exists).
   */
  void Unset(const K key) {
    if (HasFlags(DICT_FLAG_FILL_HOLES_UNSORTED)) {
      Print(
          "Unset on Dict with DICT_FLAG_FILL_HOLES_UNSORTED flag must be called by passing the iterator, instead of "
          "the key. Thus way iterator will continue with proper value after incrementation.");
      DebugBreak();
      return;
    }
    InternalUnset(key);
  }

  /**
   * Removes value from the dictionary by the given key (if exists).
   */
  void InternalUnset(const K key) {
    if (ArraySize(_DictSlots_ref.DictSlots) == 0) {
      // Nothing to unset.
      return;
    }

    unsigned int position;

    if (GetMode() == DictModeList) {
      // In list mode value index is the slot index.
      position = (int)key;
    } else {
      position = Hash(key) % ArraySize(_DictSlots_ref.DictSlots);
    }

    unsigned int tries_left = ArraySize(_DictSlots_ref.DictSlots);

    while (tries_left-- > 0) {
      if (_DictSlots_ref.DictSlots[position].WasUsed() == false) {
        // We stop searching now.
        return;
      }

      bool _should_be_removed = false;

      if (_DictSlots_ref.DictSlots[position].IsUsed()) {
        if (GetMode() == DictModeList) {
          _should_be_removed = position == (unsigned int)key;
        } else {
          _should_be_removed =
              _DictSlots_ref.DictSlots[position].HasKey() && _DictSlots_ref.DictSlots[position].key == key;
        }
      }

      if (_should_be_removed) {
        // Key/index perfectly matches, it indicates key/index exists in the dictionary.
        _DictSlots_ref.DictSlots[position].RemoveFlags(DICT_SLOT_IS_USED);

        if (GetMode() == DictModeDict) {
          // In List mode we don't decrement number of used elements.
          --_DictSlots_ref._num_used;
        } else if (HasFlags(DICT_FLAG_FILL_HOLES_UNSORTED)) {
          // This is List mode and we need to fill this hole.
          FillHoleUnsorted(position);
        }
        return;
      } else if (GetMode() == DictModeList) {
        Print("Internal error. Slot should have been removed!");
        DebugBreak();
        return;
      }

      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(_DictSlots_ref.DictSlots);
    }

    // No key found.
  }

  /**
   * Checks whether overflow listener allows dict to grow up.
   */
  bool IsGrowUpAllowed() {
    if (overflow_listener == NULL) {
      return true;
    }

    // Checking if overflow listener allows resize from current to higher number of slots.
    return overflow_listener(DICT_OVERFLOW_REASON_FULL, Size(), 0);
  }

  /**
   * Moves last slot to given one to fill the hole after removing the value.
   */
  void FillHoleUnsorted(int _hole_slot_idx) {
    // After moving last element to fill the hole we
    if ((unsigned int)_hole_slot_idx == Size() - 1) {
      // We've just removed last element, thus don't need to do anything.
    } else {
      // Moving last slot into given one.
      _DictSlots_ref.DictSlots[_hole_slot_idx] = _DictSlots_ref.DictSlots[Size() - 1];

      // Marking last slot as unused.
      _DictSlots_ref.DictSlots[Size() - 1].RemoveFlags(DICT_SLOT_IS_USED);
    }
    // One element less in the List-based Dict.
    --_DictSlots_ref._num_used;
  }

  /**
   * Returns number of used DictSlots.
   */
  const unsigned int Size() { return _DictSlots_ref._num_used; }

  /**
   * Returns number of all (reserved) DictSlots.
   */
  const unsigned int ReservedSize() { return ArraySize(_DictSlots_ref.DictSlots); }

  /**
   * Checks whether given key exists in the dictionary.
   */
  bool KeyExists(const K key, unsigned int& position) {
    int numSlots = ArraySize(_DictSlots_ref.DictSlots);

    if (numSlots == 0) return false;

    position = Hash(key) % numSlots;

    unsigned int tries_left = numSlots;

    while (tries_left-- > 0) {
      if (_DictSlots_ref.DictSlots[position].WasUsed() == false) {
        // We stop searching now.
        return false;
      }

      if (_DictSlots_ref.DictSlots[position].IsUsed() && _DictSlots_ref.DictSlots[position].HasKey() &&
          _DictSlots_ref.DictSlots[position].key == key) {
        // Key perfectly matches, it indicates key exists in the dictionary.
        return true;
      }

      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % numSlots;
    }

    // No key found.
    return false;
  }
  bool KeyExists(const K key) {
    unsigned int position;
    return KeyExists(key, position);
  }

  /**
   * Sets dictionary overflow listener and, optionally, maximum number of conflicts which will cause overflow and
   * eventually a slot reuse.
   */
  void SetOverflowListener(DictOverflowListener _listener, int _num_max_conflicts = -1) {
    overflow_listener = _listener;

    if (_num_max_conflicts != -1) {
      SetMaxConflicts(_num_max_conflicts);
    }
  }

  /**
   * Sets maximum number of conflicts which will cause overflow and a slot reuse if no overflow listener was set.
   */
  void SetMaxConflicts(int _num_max_conflicts = 0) { overflow_listener_max_conflicts = _num_max_conflicts; }

 protected:
  /**
   * Array of DictSlots.
   */
  DictSlotsRef<K, V> _DictSlots_ref;

  DictOverflowListener overflow_listener;
  unsigned int overflow_listener_max_conflicts;

  /* Hash methods */

  /**
   * Specialization of hashing function.
   */
  template <typename X>
  unsigned int Hash(X x) {
    return (int)x;
  }

  /**
   * Specialization of hashing function.
   */
  unsigned int Hash(datetime x) { return (int)x; }

  /**
   * Specialization of hashing function.
   */
  unsigned int Hash(const string& x) {
    ARRAY(unsigned char, c);
    unsigned int h = 0;

    if (!IsNull(x)) {
      h = 5381;
      int n = StringToCharArray(x, c);
      for (int i = 0; i < n; i++) {
        h = ((h << 5) + h) + c[i];
      }
    }

    return h;
  }

  /**
   * Specialization of hashing function.
   */
  unsigned int Hash(unsigned int x) { return x; }

  /**
   * Specialization of hashing function.
   */
  unsigned int Hash(int x) { return (unsigned int)x; }

  /**
   * Specialization of hashing function.
   */
  unsigned int Hash(float x) { return (unsigned int)((unsigned long)x * 10000 % 10000); }
};

#endif

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
#ifndef DICT_BASE_MQH
#define DICT_BASE_MQH

// Includes.
#include "Convert.mqh"
#include "DictIteratorBase.mqh"
#include "DictSlot.mqh"
#include "Serializer.mqh"

/**
 * Whether Dict operates in yet uknown mode, as dict or as list.
 */
enum DictMode { DictModeUnknown, DictModeDict, DictModeList };

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

  Ref<Log> _logger;

 public:
  DictBase() {
    _hash = rand();
    _current_id = 0;
    _mode = DictModeUnknown;
  }

  /**
   * Destructor.
   */
  ~DictBase() {}

  /**
   * Returns logger object.
   */
  Log* Logger() { return _logger.Ptr(); }

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
   * Removes value from the dictionary by the given key (if exists).
   */
  void Unset(const K key) {
    if (ArraySize(_DictSlots_ref.DictSlots) == 0) {
      // Nothing to unset.
      return;
    }

    unsigned int position = Hash(key) % ArraySize(_DictSlots_ref.DictSlots);
    unsigned int tries_left = ArraySize(_DictSlots_ref.DictSlots);

    while (tries_left-- > 0) {
      if (_DictSlots_ref.DictSlots[position].WasUsed() == false) {
        // We stop searching now.
        return;
      }

      if (_DictSlots_ref.DictSlots[position].IsUsed() && _DictSlots_ref.DictSlots[position].HasKey() &&
          _DictSlots_ref.DictSlots[position].key == key) {
        // Key perfectly matches, it indicates key exists in the dictionary.
        _DictSlots_ref.DictSlots[position].RemoveFlags(DICT_SLOT_IS_USED);
        --_DictSlots_ref._num_used;
        return;
      }

      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(_DictSlots_ref.DictSlots);
    }

    // No key found.
  }

  /**
   * Returns number of used DictSlots.
   */
  unsigned int Size() { return _DictSlots_ref._num_used; }

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

 protected:
  /**
   * Array of DictSlots.
   */
  DictSlotsRef<K, V> _DictSlots_ref;

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
    unsigned char c[];
    unsigned int h = 0;

    if (x != NULL) {
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

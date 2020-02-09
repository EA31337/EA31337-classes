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
#ifndef DICT_BASE_MQH
#define DICT_BASE_MQH

#include "JSON.mqh"

/**
 * Represents a single item in the hash table.
 */
template <typename K, typename V>
struct DictSlot {
  bool has_key;   // Whether DictSlot has key (false if DictSlot<K, V> is hashless).
  bool is_used;   // Whether DictSlot is currently in use.
  bool was_used;  // Whether DictSlots was in use and now is in use or was emptied.
  K key;          // Key used to store value.
  V value;        // Value stored.

  DictSlot() { is_used = was_used = has_key = false; }
};

template <typename K, typename V>
struct DictSlotsRef {
  DictSlot<K, V> DictSlots[];

  // Incremental index for dict operating in list mode.
  unsigned int _list_index;

  DictSlotsRef() { _list_index = 0; }
};

/**
 * Whether Dict operates in yet uknown mode, as dict or as list.
 */
enum DictMode { UNKNOWN, DICT, LIST };

template <typename X>
string DictMakeKey(X value) {
  return "\"" + JSON::Stringify(value) + "\"";
}

/**
 * Hash-table based dictionary.
 */
template <typename K, typename V>
class DictBase {
 protected:
  // Incremental id used by Push() method.
  unsigned int _current_id;

  // Number of used DictSlots.
  unsigned int _num_used;

  // Whether Dict operates in yet uknown mode, as dict or as list.
  DictMode _mode;

 public:
  /**
   * Helper to store DictSlots for faster array switching in MQL4.
   */

 public:
  DictBase() {
    _current_id = 0;
    _num_used = 0;
    _mode = DictMode::UNKNOWN;
  }

  unsigned int GetDictSlotCount() { return ArraySize(_DictSlots_ref.DictSlots); }

  DictSlot<K, V> GetDictSlot(const unsigned int index) { return _DictSlots_ref.DictSlots[index]; }

  string ToJSON(bool value, const bool stripWhitespaces, unsigned int indentation) { return JSON::Stringify(value); }

  string ToJSON(int value, const bool stripWhitespaces, unsigned int indentation) { return JSON::Stringify(value); }

  string ToJSON(float value, const bool stripWhitespaces, unsigned int indentation) { return JSON::Stringify(value); }

  string ToJSON(double value, const bool stripWhitespaces, unsigned int indentation) { return JSON::Stringify(value); }

  string ToJSON(string value, const bool stripWhitespaces, unsigned int indentation) { return JSON::Stringify(value); }

  template <typename X, typename Y>
  string ToJSON(DictBase<X, Y>& value, const bool stripWhitespaces = false, const unsigned int indentation = 0) {
    return value.ToJSON(stripWhitespaces, indentation);
  }

  string ToJSON(const bool stripWhitespaces = false, const unsigned int indentation = 2) {
    string json = _mode == DictMode::LIST ? "[" : "{";

    if (!stripWhitespaces) json += "\n";

    unsigned int numDictSlots = GetDictSlotCount();
    bool alreadyStarted = false;

    for (unsigned int i = 0; i < numDictSlots; ++i) {
      DictSlot<K, V> dictSlot = GetDictSlot(i);

      if (!dictSlot.is_used) continue;

      if (alreadyStarted) {
        // Adding continuation symbol (',');
        json += ",";
        if (!stripWhitespaces) json += "\n";
      } else
        alreadyStarted = true;

      if (!stripWhitespaces)
        for (unsigned int j = 0; j < indentation; ++j) json += " ";

      if (_mode != DictMode::LIST) {
        json += DictMakeKey(dictSlot.key) + ":";
        if (!stripWhitespaces) json += " ";
      }

      json += ToJSON(dictSlot.value, stripWhitespaces, indentation + JSON_INDENTATION);
    }

    if (!stripWhitespaces) json += "\n";

    if (!stripWhitespaces)
      for (unsigned int k = 0; k < indentation - 2; ++k) json += " ";

    json += _mode == DictMode::LIST ? "]" : "}";

    return json;
  }

  /**
   * Removes value from the dictionary by the given key (if exists).
   */
  void Unset(const K key) {
    unsigned int position = Hash(key) % ArraySize(_DictSlots_ref.DictSlots);
    unsigned int tries_left = ArraySize(_DictSlots_ref.DictSlots);

    while (tries_left-- > 0) {
      if (_DictSlots_ref.DictSlots[position].was_used == false) {
        // We stop searching now.
        return;
      }

      if (_DictSlots_ref.DictSlots[position].is_used && _DictSlots_ref.DictSlots[position].has_key &&
          _DictSlots_ref.DictSlots[position].key == key) {
        // Key perfectly matches, it indicates key exists in the dictionary.
        _DictSlots_ref.DictSlots[position].is_used = false;
        --_num_used;
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
  unsigned int Size() { return _num_used; }

  /**
   * Checks whether given key exists in the dictionary.
   */
  bool KeyExists(const K key) {
    unsigned int position = Hash(key) % ArraySize(_DictSlots_ref.DictSlots);
    unsigned int tries_left = ArraySize(_DictSlots_ref.DictSlots);

    while (tries_left-- > 0) {
      if (_DictSlots_ref.DictSlots[position].was_used == false) {
        // We stop searching now.
        return false;
      }

      if (_DictSlots_ref.DictSlots[position].is_used && _DictSlots_ref.DictSlots[position].has_key &&
          _DictSlots_ref.DictSlots[position].key == key) {
        // Key perfectly matches, it indicates key exists in the dictionary.
        return true;
      }

      // Position may overflow, so we will start from the beginning.
      position = (position + 1) % ArraySize(_DictSlots_ref.DictSlots);
    }

    // No key found.
    return false;
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

    return h % ArraySize(_DictSlots_ref.DictSlots);
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
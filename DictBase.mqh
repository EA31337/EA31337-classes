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
 * Hash-table based dictionary.
 */
template<typename K, typename V>
class DictBase {
protected:

  // Incremental id used by Push() method.
  unsigned int _current_id;

  // Number of used slots.
  unsigned int _num_used;

public:

  /**
  * Represents a single item in the hash table.
  */
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
  struct SlotsRef
  {
     Slot slots[];
  };

public:

  DictBase()
  {
    _current_id = 0;
    _num_used   = 0;
  }
  
  uint GetSlotCount() {
    return ArraySize(_slots_ref.slots);
  }
  
  Slot GetSlot(uint index) {
    return _slots_ref.slots[index];
  }
  
  virtual string ToJSON(bool value, uint indent = 0) {
    return JSON::Stringify(value, indent);
  }

  virtual string ToJSON(int value, uint indent = 0) {
    return JSON::Stringify(value, indent);
  }

  virtual string ToJSON(float value, uint indent = 0) {
    return JSON::Stringify(value, indent);
  }

  virtual string ToJSON(double value, uint indent = 0) {
    return JSON::Stringify(value, indent);
  }

  virtual string ToJSON(string value, uint indent = 0) {
    return JSON::Stringify(value, indent);
  }

  template<typename X, typename Y>
  string ToJSON(DictBase<X, Y> &value, uint indent = 0) {
    return value.ToJSON(indent);
  }
  
  virtual string ToJSON(uint indentation = 2) {
    string json = "{\n";
    
    uint numSlots = GetSlotCount();
    bool alreadyStarted = false;
    
    for (uint i = 0; i < numSlots; ++i)
    {
      Slot slot = GetSlot(i);
      
      if (!slot.is_used)
        continue;
        
      if (alreadyStarted)
        // Adding continuation symbol (',');
        json += ",\n";
      else
        alreadyStarted = true;

      for (uint j = 0; j < indentation; ++j)
        json += " ";
      
      json += JSON::Stringify(slot.key) + ": ";
      
      json += ToJSON(slot.value, indentation + JSON_INDENTATION);
    }
    
    json += "\n";
    
    for (uint j = 0; j < indentation - 2; ++j)
      json += " ";
      
    json += "}";

  
    return json;

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

protected:

  /**
   * Array of slots.
   */
  SlotsRef _slots_ref;

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
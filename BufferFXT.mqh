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

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Prevents processing this includes file for the second time.
#ifndef BUFFER_FXT_MQH
#define BUFFER_FXT_MQH

// Includes.
#include "DictStruct.mqh"

// Structs.
struct BufferFXTEntry {
 public:
  bool operator==(const BufferFXTEntry& _s) {
    // @fixme
    return false;
  }
  string ToJSON() {
    // @fixme
    return "{}";
  }
};

string ToJSON(BufferFXTEntry& _value, const bool, const unsigned int) { return _value.ToJSON(); };

/**
 * Implements class to store tick data.
 */
class BufferFXT : public DictStruct<long, BufferFXTEntry> {
 public:
  BufferFXT() {}

  /**
   * Adds new value.
   */
  void Add(BufferFXTEntry& _value, long _dt = 0) {
    _dt = _dt > 0 ? _dt : TimeCurrent();
    Set(_dt, _value);
  }

  /**
   * Save data into file.
   */
  void SaveToFile() {
    // @todo: foreach BufferFXTEntry
    // @see: https://docs.mql4.com/files/filewritestruct
  }

};

#endif  // BUFFER_FXT_MQH

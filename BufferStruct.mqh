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
#ifndef BUFFER_STRUCT_MQH
#define BUFFER_STRUCT_MQH

// Includes.
#include "DictStruct.mqh"

// Structs.
struct BufferStructEntry : public MqlParam {
 public:
  bool operator==(const BufferStructEntry& _s) {
    return type == _s.type && double_value == _s.double_value && integer_value == _s.integer_value &&
           string_value == _s.string_value;
  }

  JsonNodeType Serialize(JsonSerializer& s) {
    s.PassEnum(this, "type", type);

    string aux_string;

    switch (type) {
      case TYPE_BOOL:
      case TYPE_UCHAR:
      case TYPE_CHAR:
      case TYPE_USHORT:
      case TYPE_SHORT:
      case TYPE_UINT:
      case TYPE_INT:
      case TYPE_ULONG:
      case TYPE_LONG:
        s.Pass(this, "value", integer_value);
        break;

      case TYPE_DOUBLE:
        s.Pass(this, "value", double_value);
        break;

      case TYPE_STRING:
        s.Pass(this, "value", string_value);
        break;

      case TYPE_DATETIME:
        if (s.IsWriting()) {
          aux_string = TimeToString(integer_value);
          s.Pass(this, "value", aux_string);
        } else {
          s.Pass(this, "value", aux_string);
          integer_value = StringToTime(aux_string);
        }
        break;
    }

    return JsonNodeObject;
  }
};

/**
 * Class to store struct data.
 */
template <typename TStruct>
class BufferStruct : public DictStruct<long, TStruct> {
 public:
  void BufferStruct() {}

  /**
   * Adds new value.
   */
  void Add(TStruct& _value, long _dt = 0) {
    _dt = _dt > 0 ? _dt : TimeCurrent();
    Set(_dt, _value);
  }
};

#endif  // BUFFER_STRUCT_MQH

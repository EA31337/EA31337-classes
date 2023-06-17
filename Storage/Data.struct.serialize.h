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

/**
 * @file
 * Includes Data struct serialization methods.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Data.struct.h"
#include "../Serializer/Serializer.h"

/* Method to serialize DataParamEntry struct. */
SerializerNodeType DataParamEntry::Serialize(Serializer &s) {
  s.PassEnum(THIS_REF, "type", type, SERIALIZER_FIELD_FLAG_HIDDEN);
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
      s.Pass(THIS_REF, "value", integer_value);
      break;

    case TYPE_DOUBLE:
      s.Pass(THIS_REF, "value", double_value);
      break;

    case TYPE_STRING:
      s.Pass(THIS_REF, "value", string_value);
      break;

    case TYPE_DATETIME:
      if (s.IsWriting()) {
        aux_string = TimeToString(integer_value);
        s.Pass(THIS_REF, "value", aux_string);
      } else {
        s.Pass(THIS_REF, "value", aux_string);
        integer_value = StringToTime(aux_string);
      }
      break;

    default:
      // Unknown type. Serializing anyway.
      s.Pass(THIS_REF, "value", aux_string);
  }
  return SerializerNodeObject;
}

//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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
 * Includes IndicatorData's struct serializers.
 */

#include "../Serializer.mqh"

// Forward class declaration.
class Serializer;

/* Method to serialize IndicatorDataEntry structure. */
SerializerNodeType IndicatorDataEntry::Serialize(Serializer &_s) {
  int _asize = ArraySize(values);
  _s.Pass(THIS_REF, "datetime", timestamp, SERIALIZER_FIELD_FLAG_DYNAMIC);
  _s.Pass(THIS_REF, "flags", flags, SERIALIZER_FIELD_FLAG_DYNAMIC);
  for (int i = 0; i < _asize; i++) {
    // _s.Pass(THIS_REF, (string)i, values[i], SERIALIZER_FIELD_FLAG_DYNAMIC | SERIALIZER_FIELD_FLAG_FEATURE); // Can
    // this work? _s.Pass(THIS_REF, (string)i, GetEntry(i), SERIALIZER_FIELD_FLAG_DYNAMIC |
    // SERIALIZER_FIELD_FLAG_FEATURE); // Can this work?

    switch (values[i].GetDataType()) {
      case TYPE_DOUBLE:
        _s.Pass(THIS_REF, (string)i, values[i].value.vdbl,
                SERIALIZER_FIELD_FLAG_DYNAMIC | SERIALIZER_FIELD_FLAG_FEATURE);
        break;
      case TYPE_FLOAT:
        _s.Pass(THIS_REF, (string)i, values[i].value.vflt,
                SERIALIZER_FIELD_FLAG_DYNAMIC | SERIALIZER_FIELD_FLAG_FEATURE);
        break;
      case TYPE_INT:
      case TYPE_UINT:
        if (CheckFlags(INDI_ENTRY_FLAG_IS_BITWISE)) {
          // Split for each bit and pass 0 or 1.
          for (int j = 0; j < sizeof(int) * 8; ++j) {
            int _value = (values[i].value.vint & (1 << j)) != 0;
            _s.Pass(THIS_REF, StringFormat("%d@%d", i, j), _value, SERIALIZER_FIELD_FLAG_FEATURE);
          }
        } else {
          _s.Pass(THIS_REF, (string)i, values[i].value.vint,
                  SERIALIZER_FIELD_FLAG_DYNAMIC | SERIALIZER_FIELD_FLAG_FEATURE);
        }
        break;
      case TYPE_LONG:
      case TYPE_ULONG:
        if (CheckFlags(INDI_ENTRY_FLAG_IS_BITWISE)) {
          // Split for each bit and pass 0 or 1.
          /* @fixme: j, j already defined.
          for (int j = 0; j < sizeof(int) * 8; ++j) {
            int _value = (values[i].vlong & (1 << j)) != 0;
            _s.Pass(THIS_REF, StringFormat("%d@%d", i, j), _value, SERIALIZER_FIELD_FLAG_FEATURE);
          }
          */
          SetUserError(ERR_INVALID_PARAMETER);
        } else {
          _s.Pass(THIS_REF, (string)i, values[i].value.vlong,
                  SERIALIZER_FIELD_FLAG_DYNAMIC | SERIALIZER_FIELD_FLAG_FEATURE);
        }
        break;
      default:
        // Type 0 means invalid entry. Invalid entries shouldn't be serialized.
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
  }
  return SerializerNodeObject;
}

/* Method to serialize IndicatorDataEntry's IndicatorDataEntryValue union. */
SerializerNodeType IndicatorDataEntryValue::Serialize(Serializer &_s) {
  _s.Pass(THIS_REF, "flags", flags);
  _s.Pass(THIS_REF, "vdbl", value.vdbl);
  _s.Pass(THIS_REF, "vflt", value.vflt);
  _s.Pass(THIS_REF, "vint", value.vint);
  _s.Pass(THIS_REF, "vlong", value.vlong);
  return SerializerNodeObject;
};

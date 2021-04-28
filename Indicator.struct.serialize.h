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
 * Includes Indicator's struct serializers.
 */

// Forward class declaration.
class Serializer;

/* Method to serialize IndicatorDataEntry structure. */
SerializerNodeType IndicatorDataEntry::Serialize(Serializer &_s) {
  int _asize = ArraySize(values);
  _s.Pass(this, "datetime", timestamp);
  for (int i = 0; i < _asize; i++) {
    if (IsDouble()) {
      _s.Pass(this, (string)i, values[i].vdbl);
    } else if (IsBitwise()) {
      // Split for each bit and pass 0 or 1.
      for (int j = 0; j < sizeof(int) * 8; ++j) {
        string _key = IntegerToString(i) + "@" + IntegerToString(j);
        int _value = (values[i].vint & (1 << j)) != 0;
        _s.Pass(this, _key, _value, SERIALIZER_FIELD_FLAG_HIDDEN);
      }
    } else {
      _s.Pass(this, IntegerToString(i), values[i].vint);
    }
  }
  // _s.Pass(this, "is_valid", IsValid(), SERIALIZER_FIELD_FLAG_HIDDEN);
  // _s.Pass(this, "is_bitwise", IsBitwise(), SERIALIZER_FIELD_FLAG_HIDDEN);
  return SerializerNodeObject;
}

/* Method to serialize IndicatorParams structure. */
SerializerNodeType IndicatorParams::Serialize(Serializer &s) {
  s.Pass(this, "name", name);
  s.Pass(this, "shift", shift);
  s.Pass(this, "max_modes", max_modes);
  s.Pass(this, "max_buffers", max_buffers);
  s.PassEnum(this, "itype", itype);
  s.PassEnum(this, "idstype", idstype);
  s.PassEnum(this, "dtype", dtype);
  // s.PassObject(this, "indicator", indi_data); // @todo
  // s.Pass(this, "indi_data_ownership", indi_data_ownership);
  s.Pass(this, "indi_color", indi_color, SERIALIZER_FIELD_FLAG_HIDDEN);
  s.Pass(this, "indi_mode", indi_mode);
  s.Pass(this, "is_draw", is_draw);
  s.Pass(this, "draw_window", draw_window, SERIALIZER_FIELD_FLAG_HIDDEN);
  s.Pass(this, "custom_indi_name", custom_indi_name);
  s.Enter(SerializerEnterObject, "chart");
  // ChartParams::Serialize(s); // @fixme
  s.Leave();
  return SerializerNodeObject;
}

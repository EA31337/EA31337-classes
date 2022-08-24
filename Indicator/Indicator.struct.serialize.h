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

#include "../Serializer/Serializer.h"
#include "../Serializer/SerializerNode.enum.h"
#include "Indicator.struct.h"

/* Method to serialize IndicatorParams structure. */
SerializerNodeType IndicatorParams::Serialize(Serializer &s) {
  s.Pass(THIS_REF, "name", name);
  s.Pass(THIS_REF, "shift", shift);
  // s.Pass(THIS_REF, "max_modes", max_modes);
  // s.Pass(THIS_REF, "max_buffers", max_buffers);
  s.PassEnum(THIS_REF, "itype", itype);
  // s.PassEnum(THIS_REF, "idstype", idstype);
  // s.PassEnum(THIS_REF, "dtype", dtype);

  // s.PassObject(this, "indicator", indi_data); // @todo
  // s.Pass(THIS_REF, "indi_data_ownership", indi_data_ownership);
  // s.Pass(THIS_REF, "indi_color", indi_color, SERIALIZER_FIELD_FLAG_HIDDEN);
  // s.Pass(THIS_REF, "is_draw", is_draw);
  // s.Pass(THIS_REF, "draw_window", draw_window, SERIALIZER_FIELD_FLAG_HIDDEN);
  s.Pass(THIS_REF, "custom_indi_name", custom_indi_name);
  return SerializerNodeObject;
}

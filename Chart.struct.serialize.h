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
 * Includes Chart's struct serializers.
 */

// Forward class declaration.
class Serializer;

// Includes.
#include "Serializer.mqh"
#include "SerializerNode.enum.h"

/* Method to serialize ChartEntry structure. */
SerializerNodeType ChartEntry::Serialize(Serializer& _s) {
  _s.PassStruct(THIS_REF, "bar", bar, SERIALIZER_FIELD_FLAG_DYNAMIC);
  return SerializerNodeObject;
}

/* Method to serialize ChartParams structure. */
SerializerNodeType ChartParams::Serialize(Serializer& s) {
  s.Pass(THIS_REF, "id", id);
  s.Pass(THIS_REF, "symbol", symbol);
  // s.PassStruct(THIS_REF, "tf", tf); // @fixme
  return SerializerNodeObject;
}

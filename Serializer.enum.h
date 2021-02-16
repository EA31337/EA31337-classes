//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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
 * Includes Serializer's enums.
 */

enum SerializerEnterMode { SerializerEnterArray, SerializerEnterObject };
enum SerializerMode { Serialize, Unserialize };

enum ENUM_SERIALIZER_FLAGS {
  SERIALIZER_FLAG_SKIP_HIDDEN = 1,
  SERIALIZER_FLAG_ROOT_NODE = 2,
  SERIALIZER_FLAG_SKIP_PUSH = 4,
  SERIALIZER_FLAG_SINGLE_VALUE = 8,
  SERIALIZER_FLAG_SIMULATE_SERIALIZE = 16,
  SERIALIZER_FLAG_EXCLUDE_DEFAULT = 32,
  SERIALIZER_FLAG_INCLUDE_DYNAMIC = 64 | SERIALIZER_FLAG_EXCLUDE_DEFAULT,
  SERIALIZER_FLAG_INCLUDE_FEATURE = 128 | SERIALIZER_FLAG_EXCLUDE_DEFAULT,
  SERIALIZER_FLAG_INCLUDE_DEFAULT = 256,
  SERIALIZER_FLAG_INCLUDE_ALL = SERIALIZER_FLAG_INCLUDE_DEFAULT | SERIALIZER_FLAG_INCLUDE_DYNAMIC | SERIALIZER_FLAG_INCLUDE_FEATURE,  
};

enum ENUM_SERIALIZER_FIELD_FLAGS {
  SERIALIZER_FIELD_FLAG_HIDDEN = 1,
  SERIALIZER_FIELD_FLAG_DYNAMIC = 2,
  SERIALIZER_FIELD_FLAG_FEATURE = 4,
  SERIALIZER_FIELD_FLAG_DEFAULT = 8,
  SERIALIZER_FIELD_FLAG_VISIBLE = 16
};


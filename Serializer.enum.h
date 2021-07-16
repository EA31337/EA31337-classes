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
 * Includes Serializer's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

/* Enumeration for serializer enter mode. */
enum SerializerEnterMode { SerializerEnterArray, SerializerEnterObject };

/* Enumeration for serializer mode. */
enum SerializerMode { Serialize, Unserialize };

/* Enumeration for serializer flags. */
enum ENUM_SERIALIZER_FLAGS {
  _SERIALIZER_FLAGS_START = 0,
  SERIALIZER_FLAG_SKIP_HIDDEN = 1 << 0,
  SERIALIZER_FLAG_ROOT_NODE = 1 << 1,
  SERIALIZER_FLAG_SKIP_PUSH = 1 << 2,
  SERIALIZER_FLAG_SINGLE_VALUE = 1 << 3,
  SERIALIZER_FLAG_SIMULATE_SERIALIZE = 1 << 4,
  SERIALIZER_FLAG_EXCLUDE_DEFAULT = 1 << 5,
  SERIALIZER_FLAG_INCLUDE_DYNAMIC = (1 << 6) | SERIALIZER_FLAG_EXCLUDE_DEFAULT,
  SERIALIZER_FLAG_INCLUDE_FEATURE = (1 << 7) | SERIALIZER_FLAG_EXCLUDE_DEFAULT,
  SERIALIZER_FLAG_INCLUDE_DEFAULT = 1 << 8,
  SERIALIZER_FLAG_REUSE_STUB = 1 << 9,
  SERIALIZER_FLAG_REUSE_OBJECT = 1 << 10,
  _SERIALIZER_FLAGS_END,
  // Compound flags.
  SERIALIZER_FLAG_INCLUDE_ALL =
      SERIALIZER_FLAG_INCLUDE_DEFAULT | SERIALIZER_FLAG_INCLUDE_DYNAMIC | SERIALIZER_FLAG_INCLUDE_FEATURE,
};

/* Enumeration for serializer field flags. */
enum ENUM_SERIALIZER_FIELD_FLAGS {
  _SERIALIZER_FIELD_FLAGS_START = 1 << 16,
  SERIALIZER_FIELD_FLAG_HIDDEN = 1 << 16,
  SERIALIZER_FIELD_FLAG_DYNAMIC = 1 << 17,
  SERIALIZER_FIELD_FLAG_FEATURE = 1 << 18,
  SERIALIZER_FIELD_FLAG_DEFAULT = 1 << 19,
  SERIALIZER_FIELD_FLAG_VISIBLE = 1 << 20,
  _SERIALIZER_FIELD_FLAGS_END
};

enum ENUMSERIALIZER_GENERIC_FLAGS {
  _SERIALIZER_GENERIC_FLAGS_START = 1 << 24,
  _SERIALIZER_GENERIC_FLAGS_END,
};

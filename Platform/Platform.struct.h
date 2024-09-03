//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Includes Platform's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Serializer/SerializerNode.enum.h"

/* Defines struct for Platform parameters. */
struct PlatformParams {
 private:
  int id;
  string name;

 public:
  // Enumeration of platform parameters.
  enum ENUM_PLATFORM_PARAM {
    PLATFORM_PARAM_ID = 1,  // ID
    PLATFORM_PARAM_NAME,    // Name
    FINAL_ENUM_PLATFORM_PARAM_ENTRY
  };
#define ENUM_PLATFORM_PARAM STRUCT_ENUM(PlatformParams, ENUM_PLATFORM_PARAM)
 public:
  // Constructors.
  PlatformParams() {}
  PlatformParams(const PlatformParams &_eparams) { THIS_REF = _eparams; }
  PlatformParams(string _entry) { SerializerConverter::FromString<SerializerJson>(_entry).ToStruct(THIS_REF); }
  // Getters.
  template <typename T>
  T Get(ENUM_PLATFORM_PARAM _param) {
    switch (_param) {
      case PLATFORM_PARAM_ID:
        return (T)id;
      case PLATFORM_PARAM_NAME:
        return (T)name;
      default:
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  // Setters.
  template <typename T>
  void Set(ENUM_TRADE_PARAM _param, T _value) {
    switch (_param) {
      case PLATFORM_PARAM_ID:
        ConvertBasic::Convert(_value, id);
        return;
      case PLATFORM_PARAM_NAME:
        ConvertBasic::Convert(_value, name);
        return;
      default:
        break;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  // Serializers.
  SerializerNodeType Serialize(Serializer &s) const {
    s.Pass(THIS_REF, "id", id);
    s.Pass(THIS_REF, "name", name);
    return SerializerNodeObject;
  }
};

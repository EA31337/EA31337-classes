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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Common.extern.h"
#include "Std.h"
#include "Storage/Array.h"
#include "Storage/DateTime.h"
#include "Storage/String.h"

/**
 * Class to provide conversion methods.
 */
class ConvertBasic {
 public:
  /**
   * Convert integer to hex.
   */
  static string IntToHex(long long_number) {
    string result;
    int integer_number = (int)long_number;
    for (int i = 0; i < 4; i++) {
      int byte = (integer_number >> (i * 8)) & 0xff;
      result += StringFormat("%02x", byte);
    }
    return result;
  }

  /**
   * Convert character into integer.
   */
  static int CharToInt(ARRAY_REF(int, _chars)) {
    return ((_chars[0]) | (_chars[1] << 8) | (_chars[2] << 16) | (_chars[3] << 24));
  }

  /**
   * Assume: len % 4 == 0.
   */
  static int String4ToIntArray(ARRAY_REF(int, output), string in) {
    int len;
    int i, j;
    len = StringLen(in);
    if (len % 4 != 0) len = len - len % 4;
    int size = ArraySize(output);
    if (size < len / 4) {
      ArrayResize(output, len / 4);
    }
    for (i = 0, j = 0; j < len; i++, j += 4) {
      output[i] = (StringGetCharacter(in, j)) | ((StringGetCharacter(in, j + 1)) << 8) |
                  ((StringGetCharacter(in, j + 2)) << 16) | ((StringGetCharacter(in, j + 3)) << 24);
    }
    return (len / 4);
  }

  static void StringToType(string _value, bool& _out) {
#ifdef __MQL__
    _out = _value != "" && _value != NULL && _value != "0" && _value != "false";
#else
    _out = _value != "" && _value != "0" && _value != "false";
#endif
  }

  static void StringToType(string _value, int& _out) { _out = (int)StringToInteger(_value); }
  static void StringToType(string _value, unsigned int& _out) { _out = (unsigned int)StringToInteger(_value); }
  static void StringToType(string _value, char& _out) { _out = (char)_value[0]; }
  static void StringToType(string _value, unsigned char& _out) { _out = (unsigned char)_value[0]; }
  static void StringToType(string _value, long& _out) { _out = StringToInteger(_value); }
  static void StringToType(string _value, unsigned long& _out) { _out = StringToInteger(_value); }
  static void StringToType(string _value, short& _out) { _out = (short)StringToInteger(_value); }
  static void StringToType(string _value, unsigned short& _out) { _out = (unsigned short)StringToInteger(_value); }
  static void StringToType(string _value, float& _out) { _out = (float)StringToDouble(_value); }
  static void StringToType(string _value, double& _out) { _out = StringToDouble(_value); }
  static void StringToType(string _value, string& _out) { _out = _value; }
  static void StringToType(string _value, color& _out) { _out = 0; }
  static void StringToType(string _value, datetime& _out) {
#ifdef __MQL4__
    _out = StrToTime(_value);
#else
    _out = StringToTime(_value);
#endif
  }

  template <typename X>
  static X StringTo(string _value) {
    X _out;
    StringToType(_value, _out);
    return _out;
  }

  static void BoolToType(bool _value, bool& _out) { _out = _value; }
  static void BoolToType(bool _value, char& _out) { _out = (char)_value; }
  static void BoolToType(bool _value, unsigned char& _out) { _out = (unsigned char)_value; }
  static void BoolToType(bool _value, int& _out) { _out = (int)_value; }
  static void BoolToType(bool _value, unsigned int& _out) { _out = (unsigned int)_value; }
  static void BoolToType(bool _value, long& _out) { _out = (long)_value; }
  static void BoolToType(bool _value, unsigned long& _out) { _out = (unsigned long)_value; }
  static void BoolToType(bool _value, short& _out) { _out = (short)_value; }
  static void BoolToType(bool _value, unsigned short& _out) { _out = (unsigned short)_value; }
  static void BoolToType(bool _value, float& _out) { _out = (float)_value; }
  static void BoolToType(bool _value, double& _out) { _out = (double)_value; }
  static void BoolToType(bool _value, string& _out) { _out = _value ? "1" : "0"; }
  static void BoolToType(bool _value, color& _out) { _out = 0; }
  static void BoolToType(bool _value, datetime& _out) {}

  template <typename X>
  static X BoolTo(bool _value) {
    X _out;
    BoolToType(_value, _out);
    return _out;
  }

  static void LongToType(long _value, bool& _out) { _out = (bool)_value; }
  static void LongToType(long _value, char& _out) { _out = (char)_value; }
  static void LongToType(long _value, unsigned char& _out) { _out = (unsigned char)_value; }
  static void LongToType(long _value, int& _out) { _out = (int)_value; }
  static void LongToType(long _value, unsigned int& _out) { _out = (unsigned int)_value; }
  static void LongToType(long _value, long& _out) { _out = (long)_value; }
  static void LongToType(long _value, unsigned long& _out) { _out = (unsigned long)_value; }
  static void LongToType(long _value, short& _out) { _out = (short)_value; }
  static void LongToType(long _value, unsigned short& _out) { _out = (unsigned short)_value; }
  static void LongToType(long _value, float& _out) { _out = (float)_value; }
  static void LongToType(long _value, double& _out) { _out = (double)_value; }
  static void LongToType(long _value, string& _out) { _out = _value ? "1" : "0"; }
  static void LongToType(long _value, color& _out) { _out = 0; }
  static void LongToType(long _value, datetime& _out) {}

  template <typename X>
  static X LongTo(long _value) {
    X _out;
    LongToType(_value, _out);
    return _out;
  }

  static void DoubleToType(double _value, bool& _out) { _out = (bool)_value; }
  static void DoubleToType(double _value, char& _out) { _out = (char)_value; }
  static void DoubleToType(double _value, unsigned char& _out) { _out = (unsigned char)_value; }
  static void DoubleToType(double _value, int& _out) { _out = (int)_value; }
  static void DoubleToType(double _value, unsigned int& _out) { _out = (unsigned int)_value; }
  static void DoubleToType(double _value, long& _out) { _out = (long)_value; }
  static void DoubleToType(double _value, unsigned long& _out) { _out = (unsigned long)_value; }
  static void DoubleToType(double _value, short& _out) { _out = (short)_value; }
  static void DoubleToType(double _value, unsigned short& _out) { _out = (unsigned short)_value; }
  static void DoubleToType(double _value, float& _out) { _out = (float)_value; }
  static void DoubleToType(double _value, double& _out) { _out = (double)_value; }
  static void DoubleToType(double _value, string& _out) { _out = _value ? "1" : "0"; }
  static void DoubleToType(double _value, color& _out) { _out = 0; }
  static void DoubleToType(double _value, datetime& _out) {}

  template <typename X>
  static X DoubleTo(double _value) {
    X _out;
    DoubleToType(_value, _out);
    return _out;
  }
};

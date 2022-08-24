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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Data.struct.h"
#include "Indicator/Indicator.struct.h"
#include "Math.define.h"
#include "Math.enum.h"
#include "Math.extern.h"
#include "Math.struct.h"

/**
 * Class to provide math related methods.
 */
class Math {
 protected:
 public:
  Math() {}

  /* Calculation */

  template <typename X>
  static X ReLU(X _value) {
    return (X)fmax(0, _value);
  }

  /**
   * Returns value changed by the given percentage.
   *
   * @param double _value
   *   Base value to change.
   * @param float _pct
   *   Percentage to change (1 is 100%).
   *
   * @return
   *   Returns value after the change.
   */
  static double ChangeByPct(double _v, float _pct) { return _v != 0 ? _v + (fabs(_v) * _pct) : 0; }

  /**
   * Calculates change between 2 values in percentage.
   *
   * @docs: https://stackoverflow.com/a/65511594/55075
   *
   * @param double _v1
   *   First value.
   * @param double _v2
   *   Second value.
   * @param bool _hundreds
   *   When true, 100% is 100, otherwise 1.
   * @return
   *   Returns percentage change.
   */
  static double ChangeInPct(double _v1, double _v2, bool _hundreds = false) {
    double _result = 0;
    if (_v1 != 0 && _v2 != 0) {
      // If values are non-zero, use the standard formula.
      _result = (_v2 / _v1) - 1;
    } else if (_v1 == 0 || _v2 == 0) {
      // Change is zero when both values are zeros, otherwise it's 1 (100%).
      _result = _v1 == 0 && _v2 == 0 ? 0 : 1;
    }
    _result = _v2 > _v1 ? fabs(_result) : -fabs(_result);
    return _hundreds ? _result * 100 : _result;
  }

  /**
   * Checks condition for 2 values based on the given comparison operator.
   */
  template <typename T1, typename T2>
  static bool Compare(T1 _v1, T2 _v2, ENUM_MATH_CONDITION _op = MATH_COND_EQ) {
    switch (_op) {
      case MATH_COND_EQ:
        return _v1 == _v2;
      case MATH_COND_GT:
        return _v1 > _v2;
      case MATH_COND_LE:
        return _v1 < _v2;
      default:
        break;
    }
    return false;
  }

  /**
   * Gets number of digits after decimal in a floating point number.
   */
  template <typename V>
  static short FloatDigits(V _value) {
    short _cnt = 0;
    while ((int)_value != _value) {
      _value *= 10;
      _cnt++;
    }
    return _cnt;
  }

  /**
   * Returns a non-zero value.
   *
   * @return
   *   Returns a non-zero value.
   */
  static double NonZero(double _v) { return _v == 0 ? DBL_MIN : _v; }

  /* Conditions */

  /**
   * Checks for math condition.
   *
   * @param ENUM_MATH_CONDITION _cond
   *   Math condition.
   * @param MqlParam[] _args
   *   Condition arguments.
   * @return
   *   Returns true when the condition is met.
   */
  /*
    bool CheckCondition(ENUM_MATH_CONDITION _cond, DataParamEntry &_args[]) {
      switch (_cond) {
        case MATH_COND_EQ:
          // @todo
          return false;
        case MATH_COND_GT:
          // @todo
          return false;
        case MATH_COND_LE:
          // @todo
          return false;
        default:
          // logger.Error(StringFormat("Invalid math condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
          return false;
      }
    }
    bool CheckCondition(ENUM_MATH_CONDITION _cond) {
      DataParamEntry _args[] = {};
      return Math::CheckCondition(_cond, _args);
    }
  */

  template <typename T>
  static T Add(T a, T b) {
    return a + b;
  }
  template <typename T>
  static T Sub(T a, T b) {
    return a - b;
  }
  template <typename T>
  static T Mul(T a, T b) {
    return a * b;
  }
  template <typename T>
  static T Div(T a, T b) {
    return a / b;
  }
  template <typename T>
  static T Sin(T a) {
    return sin(a);
  }
  template <typename T>
  static T Cos(T a) {
    return cos(a);
  }
  template <typename T>
  static T Tang(T a) {
    return tan(a);
  }
  template <typename T>
  static T Min(T a, T b) {
    return MathMin(a, b);
  }
  template <typename T>
  static T Min(T a, T b, T c) {
    return MathMin(MathMin(a, b), c);
  }
  template <typename T>
  static T Min(T a, T b, T c, T d) {
    return MathMin(MathMin(MathMin(a, b), c), d);
  }
  template <typename T>
  static T Max(T a, T b) {
    return MathMax(a, b);
  }
  template <typename T>
  static T Max(T a, T b, T c) {
    return MathMax(MathMax(a, b), c);
  }
  template <typename T>
  static T Max(T a, T b, T c, T d) {
    return MathMax(MathMax(MathMax(a, b), c), d);
  }
  template <typename T>
  static T Avg(T a, T b) {
    return (a + b) / 2;
  }
  template <typename T>
  static T Avg(T a, T b, T c) {
    return (a + b + c) / 3;
  }
  template <typename T>
  static T Avg(T a, T b, T c, T d) {
    return (a + b + c + d) / 4;
  }
  template <typename T>
  static T Abs(T a) {
    return MathAbs(a);
  }

  template <typename T>
  static T Op(ENUM_MATH_OP _op, T _val_1, T _val_2 = 0) {
    switch (_op) {
      case MATH_OP_ADD:
        return Add(_val_1, _val_2);
      case MATH_OP_SUB:
        return Sub(_val_1, _val_2);
      case MATH_OP_MUL:
        return Mul(_val_1, _val_2);
      case MATH_OP_DIV:
        return Div(_val_1, _val_2);
      case MATH_OP_SIN:
        return Sin(_val_1);
      case MATH_OP_COS:
        return Cos(_val_2);
      case MATH_OP_TAN:
        return Tang(_val_2);
      case MATH_OP_MIN:
        return Min(_val_1, _val_2);
      case MATH_OP_MAX:
        return Max(_val_1, _val_2);
      case MATH_OP_AVG:
        return Avg(_val_1, _val_2);
      case MATH_OP_RELU:
        return ReLU(_val_1);
      case MATH_OP_ABS:
        return Abs(_val_1);
      case MATH_OP_ABS_DIFF:
        return Abs(_val_1 - _val_2);
      default:
        return EMPTY_VALUE;
    }
  }
};

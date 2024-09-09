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
#include "../Indicator/Indicator.struct.h"
#include "../Storage/Data.struct.h"
#include "Math.define.h"
#include "Math.enum.h"
#include "Math.extern.h"
#include "Math.normal.h"
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

  static double RandomNonZero(void) {
    double rnd = 0;

    while (rnd == 0.0 || rnd == 1.0) {
      rnd = MathRand() / 32767.0;
    }

    return rnd;
  }

  static double TailLogProbability(const double probability, const bool tail, const bool log_mode) {
    if (tail == true) {
      if (log_mode)
        return MathExp(probability);
      else
        return (probability);
    } else {
      if (log_mode)
        return (1.0 - MathExp(probability));
      else
        return (1.0 - probability);
    }
  }

  static double QuantileNormal(const double probability, const double mu, const double sigma, const bool tail,
                               const bool log_mode, int &error_code) {
    // Check NaN.
    if (!MathIsValidNumber(probability) || !MathIsValidNumber(mu) || !MathIsValidNumber(sigma)) {
      error_code = MATH_ERR_ARGUMENTS_NAN;
      return NaN;
    }
    //--- check sigma
    if (sigma <= 0) {
      error_code = MATH_ERR_ARGUMENTS_INVALID;
      return NaN;
    }

    // Calculate real probability.
    double prob = TailLogProbability(probability, tail, log_mode);

    // Check probability range.
    if (prob < 0.0 || prob > 1.0) {
      error_code = MATH_ERR_ARGUMENTS_INVALID;
      return NaN;
    }

    // f(0)=-infinity
    if (prob == 0.0) {
      error_code = MATH_ERR_RESULT_INFINITE;
      return NEGINF;
    }
    // f(1)=+infinity
    if (prob == 1.0) {
      error_code = MATH_ERR_RESULT_INFINITE;
      return POSINF;
    }

    error_code = MATH_ERR_OK;

    double q = prob - 0.5;
    double r = 0;
    double ppnd16 = 0.0;

    if (MathAbs(q) <= 0.425) {
      r = 0.180625 - q * q;
      ppnd16 = q *
               (((((((normal_q_a7 * r + normal_q_a6) * r + normal_q_a5) * r + normal_q_a4) * r + normal_q_a3) * r +
                  normal_q_a2) *
                     r +
                 normal_q_a1) *
                    r +
                normal_q_a0) /
               (((((((normal_q_b7 * r + normal_q_b6) * r + normal_q_b5) * r + normal_q_b4) * r + normal_q_b3) * r +
                  normal_q_b2) *
                     r +
                 normal_q_b1) *
                    r +
                1.0);

      error_code = MATH_ERR_OK;

      return mu + sigma * ppnd16;
    } else {
      if (q < 0.0)
        r = prob;
      else
        r = 1.0 - prob;

      r = MathSqrt(-MathLog(r));

      if (r <= 5.0) {
        r = r - 1.6;
        ppnd16 = (((((((normal_q_c7 * r + normal_q_c6) * r + normal_q_c5) * r + normal_q_c4) * r + normal_q_c3) * r +
                    normal_q_c2) *
                       r +
                   normal_q_c1) *
                      r +
                  normal_q_c0) /
                 (((((((normal_q_d7 * r + normal_q_d6) * r + normal_q_d5) * r + normal_q_d4) * r + normal_q_d3) * r +
                    normal_q_d2) *
                       r +
                   normal_q_d1) *
                      r +
                  1.0);
      } else {
        r = r - 5.0;
        ppnd16 = (((((((normal_q_e7 * r + normal_q_e6) * r + normal_q_e5) * r + normal_q_e4) * r + normal_q_e3) * r +
                    normal_q_e2) *
                       r +
                   normal_q_e1) *
                      r +
                  normal_q_e0) /
                 (((((((normal_q_f7 * r + normal_q_f6) * r + normal_q_f5) * r + normal_q_f4) * r + normal_q_f3) * r +
                    normal_q_f2) *
                       r +
                   normal_q_f1) *
                      r +
                  1.0);
      }

      if (q < 0.0) ppnd16 = -ppnd16;
    }
    // Return rescaled/shifted value.
    return mu + sigma * ppnd16;
  }

  static bool QuantileNormal(CONST_ARRAY_REF(double, probability), const double mu, const double sigma, const bool tail,
                             const bool log_mode, ARRAY_REF(double, result)) {
    //--- check NaN
    if (!MathIsValidNumber(mu) || !MathIsValidNumber(sigma)) return false;
    //--- check sigma
    if (sigma < 0) return false;

    int data_count = ArraySize(probability);
    if (data_count == 0) return false;

    int error_code = 0, i;
    ArrayResize(result, data_count);

    //--- case sigma==0
    if (sigma == 0.0) {
      for (i = 0; i < data_count; i++) result[i] = mu;
      return true;
    }

    for (i = 0; i < data_count; i++) {
      //--- calculate real probability
      double prob = TailLogProbability(probability[i], tail, log_mode);
      //--- check probability range
      if (prob < 0.0 || prob > 1.0) return false;

      //--- f(0)=-infinity, f(1)=+infinity
      if (prob == 0.0 || prob == 1.0) {
        if (prob == 0.0)
          result[i] = NEGINF;
        else
          result[i] = POSINF;
      } else {
        double q = prob - 0.5;
        double r = 0;
        double ppnd16 = 0.0;
        //---
        if (MathAbs(q) <= 0.425) {
          r = 0.180625 - q * q;
          ppnd16 = q *
                   (((((((normal_q_a7 * r + normal_q_a6) * r + normal_q_a5) * r + normal_q_a4) * r + normal_q_a3) * r +
                      normal_q_a2) *
                         r +
                     normal_q_a1) *
                        r +
                    normal_q_a0) /
                   (((((((normal_q_b7 * r + normal_q_b6) * r + normal_q_b5) * r + normal_q_b4) * r + normal_q_b3) * r +
                      normal_q_b2) *
                         r +
                     normal_q_b1) *
                        r +
                    1.0);
          //--- set rescaled/shifted value
          result[i] = mu + sigma * ppnd16;
        } else {
          if (q < 0.0)
            r = prob;
          else
            r = 1.0 - prob;
          //---
          r = MathSqrt(-MathLog(r));
          //---
          if (r <= 5.0) {
            r = r - 1.6;
            ppnd16 =
                (((((((normal_q_c7 * r + normal_q_c6) * r + normal_q_c5) * r + normal_q_c4) * r + normal_q_c3) * r +
                   normal_q_c2) *
                      r +
                  normal_q_c1) *
                     r +
                 normal_q_c0) /
                (((((((normal_q_d7 * r + normal_q_d6) * r + normal_q_d5) * r + normal_q_d4) * r + normal_q_d3) * r +
                   normal_q_d2) *
                      r +
                  normal_q_d1) *
                     r +
                 1.0);
          } else {
            r = r - 5.0;
            ppnd16 =
                (((((((normal_q_e7 * r + normal_q_e6) * r + normal_q_e5) * r + normal_q_e4) * r + normal_q_e3) * r +
                   normal_q_e2) *
                      r +
                  normal_q_e1) *
                     r +
                 normal_q_e0) /
                (((((((normal_q_f7 * r + normal_q_f6) * r + normal_q_f5) * r + normal_q_f4) * r + normal_q_f3) * r +
                   normal_q_f2) *
                      r +
                  normal_q_f1) *
                     r +
                 1.0);
          }
          //---
          if (q < 0.0) ppnd16 = -ppnd16;
        }
        //--- set rescaled/shifted value
        result[i] = mu + sigma * ppnd16;
      }
    }
    return true;
  }

  static bool QuantileNormal(CONST_ARRAY_REF(double, probability), const double mu, const double sigma,
                             ARRAY_REF(double, result)) {
    return QuantileNormal(probability, mu, sigma, true, false, result);
  }

  static double RandomNormal(const double mu, const double sigma, int &error_code) {
    if (!MathIsValidNumber(mu) || !MathIsValidNumber(sigma)) {
      error_code = MATH_ERR_ARGUMENTS_NAN;
      return NaN;
    }

    if (sigma < 0) {
      error_code = MATH_ERR_ARGUMENTS_INVALID;
      return NaN;
    }

    error_code = MATH_ERR_OK;

    if (sigma == 0.0) return mu;

    double rnd = RandomNonZero();

    return QuantileNormal(rnd, mu, sigma, true, false, error_code);
  }

  static bool RandomNormal(const double mu, const double sigma, const int data_count, ARRAY_REF(double, result)) {
    int i;

    // Check NaN.
    if (!MathIsValidNumber(mu) || !MathIsValidNumber(sigma)) {
      return false;
    }

    // Check sigma.
    if (sigma < 0) {
      return false;
    }

    // Prepare output array and calculate random values.
    ArrayResize(result, data_count);

    if (sigma == 0.0) {
      for (i = 0; i < data_count; i++) result[i] = mu;
      return true;
    }

    int err_code = 0;

    for (i = 0; i < data_count; i++) {
      result[i] = RandomNonZero();
    }

    // Return normal random array using quantile.
    return QuantileNormal(result, mu, sigma, result);
  }

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

#ifdef __MQL__

/**
 * Specialization of MQL's Round() to support int64 input.
 */
int64 MathRound(int64 _value) { return _value; }

/**
 * Specialization of MQL's round() to support int64 input.
 */
int64 round(int64 _value) { return MathRound(_value); }

#endif

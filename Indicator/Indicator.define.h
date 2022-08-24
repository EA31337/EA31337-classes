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
 * Includes Indicator's defines.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Defines macros.
#define COMMA ,
#define DUMMY

#define ICUSTOM_DEF(SET_HANDLE, PARAMS)                                        \
  double _res[];                                                               \
  if (_handle == NULL || _handle == INVALID_HANDLE) {                          \
    if ((_handle = ::iCustom(_symbol, _tf, _name PARAMS)) == INVALID_HANDLE) { \
      SetUserError(ERR_USER_INVALID_HANDLE);                                   \
      return EMPTY_VALUE;                                                      \
    }                                                                          \
    SET_HANDLE;                                                                \
  }                                                                            \
  if (Terminal::IsVisualMode()) {                                              \
    int _bars_calc = ::BarsCalculated(_handle);                                \
    if (GetLastError() > 0) {                                                  \
      return EMPTY_VALUE;                                                      \
    } else if (_bars_calc <= 2) {                                              \
      SetUserError(ERR_USER_INVALID_BUFF_NUM);                                 \
      return EMPTY_VALUE;                                                      \
    }                                                                          \
  }                                                                            \
  if (::CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {                     \
    return ArraySize(_res) > 0 ? _res[0] : EMPTY_VALUE;                        \
  }                                                                            \
  return _res[0];

// Defines bitwise method macro.
#define METHOD(method, no) ((method & (1 << no)) == 1 << no)

#ifndef __MQL4__
// Defines macros (for MQL4 backward compatibility).
#define IndicatorDigits(_digits) IndicatorSetInteger(INDICATOR_DIGITS, _digits)
#define IndicatorShortName(name) IndicatorSetString(INDICATOR_SHORTNAME, name)
#endif

/* Common indicator line identifiers */

// @see: https://docs.mql4.com/constants/indicatorconstants/lines
// @see: https://www.mql5.com/en/docs/constants/indicatorconstants/lines

#ifndef __MQL__
// Indicator constants.
// @docs
// - https://www.mql5.com/en/docs/constants/indicatorconstants/lines
// Identifiers of indicator lines permissible when copying values of iMACD(), iRVI() and iStochastic().
#define MAIN_LINE 0    // Main line.
#define SIGNAL_LINE 1  // Signal line.
// Identifiers of indicator lines permissible when copying values of ADX() and ADXW().
#define MAIN_LINE 0     // Main line.
#define PLUSDI_LINE 1   // Line +DI.
#define MINUSDI_LINE 2  // Line -DI.
// Identifiers of indicator lines permissible when copying values of iBands().
#define BASE_LINE 0   // Main line.
#define UPPER_BAND 1  // Upper limit.
#define LOWER_BAND 2  // Lower limit.
// Identifiers of indicator lines permissible when copying values of iEnvelopes() and iFractals().
#define UPPER_LINE 0  // Upper line.
#define LOWER_LINE 1  // Bottom line.
#endif

#ifndef __MQL__
//
// Empty value in an indicator buffer.
// @docs
// - https://docs.mql4.com/constants/namedconstants/otherconstants
// - https://www.mql5.com/en/docs/constants/namedconstants/otherconstants
#define EMPTY_VALUE DBL_MAX
#endif

#define INDICATOR_BUILTIN_CALL_AND_RETURN(NATIVE_METHOD_CALL, MODE, SHIFT)                                 \
  int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL; \
  double _res[];                                                                                           \
  ResetLastError();                                                                                        \
  if (_handle == NULL || _handle == INVALID_HANDLE) {                                                      \
    if ((_handle = NATIVE_METHOD_CALL) == INVALID_HANDLE) {                                                \
      SetUserError(ERR_USER_INVALID_HANDLE);                                                               \
      return EMPTY_VALUE;                                                                                  \
    } else if (Object::IsValid(_obj)) {                                                                    \
      _obj.SetHandle(_handle);                                                                             \
    }                                                                                                      \
  }                                                                                                        \
  if (Terminal::IsVisualMode()) {                                                                          \
    /* To avoid error 4806 (ERR_INDICATOR_DATA_NOT_FOUND), */                                              \
    /* we check the number of calculated data only in visual mode. */                                      \
    int _bars_calc = BarsCalculated(_handle);                                                              \
    if (GetLastError() > 0) {                                                                              \
      return EMPTY_VALUE;                                                                                  \
    } else if (_bars_calc <= 2) {                                                                          \
      SetUserError(ERR_USER_INVALID_BUFF_NUM);                                                             \
      return EMPTY_VALUE;                                                                                  \
    }                                                                                                      \
  }                                                                                                        \
  if (CopyBuffer(_handle, MODE, SHIFT, 1, _res) < 0) {                                                     \
    return ArraySize(_res) > 0 ? _res[0] : EMPTY_VALUE;                                                    \
  }                                                                                                        \
  return _res[0];

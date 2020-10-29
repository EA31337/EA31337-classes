//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
 * Includes Indicator's enums.
 */

// Indicator line identifiers used in Envelopes and Fractals indicators.
enum ENUM_LO_UP_LINE {
#ifdef __MQL4__
  LINE_UPPER = MODE_UPPER,  // Upper line.
  LINE_LOWER = MODE_LOWER,  // Bottom line.
#else
  LINE_UPPER = UPPER_LINE,  // Upper line.
  LINE_LOWER = LOWER_LINE,  // Bottom line.
#endif
  FINAL_LO_UP_LINE_ENTRY,
};

// Indicator line identifiers used in MACD, RVI and Stochastic indicators.
enum ENUM_SIGNAL_LINE {
#ifdef __MQL4__
  // @see: https://docs.mql4.com/constants/indicatorconstants/lines
  LINE_MAIN = MODE_MAIN,      // Main line.
  LINE_SIGNAL = MODE_SIGNAL,  // Signal line.
#else
  // @see: https://www.mql5.com/en/docs/constants/indicatorconstants/lines
  LINE_MAIN = MAIN_LINE,      // Main line.
  LINE_SIGNAL = SIGNAL_LINE,  // Signal line.
#endif
  FINAL_SIGNAL_LINE_ENTRY,
};

#ifdef __MQL4__
// The volume type is used in calculations.
// For MT4, we define it for backward compatibility.
// @docs: https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
enum ENUM_APPLIED_VOLUME { VOLUME_TICK = 0, VOLUME_REAL = 1 };
#endif

// Indicator entry flags.
enum INDICATOR_ENTRY_FLAGS {
  INDI_ENTRY_FLAG_NONE = 0,
  INDI_ENTRY_FLAG_IS_VALID = 1,
  INDI_ENTRY_FLAG_RESERVED1 = 2,
  INDI_ENTRY_FLAG_RESERVED2 = 4,
  INDI_ENTRY_FLAG_RESERVED3 = 8
};

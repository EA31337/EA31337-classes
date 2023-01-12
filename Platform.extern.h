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

template <typename... Args>
double iCustom(string symbol, int timeframe, string name, Args... args) {
  Alert(__FUNCSIG__, " it not implemented!");
  return 0;
}

/**
 * Returns number of candles for a given symbol and time-frame.
 */
extern int Bars(CONST_REF_TO(string) _symbol, ENUM_TIMEFRAMES _tf);

/**
 * Returns the number of calculated data for the specified indicator.
 */
extern int BarsCalculated(int indicator_handle);

/**
 * Gets data of a specified buffer of a certain indicator in the necessary quantity.
 */
extern int CopyBuffer(int indicator_handle, int buffer_num, int start_pos, int count, ARRAY_REF(double, buffer));

#endif

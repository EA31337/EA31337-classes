//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

// Define external global functions.
#ifndef __MQL__
template <typename T>
extern T MathAbs(T value);
template <typename T>
extern T fabs(T value);
template <typename T>
extern T pow(T base, T exponent);
template <typename T>
extern T MathPow(T base, T exponent);
template <typename T>
extern T round(T value);
template <typename T>
extern T MathRound(T value);
template <typename T>
extern T fmax(T value1, T value2);
template <typename T>
extern T MathMax(T value1, T value2);
template <typename T>
extern T fmin(T value1, T value2);
template <typename T>
extern T MathMin(T value1, T value2);
template <typename T>
extern T MathLog10(T value1);
template <typename T>
extern T log10(T value);
#endif

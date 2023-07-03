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

// Define external global functions.
#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once

#include <algorithm>
#include <cmath>

template <typename T>
T MathAbs(T value) {
  return std::abs(value);
}
template <typename T>
T fabs(T value) {
  return std::abs(value);
}
template <typename T>
T pow(T base, T exponent) {
  return (T)std::pow(base, exponent);
}
template <typename T>
T MathPow(T base, T exponent) {
  return std::pow(base, exponent);
}
template <typename T>
T MathLog(T value) {
  return std::log(value);
}
template <typename T>
T MathExp(T value) {
  return std::exp(value);
}
template <typename T>
T MathSqrt(T value) {
  return std::sqrt(value);
}
template <typename T>
T round(T value) {
  return std::round(value);
}
template <typename T>
T MathRound(T value) {
  return std::round(value);
}
template <typename T>
T fmax(T value1, T value2) {
  return std::max(value1, value2);
}
template <typename T>
T MathMax(T value1, T value2) {
  return std::max(value1, value2);
}
template <typename T>
T fmin(T value1, T value2) {
  return std::min(value1, value2);
}
template <typename T>
T MathMin(T value1, T value2) {
  return std::min(value1, value2);
}
template <typename T>
T MathLog10(T value) {
  return std::log10(value);
}
template <typename T>
T log10(T value) {
  return std::log10(value);
}
int MathRand() { return std::rand() % 32768; }
// int rand() { return std::rand() % 32768; }
#endif

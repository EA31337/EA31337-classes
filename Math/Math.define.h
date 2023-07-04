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

// Defines macros.
#define fmax2(_v1, _v2) fmax(_v1, _v2)
#define fmax3(_v1, _v2, _v3) fmax(fmax(_v1, _v2), _v3)
#define fmax4(_v1, _v2, _v3, _v4) fmax(fmax(fmax(_v1, _v2), _v3), _v4)
#define fmax5(_v1, _v2, _v3, _v4, _v5) fmax(fmax(fmax(fmax(_v1, _v2), _v3), _v4), _v5)
#define fmax6(_v1, _v2, _v3, _v4, _v5, _v6) fmax(fmax(fmax(fmax(fmax(_v1, _v2), _v3), _v4), _v5), _v6)
#define fmin2(_v1, _v2) fmin(_v1, _v2)
#define fmin3(_v1, _v2, _v3) fmin(fmin(_v1, _v2), _v3)
#define fmin4(_v1, _v2, _v3, _v4) fmin(fmin(fmin(_v1, _v2), _v3), _v4)
#define fmin5(_v1, _v2, _v3, _v4, _v5) fmin(fmin(fmin(fmin(_v1, _v2), _v3), _v4), _v5)
#define fmin6(_v1, _v2, _v3, _v4, _v5, _v6) fmin(fmin(fmin(fmin(fmin(_v1, _v2), _v3), _v4), _v5), _v6)

#ifdef __cplusplus
#include <limits>

#ifndef CHAR_MIN
#define CHAR_MIN std::numeric_limits<char>::min()
#endif

#ifndef CHAR_MAX
#define CHAR_MAX std::numeric_limits<char>::max()
#endif

#ifndef UCHAR_MAX
#define UCHAR_MAX std::numeric_limits<unsigned char>::max()
#endif

#ifndef SHORT_MAX
#define SHORT_MAX std::numeric_limits<short>::max()
#endif

#ifndef SHORT_MIN
#define SHORT_MIN std::numeric_limits<short>::min()
#endif

#ifndef USHORT_MAX
#define USHORT_MAX std::numeric_limits<unsigned short>::max()
#endif

#ifndef INT_MIN
#define INT_MIN std::numeric_limits<int>::min()
#endif

#ifndef INT_MAX
#define INT_MAX std::numeric_limits<int>::max()
#endif

#ifndef UINT_MAX
#define UINT_MAX std::numeric_limits<unsigned int>::max()
#endif

#ifndef LONG_MIN
#define LONG_MIN std::numeric_limits<int64>::min()
#endif

#ifndef LONG_MAX
#define LONG_MAX std::numeric_limits<int64>::max()
#endif

#ifndef ULONG_MAX
#define ULONG_MAX std::numeric_limits<short>::max()
#endif

#ifndef FLT_MIN
#define FLT_MIN std::numeric_limits<float>::min()
#endif

#ifndef FLT_MAX
#define FLT_MAX std::numeric_limits<float>::max()
#endif

#ifndef DBL_MIN
#define DBL_MIN std::numeric_limits<double>::min()
#endif

#ifndef DBL_MAX
#define DBL_MAX std::numeric_limits<double>::max()
#endif

#endif

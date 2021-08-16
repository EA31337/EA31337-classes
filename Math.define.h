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

//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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
#pragma once

template <typename T>
extern int ArraySize(const ARRAY_REF(T, _array));

template <typename T, int size>
extern constexpr int ArraySize(const T REF(_array)[size]);

template <typename T>
extern int ArrayResize(ARRAY_REF(T, _array), int _new_size, int _reserve_size = 0);

template <typename T>
extern bool ArraySetAsSeries(ARRAY_REF(T, _array), bool _flag);

template <typename T>
extern int ArrayMaximum(const ARRAY_REF(T, _array), int _start = 0, unsigned int _count = WHOLE_ARRAY);

template <typename T>
extern int ArrayMinimum(const ARRAY_REF(T, _array), int _start = 0, unsigned int _count = WHOLE_ARRAY);

template <typename T>
extern int ArrayFree(const ARRAY_REF(T, _array));

#endif

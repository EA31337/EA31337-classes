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

/**
 * @file
 * Includes external declarations related to objects.
 */
#ifndef __MQL__

// Allows the preprocessor to include a header file when it is needed.
#pragma once

// Includes.
#include "Object.enum.h"

template <typename X>
X* GetPointer(X& value) {
  return &value;
}
template <typename X>
X* GetPointer(X* ptr) {
  return ptr;
}

template <typename X>
ENUM_POINTER_TYPE CheckPointer(X& value) {
  return (&value) != nullptr ? POINTER_DYNAMIC : POINTER_INVALID;
}
template <typename X>
ENUM_POINTER_TYPE CheckPointer(X* ptr) {
  return ptr != nullptr ? POINTER_DYNAMIC : POINTER_INVALID;
}

enum ENUM_OBJECT {
  OBJ_VLINE = 0,               // Vertical Line
  OBJ_HLINE = 1,               // Horizontal Line
  OBJ_TREND = 2,               // Trend Line
  OBJ_TRENDBYANGLE = 3,        // Trend Line By Angle
  OBJ_CYCLES = 4,              // Cycle Lines
  OBJ_ARROWED_LINE = 108,      // Arrowed Line
  OBJ_CHANNEL = 5,             // Equidistant Channel
  OBJ_STDDEVCHANNEL = 6,       // Standard Deviation Channel
  OBJ_REGRESSION = 7,          // Linear Regression Channel
  OBJ_PITCHFORK = 8,           // Andrews Pitchfork
  OBJ_GANNLINE = 9,            // Gann Line
  OBJ_GANNFAN = 10,            // Gann Fan
  OBJ_GANNGRID = 11,           // Gann Grid
  OBJ_FIBO = 12,               // Fibonacci Retracement
  OBJ_FIBOTIMES = 13,          // Fibonacci Time Zones
  OBJ_FIBOFAN = 14,            // Fibonacci Fan
  OBJ_FIBOARC = 15,            // Fibonacci Arcs
  OBJ_FIBOCHANNEL = 16,        // Fibonacci Channel
  OBJ_EXPANSION = 17,          // Fibonacci Expansion
  OBJ_ELLIOTWAVE5 = 18,        // Elliott Motive Wave
  OBJ_ELLIOTWAVE3 = 19,        // Elliott Correction Wave
  OBJ_RECTANGLE = 20,          // Rectangle
  OBJ_TRIANGLE = 21,           // Triangle
  OBJ_ELLIPSE = 22,            // Ellipse
  OBJ_ARROW_THUMB_UP = 23,     // Thumbs Up
  OBJ_ARROW_THUMB_DOWN = 24,   // Thumbs Down
  OBJ_ARROW_UP = 25,           // Arrow Up
  OBJ_ARROW_DOWN = 26,         // Arrow Down
  OBJ_ARROW_STOP = 27,         // Stop Sign
  OBJ_ARROW_CHECK = 28,        // Check Sign
  OBJ_ARROW_LEFT_PRICE = 29,   // Left Price Label
  OBJ_ARROW_RIGHT_PRICE = 30,  // Right Price Label
  OBJ_ARROW_BUY = 31,          // Buy Sign
  OBJ_ARROW_SELL = 32,         // Sell Sign
  OBJ_ARROW = 100,             // Arrow
  OBJ_TEXT = 101,              // Text
  OBJ_LABEL = 102,             // Label
  OBJ_BUTTON = 103,            // Button
  OBJ_CHART = 104,             // Chart
  OBJ_BITMAP = 105,            // Bitmap
  OBJ_BITMAP_LABEL = 106,      // Bitmap Label
  OBJ_EDIT = 107,              // Edit
  OBJ_EVENT = 109,             // The "Event" object corresponding to an event in the economic calendar
  OBJ_RECTANGLE_LABEL = 110  // The "Rectangle label" object for creating and designing the custom graphical interface.
};

#endif

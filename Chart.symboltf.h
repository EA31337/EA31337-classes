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
 * Includes SymbolTf struct.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Std.h"

/**
 * Represents symbol and timeframe. To be used by IndicatorBase and ChartBase classes.
 */
struct SymbolTf {
  const string symbol;
  const ENUM_TIMEFRAMES tf;
  const string symbol_tf_key;

  CONST_REF_TO(string) Key() const { return symbol_tf_key; }
  CONST_REF_TO(string) Symbol() const { return symbol; }
  ENUM_TIMEFRAMES Tf() const { return tf; }

  SymbolTf(string _symbol, ENUM_TIMEFRAMES _tf)
      : symbol(_symbol), tf(_tf), symbol_tf_key(_symbol + "_" + IntegerToString((int)_tf)) {}

  bool operator==(const SymbolTf& _r) const { return symbol_tf_key == _r.symbol_tf_key; }
};

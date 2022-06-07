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

// Includes.

/**
 * Current platform's static methods.
 */

#include "Flags.h"
#include "IndicatorBase.h"
#include "Std.h"

#ifdef __MQLBUILD__
#include "Indicator/tests/classes/IndicatorTfDummy.h"
#include "Indicator/tests/classes/IndicatorTickReal.h"
#define PLATFORM_DEFAULT_INDICATOR_TICK IndicatorTickReal
#else
#error "Platform not supported!
#endif

class Platform {
 public:
  /**
   * Binds Candle and/or Tick indicator as a source of prices or data for given indicator.
   *
   * Note that some indicators may work on custom set of buffers required from data source and not on Candle or Tick
   * indicator.
   */
  static void BindDefaultDataSource(IndicatorBase *_indi, string _symbol, ENUM_TIMEFRAMES _tf) {
    Flags<unsigned int> _suitable_ds_types = _indi PTR_DEREF GetSuitableDataSourceTypes();

    if (_suitable_ds_types.HasFlag(INDI_SUITABLE_DS_TYPE_CUSTOM)) {
      // We can't attach any default data source as we don't know what type of indicator to create.
      Print("ERROR: Cannot bind default data source for ", _indi PTR_DEREF GetFullName(),
            " as we don't know what type of indicator to create!");
      DebugBreak();
    }

    // @fixit @todo We should cache Candle indicator per TF!

    if (_suitable_ds_types.HasFlag(INDI_SUITABLE_DS_TYPE_CANDLE)) {
      _indi PTR_DEREF GetOuterDataSource() PTR_DEREF SetDataSource(new IndicatorTfDummy(_tf));
    }

    if (_suitable_ds_types.HasFlag(INDI_SUITABLE_DS_TYPE_TICK)) {
      _indi PTR_DEREF GetOuterDataSource() PTR_DEREF SetDataSource(new PLATFORM_DEFAULT_INDICATOR_TICK(_symbol));
    }
  }
};
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

// Includes.
#include "../Indicator.mqh"
#include "tests/classes/IndicatorTickReal.h"

/**
 * Indicator to be used with IndicatorTick or IndicatorCandle as a data source.
 *
 * In order it to work with
 */
template <typename TS>
class IndicatorTickOrCandleSource : public Indicator<TS> {
 public:
  /**
   * Class constructor.
   */
  IndicatorTickOrCandleSource(const TS& _iparams, IndicatorBase* _indi_src = NULL, int _indi_mode = 0)
      : Indicator(_iparams, _indi_src, _indi_mode) {}
  IndicatorTickOrCandleSource(const TS& _iparams, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(_iparams, _tf) {}
  IndicatorTickOrCandleSource(ENUM_INDICATOR_TYPE _itype, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                              string _name = "")
      : Indicator(_itype, _tf, _shift, _name) {}

  /**
   * Class deconstructor.
   */
  ~IndicatorTickOrCandleSource() {}

  /**
   * Called when user tries to set given data source. Could be used to check if indicator implements all required value
   * storages.
   */
  bool OnValidateDataSource(IndicatorBase* _ds, string& _reason) override {
    // @todo Make use of this method.
    return true;
  }
};

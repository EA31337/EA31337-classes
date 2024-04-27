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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Indicator.mqh"
#include "tests/classes/IndicatorTfDummy.h"
#include "tests/classes/IndicatorTickReal.h"

/**
 * Indicator to be used with IndicatorCandle as a data source.
 */
template <typename TS>
class IndicatorCandleSource : public Indicator<TS> {
 public:
  /**
   * Class constructor.
   */
  IndicatorCandleSource(const TS& _iparams, IndicatorBase* _indi_src = NULL, int _indi_mode = 0)
      : Indicator(_iparams, _indi_src, _indi_mode) {}
  IndicatorCandleSource(const TS& _iparams, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(_iparams, _tf) {}
  IndicatorCandleSource(ENUM_INDICATOR_TYPE _itype, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                        string _name = "")
      : Indicator(_itype, _tf, _shift, _name) {}

  /**
   * Class deconstructor.
   */
  ~IndicatorCandleSource() {}

  /**
   * Sets indicator data source.
   */
  void SetDataSource(IndicatorBase* _indi, int _input_mode = -1) override {
    if (_indi == NULL) {
      // Just deselecting data source.
      Indicator<TS>::SetDataSource(_indi, _input_mode);
      return;
    }

    // We can only use data sources which supports all possible modes from IndicatorCandle.
    bool _result = true;

    _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_OPEN);
    _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_HIGH);
    _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_LOW);
    _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_CLOSE);
    _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_SPREAD);
    _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_TICK_VOLUME);
    _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_VOLUME);

    if (!_result) {
      Alert("Passed indicator ", _indi.GetFullName(), " does not define all required specific data storages!");
      DebugBreak();
    }

    Indicator<TS>::SetDataSource(_indi, _input_mode);
  }

  /**
   * Called when user tries to set given data source. Could be used to check if indicator implements all required value
   * storages.
   */
  bool OnValidateDataSource(IndicatorBase* _ds, string& _reason) override {
    // @todo Make use of this method.
    return true;
  }

  /**
   * Called if data source is requested, but wasn't yet set. May be used to initialize indicators that must operate on
   * some data source.
   */
  IndicatorBase* OnDataSourceRequest() override {
    // Defaulting to real platform ticks.
    IndicatorBase* _indi_tick =
        new IndicatorTickReal(GetSymbol(), GetTf(), "Ticker for Tf on IndicatorCandleSource-based indicator");

    // Tf will work on real platform ticks.
    IndicatorBase* _indi_tf = new IndicatorTfDummy(GetTf());
    _indi_tf.SetDataSource(_indi_tick);

    // Indicator will work on Tf, which will receive real platform ticks.
    return _indi_tf;
  }
};

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

/**
 * Indicator to be used with IndicatorTick as a data source.
 */
template <typename TS>
class IndicatorTickSource : public Indicator<TS> {
 public:
  /**
   * Class constructor.
   */
  IndicatorTickSource(const TS& _iparams, IndicatorBase* _indi_src = NULL, int _indi_mode = 0)
      : Indicator(_iparams, _indi_src, _indi_mode) {}
  IndicatorTickSource(const TS& _iparams, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(_iparams, _tf) {}
  IndicatorTickSource(ENUM_INDICATOR_TYPE _itype, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                      string _name = "")
      : Indicator(_itype, _tf, _shift, _name) {}

  /**
   * Class deconstructor.
   */
  ~IndicatorCandleSource() {}

  /**
   * Sets indicator data source.
   */
  void SetDataSource(IndicatorBase* _indi, int _input_mode = 0) override {
    if (_indi == NULL) {
      // Just deselecting data source.
      Indicator<TS>::SetDataSource(_indi, _input_mode);
      return;
    }

    // We can only use data sources which supports all possible modes from IndicatorTick.
    bool _result = true;

    _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_APPLIED);

    if (!_result) {
      Alert("Passed indicator ", _indi.GetFullName(), " does not define all required specific data storages!");
      DebugBreak();
    }

    Indicator<TS>::SetDataSource(_indi, _input_mode);
  }

  /**
   * Called if data source is requested, but wasn't yet set. May be used to initialize indicators that must operate on
   * some data source.
   */
  IndicatorBase* OnDataSourceRequest() override {
    // Defaulting to platform ticks.
    return new IndicatorTickReal(GetSymbol(), GetTf(), "AMA on IndicatorTickReal");
  }
};

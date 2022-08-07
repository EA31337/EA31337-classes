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
#include "Indicator.h"

/**
 * Indicator to be used with IndicatorTick as a data source.
 */
template <typename TS>
class IndicatorTickSource : public Indicator<TS> {
 public:
  /**
   * Class constructor.
   */
  IndicatorTickSource(const TS& _iparams, const IndicatorDataParams& _idparams, IndicatorData* _indi_src = NULL,
                      int _indi_mode = 0)
      : Indicator(_iparams, _idparams, _indi_src, _indi_mode) {}
  IndicatorTickSource(const TS& _iparams, const IndicatorDataParams& _idparams, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
      : Indicator(_iparams, _idparams, _tf) {}
  IndicatorTickSource(ENUM_INDICATOR_TYPE _itype, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                      string _name = "")
      : Indicator(_itype, _tf, _shift, _name) {}

  /**
   * Class deconstructor.
   */
  ~IndicatorTickSource() {}

  /**
   * Sets indicator data source.
   */
  void SetDataSource(IndicatorData* _indi, int _input_mode = -1) override {
    if (_indi == NULL) {
      // Just deselecting data source.
      Indicator<TS>::SetDataSource(_indi, _input_mode);
      return;
    }

    // We can only use data sources which supports all possible modes from IndicatorTick.
    bool _result = true;

    if (_input_mode == -1) {
      // Source mode which acts as an applied price wasn't selected, so we have to ensure that source is a Tick
      // indicator. Valid only if implements bid or ask price.
      _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_BID) ||
                 _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_ASK);
    } else {
      // Applied price selected. We will select source indicator only if it provides price buffer for given applied
      // price.
      switch (_input_mode) {
        case PRICE_OPEN:
          _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_OPEN);
          break;
        case PRICE_HIGH:
          _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_HIGH);
          break;
        case PRICE_LOW:
          _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_LOW);
          break;
        case PRICE_CLOSE:
          _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_CLOSE);
          break;
        case PRICE_MEDIAN:
          _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_MEDIAN);
          break;
        case PRICE_TYPICAL:
          _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_TYPICAL);
          break;
        case PRICE_WEIGHTED:
          _result &= _indi.HasSpecificValueStorage(INDI_VS_TYPE_PRICE_WEIGHTED);
          break;
        default:
          Alert("Invalid input mode ", _input_mode, " for indicator ", _indi.GetFullName(),
                ". Must be one one PRICE_(OPEN|HIGH|LOW|CLOSE|MEDIAN|TYPICAL|WEIGHTED)!");
          DebugBreak();
      }
    }

    if (!_result) {
      Alert("Passed indicator ", _indi.GetFullName(),
            " does not provide required data storage(s)! Mode selected: ", _input_mode);
      DebugBreak();
    }

    Indicator<TS>::SetDataSource(_indi, _input_mode);
  }

  /**
   * Called when user tries to set given data source. Could be used to check if indicator implements all required value
   * storages.
   */
  bool OnValidateDataSource(IndicatorData* _ds, string& _reason) override {
    // @todo Make use of this method.
    return true;
  }
};

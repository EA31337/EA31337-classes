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
#include "../Bar.struct.h"
#include "../BufferStruct.mqh"
#include "../Indicator.mqh"
#include "../Pattern.struct.h"
#include "../Serializer.mqh"
#include "Indi_Price.mqh"
#include "Special/Indi_Math.mqh"

// Structs.
struct PatternParams : IndicatorParams {
  // Struct constructor.
  void PatternParams(int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_PATTERN;
    max_modes = 8;
    SetDataValueType(TYPE_INT);
    SetDataValueRange(IDATA_RANGE_RANGE);
    SetDataSourceType(IDATA_BUILTIN);
    shift = _shift;
    tf = _tf;
  };
  void PatternParams(PatternParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements Pattern Detector.
 */
class Indi_Pattern : public Indicator {
 protected:
  PatternParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_Pattern(PatternParams &_params) : params(_params), Indicator((IndicatorParams)_params){};
  Indi_Pattern(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_PATTERN, _tf) { params.tf = _tf; };

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry(params.max_modes);
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);

      ResetLastError();
      BarOHLC _ohlcs[8];
      int i;
      int _value = WRONG_VALUE;

      switch (params.idstype) {
        case IDATA_BUILTIN:
          // In this mode, price is fetched from chart.
          for (i = 0; i < 7; ++i) {
            _ohlcs[i] = Chart::GetOHLC(_shift + i);
          }
          break;
        case IDATA_INDICATOR:
          // In this mode, price is fetched from given indicator. Such indicator
          // must have at least 4 buffers and define OHLC in the first 4 buffers.
          // Indi_Price is an example of such indicator.
          if (GetDataSource() == NULL) {
            Logger().Error(
                "In order use custom indicator as a source, you need to select one using SetIndicatorData() method, "
                "which is a part of PatternParams structure.",
                "Indi_Pattern");
            Alert(
                "Indi_Pattern: In order use custom indicator as a source, you need to select one using "
                "SetIndicatorData() "
                "method, which is a part of PatternParams structure.");
            SetUserError(ERR_INVALID_PARAMETER);
            return _value;
          }

          for (i = 0; i < 7; ++i) {
            _ohlcs[i].open = GetDataSource().GetValue<float>(_shift + i, PRICE_OPEN);
            _ohlcs[i].high = GetDataSource().GetValue<float>(_shift + i, PRICE_HIGH);
            _ohlcs[i].low = GetDataSource().GetValue<float>(_shift + i, PRICE_LOW);
            _ohlcs[i].close = GetDataSource().GetValue<float>(_shift + i, PRICE_CLOSE);
          }
          break;
        default:
          SetUserError(ERR_INVALID_PARAMETER);
      }

      PatternEntry pattern(_ohlcs);

      for (int _mode = 0; _mode < (int)params.max_modes; _mode++) {
        _entry.values[_mode] = pattern[_mode + 1];
      }

      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, true);
      // @fixit After changint type to bitwise, it doesn't serialize integer values into CSV.
      //_entry.SetFlag(INDI_ENTRY_FLAG_IS_BITWISE, true);
      istate.is_ready = true;

      if (_entry.IsValid()) {
        _entry.AddFlags(_entry.GetDataTypeFlag(params.GetDataValueType()));
        idata.Add(_entry, _bar_time);
      }
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_INT};
    _param.integer_value = GetEntry(_shift).GetValue<int>(_mode);
    return _param;
  }
};

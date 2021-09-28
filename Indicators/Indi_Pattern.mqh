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
struct IndiPatternParams : IndicatorParams {
  // Struct constructor.
  void IndiPatternParams(int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_PATTERN;
    max_modes = 5;
    SetDataValueType(TYPE_INT);
    SetDataValueRange(IDATA_RANGE_BITWISE);
    SetDataSourceType(IDATA_BUILTIN);
    shift = _shift;
    tf = _tf;
  };
  void IndiPatternParams(IndiPatternParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements Pattern Detector.
 */
class Indi_Pattern : public Indicator<IndiPatternParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Pattern(IndiPatternParams &_params) : iparams(_params), Indicator<IndiPatternParams>(_params){};
  Indi_Pattern(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_PATTERN, _tf) { iparams.tf = _tf; };

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry(iparams.GetMaxModes());
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);

      ResetLastError();
      BarOHLC _ohlcs[8];
      int i;
      int _value = WRONG_VALUE;

      switch (iparams.idstype) {
        case IDATA_BUILTIN:
          // In this mode, price is fetched from chart.
          for (i = 0; i < iparams.GetMaxModes(); ++i) {
            _ohlcs[i] = Chart::GetOHLC(_shift + i);
            if (!_ohlcs[i].IsValid()) {
              // Return empty entry on invalid candles.
              return _entry;
            }
          }
          break;
        case IDATA_INDICATOR:
          // In this mode, price is fetched from given indicator. Such indicator
          // must have at least 4 buffers and define OHLC in the first 4 buffers.
          // Indi_Price is an example of such indicator.
          if (indi_src == NULL) {
            GetLogger().Error(
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

          for (i = 0; i < iparams.GetMaxModes(); ++i) {
            _ohlcs[i].open = indi_src.GetValue<float>(_shift + i, PRICE_OPEN);
            _ohlcs[i].high = indi_src.GetValue<float>(_shift + i, PRICE_HIGH);
            _ohlcs[i].low = indi_src.GetValue<float>(_shift + i, PRICE_LOW);
            _ohlcs[i].close = indi_src.GetValue<float>(_shift + i, PRICE_CLOSE);
            if (!_ohlcs[i].IsValid()) {
              // Return empty entry on invalid candles.
              return _entry;
            }
          }
          break;
        default:
          SetUserError(ERR_INVALID_PARAMETER);
      }

      PatternEntry pattern(_ohlcs);

      for (int _mode = 0; _mode < iparams.GetMaxModes(); _mode++) {
        _entry.values[_mode] = pattern[_mode + 1];
      }

      _entry.SetFlag(INDI_ENTRY_FLAG_IS_BITWISE, true);
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _ohlcs[0].IsValid() && _entry.values[1] > 0);

      if (_entry.IsValid()) {
        istate.is_ready = true;
        _entry.AddFlags(_entry.GetDataTypeFlag(iparams.GetDataValueType()));
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

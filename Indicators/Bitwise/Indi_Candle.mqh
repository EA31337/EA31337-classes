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
#include "../../Bar.struct.h"
#include "../../BufferStruct.mqh"
#include "../../Indicator.mqh"
#include "../../Pattern.struct.h"
#include "../../Serializer.mqh"
#include "../Indi_Price.mqh"
#include "../Special/Indi_Math.mqh"

// Structs.
struct CandleParams : IndicatorParams {
  // Struct constructor.
  void CandleParams(int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_CANDLE;
    max_modes = 1;
    SetDataValueType(TYPE_INT);
    SetDataValueRange(IDATA_RANGE_RANGE);
    SetDataSourceType(IDATA_BUILTIN);
    shift = _shift;
    tf = _tf;
  };
  void CandleParams(CandleParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements Candle Pattern Detector.
 */
class Indi_Candle : public Indicator<CandleParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Candle(CandleParams &_params) : Indicator<CandleParams>(_params){};
  Indi_Candle(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_CANDLE, _tf) { iparams.tf = _tf; };

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
      BarOHLC _ohlcs[1];

      switch (iparams.idstype) {
        case IDATA_BUILTIN:
          // In this mode, price is fetched from chart.
          _ohlcs[0] = Chart::GetOHLC(_shift);
          break;
        case IDATA_INDICATOR:
          // In this mode, price is fetched from given indicator. Such indicator
          // must have at least 4 buffers and define OHLC in the first 4 buffers.
          // Indi_Price is an example of such indicator.
          if (indi_src == NULL) {
            GetLogger().Error(
                "In order use custom indicator as a source, you need to select one using SetIndicatorData() method, "
                "which is a part of CandleParams structure.",
                "Indi_Candle");
            Alert(
                "Indi_Candle: In order use custom indicator as a source, you need to select one using "
                "SetIndicatorData() "
                "method, which is a part of CandleParams structure.");
            SetUserError(ERR_INVALID_PARAMETER);
            _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, false);
            return _entry;
          }

          _ohlcs[0].open = indi_src.GetValue<float>(_shift, PRICE_OPEN);
          _ohlcs[0].high = indi_src.GetValue<float>(_shift, PRICE_HIGH);
          _ohlcs[0].low = indi_src.GetValue<float>(_shift, PRICE_LOW);
          _ohlcs[0].close = indi_src.GetValue<float>(_shift, PRICE_CLOSE);
          break;
        default:
          SetUserError(ERR_INVALID_PARAMETER);
          _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, false);
          return _entry;
      }

      PatternCandle1 pattern(_ohlcs[0]);
      _entry.values[0].Set(pattern.GetPattern());

      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, true);
      istate.is_ready = true;

      if (_entry.IsValid()) {
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
    _param.integer_value = GetEntry(_shift).GetValue<int>();
    return _param;
  }
};

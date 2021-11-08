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
#include "../Price/Indi_Price.mqh"
#include "../Special/Indi_Math.mqh"

// Structs.
struct CandleParams : IndicatorParams {
  // Struct constructor.
  CandleParams(int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : IndicatorParams(INDI_CANDLE, 1, TYPE_INT) {
    SetDataValueRange(IDATA_RANGE_RANGE);
    SetDataSourceType(IDATA_BUILTIN);
    shift = _shift;
    tf = _tf;
  };
  CandleParams(CandleParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
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
  Indi_Candle(CandleParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<CandleParams>(_p, _indi_src){};
  Indi_Candle(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_CANDLE, _tf, _shift){};

  /**
   * Alters indicator's struct value.
   */
  virtual void GetEntryAlter(IndicatorDataEntry &_entry, int _shift = 0) {
    _entry.SetFlag(INDI_ENTRY_FLAG_IS_BITWISE, true);
    Indicator<CandleParams>::GetEntryAlter(_entry, _shift);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    BarOHLC _ohlcs[1];

    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        // In this mode, price is fetched from chart.
        _ohlcs[0] = Chart::GetOHLC(_ishift);
        break;
      case IDATA_INDICATOR:
        // In this mode, price is fetched from given indicator. Such indicator
        // must have at least 4 buffers and define OHLC in the first 4 buffers.
        // Indi_Price is an example of such indicator.
        if (!indi_src.IsSet()) {
          GetLogger().Error(
              "In order use custom indicator as a source, you need to select one using SetIndicatorData() method, "
              "which is a part of CandleParams structure.",
              "Indi_Candle");
          Alert(
              "Indi_Candle: In order use custom indicator as a source, you need to select one using "
              "SetIndicatorData() "
              "method, which is a part of CandleParams structure.");
          SetUserError(ERR_INVALID_PARAMETER);
          break;
        }

        _ohlcs[0].open = GetDataSource().GetValue<float>(_ishift, PRICE_OPEN);
        _ohlcs[0].high = GetDataSource().GetValue<float>(_ishift, PRICE_HIGH);
        _ohlcs[0].low = GetDataSource().GetValue<float>(_ishift, PRICE_LOW);
        _ohlcs[0].close = GetDataSource().GetValue<float>(_ishift, PRICE_CLOSE);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }

    PatternCandle1 pattern(_ohlcs[0]);
    _value = pattern.GetPattern();
    return _value;
  }

  /**
   * Checks if indicator entry is valid.
   *
   * @return
   *   Returns true if entry is valid (has valid values), otherwise false.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return !_entry.HasValue<double>(INT_MAX) && _entry.GetMin<int>() >= 0;
  }
};

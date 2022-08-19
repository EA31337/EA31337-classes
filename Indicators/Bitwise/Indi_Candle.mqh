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
#include "../../Indicator/Indicator.h"
#include "../../Pattern.struct.h"
#include "../../Serializer/Serializer.h"
#include "../Price/Indi_Price.mqh"
#include "../Special/Indi_Math.mqh"

// Structs.
struct CandleParams : IndicatorParams {
  // Struct constructor.
  CandleParams(int _shift = 0) : IndicatorParams(INDI_CANDLE) { shift = _shift; };
  CandleParams(CandleParams &_params) { THIS_REF = _params; };
};

/**
 * Implements Candle Pattern Detector.
 */
class Indi_Candle : public Indicator<CandleParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Candle(CandleParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
              int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_INT, _idstype, IDATA_RANGE_RANGE, _indi_src_mode),
                  _indi_src){};

  Indi_Candle(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
              int _indi_src_mode = 0)
      : Indicator(CandleParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_INT, _idstype, IDATA_RANGE_RANGE, _indi_src_mode),
                  _indi_src){};

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_CUSTOM; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN | IDATA_ICUSTOM; }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<CandleParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // Patter uses OHLC.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_OPEN) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_LOW) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_CLOSE);
  }

  /**
   * Alters indicator's struct value.
   */
  void GetEntryAlter(IndicatorDataEntry &_entry, int _shift) override {
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

    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        // In this mode, price is fetched from IndicatorCandle.
        _ohlcs[0] = GetCandle() PTR_DEREF GetOHLC(_ishift);
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

        _ohlcs[0].open = GetDataSource().GetValue<float>(PRICE_OPEN, _ishift);
        _ohlcs[0].high = GetDataSource().GetValue<float>(PRICE_HIGH, _ishift);
        _ohlcs[0].low = GetDataSource().GetValue<float>(PRICE_LOW, _ishift);
        _ohlcs[0].close = GetDataSource().GetValue<float>(PRICE_CLOSE, _ishift);
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

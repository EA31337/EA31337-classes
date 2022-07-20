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
struct IndiPatternParams : IndicatorParams {
  // Struct constructor.
  IndiPatternParams(int _shift = 0) : IndicatorParams(INDI_PATTERN, 5, TYPE_UINT) {
    SetDataValueType(TYPE_UINT);
    SetDataValueRange(IDATA_RANGE_BITWISE);
    shift = _shift;
  };
  IndiPatternParams(IndiPatternParams& _params) { THIS_REF = _params; };
};

/**
 * Implements Pattern Detector.
 */
class Indi_Pattern : public Indicator<IndiPatternParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Pattern(IndiPatternParams& _p, IndicatorBase* _indi_src = NULL) : Indicator(_p, _indi_src){};
  Indi_Pattern(int _shift = 0) : Indicator(INDI_PATTERN, _shift){};

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_CUSTOM; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN | IDATA_INDICATOR; }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorBase* _ds) override {
    if (Indicator<IndiPatternParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // Patter uses OHLC.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_OPEN) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_LOW) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_CLOSE);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) {
    int i;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    BarOHLC _ohlcs[8];

    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        // In this mode, price is fetched from candle.
        for (i = 0; i < iparams.GetMaxModes(); ++i) {
          _ohlcs[i] = GetCandle() PTR_DEREF GetOHLC(_ishift + i);
          if (!_ohlcs[i].IsValid()) {
            // Return empty entry on invalid candles.
            return WRONG_VALUE;
          }
        }
        break;
      case IDATA_INDICATOR:
        // In this mode, price is fetched from given indicator. Such indicator
        // must have at least 4 buffers and define OHLC in the first 4 buffers.
        // Indi_Price is an example of such indicator.
        if (!indi_src.IsSet()) {
          GetLogger().Error(
              "In order use custom indicator as a source, you need to select one using SetIndicatorData() method, "
              "which is a part of PatternParams structure.",
              "Indi_Pattern");
          Alert(
              "Indi_Pattern: In order use custom indicator as a source, you need to select one using "
              "SetIndicatorData() "
              "method, which is a part of PatternParams structure.");
          SetUserError(ERR_INVALID_PARAMETER);
          return WRONG_VALUE;
        }

        for (i = 0; i < iparams.GetMaxModes(); ++i) {
          _ohlcs[i].open = GetDataSource().GetValue<float>(PRICE_OPEN, _ishift + i);
          _ohlcs[i].high = GetDataSource().GetValue<float>(PRICE_HIGH, _ishift + i);
          _ohlcs[i].low = GetDataSource().GetValue<float>(PRICE_LOW, _ishift + i);
          _ohlcs[i].close = GetDataSource().GetValue<float>(PRICE_CLOSE, _ishift + i);
          if (!_ohlcs[i].IsValid()) {
            // Return empty entry on invalid candles.
            return WRONG_VALUE;
          }
        }
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        return WRONG_VALUE;
    }
    PatternEntry pattern(_ohlcs);
    return pattern[_mode + 1];
  }

  /**
   * Alters indicator's struct value.
   */
  void GetEntryAlter(IndicatorDataEntry& _entry, int _shift) override {
    _entry.SetFlag(INDI_ENTRY_FLAG_IS_BITWISE, true);
    Indicator<IndiPatternParams>::GetEntryAlter(_entry, _shift);
  }

  /**
   * Checks if indicator entry is valid.
   *
   * @return
   *   Returns true if entry is valid (has valid values), otherwise false.
   */
  virtual bool IsValidEntry(IndicatorDataEntry& _entry) { return !_entry.HasValue<int>(INT_MAX); }
};

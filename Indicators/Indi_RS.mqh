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
#include "../BufferStruct.mqh"
#include "../Indicator/Indicator.h"
#include "OHLC/Indi_OHLC.mqh"
#include "Special/Indi_Math.mqh"

// Structs.
struct IndiRSParams : IndicatorParams {
  ENUM_APPLIED_VOLUME applied_volume;
  // Struct constructor.
  IndiRSParams(ENUM_APPLIED_VOLUME _applied_volume = VOLUME_TICK, int _shift = 0) : IndicatorParams(INDI_RS) {
    applied_volume = _applied_volume;
    shift = _shift;
  };
  IndiRSParams(IndiRSParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_RS : public Indicator<IndiRSParams> {
  DictStruct<int, Ref<Indi_Math>> imath;

 public:
  /**
   * Class constructor.
   */
  Indi_RS(IndiRSParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_MATH, IndicatorData *_indi_src = NULL,
          int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE_DIFF, _indi_src_mode),
                  _indi_src) {
    Init();
  };
  Indi_RS(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_MATH, IndicatorData *_indi_src = NULL,
          int _indi_src_mode = 0)
      : Indicator(IndiRSParams(),
                  IndicatorDataParams::GetInstance(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE_DIFF, _indi_src_mode),
                  _indi_src) {
    Init();
  };

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override {
    return INDI_SUITABLE_DS_TYPE_CUSTOM | INDI_SUITABLE_DS_TYPE_BASE_ONLY;
  }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_MATH; }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiRSParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // RS uses OHLC.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_OPEN) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_LOW) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_CLOSE);
  }

  void Init() {
    if (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE)) == IDATA_MATH) {
      IndiOHLCParams _iohlc_params();
      IndiMathParams _imath0_p(MATH_OP_SUB, INDI_OHLC_CLOSE, 0, INDI_OHLC_CLOSE, 1);
      IndiMathParams _imath1_p(MATH_OP_SUB, INDI_OHLC_CLOSE, 1, INDI_OHLC_CLOSE, 0);
      Ref<Indi_Math> _imath0 = new Indi_Math(_imath0_p);
      Ref<Indi_Math> _imath1 = new Indi_Math(_imath1_p);
      imath.Set(0, _imath0);
      imath.Set(1, _imath1);
    }
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_MATH:
        // Updating Maths' data sources to be the same as RS data source.
        imath.GetByKey(0) REF_DEREF SetDataSource(GetDataSource());
        imath.GetByKey(1) REF_DEREF SetDataSource(GetDataSource());
        return imath[_mode].Ptr().GetEntryValue();
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return EMPTY_VALUE;
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) { return true; }
};

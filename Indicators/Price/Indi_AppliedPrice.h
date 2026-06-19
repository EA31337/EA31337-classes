//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
#include "../../Indicator/Indicator.h"
#include "../../Storage/Dict/Buffer/BufferStruct.h"
#include "../OHLC/Indi_OHLC.mqh"

// Structs.
struct IndiAppliedPriceParams : IndicatorParams {
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  IndiAppliedPriceParams(ENUM_APPLIED_PRICE _applied_price = PRICE_OPEN, int _shift = 0)
      : IndicatorParams(INDI_APPLIED_PRICE), applied_price(_applied_price) {
    shift = _shift;
  };
  IndiAppliedPriceParams(IndiAppliedPriceParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the "Applied Price over OHCL Indicator" indicator, e.g. over Indi_Price.
 */
class Indi_AppliedPrice : public Indicator<IndiAppliedPriceParams> {
 protected:
  void OnInit() {
    /*
    if (!indi_src.IsSet()) {
      Indi_OHLC *_indi_ohlc = new Indi_OHLC();
      SetDataSource(_indi_ohlc);
    }
    */
  }

 public:
  /**
   * Class constructor.
   */
  Indi_AppliedPrice(IndiAppliedPriceParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_INDICATOR,
                    IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src) {
    OnInit();
  };
  Indi_AppliedPrice(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_INDICATOR, IndicatorData *_indi_src = NULL,
                    int _indi_src_mode = 0)
      : Indicator(IndiAppliedPriceParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src) {
    OnInit();
  };

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override {
    return INDI_SUITABLE_DS_TYPE_AP | INDI_SUITABLE_DS_TYPE_BASE_ONLY;
  }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_INDICATOR; }

  static double iAppliedPriceOnIndicator(IndicatorData *_indi, ENUM_APPLIED_PRICE _applied_price, int _shift = 0) {
    ARRAY(double, _ohlc);
    PTR_TO_REF(_indi)[_shift].GetArray(_ohlc, 4);
    return BarOHLC::GetAppliedPrice(_applied_price, _ohlc[0], _ohlc[1], _ohlc[2], _ohlc[3]);
  }

  /**
   * Returns the indicator's value.
   */
   IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _abs_shift = 0) override {
     double _value = EMPTY_VALUE;
     switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
       case IDATA_INDICATOR:
         if (HasDataSource()) {
           _value =
               Indi_AppliedPrice::iAppliedPriceOnIndicator(GetDataSource(), GetAppliedPrice(), ToRelShift(_abs_shift));
         }
         break;
       case IDATA_BUILTIN:
       case IDATA_CHART:
       case IDATA_ICUSTOM:
       case IDATA_ICUSTOM_LEGACY:
       case IDATA_ONCALCULATE:
       case IDATA_MATH:
         SetUserError(ERR_INVALID_PARAMETER);
         break;
       default:
         break;
     }
     return _value;
   }

  /**
   * Checks if indicator entry is valid.
   *
   * @return
   *   Returns true if entry is valid (has valid values), otherwise false.
   */
   bool IsValidEntry(IndicatorDataEntry &_entry) override {
     bool _is_valid = Indicator<IndiAppliedPriceParams>::IsValidEntry(_entry);
     switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
       case IDATA_INDICATOR:
         if (!HasDataSource()) {
           logger REF_DEREF Error("Indi_AppliedPrice requires source indicator to be set via SetDataSource()!");
           _is_valid &= false;
         }
         break;
       case IDATA_BUILTIN:
       case IDATA_CHART:
       case IDATA_ICUSTOM:
       case IDATA_ICUSTOM_LEGACY:
       case IDATA_ONCALCULATE:
       case IDATA_MATH:
         break;
     }
     return _is_valid;
   }

  /* Getters */

  /**
   * Get applied price.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return iparams.applied_price; }

  /* Setters */

  /**
   * Get applied price.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};

#ifdef __EMSCRIPTEN__
#include <emscripten/bind.h>

EMSCRIPTEN_BINDINGS(Indi_AppliedPrice_Params) {
  emscripten::value_object<IndiAppliedPriceParams>("indicators.AppliedPriceParams")
      .field("appliedPrice", &IndiAppliedPriceParams::applied_price)
      // Inherited fields:
      .field("shift", &IndiAppliedPriceParams::shift);
}

EMSCRIPTEN_BINDINGS(Indi_AppliedPriceBase) {
  emscripten::class_<Indicator<IndiAppliedPriceParams>, emscripten::base<IndicatorData>>("Indi_AppliedPriceBase");
}

EMSCRIPTEN_BINDINGS(Indi_AppliedPrice) {
  emscripten::class_<Indi_AppliedPrice, emscripten::base<Indicator<IndiAppliedPriceParams>>>("indicators.AppliedPrice")
      .smart_ptr<Ref<Indi_AppliedPrice>>("Ref<Indi_AppliedPrice>")
      .constructor(&make_ref<Indi_AppliedPrice, IndiAppliedPriceParams &>)
      .constructor(&make_ref<Indi_AppliedPrice, IndiAppliedPriceParams &, ENUM_IDATA_SOURCE_TYPE>)
      .constructor(&make_ref<Indi_AppliedPrice, IndiAppliedPriceParams &, ENUM_IDATA_SOURCE_TYPE, IndicatorData *>,
                   emscripten::allow_raw_pointer<emscripten::arg<2>>())
      .constructor(&make_ref<Indi_AppliedPrice, IndiAppliedPriceParams &, ENUM_IDATA_SOURCE_TYPE, IndicatorData *, int>,
                   emscripten::allow_raw_pointer<emscripten::arg<2>>());
}

#endif  // __EMSCRIPTEN__

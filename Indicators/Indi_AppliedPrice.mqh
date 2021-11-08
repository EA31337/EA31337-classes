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
#include "../Indicator.mqh"
#include "OHLC/Indi_OHLC.mqh"

// Structs.
struct IndiAppliedPriceParams : IndicatorParams {
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  IndiAppliedPriceParams(ENUM_APPLIED_PRICE _applied_price = PRICE_OPEN, int _shift = 0)
      : applied_price(_applied_price), IndicatorParams(INDI_APPLIED_PRICE, 1, TYPE_DOUBLE) {
    SetDataSourceType(IDATA_INDICATOR);
    SetDataValueRange(IDATA_RANGE_PRICE);
    shift = _shift;
  };
  IndiAppliedPriceParams(IndiAppliedPriceParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements the "Applied Price over OHCL Indicator" indicator, e.g. over Indi_Price.
 */
class Indi_AppliedPrice : public Indicator<IndiAppliedPriceParams> {
 protected:
  void OnInit() {
    if (!indi_src.IsSet()) {
      Indi_OHLC *_indi_ohlc = new Indi_OHLC();
      SetDataSource(_indi_ohlc);
    }
  }

 public:
  /**
   * Class constructor.
   */
  Indi_AppliedPrice(IndiAppliedPriceParams &_p, IndicatorBase *_indi_src = NULL)
      : Indicator<IndiAppliedPriceParams>(_p, _indi_src) {
    OnInit();
  };
  Indi_AppliedPrice(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_PRICE, _tf, _shift) {
    OnInit();
  };

  static double iAppliedPriceOnIndicator(IndicatorBase *_indi, ENUM_APPLIED_PRICE _applied_price, int _shift = 0) {
    double _ohlc[4];
    _indi[_shift].GetArray(_ohlc, 4);
    return BarOHLC::GetAppliedPrice(_applied_price, _ohlc[0], _ohlc[1], _ohlc[2], _ohlc[3]);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_INDICATOR:
        if (HasDataSource()) {
          // Future validation of indi_src will check if we set mode for source indicator
          // (e.g. for applied price of Indi_Price).
          iparams.SetDataSourceMode(GetAppliedPrice());
          _value = Indi_AppliedPrice::iAppliedPriceOnIndicator(GetDataSource(), GetAppliedPrice(), _ishift);
        }
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
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
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    bool _is_valid = Indicator<IndiAppliedPriceParams>::IsValidEntry(_entry);
    switch (iparams.idstype) {
      case IDATA_INDICATOR:
        if (!HasDataSource()) {
          GetLogger().Error("Indi_AppliedPrice requires source indicator to be set via SetDataSource()!");
          _is_valid &= false;
        }
        break;
    }
    return _is_valid;
  }

  /* Getters */

  /**
   * Get applied price.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return iparams.applied_price; }

  /* Setters */

  /**
   * Get applied price.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};

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
#include "../Indicator/Indicator.h"
#include "../Storage/Singleton.h"
#include "Indi_MA.mqh"
#include "Indi_PriceFeeder.mqh"
#include "Price/Indi_Price.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iEnvelopes(string _symbol, int _tf, int _period, int _ma_method, int _ma_shift, int _ap, double _deviation,
                  int _mode, int _shift) {
  ResetLastError();
  return Indi_Envelopes::iEnvelopes(_symbol, (ENUM_TIMEFRAMES)_tf, _period, (ENUM_MA_METHOD)_ma_method, _ma_shift,
                                    (ENUM_APPLIED_PRICE)_ap, _deviation, _mode, _shift);
}
double iEnvelopesOnArray(double &_arr[], int _total, int _ma_period, int _ma_method, int _ma_shift, double _deviation,
                         int _mode, int _shift) {
  ResetLastError();
  return Indi_Envelopes::iEnvelopesOnArray(_arr, _total, _ma_period, (ENUM_MA_METHOD)_ma_method, _ma_shift, _deviation,
                                           _mode, _shift);
}
#endif

// Structs.
struct IndiEnvelopesParams : IndicatorParams {
  int ma_period;
  int ma_shift;
  ENUM_MA_METHOD ma_method;
  ENUM_APPLIED_PRICE applied_price;
  double deviation;
  // Struct constructors.
  IndiEnvelopesParams(int _ma_period = 13, int _ma_shift = 0, ENUM_MA_METHOD _ma_method = MODE_SMA,
                      ENUM_APPLIED_PRICE _ap = PRICE_OPEN, double _deviation = 2, int _shift = 0)
      : ma_period(_ma_period),
        ma_shift(_ma_shift),
        ma_method(_ma_method),
        applied_price(_ap),
        deviation(_deviation),
        IndicatorParams(INDI_ENVELOPES) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\Envelopes");
  };
  IndiEnvelopesParams(IndiEnvelopesParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Envelopes indicator.
 */
class Indi_Envelopes : public Indicator<IndiEnvelopesParams> {
 protected:
  /* Protected methods */

  /**
   * Initialize.
   */
  void Init() {
#ifdef __MQL4__
    // There is extra LINE_MAIN in MQL4 for Envelopes.
    Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES), 3);
#else
    Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES), 2);
#endif
  }

 public:
  /**
   * Class constructor.
   */
  Indi_Envelopes(IndiEnvelopesParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                 IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src) {
    Init();
  }
  Indi_Envelopes(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                 int _indi_src_mode = 0)
      : Indicator(IndiEnvelopesParams(),
                  IndicatorDataParams::GetInstance(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src) {
    Init();
  }
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_AP; }

 public:
  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override {
    return IDATA_BUILTIN | IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR;
  }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ienvelopes
   * - https://www.mql5.com/en/docs/indicators/ienvelopes
   */
  static double iEnvelopes(string _symbol, ENUM_TIMEFRAMES _tf, int _ma_period, ENUM_MA_METHOD _ma_method,
                           int _ma_shift, ENUM_APPLIED_PRICE _ap, double _deviation,
                           int _mode,  // (MT4 _mode): 0 - MODE_MAIN,  1 - MODE_UPPER, 2 - MODE_LOWER; (MT5 _mode): 0 -
                                       // UPPER_LINE, 1 - LOWER_LINE
                           int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL4__
    return ::iEnvelopes(_symbol, _tf, _ma_period, _ma_method, _ma_shift, _ap, _deviation, _mode, _shift);
#else  // __MQL5__
    switch (_mode) {
      case LINE_UPPER:
        _mode = 0;
        break;
      case LINE_LOWER:
        _mode = 1;
        break;
    }
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iEnvelopes(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _ap, _deviation)) ==
          INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      } else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    if (Terminal::IsVisualMode()) {
      // To avoid error 4806 (ERR_INDICATOR_DATA_NOT_FOUND),
      // we check the number of calculated data only in visual mode.
      int _bars_calc = BarsCalculated(_handle);
      if (GetLastError() > 0) {
        return EMPTY_VALUE;
      } else if (_bars_calc <= 2) {
        SetUserError(ERR_USER_INVALID_BUFF_NUM);
        return EMPTY_VALUE;
      }
    }
    if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {
      return ArraySize(_res) > 0 ? _res[0] : EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  static double iEnvelopesOnIndicator(IndicatorData *_target, IndicatorData *_source, string _symbol,
                                      ENUM_TIMEFRAMES _tf, int _ma_period,
                                      ENUM_MA_METHOD _ma_method,  // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
                                      ENUM_APPLIED_PRICE _ap, int _ma_shift, double _deviation,
                                      int _mode,  // (MT4 _mode): 0 - MODE_MAIN,  1 - MODE_UPPER, 2 - MODE_LOWER; (MT5
                                                  // _mode): 0 - UPPER_LINE, 1 - LOWER_LINE
                                      int _shift = 0) {
    return iEnvelopesOnArray(_source.GetSpecificAppliedPriceValueStorage(_ap, _target), 0, _ma_period, _ma_method,
                             _ma_shift, _deviation, _mode, _shift, _target PTR_DEREF GetCache());
  }

  static double iEnvelopesOnArray(double &price[], int total, int ma_period, ENUM_MA_METHOD ma_method, int ma_shift,
                                  double deviation, int mode, int shift,
                                  IndicatorCalculateCache<double> *_cache = NULL) {
#ifdef __MQL4__
    return iEnvelopesOnArray(price, total, ma_period, ma_method, ma_shift, deviation, mode, shift);
#else
    // We're reusing the same native array for each consecutive calculation.
    NativeValueStorage<double> *_price = Singleton<NativeValueStorage<double> >::Get();
    _price.SetData(price);

    return iEnvelopesOnArray(_price, total, ma_period, ma_method, ma_shift, deviation, mode, shift);
#endif
  }

  static double iEnvelopesOnArray(ValueStorage<double> *_price, int _total, int _ma_period, ENUM_MA_METHOD _ma_method,
                                  int _ma_shift, double _deviation, int _mode, int _shift,
                                  IndicatorCalculateCache<double> *_cache = NULL) {
    double _indi_value_buffer[];
    double _result;

    ArrayResize(_indi_value_buffer, _ma_period);

    // MA will use sub-cache of the given one.
    _result = Indi_MA::iMAOnArray(_price, 0, _ma_period, _ma_shift, _ma_method, _shift, _cache.GetSubCache(0));

    switch (_mode) {
      case LINE_UPPER:
        _result *= (1.0 + _deviation / 100);
        break;
      case LINE_LOWER:
        _result *= (1.0 - _deviation / 100);
        break;
#ifdef __MQL4__
      case LINE_MAIN:
        // The LINE_MAIN only exists in MQL4 for Envelopes.
        _result *= 1.0;
        break;
#endif
      default:
        _result = DBL_MIN;
    }

    return _result;
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_Envelopes::iEnvelopes(GetSymbol(), GetTf(), GetMAPeriod(), GetMAMethod(), GetMAShift(),
                                            GetAppliedPrice(), GetDeviation(), _mode, _ishift, THIS_PTR);
        break;
      case IDATA_ONCALCULATE:
        // @todo Is cache needed here?
        _value = Indi_Envelopes::iEnvelopesOnIndicator(THIS_PTR, GetDataSource(), GetSymbol(), GetTf(), GetMAPeriod(),
                                                       GetMAMethod(), GetAppliedPrice(), GetMAShift(), GetDeviation(),
                                                       _mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /**/ GetMAPeriod(),
                         GetMAMethod(), GetMAShift(), GetAppliedPrice(), GetDeviation() /**/, _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_Envelopes::iEnvelopesOnIndicator(THIS_PTR, GetDataSource(), GetSymbol(), GetTf(), GetMAPeriod(),
                                                       GetMAMethod(), GetAppliedPrice(), GetMAShift(), GetDeviation(),
                                                       _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _value;
  }

  /**
   * Alters indicator's struct value.
   */
  void GetEntryAlter(IndicatorDataEntry &_entry, int _shift) override {
    Indicator<IndiEnvelopesParams>::GetEntryAlter(_entry, _shift);
#ifdef __MQL4__
    // The LINE_MAIN only exists in MQL4 for Envelopes.
    _entry.values[LINE_MAIN] = GetValue<double>((ENUM_LO_UP_LINE)LINE_MAIN, _shift);
#endif
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return Indicator<IndiEnvelopesParams>::IsValidEntry(_entry) && _entry.IsGt<double>(0);
  }

  /* Getters */

  /**
   * Get MA period value.
   */
  int GetMAPeriod() { return iparams.ma_period; }

  /**
   * Set MA method.
   */
  ENUM_MA_METHOD GetMAMethod() { return iparams.ma_method; }

  /**
   * Get MA shift value.
   */
  int GetMAShift() { return iparams.ma_shift; }

  /**
   * Get applied price value.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return iparams.applied_price; }

  /**
   * Get deviation value.
   */
  double GetDeviation() { return iparams.deviation; }

  /* Setters */

  /**
   * Set MA period value.
   */
  void SetMAPeriod(int _ma_period) {
    istate.is_changed = true;
    iparams.ma_period = _ma_period;
  }

  /**
   * Set MA method.
   */
  void SetMAMethod(ENUM_MA_METHOD _ma_method) {
    istate.is_changed = true;
    iparams.ma_method = _ma_method;
  }

  /**
   * Set MA shift value.
   */
  void SetMAShift(int _ma_shift) {
    istate.is_changed = true;
    iparams.ma_shift = _ma_shift;
  }

  /**
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _ap) {
    istate.is_changed = true;
    iparams.applied_price = _ap;
  }

  /**
   * Set deviation value.
   */
  void SetDeviation(double _deviation) {
    istate.is_changed = true;
    iparams.deviation = _deviation;
  }
};

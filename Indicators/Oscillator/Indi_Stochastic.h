//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

// Includes.
#include "../../Indicator/Indicator.h"
#include "../Price/Indi_MA.h"

#ifndef __MQL__
// Enums.
// @see: https://www.mql5.com/en/docs/constants/indicatorconstants/prices
enum ENUM_STO_PRICE {
  STO_LOWHIGH = 0,  // Calculation is based on Low/High prices.
  STO_CLOSECLOSE,   // Calculation is based on Close/Close prices.
};
#endif

#ifndef __MQL4__
// Forward declaration.
class Indi_Stochastic;

// Defines global functions (for MQL4 backward compability).
double iStochastic(string _symbol, int _tf, int _kperiod, int _dperiod, int _slowing, int _ma_method, int _pf,
                   int _mode, int _shift) {
  ResetLastError();
  return Indi_Stochastic::iStochastic(_symbol, (ENUM_TIMEFRAMES)_tf, _kperiod, _dperiod, _slowing,
                                      (ENUM_MA_METHOD)_ma_method, (ENUM_STO_PRICE)_pf, _mode, _shift);
}
#endif

// Structs.
struct IndiStochParams : IndicatorParams {
  int kperiod;
  int dperiod;
  int slowing;
  ENUM_MA_METHOD ma_method;
  ENUM_STO_PRICE price_field;
  // Struct constructors.
  IndiStochParams(int _kperiod = 5, int _dperiod = 3, int _slowing = 3, ENUM_MA_METHOD _ma_method = MODE_SMA,
                  ENUM_STO_PRICE _pf = STO_LOWHIGH, int _shift = 0)
      : kperiod(_kperiod),
        dperiod(_dperiod),
        slowing(_slowing),
        ma_method(_ma_method),
        price_field(_pf),
        IndicatorParams(INDI_STOCHASTIC) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\Stochastic");
  };
  IndiStochParams(IndiStochParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Stochastic Oscillator.
 */
class Indi_Stochastic : public Indicator<IndiStochParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Stochastic(IndiStochParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                  int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(FINAL_SIGNAL_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_RANGE,
                                                   _indi_src_mode),
                  _indi_src) {}
  Indi_Stochastic(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                  int _indi_src_mode = 0)
      : Indicator(IndiStochParams(),
                  IndicatorDataParams::GetInstance(FINAL_SIGNAL_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_RANGE,
                                                   _indi_src_mode),
                  _indi_src) {}
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN | IDATA_ICUSTOM; }

  /**
   * Calculates the Stochastic Oscillator and returns its value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/istochastic
   * - https://www.mql5.com/en/docs/indicators/istochastic
   */
  static double iStochastic(
      string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _kperiod, unsigned int _dperiod, unsigned int _slowing,
      ENUM_MA_METHOD _ma_method,    // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
      ENUM_STO_PRICE _price_field,  // (MT4 _price_field):      0      - Low/High,       1        - Close/Close
                                    // (MT5 _price_field): STO_LOWHIGH - Low/High, STO_CLOSECLOSE - Close/Close
      int _mode,                    // (MT4): 0 - MODE_MAIN/MAIN_LINE, 1 - MODE_SIGNAL/SIGNAL_LINE
      int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL__
#ifdef __MQL4__
    return ::iStochastic(_symbol, _tf, _kperiod, _dperiod, _slowing, _ma_method, _price_field, _mode, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(
        ::iStochastic(_symbol, _tf, _kperiod, _dperiod, _slowing, _ma_method, _price_field), _mode, _shift);
#endif
#else  // Non-MQL.
    // @todo: Use Platform class.
    RUNTIME_ERROR(
        "Not implemented. Please use an On-Indicator mode and attach "
        "indicator via Platform::Add/AddWithDefaultBindings().");
    return DBL_MAX;
#endif
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = LINE_MAIN, int _abs_shift = 0) {
    double _value = EMPTY_VALUE;
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_Stochastic::iStochastic(GetSymbol(), GetTf(), GetKPeriod(), GetDPeriod(), GetSlowing(),
                                              GetMAMethod(), GetPriceField(), _mode, ToRelShift(_abs_shift), THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetKPeriod(),
                         GetDPeriod(), GetSlowing() /*]*/, _mode, ToRelShift(_abs_shift));
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) { return _entry.IsWithinRange<double>(0, 101); }

  /* Getters */

  /**
   * Get period of the %K line.
   */
  int GetKPeriod() { return iparams.kperiod; }

  /**
   * Get period of the %D line.
   */
  int GetDPeriod() { return iparams.dperiod; }

  /**
   * Get slowing value.
   */
  int GetSlowing() { return iparams.slowing; }

  /**
   * Set MA method.
   */
  ENUM_MA_METHOD GetMAMethod() { return iparams.ma_method; }

  /**
   * Get price field parameter.
   */
  ENUM_STO_PRICE GetPriceField() { return iparams.price_field; }

  /* Setters */

  /**
   * Set period of the %K line.
   */
  void SetKPeriod(int _kperiod) {
    istate.is_changed = true;
    iparams.kperiod = _kperiod;
  }

  /**
   * Set period of the %D line.
   */
  void SetDPeriod(int _dperiod) {
    istate.is_changed = true;
    iparams.dperiod = _dperiod;
  }

  /**
   * Set slowing value.
   */
  void SetSlowing(int _slowing) {
    istate.is_changed = true;
    iparams.slowing = _slowing;
  }

  /**
   * Set MA method.
   */
  void SetMAMethod(ENUM_MA_METHOD _ma_method) {
    istate.is_changed = true;
    iparams.ma_method = _ma_method;
  }

  /**
   * Set price field parameter.
   */
  void SetPriceField(ENUM_STO_PRICE _price_field) {
    istate.is_changed = true;
    iparams.price_field = _price_field;
  }
};

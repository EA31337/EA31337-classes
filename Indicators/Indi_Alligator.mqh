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

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iAlligator(string _symbol, int _tf, int _jp, int _js, int _tp, int _ts, int _lp, int _ls, int _ma_method,
                  int _ap, int _mode, int _shift) {
  ResetLastError();
  return Indi_Alligator::iAlligator(_symbol, (ENUM_TIMEFRAMES)_tf, _jp, _js, _tp, _ts, _lp, _ls,
                                    (ENUM_MA_METHOD)_ma_method, (ENUM_APPLIED_PRICE)_ap, (ENUM_ALLIGATOR_LINE)_mode,
                                    _shift);
}
#endif

#ifndef __MQLBUILD__
// Defines.
// Indicator constants.
// Identifiers of indicator lines permissible when copying values of iAlligator().
#define GATORJAW_LINE 0    // Jaw line.
#define GATORTEETH_LINE 1  // Teeth line.
#define GATORLIPS_LINE 2   // Lips line.
#endif

// Enums.
// Indicator line identifiers used in Gator and Alligator indicators.
// @docs
// - https://www.mql5.com/en/docs/constants/indicatorconstants/lines
enum ENUM_ALLIGATOR_LINE {
#ifdef __MQL4__
  LINE_JAW = MODE_GATORJAW,      // Jaw line.
  LINE_TEETH = MODE_GATORTEETH,  // Teeth line.
  LINE_LIPS = MODE_GATORLIPS,    // Lips line.
#else
  LINE_JAW = GATORJAW_LINE,      // Jaw line.
  LINE_TEETH = GATORTEETH_LINE,  // Teeth line.
  LINE_LIPS = GATORLIPS_LINE,    // Lips line.
#endif
  FINAL_ALLIGATOR_LINE_ENTRY,
};

// Structs.
struct IndiAlligatorParams : IndicatorParams {
  int jaw_period;                    // Jaw line averaging period.
  int jaw_shift;                     // Jaw line shift.
  int teeth_period;                  // Teeth line averaging period.
  int teeth_shift;                   // Teeth line shift.
  int lips_period;                   // Lips line averaging period.
  int lips_shift;                    // Lips line shift.
  ENUM_MA_METHOD ma_method;          // Averaging method.
  ENUM_APPLIED_PRICE applied_price;  // Applied price.
  // Struct constructors.
  IndiAlligatorParams(int _jp = 13, int _js = 8, int _tp = 8, int _ts = 5, int _lp = 5, int _ls = 3,
                      ENUM_MA_METHOD _mm = MODE_SMMA, ENUM_APPLIED_PRICE _ap = PRICE_MEDIAN, int _shift = 0)
      : jaw_period(_jp),
        jaw_shift(_js),
        teeth_period(_tp),
        teeth_shift(_ts),
        lips_period(_lp),
        lips_shift(_ls),
        ma_method(_mm),
        applied_price(_ap),
        IndicatorParams(INDI_ALLIGATOR) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\Alligator");
  };
  IndiAlligatorParams(IndiAlligatorParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Alligator indicator.
 */
class Indi_Alligator : public Indicator<IndiAlligatorParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Alligator(IndiAlligatorParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                 IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(
            _p, IndicatorDataParams::GetInstance(FINAL_ALLIGATOR_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE),
            _indi_src, _indi_src_mode) {}
  Indi_Alligator(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                 int _indi_src_mode = 0)
      : Indicator(
            IndiAlligatorParams(),
            IndicatorDataParams::GetInstance(FINAL_ALLIGATOR_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE),
            _indi_src, _indi_src_mode){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN | IDATA_ICUSTOM; }

  /**
   * Returns the indicator value.
   *
   * @param
   * _ma_method ENUM_MA_METHOD
   * - MT4/MT5: MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
   * _applied_price ENUM_APPLIED_PRICE
   * - MT4: MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
   * - MT5: PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
   * _mode ENUM_ALLIGATOR_LINE
   * - EA: LINE_JAW, LINE_TEETH, LINE_LIPS
   * - MT4: 1 - MODE_GATORJAW, 2 - MODE_GATORTEETH, 3 - MODE_GATORLIPS
   * - MT5: 0 - GATORJAW_LINE, 1 - GATORTEETH_LINE, 2 - GATORLIPS_LINE
   *
   * @docs
   * - https://docs.mql4.com/indicators/ialligator
   * - https://www.mql5.com/en/docs/indicators/ialligator
   */
  static double iAlligator(string _symbol, ENUM_TIMEFRAMES _tf, int _jaw_period, int _jaw_shift, int _teeth_period,
                           int _teeth_shift, int _lips_period, int _lips_shift, ENUM_MA_METHOD _ma_method,
                           ENUM_APPLIED_PRICE _applied_price, ENUM_ALLIGATOR_LINE _mode, int _shift = 0,
                           IndicatorData *_obj = NULL) {
#ifdef __MQL4__
    return ::iAlligator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift,
                        _ma_method, _applied_price, _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iAlligator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period,
                                  _lips_shift, _ma_method, _applied_price)) == INVALID_HANDLE) {
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

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
#ifdef __MQL4__
    if (_mode == 0) {
      // In MQL4 mode 0 should be treated as mode 1 as Alligator buffers starts from index 1.
      return GetEntryValue((ENUM_ALLIGATOR_LINE)1, _ishift);
    }
#endif
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_Alligator::iAlligator(GetSymbol(), GetTf(), GetJawPeriod(), GetJawShift(), GetTeethPeriod(),
                                            GetTeethShift(), GetLipsPeriod(), GetLipsShift(), GetMAMethod(),
                                            GetAppliedPrice(), (ENUM_ALLIGATOR_LINE)_mode, _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/
                         GetJawPeriod(), GetJawShift(), GetTeethPeriod(), GetTeethShift(), GetLipsPeriod(),
                         GetLipsShift(), GetMAMethod(),
                         GetAppliedPrice()
                         /*]*/,
                         _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE) && _entry.IsGt<double>(0);
  }

  /* Class getters */

  /**
   * Get jaw period value.
   */
  int GetJawPeriod() { return iparams.jaw_period; }

  /**
   * Get jaw shift value.
   */
  int GetJawShift() { return iparams.jaw_shift; }

  /**
   * Get teeth period value.
   */
  int GetTeethPeriod() { return iparams.teeth_period; }

  /**
   * Get teeth shift value.
   */
  int GetTeethShift() { return iparams.teeth_shift; }

  /**
   * Get lips period value.
   */
  int GetLipsPeriod() { return iparams.lips_period; }

  /**
   * Get lips shift value.
   */
  int GetLipsShift() { return iparams.lips_shift; }

  /**
   * Get MA method.
   */
  ENUM_MA_METHOD GetMAMethod() { return iparams.ma_method; }

  /**
   * Get applied price value.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return iparams.applied_price; }

  /* Class setters */

  /**
   * Set jaw period value.
   */
  void SetJawPeriod(int _jaw_period) {
    istate.is_changed = true;
    iparams.jaw_period = _jaw_period;
  }

  /**
   * Set jaw shift value.
   */
  void SetJawShift(int _jaw_shift) {
    istate.is_changed = true;
    iparams.jaw_shift = _jaw_shift;
  }

  /**
   * Set teeth period value.
   */
  void SetTeethPeriod(int _teeth_period) {
    istate.is_changed = true;
    iparams.teeth_period = _teeth_period;
  }

  /**
   * Set teeth shift value.
   */
  void SetTeethShift(int _teeth_shift) {
    istate.is_changed = true;
    iparams.teeth_period = _teeth_shift;
  }

  /**
   * Set lips period value.
   */
  void SetLipsPeriod(int _lips_period) {
    istate.is_changed = true;
    iparams.lips_period = _lips_period;
  }

  /**
   * Set lips shift value.
   */
  void SetLipsShift(int _lips_shift) {
    istate.is_changed = true;
    iparams.lips_period = _lips_shift;
  }

  /**
   * Set MA method.
   */
  void SetMAMethod(ENUM_MA_METHOD _ma_method) {
    istate.is_changed = true;
    iparams.ma_method = _ma_method;
  }

  /**
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};

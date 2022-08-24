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

/**
 * @file
 * Gator Oscillator
 *
 * Note: It doesn't give independent signals. Is is used for Alligator correction.
 */

// Includes.
#include "../Indicator/Indicator.h"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iGator(string _symbol, int _tf, int _jp, int _js, int _tp, int _ts, int _lp, int _ls, int _ma_method, int _ap,
              int _mode, int _shift) {
  ResetLastError();
  return Indi_Gator::iGator(_symbol, (ENUM_TIMEFRAMES)_tf, _jp, _js, _tp, _ts, _lp, _ls, (ENUM_MA_METHOD)_ma_method,
                            (ENUM_APPLIED_PRICE)_ap, (ENUM_GATOR_HISTOGRAM)_mode, _shift);
}
#endif

#ifndef __MQLBUILD__
// Indicator constants.
// @docs
// - https://www.mql5.com/en/docs/constants/indicatorconstants/lines
// Identifiers of indicator lines permissible when copying values of iGator().
#define UPPER_HISTOGRAM 0  // Upper histogram.
#define LOWER_HISTOGRAM 2  // Bottom histogram.
#endif

// Indicator line identifiers used in Gator oscillator.
enum ENUM_GATOR_HISTOGRAM {
#ifdef __MQL4__
  LINE_UPPER_HISTCOLOR = 0,           // 0
  LINE_UPPER_HISTOGRAM = MODE_UPPER,  // 1
  LINE_LOWER_HISTOGRAM = MODE_LOWER,  // 2
  LINE_LOWER_HISTCOLOR,               // 3
#else
  LINE_UPPER_HISTOGRAM = UPPER_HISTOGRAM,  // 0
  LINE_UPPER_HISTCOLOR = 1,
  LINE_LOWER_HISTOGRAM = LOWER_HISTOGRAM,  // 2
  LINE_LOWER_HISTCOLOR = 3,
#endif
  FINAL_GATOR_LINE_HISTOGRAM_ENTRY
};

// Defines two colors used in Gator oscillator.
enum ENUM_GATOR_COLOR { GATOR_HISTCOLOR_GREEN = 0, GATOR_HISTCOLOR_RED = 1, FINAL_GATOR_HISTCOLOR_ENTRY };

// Structs.
struct IndiGatorParams : IndicatorParams {
  int jaw_period;                    // Jaw line averaging period.
  int jaw_shift;                     // Jaw line shift.
  int teeth_period;                  // Teeth line averaging period.
  int teeth_shift;                   // Teeth line shift.
  int lips_period;                   // Lips line averaging period.
  int lips_shift;                    // Lips line shift.
  ENUM_MA_METHOD ma_method;          // Averaging method.
  ENUM_APPLIED_PRICE applied_price;  // Applied price.
  // Struct constructors.
  IndiGatorParams(int _jp = 13, int _js = 8, int _tp = 8, int _ts = 5, int _lp = 5, int _ls = 3,
                  ENUM_MA_METHOD _mm = MODE_SMMA, ENUM_APPLIED_PRICE _ap = PRICE_MEDIAN, int _shift = 0)
      : jaw_period(_jp),
        jaw_shift(_js),
        teeth_period(_tp),
        teeth_shift(_ts),
        lips_period(_lp),
        lips_shift(_ls),
        ma_method(_mm),
        applied_price(_ap),
        IndicatorParams(INDI_GATOR) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\Gator");
  };
  IndiGatorParams(IndiGatorParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Gator oscillator.
 */
class Indi_Gator : public Indicator<IndiGatorParams> {
 protected:
  /* Protected methods */

  /**
   * Initialize.
   */
  void Init() { Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES), FINAL_GATOR_LINE_HISTOGRAM_ENTRY); }

 public:
  /**
   * Class constructor.
   */
  Indi_Gator(IndiGatorParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
             int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(FINAL_GATOR_LINE_HISTOGRAM_ENTRY, TYPE_DOUBLE, _idstype,
                                                   IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {
    Init();
  }
  Indi_Gator(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
             int _indi_src_mode = 0)
      : Indicator(IndiGatorParams(),
                  IndicatorDataParams::GetInstance(FINAL_GATOR_LINE_HISTOGRAM_ENTRY, TYPE_DOUBLE, _idstype,
                                                   IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {
    Init();
  }

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

 public:
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
   * _mode ENUM_GATOR_HISTOGRAM
   * - EA: LINE_UPPER_HISTOGRAM, LINE_UPPER_HISTCOLOR, LINE_LOWER_HISTOGRAM, LINE_LOWER_HISTCOLOR
   * - MT4: MODE_UPPER, MODE_LOWER
   * - MT5: 0 - UPPER_HISTOGRAM, 1 - color buffer (upper), 2 - LOWER_HISTOGRAM, 3 - color buffer (lower)
   *
   * @docs
   * - https://docs.mql4.com/indicators/igator
   * - https://www.mql5.com/en/docs/indicators/igator
   */
  static double iGator(string _symbol, ENUM_TIMEFRAMES _tf, int _jaw_period, int _jaw_shift, int _teeth_period,
                       int _teeth_shift, int _lips_period, int _lips_shift, ENUM_MA_METHOD _ma_method,
                       ENUM_APPLIED_PRICE _applied_price, ENUM_GATOR_HISTOGRAM _mode, int _shift = 0,
                       IndicatorData *_obj = NULL) {
#ifdef __MQL4__
    return ::iGator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift,
                    _ma_method, _applied_price, _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iGator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period,
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
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_Gator::iGator(GetSymbol(), GetTf(), GetJawPeriod(), GetJawShift(), GetTeethPeriod(),
                                    GetTeethShift(), GetLipsPeriod(), GetLipsShift(), GetMAMethod(), GetAppliedPrice(),
                                    (ENUM_GATOR_HISTOGRAM)_mode, _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /**/
                         GetJawPeriod(), GetJawShift(), GetTeethPeriod(), GetTeethShift(), GetLipsPeriod(),
                         GetLipsShift(), GetMAMethod(),
                         GetAppliedPrice()
                         /**/,
                         _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /**
   * Alters indicator's struct value.
   */
  void GetEntryAlter(IndicatorDataEntry &_entry, int _shift) override {
    Indicator<IndiGatorParams>::GetEntryAlter(_entry, _shift);
#ifdef __MQL4__
    // @todo: Can we calculate upper and lower histogram color in MT4?
    // @see: https://docs.mql4.com/indicators/igator
    // @see: https://www.mql5.com/en/docs/indicators/igator
    _entry.values[LINE_UPPER_HISTCOLOR] = (double)NULL;
    _entry.values[LINE_LOWER_HISTCOLOR] = (double)NULL;
#endif
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return !_entry.HasValue(EMPTY_VALUE) && (_entry.values[(int)LINE_UPPER_HISTOGRAM].GetDbl() != 0 ||
                                             _entry.values[(int)LINE_LOWER_HISTOGRAM].GetDbl() != 0);
  }

  /* Getters */

  /**
   * Get jaw period value.
   */
  unsigned int GetJawPeriod() { return iparams.jaw_period; }

  /**
   * Get jaw shift value.
   */
  unsigned int GetJawShift() { return iparams.jaw_shift; }

  /**
   * Get teeth period value.
   */
  unsigned int GetTeethPeriod() { return iparams.teeth_period; }

  /**
   * Get teeth shift value.
   */
  unsigned int GetTeethShift() { return iparams.teeth_shift; }

  /**
   * Get lips period value.
   */
  unsigned int GetLipsPeriod() { return iparams.lips_period; }

  /**
   * Get lips shift value.
   */
  unsigned int GetLipsShift() { return iparams.lips_shift; }

  /**
   * Get MA method.
   */
  ENUM_MA_METHOD GetMAMethod() { return iparams.ma_method; }

  /**
   * Get applied price value.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return iparams.applied_price; }

  /* Setters */

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

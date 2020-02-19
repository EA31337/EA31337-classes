//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
#include "../Indicator.mqh"

// Structs.
struct AlligatorEntry : IndicatorEntry {
  double value[FINAL_GATOR_LINE_ENTRY];
  string ToString() {
    return StringFormat("%g,%g,%g",
      value[LINE_JAW], value[LINE_TEETH], value[LINE_LIPS]);
  }
  bool IsValid() {
    double _min_value = fmin(fmin(value[LINE_JAW], value[LINE_TEETH]), value[LINE_LIPS]);
    double _max_value = fmax(fmax(value[LINE_JAW], value[LINE_TEETH]), value[LINE_LIPS]);
    return _min_value > 0 && _max_value != EMPTY_VALUE;
  }
};
struct Alligator_Params {
 unsigned int    jaw_period;       // Jaw line averaging period.
 unsigned int    jaw_shift;        // Jaw line shift.
 unsigned int    teeth_period;     // Teeth line averaging period.
 unsigned int    teeth_shift;      // Teeth line shift.
 unsigned int    lips_period;      // Lips line averaging period.
 unsigned int    lips_shift;       // Lips line shift.
 ENUM_MA_METHOD     ma_method; 	  // Averaging method.
 ENUM_APPLIED_PRICE applied_price; // Applied price.
 // Constructor.
 void Alligator_Params(unsigned int _jp, unsigned int _js, unsigned int _tp, unsigned int _ts, unsigned int _lp, unsigned int _ls, ENUM_MA_METHOD _mm, ENUM_APPLIED_PRICE _ap)
   : jaw_period(_jp), jaw_shift(_js),
     teeth_period(_tp), teeth_shift(_ts),
     lips_period(_lp), lips_shift(_ls),
     ma_method(_mm), applied_price(_ap) {};
};

/**
 * Implements the Alligator indicator.
 */
class Indi_Alligator : public Indicator {

 public:

  Alligator_Params params;

  /**
   * Class constructor.
   */
  Indi_Alligator(Alligator_Params &_p, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(
        _p.jaw_period, _p.jaw_shift,
        _p.teeth_period, _p.teeth_shift,
        _p.lips_period, _p.lips_shift,
        _p.ma_method, _p.applied_price
      ),
      Indicator(_iparams, _cparams) {};
  Indi_Alligator(Alligator_Params &_p, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(
        _p.jaw_period, _p.jaw_shift,
        _p.teeth_period, _p.teeth_shift,
        _p.lips_period, _p.lips_shift,
        _p.ma_method, _p.applied_price
      ),
      Indicator(INDI_ALLIGATOR, _tf) {};

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ialligator
   * - https://www.mql5.com/en/docs/indicators/ialligator
   */
  static double iAlligator(
    string _symbol,
    ENUM_TIMEFRAMES _tf,
    unsigned int _jaw_period,
    unsigned int _jaw_shift,
    unsigned int _teeth_period,
    unsigned int _teeth_shift,
    unsigned int _lips_period,
    unsigned int _lips_shift,
    ENUM_MA_METHOD _ma_method,         // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
    ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
    ENUM_GATOR_LINE _mode,             // (MT4 _mode): 1 - MODE_GATORJAW, 2 - MODE_GATORTEETH, 3 - MODE_GATORLIPS
    int _shift = 0,                    // (MT5 _mode): 0 - GATORJAW_LINE, 1 - GATORTEETH_LINE, 2 - GATORLIPS_LINE
    Indicator *_obj = NULL
      ) {
#ifdef __MQL4__
    return ::iAlligator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price, _mode, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iAlligator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift, _ma_method, _applied_price)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      }
      else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    int _bars_calc = BarsCalculated(_handle);
    if (_bars_calc < 2) {
      SetUserError(ERR_USER_INVALID_BUFF_NUM);
      return EMPTY_VALUE;
    }
    if (CopyBuffer(_handle, _mode, -_shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
    * Returns the indicator's value.
    */
  double GetValue(ENUM_GATOR_LINE _mode, int _shift = 0) {
    double _value = Indi_Alligator::iAlligator(GetSymbol(), GetTf(), GetJawPeriod(), GetJawShift(), GetTeethPeriod(), GetTeethShift(), GetLipsPeriod(), GetLipsShift(), GetMAMethod(), GetAppliedPrice(), _mode, _shift);
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

  /**
    * Returns the indicator's struct value.
    */
  AlligatorEntry GetEntry(int _shift = 0) {
    AlligatorEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value[LINE_JAW] = GetValue(LINE_JAW, _shift);
    _entry.value[LINE_TEETH] = GetValue(LINE_TEETH, _shift);
    _entry.value[LINE_LIPS] = GetValue(LINE_LIPS, _shift);
    if (_entry.IsValid()) { _entry.AddFlags(INDI_ENTRY_FLAG_IS_VALID); }
    return _entry;
  }

    /* Class getters */

    /**
     * Get jaw period value.
     */
    unsigned int GetJawPeriod() {
      return params.jaw_period;
    }

    /**
     * Get jaw shift value.
     */
    unsigned int GetJawShift() {
      return params.jaw_shift;
    }

    /**
     * Get teeth period value.
     */
    unsigned int GetTeethPeriod() {
      return params.teeth_period;
    }

    /**
     * Get teeth shift value.
     */
    unsigned int GetTeethShift() {
      return params.teeth_shift;
    }

    /**
     * Get lips period value.
     */
    unsigned int GetLipsPeriod() {
      return params.lips_period;
    }

    /**
     * Get lips shift value.
     */
    unsigned int GetLipsShift() {
      return params.lips_shift;
    }

    /**
     * Get MA method.
     */
    ENUM_MA_METHOD GetMAMethod() {
      return params.ma_method;
    }

    /**
     * Get applied price value.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return params.applied_price;
    }

    /* Class setters */

    /**
     * Set jaw period value.
     */
    void SetJawPeriod(unsigned int _jaw_period) {
      new_params = true;
      params.jaw_period = _jaw_period;
    }

    /**
     * Set jaw shift value.
     */
    void SetJawShift(unsigned int _jaw_shift) {
      new_params = true;
      params.jaw_shift = _jaw_shift;
    }

    /**
     * Set teeth period value.
     */
    void SetTeethPeriod(unsigned int _teeth_period) {
      new_params = true;
      params.teeth_period = _teeth_period;
    }

    /**
     * Set teeth shift value.
     */
    void SetTeethShift(unsigned int _teeth_shift) {
      new_params = true;
      params.teeth_period = _teeth_shift;
    }

    /**
     * Set lips period value.
     */
    void SetLipsPeriod(unsigned int _lips_period) {
      new_params = true;
      params.lips_period = _lips_period;
    }

    /**
     * Set lips shift value.
     */
    void SetLipsShift(unsigned int _lips_shift) {
      new_params = true;
      params.lips_period = _lips_shift;
    }

    /**
     * Set MA method.
     */
    void SetMAMethod(ENUM_MA_METHOD _ma_method) {
      new_params = true;
      params.ma_method = _ma_method;
    }

    /**
     * Set applied price value.
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      new_params = true;
      params.applied_price = _applied_price;
    }

};

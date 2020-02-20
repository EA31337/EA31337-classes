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
struct EnvelopesEntry : IndicatorEntry {
  double value[FINAL_LO_UP_LINE_ENTRY];
  string ToString(int _mode = EMPTY) {
    return StringFormat("%g,%g", value[LINE_LOWER], value[LINE_UPPER]);
  }
  bool IsValid() {
    double _min_value = fmin(value[LINE_LOWER], value[LINE_UPPER]);
    double _max_value = fmax(value[LINE_LOWER], value[LINE_UPPER]);
    return value[LINE_UPPER] > value[LINE_LOWER] && _min_value > 0 && _max_value != EMPTY_VALUE;
  }
};
struct Envelopes_Params : IndicatorParams {
  unsigned int ma_period;
  unsigned int ma_shift;
  ENUM_MA_METHOD ma_method;
  ENUM_APPLIED_PRICE applied_price;
  double deviation;
  // Constructor.
  void Envelopes_Params(unsigned int _ma_period, unsigned int _ma_shift, ENUM_MA_METHOD _ma_method, ENUM_APPLIED_PRICE _ap, double _deviation)
    : ma_period(_ma_period), ma_shift(_ma_shift), ma_method(_ma_method), applied_price(_ap), deviation(_deviation) {};
};

/**
 * Implements the Envelopes indicator.
 */
class Indi_Envelopes : public Indicator {

 protected:

  // Structs.
  Envelopes_Params params;

 public:

  /**
   * Class constructor.
   */
  Indi_Envelopes(Envelopes_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_params.ma_period, _params.ma_shift, _params.ma_method, _params.applied_price, _params.deviation),
      Indicator(_iparams, _cparams) { Init(); }
  Indi_Envelopes(Envelopes_Params &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_params.ma_period, _params.ma_shift, _params.ma_method, _params.applied_price, _params.deviation),
      Indicator(INDI_ENVELOPES, _tf) { Init(); }

  /**
   * Initialize parameters.
   */
  void Init() {
    iparams.SetDataType(TYPE_DOUBLE);
    iparams.SetMaxModes(FINAL_LO_UP_LINE_ENTRY);
  }

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/ienvelopes
     * - https://www.mql5.com/en/docs/indicators/ienvelopes
     */
    static double iEnvelopes(
      string _symbol,
      ENUM_TIMEFRAMES _tf,
      unsigned int _ma_period,
      ENUM_MA_METHOD _ma_method,         // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
      int _ma_shift,
      ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
      double _deviation,
      int _mode,                         // (MT4 _mode): 0 - MODE_MAIN,  1 - MODE_UPPER, 2 - MODE_LOWER; (MT5 _mode): 0 - UPPER_LINE, 1 - LOWER_LINE
      int _shift = 0,
      Indicator *_obj = NULL
      )
    {
      ResetLastError();
#ifdef __MQL4__
      return ::iEnvelopes(_symbol, _tf, _ma_period, _ma_method, _ma_shift, _applied_price, _deviation, _mode, _shift);
#else // __MQL5__
      int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
      double _res[];
      if (_handle == NULL || _handle == INVALID_HANDLE) {
        if ((_handle = ::iEnvelopes(_symbol, _tf, _ma_period, _ma_shift, _ma_method, _applied_price, _deviation)) == INVALID_HANDLE) {
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
  double GetValue(ENUM_LO_UP_LINE _mode, int _shift = 0) {
    istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
    double _value = Indi_Envelopes::iEnvelopes(GetSymbol(), GetTf(), GetMAPeriod(), GetMAMethod(), GetMAShift(), GetAppliedPrice(), GetDeviation(), _mode, _shift, GetPointer(this));
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
    * Returns the indicator's struct value.
    */
  EnvelopesEntry GetEntry(int _shift = 0) {
    EnvelopesEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value[LINE_LOWER] = GetValue(LINE_LOWER);
    _entry.value[LINE_UPPER] = GetValue(LINE_UPPER);
    if (_entry.IsValid()) { _entry.AddFlags(INDI_ENTRY_FLAG_IS_VALID); }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value[_mode];
    return _param;
  }

    /* Getters */

    /**
     * Get MA period value.
     */
    unsigned int GetMAPeriod() {
      return params.ma_period;
    }

    /**
     * Set MA method.
     */
    ENUM_MA_METHOD GetMAMethod() {
      return params.ma_method;
    }

    /**
     * Get MA shift value.
     */
    unsigned int GetMAShift() {
      return params.ma_shift;
    }

    /**
     * Get applied price value.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return params.applied_price;
    }

    /**
     * Get deviation value.
     */
    double GetDeviation() {
      return params.deviation;
    }

    /* Setters */

    /**
     * Set MA period value.
     */
    void SetMAPeriod(unsigned int _ma_period) {
      istate.is_changed = true;
      params.ma_period = _ma_period;
    }

    /**
     * Set MA method.
     */
    void SetMAMethod(ENUM_MA_METHOD _ma_method) {
      istate.is_changed = true;
      params.ma_method = _ma_method;
    }

    /**
     * Set MA shift value.
     */
    void SetMAShift(int _ma_shift) {
      istate.is_changed = true;
      params.ma_shift = _ma_shift;
    }

    /**
     * Set applied price value.
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      istate.is_changed = true;
      params.applied_price = _applied_price;
    }

    /**
     * Set deviation value.
     */
    void SetDeviation(double _deviation) {
      istate.is_changed = true;
      params.deviation = _deviation;
    }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0, int _mode = EMPTY) {
    return GetEntry(_shift).ToString(_mode);
  }

};

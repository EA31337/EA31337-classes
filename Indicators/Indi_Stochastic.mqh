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
struct StochEntry : IndicatorEntry {
  double value[FINAL_SIGNAL_LINE_ENTRY];
  string ToString() {
    return StringFormat("%g,%g",
      value[LINE_MAIN], value[LINE_SIGNAL]);
  }
};
struct Stoch_Params {
  unsigned int kperiod;
  unsigned int dperiod;
  unsigned int slowing;
  ENUM_MA_METHOD ma_method;
  ENUM_STO_PRICE price_field;
  // Constructor.
  void Stoch_Params(unsigned int _kperiod, unsigned int _dperiod, unsigned int _slowing, ENUM_MA_METHOD _ma_method, ENUM_STO_PRICE _pf)
    : kperiod(_kperiod), dperiod(_dperiod), slowing(_slowing), ma_method(_ma_method), price_field(_pf) {};
};

/**
 * Implements the Stochastic Oscillator.
 */
class Indi_Stochastic : public Indicator {

 protected:

  Stoch_Params params;

 public:

  /**
   * Class constructor.
   */
  Indi_Stochastic(Stoch_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_params.kperiod, _params.dperiod, _params.slowing, _params.ma_method, _params.price_field),
      Indicator(_iparams, _cparams) {};
  Indi_Stochastic(Stoch_Params &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_params.kperiod, _params.dperiod, _params.slowing, _params.ma_method, _params.price_field),
      Indicator(INDI_STOCHASTIC, _tf) {};

  /**
    * Calculates the Stochastic Oscillator and returns its value.
    *
    * @docs
    * - https://docs.mql4.com/indicators/istochastic
    * - https://www.mql5.com/en/docs/indicators/istochastic
    */
  static double iStochastic(
    string _symbol,
    ENUM_TIMEFRAMES _tf,
    unsigned int _kperiod,
    unsigned int _dperiod,
    unsigned int _slowing,
    ENUM_MA_METHOD _ma_method,    // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
    ENUM_STO_PRICE _price_field,  // (MT4 _price_field):      0      - Low/High,       1        - Close/Close
                                  // (MT5 _price_field): STO_LOWHIGH - Low/High, STO_CLOSECLOSE - Close/Close
    int _mode,                    // (MT4): 0 - MODE_MAIN/MAIN_LINE, 1 - MODE_SIGNAL/SIGNAL_LINE
    int _shift = 0,
    Indicator *_obj = NULL
    )
  {
#ifdef __MQL4__
    return ::iStochastic(_symbol, _tf, _kperiod, _dperiod, _slowing, _ma_method, _price_field, _mode, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iStochastic(_symbol, _tf, _kperiod, _dperiod, _slowing, _ma_method, _price_field)) == INVALID_HANDLE) {
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
  double GetValue(ENUM_SIGNAL_LINE _mode = LINE_MAIN, int _shift = 0) {
    double _value = Indi_Stochastic::iStochastic(GetSymbol(), GetTf(), GetKPeriod(), GetDPeriod(), GetSlowing(), GetMAMethod(), GetPriceField(), _mode, _shift);
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  StochEntry GetEntry(int _shift = 0) {
    StochEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value[LINE_MAIN] = GetValue(LINE_MAIN, _shift);
    _entry.value[LINE_SIGNAL] = GetValue(LINE_SIGNAL, _shift);
    return _entry;
  }

    /* Getters */

    /**
     * Get period of the %K line.
     */
    unsigned int GetKPeriod() {
      return params.kperiod;
    }

    /**
     * Get period of the %D line.
     */
    unsigned int GetDPeriod() {
      return params.dperiod;
    }

    /**
     * Get slowing value.
     */
    unsigned int GetSlowing() {
      return params.slowing;
    }

    /**
     * Set MA method.
     */
    ENUM_MA_METHOD GetMAMethod() {
      return params.ma_method;
    }

    /**
     * Get price field parameter.
     */
    ENUM_STO_PRICE GetPriceField() {
      return params.price_field;
    }

    /* Setters */

    /**
     * Set period of the %K line.
     */
    void SetKPeriod(unsigned int _kperiod) {
      new_params = true;
      params.kperiod = _kperiod;
    }

    /**
     * Set period of the %D line.
     */
    void SetDPeriod(unsigned int _dperiod) {
      new_params = true;
      params.dperiod = _dperiod;
    }

    /**
     * Set slowing value.
     */
    void SetSlowing(unsigned int _slowing) {
      new_params = true;
      params.slowing = _slowing;
    }

    /**
     * Set MA method.
     */
    void SetMAMethod(ENUM_MA_METHOD _ma_method) {
      new_params = true;
      params.ma_method = _ma_method;
    }

    /**
     * Set price field parameter.
     */
    void SetPriceField(ENUM_STO_PRICE _price_field) {
      new_params = true;
      params.price_field = _price_field;
    }

};

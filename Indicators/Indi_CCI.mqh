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
struct CCIEntry : IndicatorEntry {
  double value;
  string ToString(int _mode = EMPTY) {
    return StringFormat("%g", value);
  }
  bool IsValid() { return value != WRONG_VALUE && value != EMPTY_VALUE; }
};
struct CCI_Params : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;
  // Constructor.
  void CCI_Params(unsigned int _period, ENUM_APPLIED_PRICE _applied_price)
    : period(_period), applied_price(_applied_price) {};
};

/**
 * Implements the Commodity Channel Index indicator.
 */
class Indi_CCI : public Indicator {

 public:

  CCI_Params params;

  /**
   * Class constructor.
   */
  Indi_CCI(CCI_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_params.period, _params.applied_price), Indicator(_iparams, _cparams) { Init(); }
  Indi_CCI(CCI_Params &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_params.period, _params.applied_price), Indicator(INDI_CCI, _tf) { Init(); }

  /**
   * Initialize parameters.
   */
  void Init() {
    iparams.SetDataType(TYPE_DOUBLE);
    iparams.SetMaxModes(1);
  }

  /**
    * Returns the indicator value.
    *
    * @docs
    * - https://docs.mql4.com/indicators/icci
    * - https://www.mql5.com/en/docs/indicators/icci
    */
  static double iCCI(
    string _symbol,
    ENUM_TIMEFRAMES _tf,
    unsigned int _period,
    ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
    int _shift = 0,
    Indicator *_obj = NULL
    )
  {
#ifdef __MQL4__
    return ::iCCI(_symbol, _tf, _period, _applied_price, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iCCI(_symbol, _tf, _period, _applied_price)) == INVALID_HANDLE) {
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
    if (CopyBuffer(_handle, 0, -_shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    double _value = Indi_CCI::iCCI(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _shift);
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.new_params = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  CCIEntry GetEntry(int _shift = 0) {
    CCIEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value = GetValue(_shift);
    if (_entry.IsValid()) { _entry.AddFlags(INDI_ENTRY_FLAG_IS_VALID); }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value;
    return _param;
  }

    /* Getters */

    /**
     * Get period value.
     */
    unsigned int GetPeriod() {
      return params.period;
    }

    /**
     * Get applied price value.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return params.applied_price;
    }

    /* Setters */

    /**
     * Set period value.
     */
    void SetPeriod(unsigned int _period) {
      istate.new_params = true;
      params.period = _period;
    }

    /**
     * Set applied price value.
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      istate.new_params = true;
      params.applied_price = _applied_price;
    }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0, int _mode = EMPTY) {
    return GetEntry(_shift).ToString(_mode);
  }

};

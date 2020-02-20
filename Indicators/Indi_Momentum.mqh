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
struct MomentumEntry : IndicatorEntry {
  double value;
  string ToString(int _mode = EMPTY) {
    return StringFormat("%g", value);
  }
  bool IsValid() { return value != WRONG_VALUE && value != EMPTY_VALUE; }
};
struct Momentum_Params : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;
  // Constructor.
  void Momentum_Params(unsigned int _period, ENUM_APPLIED_PRICE _ap)
    : period(_period), applied_price(_ap) {};
};

/**
 * Implements the Momentum indicator.
 */
class Indi_Momentum : public Indicator {

 protected:

  Momentum_Params params;

 public:

  /**
   * Class constructor.
   */
  Indi_Momentum(Momentum_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_params.period, _params.applied_price), Indicator(_iparams, _cparams) { Init(); }
  Indi_Momentum(Momentum_Params &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_params.period, _params.applied_price), Indicator(INDI_MOMENTUM, _tf) { Init(); }

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
    * - https://docs.mql4.com/indicators/imomentum
    * - https://www.mql5.com/en/docs/indicators/imomentum
    */
  static double iMomentum(
    string _symbol,
    ENUM_TIMEFRAMES _tf,
    unsigned int _period,
    ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
    int _shift = 0,
    Indicator *_obj = NULL
    )
  {
#ifdef __MQL4__
    return ::iMomentum(_symbol, _tf, _period, _applied_price, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iMomentum(_symbol, _tf, _period, _applied_price)) == INVALID_HANDLE) {
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
    double _value = Indi_Momentum::iMomentum(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _shift);
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.new_params = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  MomentumEntry GetEntry(int _shift = 0) {
    MomentumEntry _entry;
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
     *
     * Averaging period (bars count) for the calculation of the price change.
     */
    unsigned int GetPeriod() {
      return params.period;
    }

    /**
     * Get applied price value.
     *
     * The desired price base for calculations.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return params.applied_price;
    }

    /* Setters */

    /**
     * Set period value.
     *
     * Averaging period (bars count) for the calculation of the price change.
     */
    void SetPeriod(unsigned int _period) {
      istate.new_params = true;
      params.period = _period;
    }

    /**
     * Set applied price value.
     *
     * The desired price base for calculations.
     * @docs
     * - https://docs.mql4.com/constants/indicatorconstants/prices#enum_applied_price_enum
     * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
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

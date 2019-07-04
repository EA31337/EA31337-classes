//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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

// Properties.
#property strict

// Includes.
#include "../Indicator.mqh"

/**
 * Implements the Stochastic Oscillator.
 */
class Indi_Stochastic : public Indicator {

  // Structs.
  struct Stoch_Params {
    uint kperiod;
    uint dperiod;
    uint slowing;
    ENUM_MA_METHOD ma_method;
    ENUM_STO_PRICE price_field;
    // Constructor.
    void Stoch_Params(uint _kperiod, uint _dperiod, uint _slowing, ENUM_MA_METHOD _ma_method, ENUM_STO_PRICE _pf)
      : kperiod(_kperiod), dperiod(_dperiod), slowing(_slowing), ma_method(_ma_method), price_field(_pf) {};
  } params;

  public:

    /**
     * Class constructor.
     */
    void Indi_Stochastic(Stoch_Params &_params, IndicatorParams &_iparams, Chart *_chart = NULL)
      : params(_params.kperiod, _params.dperiod, _params.slowing, _params.ma_method, _params.price_field),
        Indicator(_iparams, _chart) {};

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
      uint _kperiod,
      uint _dperiod,
      uint _slowing,
      ENUM_MA_METHOD _ma_method,    // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
      ENUM_STO_PRICE _price_field,  // (MT4 _price_field):      0      - Low/High,       1        - Close/Close
                                    // (MT5 _price_field): STO_LOWHIGH - Low/High, STO_CLOSECLOSE - Close/Close
      uint _mode,                   // (MT4): 0 - MODE_MAIN/MAIN_LINE, 1 - MODE_SIGNAL/SIGNAL_LINE
      uint _shift = 0
      )
    {
      #ifdef __MQL4__
      return ::iStochastic(_symbol, _tf, _kperiod, _dperiod, _slowing, _ma_method, _price_field, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iStochastic(_symbol, _tf, _kperiod, _dperiod, _slowing, _ma_method, _price_field);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(uint _mode = LINE_MAIN, uint _shift = 0) {
       double _value = this.iStochastic(GetSymbol(), GetTf(), GetKPeriod(), GetDPeriod(), GetSlowing(), GetMAMethod(), GetPriceField(), _mode, _shift);
       CheckLastError();
       return _value;
    }

    /* Getters */

    /**
     * Get period of the %K line.
     */
    uint GetKPeriod() {
      return this.params.kperiod;
    }

    /**
     * Get period of the %D line.
     */
    uint GetDPeriod() {
      return this.params.dperiod;
    }

    /**
     * Get slowing value.
     */
    uint GetSlowing() {
      return this.params.slowing;
    }

    /**
     * Set MA method.
     */
    ENUM_MA_METHOD GetMAMethod() {
      return this.params.ma_method;
    }

    /**
     * Get price field parameter.
     */
    ENUM_STO_PRICE GetPriceField() {
      return this.params.price_field;
    }

    /* Setters */

    /**
     * Set period of the %K line.
     */
    void SetKPeriod(uint _kperiod) {
      this.params.kperiod = _kperiod;
    }

    /**
     * Set period of the %D line.
     */
    void SetDPeriod(uint _dperiod) {
      this.params.dperiod = _dperiod;
    }

    /**
     * Set slowing value.
     */
    void SetSlowing(uint _slowing) {
      this.params.slowing = _slowing;
    }

    /**
     * Set MA method.
     */
    void SetMAMethod(ENUM_MA_METHOD _ma_method) {
      this.params.ma_method = _ma_method;
    }

    /**
     * Set price field parameter.
     */
    void SetPriceField(ENUM_STO_PRICE _price_field) {
      this.params.price_field = _price_field;
    }

};

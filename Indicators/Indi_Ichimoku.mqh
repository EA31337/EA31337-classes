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

// Ichimoku Kinko Hyo identifiers used in Ichimoku indicator.
enum ENUM_ICHIMOKU_LINE {
  LINE_TENKANSEN   = #ifdef __MQL4__ MODE_TENKANSEN   #else TENKANSEN_LINE   #endif, // Tenkan-sen line.
  LINE_KIJUNSEN    = #ifdef __MQL4__ MODE_KIJUNSEN    #else KIJUNSEN_LINE    #endif, // Kijun-sen line.
  LINE_SENKOUSPANA = #ifdef __MQL4__ MODE_SENKOUSPANA #else SENKOUSPANA_LINE #endif, // Senkou Span A line.
  LINE_SENKOUSPANB = #ifdef __MQL4__ MODE_SENKOUSPANB #else SENKOUSPANB_LINE #endif, // Senkou Span B line.
  LINE_CHIKOUSPAN  = #ifdef __MQL4__ MODE_CHIKOUSPAN  #else CHIKOUSPAN_LINE  #endif, // Chikou Span line.
  FINAL_ICHIMOKU_LINE_ENTRY,
};

/**
 * Implements the Ichimoku Kinko Hyo indicator.
 */
class Indi_Ichimoku : public Indicator {

  // Structs.
  struct Ichimoku_Params {
    uint tenkan_sen;
    uint kijun_sen;
    uint senkou_span_b;
    // Constructor.
    void Ichimoku_Params(uint _ts, uint _ks, uint _ss_b)
      : tenkan_sen(_ts), kijun_sen(_ks), senkou_span_b(_ss_b) {};
  } params;

  public:

    /**
     * Class constructor.
     */
    void Indi_Ichimoku(Ichimoku_Params &_params, IndicatorParams &_iparams, Chart *_chart = NULL)
      : params(_params.tenkan_sen, _params.kijun_sen, _params.senkou_span_b),
        Indicator(_iparams, _chart) {};

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iichimoku
     * - https://www.mql5.com/en/docs/indicators/iichimoku
     */
    static double iIchimoku(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        int _tenkan_sen,
        int _kijun_sen,
        int _senkou_span_b,
        int _mode,             // (MT4 _mode): 1 - MODE_TENKANSEN, 2 - MODE_KIJUNSEN, 3 - MODE_SENKOUSPANA, 4 - MODE_SENKOUSPANB, 5 - MODE_CHIKOUSPAN
        int _shift = 0         // (MT5 _mode): 0 - TENKANSEN_LINE, 1 - KIJUNSEN_LINE, 2 - SENKOUSPANA_LINE, 3 - SENKOUSPANB_LINE, 4 - CHIKOUSPAN_LINE
        ) {
      #ifdef __MQL4__
      return ::iIchimoku(_symbol, _tf, _tenkan_sen, _kijun_sen, _senkou_span_b, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iIchimoku(_symbol, _tf, _tenkan_sen, _kijun_sen, _senkou_span_b);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(ENUM_ICHIMOKU_LINE _mode, uint _shift = 0) {
       double _value = this.iIchimoku(GetSymbol(), GetTf(), GetTenkanSen(), GetKijunSen(), GetSenkouSpanB(), _mode, _shift);
       CheckLastError();
       return _value;
    }

    /* Getters */

    /**
     * Get period of Tenkan-sen line.
     */
    uint GetTenkanSen() {
      return this.params.tenkan_sen;
    }

    /**
     * Get period of Kijun-sen line.
     */
    uint GetKijunSen() {
      return this.params.kijun_sen;
    }

    /**
     * Get period of Senkou Span B line.
     */
    uint GetSenkouSpanB() {
      return this.params.senkou_span_b;
    }

    /* Setters */

    /**
     * Set period of Tenkan-sen line.
     */
    void SetTenkanSen(uint _tenkan_sen) {
      this.params.tenkan_sen = _tenkan_sen;
    }

    /**
     * Set period of Kijun-sen line.
     */
    void SetKijunSen(uint _kijun_sen) {
      this.params.kijun_sen = _kijun_sen;
    }

    /**
     * Set period of Senkou Span B line.
     */
    void SetSenkouSpanB(uint _senkou_span_b) {
      this.params.senkou_span_b = _senkou_span_b;
    }

};

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

// Includes.
#include "../Indicator.mqh"

// Ichimoku Kinko Hyo identifiers used in Ichimoku indicator.
enum ENUM_ICHIMOKU_LINE {
#ifdef __MQL4__ 
  LINE_TENKANSEN   = MODE_TENKANSEN,   // Tenkan-sen line.
  LINE_KIJUNSEN    = MODE_KIJUNSEN,    // Kijun-sen line.
  LINE_SENKOUSPANA = MODE_SENKOUSPANA, // Senkou Span A line.
  LINE_SENKOUSPANB = MODE_SENKOUSPANB, // Senkou Span B line.
  LINE_CHIKOUSPAN  = MODE_CHIKOUSPAN,  // Chikou Span line.
#else
  LINE_TENKANSEN   = TENKANSEN_LINE,   // Tenkan-sen line.
  LINE_KIJUNSEN    = KIJUNSEN_LINE,    // Kijun-sen line.
  LINE_SENKOUSPANA = SENKOUSPANA_LINE, // Senkou Span A line.
  LINE_SENKOUSPANB = SENKOUSPANB_LINE, // Senkou Span B line.
  LINE_CHIKOUSPAN  = CHIKOUSPAN_LINE,  // Chikou Span line.
#endif
  FINAL_ICHIMOKU_LINE_ENTRY,
};

// Structs.
struct Ichimoku_Params {
  unsigned int tenkan_sen;
  unsigned int kijun_sen;
  unsigned int senkou_span_b;
  // Constructor.
  void Ichimoku_Params(unsigned int _ts, unsigned int _ks, unsigned int _ss_b)
    : tenkan_sen(_ts), kijun_sen(_ks), senkou_span_b(_ss_b) {};
};

/**
 * Implements the Ichimoku Kinko Hyo indicator.
 */
class Indi_Ichimoku : public Indicator {

public:

    Ichimoku_Params params;

    /**
     * Class constructor.
     */
    Indi_Ichimoku(Ichimoku_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
      : params(_params.tenkan_sen, _params.kijun_sen, _params.senkou_span_b),
        Indicator(_iparams, _cparams) {};

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
    double GetValue(ENUM_ICHIMOKU_LINE _mode, int _shift = 0) {
       double _value = iIchimoku(GetSymbol(), GetTf(), GetTenkanSen(), GetKijunSen(), GetSenkouSpanB(), _mode, _shift);
       CheckLastError();
       return _value;
    }

    /* Getters */

    /**
     * Get period of Tenkan-sen line.
     */
    unsigned int GetTenkanSen() {
      return this.params.tenkan_sen;
    }

    /**
     * Get period of Kijun-sen line.
     */
    unsigned int GetKijunSen() {
      return this.params.kijun_sen;
    }

    /**
     * Get period of Senkou Span B line.
     */
    unsigned int GetSenkouSpanB() {
      return this.params.senkou_span_b;
    }

    /* Setters */

    /**
     * Set period of Tenkan-sen line.
     */
    void SetTenkanSen(unsigned int _tenkan_sen) {
      new_params = true;
      this.params.tenkan_sen = _tenkan_sen;
    }

    /**
     * Set period of Kijun-sen line.
     */
    void SetKijunSen(unsigned int _kijun_sen) {
      new_params = true;
      this.params.kijun_sen = _kijun_sen;
    }

    /**
     * Set period of Senkou Span B line.
     */
    void SetSenkouSpanB(unsigned int _senkou_span_b) {
      new_params = true;
      this.params.senkou_span_b = _senkou_span_b;
    }

};

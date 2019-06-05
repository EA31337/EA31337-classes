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
 * Class to deal with indicators.
 */
class Indi_Ichimoku : public Indicator {

  // Structs.
  struct IndicatorParams {
    double foo;
  };

  // Struct variables.
  IndicatorParams params;

  public:

    /**
     * Class constructor.
     */
    void Indi_Ichimoku(IndicatorParams &_params, ENUM_TIMEFRAMES _tf = NULL, string _symbol = NULL) {
      this.params = _params;
    }
    void Indi_Ichimoku()
    {
    }

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
    double iIchimoku(
        int _tenkan_sen,
        int _kijun_sen,
        int _senkou_span_b,
        int _mode,
        int _shift = 0) {
       double _value = iIchimoku(GetSymbol(), GetTf(), _tenkan_sen, _kijun_sen, _senkou_span_b, _mode, _shift);
       CheckLastError();
       return _value;
    }

};

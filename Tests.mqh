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

// Includes.
#include "Indicator/Indicator.h"
#include "Market.mqh"

/**
 * Class to provide various tests.
 */
class Tests {
 public:
  /**
   * Test Bands indicator values.
   */
  static bool TestBands(bool _print = true, string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    bool correct, result = true;
    double _bands[3] = {};
    int _periods[5] = {1, 5, 15, 30, 60};
    int _modes[3] = {BAND_LOWER, BAND_BASE, BAND_UPPER};
    Chart *_chart = new Chart(_tf, _symbol);
    unsigned int _digits = _chart.GetDigits();
    double _bid = _chart.GetBid();
    double _ask = _chart.GetAsk();
    double _open = _chart.GetOpen();
    double _close = _chart.GetClose();

    if (_print) {
      Print(__FUNCTION__ + "(): Testing values for Bands indicator...");
      PrintFormat("Symbol            : %s", _symbol != NULL ? _symbol : _Symbol);
      PrintFormat("Current timeframe : %d", _tf);
      PrintFormat("Bid/Ask           : %g/%g", NormalizeDouble(_bid, _digits), NormalizeDouble(_ask, _digits));
      PrintFormat("Close/Open        : %g/%g", NormalizeDouble(_close, _digits), NormalizeDouble(_open, _digits));
    }
    for (int p = 0; p < ArraySize(_periods); p++) {
      for (int m = 0; m < ArraySize(_modes); m++) {
#ifdef __MQL4__
        _bands[m] = iBands(_symbol, _periods[p], 20, 2.0, 0, 0, _modes[m], 0);
#else
        // @fixme: Convert to use Indicator class, so it works in both MQL4 and MQL5.
        _bands[m] = 0.0;
#endif
      }
      correct = (_bands[0] > 0 && _bands[1] > 0 && _bands[2] > 0 && _bands[0] < _bands[1] && _bands[1] < _bands[2]);
      if (_print)
        PrintFormat("Bands M%d          : %g/%g/%g => %s", _periods[p], _bands[0], _bands[1], _bands[2],
                    correct ? "CORRECT" : "INCORRECT");
      result &= correct;
    }
    if (_print) Print(result ? "Bands values are correct!" : "Error: Bands values are not correct!");
    return result;
  }

  /**
   * Test all market values.
   */
  static bool TestAllMarket(bool print = true) {
    bool result = true;
    if (print) Print(__FUNCTION__ + "(): Testing market values...");
    result &= TestBands(print);
    return result;
  }
};

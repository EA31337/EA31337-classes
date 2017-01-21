//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

/**
 * Class to provide various tests.
 */
class Tests {
public:

  /**
   * Test Bands indicator values.
   */
  static bool TestBands(bool print = true) {
    double _bands[3] = {};
    int _periods[5] = { 1, 5, 15, 30, 60 };
    int _modes[3] = { MODE_LOWER, MODE_MAIN, MODE_UPPER };
    bool correct, result = true;

    if (print) {
      Print(__FUNCTION__ + "(): Testing values for Bands indicator...");
      PrintFormat("Symbol            : %s", _Symbol);
      PrintFormat("Current timeframe : %d", PERIOD_CURRENT);
      PrintFormat("Bid/Ask           : %g/%g", NormalizeDouble(Bid, Digits), NormalizeDouble(Ask, Digits));
      PrintFormat("Close/Open        : %g/%g", NormalizeDouble(Close[0], Digits), NormalizeDouble(Open[0], Digits));
    }
    for (int p = 0; p < ArraySize(_periods); p++) {
      for (int m = 0; m < ArraySize(_modes); m++) {
        _bands[m] = iBands(_Symbol, _periods[p], 20, 2.0, 0, 0, _modes[m], 0);
      }
      correct = (_bands[0] > 0 && _bands[1] > 0 && _bands[2] > 0 && _bands[0] < _bands[1] && _bands[1] < _bands[2]);
      if (print) PrintFormat("Bands M%d          : %g/%g/%g => %s", _periods[p], _bands[0], _bands[1], _bands[2], correct ? "CORRECT" : "INCORRECT");
      result &= correct;
    }
    if (print) Print(result ? "Bands values are correct!" : "Error: Bands values are not correct!");
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

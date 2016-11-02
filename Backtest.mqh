//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
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

/*
 * Class to provide functions to deal with backtesting.
 */
class Backtest {
public:

    /**
     * Check whether spread is valid.
     */
    static bool ValidSpread(bool verbose = True) {
#ifdef __MQL4__
        long symbol_spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
        int real_spread = (int)MathRound((Ask - Bid) * MathPow(10, Digits));
        double lot_step = MarketInfo(_Symbol, MODE_LOTSTEP);
#else
        // @todo
#endif
        if (real_spread == 0 || symbol_spread != real_spread) {
            if (verbose) {
                PrintFormat("Reported spread: %d pts", symbol_spread);
                PrintFormat("Real spread    : %d pts", real_spread);
                PrintFormat("Ask/Bid        : %g/%g", NormalizeDouble(Ask, Digits), NormalizeDouble(Bid, Digits));
                PrintFormat("Symbol digits  : %g", Digits);
                PrintFormat("Lot step       : %g", lot_step);
                PrintFormat("Error: Spread is not valid, it's %d!", real_spread);
            }
            return (FALSE);
        }
        return (TRUE);
    }


    /**
     * Check whether lot step is valid.
     */
    static bool ValidLotstep(bool verbose = True) {
#ifdef __MQL4__
        long symbol_spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
        int real_spread = (int)MathRound((Ask - Bid) * MathPow(10, Digits));
        double lot_step = MarketInfo(_Symbol, MODE_LOTSTEP);
#else
        // @todo
#endif
        switch (Digits) {
            case 4:
                if (lot_step != 0.1) {
                    if (verbose) {
                        PrintFormat("Symbol digits  : %g", Digits);
                        PrintFormat("Lot step       : %g", lot_step);
                        PrintFormat("Error: Expected lot step for %d digits: 0.1, found: %g", Digits, lot_step);
                    }
                    return (FALSE);
                }
                break;
            case 5:
                if (lot_step != 0.01) {
                    if (verbose) {
                        PrintFormat("Symbol digits  : %g", Digits);
                        PrintFormat("Lot step       : %g", lot_step);
                        PrintFormat("Error: Expected lot step for %d digits: 0.01, found: %g", Digits, lot_step);
                    }
                    return (FALSE);
                }
                break;
        }
        return (TRUE);
    }

  /**
   * Calculate modelling quality.
   *
   * @see:
   * - https://www.mql5.com/en/articles/1486
   * - https://www.mql5.com/en/articles/1513
   */
  static double CalculateModellingQuality(int TimePr = NULL) {

    int nBarsInM1     = 0;
    int nBarsInPr     = 0;
    int nBarsInNearPr = 0;
    int TimeNearPr = PERIOD_M1;
    double ModellingQuality = 0;
    long   StartGen     = 0;
    long   StartBar     = 0;
    long   StartGenM1   = 0;
    long   HistoryTotal = 0;
    datetime modeling_start_time =  D'1971.01.01 00:00';

    if (TimePr == NULL)       TimePr     = Period();
    if (TimePr == PERIOD_M1)  TimeNearPr = PERIOD_M1;
    if (TimePr == PERIOD_M5)  TimeNearPr = PERIOD_M1;
    if (TimePr == PERIOD_M15) TimeNearPr = PERIOD_M5;
    if (TimePr == PERIOD_M30) TimeNearPr = PERIOD_M15;
    if (TimePr == PERIOD_H1)  TimeNearPr = PERIOD_M30;
    if (TimePr == PERIOD_H4)  TimeNearPr = PERIOD_H1;
    if (TimePr == PERIOD_D1)  TimeNearPr = PERIOD_H4;
    if (TimePr == PERIOD_W1)  TimeNearPr = PERIOD_D1;
    if (TimePr == PERIOD_MN1) TimeNearPr = PERIOD_W1;

    // 1 minute.
    double nBars = fmin(iBars(NULL,TimePr) * TimePr, iBars(NULL,PERIOD_M1));
    for (int i = 0; i < nBars;i++) {
      if (iOpen(NULL,PERIOD_M1, i) >= 0.000001) {
        if (iTime(NULL, PERIOD_M1, i) >= modeling_start_time)
        {
          nBarsInM1++;
        }
      }
    }

    // Nearest time.
    nBars = iBars(NULL,TimePr);
    for (int i = 0; i < nBars;i++) {
      if (iOpen(NULL,TimePr, i) >= 0.000001) {
        if (iTime(NULL, TimePr, i) >= modeling_start_time)
          nBarsInPr++;
      }
    }

    // Period time.
    nBars = fmin(iBars(NULL, TimePr) * TimePr/TimeNearPr, iBars(NULL, TimeNearPr));
    for (int i = 0; i < nBars;i++) {
      if (iOpen(NULL, TimeNearPr, i) >= 0.000001) {
        if (iTime(NULL, TimeNearPr, i) >= modeling_start_time)
          nBarsInNearPr++;
      }
    }

    HistoryTotal   = nBarsInPr;
    nBarsInM1      = nBarsInM1 / TimePr;
    nBarsInNearPr  = nBarsInNearPr * TimeNearPr / TimePr;
    StartGenM1     = HistoryTotal - nBarsInM1;
    StartBar       = HistoryTotal - nBarsInPr;
    StartBar       = 0;
    StartGen       = HistoryTotal - nBarsInNearPr;

    if(TimePr == PERIOD_M1) {
      StartGenM1 = HistoryTotal;
      StartGen   = StartGenM1;
    }
    if((HistoryTotal - StartBar) != 0) {
      ModellingQuality = ((0.25 * (StartGen-StartBar) +
            0.5 * (StartGenM1 - StartGen) +
            0.9 * (HistoryTotal - StartGenM1)) / (HistoryTotal - StartBar)) * 100;
    }
    return (ModellingQuality);
  }

};

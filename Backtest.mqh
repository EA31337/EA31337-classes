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

    /*
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
        if (verbose) Print("Spread is valid.");
        return (TRUE);
    }


    /*
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
                if (lot_step != 0.1 && lot_step != 0.0) {
                    if (verbose) {
                        PrintFormat("Symbol digits  : %g", Digits);
                        PrintFormat("Lot step       : %g", lot_step);
                        PrintFormat("Error: Expected lot step for %d digits: 0.1, found: %g", Digits, lot_step);
                    }
                    return (FALSE);
                }
                break;
            case 5:
                if (lot_step != 0.01 && lot_step != 0.0) {
                    if (verbose) {
                        PrintFormat("Symbol digits  : %g", Digits);
                        PrintFormat("Lot step       : %g", lot_step);
                        PrintFormat("Error: Expected lot step for %d digits: 0.01, found: %g", Digits, lot_step);
                    }
                    return (FALSE);
                }
                break;
        }
        if (verbose) Print("Lot step is valid.");
        return (TRUE);
    }

};

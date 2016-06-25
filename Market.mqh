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
 * Class to provide market information.
 */
class Market {
public:

    double pip_size; // Value of pip size.
    int pip_digits;  // Number of digits for a pip.
    int pts_per_pip; // Number of points per pip.
    double volume_precision;

    /**
     * Implements class constructor with a parameter.
     */
    Market(string symbol) {
      pip_size = GetPipSize();
      pip_digits = GetPipDigits();
      pts_per_pip = GetPointsPerPip();
    }

    /**
     * Return pip size.
     */
    static double GetPipSize() {
      int digits = (int) MarketInfo(_Symbol, MODE_DIGITS);
      switch (digits) {
        case 0:
        case 1:
          return 1.0;
        case 2:
        case 3:
          return 0.01;
        case 4:
        case 5:
        default:
          return 0.0001;
      }
    }

    /**
     * Get pip precision.
     */
    static int GetPipDigits() {
      return (_Digits < 4 ? 2 : 4);
    }

    /**
     * Get current spread in float.
     */
    static double GetSpreadInPips() {
      return Ask - Bid;
    }

    /**
     * Get current spread in points.
     */
    static int GetSpreadInPts() {
      return SymbolInfoInteger(Symbol(), SYMBOL_SPREAD);
    }

    /**
     * Get current spread in percent.
     */
    static double GetSpreadInPct() {
      return 100.0 * (Ask - Bid) / Ask;
    }

    /**
     * Get number of points per pip.
     * To be used to replace Point for trade parameters calculations.
     * See: http://forum.mql4.com/30672
     */
    static double GetPointsPerPip() {
      return MathPow(10, Digits - GetPipDigits());
    }

    /**
     * Get a lot step.
     */
    static double GetLotstep() {
      return fmax(MarketInfo(_Symbol, MODE_LOTSTEP), 10 >> GetPipDigits());
    }

    /**
     * Get a volume precision.
     */
    static double GetVolumeDigits(bool micro_lots) {
      return (int) -log10(fmin(GetLotstep(), MarketInfo(_Symbol, MODE_MINLOT)));
      return MathLog(GetLotstep()) / MathLog(0.1);
    }

    /**
     * Get current open price depending on the operation type.
     * @param:
     *   op_type int Order operation type of the order.
     * @return
     * Current open price.
     */
    static double GetOpenPrice(int op_type = EMPTY_VALUE) {
      if (op_type == EMPTY_VALUE) op_type = OrderType();
      return op_type == OP_BUY ? Ask : Bid;
    }

    /**
     * Get current close price depending on the operation type.
     * @param:
     *   op_type int Order operation type of the order.
     * @return
     * Current close price.
     */
    static double GetClosePrice(int op_type = EMPTY_VALUE) {
      if (op_type == EMPTY_VALUE) op_type = OrderType();
      return op_type == OP_BUY ? Bid : Ask;
    }

    /**
     * Check whether we're trading within market peak hours.
     */
    bool IsPeakHour() {
        int hour;
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeCurrent(dt);
        hour = dt.hour;
        #else
        hour = Hour();
        #endif
        return hour >= 8 && hour <= 16;
    }

};

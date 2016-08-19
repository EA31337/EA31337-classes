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

// Includes.
#include "Market.mqh"

// Define type of periods.
enum ENUM_PERIOD_TYPE {
  M1  = 0, // 1 minute
  M5  = 1, // 5 minutes
  M15 = 2, // 15 minutes
  M30 = 3, // 30 minutes
  H1  = 4, // 1 hour
  H4  = 5, // 4 hours
  D1  = 6, // Daily
  W1  = 7, // Weekly
  MN1 = 8, // Monthly
  FINAL_PERIOD_TYPE_ENTRY = 9 // Should be the last one. Used to calculate the number of enum items.
};

/*
 * Class to provide conversion methods.
 */
class Convert {
public:

    /*
     * Convert period to proper chart timeframe value.
     */
    static int IndexToTf(int period) {
        int tf = PERIOD_M30;
        switch (period) {
            case M1: // 1 minute
                tf = PERIOD_M1;
                break;
            case M5: // 5 minutes
                tf = PERIOD_M5;
                break;
            case M15: // 15 minutes
                tf = PERIOD_M15;
                break;
            case M30: // 30 minutes
                tf = PERIOD_M30;
                break;
            case H1: // 1 hour
                tf = PERIOD_H1;
                break;
            case H4: // 4 hours
                tf = PERIOD_H4;
                break;
            case D1: // daily
                tf = PERIOD_D1;
                break;
            case W1: // weekly
                tf = PERIOD_W1;
                break;
            case MN1: // monthly
                tf = PERIOD_MN1;
                break;
        }
        return tf;
    }

    /*
     * Convert timeframe constant to period value.
     */
    static int TfToIndex(int tf) {
        int period = M30;
        switch (tf) {
            case PERIOD_M1: // 1 minute
                period = M1;
                break;
            case PERIOD_M5: // 5 minutes
                period = M5;
                break;
            case PERIOD_M15: // 15 minutes
                period = M15;
                break;
            case PERIOD_M30: // 30 minutes
                period = M30;
                break;
            case PERIOD_H1: // 1 hour
                period = H1;
                break;
            case PERIOD_H4: // 4 hours
                period = H4;
                break;
            case PERIOD_D1: // daily
                period = D1;
                break;
            case PERIOD_W1: // weekly
                period = W1;
                break;
            case PERIOD_MN1: // monthly
                period = MN1;
                break;
        }
        return period;
    }

    /*
     * Returns OrderType as a text.
     * @param
     *   op_type int Order operation type of the order.
     * @return
     *   Return text representation of the order.
     */
    static string OrderTypeToString(int op_type) {
        switch (op_type) {
            case OP_BUY:          return("Buy");
            case OP_SELL:         return("Sell");
            case OP_BUYLIMIT:     return("BuyLimit");
            case OP_BUYSTOP:      return("BuyStop");
            case OP_SELLLIMIT:    return("SellLimit");
            case OP_SELLSTOP:     return("SellStop");
            default:              return("UnknownOrderType");
        }
    }

    /*
     * Returns OrderType as a value.
     * @param
     *   op_type int Order operation type of the order.
     * @return
     *   Return 1 for buy, -1 for sell orders.
     */
    static int OrderTypeToValue(int op_type) {
        switch (op_type) {
            case OP_SELL:
            case OP_SELLLIMIT:
            case OP_SELLSTOP:
                return -1;
                break;
            case OP_BUY:
            case OP_BUYLIMIT:
            case OP_BUYSTOP:
                return 1;
                break;
            default:
                return FALSE;
        }
    }

    /*
     * Return opposite trade of command operation.
     *
     * @param
     *   cmd int Trade command operation.
     */
    static int OrderTypeOpp(int cmd) {
        if (cmd == OP_BUY) return OP_SELL;
        if (cmd == OP_SELL) return OP_BUY;
        return EMPTY;
    }

    /*
     * Convert value into pips.
     */
    static double ValueToPips(double value) {
        return value * MathPow(10, Market::GetPipDigits());
    }

    /*
     * Convert pips into points.
     */
    static double PipsToPoints(double pips) {
        return pips * Market::GetPointsPerPip();
    }

    /*
     * Convert points into pips.
     */
    static double PointsToPips(int points) {
        return points / Market::GetPointsPerPip();
    }

    /*
     * Get the difference between two price values (in pips).
     */
    static double GetPipDiff(double price1, double price2, bool abs = False) {
        double diff = abs ? fabs(price1 - price2) : (price1 - price2);
        return Convert::ValueToPips(diff);
    }

    /*
     * Add currency sign to the plain value.
     */
    static string ValueToCurrency(double value, int digits = 2) {
        ushort sign; bool prefix = TRUE;
        string currency = AccountCurrency();
        if (currency == "USD") sign = "$";
        else if (currency == "GBP") sign = "£";
        else if (currency == "EUR") sign = "€";
        else { sign = currency; prefix = FALSE; }
        return prefix ? CharToString(sign) + DoubleToStr(value, digits) : DoubleToStr(value, digits) + CharToString(sign);
    }

};

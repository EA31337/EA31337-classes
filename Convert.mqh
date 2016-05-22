//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * @file Convert.mqh
 * Class to provide conversion methods.
 */

class Convert {
public:

    /*
     * Convert period to proper chart timeframe value.
     */
    static int PeriodToTf(int period) {
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
    static int TfToPeriod(int tf) {
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
    static double GetPipDiff(double price1, double price2, bool abs = false) {
        double diff = Misc::If(abs, MathAbs(price1 - price2), price1 - price2);
        return Convert::ValueToPips(diff);
    }

    /*
     * Add currency sign to the plain value.
     */
    /*
    static string ValueToCurrency(double value, int digits = 2) {
        ushort sign; bool prefix = TRUE;
        string currency = AccountCurrency();
        if (currency == "USD") sign = '$';
        else if (currency == "GBP") sign = '£';
        else if (currency == "EUR") sign = '';
        else { sign = currency; prefix = FALSE; }
        return Misc::If(prefix, CharToString(sign) + DoubleToStr(value, digits), DoubleToStr(value, digits) + CharToString(sign));
    }
    */

};

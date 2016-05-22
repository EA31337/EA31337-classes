//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * @file Market.mqh
 * Class to provide market information.
 */

class Market {
public:

    double pip_size; // Value of pip size.
    int pip_digits;  // Number of digits for a pip.
    int pts_per_pip; // Number of points per pip.
    double volume_precision;

    /*
     * Implements class constructor with a parameter.
     */
    Market(string symbol) {
        pip_size = GetPipSize();
        pip_digits = GetPipDigits();
        pts_per_pip = GetPointsPerPip();
    }

    /*
     * Return pip size.
     */
    static double GetPipSize() {
        if (Digits < 4) {
            return 0.01;
        } else {
            return 0.0001;
        }
    }

    /*
     * Get pip precision.
     */
    static double GetPipDigits() {
        if (Digits < 4) {
            return 2;
        } else {
            return 4;
        }
    }

    /*
     * Get number of points per pip.
     * To be used to replace Point for trade parameters calculations.
     * See: http://forum.mql4.com/30672
     */
    static double GetPointsPerPip() {
        return MathPow(10, Digits - GetPipDigits());
    }

    /*
     * Get a volume precision.
     */
    static double GetVolumePrecision(bool micro_lots) {
        if (micro_lots) return 2;
        else return 1;
    }

    /*
     * Get current open price depending on the operation type.
     * @param:
     *   op_type int Order operation type of the order.
     * @return
     * Current open price.
     */
    static double GetOpenPrice(int op_type = EMPTY_VALUE) {
        if (op_type == EMPTY_VALUE) op_type = OrderType();
        return Misc::If(op_type == OP_BUY, Ask, Bid);
    }

    /*
     * Get current close price depending on the operation type.
     * @param:
     *   op_type int Order operation type of the order.
     * @return
     * Current close price.
     */
    static double GetClosePrice(int op_type = EMPTY_VALUE) {
        if (op_type == EMPTY_VALUE) op_type = OrderType();
        return Misc::If(op_type == OP_BUY, Bid, Ask);
    }

};

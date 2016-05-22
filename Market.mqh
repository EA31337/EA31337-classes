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

};

//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * @file Misc.mqh
 * Class to provide basic useful miscellaneous methods.
 */

class Misc {
public:

    /*
     * Return integer depending on the condition.
     */
    static int If(bool condition, int on_true, int on_false) {
        // if condition is TRUE, return on_true, otherwise on_false
        if (condition) return (on_true);
        else return (on_false);
    }

    /*
     * Return double depending on the condition.
     */
    static double If(bool condition, double on_true, double on_false) {
        // if condition is TRUE, return on_true, otherwise on_false
        if (condition) return (on_true);
        else return (on_false);
    }

    /*
     * Return string depending on the condition.
     */
    static string If(bool condition, string on_true, string on_false) {
        // if condition is TRUE, return on_true, otherwise on_false
        if (condition) return (on_true);
        else return (on_false);
    }

};

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

/*
 * Class to provide basic useful miscellaneous methods.
 */
class Misc {
public:

    /*
     * Return integer depending on the condition.
     */
    static int If(bool condition, int on_true, int on_false) {
        // if condition is true, return on_true, otherwise on_false
        if (condition) return (on_true);
        else return (on_false);
    }

    /*
     * Return double depending on the condition.
     */
    static double If(bool condition, double on_true, double on_false) {
        // if condition is true, return on_true, otherwise on_false
        if (condition) return (on_true);
        else return (on_false);
    }

    /*
     * Return string depending on the condition.
     */
    static string If(bool condition, string on_true, string on_false) {
        // if condition is true, return on_true, otherwise on_false
        if (condition) return (on_true);
        else return (on_false);
    }

};

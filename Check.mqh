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
 * Class to provide functions that return parameters of the current state of the client terminal.
 */
class Check {
public:

    /**
     * Checks if the Expert Advisor runs in the testing mode.
     */
    static bool IsTesting() {
#ifdef __MQL4__
        return ::IsTesting();
#else
        return (MQL5InfoInteger(MQL5_TESTER));
#endif
    }

    /**
     * Checks if Expert Advisor runs in the Strategy Tester optimization mode.
     */
    static bool IsOptimization() {
#ifdef __MQL4__
        return ::IsOptimization();
#else
        return (MQL5InfoInteger(MQL5_OPTIMIZATION));
#endif
    }

    /**
     * Checks if the Expert Advisor is tested in visual mode.
     */
    static bool IsVisualMode() {
#ifdef __MQL4__
        return ::IsVisualMode();
#else
        return (MQL5InfoInteger(MQL5_VISUAL_MODE));
#endif
    }

    /**
     * Checks if the Expert Advisor is tested for real time mode
     * outside of the Strategy Tester.
     */
    static bool IsRealtime() {
        if (!IsTesting() && !IsOptimization() && !IsVisualMode()) {
            return (True);
        } else {
            return (False);
        }
    }

/* @todo
GetLastError
IsStopped
UninitializeReason
MQLInfoInteger
MQLInfoString
MQLSetInteger
TerminalInfoInteger
TerminalInfoDouble
TerminalInfoString
Symbol
Period
Digits
Point
IsConnected
IsDemo
IsDllsAllowed
IsExpertEnabled
IsLibrariesAllowed
IsTradeAllowed
IsTradeContextBusy
TerminalCompany
TerminalName
TerminalPath
*/

};

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
#include "Strings.mqh"

// Properties.
#property strict

/*
 * Class to provide report handling methods.
 */
class Report {
public:

    // Used for writing the report file.
    string log[];

    /*
     * Add message into the report file.
     */
    void ReportAdd(string msg) {
      int last = ArraySize(log);
      ArrayResize(log, last + 1);
      log[last] = TimeToStr(time_current,TIME_DATE|TIME_SECONDS) + ": " + msg;
    }

    /*
     * Write report data into file.
     */
    static void WriteReport(string filename, string data, bool verbose = False) {
        int handle = FileOpen(filename, FILE_CSV|FILE_WRITE, '\t');
        if (handle < 1) return;

        FileWrite(handle, data);
        FileClose(handle);

        if (verbose) {
            Strings::PrintText(data);
        }
    }

};

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

// Properties.
#property strict

/**
 * Class to provide methods storing ticks.
 */
class Ticks {
public:
    struct tick {
      datetime timestamp;
      double bid, ask;
      long vol;
    };
    int index;
    tick tarr[];
    string filepath;

    /**
     * Class constructor.
     */
    void Ticks(int size = 1000) {
      index = 0;
      ArrayResize(tarr, size, size);
      filepath = StringFormat("ticks_%s.csv", TimeToStr(TimeCurrent(), TIME_DATE));
    }

    /**
     * Append a new tick.
     */
    bool AddTick() {
      if (index++ >= ArraySize(tarr) - 1) {
        if (ArrayResize(tarr, index + 100, 1000) < 0) {
          return false;
        }
      }
      tarr[index].timestamp = TimeCurrent();
      tarr[index].bid       = MarketInfo(NULL, MODE_BID);
      tarr[index].ask       = MarketInfo(NULL, MODE_ASK);
#ifdef __MQL5__
      // @fixme
      long Volume[];
      ArraySetAsSeries(Volume, true);
      CopyTickVolume(NULL, 0, 0, 1, tarr[index].vol);
#else
      tarr[index].vol       = Volume[0];
#endif
      return true;
    }

    /**
     * Store a tick.
     */
    void OnTick() {
      AddTick();
    }

    /**
     * Save ticks into CSV file.
     */
    bool SaveToCSV(string filename = NULL, bool verbose = true) {
      ResetLastError();
      filename = filename != NULL ? filename : filepath;
      int _handle = FileOpen(filename, FILE_WRITE|FILE_CSV, ",");
      if (_handle != INVALID_HANDLE) {
        FileWrite(_handle, "Datatime", "Bid", "Ask", "Volume");
        for (int i = 0; i < index; i++) {
          if (tarr[i].timestamp > 0) {
            FileWrite(_handle,
              TimeToStr(tarr[i].timestamp, TIME_DATE|TIME_MINUTES|TIME_SECONDS),
              tarr[i].bid,
              tarr[i].ask,
              tarr[i].vol);
          }
        }
        FileClose(_handle);
        if (verbose) {
          PrintFormat("%s: %d ticks written to '%s' file.", __FUNCTION__, index, filename);
        }
        return true;
      } else {
        if (verbose) {
          PrintFormat("%s: Cannot open file for writting, error: %s", __FUNCTION__, GetLastError());
        }
        return false;
      }
    }

};

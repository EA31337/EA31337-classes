//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2018, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

// Includes.
#include "Chart.mqh"
#include "DateTime.mqh"
#include "Market.mqh"

/**
 * Class to provide methods handling ticks.
 */
class Ticker {

  // Structs.
  struct TTick {
    datetime timestamp;
    double bid, ask;
    double vol;
  };

  protected:
    string symbol;
    ulong total_added, total_ignored, total_processed, total_saved;

  public:

    // Struct variables.
    TTick data[];
    // Class variables.
    Market *market;
    Log *logger;
    // Public variables.
    int index;

    /**
     * Class constructor.
     */
    void Ticker(Market *_market = NULL, int size = 1000) :
      market(CheckPointer(_market) != POINTER_INVALID ? _market : new Market),
      logger(market.Log()),
      total_added(0),
      total_ignored(0),
      total_processed(0),
      total_saved(0) {
        index = 0;
        ArrayResize(data, size, size);
        symbol = CheckPointer(market) != POINTER_INVALID ? market.GetSymbol() : _Symbol;
    }

    /**
     * Class deconstructor.
     */
    void ~Ticker() {
      delete logger;
      delete market;
    }

    /* Getters */

    /**
     * Get number of added ticks.
     */
    ulong GetTotalAdded() {
      return total_added;
    }


    /**
     * Get number of ignored ticks.
     */
    ulong GetTotalIgnored() {
      return total_ignored;
    }

    /**
     * Get number of parsed ticks.
     */
    ulong GetTotalProcessed() {
      return total_processed;
    }


    /**
     * Get number of saved ticks.
     */
    ulong GetTotalSaved() {
      return total_saved;
    }

    /* Other methods */

    /**
     * Processes tick.
     *
     * @param
     * _method Ignore method (0-15).
     * _tf Timeframe to use.
     * @return
     * Returns true when tick should be parsed, otherwise ignored.
     */
    bool Process(uint _method, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
      total_processed++;
      if (_method == 0) {
        return true;
      }
      bool _res = false;
      double _last_bid = market.GetLastBid();
      double _bid = market.GetBid();
      if ((_method % 1) == 0) _res &= (_last_bid != _bid);
      if ((_method % 2) == 0) _res &= (Chart::iOpen(symbol, _tf) == _bid);
      if ((_method % 4) == 0) _res &= (Chart::iTime(symbol, _tf) != TimeCurrent());
      if ((_method % 8) == 0) _res &= (Chart::iLow(symbol, _tf) == _bid || Chart::iHigh(symbol, _tf) == _bid);
      if (!_res) {
        total_ignored++;
      }
      return _res;
    }

    /**
     * Append a new tick to an array.
     */
    bool Add() {
      if (index++ >= ArraySize(data) - 1) {
        if (ArrayResize(data, index + 100, 1000) < 0) {
          logger.Error(StringFormat("Cannot resize array (index: %d)!", index), __FUNCTION__);
          return false;
        }
      }
      data[index].timestamp = TimeCurrent();
      data[index].bid       = market.GetBid();
      data[index].ask       = market.GetAsk();
      data[index].vol       = market.GetSessionVolume();
      total_added++;
      return true;
    }

    /**
     * Empties the tick array.
     */
    void Reset() {
      total_added = 0;
      index = 0;
    }

    /**
     * Save ticks into CSV file.
     */
    bool SaveToCSV(string filename = NULL, bool verbose = true) {
      ResetLastError();
      filename = filename != NULL ? filename : StringFormat("ticks_%s.csv", DateTime::TimeToStr(TimeCurrent(), TIME_DATE));
      int _handle = FileOpen(filename, FILE_WRITE|FILE_CSV, ",");
      if (_handle != INVALID_HANDLE) {
        total_saved = 0;
        FileWrite(_handle, "Datatime", "Bid", "Ask", "Volume");
        for (int i = 0; i < index; i++) {
          if (data[i].timestamp > 0) {
            FileWrite(_handle,
                DateTime::TimeToStr(data[i].timestamp, TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                data[i].bid,
                data[i].ask,
                data[i].vol);
            total_saved++;
          }
        }
        FileClose(_handle);
        if (verbose) {
          PrintFormat("%s: %d ticks written to '%s' file.", __FUNCTION__, index, filename);
        }
        return true;
      }
      else {
        if (verbose) {
          PrintFormat("%s: Cannot open file for writting, error: %s", __FUNCTION__, GetLastError());
        }
        return false;
      }
    }

  /**
   * Returns textual representation of the Market class.
   */
  string ToString() {
    return StringFormat(
      "Processed: %d; Ignored: %d; Added: %d; Saved: %d;",
      GetTotalProcessed(),
      GetTotalIgnored(),
      GetTotalAdded(),
      GetTotalSaved()
    );
  }

};

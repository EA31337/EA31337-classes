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

// Properties.
#property strict

// Includes.
#include "Market.mqh"

/**
 * @file
 * Class to provide chart operations.
 *
 * @docs
 * - https://docs.mql4.com/chart_operations/chartredraw
 * - https://www.mql5.com/en/docs/chart_operations
 */

class Chart {
protected:
  // Variables.
  string symbol;
  ENUM_TIMEFRAMES tf;
  // Class variables.
  Market *market;

public:

  /**
   * Class constructor.
   */
  void Chart(int timeframe, string _symbol = NULL, ENUM_TIMEFRAMES _tf = NULL) :
    symbol(_symbol != NULL ? _symbol : _Symbol),
    tf(_tf != NULL ? _tf : PERIOD_CURRENT),
    market(new Market(symbol))
  {
  }

  /**
   * Draw MA on chart.
   */
  /*
  bool DrawMA(int _ma_fast, int _ma_medium, int _ma_slow, ENUM_MA_METHOD _method, ENUM_APPLIED_PRICE _applied) {
    int Counter = 1;
    int shift = market.iBarShift(symbol, tf, TimeCurrent());
    while (Counter < Bars) {
      string itime = TimeToStr(market.iTime(NULL, tf, Counter));

      // FIXME: The shift parameter (Counter, Counter-1) doesn't use the real values of MA_Fast, MA_Medium and MA_Slow including MA_Shift_Fast, etc.
      double MA_Fast_Curr = iMA(symbol, tf, _ma_fast, 0, _method, _applied, Counter); // Current Bar.
      double MA_Fast_Prev = iMA(symbol, tf, _ma_fast, 0, _method, _applied, Counter-1); // Previous Bar.
      ObjectCreate("MA_Fast" + itime, OBJ_TREND, 0, iTime(symbol,0,Counter), MA_Fast_Curr, market.iTime(symbol,0,Counter-1), MA_Fast_Prev);
      ObjectSet("MA_Fast" + itime, OBJPROP_RAY, false);
      ObjectSet("MA_Fast" + itime, OBJPROP_COLOR, Yellow);

      double MA_Medium_Curr = iMA(symbol, tf, _ma_medium, 0, _method, _applied, Counter); // Current Bar.
      double MA_Medium_Prev = iMA(symbol, tf, _ma_medium, 0, _method, _applied, Counter-1); // Previous Bar.
      ObjectCreate("MA_Medium" + itime, OBJ_TREND, 0, iTime(symbol,0,Counter), MA_Medium_Curr, market.iTime(symbol,0,Counter-1), MA_Medium_Prev);
      ObjectSet("MA_Medium" + itime, OBJPROP_RAY, false);
      ObjectSet("MA_Medium" + itime, OBJPROP_COLOR, Gold);

      double MA_Slow_Curr = iMA(symbol, tf, _ma_slow, 0, _method, _applied, Counter); // Current Bar.
      double MA_Slow_Prev = iMA(symbol, tf, _ma_slow, 0, _method, _applied, Counter-1); // Previous Bar.
      ObjectCreate("MA_Slow" + itime, OBJ_TREND, 0, iTime(symbol,0,Counter), MA_Slow_Curr, market.iTime(symbol,0,Counter-1), MA_Slow_Prev);
      ObjectSet("MA_Slow" + itime, OBJPROP_RAY, false);
      ObjectSet("MA_Slow" + itime, OBJPROP_COLOR, Orange);
      Counter++;
    }
    return true;
  }
  */

    /*
     * Draw a vertical line.
     */
    bool DrawVLine(string oname, datetime tm) {
      bool result = ObjectCreate(NULL, oname, OBJ_VLINE, 0, tm, 0);
      if (!result) PrintFormat("%(): Can't create vertical line! code #", __FUNCTION__, GetLastError());
      return (result);
    }

    /*
     * Draw a horizontal line.
     */
    bool DrawHLine(string oname, double value) {
      bool result = ObjectCreate(NULL, oname, OBJ_HLINE, 0, 0, value);
      if (!result) PrintFormat("%(): Can't create horizontal line! code #", __FUNCTION__, GetLastError());
      return (result);
    }

    /*
     * Delete a vertical line.
     */
    bool DeleteVertLine(string oname) {
      bool result = ObjectDelete(NULL, oname);
      if (!result) PrintFormat("%(): Can't delete vertical line! code #", __FUNCTION__, GetLastError());
      return (result);
    }

  /**
   * Redraws the current chart forcedly.
   */
  void ChartRedraw() {
    #ifdef __MQL4__ WindowRedraw(); #else ChartRedraw(0); #endif
  }

};
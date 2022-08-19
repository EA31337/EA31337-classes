//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/**
 * @file
 * Class to provide chart, timeframe and timeseries operations.
 *
 * @docs
 * - https://www.mql5.com/en/docs/chart_operations
 * - https://www.mql5.com/en/docs/series
 */

// Prevents processing this includes file for the second time.
#ifndef CHART_MQH
#define CHART_MQH

// Includes.
#include "Chart.define.h"
#include "Chart.enum.h"
#include "Chart.struct.h"
#include "Chart.struct.serialize.h"
#include "Convert.mqh"
#include "Market.mqh"
#include "Serializer/Serializer.h"
#include "Task/TaskCondition.enum.h"

// Forward class declaration.
class Chart;
class Market;

#ifndef __MQL4__
// Defines structs (for MQL4 backward compatibility).
// Struct arrays that contains given values of each bar of the current chart.
// For MQL4 backward compatibility.
// @docs: https://docs.mql4.com/predefined
#include "ChartMt.h"
ChartBarTime Time;
ChartPriceClose Close;
ChartPriceHigh High;
ChartPriceLow Low;
ChartPriceOpen Open;
#endif

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compatibility).
int iBarShift(string _symbol, int _tf, datetime _time, bool _exact = false) {
  return ChartStatic::iBarShift(_symbol, (ENUM_TIMEFRAMES)_tf, _time, _exact);
}
double iClose(string _symbol, int _tf, int _shift) {
  return ChartStatic::iClose(_symbol, (ENUM_TIMEFRAMES)_tf, _shift);
}
#endif

#ifndef __MQL__
struct MqlRates {
  datetime time;     // Period start time
  double open;       // Open price
  double high;       // The highest price of the period
  double low;        // The lowest price of the period
  double close;      // Close price
  long tick_volume;  // Tick volume
  int spread;        // Spread
  long real_volume;  // Trade volume
};
#endif

/**
 * Class to provide chart, timeframe and timeseries operations.
 */
class Chart : public Market {
 protected:
  // Structs.
  ARRAY(ChartEntry, chart_saves);
  ChartParams cparams;

  // Stores information about the prices, volumes and spread.
  ARRAY(MqlRates, rates);
  ChartEntry c_entry;

  // Stores indicator instances.
  // @todo
  // Dict<long, Indicator> indis;

  // Variables.
  datetime last_bar_time;

  // Current tick index (incremented every OnTick()).
  int tick_index;

  // Current bar index (incremented every OnTick() if IsNewBar() is true).
  int bar_index;

 public:
  /* State checking */

  /**
   * Sets a flag hiding indicators.
   *
   * After the Expert Advisor has been tested and the appropriate chart opened, the flagged indicators will not be drawn
   * in the testing chart. Every indicator called will first be flagged with the current hiding flag. It must be noted
   * that only those indicators can be drawn in the testing chart that are directly called from the expert under test.
   *
   * @param
   * _hide bool Flag for hiding indicators when testing. Set true to hide created indicators, otherwise false.
   */
  static void HideTestIndicators(bool _hide = false) {
#ifdef __MQL4__
    ::HideTestIndicators(_hide);
#else  // __MQL5__
    ::TesterHideIndicators(_hide);
#endif
  }

  /* Calculation methods */

  /* Setters */

  /**
   * Sets a chart parameter value.
   */
  template <typename T>
  void Set(ENUM_CHART_PARAM _param, T _value) {
    cparams.Set<T>(_param, _value);
  }

  /**
   * Sets chart entry.
   */
  void SetEntry(ChartEntry &_entry) { c_entry = _entry; }

  /* Chart operations */

  /**
   * Redraws the current chart forcedly.
   *
   * @see:
   * https://docs.mql4.com/chart_operations/chartredraw
   */
  static void WindowRedraw() {
#ifdef __MQLBUILD__
#ifdef __MQL4__
    ::WindowRedraw();
#else
    ::ChartRedraw(0);
#endif
#else  // C++
    printf("@todo: %s\n", "WindowRedraw()");
#endif
  }

  /* Getters */

  /**
   * Gets chart entry.
   */
  ChartEntry GetEntry() const { return c_entry; }

  /* Conditions */

  /* Printer methods */

  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
};

#endif

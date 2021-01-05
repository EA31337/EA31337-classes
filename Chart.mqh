//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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

// Class dependencies.
class Chart;
class Market;

// Prevents processing this includes file for the second time.
#ifndef CHART_MQH
#define CHART_MQH

// Includes.
#include "Chart.enum.h"
#include "Chart.struct.h"
#include "Condition.enum.h"
#include "Convert.mqh"
#include "Market.mqh"
#include "Serializer.mqh"

#ifndef __MQL4__
// Defines structs (for MQL4 backward compatibility).
// Struct arrays that contains given values of each bar of the current chart.
// For MQL4 backward compatibility.
// @docs: https://docs.mql4.com/predefined
ChartBarTime Time;
ChartPriceClose Close;
ChartPriceHigh High;
ChartPriceLow Low;
ChartPriceOpen Open;
#endif

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compatibility).
int iBarShift(string _symbol, int _tf, datetime _time, bool _exact = false) {
  return Chart::iBarShift(_symbol, (ENUM_TIMEFRAMES)_tf, _time, _exact);
}
double iClose(string _symbol, int _tf, int _shift) { return Chart::iClose(_symbol, (ENUM_TIMEFRAMES)_tf, _shift); }
#endif

// Define type of periods.
// @see: https://docs.mql4.com/constants/chartconstants/enum_timeframes
#define TFS 21
const ENUM_TIMEFRAMES TIMEFRAMES_LIST[TFS] = {PERIOD_M1,  PERIOD_M2,  PERIOD_M3,  PERIOD_M4,  PERIOD_M5,  PERIOD_M6,
                                              PERIOD_M10, PERIOD_M12, PERIOD_M15, PERIOD_M20, PERIOD_M30, PERIOD_H1,
                                              PERIOD_H2,  PERIOD_H3,  PERIOD_H4,  PERIOD_H6,  PERIOD_H8,  PERIOD_H12,
                                              PERIOD_D1,  PERIOD_W1,  PERIOD_MN1};

/**
 * Class to provide chart, timeframe and timeseries operations.
 */
class Chart : public Market {
 protected:
  // Structs.
  ChartEntry chart_saves[];
  ChartParams cparams;

  // Stores information about the prices, volumes and spread.
  MqlRates rates[];
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
  /**
   * Class constructor.
   */
  void Chart(ChartParams &_cparams, string _symbol = NULL)
      : cparams(_cparams.tf), Market(_symbol), last_bar_time(GetBarTime()), tick_index(-1), bar_index(-1) {
    // Save the first BarOHLC values.
    SaveChartEntry();
  }
  void Chart(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, string _symbol = NULL)
      : cparams(_tf), Market(_symbol), last_bar_time(GetBarTime()), tick_index(-1), bar_index(-1) {
    // Save the first BarOHLC values.
    SaveChartEntry();
  }
  Chart(ENUM_TIMEFRAMES_INDEX _tfi, string _symbol = NULL)
      : cparams(_tfi), Market(_symbol), last_bar_time(GetBarTime()), tick_index(-1), bar_index(-1) {
    // Save the first BarOHLC values.
    SaveChartEntry();
  }

  /**
   * Class constructor.
   */
  ~Chart() {}

  /* Getters */

  /**
   * Get Chart ID.
   */
  long GetId() { return ChartID(); }

  /**
   * Get the current timeframe.
   */
  ENUM_TIMEFRAMES GetTf() { return cparams.tf; }

  /**
   * Gets chart entry.
   */
  static ChartEntry GetEntry(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, unsigned int _shift = 0, string _symbol = NULL) {
    datetime _time = Chart::iTime(_symbol, _tf, _shift);
    ChartEntry _chart_entry;
    if (_time > 0) {
      float _open = (float)Chart::iOpen(_symbol, _tf, _shift);
      float _high = (float)Chart::iHigh(_symbol, _tf, _shift);
      float _low = (float)Chart::iLow(_symbol, _tf, _shift);
      float _close = (float)Chart::iClose(_symbol, _tf, _shift);
      BarOHLC _ohlc(_open, _high, _low, _close, _time);
      BarEntry _bar_entry(_ohlc);
      _chart_entry.SetBar(_bar_entry);
    }
    return _chart_entry;
  }
  ChartEntry GetEntry(unsigned int _shift = 0) {
    datetime _time = GetBarTime(_shift);
    ChartEntry _chart_entry;
    if (_time > 0) {
      // @todo: Adds caching.
      float _open = (float)GetOpen(_shift);
      float _high = (float)GetHigh(_shift);
      float _low = (float)GetLow(_shift);
      float _close = (float)GetClose(_shift);
      BarOHLC _ohlc(_open, _high, _low, _close, _time);
      BarEntry _bar_entry(_ohlc);
      _chart_entry.SetBar(_bar_entry);
    }
    return _chart_entry;
  }

  /* Convert methods */

  /**
   * Convert period to proper chart timeframe value.
   *
   */
  static ENUM_TIMEFRAMES IndexToTf(ENUM_TIMEFRAMES_INDEX index) {
    // @todo: Convert it into a loop and using tf constant, see: TfToIndex().
    switch (index) {
      case M1:
        return PERIOD_M1;  // For 1 minute.
      case M2:
        return PERIOD_M2;  // For 2 minutes (non-standard).
      case M3:
        return PERIOD_M3;  // For 3 minutes (non-standard).
      case M4:
        return PERIOD_M4;  // For 4 minutes (non-standard).
      case M5:
        return PERIOD_M5;  // For 5 minutes.
      case M6:
        return PERIOD_M6;  // For 6 minutes (non-standard).
      case M10:
        return PERIOD_M10;  // For 10 minutes (non-standard).
      case M12:
        return PERIOD_M12;  // For 12 minutes (non-standard).
      case M15:
        return PERIOD_M15;  // For 15 minutes.
      case M20:
        return PERIOD_M20;  // For 20 minutes (non-standard).
      case M30:
        return PERIOD_M30;  // For 30 minutes.
      case H1:
        return PERIOD_H1;  // For 1 hour.
      case H2:
        return PERIOD_H2;  // For 2 hours (non-standard).
      case H3:
        return PERIOD_H3;  // For 3 hours (non-standard).
      case H4:
        return PERIOD_H4;  // For 4 hours.
      case H6:
        return PERIOD_H6;  // For 6 hours (non-standard).
      case H8:
        return PERIOD_H8;  // For 8 hours (non-standard).
      case H12:
        return PERIOD_H12;  // For 12 hours (non-standard).
      case D1:
        return PERIOD_D1;  // Daily.
      case W1:
        return PERIOD_W1;  // Weekly.
      case MN1:
        return PERIOD_MN1;  // Monthly.
      default:
        return NULL;
    }
  }

  /**
   * Convert timeframe constant to index value.
   */
  static ENUM_TIMEFRAMES_INDEX TfToIndex(ENUM_TIMEFRAMES _tf) {
    _tf = (_tf == 0 || _tf == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)_Period : _tf;
    for (int i = 0; i < ArraySize(TIMEFRAMES_LIST); i++) {
      if (TIMEFRAMES_LIST[i] == _tf) {
        return (ENUM_TIMEFRAMES_INDEX)i;
      }
    }
    return NULL;
  }
  ENUM_TIMEFRAMES_INDEX TfToIndex() { return TfToIndex(cparams.tf); }

  /**
   * Returns text representation of the timeframe constant.
   */
  static string TfToString(const ENUM_TIMEFRAMES _tf) {
    return StringSubstr(EnumToString((_tf == 0 || _tf == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)_Period : _tf)), 7);
  }
  string TfToString() { return TfToString(cparams.tf); }

  /**
   * Returns text representation of the timeframe index.
   */
  static string IndexToString(ENUM_TIMEFRAMES_INDEX _tfi) { return TfToString(IndexToTf(_tfi)); }

  /* State checking */

  /**
   * Validates whether given timeframe is valid.
   */
  static bool IsValidShift(int _shift, ENUM_TIMEFRAMES _tf, string _symbol = NULL) { return Chart::iTime(_symbol, _tf, _shift) > 0; }
  bool IsValidShift(int _shift) {
    return GetBarTime(_shift) > 0;
  }

  /**
   * Validates whether given timeframe is valid.
   */
  static bool IsValidTf(ENUM_TIMEFRAMES _tf, string _symbol = NULL) { return Chart::iOpen(_symbol, _tf) > 0; }
  bool IsValidTf() {
    static bool is_valid = false;
    return is_valid ? is_valid : GetOpen() > 0;
  }

  /**
   * Validate whether given timeframe index is valid.
   */
  static bool IsValidTfIndex(ENUM_TIMEFRAMES_INDEX _tfi, string _symbol = NULL) {
    return IsValidTf(IndexToTf(_tfi), _symbol);
  }
  bool IsValidTfIndex() { return IsValidTfIndex(cparams.tfi, symbol); }

  /* Timeseries */
  /* @see: https://docs.mql4.com/series */

  /**
   * Returns open time price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static datetime iTime(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, uint _shift = 0) {
#ifdef __MQL4__
    return ::iTime(_symbol, _tf, _shift);  // Same as: Time[_shift]
#else                                      // __MQL5__
    datetime _arr[];
    // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
    // @todo: Improves performance by caching values.
    return (_shift >= 0 && ::CopyTime(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : -1;
#endif
  }
  datetime GetBarTime(ENUM_TIMEFRAMES _tf, uint _shift = 0) { return Chart::iTime(symbol, _tf, _shift); }
  datetime GetBarTime(unsigned int _shift = 0) { return Chart::iTime(symbol, cparams.tf, _shift); }
  datetime GetLastBarTime() { return last_bar_time; }

  /**
   * Returns open price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static double iOpen(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, uint _shift = 0) {
#ifdef __MQL4__
    return ::iOpen(_symbol, _tf, _shift);  // Same as: Open[_shift]
#else                                      // __MQL5__
    double _arr[];
    ArraySetAsSeries(_arr, true);
    return (_shift >= 0 && CopyOpen(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : -1;
#endif
  }
  double GetOpen(ENUM_TIMEFRAMES _tf, uint _shift = 0) { return Chart::iOpen(symbol, _tf, _shift); }
  double GetOpen(uint _shift = 0) { return Chart::iOpen(symbol, cparams.tf, _shift); }

  /**
   * Returns close price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   *
   * @see http://docs.mql4.com/series/iclose
   */
  static double iClose(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) {
#ifdef __MQL4__
    return ::iClose(_symbol, _tf, _shift);  // Same as: Close[_shift]
#else                                       // __MQL5__
    double _arr[];
    ArraySetAsSeries(_arr, true);
    return (_shift >= 0 && CopyClose(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : -1;
#endif
  }
  double GetClose(ENUM_TIMEFRAMES _tf, int _shift = 0) { return Chart::iClose(symbol, _tf, _shift); }
  double GetClose(int _shift = 0) { return Chart::iClose(symbol, cparams.tf, _shift); }

  /**
   * Returns low price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static double iLow(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, uint _shift = 0) {
#ifdef __MQL4__
    return ::iLow(_symbol, _tf, _shift);  // Same as: Low[_shift]
#else                                     // __MQL5__
    double _arr[];
    ArraySetAsSeries(_arr, true);
    return (_shift >= 0 && CopyLow(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : -1;
#endif
  }
  double GetLow(ENUM_TIMEFRAMES _tf, uint _shift = 0) { return Chart::iLow(symbol, _tf, _shift); }
  double GetLow(uint _shift = 0) { return Chart::iLow(symbol, cparams.tf, _shift); }

  /**
   * Returns low price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static double iHigh(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, uint _shift = 0) {
#ifdef __MQL4__
    return ::iHigh(_symbol, _tf, _shift);  // Same as: High[_shift]
#else                                      // __MQL5__
    double _arr[];
    ArraySetAsSeries(_arr, true);
    return (_shift >= 0 && CopyHigh(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : -1;
#endif
  }
  double GetHigh(ENUM_TIMEFRAMES _tf, uint _shift = 0) { return iHigh(symbol, _tf, _shift); }
  double GetHigh(uint _shift = 0) { return iHigh(symbol, cparams.tf, _shift); }

  /**
   * Returns the current price value given applied price type.
   */
  static double iPrice(ENUM_APPLIED_PRICE _ap, string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT,
                       int _shift = 0) {
    double _result = EMPTY_VALUE;
    switch (_ap) {
      // Close price.
      case PRICE_CLOSE:
        _result = Chart::iClose(_symbol, _tf, _shift);
        break;
      // Open price.
      case PRICE_OPEN:
        _result = Chart::iOpen(_symbol, _tf, _shift);
        break;
      // The maximum price for the period.
      case PRICE_HIGH:
        _result = Chart::iHigh(_symbol, _tf, _shift);
        break;
      // The minimum price for the period.
      case PRICE_LOW:
        _result = Chart::iLow(_symbol, _tf, _shift);
        break;
      // Median price: (high + low)/2.
      case PRICE_MEDIAN:
        _result = (Chart::iHigh(_symbol, _tf, _shift) + Chart::iLow(_symbol, _tf, _shift)) / 2;
        break;
      // Typical price: (high + low + close)/3.
      case PRICE_TYPICAL:
        _result = (Chart::iHigh(_symbol, _tf, _shift) + Chart::iLow(_symbol, _tf, _shift) +
                   Chart::iClose(_symbol, _tf, _shift)) /
                  3;
        break;
      // Weighted close price: (high + low + close + close)/4.
      case PRICE_WEIGHTED:
        _result = (Chart::iHigh(_symbol, _tf, _shift) + Chart::iLow(_symbol, _tf, _shift) +
                   Chart::iClose(_symbol, _tf, _shift) + Chart::iClose(_symbol, _tf, _shift)) /
                  4;
        break;
    }
    return _result;
  }
  double GetPrice(ENUM_APPLIED_PRICE _ap, int _shift = 0) { return Chart::iPrice(_ap, symbol, cparams.tf, _shift); }

  /**
   * Returns the price value given applied price type.
   */
  static float GetAppliedPrice(ENUM_APPLIED_PRICE _ap, float _o, float _h, float _c, float _l) {
    BarOHLC _bar(_o, _h, _c, _l);
    return _bar.GetAppliedPrice(_ap);
  }

  /**
   * Returns tick volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  static long iVolume(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, uint _shift = 0) {
#ifdef __MQL4__
    return ::iVolume(_symbol, _tf, _shift);  // Same as: Volume[_shift]
#else                                        // __MQL5__
    long _arr[];
    ArraySetAsSeries(_arr, true);
    return (_shift >= 0 && CopyTickVolume(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : -1;
#endif
  }
  long GetVolume(ENUM_TIMEFRAMES _tf, uint _shift = 0) { return iVolume(symbol, _tf, _shift); }
  long GetVolume(uint _shift = 0) { return iVolume(symbol, cparams.tf, _shift); }

  /**
   * Returns the shift of the maximum value over a specific number of periods depending on type.
   */
  static int iHighest(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _type = MODE_HIGH,
                      uint _count = WHOLE_ARRAY, int _start = 0) {
#ifdef __MQL4__
    return ::iHighest(_symbol, _tf, _type, _count, _start);
#else  // __MQL5__
    if (_start < 0) return (-1);
    _count = (_count <= 0 ? Chart::iBars(_symbol, _tf) : _count);
    double arr_d[];
    long arr_l[];
    datetime arr_dt[];
    ArraySetAsSeries(arr_d, true);
    switch (_type) {
      case MODE_OPEN:
        CopyOpen(_symbol, _tf, _start, _count, arr_d);
        break;
      case MODE_LOW:
        CopyLow(_symbol, _tf, _start, _count, arr_d);
        break;
      case MODE_HIGH:
        CopyHigh(_symbol, _tf, _start, _count, arr_d);
        break;
      case MODE_CLOSE:
        CopyClose(_symbol, _tf, _start, _count, arr_d);
        break;
      case MODE_VOLUME:
        ArraySetAsSeries(arr_l, true);
        CopyTickVolume(_symbol, _tf, _start, _count, arr_l);
        return (ArrayMaximum(arr_l, 0, _count) + _start);
      case MODE_TIME:
        ArraySetAsSeries(arr_dt, true);
        CopyTime(_symbol, _tf, _start, _count, arr_dt);
        return (ArrayMaximum(arr_dt, 0, _count) + _start);
      default:
        break;
    }
    return (ArrayMaximum(arr_d, 0, _count) + _start);
#endif
  }
  int GetHighest(ENUM_TIMEFRAMES _tf, int type, int _count = WHOLE_ARRAY, int _start = 0) {
    return iHighest(symbol, _tf, type, _count, _start);
  }
  int GetHighest(int type, int _count = WHOLE_ARRAY, int _start = 0) {
    return iHighest(symbol, cparams.tf, type, _count, _start);
  }

  /**
   * Returns the shift of the lowest value over a specific number of periods depending on type.
   */
  static int iLowest(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _type = MODE_LOW,
                     unsigned int _count = WHOLE_ARRAY, int _start = 0) {
#ifdef __MQL4__
    return ::iLowest(_symbol, _tf, _type, _count, _start);
#else  // __MQL5__
    if (_start < 0) return (-1);
    _count = (_count <= 0 ? iBars(_symbol, _tf) : _count);
    double arr_d[];
    long arr_l[];
    datetime arr_dt[];
    ArraySetAsSeries(arr_d, true);
    switch (_type) {
      case MODE_OPEN:
        CopyOpen(_symbol, _tf, _start, _count, arr_d);
        break;
      case MODE_LOW:
        CopyLow(_symbol, _tf, _start, _count, arr_d);
        break;
      case MODE_HIGH:
        CopyHigh(_symbol, _tf, _start, _count, arr_d);
        break;
      case MODE_CLOSE:
        CopyClose(_symbol, _tf, _start, _count, arr_d);
        break;
      case MODE_VOLUME:
        ArraySetAsSeries(arr_l, true);
        CopyTickVolume(_symbol, _tf, _start, _count, arr_l);
        return (ArrayMinimum(arr_l, 0, _count) + _start);
      case MODE_TIME:
        ArraySetAsSeries(arr_dt, true);
        CopyTime(_symbol, _tf, _start, _count, arr_dt);
        return (ArrayMinimum(arr_dt, 0, _count) + _start);
      default:
        break;
    }
    return (ArrayMinimum(arr_d, 0, _count) + _start);
#endif
  }
  int GetLowest(int _type, int _count = WHOLE_ARRAY, int _start = 0) {
    return iLowest(symbol, cparams.tf, _type, _count, _start);
  }

  /**
   * Returns the number of bars on the specified chart.
   */
  static int iBars(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
#ifdef __MQL4__
    // In MQL4, for the current chart, the information about the amount of bars is in the Bars predefined variable.
    return ::iBars(_symbol, _tf);
#else  // _MQL5__
    // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
    return ::Bars(_symbol, _tf);
#endif
  }
  int GetBars() { return Chart::iBars(symbol, cparams.tf); }

  /**
   * Search for a bar by its time.
   *
   * Returns the index of the bar which covers the specified time.
   */
  static int iBarShift(string _symbol, ENUM_TIMEFRAMES _tf, datetime _time, bool _exact = false) {
#ifdef __MQL4__
    return ::iBarShift(_symbol, _tf, _time, _exact);
#else  // __MQL5__
    if (_time < 0) return (-1);
    datetime arr[], _time0;
    // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
    CopyTime(_symbol, _tf, 0, 1, arr);
    _time0 = arr[0];
    if (CopyTime(_symbol, _tf, _time, _time0, arr) > 0) {
      if (ArraySize(arr) > 2) {
        return ArraySize(arr) - 1;
      } else {
        return _time < _time0 ? 1 : 0;
      }
    } else {
      return -1;
    }
#endif
  }
  int GetBarShift(datetime _time, bool _exact = false) { return iBarShift(symbol, cparams.tf, _time, _exact); }

  /**
   * Get peak price at given number of bars.
   *
   * In case of error, check it via GetLastError().
   */
  double GetPeakPrice(int bars, int mode, int index, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT) {
    int ibar = -1;
    // @todo: Add symbol parameter.
    double peak_price = GetOpen(0);
    switch (mode) {
      case MODE_HIGH:
        ibar = iHighest(symbol, timeframe, MODE_HIGH, bars, index);
        return ibar >= 0 ? GetHigh(timeframe, ibar) : false;
      case MODE_LOW:
        ibar = iLowest(symbol, timeframe, MODE_LOW, bars, index);
        return ibar >= 0 ? GetLow(timeframe, ibar) : false;
      default:
        return false;
    }
  }
  double GetPeakPrice(int bars, int mode = MODE_HIGH, int index = 0) {
    return GetPeakPrice(bars, mode, index, cparams.tf);
  }

  /**
   * List active timeframes.
   *
   * @param
   * _all bool If true, return also non-active timeframes.
   *
   * @return
   * Returns textual representation of list of timeframes.
   */
  static string ListTimeframes(bool _all = false, string _prefix = "Timeframes: ") {
    string output = _prefix;
    for (ENUM_TIMEFRAMES_INDEX _tfi = 0; _tfi < FINAL_ENUM_TIMEFRAMES_INDEX; _tfi++) {
      if (_all) {
        output += StringFormat("%s: %s; ", IndexToString(_tfi), IsValidTfIndex(_tfi) ? "On" : "Off");
      } else {
        output += IsValidTfIndex(_tfi) ? IndexToString(_tfi) + "; " : "";
      }
    }
    return output;
  }

  /* Chart */

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

  /**
   * Calculate modelling quality.
   *
   * @see:
   * - https://www.mql5.com/en/articles/1486
   * - https://www.mql5.com/en/articles/1513
   */
  static double CalcModellingQuality(ENUM_TIMEFRAMES TimePr = NULL) {
    int i;
    int nBarsInM1 = 0;
    int nBarsInPr = 0;
    int nBarsInNearPr = 0;
    ENUM_TIMEFRAMES TimeNearPr = PERIOD_M1;
    double ModellingQuality = 0;
    long StartGen = 0;
    long StartBar = 0;
    long StartGenM1 = 0;
    long HistoryTotal = 0;
    datetime modeling_start_time = D'1971.01.01 00:00';

    if (TimePr == NULL) TimePr = (ENUM_TIMEFRAMES)Period();
    if (TimePr == PERIOD_M1) TimeNearPr = PERIOD_M1;
    if (TimePr == PERIOD_M5) TimeNearPr = PERIOD_M1;
    if (TimePr == PERIOD_M15) TimeNearPr = PERIOD_M5;
    if (TimePr == PERIOD_M30) TimeNearPr = PERIOD_M15;
    if (TimePr == PERIOD_H1) TimeNearPr = PERIOD_M30;
    if (TimePr == PERIOD_H4) TimeNearPr = PERIOD_H1;
    if (TimePr == PERIOD_D1) TimeNearPr = PERIOD_H4;
    if (TimePr == PERIOD_W1) TimeNearPr = PERIOD_D1;
    if (TimePr == PERIOD_MN1) TimeNearPr = PERIOD_W1;

    // 1 minute.
    double nBars = fmin(iBars(NULL, TimePr) * TimePr, iBars(NULL, PERIOD_M1));
    for (i = 0; i < nBars; i++) {
      if (Chart::iOpen(NULL, PERIOD_M1, i) >= 0.000001) {
        if (Chart::iTime(NULL, PERIOD_M1, i) >= modeling_start_time) {
          nBarsInM1++;
        }
      }
    }

    // Nearest time.
    nBars = iBars(NULL, TimePr);
    for (i = 0; i < nBars; i++) {
      if (Chart::iOpen(NULL, TimePr, i) >= 0.000001) {
        if (Chart::iTime(NULL, TimePr, i) >= modeling_start_time) nBarsInPr++;
      }
    }

    // Period time.
    nBars = fmin(iBars(NULL, TimePr) * TimePr / TimeNearPr, iBars(NULL, TimeNearPr));
    for (i = 0; i < nBars; i++) {
      if (Chart::iOpen(NULL, TimeNearPr, (int)i) >= 0.000001) {
        if (Chart::iTime(NULL, TimeNearPr, i) >= modeling_start_time) nBarsInNearPr++;
      }
    }

    HistoryTotal = nBarsInPr;
    nBarsInM1 = nBarsInM1 / TimePr;
    nBarsInNearPr = nBarsInNearPr * TimeNearPr / TimePr;
    StartGenM1 = HistoryTotal - nBarsInM1;
    StartBar = HistoryTotal - nBarsInPr;
    StartBar = 0;
    StartGen = HistoryTotal - nBarsInNearPr;

    if (TimePr == PERIOD_M1) {
      StartGenM1 = HistoryTotal;
      StartGen = StartGenM1;
    }
    if ((HistoryTotal - StartBar) != 0) {
      ModellingQuality =
          ((0.25 * (StartGen - StartBar) + 0.5 * (StartGenM1 - StartGen) + 0.9 * (HistoryTotal - StartGenM1)) /
           (HistoryTotal - StartBar)) *
          100;
    }
    return (ModellingQuality);
  }

  /**
   * Returns number of seconds in a period.
   */
  static unsigned int PeriodSeconds(ENUM_TIMEFRAMES _tf) { return ::PeriodSeconds(_tf); }
  unsigned int GetPeriodSeconds() { return Chart::PeriodSeconds(cparams.tf); }

  /**
   * Returns number of minutes in a period.
   */
  static double PeriodMinutes(ENUM_TIMEFRAMES _tf) { return Chart::PeriodSeconds(_tf) / 60; }
  double GetPeriodMinutes() { return Chart::PeriodMinutes(cparams.tf); }

  /**
   * Returns number of hours in a period.
   */
  static double PeriodHours(ENUM_TIMEFRAMES _tf) { return Chart::PeriodSeconds(_tf) / (60 * 60); }
  double GetPeriodHours() { return Chart::PeriodHours(cparams.tf); }

  /* Setters */

  /**
   * Sets chart entry.
   */
  void SetEntry(ChartEntry &_entry) { c_entry = _entry; }

  /**
   * Sets open time value for the last bar of indicated symbol with timeframe.
   */
  void SetLastBarTime() { last_bar_time = GetBarTime(); }

  /* State checking */

  /**
   * Check whether the price is in its peak for the current period.
   */
  static bool IsPeak(ENUM_TIMEFRAMES _period, string _symbol = NULL) {
    return GetAsk(_symbol) >= Chart::iHigh(_symbol, _period) || GetAsk(_symbol) <= Chart::iLow(_symbol, _period);
  }
  bool IsPeak() { return IsPeak(cparams.tf, symbol); }

  /**
   * Acknowledges chart that new tick happened.
   */
  virtual void OnTick() {
    ++tick_index;

    if (GetLastBarTime() != GetBarTime()) {
      ++bar_index;
    }
  }

  /**
   * Returns current tick index (incremented every OnTick()).
   */
  unsigned int GetTickIndex() { return tick_index == -1 ? 0 : tick_index; }

  /**
   * Returns current bar index (incremented every OnTick() if IsNewBar() is true).
   */
  unsigned int GetBarIndex() { return bar_index == -1 ? 0 : bar_index; }

  /**
   * Check if there is a new bar to parse.
   */
  bool IsNewBar() {
    // static datetime _last_itime = iTime();
    bool _result = false;
    if (GetLastBarTime() != GetBarTime()) {
      SetLastBarTime();
      _result = true;
    }
    return _result;
  }

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

  /**
   * Returns list of modelling quality for all periods.
   */
  static string GetModellingQuality() {
    string output = "Modelling Quality: ";
    output += StringFormat(
        "%s: %.2f%%, %s: %.2f%%, %s: %.2f%%, %s: %.2f%%, %s: %.2f%%, %s: %.2f%%, %s: %.2f%%, %s: %.2f%%, %s: %.2f%%;",
        "M1", CalcModellingQuality(PERIOD_M1), "M5", CalcModellingQuality(PERIOD_M5), "M15",
        CalcModellingQuality(PERIOD_M15), "M30", CalcModellingQuality(PERIOD_M30), "H1",
        CalcModellingQuality(PERIOD_H1), "H4", CalcModellingQuality(PERIOD_H4), "D1", CalcModellingQuality(PERIOD_D1),
        "W1", CalcModellingQuality(PERIOD_W1), "MN1", CalcModellingQuality(PERIOD_MN1));
    return output;
  }

  /* Conditions */

  /**
   * Checks for chart condition.
   *
   * @param ENUM_CHART_CONDITION _cond
   *   Chart condition.
   * @param MqlParam _args
   *   Trade action arguments.
   * @return
   *   Returns true when the condition is met.
   */
  bool CheckCondition(ENUM_CHART_CONDITION _cond, IndiParamEntry &_args[]) {
    float _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4;
    switch (_cond) {
      case CHART_COND_ASK_BAR_PEAK:
        return IsPeak();
      case CHART_COND_ASK_GT_BAR_HIGH:
        return GetAsk() > GetHigh();
      case CHART_COND_ASK_GT_BAR_LOW:
        return GetAsk() > GetLow();
      case CHART_COND_ASK_LT_BAR_HIGH:
        return GetAsk() < GetHigh();
      case CHART_COND_ASK_LT_BAR_LOW:
        return GetAsk() < GetLow();
      case CHART_COND_BAR_CLOSE_GT_PP_PP: {
        ChartEntry _centry = Chart::GetEntry(1);
        return GetClose() > _centry.bar.ohlc.GetPivot();
      }
      case CHART_COND_BAR_CLOSE_GT_PP_R1: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _r1;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_R2: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _r2;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_R3: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _r3;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_R4: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _r4;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_S1: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _s1;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_S2: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _s2;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_S3: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _s3;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_S4: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _s4;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_PP: {
        ChartEntry _centry = Chart::GetEntry(1);
        return GetClose() < _centry.bar.ohlc.GetPivot();
      }
      case CHART_COND_BAR_CLOSE_LT_PP_R1: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _r1;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_R2: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _r2;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_R3: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _r3;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_R4: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _r4;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_S1: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _s1;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_S2: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _s2;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_S3: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _s3;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_S4: {
        ChartEntry _centry = Chart::GetEntry(1);
        _centry.bar.ohlc.GetPivots(cparams.pp_type, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _s4;
      }
      case CHART_COND_BAR_HIGHEST_CURR_20:
        return GetHighest(MODE_CLOSE, 20) == 0;
      case CHART_COND_BAR_HIGHEST_CURR_50:
        return GetHighest(MODE_CLOSE, 50) == 0;
      case CHART_COND_BAR_HIGHEST_PREV_20:
        return GetHighest(MODE_CLOSE, 20) == 1;
      case CHART_COND_BAR_HIGHEST_PREV_50:
        return GetHighest(MODE_CLOSE, 50) == 1;
      case CHART_COND_BAR_HIGH_GT_OPEN:
        return GetHigh() > GetOpen();
      case CHART_COND_BAR_HIGH_LT_OPEN:
        return GetHigh() < GetOpen();
      case CHART_COND_BAR_INDEX_EQ_ARG:
        // Current bar's index equals argument value.
        if (ArraySize(_args) > 0) {
          return GetBarIndex() == Convert::MqlParamToInteger(_args[0]);
        } else {
          SetUserError(ERR_INVALID_PARAMETER);
          return false;
        }
      case CHART_COND_BAR_INDEX_GT_ARG:
        // Current bar's index greater than argument value.
        if (ArraySize(_args) > 0) {
          return GetBarIndex() > Convert::MqlParamToInteger(_args[0]);
        } else {
          SetUserError(ERR_INVALID_PARAMETER);
          return false;
        }
      case CHART_COND_BAR_INDEX_LT_ARG:
        // Current bar's index lower than argument value.
        if (ArraySize(_args) > 0) {
          return GetBarIndex() < Convert::MqlParamToInteger(_args[0]);
        } else {
          SetUserError(ERR_INVALID_PARAMETER);
          return false;
        }
      case CHART_COND_BAR_LOWEST_CURR_20:
        return GetLowest(MODE_CLOSE, 20) == 0;
      case CHART_COND_BAR_LOWEST_CURR_50:
        return GetLowest(MODE_CLOSE, 50) == 0;
      case CHART_COND_BAR_LOWEST_PREV_20:
        return GetLowest(MODE_CLOSE, 20) == 1;
      case CHART_COND_BAR_LOWEST_PREV_50:
        return GetLowest(MODE_CLOSE, 50) == 1;
      case CHART_COND_BAR_LOW_GT_OPEN:
        return GetLow() > GetOpen();
      case CHART_COND_BAR_LOW_LT_OPEN:
        return GetLow() < GetOpen();
      case CHART_COND_BAR_NEW:
        return IsNewBar();
      /*
      case CHART_COND_BAR_NEW_DAY:
        // @todo;
        return false;
      case CHART_COND_BAR_NEW_HOUR:
        // @todo;
        return false;
      case CHART_COND_BAR_NEW_MONTH:
        // @todo;
        return false;
      case CHART_COND_BAR_NEW_WEEK:
        // @todo;
        return false;
      case CHART_COND_BAR_NEW_YEAR:
        // @todo;
        return false;
      */
      default:
        Logger().Error(StringFormat("Invalid market condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }
  bool CheckCondition(ENUM_CHART_CONDITION _cond) {
    IndiParamEntry _args[] = {};
    return Chart::CheckCondition(_cond, _args);
  }

  /* Printer methods */

  /**
   * Returns textual representation of the Chart class.
   */
  string ToString(unsigned int _shift = 0) { return StringFormat("%s: %s", TfToString(), GetEntry(_shift).ToCSV()); }

  /* Other methods */

  /* Snapshots */

  /**
   * Save the current BarOHLC values.
   *
   * @return
   *   Returns true if BarOHLC values has been saved, otherwise false.
   */
  bool SaveChartEntry() {
    // @todo: Use MqlRates.
    uint _last = ArraySize(chart_saves);
    if (ArrayResize(chart_saves, _last + 1, 100)) {
      chart_saves[_last].bar.ohlc.time = Chart::iTime();
      chart_saves[_last].bar.ohlc.open = (float)Chart::GetOpen();
      chart_saves[_last].bar.ohlc.high = (float)Chart::GetHigh();
      chart_saves[_last].bar.ohlc.low = (float)Chart::GetLow();
      chart_saves[_last].bar.ohlc.close = (float)Chart::GetClose();
      return true;
    } else {
      return false;
    }
  }

  /**
   * Load stored BarOHLC values.
   *
   * @param
   *   _index uint Index of the element in BarOHLC array.
   * @return
   *   Returns BarOHLC struct element.
   */
  ChartEntry LoadChartEntry(uint _index = 0) { return chart_saves[_index]; }

  /**
   * Return size of BarOHLC array.
   */
  ulong SizeChartEntry() { return ArraySize(chart_saves); }
};
#endif

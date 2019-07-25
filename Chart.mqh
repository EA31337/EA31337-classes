//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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

/**
 * @file
 * Class to provide chart, timeframe and timeseries operations.
 *
 * @docs
 * - https://www.mql5.com/en/docs/chart_operations
 * - https://www.mql5.com/en/docs/series
 */

// Properties.
#property strict

// Class dependencies.
class Chart;
class Market;

// Prevents processing this includes file for the second time.
#ifndef CHART_MQH
#define CHART_MQH

// Includes.
#include "Market.mqh"

// Define type of periods.
// @see: https://docs.mql4.com/constants/chartconstants/enum_timeframes
enum ENUM_TIMEFRAMES_INDEX {
  M1  =  0, // 1 minute
  M2  =  1, // 2 minutes (non-standard)
  M3  =  2, // 3 minutes (non-standard)
  M4  =  3, // 4 minutes (non-standard)
  M5  =  4, // 5 minutes
  M6  =  5, // 6 minutes (non-standard)
  M10 =  6, // 10 minutes (non-standard)
  M12 =  7, // 12 minutes (non-standard)
  M15 =  8, // 15 minutes
  M20 =  9, // 20 minutes (non-standard)
  M30 = 10, // 30 minutes
  H1  = 11, // 1 hour
  H2  = 12, // 2 hours (non-standard)
  H3  = 13, // 3 hours (non-standard)
  H4  = 14, // 4 hours
  H6  = 15, // 6 hours (non-standard)
  H8  = 16, // 8 hours (non-standard)
  H12 = 17, // 12 hours (non-standard)
  D1  = 18, // Daily
  W1  = 19, // Weekly
  MN1 = 20, // Monthly
  // This item should be the last one.
  // Used to calculate the number of enum items.
  FINAL_ENUM_TIMEFRAMES_INDEX = 21
};

// Define type of periods using bitwise operators.
enum ENUM_TIMEFRAMES_BITS {
  M1B  = 1 << 0, //   =1: 1 minute
  M5B  = 1 << 1, //   =2: 5 minutes
  M15B = 1 << 2, //   =4: 15 minutes
  M30B = 1 << 3, //   =8: 30 minutes
  H1B  = 1 << 4, //  =16: 1 hour
  H4B  = 1 << 5, //  =32: 4 hours
  D1B  = 1 << 6, //  =64: Daily
  W1B  = 1 << 7, // =128: Weekly
  MN1B = 1 << 8, // =256: Monthly
};

// Enums.
// Define type of periods.
// @see: https://docs.mql4.com/constants/chartconstants/enum_timeframes
#define TFS 21
const ENUM_TIMEFRAMES arr_tf[TFS] = {
  PERIOD_M1, PERIOD_M2, PERIOD_M3, PERIOD_M4, PERIOD_M5, PERIOD_M6,
  PERIOD_M10, PERIOD_M12, PERIOD_M15, PERIOD_M20, PERIOD_M30,
  PERIOD_H1, PERIOD_H2, PERIOD_H3, PERIOD_H4, PERIOD_H6, PERIOD_H8, PERIOD_H12,
  PERIOD_D1, PERIOD_W1, PERIOD_MN1
};

/**
 * Class to provide chart, timeframe and timeseries operations.
 */
class Chart : public Market {

  // Structs.
  struct ChartParams {
    ENUM_TIMEFRAMES tf;
    ENUM_TIMEFRAMES_INDEX tfi;
    // Constructor.
    void ChartParams(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
      : tf(_tf), tfi(Chart::TfToIndex(_tf)) {};
    void ChartParams(ENUM_TIMEFRAMES_INDEX _tfi)
      : tfi(_tfi), tf(Chart::IndexToTf(_tfi)) {};
  } cparams;
  // Struct for storing OHLC values.
  struct OHLC {
    datetime time;
    double open, high, low, close;
  } ohlc_saves[];

  protected:

    // Stores information about the prices, volumes and spread.
    MqlRates rates[];

    // Variables.
    datetime last_bar_time;

  public:

    // Enums.
    enum ENUM_PP_METHOD {
      PP_CAMARILLA,  // A set of eight very probable levels which resemble support and resistance values for a current trend.
      PP_CLASSIC,
      PP_FIBONACCI,
      PP_FLOOR,      // Most basic and popular type of pivots used in Forex trading technical analysis.
      PP_TOM_DEMARK, // Tom DeMark's pivot point (predicted lows and highs of the period).
      PP_WOODIE      // Woodie's pivot point are giving more weight to the Close price of the previous period.
    };

    /**
     * Class constructor.
     */
    void Chart(ChartParams &_cparams, string _symbol = NULL)
      : cparams(_cparams.tf),
        Market(_symbol),
        last_bar_time(GetBarTime())
    {
      // Save the first OHLC values.
      this.SaveOHLC();
    }
    void Chart(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, string _symbol = NULL)
      : cparams(_tf),
        Market(_symbol),
        last_bar_time(GetBarTime())
    {
      // Save the first OHLC values.
      this.SaveOHLC();
    }
    void Chart(ENUM_TIMEFRAMES_INDEX _tfi, string _symbol = NULL)
      : cparams(_tfi),
        Market(_symbol),
        last_bar_time(GetBarTime())
    {
      // Save the first OHLC values.
      this.SaveOHLC();
    }

    /**
     * Class constructor.
     */
    void ~Chart() {
    }

    /**
     * Get the current timeframe.
     */
    ENUM_TIMEFRAMES GetTf() {
      return cparams.tf;
    }

    /**
     * Convert period to proper chart timeframe value.
     *
     */
    static ENUM_TIMEFRAMES IndexToTf(ENUM_TIMEFRAMES_INDEX index) {
      // @todo: Convert it into a loop and using tf constant, see: TfToIndex().
      switch (index) {
        case M1:  return PERIOD_M1;  // For 1 minute.
        case M2:  return PERIOD_M2;  // For 2 minutes (non-standard).
        case M3:  return PERIOD_M3;  // For 3 minutes (non-standard).
        case M4:  return PERIOD_M4;  // For 4 minutes (non-standard).
        case M5:  return PERIOD_M5;  // For 5 minutes.
        case M6:  return PERIOD_M6;  // For 6 minutes (non-standard).
        case M10: return PERIOD_M10; // For 10 minutes (non-standard).
        case M12: return PERIOD_M12; // For 12 minutes (non-standard).
        case M15: return PERIOD_M15; // For 15 minutes.
        case M20: return PERIOD_M20; // For 20 minutes (non-standard).
        case M30: return PERIOD_M30; // For 30 minutes.
        case H1:  return PERIOD_H1;  // For 1 hour.
        case H2:  return PERIOD_H2;  // For 2 hours (non-standard).
        case H3:  return PERIOD_H3;  // For 3 hours (non-standard).
        case H4:  return PERIOD_H4;  // For 4 hours.
        case H6:  return PERIOD_H6;  // For 6 hours (non-standard).
        case H8:  return PERIOD_H8;  // For 8 hours (non-standard).
        case H12: return PERIOD_H12; // For 12 hours (non-standard).
        case D1:  return PERIOD_D1;  // Daily.
        case W1:  return PERIOD_W1;  // Weekly.
        case MN1: return PERIOD_MN1; // Monthly.
        default:  return NULL;
      }
    }

    /**
     * Convert timeframe constant to index value.
     */
    static ENUM_TIMEFRAMES_INDEX TfToIndex(ENUM_TIMEFRAMES _tf) {
      _tf = (_tf == 0 || _tf == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES) _Period : _tf;
      for (int i = 0; i < ArraySize(arr_tf); i++) {
        if (arr_tf[i] == _tf) {
          return (ENUM_TIMEFRAMES_INDEX) i;
        }
      }
      return NULL;
    }
    ENUM_TIMEFRAMES_INDEX TfToIndex() {
      return TfToIndex(this.cparams.tf);
    }

    /**
     * Returns text representation of the timeframe constant.
     */
    static string TfToString(const ENUM_TIMEFRAMES _tf) {
      return StringSubstr(EnumToString((_tf == 0 || _tf == PERIOD_CURRENT ? (ENUM_TIMEFRAMES) _Period : _tf)), 7);
    }
    string TfToString() {
      return TfToString(this.cparams.tf);
    }

    /**
     * Returns text representation of the timeframe index.
     */
    static string IndexToString(ENUM_TIMEFRAMES_INDEX _tfi) {
      return TfToString(IndexToTf(_tfi));
    }

    /**
     * Validate whether given timeframe is valid.
     */
    static bool IsValidTf(ENUM_TIMEFRAMES _tf, string _symbol = NULL) {
      return Chart::iOpen(_symbol, _tf) > 0;
    }
    bool IsValidTf() {
      static bool is_valid = false;
      return is_valid ? is_valid : this.GetOpen() > 0;
    }

    /**
     * Validate whether given timeframe index is valid.
     */
    static bool IsValidTfIndex(ENUM_TIMEFRAMES_INDEX _tfi, string _symbol = NULL) {
      return IsValidTf(IndexToTf(_tfi), _symbol);
    }
    bool IsValidTfIndex() {
      return this.IsValidTfIndex(cparams.tfi, this.symbol);
    }

    /* Timeseries */
    /* @see: https://docs.mql4.com/series */

    /**
     * Returns open time value for the bar of indicated symbol with timeframe and shift.
     *
     * If local history is empty (not loaded), function returns 0.
     */
    static datetime iTime(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, uint _shift = 0) {
      #ifdef __MQL4__
      return ::iTime(_symbol, _tf, _shift);
      #else // __MQL5__
      datetime _arr[];
      // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
      return (_shift >=0 && ::CopyTime(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : -1;
      #endif
    }
    datetime GetBarTime(ENUM_TIMEFRAMES _tf, uint _shift = 0) {
      return Chart::iTime(this.symbol, _tf, _shift);
    }
    datetime GetBarTime(uint _shift = 0) {
      return Chart::iTime(this.symbol, this.cparams.tf, _shift);
    }
    datetime GetLastBarTime() {
      return last_bar_time;
    }

    /**
     * Returns Open value for the bar of indicated symbol.
     *
     * If local history is empty (not loaded), function returns 0.
     */
    static double iOpen(string _symbol, ENUM_TIMEFRAMES _tf, uint _shift = 0) {
      #ifdef __MQL4__
      return ::iOpen(_symbol, _tf, _shift);
      #else // __MQL5__
      double _arr[];
      // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
      return (_shift >= 0 && CopyOpen(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : -1;
      #endif
    }
    double GetOpen(ENUM_TIMEFRAMES _tf, uint _shift = 0) {
      return Chart::iOpen(this.symbol, _tf, _shift);
    }
    double GetOpen(uint _shift = 0) {
      return Chart::iOpen(this.symbol, cparams.tf, _shift);
    }

    /**
     * Returns Close value for the bar of indicated symbol.
     *
     * If local history is empty (not loaded), function returns 0.
     *
     * @see http://docs.mql4.com/series/iclose
     */
    static double iClose(string _symbol, ENUM_TIMEFRAMES _tf, int _shift = 0) {
      #ifdef __MQL4__
      return ::iClose(_symbol, _tf, _shift);
      #else // __MQL5__
      double _arr[];
      // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
      return (_shift >= 0 && CopyClose(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : -1;
      #endif
    }
    double GetClose(ENUM_TIMEFRAMES _tf, int _shift = 0) {
      return Chart::iClose(this.symbol, _tf, _shift);
    }
    double GetClose(int _shift = 0) {
      return Chart::iClose(this.symbol, cparams.tf, _shift);
    }

    /**
     * Returns Low value for the bar of indicated symbol.
     *
     * If local history is empty (not loaded), function returns 0.
     */
    static double iLow(string _symbol, ENUM_TIMEFRAMES _tf, uint _shift = 0) {
      #ifdef __MQL4__
      return ::iLow(_symbol, _tf, _shift);
      #else // __MQL5__
      double _arr[];
      // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
      return (_shift >= 0 && CopyLow(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : -1;
      #endif
    }
    double GetLow(ENUM_TIMEFRAMES _tf, uint _shift = 0) {
      return Chart::iLow(this.symbol, _tf, _shift);
    }
    double GetLow(uint _shift = 0) {
      return Chart::iLow(this.symbol, cparams.tf, _shift);
    }

    /**
     * Returns Low value for the bar of indicated symbol.
     *
     * If local history is empty (not loaded), function returns 0.
     */
    static double iHigh(string _symbol, ENUM_TIMEFRAMES _tf, uint _shift = 0) {
      #ifdef __MQL4__
      return ::iHigh(_symbol, _tf, _shift);
      #else // __MQL5__
      double _arr[];
      // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
      return (_shift >= 0 && CopyHigh(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : -1;
      #endif
    }
    double GetHigh(ENUM_TIMEFRAMES _tf, uint _shift = 0) {
      return iHigh(symbol, _tf, _shift);
    }
    double GetHigh(uint _shift = 0) {
      return iHigh(symbol, cparams.tf, _shift);
    }

    /**
     * Returns tick volume value for the bar.
     *
     * If local history is empty (not loaded), function returns 0.
     */
    static long iVolume(string _symbol, ENUM_TIMEFRAMES _tf, uint _shift = 0) {
      #ifdef __MQL4__
      return ::iVolume(_symbol, _tf, _shift);
      #else // __MQL5__
      long _arr[];
      // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
      return (_shift >= 0 && CopyTickVolume(_symbol, _tf, _shift, 1, _arr) > 0) ? _arr[0] : -1;
      #endif
    }
    long GetVolume(ENUM_TIMEFRAMES _tf, uint _shift = 0) {
      return this.iVolume(this.symbol, _tf, _shift);
    }
    long GetVolume(uint _shift = 0) {
      return this.iVolume(this.symbol, cparams.tf, _shift);
    }

    /**
     * Returns the shift of the maximum value over a specific number of periods depending on type.
     */
    static int iHighest(string _symbol, ENUM_TIMEFRAMES _tf, int type, uint _count = WHOLE_ARRAY, int _start = 0) {
      #ifdef __MQL4__
      return ::iHighest(_symbol, _tf, type, _count, _start);
      #else // __MQL5__
      if (_start < 0) return (-1);
      _count = (_count <= 0 ? Chart::iBars(_symbol, _tf) : _count);
      double arr_d[];
      long arr_l[];
      datetime arr_dt[];
      ArraySetAsSeries(arr_d, true);
      switch (type) {
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
      return this.iHighest(this.symbol, _tf, type, _count, _start);
    }
    int GetHighest(int type, int _count = WHOLE_ARRAY, int _start = 0) {
      return this.iHighest(this.symbol, cparams.tf, type, _count, _start);
    }

    /**
     * Returns the shift of the lowest value over a specific number of periods depending on type.
     */
    static int iLowest(string _symbol, ENUM_TIMEFRAMES _tf, int _type, uint _count = WHOLE_ARRAY, int _start = 0) {
      #ifdef __MQL4__
      return ::iLowest(_symbol, _tf, _type, _count, _start);
      #else // __MQL5__
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
    int GetLowest(ENUM_TIMEFRAMES _tf, int _type, int _count = WHOLE_ARRAY, int _start = 0) {
      return this.iLowest(this.symbol, _tf, _type, _count, _start);
    }

    /**
     * Returns the number of bars on the specified chart.
     */
    static uint iBars(string _symbol, ENUM_TIMEFRAMES _tf) {
      #ifdef __MQL4__
      // In MQL4, for the current chart, the information about the amount of bars is in the Bars predefined variable.
      return ::iBars(_symbol, _tf);
      #else // _MQL5__
      // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
      return ::Bars(_symbol, _tf);
      #endif
    }
    uint GetBars() {
      return this.iBars(this.symbol, cparams.tf);
    }

    /**
     * Search for a bar by its time.
     *
     * Returns the index of the bar which covers the specified time.
     */
    static uint iBarShift(string _symbol, ENUM_TIMEFRAMES _tf, datetime _time, bool _exact = false) {
      #ifdef __MQL4__
      return ::iBarShift(_symbol, _tf, _time, _exact);
      #else // __MQL5__
      if (_time < 0) return (-1);
      datetime arr[], _time0;
      // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
      CopyTime(_symbol, _tf, 0, 1, arr);
      _time0 = arr[0];
      if (CopyTime(_symbol,_tf, _time, _time0, arr) > 0) {
        if (ArraySize(arr) > 2 ) {
          return ArraySize(arr) - 1;
        } else {
          return _time < _time0 ? 1 : 0;
        }
      } else {
        return -1;
      }
      #endif
    }
    uint GetBarShift(datetime _time, bool _exact = false) {
      return iBarShift(this.symbol, cparams.tf, _time, _exact);
    }

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
          ibar = this.iHighest(symbol, timeframe, MODE_HIGH, bars, index);
          return ibar >= 0 ? this.iHigh(this.symbol, timeframe, ibar) : false;
        case MODE_LOW:
          ibar = this.iLowest(symbol, timeframe, MODE_LOW,  bars, index);
          return ibar >= 0 ? this.iLow(this.symbol, timeframe, ibar) : false;
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
      for (ENUM_TIMEFRAMES_INDEX _tfi = 0; _tfi < FINAL_ENUM_TIMEFRAMES_INDEX; _tfi++ ) {
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
     * After the Expert Advisor has been tested and the appropriate chart opened, the flagged indicators will not be drawn in the testing chart.
     * Every indicator called will first be flagged with the current hiding flag.
     * It must be noted that only those indicators can be drawn in the testing chart that are directly called from the expert under test.
     *
     * @param
     * _hide bool Flag for hiding indicators when testing. Set true to hide created indicators, otherwise false.
     */
    static void HideTestIndicators(bool _hide = false) {
      #ifdef __MQL4__
      ::HideTestIndicators(_hide);
      #else // __MQL5__
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
    static double CalcModellingQuality(int TimePr = NULL) {

      int i;
      int nBarsInM1     = 0;
      int nBarsInPr     = 0;
      int nBarsInNearPr = 0;
      ENUM_TIMEFRAMES  TimeNearPr = PERIOD_M1;
      double ModellingQuality = 0;
      long   StartGen     = 0;
      long   StartBar     = 0;
      long   StartGenM1   = 0;
      long   HistoryTotal = 0;
      datetime modeling_start_time =  D'1971.01.01 00:00';

      if (TimePr == NULL)       TimePr     = Period();
      if (TimePr == PERIOD_M1)  TimeNearPr = PERIOD_M1;
      if (TimePr == PERIOD_M5)  TimeNearPr = PERIOD_M1;
      if (TimePr == PERIOD_M15) TimeNearPr = PERIOD_M5;
      if (TimePr == PERIOD_M30) TimeNearPr = PERIOD_M15;
      if (TimePr == PERIOD_H1)  TimeNearPr = PERIOD_M30;
      if (TimePr == PERIOD_H4)  TimeNearPr = PERIOD_H1;
      if (TimePr == PERIOD_D1)  TimeNearPr = PERIOD_H4;
      if (TimePr == PERIOD_W1)  TimeNearPr = PERIOD_D1;
      if (TimePr == PERIOD_MN1) TimeNearPr = PERIOD_W1;

      // 1 minute.
      double nBars = fmin(iBars(NULL, (ENUM_TIMEFRAMES) TimePr) * TimePr, iBars(NULL,PERIOD_M1));
      for (i = 0; i < nBars;i++) {
        if (iOpen(NULL,PERIOD_M1, i) >= 0.000001) {
          if (iTime(NULL, PERIOD_M1, i) >= modeling_start_time)
          {
            nBarsInM1++;
          }
        }
      }

      // Nearest time.
      nBars = iBars(NULL, (ENUM_TIMEFRAMES) TimePr);
      for (i = 0; i < nBars;i++) {
        if (iOpen(NULL,TimePr, i) >= 0.000001) {
          if (iTime(NULL, TimePr, i) >= modeling_start_time)
            nBarsInPr++;
        }
      }

      // Period time.
      nBars = fmin(iBars(NULL, (ENUM_TIMEFRAMES) TimePr) * TimePr/TimeNearPr, iBars(NULL, TimeNearPr));
      for (i = 0; i < nBars;i++) {
        if (iOpen(NULL, TimeNearPr, i) >= 0.000001) {
          if (iTime(NULL, TimeNearPr, i) >= modeling_start_time)
            nBarsInNearPr++;
        }
      }

      HistoryTotal   = nBarsInPr;
      nBarsInM1      = nBarsInM1 / TimePr;
      nBarsInNearPr  = nBarsInNearPr * TimeNearPr / TimePr;
      StartGenM1     = HistoryTotal - nBarsInM1;
      StartBar       = HistoryTotal - nBarsInPr;
      StartBar       = 0;
      StartGen       = HistoryTotal - nBarsInNearPr;

      if(TimePr == PERIOD_M1) {
        StartGenM1 = HistoryTotal;
        StartGen   = StartGenM1;
      }
      if((HistoryTotal - StartBar) != 0) {
        ModellingQuality = ((0.25 * (StartGen-StartBar) +
              0.5 * (StartGenM1 - StartGen) +
              0.9 * (HistoryTotal - StartGenM1)) / (HistoryTotal - StartBar)) * 100;
      }
      return (ModellingQuality);
    }

    /**
     * Calculates pivot points in different systems.
     */
    static void CalcPivotPoints(string _symbol, ENUM_TIMEFRAMES _tf, ENUM_PP_METHOD _method, double &PP, double &S1, double &S2, double &S3, double &S4, double &R1, double &R2, double &R3, double &R4) {
      double _open   = iOpen(_symbol, _tf, 1);
      double _high   = iHigh(_symbol, _tf, 1);
      double _low    = iLow(_symbol, _tf, 1);
      double _close  = iClose(_symbol, _tf, 1);
      double _range  = _high - _low;

      switch (_method) {
        case PP_CAMARILLA:
          // A set of eight very probable levels which resemble support and resistance values for a current trend.
          // S1 = C - (H - L) * 1.1 / 12 (1.0833)
          // S2 = C - (H - L) * 1.1 / 6 (1.1666)
          // S3 = C - (H - L) * 1.1 / 4 (1.25)
          // S4 = C - (H - L) * 1.1 / 2 (1.5)
          // R1 = (H - L) * 1.1 / 12 + C (1.0833)
          // R2 = (H - L) * 1.1 / 6 + C (1.1666)
          // R3 = (H - L) * 1.1 / 4 + C (1.25)
          // R4 = (H - L) * 1.1 / 2 + C (1.5)
          PP = (_high + _low + _close) / 3;
          S1 = _close - _range * 1.1 / 12;
          S2 = _close - _range * 1.1 / 6;
          S3 = _close - _range * 1.1 / 4;
          S4 = _close - _range * 1.1 / 2;
          R1 = _close + _range * 1.1 / 12;
          R2 = _close + _range * 1.1 / 6;
          R3 = _close + _range * 1.1 / 4;
          R4 = _close + _range * 1.1 / 2;
          break;
        case PP_CLASSIC:
          PP = (_high + _low + _close) / 3;
          S1 = (2 * PP) - _high;
          S2 = PP - _range;
          S3 = PP - _range * 2;
          S4 = PP - _range * 3;
          R1 = (2 * PP) - _low;
          R2 = PP + _range;
          R3 = PP + _range * 2;
          R4 = PP + _range * 3;
          break;
        case PP_FIBONACCI:
          PP = (_high + _low + _close) / 3;
          S1 = PP - 0.382 * _range;
          S2 = PP - 0.618 * _range;
          S3 = PP - _range;
          S4 = S1 - _range; // ?
          R1 = PP + 0.382 * _range;
          R2 = PP + 0.618 * _range;
          R3 = PP + _range;
          R4 = R1 + _range; // ?
          break;
        case PP_FLOOR:
          // Most basic and popular type of pivots used in Forex trading technical analysis.
          // Pivot (P) = (H + L + C) / 3
          // Support (S1) = (2 * P) - H
          // S2 = P - H + L
          // S3 = L - 2 * (H - P)
          // Resistance (R1) = (2 * P) - L
          // R2 = P + H - L
          // R3 = H + 2 * (P - L)
          PP = (_high + _low + _close) / 3;
          S1 = (2 * PP) - _high;
          S2 = PP - _range;
          S3 = _low - 2 * (_high - PP);
          S4 = S3; // ?
          R1 = (2 * PP) - _low;
          R2 = PP + _range;
          R3 = _high + 2 * (PP - _low);
          R4 = R3;
          break;
        case PP_TOM_DEMARK:
          // Tom DeMark's pivot point (predicted lows and highs of the period).
          // If Close < Open Then X = H + 2 * L + C
          // If Close > Open Then X = 2 * H + L + C
          // If Close = Open Then X = H + L + 2 * C
          // New High = X / 2 - L
          // New Low = X / 2 - H
          if (_close < _open) PP = (_high + (2 * _low) + _close) / 4;
          else if (_close > _open) PP = ((2 * _high) + _low + _close) / 4;
          else if (_close == _open) PP = (_high + _low + (2 * _close)) / 4;
          S1 = (2 * PP) - _high;
          S2 = PP - _range;
          S3 = S1 - _range;
          S4 = S2 - _range; // ?
          R1 = (2 * PP) - _low;
          R2 = PP + _range;
          R3 = R1 + _range;
          R4 = R2 + _range; // ?
          break;
        case PP_WOODIE:
          // Woodie's pivot point are giving more weight to the Close price of the previous period.
          // They are similar to floor pivot points, but are calculated in a somewhat different way.
          // Pivot (P) = (H + L + 2 * C) / 4
          // Support (S1) = (2 * P) - H
          // S2 = P - H + L
          // Resistance (R1) = (2 * P) - L
          // R2 = P + H - L
          PP = (_high + _low + (2 * _close)) / 4;
          S1 = (2 * PP) - _high;
          S2 = PP - _range;
          S3 = S1 - _range;
          S4 = S2 - _range; // ?
          R1 = (2 * PP) - _low;
          R2 = PP + _range;
          R3 = R1 + _range;
          R4 = R2 + _range; // ?
          break;
      }
      PP = NormalizePrice(_symbol, PP);
      S1 = NormalizePrice(_symbol, S1);
      S2 = NormalizePrice(_symbol, S2);
      S3 = NormalizePrice(_symbol, S3);
      S4 = NormalizePrice(_symbol, S4);
      R1 = NormalizePrice(_symbol, R1);
      R2 = NormalizePrice(_symbol, R2);
      R3 = NormalizePrice(_symbol, R3);
      R4 = NormalizePrice(_symbol, R4);
    }
    void CalcPivotPoints(ENUM_PP_METHOD _method, double &PP, double &S1, double &S2, double &S3, double &S4, double &R1, double &R2, double &R3, double &R4) {
      CalcPivotPoints(this.symbol, cparams.tf, _method, PP, S1, S2, S3, S4, R1, R2, R3, R4);
    }

    /**
     * Returns bar's range size in pips.
     */
    double GetBarRangeSize(uint _bar) {
      return (GetHigh(_bar) - GetLow(_bar)) / GetPointsPerPip();
    }

    /**
     * Returns bar's candle size in pips.
     */
    double GetBarCandleSize(uint _bar) {
      return (GetClose(_bar) - GetOpen(_bar)) / GetPointsPerPip();
    }

    /**
     * Returns bar's body size in pips.
     */
    double GetBarBodySize(uint _bar) {
      return fabs(GetClose(_bar) - GetOpen(_bar)) / GetPointsPerPip();
    }

    /**
     * Returns bar's head size in pips.
     */
    double GetBarHeadSize(uint _bar) {
      return (GetHigh(_bar) - fmax(GetClose(_bar), GetOpen(_bar))) / GetPointsPerPip();
    }

    /**
     * Returns bar's tail size in pips.
     */
    double GetBarTailSize(uint _bar) {
      return (fmin(GetClose(_bar), GetOpen(_bar)) - GetLow(_bar)) / GetPointsPerPip();
    }

    /* Setters */

    /**
     * Sets open time value for the last bar of indicated symbol with timeframe.
     */
    void SetLastBarTime() {
      last_bar_time = this.GetBarTime();
    }

    /* State checking */

    /**
     * Check whether the price is in its peak for the current period.
     */
    static bool IsPeak(ENUM_TIMEFRAMES _period, string _symbol = NULL) {
      return GetAsk(_symbol) >= Chart::iHigh(_symbol, _period) || GetAsk(_symbol) <= Chart::iLow(_symbol, _period);
    }
    bool IsPeak() {
      return IsPeak(cparams.tf, this.symbol);
    }

    /**
     * Check if there is a new bar to parse.
     */
    bool IsNewBar() {
      //static datetime _last_itime = this.iTime();
      bool _result = false;
      if (this.GetLastBarTime() != this.GetBarTime()) {
        this.SetLastBarTime();
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
      #ifdef __MQL4__ ::WindowRedraw(); #else ::ChartRedraw(0); #endif
    }

    /* Getters */

    /**
     * Returns textual representation of the Chart class.
     */
    string ToString() {
      return StringFormat(
        "OHLC (%s): %g/%g/%g/%g",
        this.TfToString(), this.GetOpen(), this.GetClose(), this.GetLow(), this.GetHigh()
        );
    }

    /**
     * Returns list of modelling quality for all periods.
     */
    static string GetModellingQuality() {
      string output = "Modelling Quality: ";
      output +=
        StringFormat("%s: %.2f%%, %s: %.2f%%, %s: %.2f%%, %s: %.2f%%, %s: %.2f%%, %s: %.2f%%, %s: %.2f%%, %s: %.2f%%, %s: %.2f%%;",
            "M1",  CalcModellingQuality(PERIOD_M1),
            "M5",  CalcModellingQuality(PERIOD_M5),
            "M15", CalcModellingQuality(PERIOD_M15),
            "M30", CalcModellingQuality(PERIOD_M30),
            "H1",  CalcModellingQuality(PERIOD_H1),
            "H4",  CalcModellingQuality(PERIOD_H4),
            "D1",  CalcModellingQuality(PERIOD_D1),
            "W1",  CalcModellingQuality(PERIOD_W1),
            "MN1", CalcModellingQuality(PERIOD_MN1)
            );
      return output;
    }

    /* Other methods */

    /* Snapshots */

    /**
     * Save the current OHLC values.
     *
     * @return
     *   Returns true if OHLC values has been saved, otherwise false.
     */
    bool SaveOHLC() {
      // @todo: Use MqlRates.
      uint _last = ArraySize(ohlc_saves);
      if (ArrayResize(ohlc_saves, _last + 1, 100)) {
        ohlc_saves[_last].time  = this.iTime();
        ohlc_saves[_last].open  = this.GetOpen();
        ohlc_saves[_last].high = this.GetHigh();
        ohlc_saves[_last].low = this.GetLow();
        ohlc_saves[_last].close = this.GetClose();
        return true;
      } else {
        return false;
      }
    }

    /**
     * Load stored OHLC values.
     *
     * @param
     *   _index uint Index of the element in OHLC array.
     * @return
     *   Returns OHLC struct element.
     */
    OHLC LoadOHLC(uint _index = 0) {
      return ohlc_saves[_index];
    }

    /**
     * Return size of OHLC array.
     */
    ulong SizeOHLC() {
      return ArraySize(ohlc_saves);
    }

};
#endif
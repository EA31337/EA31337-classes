//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
 * Class to provide generic chart operations.
 */

// Prevents processing this includes file for the second time.
#ifndef __MQL__
#pragma once
#endif

#ifdef __DISABLE

// Includes.`
#include "Bar.struct.h"
#include "Chart.enum.h"
#include "Chart.struct.h"
#include "Chart.symboltf.h"
#include "Data.define.h"
#include "Log.mqh"
#include "Refs.mqh"
#include "Storage/Dict/Dict.h"
#include "Task/TaskCondition.enum.h"

/**
 * Abstract class used as a base for market prices source.
 */
class ChartBase : public Dynamic {
  // Unique, incremental id of the chart.
  int id;

  // Generic chart params.
  ChartParams cparams;

  // Time of the last bar.
  datetime last_bar_time;

  // Index of the current bar.
  int bar_index;

  // Whether new bar happened in the current tick.
  bool is_new_bar;

  // Index of the current tick.
  int tick_index;

  // Logger.
  Ref<Log> logger;

  // Array of saved chart entries.
  ARRAY(ChartEntry, chart_saves);

 public:
  /**
   * Constructor.
   */
  ChartBase(string _symbol, ENUM_TIMEFRAMES _tf) : logger(new Log()) {
    Set<string>(CHART_PARAM_SYMBOL, _symbol);
    Set<ENUM_TIMEFRAMES>(CHART_PARAM_TF, _tf);

    static int _id = 0;
    id = _id++;
  }

  /* Getters */

  /**
   * Gets a chart parameter value.
   */
  template <typename T>
  T Get(ENUM_CHART_PARAM _param) {
    return cparams.Get<T>(_param);
  }

  /**
   * Returns time of the bar with a given shift.
   */
  virtual datetime GetBarTime(int _rel_shift = 0) = 0;

  datetime GetLastBarTime() { return last_bar_time; }

  /**
   * Returns the number of bars on the chart.
   */
  virtual int GetBars() = 0;

  /**
   * Search for a bar by its time.
   *
   * Returns the index of the bar which covers the specified time.
   */
  virtual int GetBarShift(datetime _time, bool _exact = false) = 0;

  /**
   * Unique, incremental id of the chart.
   */
  int GetId() { return id; }

  /**
   * Returns pointer to logger.
   */
  Log* GetLogger() { return logger.Ptr(); }

  /**
   * Gets copy of params.
   *
   * @return
   *   Returns structure for Trade's params.
   */
  ChartParams GetParams() const { return cparams; }

  /**
   * Return symbol bound to chart.
   */
  CONST_REF_TO(string) GetSymbol() { return cparams.Get<string>(CHART_PARAM_SYMBOL); }

  /**
   * Return time-frame bound to chart.
   */
  ENUM_TIMEFRAMES GetTf() { return cparams.Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF); }

  /**
   * Returns open time price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual datetime GetTime(unsigned int _shift = 0) = 0;

  /**
   * Return symbol pair for a given symbol index.
   */
  virtual const string GetSymbolName(int _index) { return ::SymbolName(_index, true); }

  /**
   * Return number of symbols available for the chart.
   */
  virtual int GetSymbolsTotal() { return ::SymbolsTotal(true); }

  /* Price getters */

  /**
   * Returns the price value given applied price type.
   */
  static float GetAppliedPrice(ENUM_APPLIED_PRICE _ap, float _o, float _h, float _c, float _l) {
    BarOHLC _bar(_o, _h, _c, _l);
    return _bar.GetAppliedPrice(_ap);
  }

  /**
   * Gets OHLC price values.
   */
  virtual BarOHLC GetOHLC(int _rel_shift = 0) {
    datetime _time = GetBarTime(_rel_shift);
    float _open = 0, _high = 0, _low = 0, _close = 0;
    if (_time > 0) {
      _open = (float)GetOpen(_rel_shift);
      _high = (float)GetHigh(_rel_shift);
      _low = (float)GetLow(_rel_shift);
      _close = (float)GetClose(_rel_shift);
    }
    BarOHLC _ohlc(_open, _high, _low, _close, _time);
    return _ohlc;
  }

  /**
   * Returns the current price value given applied price type, symbol and timeframe.
   */
  virtual double GetPrice(ENUM_APPLIED_PRICE _ap, int _shift = 0) = 0;

  /**
   * Returns tick volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual int64 GetVolume(int _shift = 0) = 0;

  /**
   * Returns the shift of the maximum value over a specific number of periods depending on type.
   */
  virtual int GetHighest(int type, int _count = WHOLE_ARRAY, int _start = 0) = 0;

  /**
   * Returns the shift of the minimum value over a specific number of periods depending on type.
   */
  virtual int GetLowest(int type, int _count = WHOLE_ARRAY, int _start = 0) = 0;

  /**
   * Gets chart entry.
   *
   * @param
   *   _tf ENUM_TIMEFRAMES Timeframe to use.
   *   _shift unsigned int _shift Shift to use.
   *   _symbol string Symbol to use.
   *
   * @return
   *   Returns ChartEntry struct.
   */
  ChartEntry GetEntry(unsigned int _shift = 0) {
    ChartEntry _chart_entry;
    BarOHLC _ohlc = GetOHLC(_shift);
    if (_ohlc.open > 0) {
      BarEntry _bar_entry(_ohlc);
      _chart_entry.SetBar(_bar_entry);
    }
    return _chart_entry;
  }

  /**
   * Returns ask price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetAsk(int _shift = 0) { return GetPrice(PRICE_ASK, _shift); }

  /**
   * Returns bid price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetBid(int _shift = 0) { return GetPrice(PRICE_BID, _shift); }

  /**
   * Returns close price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetClose(int _shift = 0) { return GetPrice(PRICE_CLOSE, _shift); }

  /**
   * Returns high price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetHigh(int _shift = 0) { return GetPrice(PRICE_HIGH, _shift); }

  /**
   * Returns open price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetOpen(int _shift = 0) { return GetPrice(PRICE_OPEN, _shift); }

  /**
   * Returns low price value for the bar of indicated symbol.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  double GetLow(int _shift = 0) { return GetPrice(PRICE_LOW, _shift); }

  /**
   * Get peak price at given number of bars.
   *
   * In case of error, check it via GetLastError().
   */
  virtual double GetPeakPrice(int _bars, int _mode, int _index) {
    int _ibar = -1;
    double peak_price = GetOpen(0);
    switch (_mode) {
      case MODE_HIGH:
        _ibar = GetHighest(MODE_HIGH, _bars, _index);
        return _ibar >= 0 ? GetHigh(_ibar) : false;
      case MODE_LOW:
        _ibar = GetLowest(MODE_LOW, _bars, _index);
        return _ibar >= 0 ? GetLow(_ibar) : false;
      default:
        return false;
    }
  }

  /* Setters */

  /**
   * Sets chart parameter value.
   */
  template <typename T>
  void Set(ENUM_CHART_PARAM _param, T _value) {
    cparams.Set(_param, _value);
  }

  /* State checking */

  /**
   * Checks whether chart has valid configuration.
   */
  bool IsValid() { return GetOpen() > 0; }

  /**
   * Validate whether given timeframe index is valid.
   */
  bool IsValidTfIndex(ENUM_TIMEFRAMES_INDEX _tfi) {
    if (!IsValid()) {
      return false;
    }

    for (int i = 0; i < GetTfIndicesTotal(); ++i) {
      if (GetTfIndicesItem(i) == _tfi) {
        return true;
      }
    }

    return false;
  }

  /**
   * Validates whether given timeframe is valid.
   */
  bool IsValidShift(int _shift) { return GetTime(_shift) > 0; }

  /**
   * Returns total number of timeframe indices the chart supports. Supports all TFs by default.
   */
  virtual int GetTfIndicesTotal() { return FINAL_ENUM_TIMEFRAMES_INDEX; }

  /**
   * Returns item from the list of timeframe indices the chart supports. Supports all TFs by default.
   */
  virtual ENUM_TIMEFRAMES_INDEX GetTfIndicesItem(int _index) { return (ENUM_TIMEFRAMES_INDEX)_index; }

  /**
   * List active timeframes.
   *
   * @param
   * _all bool If true, return also non-active timeframes.
   *
   * @return
   * Returns textual representation of list of timeframes.
   */
  string ListTimeframes(bool _all = false, string _prefix = "Timeframes: ") {
    string output = _prefix;
    for (int i = 0; i < GetTfIndicesTotal(); i++) {
      ENUM_TIMEFRAMES_INDEX _tfi = GetTfIndicesItem(i);
      if (_all) {
        output += StringFormat("%s: %s; ", ChartTf::IndexToString(_tfi), IsValidTfIndex(_tfi) ? "On" : "Off");
      } else {
        output += IsValidTfIndex(_tfi) ? ChartTf::IndexToString(_tfi) + "; " : "";
      }
    }
    return output;
  }

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

  /**
   * Calculate modelling quality.
   *
   * @see:
   * - https://www.mql5.com/en/articles/1486
   * - https://www.mql5.com/en/articles/1513
   */
  static double CalcModellingQuality(ENUM_TIMEFRAMES TimePr = PERIOD_CURRENT) {
    int nBarsInM1 = 0;
    int nBarsInPr = 0;
    int nBarsInNearPr = 0;
    ENUM_TIMEFRAMES TimeNearPr = PERIOD_M1;
    double ModellingQuality = 0;
    int64 StartGen = 0;
    int64 StartBar = 0;
    int64 StartGenM1 = 0;
    int64 HistoryTotal = 0;
    datetime x = StrToTime("1971.01.01 00:00");
    datetime modeling_start_time = StrToTime("1971.01.01 00:00");

    /** @TODO

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
      if (ChartStatic::iOpen(NULL, PERIOD_M1, i) >= 0.000001) {
        if (GetTime(NULL, PERIOD_M1, i) >= modeling_start_time) {
          nBarsInM1++;
        }
      }
    }

    // Nearest time.
    nBars = ChartStatic::iBars(NULL, TimePr);
    for (i = 0; i < nBars; i++) {
      if (ChartStatic::iOpen(NULL, TimePr, i) >= 0.000001) {
        if (ChartStatic::iTime(NULL, TimePr, i) >= modeling_start_time) nBarsInPr++;
      }
    }

    // Period time.
    nBars = fmin(ChartStatic::iBars(NULL, TimePr) * TimePr / TimeNearPr, iBars(NULL, TimeNearPr));
    for (i = 0; i < nBars; i++) {
      if (ChartStatic::iOpen(NULL, TimeNearPr, (int)i) >= 0.000001) {
        if (ChartStatic::iTime(NULL, TimeNearPr, i) >= modeling_start_time) nBarsInNearPr++;
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
    */

    return (ModellingQuality);
  }

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
  bool CheckCondition(ENUM_CHART_CONDITION _cond, ARRAY_REF(DataParamEntry, _args)) {
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
        ChartEntry _centry = GetEntry(1);
        return GetClose() > _centry.bar.ohlc.GetPivot();
      }
      case CHART_COND_BAR_CLOSE_GT_PP_R1: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _r1;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_R2: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _r2;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_R3: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _r3;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_R4: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _r4;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_S1: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _s1;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_S2: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _s2;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_S3: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _s3;
      }
      case CHART_COND_BAR_CLOSE_GT_PP_S4: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() > _s4;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_PP: {
        ChartEntry _centry = GetEntry(1);
        return GetClose() < _centry.bar.ohlc.GetPivot();
      }
      case CHART_COND_BAR_CLOSE_LT_PP_R1: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _r1;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_R2: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _r2;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_R3: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _r3;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_R4: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _r4;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_S1: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _s1;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_S2: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _s2;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_S3: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
        return GetClose() < _s3;
      }
      case CHART_COND_BAR_CLOSE_LT_PP_S4: {
        ChartEntry _centry = GetEntry(1);
        _centry.bar.ohlc.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
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
          return GetBarIndex() == DataParamEntry::ToInteger(_args[0]);
        } else {
          SetUserError(ERR_INVALID_PARAMETER);
          return false;
        }
      case CHART_COND_BAR_INDEX_GT_ARG:
        // Current bar's index greater than argument value.
        if (ArraySize(_args) > 0) {
          return GetBarIndex() > DataParamEntry::ToInteger(_args[0]);
        } else {
          SetUserError(ERR_INVALID_PARAMETER);
          return false;
        }
      case CHART_COND_BAR_INDEX_LT_ARG:
        // Current bar's index lower than argument value.
        if (ArraySize(_args) > 0) {
          return GetBarIndex() < DataParamEntry::ToInteger(_args[0]);
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
        GetLogger().Error(StringFormat("Invalid market condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }
  bool CheckCondition(ENUM_CHART_CONDITION _cond) {
    ARRAY(DataParamEntry, _args);
    return CheckCondition(_cond, _args);
  }

  /* Printer methods */

  /**
   * Returns textual representation of the Chart class.
   */
  string ToString(unsigned int _shift = 0) {
    return StringFormat("%s: %s", ChartTf::TfToString(Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF)), GetEntry(_shift).ToCSV());
  }

  /* Snapshots */

  /**
   * Save the current BarOHLC values.
   *
   * @return
   *   Returns true if BarOHLC values has been saved, otherwise false.
   */
  bool SaveChartEntry() {
    // @todo: Use MqlRates.
    unsigned int _last = ArraySize(chart_saves);
    if (ArrayResize(chart_saves, _last + 1, 100)) {
      chart_saves[_last].bar.ohlc.time = GetTime();
      chart_saves[_last].bar.ohlc.open = (float)GetOpen();
      chart_saves[_last].bar.ohlc.high = (float)GetHigh();
      chart_saves[_last].bar.ohlc.low = (float)GetLow();
      chart_saves[_last].bar.ohlc.close = (float)GetClose();
      return true;
    } else {
      return false;
    }
  }

  /* State checking */

  /**
   * Check whether the price is in its peak for the current period.
   */
  bool IsPeak() { return GetAsk() >= GetHigh() || GetAsk() <= GetLow(); }

  /* Other methods */

  /**
   * Load stored BarOHLC values.
   *
   * @param
   *   _index unsigned int Index of the element in BarOHLC array.
   * @return
   *   Returns BarOHLC struct element.
   */
  ChartEntry LoadChartEntry(unsigned int _index = 0) { return chart_saves[_index]; }

  /**
   * Return size of BarOHLC array.
   */
  uint64 SizeChartEntry() { return ArraySize(chart_saves); }

  /* Serializers */

  /**
   * Returns serialized representation of the object instance.
   */
  SerializerNodeType Serialize(Serializer& _s) {
    /**
    TODO

    ChartEntry _centry = GetEntry();
    _s.PassStruct(THIS_REF, "chart-entry", _centry, SERIALIZER_FIELD_FLAG_DYNAMIC);
    */
    return SerializerNodeObject;
  }
};

#endif

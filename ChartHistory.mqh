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
 * Includes ChartHistory struct.
 */

#include "Chart.enum.h"
#ifdef __MQL5__
#include "MQL4.mqh"
#endif

struct ChartHistory {

  /* State checking */

  /**
   * Validate whether given timeframe index is valid.
   */
  static bool IsValidTfIndex(ENUM_TIMEFRAMES_INDEX _tfi, string _symbol = NULL) {
    return IsValidTf(IndexToTf(_tfi), _symbol);
  }

  /**
   * Validates whether given timeframe is valid.
   */
  static bool IsValidShift(int _shift, ENUM_TIMEFRAMES _tf, string _symbol = NULL) {
    return ChartHistory::iTime(_symbol, _tf, _shift) > 0;
  }

  /**
   * Validates whether given timeframe is valid.
   */
  static bool IsValidTf(ENUM_TIMEFRAMES _tf, string _symbol = NULL) { return ChartHistory::iOpen(_symbol, _tf) > 0; }

  /* Convert methods */

  /**
   * Convert period to proper chart timeframe value.
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

  /**
   * Returns text representation of the timeframe constant.
   */
  static string TfToString(const ENUM_TIMEFRAMES _tf) {
    return StringSubstr(EnumToString((_tf == 0 || _tf == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)_Period : _tf)), 7);
  }

  /**
   * Returns text representation of the timeframe index.
   */
  static string IndexToString(ENUM_TIMEFRAMES_INDEX _tfi) { return ChartHistory::TfToString(IndexToTf(_tfi)); }

  /* Chart data */

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

  /**
   * Returns the current price value given applied price type.
   */
  static double iPrice(ENUM_APPLIED_PRICE _ap, string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT,
                       int _shift = 0) {
    double _result = EMPTY_VALUE;
    switch (_ap) {
      // Close price.
      case PRICE_CLOSE:
        _result = ChartHistory::iClose(_symbol, _tf, _shift);
        break;
      // Open price.
      case PRICE_OPEN:
        _result = ChartHistory::iOpen(_symbol, _tf, _shift);
        break;
      // The maximum price for the period.
      case PRICE_HIGH:
        _result = ChartHistory::iHigh(_symbol, _tf, _shift);
        break;
      // The minimum price for the period.
      case PRICE_LOW:
        _result = ChartHistory::iLow(_symbol, _tf, _shift);
        break;
      // Median price: (high + low)/2.
      case PRICE_MEDIAN:
        _result = (ChartHistory::iHigh(_symbol, _tf, _shift) + ChartHistory::iLow(_symbol, _tf, _shift)) / 2;
        break;
      // Typical price: (high + low + close)/3.
      case PRICE_TYPICAL:
        _result = (ChartHistory::iHigh(_symbol, _tf, _shift) + ChartHistory::iLow(_symbol, _tf, _shift) +
                   ChartHistory::iClose(_symbol, _tf, _shift)) /
                  3;
        break;
      // Weighted close price: (high + low + close + close)/4.
      case PRICE_WEIGHTED:
        _result = (ChartHistory::iHigh(_symbol, _tf, _shift) + ChartHistory::iLow(_symbol, _tf, _shift) +
                   ChartHistory::iClose(_symbol, _tf, _shift) + ChartHistory::iClose(_symbol, _tf, _shift)) /
                  4;
        break;
    }
    return _result;
  }

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

  /**
   * Returns the shift of the maximum value over a specific number of periods depending on type.
   */
  static int iHighest(string _symbol = NULL, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _type = MODE_HIGH,
                      uint _count = WHOLE_ARRAY, int _start = 0) {
#ifdef __MQL4__
    return ::iHighest(_symbol, _tf, _type, _count, _start);
#else  // __MQL5__
    if (_start < 0) return (-1);
    _count = (_count <= 0 ? ChartHistory::iBars(_symbol, _tf) : _count);
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
};

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

// Includes.
#include "MQL4.mqh"
#include "Terminal.mqh"

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

// Enums.
// Define type of periods.
// @see: https://docs.mql4.com/constants/chartconstants/enum_timeframes
#ifdef __MQL4__
#define TFS 9
const ENUM_TIMEFRAMES arr_tf[TFS] = {
  PERIOD_M1, PERIOD_M5, PERIOD_M15,
  PERIOD_M30, PERIOD_H1, PERIOD_H4,
  PERIOD_D1, PERIOD_W1, PERIOD_MN1
};
#else // __MQL5__
#define TFS 21
const ENUM_TIMEFRAMES arr_tf[TFS] = {
  PERIOD_M1, PERIOD_M2, PERIOD_M3, PERIOD_M4, PERIOD_M5, PERIOD_M6,
  PERIOD_M10, PERIOD_M12, PERIOD_M15, PERIOD_M20, PERIOD_M30,
  PERIOD_H1, PERIOD_H2, PERIOD_H3, PERIOD_H4, PERIOD_H6, PERIOD_H8, PERIOD_H12,
  PERIOD_D1, PERIOD_W1, PERIOD_MN1
};
#endif

/**
 * Class to provide chart, timeframe and timeseries operations.
 */
class Chart : public Terminal {
  protected:
    // Variables.
    ENUM_TIMEFRAMES tf;

  public:

    /**
     * Class constructor.
     */
    void Chart(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) :
      tf(_tf == 0 ? PERIOD_CURRENT : _tf)
      {
      }

    /**
     * Class constructor.
     */
    void ~Chart() {
      delete market;
    }

    /**
     * Get the current timeframe.
     */
    ENUM_TIMEFRAMES GetTf() {
      return tf;
    }

    /**
     * Convert period to proper chart timeframe value.
     *
     */
    static ENUM_TIMEFRAMES IndexToTf(int index) {
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
    /*
       static int TfToIndex(ENUM_TIMEFRAMES tf) {
       switch (tf) {
       case PERIOD_M1:  return M1;
       case PERIOD_M2:  return M2;
       case PERIOD_M3:  return M3;
       case PERIOD_M4:  return M4;
       case PERIOD_M5:  return M5;
       case PERIOD_M6:  return M6;
       case PERIOD_M10: return M10;
       case PERIOD_M12: return M12;
       case PERIOD_M15: return M15;
       case PERIOD_M20: return M20;
       case PERIOD_M30: return M30;
       case PERIOD_H1:  return H1;
       case PERIOD_H2:  return H2;
       case PERIOD_H3:  return H3;
       case PERIOD_H4:  return H4;
       case PERIOD_H6:  return H6;
       case PERIOD_H8:  return H8;
       case PERIOD_H12: return H12;
       case PERIOD_D1:  return D1;
       case PERIOD_W1:  return W1;
       case PERIOD_MN1: return MN1;
       default:         return NULL;
       }
       }
     */

    /**
     * Convert timeframe constant to index value.
     */
    static uint TfToIndex(ENUM_TIMEFRAMES _tf) {
      _tf = (_tf == 0 || _tf == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES) _Period : _tf;
      for (int i = 0; i < ArraySize(arr_tf); i++) {
        if (arr_tf[i] == _tf) {
          return (i);
        }
      }
      return (0);
    }

    /**
     * Returns text representation of the timeframe constant.
     */
    static string TfToString(const ENUM_TIMEFRAMES _tf) {
      return StringSubstr(EnumToString(_tf), 7);
    }
    string TfToString() {
      return StringSubstr(EnumToString(tf), 7);
    }

    /**
     * Returns text representation of the timeframe index.
     */
    static string IndexToString(uint tfi) {
      return TfToString(IndexToTf(tfi));
    }

    /**
     * Validate whether given timeframe is valid.
     */
    static bool ValidTf(ENUM_TIMEFRAMES _tf, string _symbol = NULL) {
      return iHigh(_symbol, _tf) > 0;
    }
    bool ValidTf() {
      return ValidTf(tf, market.GetSymbol());
    }

    /**
     * Validate whether given timeframe index is valid.
     */
    static bool ValidTfIndex(uint _tf, string _symbol = NULL) {
      return ValidTf(IndexToTf(_tf), _symbol);
    }
    bool ValidTfIndex() {
      return ValidTfIndex(tf, market.GetSymbol());
    }

    /* Timeseries */
    /* @see: https://docs.mql4.com/series */

    /**
     * Returns time value for the bar of indicated symbol with timeframe and shift.
     *
     * If local history is empty (not loaded), function returns 0.
     */

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
    datetime iTime(uint _shift = 0) {
      return iTime(market.GetSymbol(), tf, _shift);
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
    double iOpen(uint _shift = 0) {
      return iOpen(market.GetSymbol(), tf, _shift);
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
    double iClose(int _shift = 0) {
      return iClose(market.GetSymbol(), tf, _shift);
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
    double iLow(uint _shift = 0) {
      return iLow(market.GetSymbol(), tf, _shift);
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
    double iHigh(uint _shift = 0) {
      return iHigh(market.GetSymbol(), tf, _shift);
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
    long iVolume(uint _shift = 0) {
      return iVolume(market.GetSymbol(), tf, _shift);
    }

    /**
     * Returns the shift of the maximum value over a specific number of periods depending on type.
     */
    static int iHighest(string _symbol, ENUM_TIMEFRAMES _tf, int type, int _count = WHOLE_ARRAY, int _start = 0) {
      #ifdef __MQL4__
      return ::iHighest(_symbol, _tf, type, _count, _start);
      #else // __MQL5__
      if (_start < 0) return (-1);
      _count = (_count <= 0 ? iBars(_symbol, _tf) : _count);
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
    int iHighest(int type, int _count = WHOLE_ARRAY, int _start = 0) {
      return iHighest(market.GetSymbol(), tf, type, _count, _start);
    }

    /**
     * Returns the shift of the lowest value over a specific number of periods depending on type.
     */
    static int iLowest(string _symbol, ENUM_TIMEFRAMES _tf, int _type, int _count = WHOLE_ARRAY, int _start = 0) {
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
    int iLowest(ENUM_TIMEFRAMES _tf, int _type, int _count = WHOLE_ARRAY, int _start = 0) {
      return iLowest(market.GetSymbol(), _tf, _type, _count, _start);
    }

    /**
     * Returns the number of bars on the specified chart.
     */
    static bool iBars(string _symbol, ENUM_TIMEFRAMES _tf) {
      #ifdef __MQL4__
      return ::iBars(_symbol, _tf);
      #else // _MQL5__
      // ENUM_TIMEFRAMES _tf = MQL4::TFMigrate(_tf);
      return ::Bars(_symbol, _tf);
      #endif
    }
    bool iBars() {
      return iBars(market.GetSymbol(), tf);
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
    uint iBarShift(ENUM_TIMEFRAMES _tf, datetime _time, bool _exact = false) {
      return iBarShift(market.GetSymbol(), _tf, _time, _exact);
    }

    /* Chart operations */

    /**
     * Redraws the current chart forcedly.
     *
     * @see:
     * https://docs.mql4.com/chart_operations/chartredraw
     */
    void ChartRedraw() {
      #ifdef __MQL4__ WindowRedraw(); #else ChartRedraw(0); #endif
    }

};

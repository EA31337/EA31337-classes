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
 * Includes Chart's structs.
 */

// Forward class declaration.
class Class;
class Serializer;

// Includes.
#include "Bar.struct.h"
#include "Chart.enum.h"
#include "Chart.struct.tf.h"
#include "Serializer.mqh"

/**
 * Wrapper struct that returns open time of each bar of the current chart.
 *
 * @see: https://docs.mql4.com/predefined/time
 */
struct ChartBarTime {
 protected:
  string symbol;
  ENUM_TIMEFRAMES tf;

 public:
  ChartBarTime() : symbol(_Symbol), tf(PERIOD_CURRENT) {}
  datetime operator[](const int _shift) const { return Get(symbol, tf, _shift); }
  static datetime Get(const string _symbol, const ENUM_TIMEFRAMES _tf, const int _shift) {
    return ChartHistory::iTime(_symbol, _tf, _shift);
  }
};

/* Defines struct to store bar entries. */
struct ChartEntry {
  BarEntry bar;
  // Constructors.
  ChartEntry() {}
  ChartEntry(const BarEntry& _bar) { SetBar(_bar); }
  // Getters.
  BarEntry GetBar() { return bar; }
  string ToCSV() { return StringFormat("%s", bar.ToCSV()); }
  // Setters.
  void SetBar(const BarEntry& _bar) { bar = _bar; }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s) {
    _s.PassStruct(this, "bar", bar, SERIALIZER_FIELD_FLAG_DYNAMIC);
    return SerializerNodeObject;
  }
};

/* Defines struct to retrieve chart history data. */
struct ChartHistory {

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
};

/* Defines struct for chart parameters. */
struct ChartParams {
  ChartTf tf;
  ENUM_PP_TYPE pp_type;
  // Copy constructor.
  void ChartParams(ChartParams &_cparams)
    : pp_type(_cparams.pp_type), tf(_cparams.tf) {}
  // Constructors.
  void ChartParams(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
      : tf(_tf), pp_type(PP_CLASSIC){};
  void ChartParams(ENUM_TIMEFRAMES_INDEX _tfi) : tf(_tfi), pp_type(PP_CLASSIC){};
  // Getters.
  ChartTf GetChartTf() const { return tf; }
  ENUM_TIMEFRAMES GetTf() const { return tf.GetTf(); }
  ENUM_TIMEFRAMES_INDEX GetTfIndex() const { return tf.GetIndex(); }
  // Setters.
  void SetPP(ENUM_PP_TYPE _pp) { pp_type = _pp; }
  void SetTf(ENUM_TIMEFRAMES _tf) { tf.SetTf(_tf); };
  // Serializers.
  SerializerNodeType Serialize(Serializer& s);
};

/* Method to serialize ChartParams structure. */
SerializerNodeType ChartParams::Serialize(Serializer& s) {
  s.PassStruct(this, "tf", tf);
  s.PassEnum(this, "pp_type", pp_type);
  return SerializerNodeObject;
}

/**
 * Wrapper struct that returns close prices of each bar of the current chart.
 *
 * @see: https://docs.mql4.com/predefined/close
 */
struct ChartPriceClose {
 protected:
  string symbol;
  ENUM_TIMEFRAMES tf;

 public:
  ChartPriceClose() : symbol(_Symbol), tf(PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol, tf, _shift); }
  static double Get(const string _symbol, const ENUM_TIMEFRAMES _tf, const int _shift) {
    return ChartHistory::iClose(_symbol, _tf, _shift);
  }
};

/**
 * Wrapper struct that returns the highest prices of each bar of the current chart.
 *
 * @see: https://docs.mql4.com/predefined/high
 */
struct ChartPriceHigh {
 protected:
  string symbol;
  ENUM_TIMEFRAMES tf;

 public:
  ChartPriceHigh() : symbol(_Symbol), tf(PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol, tf, _shift); }
  static double Get(const string _symbol, const ENUM_TIMEFRAMES _tf, const int _shift) {
    return ChartHistory::iHigh(_symbol, _tf, _shift);
  }
};

/**
 * Wrapper struct that returns the lowest prices of each bar of the current chart.
 *
 * @see: https://docs.mql4.com/predefined/low
 */
struct ChartPriceLow {
 protected:
  string symbol;
  ENUM_TIMEFRAMES tf;

 public:
  ChartPriceLow() : symbol(_Symbol), tf(PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol, tf, _shift); }
  static double Get(const string _symbol, const ENUM_TIMEFRAMES _tf, const int _shift) {
    return ChartHistory::iLow(_symbol, _tf, _shift);
  }
};

/**
 * Wrapper struct that returns open prices of each bar of the current chart.
 *
 * @see: https://docs.mql4.com/predefined/open
 */
struct ChartPriceOpen {
 protected:
  string symbol;
  ENUM_TIMEFRAMES tf;

 public:
  ChartPriceOpen() : symbol(_Symbol), tf(PERIOD_CURRENT) {}
  double operator[](const int _shift) const { return Get(symbol, tf, _shift); }
  static double Get(const string _symbol, const ENUM_TIMEFRAMES _tf, const int _shift) {
    return ChartHistory::iOpen(_symbol, _tf, _shift);
  }
};
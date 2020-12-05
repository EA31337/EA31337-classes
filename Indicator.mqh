//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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

// Ignore processing of this file if already included.
#ifndef INDICATOR_MQH
#define INDICATOR_MQH

// Forward declaration.
class Chart;

// Includes.
#include "Array.mqh"
#include "BufferStruct.mqh"
#include "Chart.mqh"
#include "DateTime.mqh"
#include "DrawIndicator.mqh"
#include "Indicator.enum.h"
#include "Indicator.struct.h"
#include "Math.h"
#include "Object.mqh"
#include "Refs.mqh"
#include "Serializer.mqh"
#include "SerializerCsv.mqh"

// Defines macros.
#define COMMA ,
#define DUMMY
#define ICUSTOM_DEF(PARAMS)                                                    \
  double _res[];                                                               \
  if (_handle == NULL || _handle == INVALID_HANDLE) {                          \
    if ((_handle = ::iCustom(_symbol, _tf, _name PARAMS)) == INVALID_HANDLE) { \
      SetUserError(ERR_USER_INVALID_HANDLE);                                   \
      return EMPTY_VALUE;                                                      \
    }                                                                          \
  }                                                                            \
  int _bars_calc = BarsCalculated(_handle);                                    \
  if (GetLastError() > 0) {                                                    \
    return EMPTY_VALUE;                                                        \
  } else if (_bars_calc <= 2) {                                                \
    SetUserError(ERR_USER_INVALID_BUFF_NUM);                                   \
    return EMPTY_VALUE;                                                        \
  }                                                                            \
  if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {                       \
    return EMPTY_VALUE;                                                        \
  }                                                                            \
  return _res[0];

// Defines bitwise method macro.
#define METHOD(method, no) ((method & (1 << no)) == 1 << no)

#ifndef __MQL4__
// Defines macros (for MQL4 backward compatibility).
#define IndicatorDigits(_digits) IndicatorSetInteger(INDICATOR_DIGITS, _digits)
#define IndicatorShortName(name) IndicatorSetString(INDICATOR_SHORTNAME, name)
#endif

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compatibility).
bool IndicatorBuffers(int _count) { return Indicator::SetIndicatorBuffers(_count); }
int IndicatorCounted(int _value = 0) {
  static int prev_calculated = 0;
  // https://docs.mql4.com/customind/indicatorcounted
  prev_calculated = _value > 0 ? _value : prev_calculated;
  return prev_calculated;
}
#endif

/* Common indicator line identifiers */

// @see: https://docs.mql4.com/constants/indicatorconstants/lines
// @see: https://www.mql5.com/en/docs/constants/indicatorconstants/lines

#ifndef __MQLBUILD__
// Indicator constants.
// @docs
// - https://www.mql5.com/en/docs/constants/indicatorconstants/lines
// Identifiers of indicator lines permissible when copying values of iMACD(), iRVI() and iStochastic().
#define MAIN_LINE 0    // Main line.
#define SIGNAL_LINE 1  // Signal line.
// Identifiers of indicator lines permissible when copying values of ADX() and ADXW().
#define MAIN_LINE 0     // Main line.
#define PLUSDI_LINE 1   // Line +DI.
#define MINUSDI_LINE 2  // Line -DI.
// Identifiers of indicator lines permissible when copying values of iBands().
#define BASE_LINE 0   // Main line.
#define UPPER_BAND 1  // Upper limit.
#define LOWER_BAND 2  // Lower limit.
// Identifiers of indicator lines permissible when copying values of iEnvelopes() and iFractals().
#define UPPER_LINE 0  // Upper line.
#define LOWER_LINE 1  // Bottom line.
#endif

// Defines.
#define ArrayResizeLeft(_arr, _new_size, _reserve_size)  \
  ArraySetAsSeries(_arr, true);                          \
  if (ArrayResize(_arr, _new_size, _reserve_size) < 0) { \
    return false;                                        \
  }                                                      \
  ArraySetAsSeries(_arr, false);

// Forward declarations.
class DrawIndicator;

#ifndef __MQLBUILD__
//
// Empty value in an indicator buffer.
// @docs
// - https://docs.mql4.com/constants/namedconstants/otherconstants
// - https://www.mql5.com/en/docs/constants/namedconstants/otherconstants
#define EMPTY_VALUE DBL_MAX
#endif

/**
 * Class to deal with indicators.
 */
class Indicator : public Chart {
 protected:
  // Structs.
  BufferStruct<IndicatorDataEntry> idata;
  DrawIndicator* draw;
  IndicatorParams iparams;
  IndicatorState istate;
  void* mydata;
  bool is_feeding;  // Whether FeedHistoryEntries is already working.
  bool is_fed;      // Whether FeedHistoryEntries already done its job.

 public:
  /* Indicator enumerations */

  /*
   * Default enumerations:
   *
   * ENUM_MA_METHOD values:
   *   0: MODE_SMA (Simple averaging)
   *   1: MODE_EMA (Exponential averaging)
   *   2: MODE_SMMA (Smoothed averaging)
   *   3: MODE_LWMA (Linear-weighted averaging)
   *
   * ENUM_APPLIED_PRICE values:
   *   0: PRICE_CLOSE (Close price)
   *   1: PRICE_OPEN (Open price)
   *   2: PRICE_HIGH (The maximum price for the period)
   *   3: PRICE_LOW (The minimum price for the period)
   *   4: PRICE_MEDIAN (Median price) = (high + low)/2
   *   5: PRICE_TYPICAL (Typical price) = (high + low + close)/3
   *   6: PRICE_WEIGHTED (Average price) = (high + low + close + close)/4
   *
   */

  /* Special methods */

  /**
   * Class constructor.
   */
  Indicator(IndicatorParams& _iparams) : Chart((ChartParams)_iparams), draw(NULL), is_feeding(false), is_fed(false) {
    iparams = _iparams;
    SetName(_iparams.name != "" ? _iparams.name : EnumToString(iparams.itype));
    InitDraw();
  }
  Indicator(const IndicatorParams& _iparams, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
      : Chart(_tf), draw(NULL), is_feeding(false), is_fed(false) {
    iparams = _iparams;
    SetName(_iparams.name != "" ? _iparams.name : EnumToString(iparams.itype));
    InitDraw();
  }
  Indicator(ENUM_INDICATOR_TYPE _itype, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, string _name = "")
      : Chart(_tf), draw(NULL), is_feeding(false), is_fed(false) {
    iparams.SetIndicatorType(_itype);
    SetName(_name != "" ? _name : EnumToString(iparams.itype));
    InitDraw();
  }

  /**
   * Class deconstructor.
   */
  ~Indicator() {
    ReleaseHandle();
    DeinitDraw();
    if (iparams.indi_data != NULL && iparams.indi_data_ownership) {
      delete iparams.indi_data;
    }
  }

  /* Init methods */

  /**
   * Initialize indicator data drawing on custom data.
   */
  bool InitDraw() {
    if (iparams.is_draw && !Object::IsValid(draw)) {
      draw = new DrawIndicator(&this);
      draw.SetColorLine(iparams.indi_color);
    }
    return iparams.is_draw;
  }

  /* Deinit methods */

  /**
   * Deinitialize drawing.
   */
  void DeinitDraw() {
    if (draw) {
      delete draw;
    }
  }

  /* Defines MQL backward compatible methods */

  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(DUMMY);
#endif
  }

  template <typename A>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(COMMA _a);
#endif
  }

  template <typename A, typename B>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(COMMA _a COMMA _b);
#endif
  }

  template <typename A, typename B, typename C>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, int _mode,
                 int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(COMMA _a COMMA _b COMMA _c);
#endif
  }

  template <typename A, typename B, typename C, typename D>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, int _mode,
                 int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(COMMA _a COMMA _b COMMA _c COMMA _d);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e,
                 int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, I _i, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h COMMA _i);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, I _i, J _j, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h COMMA _i COMMA _j);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J, typename K>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, I _i, J _j, K _k, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h COMMA _i COMMA _j COMMA _k);
#endif
  }

  /**
   * Initializes a cached proxy between i*OnArray() methods and OnCalculate()
   * used by custom indicators.
   *
   * Note that OnCalculateProxy() method sets incoming price array as not
   * series. It will be reverted back by SetPrevCalculated(). It is because
   * OnCalculate() methods assumes that prices are set as not series.
   *
   * For real example how you can use this method, look at
   * Indi_MA::iMAOnArray() method.
   *
   * Usage:
   *
   * static double iFooOnArray(double &price[], int total, int period,
   *   int foo_shift, int foo_method, int shift, string cache_name = "")
   * {
   *  if (cache_name != "") {
   *   String cache_key;
   *   cache_key.Add(cache_name);
   *   cache_key.Add(period);
   *   cache_key.Add(foo_method);
   *
   *   Ref<IndicatorCalculateCache> cache = Indicator::OnCalculateProxy(cache_key.ToString(), price, total);
   *
   *   int prev_calculated =
   *     Indi_Foo::Calculate(total, cache.Ptr().prev_calculated, 0, price, cache.Ptr().buffer1, ma_method, period);
   *
   *   cache.Ptr().SetPrevCalculated(price, prev_calculated);
   *
   *   return cache.Ptr().GetValue(1, shift + ma_shift);
   *  }
   *  else {
   *    // Default iFooOnArray.
   *  }
   *
   *  WARNING: Do not use shifts when creating cache_key, as this will create many invalid buffers.
   */
  static IndicatorCalculateCache OnCalculateProxy(string key, double& price[], int& total) {
    if (total == 0) {
      total = ArraySize(price);
    }

    // Stores previously calculated value.
    static DictStruct<string, IndicatorCalculateCache> cache;

    unsigned int position;
    IndicatorCalculateCache cache_item;

    if (cache.KeyExists(key, position)) {
      cache_item = cache.GetByKey(key);
    } else {
      IndicatorCalculateCache cache_item_new(1, ArraySize(price));
      cache_item = cache_item_new;
      cache.Set(key, cache_item);
    }

    // Number of bars available in the chart. Same as length of the input `array`.
    int rates_total = ArraySize(price);

    int begin = 0;

    cache_item.Resize(rates_total);

    cache_item.price_was_as_series = ArrayGetAsSeries(price);
    ArraySetAsSeries(price, false);

    return cache_item;
  }

  /**
   * Allocates memory for buffers used for custom indicator calculations.
   */
  static int IndicatorBuffers(int _count = 0) {
    static int indi_buffers = 1;
    indi_buffers = _count > 0 ? _count : indi_buffers;
    return indi_buffers;
  }
  static int GetIndicatorBuffers() { return Indicator::IndicatorBuffers(); }
  static bool SetIndicatorBuffers(int _count) {
    Indicator::IndicatorBuffers(_count);
    return GetIndicatorBuffers() > 0 && GetIndicatorBuffers() <= 512;
  }

  /* Operator overloading methods */

  /**
   * Access indicator entry data using [] operator.
   */
  IndicatorDataEntry operator[](int _shift) { return GetEntry(_shift); }
  IndicatorDataEntry operator[](ENUM_INDICATOR_INDEX _shift) { return GetEntry(_shift); }
  IndicatorDataEntry operator[](datetime _dt) { return idata[_dt]; }

  /* State methods */

  /**
   * Checks for crossover.
   *
   * @param
   *   Returns true when values are crossing over, otherwise false.
   */
  double IsCrossover(int _shift1 = 0, int _shift2 = 1, int _mode1 = 0, int _mode2 = 0) {
    double _curr_value1 = GetEntry(_shift1)[_mode1];
    double _prev_value1 = GetEntry(_shift2)[_mode1];
    double _curr_value2 = GetEntry(_shift1)[_mode2];
    double _prev_value2 = GetEntry(_shift2)[_mode2];
    return ((_curr_value1 > _prev_value1 && _curr_value2 < _prev_value2) ||
            (_prev_value1 > _curr_value1 && _prev_value2 < _curr_value2));
  }

  /* Getters */

  /**
   * Returns the lowest value.
   */
  /*
 double GetMinDbl(int start_bar, int count = WHOLE_ARRAY) {
   double min = NULL;
   int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

   for (int shift = start_bar; shift <= last_bar; ++shift) {
     double value = GetEntry(shift).GetMin(iparams.max_modes);
     if (min == NULL || value < min) {
       min = value;
     }
   }

   return min;
 }
 */

  /**
   * Returns the lowest bar's index (shift).
   */
  /*
 int GetLowest(int count = WHOLE_ARRAY, int start_bar = 0) {
   int min_idx = -1;
   double min = NULL;
   int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

   for (int shift = start_bar; shift <= last_bar; ++shift) {
     double value = GetEntry(shift).GetMin();
     if (min == NULL || value < min) {
       min = value;
       min_idx = shift;
     }
   }

   return min_idx;
 }
 */

  /**
   * Returns the highest value.
   */
  /*
 double GetMaxDbl(int start_bar = 0, int count = WHOLE_ARRAY) {
   double max = NULL;
   int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

   for (int shift = start_bar; shift <= last_bar; ++shift) {
     double value = GetEntry(shift).GetMax();
     if (max == NULL || value > max) {
       max = value;
     }
   }

   return max;
 }
 */

  /**
   * Returns the highest bar's index (shift).
   */
  /*
 int GetHighest(int count = WHOLE_ARRAY, int start_bar = 0) {
   int max_idx = -1;
   double max = NULL;
   int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

   for (int shift = start_bar; shift <= last_bar; ++shift) {
     double value = GetEntry(shift).GetMax();
     if (max == NULL || value > max) {
       max = value;
       max_idx = shift;
     }
   }

   return max_idx;
 }
 */

  /**
   * Returns average value.
   */
  /*
 double GetAvgDbl(int start_bar, ENUM_IDATA_VALUE_TYPE data_type, int count = WHOLE_ARRAY) {
   int num_values = 0;
   double sum = 0;
   int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

   for (int shift = start_bar; shift <= last_bar; ++shift) {
     double value_min = GetEntry(shift).GetMin();
     double value_max = GetEntry(shift).GetMax();

     sum += value_min + value_max;
     num_values += 2;
   }

   return sum / num_values;
 }
 */

  /**
   * Returns median of values.
   */
  /*
 double GetMedDbl(int start_bar, int count = WHOLE_ARRAY) {
   double array[];

   int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);
   int num_bars = last_bar - start_bar + 1;
   int index = 0;

   ArrayResize(array, num_bars);

   for (int shift = start_bar; shift <= last_bar; ++shift) {
     IndicatorDataEntry entry = GetEntry(shift);

     for (int type_size = int(iparams.dtype - TDBL1); type_size <= (int)iparams.dtype; ++type_size)
       array[index++] = entry.GetValue(int(type_size - TDBL1));
   }

   ArraySort(array);

   double median;

   int len = ArraySize(array);

   if (len % 2 == 0)
     median = (array[len / 2] + array[(len / 2) - 1]) / 2;
   else
     median = array[len / 2];

   return median;
 }
 */

  /**
   * Returns the lowest value.
   */
  /*
 int GetMinInt(int start_bar, int count = WHOLE_ARRAY) {
   int min = NULL;
   int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

   for (int shift = start_bar; shift <= last_bar; ++shift) {
     int value = GetEntry(shift).GetMinInt();
     if (min == NULL || value < min) {
       min = value;
     }
   }

   return min;
 }
 */

  /**
   * Returns the highest value.
   */
  /*
 int GetMaxInt(int start_bar, int count = WHOLE_ARRAY) {
   int max = NULL;
   int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

   for (int shift = start_bar; shift <= last_bar; ++shift) {
     int value = GetEntry(shift).GetMax();
     if (max == NULL || value > max) {
       max = value;
     }
   }

   return max;
 }
 */

  /**
   * Returns average value.
   */
  /*
 int GetAvgInt(int start_bar, ENUM_IDATA_VALUE_TYPE data_type, int count = WHOLE_ARRAY) {
   int num_values = 0;
   int sum = 0;
   int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

   for (int shift = start_bar; shift <= last_bar; ++shift) {
     int value_min = GetEntry(shift).GetMin();
     int value_max = GetEntry(shift).GetMax();

     sum += value_min + value_max;
     num_values += 2;
   }

   return sum / num_values;
 }
 */

  /**
   * Returns median of values.
   */
  /*
 int GetMedInt(int start_bar, int count = WHOLE_ARRAY) {
   int array[];

   int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);
   int num_bars = last_bar - start_bar + 1;
   int index = 0;

   ArrayResize(array, num_bars);

   for (int shift = start_bar; shift <= last_bar; ++shift) {
     IndicatorDataEntry entry = GetEntry(shift);

     for (int type_size = int(iparams.dtype - TINT1); type_size <= (int)iparams.dtype; ++type_size)
       array[index++] = entry.value.GetValueInt(int(type_size - TINT1));
   }

   ArraySort(array);

   int median;

   int len = ArraySize(array);

   if (len % 2 == 0)
     median = (array[len / 2] + array[(len / 2) - 1]) / 2;
   else
     median = array[len / 2];

   return median;
 }
 */

  /**
   * Gets indicator's params.
   */
  IndicatorParams GetParams() { return iparams; }

  /**
   * Get indicator type.
   */
  ENUM_INDICATOR_TYPE GetType() { return iparams.itype; }

  /**
   * Get pointer to data of indicator.
   */
  BufferStruct<IndicatorDataEntry>* GetData() { return GetPointer(idata); }

  /**
   * Get data type of indicator.
   */
  ENUM_DATATYPE GetDataType() { return iparams.dtype; }

  /**
   * Get name of the indicator.
   */
  string GetName() { return iparams.name; }

  /**
   * Get more descriptive name of the indicator.
   */
  string GetDescriptiveName() {
    string name = iparams.name + " (";

    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        name += "built-in, ";
        break;
      case IDATA_ICUSTOM:
        name += "custom, ";
        break;
      case IDATA_INDICATOR:
        name += "over " + iparams.indi_data.GetDescriptiveName() + ", ";
        break;
    }

    name += IntegerToString(iparams.max_modes) + (iparams.max_modes == 1 ? " mode" : " modes");

    return name + ")";
  }

  /**
   * Get indicator's state.
   */
  IndicatorState GetState() { return istate; }

  /* Setters */

  /**
   * Sets name of the indicator.
   */
  void SetName(string _name) { iparams.SetName(_name); }

  /**
   * Sets indicator's handle.
   *
   * Note: Not supported in MT4.
   */
  void SetHandle(int _handle) {
    istate.handle = _handle;
    istate.is_changed = true;
  }

  /**
   * Sets indicator's params.
   */
  void SetParams(IndicatorParams& _iparams) { iparams = _iparams; }

  /* Conditions */

  /**
   * Checks for indicator condition.
   *
   * @param ENUM_INDICATOR_CONDITION _cond
   *   Indicator condition.
   * @param MqlParam[] _args
   *   Condition arguments.
   * @return
   *   Returns true when the condition is met.
   */
  bool CheckCondition(ENUM_INDICATOR_CONDITION _cond, MqlParam& _args[]) {
    switch (_cond) {
      case INDI_COND_ENTRY_IS_MAX:
        // @todo: Add arguments, check if the entry value is max.
        return false;
      case INDI_COND_ENTRY_IS_MIN:
        // @todo: Add arguments, check if the entry value is min.
        return false;
      case INDI_COND_ENTRY_GT_AVG:
        // @todo: Add arguments, check if...
        // Indicator entry value is greater than average.
        return false;
      case INDI_COND_ENTRY_GT_MED:
        // @todo: Add arguments, check if...
        // Indicator entry value is greater than median.
        return false;
      case INDI_COND_ENTRY_LT_AVG:
        // @todo: Add arguments, check if...
        // Indicator entry value is lesser than average.
        return false;
      case INDI_COND_ENTRY_LT_MED:
        // @todo: Add arguments, check if...
        // Indicator entry value is lesser than median.
        return false;
      default:
        Logger().Error(StringFormat("Invalid indicator condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }
  bool CheckCondition(ENUM_INDICATOR_CONDITION _cond) {
    MqlParam _args[] = {};
    return Indicator::CheckCondition(_cond, _args);
  }

  /**
   * Execute Indicator action.
   *
   * @param ENUM_INDICATOR_ACTION _action
   *   Indicator action to execute.
   * @param MqlParam _args
   *   Indicator action arguments.
   * @return
   *   Returns true when the action has been executed successfully.
   */
  bool ExecuteAction(ENUM_INDICATOR_ACTION _action, MqlParam& _args[]) {
    bool _result = true;
    long _arg1 = ArraySize(_args) > 0 ? Convert::MqlParamToInteger(_args[0]) : WRONG_VALUE;
    switch (_action) {
      case INDI_ACTION_CLEAR_CACHE:
        _arg1 = _arg1 > 0 ? _arg1 : TimeCurrent();
        idata.Clear(_arg1);
        return true;
      default:
        Logger().Error(StringFormat("Invalid Indicator action: %s!", EnumToString(_action), __FUNCTION_LINE__));
        return false;
    }
    return _result;
  }
  bool ExecuteAction(ENUM_INDICATOR_ACTION _action) {
    MqlParam _args[] = {};
    return Indicator::ExecuteAction(_action, _args);
  }
  bool ExecuteAction(ENUM_INDICATOR_ACTION _action, long _arg1) {
    MqlParam _args[] = {{TYPE_LONG}};
    _args[0].integer_value = _arg1;
    return Indicator::ExecuteAction(_action, _args);
  }

  /* Other methods */

  /**
   * Releases indicator's handle.
   *
   * Note: Not supported in MT4.
   */
  void ReleaseHandle() {
#ifdef __MQL5__
    if (istate.handle != INVALID_HANDLE) {
      IndicatorRelease(istate.handle);
    }
#endif
    istate.handle = INVALID_HANDLE;
    istate.is_changed = true;
  }

  /**
   * Checks whether indicator has a valid value for a given shift.
   */
  virtual bool HasValidEntry(int _shift = 0) {
    unsigned int position;
    long bar_time = GetBarTime(_shift);

    if (idata.KeyExists(bar_time, position)) {
      return idata.GetByPos(position).IsValid();
    }

    return false;
  }

  /**
   * Adds entry to the indicator's buffer. Invalid entry won't be added.
   */
  bool AddEntry(IndicatorDataEntry& entry, int _shift = 0) {
    if (!entry.IsValid()) return false;

    datetime timestamp = GetBarTime(_shift);
    entry.timestamp = timestamp;
    idata.Add(entry, timestamp);

    return true;
  }

  /**
   * Returns shift at which the last known valid entry exists for a given
   * period (or from the start, when period is not specified).
   */
  bool GetLastValidEntryShift(int& out_shift, int period = 0) {
    out_shift = 0;

    while (true) {
      if ((period != 0 && out_shift >= period) || !HasValidEntry(out_shift + 1))
        return out_shift > 0;  // Current shift is always invalid.

      ++out_shift;
    }

    return out_shift > 0;
  }

  /**
   * Returns shift at which the oldest known valid entry exists for a given
   * period (or from the start, when period is not specified).
   */
  bool GetOldestValidEntryShift(int& out_shift, int& out_num_valid, int shift = 0, int period = 0) {
    bool found = false;
    // Counting from previous up to previous - period.
    for (out_shift = shift + 1; out_shift < shift + period + 1; ++out_shift) {
      if (!HasValidEntry(out_shift)) {
        --out_shift;
        out_num_valid = out_shift - shift;
        return found;
      } else
        found = true;
    }

    --out_shift;
    out_num_valid = out_shift - shift;
    return found;
  }

  /**
   * Checks whether indicator has valid at least given number of last entries
   * (counting from given shift or 0).
   */
  bool HasAtLeastValidLastEntries(int period, int shift = 0) {
    for (int i = 0; i < period; ++i)
      if (!HasValidEntry(shift + i)) return false;

    return true;
  }

  /**
   *
   */
  void FeedHistoryEntries(int period, int shift = 0) {
    if (is_feeding || is_fed) {
      // Avoiding forever loop.
      return;
    }

    is_feeding = true;

    for (int i = shift + period; i > shift; --i) {
      if (Chart::iPrice(PRICE_OPEN, GetSymbol(), GetTf(), i) <= 0) {
        // No data for that entry
        continue;
      }

      GetEntry(i);
    }

    is_feeding = false;
    is_fed = true;
  }

  template <typename T>
  T GetValue(int _shift = 0, int _mode = -1) {
    T _result;
    int _index = _mode != -1 ? _mode : iparams.indi_mode;
    GetEntry(_shift).values[_index].Get(_result);
    ResetLastError();
    return _result;
  }

  /**
   * Returns values for a given shift.
   *
   * Note: Remember to check if shift exists by HasValidEntry(shift).
   */
  template <typename T>
  bool GetValues(int _shift, T& _out1, T& _out2) {
    IndicatorDataEntry _entry = GetEntry(_shift);
    _out1 = _entry.values[0];
    _out2 = _entry.values[1];
    bool _result = GetLastError() != 4401;
    ResetLastError();
    return _result;
  }

  template <typename T>
  bool GetValues(int _shift, T& _out1, T& _out2, T& _out3) {
    IndicatorDataEntry _entry = GetEntry(_shift);
    _out1 = _entry.values[0];
    _out2 = _entry.values[1];
    _out3 = _entry.values[2];
    bool _result = GetLastError() != 4401;
    ResetLastError();
    return _result;
  }

  template <typename T>
  bool GetValues(int _shift, T& _out1, T& _out2, T& _out3, T& _out4) {
    IndicatorDataEntry _entry = GetEntry(_shift);
    _out1 = _entry.values[0];
    _out2 = _entry.values[1];
    _out3 = _entry.values[2];
    _out4 = _entry.values[3];
    bool _result = GetLastError() != 4401;
    ResetLastError();
    return _result;
  }

  virtual void OnTick() {
    Chart::OnTick();

    if (iparams.is_draw) {
      // Print("Drawing ", GetName(), iparams.indi_data != NULL ? (" (over " + iparams.indi_data.GetName() + ")") : "");
      for (int i = 0; i < (int)iparams.max_modes; ++i)
        draw.DrawLineTo(GetName() + "_" + IntegerToString(i) + "_" + IntegerToString(iparams.indi_mode), GetBarTime(0),
                        GetEntry(0)[i], iparams.draw_window);
    }
  }

  /* Data representation methods */

  /* Virtual methods */

  /**
   * Returns stored data in human-readable format.
   */
  // virtual bool ToString() = NULL; // @fixme?

  /**
   * Update indicator.
   */
  virtual bool Update();

  /**
   * Returns the indicator's struct value.
   */
  virtual IndicatorDataEntry GetEntry(int _shift = 0) = NULL;

  /**
   * Returns the indicator's entry value.
   */
  virtual MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift)[_mode];
    return _param;
  }

  /**
   * Returns the indicator's value in plain format.
   */
  virtual string ToString(int _shift = 0) {
    IndicatorDataEntry _entry = GetEntry(_shift);
    SerializerConverter _stub_indi = Serializer::MakeStubObject<IndicatorDataEntry>(SERIALIZER_FLAG_SKIP_HIDDEN);
    return SerializerConverter::FromObject(_entry, SERIALIZER_FLAG_SKIP_HIDDEN)
        .ToString<SerializerCsv>(SERIALIZER_FLAG_SKIP_HIDDEN, &_stub_indi);
  }
};
#endif

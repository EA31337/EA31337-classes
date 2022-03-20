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
 * Base interface for Indicator<T> class.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward declaration.
class Chart;

// Includes.
#include "Array.mqh"
#include "BufferStruct.mqh"
#include "Chart.mqh"
#include "DateTime.mqh"
#include "DrawIndicator.mqh"
#include "Indicator.define.h"
#include "Indicator.enum.h"
#include "Indicator.struct.cache.h"
#include "Indicator.struct.h"
#include "Indicator.struct.serialize.h"
#include "Indicator.struct.signal.h"
#include "Object.mqh"
#include "Refs.mqh"
#include "Serializer.mqh"
#include "SerializerCsv.mqh"
#include "SerializerJson.mqh"
#include "Storage/ValueStorage.h"
#include "Storage/ValueStorage.indicator.h"
#include "Storage/ValueStorage.native.h"
#include "Util.h"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compatibility).
bool IndicatorBuffers(int _count) { return Indicator<IndicatorParams>::SetIndicatorBuffers(_count); }
int IndicatorCounted(int _value = 0) {
  static int prev_calculated = 0;
  // https://docs.mql4.com/customind/indicatorcounted
  prev_calculated = _value > 0 ? _value : prev_calculated;
  return prev_calculated;
}
#endif

#ifdef __MQL5__
// Defines global functions (for MQL5 forward compatibility).
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
          typename J>
double iCustom5(string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h, I _i,
                J _j, int _mode, int _shift) {
  ResetLastError();
  static Dict<string, int> _handlers;
  string _key = Util::MakeKey(_symbol, (string)_tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _j);
  int _handle = _handlers.GetByKey(_key);
  ICUSTOM_DEF(_handlers.Set(_key, _handle),
              COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h COMMA _i COMMA _j);
}
template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
          typename J, typename K, typename L, typename M>
double iCustom5(string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f, G _g, H _h, I _i,
                J _j, K _k, L _l, M _m, int _mode, int _shift) {
  ResetLastError();
  static Dict<string, int> _handlers;
  string _key = Util::MakeKey(_symbol, (string)_tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _j);
  int _handle = _handlers.GetByKey(_key);
  ICUSTOM_DEF(_handlers.Set(_key, _handle), COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h
                                                COMMA _i COMMA _j COMMA _k COMMA _l COMMA _m);
}
#endif

/**
 * Class to deal with indicators.
 */
class IndicatorBase : public Chart {
 protected:
  BufferStruct<IndicatorDataEntry> idata;
  DrawIndicator* draw;
  IndicatorState istate;
  void* mydata;
  bool is_fed;                                     // Whether calc_start_bar is already calculated.
  int calc_start_bar;                              // Index of the first valid bar (from 0).
  DictStruct<int, Ref<IndicatorBase>> indicators;  // Indicators list keyed by id.
  bool indicator_builtin;
  ARRAY(ValueStorage<double>*, value_storages);
  Ref<IndicatorBase> indi_src;  // // Indicator used as data source.
  int indi_src_mode;            // Mode of source indicator
  IndicatorCalculateCache<double> cache;

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
   */

  /* Special methods */

  /**
   * Class constructor.
   */
  IndicatorBase() : indi_src(NULL) {
    calc_start_bar = 0;
    is_fed = false;
  }

  /**
   * Class constructor.
   */
  IndicatorBase(ChartParams& _cparams) : indi_src(NULL), Chart(_cparams) {
    calc_start_bar = 0;
    is_fed = false;
  }

  /**
   * Class constructor.
   */
  IndicatorBase(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, string _symbol = NULL) : Chart(_tf, _symbol) {
    calc_start_bar = 0;
    is_fed = false;
    indi_src = NULL;
  }

  /**
   * Class constructor.
   */
  IndicatorBase(ENUM_TIMEFRAMES_INDEX _tfi, string _symbol = NULL) : Chart(_tfi, _symbol) {
    calc_start_bar = 0;
    is_fed = false;
    indi_src = NULL;
  }

  /**
   * Class deconstructor.
   */
  virtual ~IndicatorBase() {
    ReleaseHandle();

    for (int i = 0; i < ArraySize(value_storages); ++i) {
      if (value_storages[i] != NULL) {
        delete value_storages[i];
      }
    }
  }

  /* Defines MQL backward compatible methods */

  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, DUMMY);
#endif
  }

  template <typename A>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a);
#endif
  }

  template <typename A, typename B>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b);
#endif
  }

  template <typename A, typename B, typename C>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, int _mode,
                 int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c);
#endif
  }

  template <typename A, typename B, typename C, typename D>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, int _mode,
                 int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e,
                 int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, I _i, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h COMMA _i);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, I _i, J _j, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h COMMA _i COMMA _j);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J, typename K>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, I _i, J _j, K _k, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h COMMA _i COMMA _j COMMA _k);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J, typename K, typename L, typename M>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, I _i, J _j, K _k, L _l, M _m, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h COMMA _i COMMA _j COMMA _k
                       COMMA _l COMMA _m);
#endif
  }

  /* Buffer methods */

  virtual string CacheKey() { return GetName(); }

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
  /*
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
  */

  /**
   * Gets indicator data from a buffer and copy into struct array.
   *
   * @return
   * Returns true of successful copy.
   * Returns false on invalid values.
   */
  bool CopyEntries(IndicatorDataEntry& _data[], int _count, int _start_shift = 0) {
    bool _is_valid = true;
    if (ArraySize(_data) < _count) {
      _is_valid &= ArrayResize(_data, _count) > 0;
    }
    for (int i = 0; i < _count; i++) {
      IndicatorDataEntry _entry = GetEntry(_start_shift + i);
      _is_valid &= _entry.IsValid();
      _data[i] = _entry;
    }
    return _is_valid;
  }

  /**
   * Gets indicator data from a buffer and copy into array of values.
   *
   * @return
   * Returns true of successful copy.
   * Returns false on invalid values.
   */
  template <typename T>
  bool CopyValues(T& _data[], int _count, int _start_shift = 0, int _mode = 0) {
    bool _is_valid = true;
    if (ArraySize(_data) < _count) {
      _count = ArrayResize(_data, _count);
      _count = _count > 0 ? _count : ArraySize(_data);
    }
    for (int i = 0; i < _count; i++) {
      IndicatorDataEntry _entry = GetEntry(_start_shift + i);
      _is_valid &= _entry.IsValid();
      _data[i] = (T)_entry[_mode];
    }
    return _is_valid;
  }

  /**
   * Validates currently selected indicator used as data source.
   */
  void ValidateSelectedDataSource() {
    if (HasDataSource()) {
      ValidateDataSource(THIS_PTR, GetDataSourceRaw());
    }
  }

  /**
   * Loads and validates built-in indicators whose can be used as data source.
   */
  virtual void ValidateDataSource(IndicatorBase* _target, IndicatorBase* _source) {}

  /**
   * Checks whether indicator have given mode index.
   *
   * If given mode is -1 (default one) and indicator has exactly one mode, then mode index will be replaced by 0.
   */
  virtual void ValidateDataSourceMode(int& _out_mode) {}

  /**
   * Provides built-in indicators whose can be used as data source.
   */
  virtual IndicatorBase* FetchDataSource(ENUM_INDICATOR_TYPE _id) { return NULL; }

  /**
   * Returns currently selected data source without any validation.
   */
  IndicatorBase* GetDataSourceRaw() { return indi_src.Ptr(); }

  /* Operator overloading methods */

  /**
   * Access indicator entry data using [] operator.
   */
  IndicatorDataEntry operator[](int _shift) { return GetEntry(_shift); }
  IndicatorDataEntry operator[](ENUM_INDICATOR_INDEX _shift) { return GetEntry(_shift); }
  IndicatorDataEntry operator[](datetime _dt) { return idata[_dt]; }

  /* Getters */

  /**
   * Returns buffers' cache.
   */
  IndicatorCalculateCache<double>* GetCache() { return &cache; }

  /**
   * Gets an indicator's chart parameter value.
   */
  template <typename T>
  T Get(ENUM_CHART_PARAM _param) {
    return Chart::Get<T>(_param);
  }

  /**
   * Gets an indicator's state property value.
   */
  template <typename T>
  T Get(STRUCT_ENUM(IndicatorState, ENUM_INDICATOR_STATE_PROP) _prop) {
    return istate.Get<T>(_prop);
  }

  /**
   * Gets number of modes available to retrieve by GetValue().
   */
  virtual int GetModeCount() { return 0; }

  /* State methods */

  /**
   * Checks for crossover.
   *
   * @return
   *   Returns true when values are crossing over, otherwise false.
   */
  bool IsCrossover(int _shift1 = 0, int _shift2 = 1, int _mode1 = 0, int _mode2 = 0) {
    double _curr_value1 = GetEntry(_shift1)[_mode1];
    double _prev_value1 = GetEntry(_shift2)[_mode1];
    double _curr_value2 = GetEntry(_shift1)[_mode2];
    double _prev_value2 = GetEntry(_shift2)[_mode2];
    return ((_curr_value1 > _prev_value1 && _curr_value2 < _prev_value2) ||
            (_prev_value1 > _curr_value1 && _prev_value2 < _curr_value2));
  }

  /**
   * Checks if values are decreasing.
   *
   * @param int _rows
   *   Numbers of rows to check.
   * @param int _mode
   *   Indicator index mode to check.
   * @param int _shift
   *   Shift which is the final value to take into the account.
   *
   * @return
   *   Returns true when values are increasing.
   */
  bool IsDecreasing(int _rows = 1, int _mode = 0, int _shift = 0) {
    bool _result = true;
    for (int i = _shift + _rows - 1; i >= _shift && _result; i--) {
      IndicatorDataEntry _entry_curr = GetEntry(i);
      IndicatorDataEntry _entry_prev = GetEntry(i + 1);
      _result &= _entry_curr.IsValid() && _entry_prev.IsValid() && _entry_curr[_mode] < _entry_prev[_mode];
      if (!_result) {
        break;
      }
    }
    return _result;
  }

  /**
   * Checks if value decreased by the given percentage value.
   *
   * @param int _pct
   *   Percentage value to use for comparison.
   * @param int _mode
   *   Indicator index mode to use.
   * @param int _shift
   *   Indicator value shift to use.
   * @param int _count
   *   Count of bars to compare change backward.
   * @param int _hundreds
   *   When true, use percentage in hundreds, otherwise 1 is 100%.
   *
   * @return
   *   Returns true when value increased.
   */
  bool IsDecByPct(float _pct, int _mode = 0, int _shift = 0, int _count = 1, bool _hundreds = true) {
    bool _result = true;
    IndicatorDataEntry _v0 = GetEntry(_shift);
    IndicatorDataEntry _v1 = GetEntry(_shift + _count);
    _result &= _v0.IsValid() && _v1.IsValid();
    _result &= _result && Math::ChangeInPct(_v1[_mode], _v0[_mode], _hundreds) < _pct;
    return _result;
  }

  /**
   * Checks if values are increasing.
   *
   * @param int _rows
   *   Numbers of rows to check.
   * @param int _mode
   *   Indicator index mode to check.
   * @param int _shift
   *   Shift which is the final value to take into the account.
   *
   * @return
   *   Returns true when values are increasing.
   */
  bool IsIncreasing(int _rows = 1, int _mode = 0, int _shift = 0) {
    bool _result = true;
    for (int i = _shift + _rows - 1; i >= _shift && _result; i--) {
      IndicatorDataEntry _entry_curr = GetEntry(i);
      IndicatorDataEntry _entry_prev = GetEntry(i + 1);
      _result &= _entry_curr.IsValid() && _entry_prev.IsValid() && _entry_curr[_mode] > _entry_prev[_mode];
      if (!_result) {
        break;
      }
    }
    return _result;
  }

  /**
   * Checks if value increased by the given percentage value.
   *
   * @param int _pct
   *   Percentage value to use for comparison.
   * @param int _mode
   *   Indicator index mode to use.
   * @param int _shift
   *   Indicator value shift to use.
   * @param int _count
   *   Count of bars to compare change backward.
   * @param int _hundreds
   *   When true, use percentage in hundreds, otherwise 1 is 100%.
   *
   * @return
   *   Returns true when value increased.
   */
  bool IsIncByPct(float _pct, int _mode = 0, int _shift = 0, int _count = 1, bool _hundreds = true) {
    bool _result = true;
    IndicatorDataEntry _v0 = GetEntry(_shift);
    IndicatorDataEntry _v1 = GetEntry(_shift + _count);
    _result &= _v0.IsValid() && _v1.IsValid();
    _result &= _result && Math::ChangeInPct(_v1[_mode], _v0[_mode], _hundreds) > _pct;
    return _result;
  }

  /* Getters */

  /**
   * Whether data source is selected.
   */
  virtual bool HasDataSource() { return false; }

  /**
   * Returns currently selected data source doing validation.
   */
  virtual IndicatorBase* GetDataSource() { return NULL; }

  int GetDataSourceMode() { return indi_src_mode; }

  /**
   * Gets indicator's symbol.
   */
  string GetSymbol() { return Get<string>(CHART_PARAM_SYMBOL); }

  /**
   * Gets indicator's time-frame.
   */
  ENUM_TIMEFRAMES GetTf() { return Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF); }

  /**
   * Gets indicator's signals.
   *
   * When indicator values are not valid, returns empty signals.
   */
  virtual IndicatorSignal GetSignals(int _count = 3, int _shift = 0, int _mode1 = 0, int _mode2 = 0) {
    IndicatorSignal _signal;
    return _signal;
  }

  /**
   * Get indicator type.
   */
  virtual ENUM_INDICATOR_TYPE GetType() { return INDI_NONE; }

  /**
   * Get pointer to data of indicator.
   */
  BufferStruct<IndicatorDataEntry>* GetData() { return GetPointer(idata); }

  /**
   * Get data type of indicator.
   */
  virtual ENUM_DATATYPE GetDataType() { return (ENUM_DATATYPE)-1; }

  /**
   * Get name of the indicator.
   */
  virtual string GetName() { return "<Unknown>"; }

  /**
   * Get full name of the indicator (with "over ..." part).
   */
  virtual string GetFullName() { return GetName(); }

  /**
   * Get more descriptive name of the indicator.
   */
  virtual string GetDescriptiveName() { return GetName(); }

  /* Setters */

  /**
   * Sets an indicator's chart parameter value.
   */
  template <typename T>
  void Set(ENUM_CHART_PARAM _param, T _value) {
    Chart::Set<T>(_param, _value);
  }

  /**
   * Sets an indicator's state property value.
   */
  template <typename T>
  void Set(STRUCT_ENUM(IndicatorState, ENUM_INDICATOR_STATE_PROP) _prop, T _value) {
    istate.Set<T>(_prop, _value);
  }

  /**
   * Sets indicator data source.
   */
  virtual void SetDataSource(IndicatorBase* _indi, int _input_mode = 0) = NULL;

  /**
   * Sets data source's input mode.
   */
  void SetDataSourceMode(int _mode) { indi_src_mode = _mode; }

  /**
   * Sets name of the indicator.
   */
  virtual void SetName(string _name) {}

  /**
   * Sets indicator's handle.
   *
   * Note: Not supported in MT4.
   */
  virtual void SetHandle(int _handle) {}

  /**
   * Sets indicator's symbol.
   */
  void SetSymbol(string _symbol) { Set<string>(CHART_PARAM_SYMBOL, _symbol); }

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
  bool CheckCondition(ENUM_INDICATOR_CONDITION _cond, DataParamEntry& _args[]) {
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
        GetLogger().Error(StringFormat("Invalid indicator condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }
  bool CheckCondition(ENUM_INDICATOR_CONDITION _cond) {
    ARRAY(DataParamEntry, _args);
    return IndicatorBase::CheckCondition(_cond, _args);
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
  virtual bool ExecuteAction(ENUM_INDICATOR_ACTION _action, DataParamEntry& _args[]) {
    bool _result = true;
    long _arg1 = ArraySize(_args) > 0 ? DataParamEntry::ToInteger(_args[0]) : WRONG_VALUE;
    switch (_action) {
      case INDI_ACTION_CLEAR_CACHE:
        _arg1 = _arg1 > 0 ? _arg1 : TimeCurrent();
        idata.Clear(_arg1);
        return true;
      default:
        GetLogger().Error(StringFormat("Invalid Indicator action: %s!", EnumToString(_action), __FUNCTION_LINE__));
        return false;
    }
    return _result;
  }
  bool ExecuteAction(ENUM_INDICATOR_ACTION _action) {
    ARRAY(DataParamEntry, _args);
    return ExecuteAction(_action, _args);
  }
  bool ExecuteAction(ENUM_INDICATOR_ACTION _action, long _arg1) {
    ARRAY(DataParamEntry, _args);
    DataParamEntry _param1 = _arg1;
    ArrayPushObject(_args, _param1);
    _args[0].integer_value = _arg1;
    return ExecuteAction(_action, _args);
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

  virtual ENUM_IDATA_VALUE_RANGE GetIDataValueRange() = 0;

  ValueStorage<double>* GetValueStorage(int _mode = 0) {
    if (value_storages[_mode] == NULL) {
      value_storages[_mode] = new IndicatorBufferValueStorage<double>(THIS_PTR, _mode);
    }
    return value_storages[_mode];
  }

  template <typename T>
  T GetValue(int _shift = 0, int _mode = 0) {
    T _out;
    GetEntryValue(_shift, _mode).Get(_out);
    return _out;
  }

  /**
   * Returns price corresponding to indicator value for a given shift and mode.
   *
   * Can be useful for calculating trailing stops based on the indicator.
   *
   * @return
   * Returns price value of the corresponding indicator values.
   */
  template <typename T>
  float GetValuePrice(int _shift = 0, int _mode = 0, ENUM_APPLIED_PRICE _ap = PRICE_TYPICAL) {
    float _price = 0;
    if (GetIDataValueRange() != IDATA_RANGE_PRICE) {
      _price = (float)GetPrice(_ap, _shift);
    } else if (GetIDataValueRange() == IDATA_RANGE_PRICE) {
      // When indicator values are the actual prices.
      T _values[4];
      if (!CopyValues(_values, 4, _shift, _mode)) {
        // When values aren't valid, return 0.
        return _price;
      }
      datetime _bar_time = GetBarTime(_shift);
      float _value = 0;
      BarOHLC _ohlc(_values, _bar_time);
      _price = _ohlc.GetAppliedPrice(_ap);
    }
    return _price;
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

  virtual void OnTick() {}

  /* Data representation methods */

  /* Virtual methods */

  /**
   * Returns the indicator's struct value.
   */
  virtual IndicatorDataEntry GetEntry(int _shift = -1) = NULL;

  /**
   * Alters indicator's struct value.
   *
   * This method allows user to modify the struct entry before it's added to cache.
   * This method is called on GetEntry() right after values are set.
   */
  virtual void GetEntryAlter(IndicatorDataEntry& _entry, int _shift = -1) = NULL;

  /**
   * Returns the indicator's entry value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) = NULL;

  /**
   * Returns indicator value for a given shift and mode.
   */
  // virtual double GetValue(int _shift = -1, int _mode = 0) = NULL;

  /**
   * Checks whether indicator has a valid value for a given shift.
   */
  virtual bool HasValidEntry(int _shift = 0) {
    unsigned int position;
    long bar_time = GetBarTime(_shift);
    return bar_time > 0 && idata.KeyExists(bar_time, position) ? idata.GetByPos(position).IsValid() : false;
  }

  /**
   * Returns stored data in human-readable format.
   */
  // virtual bool ToString() = NULL; // @fixme?

  /**
   * Whether we can and have to select mode when specifying data source.
   */
  virtual bool IsDataSourceModeSelectable() { return true; }

  /**
   * Update indicator.
   */
  virtual bool Update() {
    // @todo
    return false;
  };

  /**
   * Returns the indicator's value in plain format.
   */
  virtual string ToString(int _shift = 0) {
    IndicatorDataEntry _entry = GetEntry(_shift);
    int _serializer_flags = SERIALIZER_FLAG_SKIP_HIDDEN | SERIALIZER_FLAG_INCLUDE_DEFAULT |
                            SERIALIZER_FLAG_INCLUDE_DYNAMIC | SERIALIZER_FLAG_INCLUDE_FEATURE;

    IndicatorDataEntry _stub_entry;
    _stub_entry.AddFlags(_entry.GetFlags());
    SerializerConverter _stub = SerializerConverter::MakeStubObject(_stub_entry, _serializer_flags, _entry.GetSize());
    return SerializerConverter::FromObject(_entry, _serializer_flags).ToString<SerializerCsv>(0, &_stub);
  }

  int GetBarsCalculated() {
    int _bars = Bars(GetSymbol(), GetTf());

    if (!is_fed) {
      // Calculating start_bar.
      for (; calc_start_bar < _bars; ++calc_start_bar) {
        // Iterating from the oldest or previously iterated.
        IndicatorDataEntry _entry = GetEntry(_bars - calc_start_bar - 1);

        if (_entry.IsValid()) {
          // From this point we assume that future entries will be all valid.
          is_fed = true;
          return _bars - calc_start_bar;
        }
      }
    }

    if (!is_fed) {
      Print("Can't find valid bars for ", GetFullName());
      return 0;
    }

    // Assuming all entries are calculated (even if have invalid values).
    return _bars;
  }
};

/**
 * CopyBuffer() method to be used on Indicator instance with ValueStorage buffer.
 *
 * Note that data will be copied so that the oldest element will be located at the start of the physical memory
 * allocated for the array
 */
template <typename T>
int CopyBuffer(IndicatorBase* _indi, int _mode, int _start, int _count, ValueStorage<T>& _buffer, int _rates_total) {
  int _num_copied = 0;
  int _buffer_size = ArraySize(_buffer);

  if (_buffer_size < _rates_total) {
    _buffer_size = ArrayResize(_buffer, _rates_total);
  }

  for (int i = _start; i < _count; ++i) {
    IndicatorDataEntry _entry = _indi.GetEntry(i);

    if (!_entry.IsValid()) {
      break;
    }

    T _value = _entry.GetValue<T>(_mode);

    //    Print(_value);

    _buffer[_buffer_size - i - 1] = _value;
    ++_num_copied;
  }

  return _num_copied;
}

/**
 * BarsCalculated()-compatible method to be used on Indicator instance.
 */
int BarsCalculated(IndicatorBase* _indi) { return _indi.GetBarsCalculated(); }

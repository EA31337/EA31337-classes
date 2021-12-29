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

/**
 * Class to deal with indicators.
 */
class IndicatorBase : public Chart {
 protected:
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
  ARRAY(WeakRef<IndicatorBase>, listeners);  // List of indicators that listens for events from this one.
  long last_tick_time;                       // Time of the last Tick() call.

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
  IndicatorBase(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, string _symbol = NULL) : indi_src(NULL), Chart(_tf, _symbol) {
    calc_start_bar = 0;
    is_fed = false;
    indi_src = NULL;
    last_tick_time = 0;
  }

  /**
   * Class constructor.
   */
  IndicatorBase(ENUM_TIMEFRAMES_INDEX _tfi, string _symbol = NULL) : Chart(_tfi, _symbol) {
    calc_start_bar = 0;
    is_fed = false;
    indi_src = NULL;
    last_tick_time = 0;
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

  /* Operator overloading methods */

  /**
   * Access indicator entry data using [] operator.
   */
  // IndicatorDataEntry operator[](datetime _dt) { return GetEntry(_dt); }
  IndicatorDataEntry operator[](int _index) { return GetEntry(_index); }
  IndicatorDataEntry operator[](ENUM_INDICATOR_INDEX _index) { return GetEntry(_index); }

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

  /**
   * Returns given data source type. Used by i*OnIndicator methods if indicator's Calculate() uses other indicators.
   */
  IndicatorBase* GetDataSource(ENUM_INDICATOR_TYPE _type) {
    IndicatorBase* _result = NULL;
    if (indicators.KeyExists((int)_type)) {
      _result = indicators[(int)_type].Ptr();
    } else {
      Ref<IndicatorBase> _indi = FetchDataSource(_type);
      if (!_indi.IsSet()) {
        Alert(GetFullName(), " does not define required indicator type ", EnumToString(_type), " for symbol ",
              GetSymbol(), ", and timeframe ", GetTf(), "!");
        DebugBreak();
      } else {
        indicators.Set((int)_type, _indi);
        _result = _indi.Ptr();
      }
    }
    return _result;
  }

  /**
   * Called if data source is requested, but wasn't yet set. May be used to initialize indicators that must operate on
   * some data source.
   */
  virtual IndicatorBase* OnDataSourceRequest() {
    Print("In order to use IDATA_INDICATOR mode for indicator ", GetFullName(),
          " without explicitly selecting an indicator, ", GetFullName(),
          " must override OnDataSourceRequest() method and return new instance of data source to be used by default.");
    DebugBreak();
    return NULL;
  }

  /**
   * Creates default, tick based indicator for given applied price.
   */
  IndicatorBase* DataSourceRequestReturnDefault(int _applied_price) {
    // Returning real candle indicator. Thus way we can use SetAppliedPrice() and select Ask or Bid price.
    switch (_applied_price) {
      case PRICE_ASK:
      case PRICE_BID:
        return new IndicatorTickReal(GetTf());
      case PRICE_OPEN:
      case PRICE_HIGH:
      case PRICE_LOW:
      case PRICE_CLOSE:
      case PRICE_MEDIAN:
      case PRICE_TYPICAL:
      case PRICE_WEIGHTED:
        return new IndicatorTfDummy(GetTf());
    }

    Print("Passed wrong value for applied price for ", GetFullName(), " indicator!");
    DebugBreak();
    return NULL;
  }

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

  /* Getters */

  /**
   * Whether data source is selected.
   */
  virtual bool HasDataSource(bool _try_initialize = false) { return false; }

  /**
   * Returns currently selected data source doing validation.
   */
  virtual IndicatorBase* GetDataSource() { return NULL; }

  int GetDataSourceMode() { return indi_src_mode; }

  /**
   * Get indicator type.
   */
  virtual ENUM_INDICATOR_TYPE GetType() { return INDI_NONE; }

  /**
   * Get data type of indicator.
   */
  virtual ENUM_DATATYPE GetDataType() { return (ENUM_DATATYPE)-1; }

  /**
   * Get name of the indicator.
   */
  virtual string GetName() { return EnumToString(GetType()); }

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
   * Adds event listener.
   */
  void AddListener(IndicatorBase* _indi) {
    WeakRef<IndicatorBase> _ref = _indi;
    ArrayPushObject(listeners, _ref);
  }

  /**
   * Removes event listener.
   */
  void RemoveListener(IndicatorBase* _indi) {
    WeakRef<IndicatorBase> _ref = _indi;
    Util::ArrayRemoveFirst(listeners, _ref);
  }

  /**
   * Sets indicator data source.
   */
  virtual void SetDataSource(IndicatorBase* _indi, int _input_mode = -1) = NULL;

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

  ValueStorage<double>* GetValueStorage(int _mode = 0) {
    if (_mode >= ArraySize(value_storages)) {
      ArrayResize(value_storages, _mode + 1);
    }

    if (value_storages[_mode] == NULL) {
      value_storages[_mode] = new IndicatorBufferValueStorage<double>(THIS_PTR, _mode);
    }
    return value_storages[_mode];
  }

  /**
   * Returns value storage of given kind.
   */
  virtual IValueStorage* GetSpecificValueStorage(ENUM_INDI_VS_TYPE _type) {
    Print("Error: ", GetFullName(), " indicator has no storage type ", EnumToString(_type), "!");
    DebugBreak();
    return NULL;
  }

  virtual IValueStorage* GetSpecificAppliedPriceValueStorage(ENUM_APPLIED_PRICE _ap) {
    switch (_ap) {
      case PRICE_ASK:
        return GetSpecificValueStorage(INDI_VS_TYPE_PRICE_ASK);
      case PRICE_BID:
        return GetSpecificValueStorage(INDI_VS_TYPE_PRICE_BID);
      case PRICE_OPEN:
        return GetSpecificValueStorage(INDI_VS_TYPE_PRICE_OPEN);
      case PRICE_HIGH:
        return GetSpecificValueStorage(INDI_VS_TYPE_PRICE_HIGH);
      case PRICE_LOW:
        return GetSpecificValueStorage(INDI_VS_TYPE_PRICE_LOW);
      case PRICE_CLOSE:
        return GetSpecificValueStorage(INDI_VS_TYPE_PRICE_CLOSE);
      case PRICE_MEDIAN:
      case PRICE_TYPICAL:
      case PRICE_WEIGHTED:
      default:
        Print("Error: Invalid applied price " + EnumToString(_ap) +
              ", only PRICE_(OPEN|HIGH|LOW|CLOSE) are currently supported by "
              "IndicatorBase::GetSpecificAppliedPriceValueStorage()!");
        DebugBreak();
        return NULL;
    }
  }

  virtual bool HasSpecificAppliedPriceValueStorage(ENUM_APPLIED_PRICE _ap) {
    switch (_ap) {
      case PRICE_ASK:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_ASK);
      case PRICE_BID:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_BID);
      case PRICE_OPEN:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_OPEN);
      case PRICE_HIGH:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_HIGH);
      case PRICE_LOW:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_LOW);
      case PRICE_CLOSE:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_CLOSE);
      case PRICE_MEDIAN:
      case PRICE_TYPICAL:
      case PRICE_WEIGHTED:
      default:
        Print("Error: Invalid applied price " + EnumToString(_ap) +
              ", only PRICE_(OPEN|HIGH|LOW|CLOSE) are currently supported by "
              "IndicatorBase::HasSpecificAppliedPriceValueStorage()!");
        DebugBreak();
        return false;
    }
  }

  /**
   * Checks whether indicator support given value storage type.
   */
  virtual bool HasSpecificValueStorage(ENUM_INDI_VS_TYPE _type) { return false; }

  template <typename T>
  T GetValue(int _index = 0, int _mode = 0) {
    T _out;
    GetEntryValue(_index, _mode).Get(_out);
    return _out;
  }

  /**
   * Returns values for a given shift.
   *
   * Note: Remember to check if shift exists by HasValidEntry(shift).
   */
  template <typename T>
  bool GetValues(int _index, T& _out1, T& _out2) {
    IndicatorDataEntry _entry = GetEntry(_index);
    _out1 = _entry.values[0];
    _out2 = _entry.values[1];
    bool _result = GetLastError() != 4401;
    ResetLastError();
    return _result;
  }

  template <typename T>
  bool GetValues(int _index, T& _out1, T& _out2, T& _out3) {
    IndicatorDataEntry _entry = GetEntry(_index);
    _out1 = _entry.values[0];
    _out2 = _entry.values[1];
    _out3 = _entry.values[2];
    bool _result = GetLastError() != 4401;
    ResetLastError();
    return _result;
  }

  template <typename T>
  bool GetValues(int _index, T& _out1, T& _out2, T& _out3, T& _out4) {
    IndicatorDataEntry _entry = GetEntry(_index);
    _out1 = _entry.values[0];
    _out2 = _entry.values[1];
    _out3 = _entry.values[2];
    _out4 = _entry.values[3];
    bool _result = GetLastError() != 4401;
    ResetLastError();
    return _result;
  }

  void Tick() {
    long _current_time = TimeCurrent();

    if (last_tick_time == _current_time) {
      // We've already ticked.
      return;
    }

    last_tick_time = _current_time;

    // Overridable OnTick() method.
    OnTick();

    // Checking and potentially initializing new data source.
    if (HasDataSource(true) != NULL) {
      // Ticking data source if not yet ticked.
      GetDataSource().Tick();
    }

    // Also ticking all used indicators if they've not yet ticked.
    for (DictStructIterator<int, Ref<IndicatorBase>> iter = indicators.Begin(); iter.IsValid(); ++iter) {
      iter.Value().Ptr().Tick();
    }
  }

  virtual void OnTick() {}

  /* Data representation methods */

  /* Virtual methods */

  /**
   * Returns the indicator's struct value.
   */
  virtual IndicatorDataEntry GetEntry(int _index = 0) = NULL;

  /**
   * Alters indicator's struct value.
   *
   * This method allows user to modify the struct entry before it's added to cache.
   * This method is called on GetEntry() right after values are set.
   */
  virtual void GetEntryAlter(IndicatorDataEntry& _entry, int _index = -1) = NULL;

  // virtual ENUM_IDATA_VALUE_RANGE GetIDataValueRange() = NULL;

  /**
   * Returns the indicator's entry value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _index = -1) = NULL;

  /**
   * Sends entry to listening indicators.
   */
  void EmitEntry(IndicatorDataEntry& entry) {
    for (int i = 0; i < ArraySize(listeners); ++i) {
      if (listeners[i].ObjectExists()) {
        listeners[i].Ptr().OnDataSourceEntry(entry);
      }
    }
  }

  /**
   * Sends historic entries to listening indicators. May be overriden.
   */
  virtual void EmitHistory() {}

  /**
   * Called when data source emits new entry (historic or future one).
   */
  virtual void OnDataSourceEntry(IndicatorDataEntry& entry){};

  /**
   * Called when indicator became a data source for other indicator.
   */
  virtual void OnBecomeDataSourceFor(IndicatorBase* _base_indi){};

  /**
   * Called when user tries to set given data source. Could be used to check if indicator implements all required value
   * storages.
   */
  virtual bool OnValidateDataSource(IndicatorBase* _ds, string& _reason) {
    _reason = "Indicator " + GetName() + " does not implement OnValidateDataSource()";
    return false;
  }

  /**
   * Returns indicator value for a given shift and mode.
   */
  // virtual double GetValue(int _shift = 0, int _mode = 0) = NULL;

  /**
   * Checks whether indicator has a valid value for a given shift.
   */
  /*
  virtual bool HasValidEntry(int _index = 0) {
    unsigned int position;
    long bar_time = GetBarTime(_index);
    return bar_time > 0 && idata.KeyExists(bar_time, position) ? idata.GetByPos(position).IsValid() : false;
  }
  */

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
  virtual string ToString(int _index = 0) {
    IndicatorDataEntry _entry = GetEntry(_index);
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

  /* Methods to get rid of */

  /**
   * Gets indicator's symbol.
   */
  string GetSymbol() { return Get<string>(CHART_PARAM_SYMBOL); }

  /**
   * Gets indicator's time-frame.
   */
  ENUM_TIMEFRAMES GetTf() { return Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF); }

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

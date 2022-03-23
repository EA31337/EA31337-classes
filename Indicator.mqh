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
#include "Indicator.define.h"
#include "Indicator.enum.h"
#include "Indicator.struct.cache.h"
#include "Indicator.struct.h"
#include "Indicator.struct.serialize.h"
#include "Indicator.struct.signal.h"
#include "IndicatorBase.h"
#include "Math.h"
#include "Object.mqh"
#include "Refs.mqh"
#include "Serializer.mqh"
#include "SerializerCsv.mqh"
#include "SerializerJson.mqh"
#include "Storage/ValueStorage.h"
#include "Storage/ValueStorage.indicator.h"
#include "Storage/ValueStorage.native.h"

/**
 * Class to deal with indicators.
 */
template <typename TS>
class Indicator : public IndicatorBase {
 protected:
  // Structs.
  TS iparams;

 protected:
  /* Protected methods */

  /**
   * It's called on class initialization.
   */
  bool Init() {
    ArrayResize(value_storages, iparams.GetMaxModes());
    switch (iparams.GetDataSourceType()) {
      case IDATA_BUILTIN:
        break;
      case IDATA_ICUSTOM:
        break;
      case IDATA_INDICATOR:
        if (!indi_src.IsSet()) {
          // Indi_Price* _indi_price = Indi_Price::GetCached(GetSymbol(), GetTf(), iparams.GetShift());
          // SetDataSource(_indi_price, true, PRICE_OPEN);
        }
        break;
    }
    return InitDraw();
  }

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
  Indicator(const TS& _iparams, IndicatorBase* _indi_src = NULL, int _indi_mode = 0)
      : IndicatorBase(_iparams.GetTf(), NULL) {
    iparams = _iparams;
    SetName(_iparams.name != "" ? _iparams.name : EnumToString(iparams.itype));
    if (_indi_src != NULL) {
      SetDataSource(_indi_src, _indi_mode);
    }
    Init();
  }
  Indicator(const TS& _iparams, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : IndicatorBase(_tf) {
    iparams = _iparams;
    SetName(_iparams.name != "" ? _iparams.name : EnumToString(iparams.itype));
    Init();
  }
  Indicator(ENUM_INDICATOR_TYPE _itype, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0, string _name = "")
      : IndicatorBase(_tf) {
    iparams.SetIndicatorType(_itype);
    iparams.SetShift(_shift);
    SetName(_name != "" ? _name : EnumToString(iparams.itype));
    Init();
  }

  /**
   * Class deconstructor.
   */
  ~Indicator() { DeinitDraw(); }

  /**
   * Initialize indicator data drawing on custom data.
   */
  bool InitDraw() {
    if (iparams.is_draw && !Object::IsValid(draw)) {
      draw = new DrawIndicator(THIS_PTR);
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

  /* Getters */

  /**
   * Gets an indicator property flag.
   */
  bool GetFlag(INDICATOR_ENTRY_FLAGS _prop, int _shift = -1) {
    IndicatorDataEntry _entry = GetEntry(_shift >= 0 ? _shift : iparams.GetShift());
    return _entry.CheckFlag(_prop);
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
   * CopyBuffer() method to be used on Indicator instance with ValueStorage buffer.
   *
   * Note that data will be copied so that the oldest element will be located at the start of the physical memory
   * allocated for the array
   */
  /*
  static int CopyBuffer(IndicatorBase * _indi, int _mode, int _start, int _count, ValueStorage<T>& _buffer,
  int _rates_total) { int _num_copied = 0; int _buffer_size = ArraySize(_buffer);

    if (_buffer_size < _rates_total) {
      _buffer_size = ArrayResize(_buffer, _rates_total);
    }

    for (int i = _start; i < _count; ++i) {
      IndicatorDataEntry _entry = _indi.GetEntry(i);

      if (!_entry.IsValid()) {
        break;
      }

      T _value = _entry.GetValue<T>(_mode);
      _buffer[_buffer_size - i - 1] = _value;
      ++_num_copied;
    }

    return _num_copied;
  }
  */

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
  void ValidateDataSource(IndicatorBase* _target, IndicatorBase* _source) {
    if (_target == NULL) {
      Alert("Internal Error! _target is NULL in ", __FUNCTION_LINE__, ".");
      DebugBreak();
      return;
    }

    if (_source == NULL) {
      Alert("Error! You have to select source indicator's via SetDataSource().");
      DebugBreak();
      return;
    }

    if (!_target.IsDataSourceModeSelectable()) {
      // We don't validate source mode as it will use all modes.
      return;
    }

    if (_source.GetModeCount() > 1 && _target.GetDataSourceMode() == -1) {
      // Mode must be selected if source indicator has more that one mode.
      Alert("Warning! ", GetName(),
            " must select source indicator's mode via SetDataSourceMode(int). Defaulting to mode 0.");
      _target.SetDataSourceMode(0);
      DebugBreak();
    } else if (_source.GetModeCount() == 1 && _target.GetDataSourceMode() == -1) {
      _target.SetDataSourceMode(0);
    } else if (_target.GetDataSourceMode() < 0 || _target.GetDataSourceMode() > _source.GetModeCount()) {
      Alert("Error! ", _target.GetName(),
            " must select valid source indicator's mode via SetDataSourceMode(int) between 0 and ",
            _source.GetModeCount(), ".");
      DebugBreak();
    }
  }

  /**
   * Checks whether indicator have given mode index.
   *
   * If given mode is -1 (default one) and indicator has exactly one mode, then mode index will be replaced by 0.
   */
  void ValidateDataSourceMode(int& _out_mode) {
    if (_out_mode == -1) {
      // First mode will be used by default, or, if selected indicator has more than one mode, error will happen.
      if (iparams.GetMaxModes() != 1) {
        Alert("Error: ", GetName(), " must have exactly one possible mode in order to skip using SetDataSourceMode()!");
        DebugBreak();
      }
      _out_mode = 0;
    } else if (_out_mode + 1 > (int)iparams.GetMaxModes()) {
      Alert("Error: ", GetName(), " have ", iparams.GetMaxModes(),
            " mode(s) buy you tried to reference mode with index ", _out_mode,
            "! Ensure that you properly set mode via SetDataSourceMode().");
      DebugBreak();
    }
  }

  /**
   * Provides built-in indicators whose can be used as data source.
   */
  virtual IndicatorBase* FetchDataSource(ENUM_INDICATOR_TYPE _id) { return NULL; }

  /* Operator overloading methods */

  /**
   * Access indicator entry data using [] operator.
   */
  IndicatorDataEntry operator[](int _shift) { return GetEntry(_shift); }
  IndicatorDataEntry operator[](ENUM_INDICATOR_INDEX _shift) { return GetEntry(_shift); }
  IndicatorDataEntry operator[](datetime _dt) { return idata[_dt]; }

  /* Getters */

  /**
   * Returns the highest bar's index (shift).
   */
  template <typename T>
  int GetHighest(int count = WHOLE_ARRAY, int start_bar = 0) {
    int max_idx = -1;
    double max = -DBL_MAX;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value = GetEntry(shift).GetMax<T>(GetModeCount());
      if (value > max) {
        max = value;
        max_idx = shift;
      }
    }

    return max_idx;
  }

  /**
   * Returns the lowest bar's index (shift).
   */
  template <typename T>
  int GetLowest(int count = WHOLE_ARRAY, int start_bar = 0) {
    int min_idx = -1;
    double min = DBL_MAX;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value = GetEntry(shift).GetMin<T>(GetModeCount());
      if (value < min) {
        min = value;
        min_idx = shift;
      }
    }

    return min_idx;
  }

  /**
   * Returns the highest value.
   */
  template <typename T>
  double GetMax(int start_bar = 0, int count = WHOLE_ARRAY) {
    double max = NULL;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value = GetEntry(shift).GetMax<T>(iparams.GetMaxModes());
      if (max == NULL || value > max) {
        max = value;
      }
    }

    return max;
  }

  /**
   * Returns the lowest value.
   */
  template <typename T>
  double GetMin(int start_bar, int count = WHOLE_ARRAY) {
    double min = NULL;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value = GetEntry(shift).GetMin<T>(iparams.GetMaxModes());
      if (min == NULL || value < min) {
        min = value;
      }
    }

    return min;
  }

  /**
   * Returns average value.
   */
  template <typename T>
  double GetAvg(int start_bar, int count = WHOLE_ARRAY) {
    int num_values = 0;
    double sum = 0;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value_min = GetEntry(shift).GetMin<T>(iparams.GetMaxModes());
      double value_max = GetEntry(shift).GetMax<T>(iparams.GetMaxModes());

      sum += value_min + value_max;
      num_values += 2;
    }

    return sum / num_values;
  }

  /**
   * Returns median of values.
   */
  template <typename T>
  double GetMed(int start_bar, int count = WHOLE_ARRAY) {
    double array[];

    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);
    int num_bars = last_bar - start_bar + 1;
    int index = 0;

    ArrayResize(array, num_bars);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      array[index++] = GetEntry(shift).GetAvg<T>(iparams.GetMaxModes());
    }

    ArraySort(array);
    double median;
    int len = ArraySize(array);
    if (len % 2 == 0) {
      median = (array[len / 2] + array[(len / 2) - 1]) / 2;
    } else {
      median = array[len / 2];
    }

    return median;
  }

  /**
   * Returns currently selected data source doing validation.
   */
  IndicatorBase* GetDataSource() {
    IndicatorBase* _result = NULL;

    if (GetDataSourceRaw() != NULL) {
      _result = GetDataSourceRaw();
    } else if (iparams.GetDataSourceId() != -1) {
      int _source_id = iparams.GetDataSourceId();

      if (indicators.KeyExists(_source_id)) {
        _result = indicators[_source_id].Ptr();
      } else {
        Ref<IndicatorBase> _source = FetchDataSource((ENUM_INDICATOR_TYPE)_source_id);

        if (!_source.IsSet()) {
          Alert(GetName(), " has no built-in source indicator ", _source_id);
          DebugBreak();
        } else {
          indicators.Set(_source_id, _source);

          _result = _source.Ptr();
        }
      }
    }

    ValidateDataSource(&this, _result);

    return _result;
  }

  /**
   * Gets number of modes available to retrieve by GetValue().
   */
  virtual int GetModeCount() { return 0; }

  /**
   * Whether data source is selected.
   */
  virtual bool HasDataSource() { return GetDataSourceRaw() != NULL || iparams.GetDataSourceId() != -1; }

  /**
   * Gets indicator's params.
   */
  IndicatorParams GetParams() { return iparams; }

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
  IndicatorSignal GetSignals(int _count = 3, int _shift = 0, int _mode1 = 0, int _mode2 = 0) {
    bool _is_valid = true;
    IndicatorDataEntry _data[];
    if (!CopyEntries(_data, _count, _shift)) {
      // Some copied data is invalid, so returns empty signals.
      IndicatorSignal _signals(0);
      return _signals;
    }
    // Returns signals.
    IndicatorSignal _signals(_data, iparams, cparams, _mode1, _mode2);
    return _signals;
  }

  /**
   * Get pointer to data of indicator.
   */
  BufferStruct<IndicatorDataEntry>* GetData() { return GetPointer(idata); }

  /**
   * Get name of the indicator.
   */
  string GetName() { return iparams.name; }

  /**
   * Get full name of the indicator (with "over ..." part).
   */
  string GetFullName() {
    return iparams.name + "[" + IntegerToString(iparams.GetMaxModes()) + "]" +
           (HasDataSource() ? (" (over " + GetDataSource().GetFullName() + ")") : "");
  }

  /**
   * Get more descriptive name of the indicator.
   */
  string GetDescriptiveName() {
    string name = iparams.name + " (";

    switch (iparams.GetDataSourceType()) {
      case IDATA_BUILTIN:
        name += "built-in, ";
        break;
      case IDATA_ICUSTOM:
        name += "custom, ";
        break;
      case IDATA_INDICATOR:
        name += "over " + GetDataSource().GetDescriptiveName() + ", ";
        break;
    }

    name += IntegerToString(iparams.GetMaxModes()) + (iparams.GetMaxModes() == 1 ? " mode" : " modes");

    return name + ")";
  }

  /* Setters */

  /**
   * Sets an indicator's chart parameter value.
   */
  template <typename T>
  void Set(ENUM_CHART_PARAM _param, T _value) {
    Chart::Set<T>(_param, _value);
  }

  /**
   * Sets indicator data source.
   */
  void SetDataSource(IndicatorBase* _indi, int _input_mode = 0) {
    indi_src = _indi;
    iparams.SetDataSource(-1, _input_mode);
  }

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

  ENUM_IDATA_VALUE_RANGE GetIDataValueRange() { return iparams.idvrange; }

  virtual void OnTick() {
    Chart::OnTick();

    if (iparams.is_draw) {
      // Print("Drawing ", GetName(), iparams.indi_data != NULL ? (" (over " + iparams.indi_data.GetName() + ")") : "");
      for (int i = 0; i < (int)iparams.GetMaxModes(); ++i)
        draw.DrawLineTo(GetName() + "_" + IntegerToString(i) + "_" + IntegerToString(iparams.GetDataSourceMode()),
                        GetBarTime(0), GetEntry(0)[i], iparams.draw_window);
    }
  }

  /* Data representation methods */

  /* Virtual methods */

  /**
   * Returns stored data in human-readable format.
   */
  // virtual bool ToString() = NULL; // @fixme?

  /**
   * Whether we can and have to select mode when specifying data source.
   */
  virtual bool IsDataSourceModeSelectable() { return true; }

  /**
   * Checks if indicator entry is valid.
   *
   * @return
   *   Returns true if entry is valid (has valid values), otherwise false.
   */
  virtual bool IsValidEntry(IndicatorDataEntry& _entry) {
    bool _result = true;
    _result &= _entry.timestamp > 0;
    _result &= _entry.GetSize() > 0;
    if (_entry.CheckFlags(INDI_ENTRY_FLAG_IS_REAL)) {
      if (_entry.CheckFlags(INDI_ENTRY_FLAG_IS_DOUBLED)) {
        _result &= !_entry.HasValue<double>(DBL_MAX);
        _result &= !_entry.HasValue<double>(NULL);
      } else {
        _result &= !_entry.HasValue<float>(FLT_MAX);
        _result &= !_entry.HasValue<float>(NULL);
      }
    } else {
      if (_entry.CheckFlags(INDI_ENTRY_FLAG_IS_UNSIGNED)) {
        if (_entry.CheckFlags(INDI_ENTRY_FLAG_IS_DOUBLED)) {
          _result &= !_entry.HasValue<ulong>(ULONG_MAX);
          _result &= !_entry.HasValue<ulong>(NULL);
        } else {
          _result &= !_entry.HasValue<uint>(UINT_MAX);
          _result &= !_entry.HasValue<uint>(NULL);
        }
      } else {
        if (_entry.CheckFlags(INDI_ENTRY_FLAG_IS_DOUBLED)) {
          _result &= !_entry.HasValue<long>(LONG_MAX);
          _result &= !_entry.HasValue<long>(NULL);
        } else {
          _result &= !_entry.HasValue<int>(INT_MAX);
          _result &= !_entry.HasValue<int>(NULL);
        }
      }
    }
    return _result;
  }

  /**
   * Update indicator.
   */
  virtual bool Update() {
    // @todo
    return false;
  };

  /**
   * Returns the indicator's struct entry for the given shift.
   *
   * @see: IndicatorDataEntry.
   *
   * @return
   *   Returns IndicatorDataEntry struct filled with indicator values.
   */
  virtual IndicatorDataEntry GetEntry(int _shift = -1) {
    ResetLastError();
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    long _bar_time = GetBarTime(_ishift);
    IndicatorDataEntry _entry = idata.GetByKey(_bar_time);
    if (_bar_time > 0 && !_entry.IsValid() && !_entry.CheckFlag(INDI_ENTRY_FLAG_INSUFFICIENT_DATA)) {
      _entry.Resize(iparams.GetMaxModes());
      _entry.timestamp = GetBarTime(_ishift);
#ifndef __MQL4__
      if (IndicatorBase::Get<bool>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_CHANGED))) {
        // Resets the handle on any parameter changes.
        IndicatorBase::Set<int>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_HANDLE), INVALID_HANDLE);
        IndicatorBase::Set<int>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_CHANGED), false);
      }
#endif
      for (int _mode = 0; _mode < (int)iparams.GetMaxModes(); _mode++) {
        switch (iparams.GetDataValueType()) {
          case TYPE_BOOL:
          case TYPE_CHAR:
          case TYPE_INT:
            _entry.values[_mode] = GetValue<int>(_mode, _ishift);
            break;
          case TYPE_LONG:
            _entry.values[_mode] = GetValue<long>(_mode, _ishift);
            break;
          case TYPE_UINT:
            _entry.values[_mode] = GetValue<uint>(_mode, _ishift);
            break;
          case TYPE_ULONG:
            _entry.values[_mode] = GetValue<ulong>(_mode, _ishift);
            break;
          case TYPE_DOUBLE:
            _entry.values[_mode] = GetValue<double>(_mode, _ishift);
            break;
          case TYPE_FLOAT:
            _entry.values[_mode] = GetValue<float>(_mode, _ishift);
            break;
          case TYPE_STRING:
          case TYPE_UCHAR:
          default:
            SetUserError(ERR_INVALID_PARAMETER);
            break;
        }
      }
      GetEntryAlter(_entry, _ishift);
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, IsValidEntry(_entry));
      if (_entry.IsValid()) {
        idata.Add(_entry, _bar_time);
        istate.is_changed = false;
        istate.is_ready = true;
      } else {
        _entry.AddFlags(INDI_ENTRY_FLAG_INSUFFICIENT_DATA);
      }
    }
    if (_LastError != ERR_NO_ERROR) {
      istate.is_ready = false;
      ResetLastError();
    }
    return _entry;
  }

  /**
   * Alters indicator's struct value.
   *
   * This method allows user to modify the struct entry before it's added to cache.
   * This method is called on GetEntry() right after values are set.
   */
  virtual void GetEntryAlter(IndicatorDataEntry& _entry, int _shift = -1) {
    _entry.AddFlags(_entry.GetDataTypeFlags(iparams.GetDataValueType()));
  };
};

#endif

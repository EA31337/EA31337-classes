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

// Forward class declaration.
struct IndicatorParams;

#include "Indicator.define.h"
#include "Indicator.enum.h"
#include "Indicator.struct.h"
#include "Indicator.struct.serialize.h"
#include "IndicatorData.h"

// Includes.
#include "../Array.mqh"
#include "../BufferStruct.mqh"
#include "../DateTime.mqh"
#include "../DrawIndicator.mqh"
#include "../Flags.h"
#include "../Math.h"
#include "../Object.mqh"
#include "../Refs.mqh"
#include "../Serializer.mqh"
#include "../SerializerCsv.mqh"
#include "../SerializerJson.mqh"
#include "../Storage/ValueStorage.h"
#include "../Storage/ValueStorage.indicator.h"
#include "../Storage/ValueStorage.native.h"

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
  string _key = Util::MakeKey(_symbol, (string)_tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m);
  int _handle = _handlers.GetByKey(_key);
  ICUSTOM_DEF(_handlers.Set(_key, _handle), COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h
                                                COMMA _i COMMA _j COMMA _k COMMA _l COMMA _m);
}
#endif

/**
 * Class to deal with indicators.
 */
template <typename TS>
class Indicator : public IndicatorData {
 protected:
  TS iparams;

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
  Indicator(const TS& _iparams, const IndicatorDataParams& _idparams, IndicatorData* _indi_src = NULL,
            int _indi_mode = 0)
      : IndicatorData(_idparams, _indi_src, _indi_mode) {
    iparams = _iparams;
    Init();
  }
  Indicator(const TS& _iparams, const IndicatorDataParams& _idparams, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
      : IndicatorData(_idparams) {
    iparams = _iparams;
    Init();
  }
  Indicator(ENUM_INDICATOR_TYPE _itype, int _shift = 0, string _name = "")
      : IndicatorData(IndicatorDataParams::GetInstance()) {
    iparams.SetIndicatorType(_itype);
    iparams.SetShift(_shift);
    Init();
  }

  /**
   * Class deconstructor.
   */
  ~Indicator() {}

  /* Getters */

  /**
   * Gets a value from IndicatorDataParams struct.
   */
  template <typename T>
  T Get(STRUCT_ENUM_IDATA_PARAM _param) {
    return idparams.Get<T>(_param);
  }

  /**
   * Gets a value from IndicatorState struct.
   */
  template <typename T>
  T Get(STRUCT_ENUM_INDICATOR_STATE_PROP _param) {
    return istate.Get<T>(_param);
  }

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

  /* Setters */

  /**
   * Sets the value for IndicatorDataParams struct.
   */
  template <typename T>
  void Set(STRUCT_ENUM_IDATA_PARAM _param, T _value) {
    idparams.Set<T>(_param, _value);
  }

  /**
   * Sets whether indicator's buffers should be drawn on the chart.
   */
  void SetDraw(bool _value, color _color = clrAquamarine, int _window = 0) {
    draw.SetEnabled(_value);
    draw.SetColorLine(_color);
    draw.SetWindow(_window);
  }

  /* Buffer methods */

  virtual string CacheKey() { return GetFullName(); }

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
   * Gets number of modes available to retrieve by GetValue().
   */
  // int GetModeCount() override { return (int)iparams.max_modes; }

  /**
   * Gets indicator's params.
   */
  IndicatorParams GetParams() { return iparams; }

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
    IndicatorSignal _signals(_data, idparams, GetSymbol(), GetTf(), _mode1, _mode2);
    return _signals;
  }

  /**
   * Get name of the indicator.
   */
  string GetName() override {
    return "(" + EnumToString(GetType()) + ")" + (iparams.name != "" ? (" " + iparams.name) : "");
  }

  /**
   * Get more descriptive name of the indicator.
   */
  string GetDescriptiveName() {
    int _max_modes = Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES));
    string name = iparams.name + " (";

    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
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

    name += IntegerToString(_max_modes) + (_max_modes == 1 ? " mode" : " modes");

    return name + ")";
  }

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
        _result &= !_entry.HasValue<double>(INT_MAX);  // Empty value from indicator.
        _result &= !_entry.HasValue<double>(DBL_MAX);
      } else {
        _result &= !_entry.HasValue<float>(FLT_MAX);
      }
    } else {
      if (_entry.CheckFlags(INDI_ENTRY_FLAG_IS_UNSIGNED)) {
        if (_entry.CheckFlags(INDI_ENTRY_FLAG_IS_DOUBLED)) {
          _result &= !_entry.HasValue<unsigned long>(ULONG_MAX);
        } else {
          _result &= !_entry.HasValue<unsigned int>(UINT_MAX);
        }
      } else {
        if (_entry.CheckFlags(INDI_ENTRY_FLAG_IS_DOUBLED)) {
          _result &= !_entry.HasValue<long>(LONG_MAX);
        } else {
          _result &= !_entry.HasValue<int>(INT_MAX);
        }
      }
    }
    return _result;
  }

  /**
   * Get indicator type.
   */
  ENUM_INDICATOR_TYPE GetType() override { return iparams.itype; }

  /**
   * Returns the indicator's struct entry for the given shift.
   *
   * @see: IndicatorDataEntry.
   *
   * @return
   *   Returns IndicatorDataEntry struct filled with indicator values.
   */
  IndicatorDataEntry GetEntry(long _index = -1) override {
    ResetLastError();
    int _ishift = _index >= 0 ? (int)_index : iparams.GetShift();
    long _bar_time;
    _bar_time = GetBarTime(_ishift);

    if (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE)) == IDATA_BUILTIN &&
        (GetPossibleDataModes() & IDATA_BUILTIN) == 0) {
      // Indicator is set to use built-in mode, but it doesn't support it.
      if ((GetPossibleDataModes() & IDATA_ONCALCULATE) != 0) {
        // Indicator supports OnCalculate() mode.
        Set<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE), IDATA_ONCALCULATE);
      } else {
        Print("Error: Indicator ", GetFullName(),
              " does not support built-in mode and there is no other mode that it can use.");
        DebugBreak();
      }
    }

    IndicatorDataEntry _entry = idata.GetByKey(_bar_time);
    if (_bar_time > 0 && !_entry.IsValid() && !_entry.CheckFlag(INDI_ENTRY_FLAG_INSUFFICIENT_DATA)) {
      int _max_modes = Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES));
      _entry.Resize(_max_modes);
      _entry.timestamp = GetBarTime(_ishift);
#ifndef __MQL4__
      if (IndicatorData::Get<bool>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_CHANGED))) {
        // Resets the handle on any parameter changes.
        IndicatorData::Set<int>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_HANDLE), INVALID_HANDLE);
        IndicatorData::Set<int>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_CHANGED), false);
      }
#endif
      for (int _mode = 0; _mode < _max_modes; _mode++) {
        switch (Get<ENUM_DATATYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DTYPE))) {
          case TYPE_BOOL:
          case TYPE_CHAR:
          case TYPE_INT:
            _entry.values[_mode] = GetValue<int>(_mode, _ishift);
            break;
          case TYPE_LONG:
            _entry.values[_mode] = GetValue<long>(_mode, _ishift);
            break;
          case TYPE_UINT:
            _entry.values[_mode] = GetValue<unsigned int>(_mode, _ishift);
            break;
          case TYPE_ULONG:
            _entry.values[_mode] = GetValue<unsigned long>(_mode, _ishift);
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

        if (_LastError != ERR_SUCCESS) {
          datetime _bar_dt = (datetime)_bar_time;
          Print("Error: Code ", _LastError, " while trying to retrieve entry at shift ", _ishift, ", mode ", _mode,
                ", time ", _bar_dt);
          DebugBreak();
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
  virtual void GetEntryAlter(IndicatorDataEntry& _entry, int _shift) {
    ENUM_DATATYPE _dtype = Get<ENUM_DATATYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DTYPE));
    _entry.AddFlags(_entry.GetDataTypeFlags(_dtype));
  };

  /**
   * Returns the indicator's entry value for the given shift and mode.
   *
   * @see: DataParamEntry.
   *
   * @return
   *   Returns DataParamEntry struct filled with a single value.
   */
  IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) override {
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    return GetEntry(_ishift)[_mode];
  }

  /* Virtual methods */

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  virtual unsigned int GetPossibleDataModes() { return 0; }

  /**
   * Update indicator.
   */
  virtual bool Update() {
    // @todo
    return false;
  };
};

#endif

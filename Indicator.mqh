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
#include "Indicator.struct.h"
#include "Indicator.struct.serialize.h"
#include "Indicator.struct.signal.h"
#include "Math.h"
#include "Object.mqh"
#include "Refs.mqh"
#include "Serializer.mqh"
#include "SerializerCsv.mqh"
#include "SerializerJson.mqh"

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
  bool is_feeding;                             // Whether FeedHistoryEntries is already working.
  bool is_fed;                                 // Whether FeedHistoryEntries already done its job.
  DictStruct<int, Ref<Indicator>> indicators;  // Indicators list keyed by id.
  bool indicator_builtin;

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
  Indicator() {}
  Indicator(IndicatorParams& _iparams) : Chart(_iparams.GetTf()), draw(NULL), is_feeding(false), is_fed(false) {
    iparams = _iparams;
    SetName(_iparams.name != "" ? _iparams.name : EnumToString(iparams.itype));
    Init();
  }
  Indicator(const IndicatorParams& _iparams, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
      : Chart(_tf), draw(NULL), is_feeding(false), is_fed(false) {
    iparams = _iparams;
    SetName(_iparams.name != "" ? _iparams.name : EnumToString(iparams.itype));
    Init();
  }
  Indicator(ENUM_INDICATOR_TYPE _itype, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, string _name = "")
      : Chart(_tf), draw(NULL), is_feeding(false), is_fed(false) {
    iparams.SetIndicatorType(_itype);
    SetName(_name != "" ? _name : EnumToString(iparams.itype));
    Init();
  }

  /**
   * Class deconstructor.
   */
  ~Indicator() {
    ReleaseHandle();
    DeinitDraw();

    if (iparams.indi_data_source != NULL && iparams.indi_managed) {
      // User selected custom, managed data source.
      if (CheckPointer(iparams.indi_data_source) == POINTER_INVALID) {
        DebugBreak();
      }
      delete iparams.indi_data_source;
      iparams.indi_data_source = NULL;
    }
  }

  /* Init methods */

  bool Init() { return InitDraw(); }

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

  /* Buffer methods */

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
  void ValidateDataSource(Indicator* _target, Indicator* _source) {
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

    if (_source.iparams.max_modes > 1 && _target.GetDataSourceMode() == -1) {
      // Mode must be selected if source indicator has more that one mode.
      Alert("Warning! ", GetName(),
            " must select source indicator's mode via SetDataSourceMode(int). Defaulting to mode 0.");
      _target.iparams.SetDataSourceMode(0);
      DebugBreak();
    } else if (_source.iparams.max_modes == 1 && _target.GetDataSourceMode() == -1) {
      _target.iparams.SetDataSourceMode(0);
    } else if (_target.GetDataSourceMode() < 0 ||
               (unsigned int)_target.GetDataSourceMode() > _source.iparams.max_modes) {
      Alert("Error! ", _target.GetName(),
            " must select valid source indicator's mode via SetDataSourceMode(int) between 0 and ",
            _source.iparams.GetMaxModes(), ".");
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
      if (iparams.max_modes != 1) {
        Alert("Error: ", GetName(), " must have exactly one possible mode in order to skip using SetDataSourceMode()!");
        DebugBreak();
      }
      _out_mode = 0;
    } else if (_out_mode + 1 > (int)iparams.max_modes) {
      Alert("Error: ", GetName(), " have ", iparams.max_modes, " mode(s) buy you tried to reference mode with index ",
            _out_mode, "! Ensure that you properly set mode via SetDataSourceMode().");
      DebugBreak();
    }
  }

  /**
   * Provides built-in indicators whose can be used as data source.
   */
  virtual Indicator* FetchDataSource(ENUM_INDICATOR_TYPE _id) { return NULL; }

  /**
   * Whether data source is selected.
   */
  bool HasDataSource() { return iparams.GetDataSource() != NULL || iparams.GetDataSourceId() != -1; }

  /**
   * Returns currently selected data source without any validation.
   */
  Indicator* GetDataSourceRaw() { return iparams.GetDataSource(); }

  /**
   * Returns currently selected data source doing validation.
   */
  Indicator* GetDataSource() {
    Indicator* _result = NULL;
    if (iparams.GetDataSource() != NULL) {
      _result = iparams.GetDataSource();
    } else if (iparams.GetDataSourceId() != -1) {
      int _source_id = iparams.GetDataSourceId();

      if (indicators.KeyExists(_source_id)) {
        _result = indicators[_source_id].Ptr();
      } else {
        Ref<Indicator> _source = FetchDataSource((ENUM_INDICATOR_TYPE)_source_id);

        if (!_source.IsSet()) {
          Alert(GetName(), " has no built-in source indicator ", _source_id);
        } else {
          indicators.Set(_source_id, _source);

          _result = _source.Ptr();
        }
      }
    }

    ValidateDataSource(&this, _result);

    return _result;
  }

  /* Operator overloading methods */

  /**
   * Access indicator entry data using [] operator.
   */
  IndicatorDataEntry operator[](int _shift) { return GetEntry(_shift); }
  IndicatorDataEntry operator[](ENUM_INDICATOR_INDEX _shift) { return GetEntry(_shift); }
  IndicatorDataEntry operator[](datetime _dt) { return idata[_dt]; }

  /* Getters */

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
   * Gets an indicator property flag.
   */
  bool GetFlag(INDICATOR_ENTRY_FLAGS _prop, int _shift = 0) {
    IndicatorDataEntry _entry = GetEntry(_shift);
    return _entry.CheckFlag(_prop);
  }

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

  int GetDataSourceMode() { return iparams.GetDataSourceMode(); }

  /**
   * Returns the highest bar's index (shift).
   */
  template <typename T>
  int GetHighest(int count = WHOLE_ARRAY, int start_bar = 0) {
    int max_idx = -1;
    double max = -DBL_MAX;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value = GetEntry(shift).GetMax<T>(iparams.max_modes);
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
      double value = GetEntry(shift).GetMin<T>(iparams.max_modes);
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
      double value = GetEntry(shift).GetMax<T>(iparams.max_modes);
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
      double value = GetEntry(shift).GetMin<T>(iparams.max_modes);
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
      double value_min = GetEntry(shift).GetMin<T>(iparams.max_modes);
      double value_max = GetEntry(shift).GetMax<T>(iparams.max_modes);

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
      array[index++] = GetEntry(shift).GetAvg<T>(iparams.max_modes);
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
    IndicatorSignal _signals(_data, iparams, cparams, _mode1, _mode2);
    return _signals;
  }

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
   * Get full name of the indicator (with "over ..." part).
   */
  string GetFullName() {
    return iparams.name + "[" + IntegerToString(iparams.GetMaxModes()) + "]" +
           (HasDataSource() ? (" (over " + GetDataSource().GetName() + "[" +
                               IntegerToString(GetDataSource().GetParams().GetMaxModes()) + "])")
                            : "");
  }

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
        name += "over " + GetDataSource().GetDescriptiveName() + ", ";
        break;
    }

    name += IntegerToString(iparams.max_modes) + (iparams.max_modes == 1 ? " mode" : " modes");

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
   * Feed history entries.
   */
  void FeedHistoryEntries(int period, int shift = 0) {
    if (is_feeding || is_fed) {
      // Avoiding forever loop.
      return;
    }

    is_feeding = true;

    for (int i = shift + period; i > shift; --i) {
      if (ChartStatic::iPrice(PRICE_OPEN, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), i) <=
          0) {
        // No data for that entry
        continue;
      }

      GetEntry(i);
    }

    is_feeding = false;
    is_fed = true;
  }

  /**
   * Returns indicator value for a given shift and mode.
   */
  template <typename T>
  T GetValue(int _shift = 0, int _mode = -1) {
    T _result;
    int _index = _mode != -1 ? _mode : iparams.indi_mode;
    GetEntry(_shift).values[_index].Get(_result);
    ResetLastError();
    return _result;
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
    if (iparams.GetIDataValueRange() != IDATA_RANGE_PRICE) {
      _price = (float)GetPrice(_ap, _shift);
    } else if (iparams.GetIDataValueRange() == IDATA_RANGE_PRICE) {
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
   * Returns the indicator's struct value.
   */
  virtual IndicatorDataEntry GetEntry(int _shift = 0) {
    IndicatorDataEntry _entry(iparams.max_modes);
    _entry = idata.GetByKey(GetBarTime(_shift), _entry);
    return _entry;
  };

  /**
   * Returns the indicator's entry value.
   */
  virtual MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_FLOAT};
    _param.double_value = (float)GetEntry(_shift).GetValue<float>(0);
    return _param;
  }

  /**
   * Returns the indicator's value in plain format.
   */
  virtual string ToString(int _shift = 0) {
    IndicatorDataEntry _entry = GetEntry(_shift);
    int _serializer_flags = SERIALIZER_FLAG_SKIP_HIDDEN | SERIALIZER_FLAG_INCLUDE_DYNAMIC;
    SerializerConverter _stub_indi =
        SerializerConverter::MakeStubObject<IndicatorDataEntry>(_serializer_flags, _entry.GetSize());
    return SerializerConverter::FromObject(_entry, _serializer_flags).ToString<SerializerCsv>(0, &_stub_indi);
  }
};
#endif

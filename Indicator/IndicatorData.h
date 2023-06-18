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

// Ignore processing of this file if already included.
#ifndef INDICATOR_DATA_H
#define INDICATOR_DATA_H

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward class declaration.
class IndicatorData;
class DrawIndicator;
class IValueStorage;

struct ExternInstantiateIndicatorBufferValueStorageDouble {
  static IValueStorage* InstantiateIndicatorBufferValueStorageDouble(IndicatorData*, int);
};

// Includes.
#include "../Bar.struct.h"
#include "../Platform/Chart/Chart.struct.tf.h"
#include "../Storage/Flags.struct.h"
#include "../Storage/IValueStorage.h"
#include "../Storage/ItemsHistory.h"
#include "../SymbolInfo.struct.h"
#include "Indicator.enum.h"
#include "IndicatorBase.h"
#include "IndicatorData.enum.h"
#include "../Storage/Cache/IndiBufferCache.h"
#include "IndicatorData.struct.h"
#include "IndicatorData.struct.serialize.h"
#include "IndicatorData.struct.signal.h"

/**
 * Implements class to store indicator data.
 */
class IndicatorData : public IndicatorBase {
 protected:
  // Class variables.
  bool do_draw;
  bool indicator_builtin;
  bool is_fed;              // Whether calc_start_bar is already calculated.
  int calc_start_bar;       // Index of the first valid bar (from 0).
  int flags;                // Flags such as INDI_FLAG_INDEXABLE_BY_SHIFT.
  int last_tick_index;      // Index of the last tick.
  long first_tick_time_ms;  // Time of the first ask/bid tick.
  void* mydata;
  bool last_tick_result;             // Result of the last Tick() invocation.
  ENUM_INDI_DATA_VS_TYPE retarget_ap_av;  // Value storage type to be used as applied price/volume.
  ARRAY(Ref<IValueStorage>, value_storages);
  ARRAY(WeakRef<IndicatorData>, listeners);  // List of indicators that listens for events from this one.
  BufferStruct<IndicatorDataEntry> idata;
  DictStruct<int, Ref<IndicatorData>> indicators;  // Indicators list keyed by id.
  // DrawIndicator* draw;
  IndiBufferCache<double> cache;
  IndicatorDataParams idparams;  // Indicator data params.
  IndicatorDataState istate;
  Ref<IndicatorData> indi_src;  // Indicator used as data source.

 protected:
  /* Protected methods */

  bool Init() {
#ifdef __cplusplus
    // In C++ we default to On-Indicator mode as there are no built-in ones.
    idparams.Set<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE), IDATA_INDICATOR);
#endif

    ArrayResize(value_storages, GetModeCount());
    if (indi_src.IsSet()) {
      // SetDataSource(_indi_src, _indi_mode);
      idparams.Set<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE), IDATA_INDICATOR);
    }
    switch (idparams.Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        break;
      case IDATA_ICUSTOM:
        break;
      case IDATA_INDICATOR:
        if (indi_src.IsSet()) {
          // Indi_Price* _indi_price = Indi_Price::GetCached(GetSymbol(), GetTf(), iparams.GetShift());
          // SetDataSource(_indi_price, true, PRICE_OPEN);
        }
        break;
      default:
        break;
    }
    // By default, indicator is indexable only by shift and data source must be also indexable by shift.
    flags = INDI_FLAG_INDEXABLE_BY_SHIFT | INDI_FLAG_SOURCE_REQ_INDEXABLE_BY_SHIFT;
    calc_start_bar = 0;
    last_tick_index = -1;
    retarget_ap_av = INDI_DATA_VS_TYPE_NONE;
    InitDraw();
    return true;
  }

  /**
   * Initialize indicator data drawing on custom data.
   */
  bool InitDraw() {
    /* @todo: To refactor.
      if (idparams.is_draw && !Object::IsValid(draw)) {
        draw = new DrawIndicator(THIS_PTR);
        draw.SetColorLine(idparams.indi_color);
      }
      return idparams.is_draw;
    */
    return false;
  }

  /**
   * Deinitialize drawing.
   */
  void DeinitDraw() {
    /* @todo: To refactor.
    if (draw) {
      delete draw;
    }
    */
  }

 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  IndicatorData(const IndicatorDataParams& _idparams, IndicatorData* _indi_src = NULL, int _indi_mode = 0)
      : do_draw(false), idparams(_idparams), indi_src(_indi_src) {
    Init();
  }
  IndicatorData(const IndicatorDataParams& _idparams, ENUM_TIMEFRAMES _tf, string _symbol = NULL)
      : do_draw(false), idparams(_idparams) {
    Init();
  }

  /**
   * Class deconstructor.
   */
  virtual ~IndicatorData() {
    DeinitDraw();
    ReleaseHandle();
  }

  /* Operator overloading methods */

  /**
   * Access indicator entry data using [] operator via shift.
   */
  IndicatorDataEntry operator[](int _rel_shift) {
    if (!bool(flags & INDI_FLAG_INDEXABLE_BY_SHIFT)) {
      Print(GetFullName(), " is not indexable by shift!");
      DebugBreak();
      IndicatorDataEntry _default;
      return _default;
    }
    return GetEntry(_rel_shift);
  }

  IndicatorDataEntry operator[](ENUM_INDICATOR_DATA_INDEX _rel_shift) { return GetEntry((int)_rel_shift); }

  /* Getters */

  /**
   * Gets a value from IndicatorDataParams struct.
   */
  template <typename T>
  T Get(STRUCT_ENUM_IDATA_PARAM _param) {
    return idparams.Get<T>(_param);
  }

  /**
   * Gets an indicator's state property value.
   */
  template <typename T>
  T Get(STRUCT_ENUM_INDICATOR_DATA_STATE_PROP _prop) {
    return istate.Get<T>(_prop);
  }

  /**
   * Gets an indicator property flag.
   */
  bool GetFlag(INDICATOR_DATA_ENTRY_FLAGS _prop, int _rel_shift = 0) {
    IndicatorDataEntry _entry = GetEntry(_rel_shift);
    return _entry.CheckFlag(_prop);
  }

  /**
   * Returns indicator's flags.
   */
  int GetFlags() { return flags; }

  /**
   * Returns time of the first ask/bid tick (time of first global OnTick()).
   * Time is compatible with time generated by IndicatorTick, e.g., Indi_TickMt.
   */
  long GetFirstTickTimeMs() { return first_tick_time_ms; }

  /**
   * Get full name of the indicator (with "over ..." part).
   */
  string GetFullName() {
    int _max_modes = Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES));
    string _mode;

    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _mode = "B-in";
        break;
      case IDATA_ONCALCULATE:
        _mode = "On-C";
        break;
      case IDATA_ICUSTOM:
        _mode = "iCus";
        break;
      case IDATA_INDICATOR:
        _mode = "On-I";
        break;
      default:
        _mode = "Unkw";
        break;
    }

    return GetName() + "#" + IntegerToString(GetId()) + "-" + _mode + "[" + IntegerToString(_max_modes) + "]" +
           (HasDataSource() ? (" (over " + GetDataSource(false) PTR_DEREF GetFullName() + ")") : "");
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
  double GetValuePrice(int _shift = 0, int _mode = 0, ENUM_APPLIED_PRICE _ap = PRICE_TYPICAL) {
    double _price = 0;
    ENUM_IDATA_VALUE_RANGE _idvrange =
        Get<ENUM_IDATA_VALUE_RANGE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDVRANGE));
    if (_idvrange != IDATA_RANGE_PRICE) {
      _price = (float)GetPrice(_ap, _shift);
    } else if (_idvrange == IDATA_RANGE_PRICE) {
      // When indicator values are the actual prices.
      T _values[4];
      if (!CopyValues(_values, 4, _shift, _mode)) {
        // When values aren't valid, return 0.
        return _price;
      }
      datetime _bar_time = GetBarTime(_shift);
      BarOHLC _ohlc(_values, _bar_time);
      _price = _ohlc.GetAppliedPrice(_ap);
    }
    return _price;
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

  /**
   * Get current close price depending on the operation type.
   */
  double GetCloseOffer(ENUM_ORDER_TYPE _cmd) { return _cmd == ORDER_TYPE_BUY ? GetBid() : GetAsk(); }

  /**
   * Returns the highest value.
   */
  template <typename T>
  double GetMax(int start_bar = 0, int count = WHOLE_ARRAY) {
    double max = -DBL_MAX;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);
    int _max_modes = Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES));

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value = GetEntry(shift).GetMax<T>(_max_modes);
      if (max == -DBL_MAX || value > max) {
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
    double min = DBL_MAX;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);
    int _max_modes = Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES));

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value = GetEntry(shift).GetMin<T>(_max_modes);
      if (min == DBL_MAX || value < min) {
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
    int _max_modes = Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES));

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value_min = GetEntry(shift).GetMin<T>(_max_modes);
      double value_max = GetEntry(shift).GetMax<T>(_max_modes);

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
    ARRAY(double, array);

    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);
    int num_bars = last_bar - start_bar + 1;
    int index = 0;
    int _max_modes = Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES));

    ArrayResize(array, num_bars);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      array[index++] = GetEntry(shift).GetAvg<T>(_max_modes);
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
   * Get current (or by given date and time) open price depending on the operation type.
   */
  double GetOpenOffer(ENUM_ORDER_TYPE _cmd) {
    // Use the right open price at opening of a market order. For example:
    // - When selling, only the latest Bid prices can be used.
    // - When buying, only the latest Ask prices can be used.
    return _cmd == ORDER_TYPE_BUY ? GetAsk() : GetBid();
  }

  /**
   * Returns symbol and optionally TF to be used e.g., to identify
   */
  string GetSymbolTf(string _separator = "@") {
    if (!HasCandleInHierarchy()) {
      return "";
    }

    // Symbol is available throught Tick indicator at the end of the hierarchy.
    string _res = GetSymbol();

    if (HasCandleInHierarchy()) {
      // TF is available throught Candle indicator at the end of the hierarchy.
      _res += _separator + ChartTf::TfToString(GetTf());
    }

    return _res;
  }

  /* Data methods */

  /**
   * Gets indicator data from a buffer and copy into struct array.
   *
   * @return
   * Returns true of successful copy.
   * Returns false on invalid values.
   */
  bool CopyEntries(ARRAY_REF(IndicatorDataEntry, _data), int _count, int _start_shift = 0) {
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
  bool CopyValues(ARRAY_REF(T, _data), int _count, int _start_shift = 0, int _mode = 0) {
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

  /* Getters */

  int GetBarsCalculated() { return GetBars(); }

  /**
   * Returns buffers' cache.
   */
  IndiBufferCache<double>* GetCache() { return &cache; }

  /**
   * Get pointer to data of indicator.
   */
  BufferStruct<IndicatorDataEntry>* GetData() { return GetPointer(idata); }

  /**
   * Returns currently selected data source doing validation.
   */
  IndicatorData* GetDataSource(bool _validate = true) {
    IndicatorData* _result = NULL;

    if (GetDataSourceRaw() != NULL) {
      _result = GetDataSourceRaw();
    } else if (Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_SRC_ID)) != -1) {
      int _source_id = Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_SRC_ID));

      Print("Setting data source by id is now obsolete. Please use SetDataSource(IndicatorData*) method for ",
            GetName(), " (data source id ", _source_id, ").");
      DebugBreak();

      if (indicators.KeyExists(_source_id)) {
        _result = indicators[_source_id].Ptr();
      } else {
        Ref<IndicatorData> _source = FetchDataSource((ENUM_INDICATOR_TYPE)_source_id);

        if (!_source.IsSet()) {
          Alert(GetName(), " has no built-in source indicator ", _source_id);
          DebugBreak();
        } else {
          indicators.Set(_source_id, _source);

          _result = _source.Ptr();
        }
      }
    } else if (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE)) == IDATA_INDICATOR) {
      // User sets data source's mode to On-Indicator, but not set data source via SetDataSource()!

      // Requesting potential data source.
      _result = OnDataSourceRequest();

      if (_result != NULL) {
        // Initializing with new data source.
        SetDataSource(_result);
        Set<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE), IDATA_INDICATOR);
      }
    }

    if (_validate) {
      ValidateDataSource(THIS_PTR, _result);
    }

    return _result;
  }

  /**
   * Returns given data source type. Used by i*OnIndicator methods if indicator's Calculate() uses other indicators.
   */
  IndicatorData* GetDataSource(ENUM_INDICATOR_TYPE _type) {
    IndicatorData* _result = NULL;
    if (indicators.KeyExists((int)_type)) {
      _result = indicators[(int)_type].Ptr();
    } else {
      Ref<IndicatorData> _indi = FetchDataSource(_type);
      if (!_indi.IsSet()) {
        Alert(GetFullName(), " does not define required indicator type ", EnumToString(_type), " for symbol ",
              GetSymbol(), "!");
        DebugBreak();
      } else {
        indicators.Set((int)_type, _indi);
        _result = _indi.Ptr();
      }
    }
    return _result;
  }

  /**
   * Gets value storage type previously set by SetDataSourceAppliedPrice() or SetDataSourceAppliedVolume().
   */
  ENUM_INDI_DATA_VS_TYPE GetDataSourceAppliedType() { return retarget_ap_av; }

  // int GetDataSourceMode() { return indi_src_mode; }

  /**
   * Returns currently selected data source without any validation.
   */
  IndicatorData* GetDataSourceRaw() { return indi_src.Ptr(); }

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

  /**
   * Whether data source is selected.
   */
  bool HasDataSource(bool _try_initialize = false) {
    if (Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_SRC_ID)) != -1) {
      return true;
    }

    if (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE)) == IDATA_INDICATOR &&
        GetDataSourceRaw() == NULL && _try_initialize) {
      SetDataSource(OnDataSourceRequest());
    }

    return GetDataSourceRaw() != NULL;
  }

  /**
   * Whether given data source is in the hierarchy.
   */
  bool HasDataSource(IndicatorData* _indi) {
    if (THIS_PTR == _indi) return true;

    if (HasDataSource(true)) {
      return GetDataSourceRaw() PTR_DEREF HasDataSource(_indi);
    }

    return false;
  }

  /**
   * Checks whether there is attached suitable data source (if required).
   */
  bool HasSuitableDataSource() {
    Flags<unsigned int> _flags = GetSuitableDataSourceTypes();
    return !_flags.HasFlag(INDI_SUITABLE_DS_TYPE_EXPECT_NONE) && GetSuitableDataSource(false) != nullptr;
  }

  /**
   * Checks whether indicator have given mode (max_modes is greater that given mode).
   */
  bool HasValueStorage(unsigned int _mode = 0) { return _mode < GetModeCount(); }

  /**
   * Whether we can and have to select mode when specifying data source.
   */
  virtual bool IsDataSourceModeSelectable() { return true; }

  /* Setters */

  /**
   * Adds event listener.
   */
  void AddListener(IndicatorData* _indi) {
    WeakRef<IndicatorData> _ref = _indi;
    ArrayPushObject(listeners, _ref);
  }

  /**
   * Removes event listener.
   */
  void RemoveListener(IndicatorData* _indi) {
    WeakRef<IndicatorData> _ref = _indi;
    Util::ArrayRemoveFirst(listeners, _ref);
  }

  /**
   * Sets the value for IndicatorDataParams struct.
   */
  template <typename T>
  void Set(STRUCT_ENUM_IDATA_PARAM _param, T _value) {
    idparams.Set<T>(_param, _value);
  }

  /**
   * Sets an indicator's state property value.
   */
  template <typename T>
  void Set(STRUCT_ENUM_INDICATOR_DATA_STATE_PROP _prop, T _value) {
    istate.Set<T>(_prop, _value);
  }

  /**
   * Sets indicator data source.
   */
  void SetDataSource(IndicatorData* _indi, int _input_mode = -1) {
    // Detecting circular dependency.
    IndicatorData* _curr;
    int _iterations_left = 50;

    // If _indi or any of the _indi's data source points to this indicator then this would create circular dependency.
    for (_curr = _indi; _curr != nullptr && _iterations_left != 0;
         _curr = _curr PTR_DEREF GetDataSource(false), --_iterations_left) {
      if (_curr == THIS_PTR) {
        // Circular dependency found.
        Print("Error: Circular dependency found when trying to attach " + _indi PTR_DEREF GetFullName() + " into " +
              GetFullName() + "!");
        DebugBreak();
        return;
      }
    }

    if (indi_src.IsSet()) {
      if (bool(flags & INDI_FLAG_SOURCE_REQ_INDEXABLE_BY_SHIFT) &&
          !bool(_indi PTR_DEREF GetFlags() & INDI_FLAG_INDEXABLE_BY_SHIFT)) {
        Print(GetFullName(), ": Cannot set data source to ", _indi PTR_DEREF GetFullName(),
              ", because source indicator isn't indexable by shift!");
        DebugBreak();
        return;
      }
      if (bool(flags & INDI_FLAG_SOURCE_REQ_INDEXABLE_BY_TIMESTAMP) &&
          !bool(_indi PTR_DEREF GetFlags() & INDI_FLAG_INDEXABLE_BY_TIMESTAMP)) {
        Print(GetFullName(), ": Cannot set data source to ", _indi PTR_DEREF GetFullName(),
              ", because source indicator isn't indexable by timestamp!");
        DebugBreak();
        return;
      }
    }

    if (indi_src.IsSet() && indi_src.Ptr() != _indi) {
      indi_src REF_DEREF RemoveListener(THIS_PTR);
    }
    indi_src = _indi;
    if (_indi != NULL) {
      indi_src REF_DEREF AddListener(THIS_PTR);
      Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_SRC_ID), -1);
      Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_SRC_MODE), _input_mode);
      indi_src REF_DEREF OnBecomeDataSourceFor(THIS_PTR);
    }
  }

  /**
   * Uses custom value storage type as applied price.
   */
  void SetDataSourceAppliedPrice(ENUM_INDI_DATA_VS_TYPE _vs_type) {
    // @todo Check if given value storage is of compatible type (double)!
    retarget_ap_av = _vs_type;
  }

  /**
   * Sets data source's input mode.
   */
  // void SetDataSourceMode(int _mode) { indi_src_mode = _mode; }

  /* Candle methods */

  /**
   * Checks whether there is Candle-featured in the hierarchy.
   */
  bool HasCandleInHierarchy() { return GetCandle(false) != nullptr; }

  /**
   * Checks whether current indicator has all buffers required to be a Candle-compatible indicator.
   */
  bool IsCandleIndicator() {
    return HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_OPEN) && HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_HIGH) &&
           HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_LOW) && HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_CLOSE) &&
           HasSpecificValueStorage(INDI_DATA_VS_TYPE_SPREAD) && HasSpecificValueStorage(INDI_DATA_VS_TYPE_TICK_VOLUME) &&
           HasSpecificValueStorage(INDI_DATA_VS_TYPE_TIME) && HasSpecificValueStorage(INDI_DATA_VS_TYPE_VOLUME);
  }

  /* Tick methods */

  /**
   * Checks whether current indicator has all buffers required to be a Tick-compatible indicator.
   */
  bool IsTickIndicator() {
    return HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_ASK) && HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_BID) &&
           HasSpecificValueStorage(INDI_DATA_VS_TYPE_SPREAD) && HasSpecificValueStorage(INDI_DATA_VS_TYPE_VOLUME) &&
           HasSpecificValueStorage(INDI_DATA_VS_TYPE_TICK_VOLUME);
  }

  bool Tick(int _global_tick_index) {
    if (last_tick_index == _global_tick_index) {
#ifdef __debug_indicator__
      Print("We've already ticked tick index #", _global_tick_index, ". Skipping Tick() for ", GetFullName());
#endif
      // We've already ticked.
      return last_tick_result;
    }

    if (_global_tick_index == 0) {
      // Time of the first tick must be compatible with time generated by IndicatorTick, e.g., Indi_TickMt.
      first_tick_time_ms = TimeCurrent() * 1000;
    }

    last_tick_index = _global_tick_index;

    last_tick_result = false;

    // Checking and potentially initializing new data source.
    if (HasDataSource(true)) {
      // Ticking data source if not yet ticked.

      // If data source returns true, that means it ticked and there could be more ticks in the future.
      last_tick_result |= GetDataSource() PTR_DEREF Tick(_global_tick_index);
    }

    // Also ticking all used indicators if they've not yet ticked.
    for (DictStructIterator<int, Ref<IndicatorData>> iter = indicators.Begin(); iter.IsValid(); ++iter) {
      // If any of the attached indicators ticks then we signal that the tick happened, even if this indicator doesn't
      // tick. It is because e.g., RSI could use Candle indicator and Candle could use Tick indicator. Ticking RSI
      // doesn't signal tick in RSI, nor Candle, but only Tick indicator and only if new tick occured in the Tick
      // indicator. In other words: Only Tick indicator returns true in its OnTick(). Also, in OnTick() it sends a tick
      // into Candle indicator which aggregates ticks. RSI doesn't have OnTick() and we can't know if there is new RSI
      // value. The only way to know that is to Tick all indicators in hierarchy and if one of them returns true in
      // OnTick() then we know that we have new value for RSI.
      bool _tick_result = iter.Value() REF_DEREF Tick(_global_tick_index);

#ifdef __debug_indicator__
      Print(iter.Value() REF_DEREF GetFullName(), "'s Tick() result: ", _tick_result ? "true" : "false");
#endif

      last_tick_result |= _tick_result;
    }

    // Overridable OnTick() method.
    last_tick_result |= OnTick(_global_tick_index);

    return last_tick_result;
  }

  /**
   * Checks whether there is Tick-featured in the hierarchy.
   */
  bool HasTickInHierarchy() { return GetTick(false) != nullptr; }

  /* Data source methods */

  /**
   * Injects data source between this indicator and its data source.
   */
  void InjectDataSource(IndicatorData* _indi) {
    if (_indi == THIS_PTR) {
      // Indicator already injected.
      return;
    }

    IndicatorData* _previous_ds = GetDataSource(false);

    SetDataSource(_indi);

    if (_previous_ds != nullptr) {
      _indi PTR_DEREF SetDataSource(_previous_ds);
    }
  }

  /**
   * Loads and validates built-in indicators whose can be used as data source.
   */
  void ValidateDataSource(IndicatorData* _target, IndicatorData* _source) {
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

    if (!_target PTR_DEREF IsDataSourceModeSelectable()) {
      // We don't validate source mode as it will use all modes.
      return;
    }

    if (_source PTR_DEREF GetModeCount() > 1 &&
        _target PTR_DEREF idparams.Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DATA_SRC_MODE)) == -1) {
      // Mode must be selected if source indicator has more that one mode.
      Alert("Warning! ", GetName(),
            " must select source indicator's mode via SetDataSourceMode(int). Defaulting to mode 0.");
      _target PTR_DEREF idparams.Set(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DATA_SRC_MODE), 0);
      DebugBreak();
    } else if (_source PTR_DEREF Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DATA_SRC_MODE)) == 1 &&
               _target PTR_DEREF idparams.Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DATA_SRC_MODE)) == -1) {
      _target PTR_DEREF idparams.Set(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DATA_SRC_MODE), 0);
    } else if (_target PTR_DEREF idparams.Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DATA_SRC_MODE)) < 0 ||
               _target PTR_DEREF idparams.Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DATA_SRC_MODE)) >
                   _source PTR_DEREF Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES))) {
      Alert("Error! ", _target PTR_DEREF GetName(),
            " must select valid source indicator's mode via SetDataSourceMode(int) between 0 and ",
            _source PTR_DEREF Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES)), ".");
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
      if (Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES)) != 1) {
        Alert("Error: ", GetName(), " must have exactly one possible mode in order to skip using SetDataSourceMode()!");
        DebugBreak();
      }
      _out_mode = 0;
    } else if (_out_mode + 1 > Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES))) {
      Alert("Error: ", GetName(), " have ", Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES)),
            " mode(s) buy you tried to reference mode with index ", _out_mode,
            "! Ensure that you properly set mode via SetDataSourceMode().");
      DebugBreak();
    }
  }

  /**
   * Validates currently selected indicator used as data source.
   */
  void ValidateSelectedDataSource() {
    if (HasDataSource()) {
      ValidateDataSource(THIS_PTR, GetDataSourceRaw());
    }
  }

  /* Handle methods */

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

  /* Printers */

  /**
   * Returns the indicator's value in plain format.
   */
  string EntryToString(int _index = 0) {
    IndicatorDataEntry _entry = GetEntry(_index);
    int _serializer_flags = SERIALIZER_FLAG_SKIP_HIDDEN | SERIALIZER_FLAG_INCLUDE_DEFAULT |
                            SERIALIZER_FLAG_INCLUDE_DYNAMIC | SERIALIZER_FLAG_INCLUDE_FEATURE;

    IndicatorDataEntry _stub_entry;
    _stub_entry.AddFlags(_entry.GetFlags());
    SerializerConverter _stub = SerializerConverter::MakeStubObject(_stub_entry, _serializer_flags, _entry.GetSize());
    return SerializerConverter::FromObject(_entry, _serializer_flags).ToString<SerializerCsv>(0, &_stub);
  }

  template <typename T>
  T GetValue(int _mode = 0, int _rel_shift = 0) {
    T _out;
    GetEntryValue(_mode, ToAbsShift(_rel_shift)).Get(_out);
    return _out;
  }

  /* Virtual methods */

  /**
   * Returns applied price as set by the indicator's params.
   */
  virtual ENUM_APPLIED_PRICE GetAppliedPrice() {
    Print("Error: GetAppliedPrice() was requested by ", GetFullName(), ", but it does not implement it!");
    DebugBreak();
    return (ENUM_APPLIED_PRICE)-1;
  }

  /**
   * Returns value storage's buffer type from this indicator's applied price (indicator must override GetAppliedPrice()
   * method!).
   */
  virtual ENUM_INDI_DATA_VS_TYPE GetAppliedPriceValueStorageType() {
    if (retarget_ap_av != INDI_DATA_VS_TYPE_NONE) {
      // User wants to use custom value storage type as applied price.
      return retarget_ap_av;
    }

    switch (GetAppliedPrice()) {
      case PRICE_OPEN:
        return INDI_DATA_VS_TYPE_PRICE_OPEN;
      case PRICE_HIGH:
        return INDI_DATA_VS_TYPE_PRICE_HIGH;
      case PRICE_LOW:
        return INDI_DATA_VS_TYPE_PRICE_LOW;
      case PRICE_CLOSE:
        return INDI_DATA_VS_TYPE_PRICE_CLOSE;
      case PRICE_MEDIAN:
        return INDI_DATA_VS_TYPE_PRICE_MEDIAN;
      case PRICE_TYPICAL:
        return INDI_DATA_VS_TYPE_PRICE_TYPICAL;
      case PRICE_WEIGHTED:
        return INDI_DATA_VS_TYPE_PRICE_WEIGHTED;
      default:
        if ((int)GetAppliedPrice() == (int)PRICE_ASK) {
          return INDI_DATA_VS_TYPE_PRICE_ASK;
        } else if ((int)GetAppliedPrice() == (int)PRICE_BID) {
          return INDI_DATA_VS_TYPE_PRICE_BID;
        }
    }

    Print("Error: ", GetFullName(), " has not supported applied price set: ", EnumToString(GetAppliedPrice()), "!");
    DebugBreak();
    return (ENUM_INDI_DATA_VS_TYPE)-1;
  }

  /**
   * Returns applied volume as set by the indicator's params.
   */
  virtual ENUM_APPLIED_VOLUME GetAppliedVolume() {
    Print("Error: GetAppliedVolume() was requested by ", GetFullName(), ", but it does not implement it!");
    DebugBreak();
    return (ENUM_APPLIED_VOLUME)-1;
  }

  /**
   * Returns value storage's buffer type from this indicator's applied volume (indicator must override
   * GetAppliedVolume() method!).
   */
  virtual ENUM_INDI_DATA_VS_TYPE GetAppliedVolumeValueStorageType() {
    if (retarget_ap_av != INDI_DATA_VS_TYPE_NONE) {
      // User wants to use custom value storage type as applied volume.
      return retarget_ap_av;
    }

    switch (GetAppliedVolume()) {
      case VOLUME_TICK:
        return INDI_DATA_VS_TYPE_TICK_VOLUME;
      case VOLUME_REAL:
        return INDI_DATA_VS_TYPE_VOLUME;
    }

    Print("Error: ", GetFullName(), " has not supported applied volume set: ", EnumToString(GetAppliedVolume()), "!");
    DebugBreak();
    return (ENUM_INDI_DATA_VS_TYPE)-1;
  }

  /**
   * Gets ask price for a given shift. Return current ask price if _shift wasn't passed or is 0.
   */
  virtual double GetAsk(int _shift = 0) { return GetTick() PTR_DEREF GetAsk(_shift); }

  /**
   * Gets bid price for a given shift. Return current bid price if _shift wasn't passed or is 0.
   */
  virtual double GetBid(int _shift = 0) { return GetTick() PTR_DEREF GetBid(_shift); }

  /**
   * Returns the number of bars on the chart decremented by iparams.shift.
   */
  virtual int GetBars() { return GetCandle() PTR_DEREF GetBars(); }

  /**
   * Returns index of the current bar.
   */
  virtual int GetBarIndex() { return GetCandle() PTR_DEREF GetBarIndex(); }

  /**
   * Returns time of the bar for a given shift.
   */
  virtual datetime GetBarTime(int _rel_shift = 0) {
    IndicatorData* _indi = GetCandle(false);

    if (_indi == nullptr) _indi = GetTick(false);

    if (_indi == nullptr) {
      Print("Error: Neither candle nor tick indicator exists in the hierarchy of ", GetFullName(), "!");
      DebugBreak();
      return (datetime)0;
    }

#ifdef __debug_items_history__
    Print("Getting bar time for shift ", _rel_shift, " for ", GetFullName());
#endif

    return _indi PTR_DEREF GetBarTime(_rel_shift);
  }

  /**
   * Search for a bar by its time.
   *
   * Returns the index of the bar which covers the specified time.
   */
  virtual int GetBarShift(datetime _time, bool _exact = false) {
    return GetTick() PTR_DEREF GetBarShift(_time, _exact);
  }

  /**
   * Traverses source indicators' hierarchy and tries to find OHLC-featured
   * indicator. IndicatorCandle satisfies such requirements.
   */
  virtual IndicatorData* GetCandle(bool _warn_if_not_found = true, IndicatorData* _originator = nullptr) {
    if (_originator == nullptr) {
      _originator = THIS_PTR;
    }
    if (IsCandleIndicator()) {
      return THIS_PTR;
    } else if (HasDataSource()) {
      return GetDataSource() PTR_DEREF GetCandle(_warn_if_not_found, _originator);
    } else {
      // _indi_src == NULL.
      if (_warn_if_not_found) {
        Print(
            "Can't find Candle-compatible indicator (which have storage buffers for: Open, High, Low, Close, Spread, "
            "Tick Volume, Time, Volume) in the "
            "hierarchy of ",
            _originator PTR_DEREF GetFullName(), "!");
        DebugBreak();
      }
      return NULL;
    }
  }

  /**
   * Get data type of indicator.
   */
  virtual ENUM_DATATYPE GetDataType() { return (ENUM_DATATYPE)-1; }

  /**
   * Gets close price for a given, optional shift.
   */
  virtual double GetClose(int _shift = 0) { return GetCandle() PTR_DEREF GetClose(_shift); }

  /**
   * Returns the indicator's struct value via index.
   */
  virtual IndicatorDataEntry GetEntry(int _rel_shift = 0) = 0;

  /**
   * Returns the indicator's struct value via timestamp.
   */
  // virtual IndicatorDataEntry GetEntry(datetime _dt) = NULL;

  /**
   * Gets high price for a given, optional shift.
   */
  virtual double GetHigh(int _shift = 0) { return GetCandle() PTR_DEREF GetHigh(_shift); }

  /**
   * Alters indicator's struct value.
   *
   * This method allows user to modify the struct entry before it's added to cache.
   * This method is called on GetEntry() right after values are set.
   */
  virtual void GetEntryAlter(IndicatorDataEntry& _entry, int _rel_shift) {}

  // virtual ENUM_IDATA_VALUE_RANGE GetIDataValueRange() = NULL;

  /**
   * Returns the indicator's entry value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _abs_shift = 0) = 0;

  /**
   * Returns the shift of the maximum value over a specific number of periods depending on type.
   */
  virtual int GetHighest(int type, int _count = WHOLE_ARRAY, int _start = 0) {
    return GetCandle() PTR_DEREF GetHighest(type, _count, _start);
  }

  /**
   * Returns time of the last bar.
   */
  virtual datetime GetLastBarTime() { return GetCandle() PTR_DEREF GetLastBarTime(); }

  /**
   * Gets low price for a given, optional shift.
   */
  virtual double GetLow(int _shift = 0) { return GetCandle() PTR_DEREF GetLow(_shift); }

  /**
   * Returns the shift of the minimum value over a specific number of periods depending on type.
   */
  virtual int GetLowest(int type, int _count = WHOLE_ARRAY, int _start = 0) {
    return GetCandle() PTR_DEREF GetLowest(type, _count, _start);
  }

  /**
   * Gets number of modes available to retrieve by GetValue().
   */
  virtual unsigned int GetModeCount() {
    return idparams.Get<unsigned int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES));
  }

  /**
   * Get name of the indicator.
   */
  virtual string GetName() { return EnumToString(GetType()); }

  /**
   * Gets open price for a given, optional shift.
   */
  virtual double GetOpen(int _shift = 0) { return GetCandle() PTR_DEREF GetOpen(_shift); }

  /**
   * Gets OHLC price values.
   */
  virtual BarOHLC GetOHLC(int _rel_shift = 0) { return GetCandle() PTR_DEREF GetOHLC(_rel_shift); }

  /**
   * Get peak price at given number of bars.
   *
   * In case of error, check it via GetLastError().
   */
  virtual double GetPeakPrice(int _bars, int _mode, int _index) {
    return GetTick() PTR_DEREF GetPeakPrice(_bars, _mode, _index);
  }

  /**
   * Returns the current price value given applied price type, symbol and timeframe.
   */
  virtual double GetPrice(ENUM_APPLIED_PRICE _ap, int _rel_shift = 0) {
    return GetCandle() PTR_DEREF GetPrice(_ap, _rel_shift);
  }

  /**
   * Gets indicator's signals.
   *
   * When indicator values are not valid, returns empty signals.
   */
  virtual IndicatorSignal GetSignals(int _count = 3, int _shift = 0, int _mode1 = 0, int _mode2 = 0) = 0;

  /**
   * Returns spread for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual long GetSpread(int _shift = 0) { return GetCandle() PTR_DEREF GetSpread(_shift); }

  /**
   * Returns spread in pips.
   */
  virtual double GetSpreadInPips(int _shift = 0) {
    return (GetAsk() - GetBid()) * pow(10, GetSymbolProps().GetPipDigits());
  }

  virtual bool HasSpecificAppliedPriceValueStorage(ENUM_APPLIED_PRICE _ap, IndicatorData* _target = nullptr) {
    if (_target != nullptr) {
      if (_target PTR_DEREF GetDataSourceAppliedType() != INDI_DATA_VS_TYPE_NONE) {
        // User wants to use custom value storage type as applied price, so we forcefully override AP given as the
        // parameter.
        // @todo Check for value storage compatibility (double).
        return HasSpecificValueStorage(_target PTR_DEREF GetDataSourceAppliedType());
      }
    }

    switch (_ap) {
      case PRICE_OPEN:
        return HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_OPEN);
      case PRICE_HIGH:
        return HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_HIGH);
      case PRICE_LOW:
        return HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_LOW);
      case PRICE_CLOSE:
        return HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_CLOSE);
      case PRICE_MEDIAN:
        return HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_MEDIAN);
      case PRICE_TYPICAL:
        return HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_TYPICAL);
      case PRICE_WEIGHTED:
        return HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_WEIGHTED);
      default:
        if ((int)GetAppliedPrice() == (int)PRICE_ASK) {
          return HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_ASK);
        } else if ((int)GetAppliedPrice() == (int)PRICE_BID) {
          return HasSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_BID);
        }
        Print("Error: Invalid applied price " + EnumToString(_ap) +
              ", only PRICE_(OPEN|HIGH|LOW|CLOSE|MEDIAN|TYPICAL|WEIGHTED) are currently supported by "
              "IndicatorData::HasSpecificAppliedPriceValueStorage()!");
        DebugBreak();
        return false;
    }
  }

  /**
   * Returns value storage to be used for given applied price or applied price overriden by target indicator via
   * SetDataSourceAppliedPrice().
   */
  ValueStorage<double>* GetSpecificAppliedPriceValueStorage(ENUM_APPLIED_PRICE _ap, IndicatorData* _target = nullptr) {
    if (_target != nullptr) {
      if (_target PTR_DEREF GetDataSourceAppliedType() != INDI_DATA_VS_TYPE_NONE) {
        // User wants to use custom value storage type as applied price, so we forcefully override AP given as the
        // parameter.
        // @todo Check for value storage compatibility (double).
        return (ValueStorage<double>*)GetSpecificValueStorage(_target PTR_DEREF GetDataSourceAppliedType());
      }
    }

    switch (_ap) {
      case PRICE_OPEN:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_OPEN);
      case PRICE_HIGH:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_HIGH);
      case PRICE_LOW:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_LOW);
      case PRICE_CLOSE:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_CLOSE);
      case PRICE_MEDIAN:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_MEDIAN);
      case PRICE_TYPICAL:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_TYPICAL);
      case PRICE_WEIGHTED:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_WEIGHTED);
      default:
        if ((int)GetAppliedPrice() == (int)PRICE_ASK) {
          return (ValueStorage<double>*)GetSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_ASK);
        } else if ((int)GetAppliedPrice() == (int)PRICE_BID) {
          return (ValueStorage<double>*)GetSpecificValueStorage(INDI_DATA_VS_TYPE_PRICE_BID);
        }
        Print("Error: Invalid applied price " + EnumToString(_ap) +
              ", only PRICE_(OPEN|HIGH|LOW|CLOSE|MEDIAN|TYPICAL|WEIGHTED) are currently supported by "
              "IndicatorData::GetSpecificAppliedPriceValueStorage()!");
        DebugBreak();
        return NULL;
    }
  }

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  virtual unsigned int GetSuitableDataSourceTypes() { return 0; }

  /**
   * Gets indicator's symbol.
   */
  virtual string GetSymbol() { return GetTick() PTR_DEREF GetSymbol(); }

  /**
   * Gets symbol info for active symbol.
   */
  virtual SymbolInfoProp GetSymbolProps() { return GetTick() PTR_DEREF GetSymbolProps(); }

  /**
   * Gets indicator's time-frame.
   */
  virtual ENUM_TIMEFRAMES GetTf() { return GetCandle() PTR_DEREF GetTf(); }

  /**
   * Traverses source indicators' hierarchy and tries to find Ask, Bid, Spread,
   * Volume and Tick Volume-featured indicator. IndicatorTick satisfies such
   * requirements.
   */
  virtual IndicatorData* GetTick(bool _warn_if_not_found = true) {
    if (IsTickIndicator()) {
      return THIS_PTR;
    } else if (HasDataSource()) {
      return GetDataSource() PTR_DEREF GetTick();
    }

    // No IndicatorTick compatible indicator found in hierarchy.
    if (_warn_if_not_found) {
      Print(
          "Can't find Tick-compatible indicator (which have storage buffers for: Ask, Bid, Spread, Volume, Tick "
          "Volume) in the hierarchy!");
      DebugBreak();
    }
    return NULL;
  }

  /**
   * Returns tick volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual long GetTickVolume(int _shift = 0) { return GetCandle() PTR_DEREF GetTickVolume(_shift); }

  /**
   * Removes candle from the buffer. Used mainly for testing purposes.
   */
  virtual void InvalidateCandle(int _abs_shift = 0) { GetCandle() PTR_DEREF InvalidateCandle(_abs_shift); }

  /**
   * Fetches historic ticks for a given time range.
   */
  bool FetchHistoryByTimeRange(long _from_ms, long _to_ms, ARRAY_REF(TickTAB<double>, _out_ticks)) { return false; }

  /**
   * Fetches historic ticks for a given start time and minimum number of tick to retrieve.
   */
  bool FetchHistoryByStartTimeAndCount(long _from_ms, ENUM_ITEMS_HISTORY_DIRECTION _dir, int _min_count,
                                       ARRAY_REF(TickTAB<double>, _out_ticks)) {
    // Print("FetchHistoryByStartTimeAndCount:");
    // Print("- Requested _from_ms = ", _from_ms, ", _dir = ", EnumToString(_dir), ", _min_count = ", _min_count);

    ArrayResize(_out_ticks, 0);

    // Number of ticks still to retrieve to satisfy the caller.
    int _num_to_retrieve = _min_count, i, o;

    // Ticks per fixed time range.
    static ARRAY(TickTAB<double>, _recv_ticks);

    // Time-frames for which we'll be receiving ticks.
    long _recv_range_ms = 1000 * 60 * 30;  // 30 min time-frames.

    // Calculating initial time frame.
    if (_dir == ITEMS_HISTORY_DIRECTION_BACKWARD) {
      // _from_ms will be at start of previous time-frame.
      _from_ms -= _recv_range_ms - 1;
    }
    // _to_ms will be at the last ms of _from_ms's timeframe.
    long _to_ms = _from_ms + _recv_range_ms - 1;

    // Print("- Initial _from_ms = ", _from_ms, "_to_ms = ", _to_ms);

    do {
      bool _success = FetchHistoryByTimeRange(_from_ms, _to_ms, _recv_ticks);

      int _num_ticks_before = ArraySize(_out_ticks);
      int _num_received = ArraySize(_recv_ticks);

      // Our _out_tick must fit additional received ticks.
      ArrayResize(_out_ticks, _num_ticks_before + _num_received);

      if (_dir == ITEMS_HISTORY_DIRECTION_BACKWARD) {
        // Moving output ticks from the beginning to the end.
        // i = input index, o = output index.
        for (i = 0, o = _num_ticks_before; i < _num_received; i++, o++) {
          _out_ticks[o] = _out_ticks[i];
        }
      }

      for (i = 0; i < ArraySize(_recv_ticks); ++i) {
        if (_dir == ITEMS_HISTORY_DIRECTION_FORWARD) {
          // Pushing received ticks at the end of the output ticks.
          ArrayPushObject(_out_ticks, _recv_ticks[i]);
        } else {
          // Filling the beginning of the output ticks with received ticks.
          _out_ticks[i] = _recv_ticks[i];
        }
      }

      if (!_success) {
        // An error happended;
        break;
      }

      _num_to_retrieve -= _num_received;

      if (_dir == ITEMS_HISTORY_DIRECTION_FORWARD) {
        // Going to the next time-frame.
        _from_ms += _recv_range_ms;
        _to_ms += _recv_range_ms;
      } else {
        // Going to the previous time-frame.
        _from_ms -= _recv_range_ms;
        _to_ms -= _recv_range_ms;
      }

    } while (_LastError != 0 && _num_to_retrieve > 0);

    // _num_to_retrieve may be negative and it's perfectly fine. We'll just have more ticks than we wanted in the output
    // array.
    return _num_to_retrieve <= 0;
  }

  /**
   * Returns value storage of given kind.
   */
  virtual IValueStorage* GetSpecificValueStorage(ENUM_INDI_DATA_VS_TYPE _type) {
    Print("Error: ", GetFullName(), " indicator has no storage type ", EnumToString(_type), "!");
    DebugBreak();
    return NULL;
  }

  /**
   * Returns best suited data source for this indicator.
   */
  virtual IndicatorData* GetSuitableDataSource(bool _warn_if_not_found = true) {
    Flags<unsigned int> _suitable_types = GetSuitableDataSourceTypes();
    IndicatorData* _curr_indi;

    // There shouldn't be any attached data source.
    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_EXPECT_NONE) && GetDataSource() != nullptr) {
      if (_warn_if_not_found) {
        Print("Error: ", GetFullName(), " doesn't support attaching data source, but has one attached!");
        DebugBreak();
      }
      return nullptr;
    }

    // Custom set of required buffers. Will invoke virtual OnCheckIfSuitableDataSource().
    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_CUSTOM)) {
      // Searching suitable data source in hierarchy.
      for (_curr_indi = GetDataSource(false); _curr_indi != nullptr;
           _curr_indi = _curr_indi PTR_DEREF GetDataSource(false)) {
        if (OnCheckIfSuitableDataSource(_curr_indi)) return _curr_indi;

        if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_BASE_ONLY)) {
          // Directly connected data source must be suitable, so we stops for loop.
          if (_warn_if_not_found) {
            Print("Error: ", GetFullName(),
                  " requested custom type of data source to be directly connected to this indicator, but none "
                  "satisfies the requirements!");
            DebugBreak();
          }
          return nullptr;
        }
      }

      if (_warn_if_not_found) {
        Print("Error: ", GetFullName(),
              " requested custom type of indicator as data source, but there is none in the hierarchy which satisfies "
              "the requirements!");
        DebugBreak();
      }
      return nullptr;
    }

    // Requires Candle-compatible indicator in the hierarchy.
    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_CANDLE)) {
      if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_BASE_ONLY)) {
        // Candle indicator must be directly connected to this indicator as its data source.
        _curr_indi = GetDataSource(false);

        if (_curr_indi == nullptr || !_curr_indi PTR_DEREF IsCandleIndicator()) {
          if (_warn_if_not_found) {
            Print("Error: ", GetFullName(),
                  " must have Candle-compatible indicator directly conected as a data source! We don't search for it "
                  "further in the hierarchy.");
            DebugBreak();
          }
          return nullptr;
        }

        return _curr_indi;
      } else {
        // Candle indicator must be in the data source hierarchy.
        _curr_indi = GetCandle(false);

        if (_curr_indi != nullptr) return _curr_indi;

        if (!_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_TICK)) {
          if (_warn_if_not_found) {
            Print("Error: ", GetFullName(),
                  " requested Candle-compatible type of indicator as data source, but there is none in the hierarchy!");
            DebugBreak();
          }
          return nullptr;
        }
      }
    }

    // Requires Tick-compatible indicator in the hierarchy.
    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_TICK)) {
      if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_BASE_ONLY)) {
        // Tick indicator must be directly connected to this indicator as its data source.
        _curr_indi = GetDataSource(false);

        if (_curr_indi == nullptr || !_curr_indi PTR_DEREF IsTickIndicator()) {
          if (_warn_if_not_found) {
            Print("Error: ", GetFullName(),
                  " must have Tick-compatible indicator directly connected as a data source! We don't search for it "
                  "further in the hierarchy.");
            DebugBreak();
          }
        }

        return _curr_indi;
      } else {
        _curr_indi = GetTick(false);
        if (_curr_indi != nullptr) return _curr_indi;

        if (_warn_if_not_found) {
          Print("Error: ", GetFullName(), " must have Tick-compatible indicator in the data source hierarchy!");
          DebugBreak();
        }
        return nullptr;
      }
    }

    ENUM_INDI_DATA_VS_TYPE _requested_vs_type;

    // Requires a single buffered or OHLC-compatible indicator (targetted via applied price) in the hierarchy.
    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_AP)) {
      // Applied price is defined by this indicator, so it must override GetAppliedPrice().
      _requested_vs_type = GetAppliedPriceValueStorageType();

      // Searching for given buffer type in the hierarchy.
      for (_curr_indi = GetDataSource(false); _curr_indi != nullptr;
           _curr_indi = _curr_indi PTR_DEREF GetDataSource(false)) {
        if (_curr_indi PTR_DEREF HasSpecificValueStorage(_requested_vs_type)) {
          return _curr_indi;
        }

        if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_BASE_ONLY)) {
          // Directly connected data source must have given data storage buffer, so we stops for loop.
          if (_warn_if_not_found) {
            Print("Error: ", GetFullName(),
                  " requested directly connected data source to contain value storage of type ",
                  EnumToString(_requested_vs_type), ", but there is no such data storage!");
            DebugBreak();
          }
          return nullptr;
        }
      }

      if (_warn_if_not_found) {
        Print("Error: ", GetFullName(), " requested that there is data source that contain value storage of type ",
              EnumToString(_requested_vs_type), " in the hierarchy, but there is no such data source!");
        DebugBreak();
      }
      return nullptr;
    }

    // Requires a single buffered or OHLC-compatible indicator (targetted via applied price or volume) in the hierarchy.
    if (_suitable_types.HasAnyFlag(INDI_SUITABLE_DS_TYPE_AP | INDI_SUITABLE_DS_TYPE_AV)) {
      _requested_vs_type = (ENUM_INDI_DATA_VS_TYPE)-1;

      if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_AP)) {
        // Applied price is defined by this indicator, so it must override GetAppliedPrice().
        _requested_vs_type = GetAppliedPriceValueStorageType();
      } else if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_AV)) {
        // Applied volume is defined by this indicator, so it must override GetAppliedVolume().
        _requested_vs_type = GetAppliedVolumeValueStorageType();
      }

      // Searching for given buffer type in the hierarchy.
      for (_curr_indi = GetDataSource(false); _curr_indi != nullptr;
           _curr_indi = _curr_indi PTR_DEREF GetDataSource(false)) {
        if (_curr_indi PTR_DEREF HasSpecificValueStorage(_requested_vs_type)) {
          return _curr_indi;
        }

        if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_BASE_ONLY)) {
          // Directly connected data source must have given data storage buffer, so we stops for loop.
          if (_warn_if_not_found) {
            Print("Error: ", GetFullName(),
                  " requested directly connected data source to contain value storage of type ",
                  EnumToString(_requested_vs_type), ", but there is no such data storage!");
            DebugBreak();
          }
          return nullptr;
        }
      }

      if (_warn_if_not_found) {
        Print("Error: ", GetFullName(), " requested that there is data source that contain value storage of type ",
              EnumToString(_requested_vs_type), " in the hierarchy, but there is no such data source!");
        DebugBreak();
      }
      return nullptr;
    }

    if (_warn_if_not_found) {
      Print("Error: ", GetFullName(),
            " must have data source, but its configuration leave us without suitable one. Please override "
            "GetSuitableDataSourceTypes() method so it will return suitable data source types!");
      DebugBreak();
    }

    return nullptr;
  }

  /**
   * Returns current tick index (incremented every OnTick()).
   */
  virtual int GetTickIndex() { return GetTick() PTR_DEREF GetTickIndex(); }

  /**
   * Get indicator type.
   */
  virtual ENUM_INDICATOR_TYPE GetType() { return INDI_NONE; }

  /**
   * Returns value storage for a given mode.
   */
  virtual IValueStorage* GetValueStorage(int _mode = 0) {
    if (_mode >= ArraySize(value_storages)) {
      ArrayResize(value_storages, _mode + 1);
    }

    if (!value_storages[_mode].IsSet()) {
      value_storages[_mode] =
          ExternInstantiateIndicatorBufferValueStorageDouble::InstantiateIndicatorBufferValueStorageDouble(THIS_PTR,
                                                                                                           _mode);
    }
    return value_storages[_mode].Ptr();
  }

  /**
   * Returns volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual long GetVolume(int _shift = 0) { return GetCandle() PTR_DEREF GetVolume(_shift); }

  /**
   * Sends entry to listening indicators.
   */
  void EmitEntry(IndicatorDataEntry& entry) {
    for (int i = 0; i < ArraySize(listeners); ++i) {
      if (listeners[i].ObjectExists()) {
        listeners[i] REF_DEREF OnDataSourceEntry(entry);
      }
    }
  }

  /**
   * Sends historic entries to listening indicators. May be overriden.
   */
  virtual void EmitHistory() {}

  /**
   * Provides built-in indicators whose can be used as data source.
   */
  virtual IndicatorData* FetchDataSource(ENUM_INDICATOR_TYPE _id) { return NULL; }

  /**
   * Checks whether indicator support given value storage type.
   */
  virtual bool HasSpecificValueStorage(ENUM_INDI_DATA_VS_TYPE _type) {
    // Maybe indexed value storage? E.g., INDI_DATA_VS_TYPE_INDEX_0.
    if ((int)_type >= INDI_DATA_VS_TYPE_INDEX_FIRST && (int)_type <= INDI_DATA_VS_TYPE_INDEX_LAST) {
      return HasValueStorage((int)_type - INDI_DATA_VS_TYPE_INDEX_FIRST);
    }
    return false;
  }

  /**
   * Check if there is a new bar to parse.
   */
  virtual bool IsNewBar() { return GetCandle() PTR_DEREF IsNewBar(); }

  /**
   * Called when indicator became a data source for other indicator.
   */
  virtual void OnBecomeDataSourceFor(IndicatorData* _base_indi){};

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  virtual bool OnCheckIfSuitableDataSource(IndicatorData* _ds) {
    Flags<unsigned int> _suitable_types = GetSuitableDataSourceTypes();

    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_EXPECT_NONE)) {
      return false;
    }

    ENUM_INDI_DATA_VS_TYPE _requested_vs_type;

    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_AP)) {
      _requested_vs_type = GetAppliedPriceValueStorageType();
      return _ds PTR_DEREF HasSpecificValueStorage(_requested_vs_type);
    }

    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_AV)) {
      _requested_vs_type = GetAppliedVolumeValueStorageType();
      return _ds PTR_DEREF HasSpecificValueStorage(_requested_vs_type);
    }

    return false;
  }

  /**
   * Called when data source emits new entry (historic or future one).
   */
  virtual void OnDataSourceEntry(IndicatorDataEntry& entry){};

  /**
   * Called when new tick is retrieved from attached data source.
   */
  virtual bool OnTick(int _global_tick_index) {
    // We really don't know if new tick have happened. Let's just return false and let the Platform's Tick() method tick
    // the Tick indicator in order to know if new tick was signalled.
    return false;
  }

  /**
   * Called if data source is requested, but wasn't yet set. May be used to initialize indicators that must operate on
   * some data source.
   */
  virtual IndicatorData* OnDataSourceRequest() {
    Print("In order to use IDATA_INDICATOR mode for indicator ", GetFullName(),
          " without explicitly selecting an indicator, ", GetFullName(),
          " must override OnDataSourceRequest() method and return new instance of data source to be used by default.");
    DebugBreak();
    return NULL;
  }

  /**
   * Creates default, tick based indicator for given applied price.
   */
  virtual IndicatorData* DataSourceRequestReturnDefault(int _applied_price) {
    DebugBreak();
    return NULL;
  }

  /**
   * Called when user tries to set given data source. Could be used to check if indicator implements all required value
   * storages.
   */
  virtual bool OnValidateDataSource(IndicatorData* _ds, string& _reason) {
    _reason = "Indicator " + GetName() + " does not implement OnValidateDataSource()";
    return false;
  }

  /**
   * Sets symbol info for symbol attached to the indicator.
   */
  virtual void SetSymbolProps(const SymbolInfoProp& _props) {}

  /**
   * Appends given entry into the history.
   */
  virtual void AppendEntry(IndicatorDataEntry& entry) {}

  /**
   * Update indicator.
   */
  virtual bool Update() {
    // @todo
    return false;
  };

  /**
   * Converts relative shift into absolute one.
   */
  virtual int ToAbsShift(int _rel_shift) = 0;

  /**
   * Converts absolute shift into relative one.
   */
  virtual int ToRelShift(int _abs_shift) = 0;

  /**
   * Loads and validates built-in indicators whose can be used as data source.
   */
  // virtual void ValidateDataSource(IndicatorData* _target, IndicatorData* _source) {}
};

/**
 * BarsCalculated()-compatible method to be used on Indicator instance.
 */
int BarsCalculated(IndicatorData* _indi) { return _indi PTR_DEREF GetBarsCalculated(); }

/**
 * CopyBuffer() method to be used on Indicator instance with ValueStorage buffer.
 *
 * Note that data will be copied so that the oldest element will be located at the start of the physical memory
 * allocated for the array
 */
template <typename T>
int CopyBuffer(IndicatorData* _indi, int _mode, int _start, int _count, ValueStorage<T>& _buffer, int _rates_total) {
  int _num_copied = 0;
  int _buffer_size = ArraySize(_buffer);

  if (_buffer_size < _rates_total) {
    _buffer_size = ArrayResize(_buffer, _rates_total);
  }

  for (int i = _start; i < _count; ++i) {
    IndicatorDataEntry _entry = _indi PTR_DEREF GetEntry(i);

    if (!_entry.IsValid()) {
      break;
    }

    T _value = _entry.GetValue<T>(_mode);

    _buffer[_buffer_size - i - 1] = _value;
    ++_num_copied;
  }

  return _num_copied;
}

// clang-format off
#include "../Storage/ValueStorage.indicator.h"
// clang-format on

IValueStorage* ExternInstantiateIndicatorBufferValueStorageDouble::InstantiateIndicatorBufferValueStorageDouble(
    IndicatorData* _indi, int _mode) {
  return new IndicatorBufferValueStorage<double>(_indi, _mode);
}

#ifndef __MQL__
int GetBarsFromStart(IndicatorData* _indi) { return _indi PTR_DEREF GetBars(); }
#endif

#ifdef EMSCRIPTEN
#include <emscripten.h>
#include <emscripten/bind.h>

EMSCRIPTEN_BINDINGS(IndicatorData) {
  emscripten::class_<IndicatorData, emscripten::base<IndicatorBase>>("IndicatorData")
      .smart_ptr<Ref<IndicatorData>>("Ref<IndicatorData>")
      .function("SetSource", emscripten::optional_override([](IndicatorData& self, IndicatorData* base) {
                  self.SetDataSource(base);
                }),
                emscripten::allow_raw_pointer<emscripten::arg<0>>());
}

#endif

#endif  // INDICATOR_DATA_H

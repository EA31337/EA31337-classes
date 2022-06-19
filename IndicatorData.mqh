//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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

// Includes.
#include "IndicatorBase.h"
#include "IndicatorData.enum.h"
#include "IndicatorData.struct.h"
#include "IndicatorData.struct.serialize.h"
#include "IndicatorData.struct.signal.h"
#include "Storage/ValueStorage.h"
#include "Storage/ValueStorage.indicator.h"
#include "Storage/ValueStorage.native.h"

/**
 * Implements class to store indicator data.
 */
class IndicatorData : public IndicatorBase {
 protected:
  // Class variables.
  ARRAY(ValueStorage<double>*, value_storages);
  ARRAY(WeakRef<IndicatorData>, listeners);  // List of indicators that listens for events from this one.
  BufferStruct<IndicatorDataEntry> idata;
  DictStruct<int, Ref<IndicatorData>> indicators;  // Indicators list keyed by id.
  IndicatorCalculateCache<double> cache;
  IndicatorDataParams idparams; // Indicator data params.
  Ref<IndicatorData> indi_src;  // Indicator used as data source.

 protected:
  /* Protected methods */

  bool Init() {
    ArrayResize(value_storages, idparams.Get<unsigned int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES)));
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
        if (indi_src.IsSet() == NULL) {
          // Indi_Price* _indi_price = Indi_Price::GetCached(GetSymbol(), GetTf(), iparams.GetShift());
          // SetDataSource(_indi_price, true, PRICE_OPEN);
        }
        break;
    }
    return true;
  }

 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  IndicatorData(const IndicatorDataParams& _idparams, IndicatorData* _indi_src = NULL, int _indi_mode = 0)
    : idparams(_idparams), indi_src(_indi_src) {
  }
  IndicatorData(const IndicatorDataParams& _idparams, ENUM_TIMEFRAMES _tf, string _symbol = NULL)
    : idparams(_idparams), IndicatorBase(_tf, _symbol) {
  }

  /**
   * Class deconstructor.
   */
  virtual ~IndicatorData() {
    for (int i = 0; i < ArraySize(value_storages); ++i) {
      if (value_storages[i] != NULL) {
        delete value_storages[i];
      }
    }
  }

  /* Operator overloading methods */

  /**
   * Access indicator entry data using [] operator via shift.
   */
  IndicatorDataEntry operator[](int _index) {
    if (!bool(flags | INDI_FLAG_INDEXABLE_BY_SHIFT)) {
      Print(GetFullName(), " is not indexable by shift!");
      DebugBreak();
      IndicatorDataEntry _default;
      return _default;
    }
    return GetEntry(_index);
  }

  /**
   * Access indicator entry data using [] operator via datetime.
   */
  IndicatorDataEntry operator[](datetime _dt) {
    if (!bool(flags | INDI_FLAG_INDEXABLE_BY_TIMESTAMP)) {
      Print(GetFullName(), " is not indexable by timestamp!");
      DebugBreak();
      IndicatorDataEntry _default;
      return _default;
    }
    return GetEntry(_dt);
  }

  IndicatorDataEntry operator[](ENUM_INDICATOR_INDEX _index) { return GetEntry((int)_index); }

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
  T Get(STRUCT_ENUM_INDICATOR_STATE_PROP _prop) {
    return istate.Get<T>(_prop);
  }

  /* Data methods */

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

  /* Getters */

  int GetBarsCalculated() {
    int _bars = Bars(GetSymbol(), GetTf());

    if (!idparams.Get<bool>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IS_FED))) {
      // Calculating start_bar.
      for (; calc_start_bar < _bars; ++calc_start_bar) {
        // Iterating from the oldest or previously iterated.
        IndicatorDataEntry _entry = GetEntry(_bars - calc_start_bar - 1);

        if (_entry.IsValid()) {
          // From this point we assume that future entries will be all valid.
          idparams.Set(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IS_FED), true);
          return _bars - calc_start_bar;
        }
      }
    }

    if (!idparams.Get<bool>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IS_FED))) {
      Print("Can't find valid bars for ", GetFullName());
      return 0;
    }

    // Assuming all entries are calculated (even if have invalid values).
    return _bars;
  }

  /**
   * Returns buffers' cache.
   */
  IndicatorCalculateCache<double>* GetCache() { return &cache; }

  /**
   * Get pointer to data of indicator.
   */
  BufferStruct<IndicatorDataEntry>* GetData() { return GetPointer(idata); }

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
              GetSymbol(), ", and timeframe ", GetTf(), "!");
        DebugBreak();
      } else {
        indicators.Set((int)_type, _indi);
        _result = _indi.Ptr();
      }
    }
    return _result;
  }

  // int GetDataSourceMode() { return indi_src_mode; }

  /**
   * Returns currently selected data source without any validation.
   */
  IndicatorBase* GetDataSourceRaw() { return indi_src.Ptr(); }

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
   * Provides built-in indicators whose can be used as data source.
   */
  virtual IndicatorBase* FetchDataSource(ENUM_INDICATOR_TYPE _id) { return NULL; }

  /* Checkers */

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
   * Sets data source's input mode.
   */
  // void SetDataSourceMode(int _mode) { indi_src_mode = _mode; }

  /* Storage methods */

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

  /* Tick methods */

  void Tick() {
    long _current_time = TimeCurrent();

    if (last_tick_time == _current_time) {
      // We've already ticked.
      return;
    }

    last_tick_time = _current_time;

    // Checking and potentially initializing new data source.
    if (HasDataSource(true) != NULL) {
      // Ticking data source if not yet ticked.
      GetDataSource().Tick();
    }

    // Also ticking all used indicators if they've not yet ticked.
    for (DictStructIterator<int, Ref<IndicatorData>> iter = indicators.Begin(); iter.IsValid(); ++iter) {
      iter.Value().Ptr().Tick();
    }

    // Overridable OnTick() method.
    OnTick();
  }

  /* Validate methods */

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

    if (!_target.IsDataSourceModeSelectable()) {
      // We don't validate source mode as it will use all modes.
      return;
    }

    if (_source.GetModeCount() > 1 && _target.idparams.Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DATA_SRC_MODE)) == -1) {
      // Mode must be selected if source indicator has more that one mode.
      Alert("Warning! ", GetName(),
            " must select source indicator's mode via SetDataSourceMode(int). Defaulting to mode 0.");
      _target.idparams.Set(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DATA_SRC_MODE), 0);
      DebugBreak();
    } else if (_source.GetModeCount() == 1 && _target.idparams.Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DATA_SRC_MODE)) == -1) {
      _target.idparams.Set(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DATA_SRC_MODE), 0);
    } else if (_target.idparams.Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DATA_SRC_MODE)) < 0 || _target.idparams.Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_DATA_SRC_MODE)) > _source.GetModeCount()) {
      Alert("Error! ", _target.GetName(),
            " must select valid source indicator's mode via SetDataSourceMode(int) between 0 and ",
            _source.GetModeCount(), ".");
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

  /* Printers */

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

  template <typename T>
  T GetValue(int _mode = 0, int _index = 0) {
    T _out;
    GetEntryValue(_mode, _index).Get(_out);
    return _out;
  }

  /* Virtual methods */

  /**
   * Returns currently selected data source doing validation.
   */
  virtual IndicatorData* GetDataSource() { return NULL; }

  /**
   * Returns the indicator's struct value.
   */
  virtual IndicatorDataEntry GetEntry(datetime _dt) {
    Print(GetFullName(),
          " must implement IndicatorDataEntry IndicatorBase::GetEntry(datetime _dt) in order to use GetEntry(datetime "
          "_dt) or _indi[datetime] subscript operator!");
    DebugBreak();
    IndicatorDataEntry _default;
    return _default;
  }

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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) = NULL;

  /**
   * Gets indicator's signals.
   *
   * When indicator values are not valid, returns empty signals.
   */
  virtual IndicatorSignal GetSignals(int _count = 3, int _shift = 0, int _mode1 = 0, int _mode2 = 0) = NULL;

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
   * Called when indicator became a data source for other indicator.
   */
  virtual void OnBecomeDataSourceFor(IndicatorData* _base_indi){};

  /**
   * Called when data source emits new entry (historic or future one).
   */
  virtual void OnDataSourceEntry(IndicatorDataEntry& entry){};

  virtual void OnTick() {}

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
   * Sets indicator data source.
   */
  virtual void SetDataSource(IndicatorData* _indi, int _input_mode = -1) = NULL;

  /**
   * Update indicator.
   */
  virtual bool Update() {
    // @todo
    return false;
  };

  /**
   * Loads and validates built-in indicators whose can be used as data source.
   */
  // virtual void ValidateDataSource(IndicatorData* _target, IndicatorData* _source) {}

  /**
   * Checks whether indicator have given mode index.
   *
   * If given mode is -1 (default one) and indicator has exactly one mode, then mode index will be replaced by 0.
   */
  virtual void ValidateDataSourceMode(int& _out_mode) {}
};

/**
 * BarsCalculated()-compatible method to be used on Indicator instance.
 */
int BarsCalculated(IndicatorData* _indi) { return _indi.GetBarsCalculated(); }

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

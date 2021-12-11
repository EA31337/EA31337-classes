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
#ifndef INDICATOR_CANDLE_H
#define INDICATOR_CANDLE_H

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Buffer/BufferCandle.h"
#include "../IndicatorBase.h"

/**
 * Class to deal with candle indicators.
 */
template <typename TS, typename TV>
class IndicatorCandle : public IndicatorBase {
 protected:
  BufferCandle<TV> icdata;
  TS icparams;

 protected:
  /* Protected methods */

  /**
   * Initialize class.
   *
   * Called on constructor.
   */
  void Init() {
    icdata.AddFlags(DICT_FLAG_FILL_HOLES_UNSORTED);
    icdata.SetOverflowListener(IndicatorCandleOverflowListener, 10);
    icparams.SetMaxModes(4);
  }

 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  IndicatorCandle(const TS& _icparams, IndicatorBase* _indi_src = NULL, int _indi_mode = 0) {
    icparams = _icparams;
    if (_indi_src != NULL) {
      SetDataSource(_indi_src, _indi_mode);
    }
    Init();
  }
  IndicatorCandle(ENUM_INDICATOR_TYPE _itype = INDI_CANDLE, int _shift = 0, string _name = "") {
    icparams.SetIndicatorType(_itype);
    icparams.SetShift(_shift);
    Init();
  }

  /* Virtual method implementations */

  /**
   * Returns the indicator's data entry.
   *
   * @see: IndicatorDataEntry.
   *
   * @return
   *   Returns IndicatorDataEntry struct filled with indicator values.
   */
  IndicatorDataEntry GetEntry(int _index) override {
    ResetLastError();
    unsigned int _ishift = _index >= 0 ? _index : icparams.GetShift();
    long _candle_time = CalcCandleTimestamp(GetBarTime(_ishift));
    CandleOCTOHLC<TV> _candle = icdata.GetByKey(_candle_time);

    if (!_candle.IsValid()) {
#ifdef __debug__
      Print(GetFullName(), ": Missing candle at shift ", _index, " (", TimeToString(_candle_time), ")");
#endif
    } else {
#ifdef __debug__verbose_
      Print(GetFullName(), ": Retrieving candle at shift ", _index, " (", TimeToString(_candle_time), ")");
#endif
    }

    return CandleToEntry(_candle_time, _candle);
  }

  /**
   * Alters indicator's struct value.
   *
   * This method allows user to modify the struct entry before it's added to cache.
   * This method is called on GetEntry() right after values are set.
   */
  virtual void GetEntryAlter(IndicatorDataEntry& _entry, int _timestamp = -1) {
    _entry.AddFlags(_entry.GetDataTypeFlags(icparams.GetDataValueType()));
  };

  /**
   * Returns the indicator's entry value for the given shift and mode.
   *
   * @see: DataParamEntry.
   *
   * @return
   *   Returns DataParamEntry struct filled with a single value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) {
    int _ishift = _shift >= 0 ? _shift : icparams.GetShift();
    return GetEntry(_ishift)[_mode];
  }

  /**
   * Function should return true if resize can be made, or false to overwrite current slot.
   */
  static bool IndicatorCandleOverflowListener(ENUM_DICT_OVERFLOW_REASON _reason, int _size, int _num_conflicts) {
    switch (_reason) {
      case DICT_OVERFLOW_REASON_FULL:
        // We allow resize if dictionary size is less than 86400 slots.
        return _size < 86400;
      case DICT_OVERFLOW_REASON_TOO_MANY_CONFLICTS:
      default:
        // When there is too many conflicts, we just reject doing resize, so first conflicting slot will be reused.
        break;
    }
    return false;
  }

  /**
   * Sends historic entries to listening indicators. May be overriden.
   */
  void EmitHistory() override {
    for (DictStructIterator<long, CandleOCTOHLC<TV>> iter(icdata.Begin()); iter.IsValid(); ++iter) {
      IndicatorDataEntry _entry = CandleToEntry(iter.Key(), iter.Value());
      EmitEntry(_entry);
    }
  }

  /**
   * Converts candle into indicator's data entry.
   */
  IndicatorDataEntry CandleToEntry(long _timestamp, CandleOCTOHLC<TV>& _candle) {
    IndicatorDataEntry _entry(4);
    _entry.timestamp = _timestamp;
    _entry.values[0] = _candle.open;
    _entry.values[1] = _candle.high;
    _entry.values[2] = _candle.low;
    _entry.values[3] = _candle.close;
    _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _candle.IsValid());
    return _entry;
  }

  /**
   * Adds tick's price to the matching candle and updates its OHLC values.
   */
  void UpdateCandle(long _tick_timestamp, double _price) {
    long _candle_timestamp = CalcCandleTimestamp(_tick_timestamp);

#ifdef __debug_verbose__
    Print("Updating candle for ", GetFullName(), " at candle ", TimeToString(_candle_timestamp), " from tick at ",
          TimeToString(_tick_timestamp));
#endif

    CandleOCTOHLC<double> _candle(_price, _price, _price, _price, _tick_timestamp, _tick_timestamp);
    if (icdata.KeyExists(_candle_timestamp)) {
      // Candle already exists.
      _candle = icdata.GetByKey(_candle_timestamp);
      _candle.Update(_tick_timestamp, _price);
    }

    icdata.Set(_candle_timestamp, _candle);
  }

  /**
   * Calculates candle's timestamp from tick's timestamp.
   */
  long CalcCandleTimestamp(long _tick_timestamp) {
    return _tick_timestamp - _tick_timestamp % (icparams.GetSecsPerCandle());
  }

  /**
   * Called when data source emits new entry (historic or future one).
   */
  virtual void OnDataSourceEntry(IndicatorDataEntry& entry) {
    // Updating candle from bid price.
    UpdateCandle(entry.timestamp, entry[1]);
  };

  /**
   * Sets indicator data source.
   */
  void SetDataSource(IndicatorBase* _indi, int _input_mode = 0) {
    if (indi_src.IsSet() && indi_src.Ptr() != _indi) {
      indi_src.Ptr().RemoveListener(THIS_PTR);
    }
    indi_src = _indi;
    if (_indi != NULL) {
      indi_src.Ptr().AddListener(THIS_PTR);
      icparams.SetDataSource(-1, _input_mode);
      indi_src.Ptr().OnBecomeDataSourceFor(THIS_PTR);
    }
  }

  string CandlesToString() {
    string _result;
    for (DictStructIterator<long, CandleOCTOHLC<TV>> iter(icdata.Begin()); iter.IsValid(); ++iter) {
      IndicatorDataEntry _entry = CandleToEntry(iter.Key(), iter.Value());
      _result += IntegerToString(iter.Key()) + ": " + _entry.ToString<double>() + "\n";
    }
    return _result;
  }

  /* Virtual methods */

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
   * Get full name of the indicator (with "over ..." part).
   */
  string GetFullName() override {
    return GetName() + "[" + IntegerToString(icparams.GetMaxModes()) + "]" +
           (HasDataSource() ? (" (over " + GetDataSource().GetFullName() + ")") : "");
  }

  /**
   * Whether data source is selected.
   */
  bool HasDataSource() override { return GetDataSourceRaw() != NULL || icparams.GetDataSourceId() != -1; }

  /**
   * Returns currently selected data source doing validation.
   */
  IndicatorBase* GetDataSource() override {
    IndicatorBase* _result = NULL;

    if (GetDataSourceRaw() != NULL) {
      _result = GetDataSourceRaw();
    } else if (icparams.GetDataSourceId() != -1) {
      int _source_id = icparams.GetDataSourceId();

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
   * Get indicator type.
   */
  ENUM_INDICATOR_TYPE GetType() override { return icparams.itype; }
};

#endif

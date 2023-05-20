//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
#ifndef INDICATOR_TICK_H
#define INDICATOR_TICK_H

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Buffer/BufferTick.h"
#include "../Indicator.mqh"

// Indicator modes.
enum ENUM_INDI_TICK_MODE {
  INDI_TICK_MODE_PRICE_ASK,
  INDI_TICK_MODE_PRICE_BID,
  FINAL_INDI_TICK_MODE_ENTRY,
};

/**
 * Class to deal with tick indicators.
 */
template <typename TS, typename TV>
class IndicatorTick : public Indicator<TS> {
 protected:
  BufferTick<TV> itdata;
  TS itparams;

 protected:
  /* Protected methods */

  /**
   * Initialize class.
   *
   * Called on constructor.
   */
  void Init() {
    // We can't index by shift.
    flags &= ~INDI_FLAG_INDEXABLE_BY_SHIFT;
    // We can only index via timestamp.
    flags |= INDI_FLAG_INDEXABLE_BY_TIMESTAMP;

    itdata.AddFlags(DICT_FLAG_FILL_HOLES_UNSORTED);
    itdata.SetOverflowListener(IndicatorTickOverflowListener, 10);
    // Ask and Bid price.
    Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES), 2);
  }

 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  IndicatorTick(const TS& _itparams, const IndicatorDataParams& _idparams, IndicatorBase* _indi_src = NULL,
                int _indi_mode = 0)
      : Indicator(_itparams, _idparams, _indi_src, _indi_mode) {
    itparams = _itparams;
    if (_indi_src != NULL) {
      SetDataSource(_indi_src, _indi_mode);
    }
    Init();
  }
  IndicatorTick(ENUM_INDICATOR_TYPE _itype = INDI_CANDLE, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                string _name = "")
      : Indicator(_itype, _tf, _shift, _name) {
    Init();
  }

  /**
   * Returns value storage of given kind.
   */
  IValueStorage* GetSpecificValueStorage(ENUM_INDI_VS_TYPE _type) override {
    switch (_type) {
      case INDI_VS_TYPE_PRICE_ASK:
        return (IValueStorage*)itdata.GetAskValueStorage();
      case INDI_VS_TYPE_PRICE_BID:
        return (IValueStorage*)itdata.GetBidValueStorage();
      default:
        // Trying in parent class.
        return Indicator<TS>::GetSpecificValueStorage(_type);
    }
  }

  /**
   * Checks whether indicator support given value storage type.
   */
  virtual bool HasSpecificValueStorage(ENUM_INDI_VS_TYPE _type) {
    switch (_type) {
      case INDI_VS_TYPE_PRICE_ASK:
      case INDI_VS_TYPE_PRICE_BID:
        return true;
    }

    return Indicator<TS>::HasSpecificValueStorage(_type);
  }

  /**
   * Sends historic entries to listening indicators. May be overriden.
   */
  void EmitHistory() override {
    for (DictStructIterator<long, TickAB<TV>> iter(itdata.Begin()); iter.IsValid(); ++iter) {
      IndicatorDataEntry _entry = TickToEntry(iter.Key(), iter.Value());
      EmitEntry(_entry);
    }
  }

  /**
   * @todo
   */
  IndicatorDataEntry TickToEntry(long _timestamp, TickAB<TV>& _tick) {
    IndicatorDataEntry _entry(2);
    _entry.timestamp = _timestamp;
    _entry.values[0] = _tick.ask;
    _entry.values[1] = _tick.bid;
    _entry.SetFlags(INDI_ENTRY_FLAG_IS_VALID);
    return _entry;
  }

  /**
   * Returns the indicator's data entry.
   *
   * @see: IndicatorDataEntry.
   *
   * @return
   *   Returns IndicatorDataEntry struct filled with indicator values.
   */
  IndicatorDataEntry GetEntry(int _timestamp = 0) override {
    ResetLastError();
    if (itdata.KeyExists(_timestamp)) {
      TickAB<TV> _tick = itdata.GetByKey(_timestamp);
      return TickToEntry(_timestamp, _tick);
    }
    int _max_modes = Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES));

    // No tick at given timestamp. Returning invalid entry.
    IndicatorDataEntry _entry(_max_modes);
    GetEntryAlter(_entry, _timestamp);

    for (int i = 0; i < _max_modes; ++i) {
      _entry.values[i] = (double)0;
    }

    _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, false);
    return _entry;
  }

  /**
   * Alters indicator's struct value.
   *
   * This method allows user to modify the struct entry before it's added to cache.
   * This method is called on GetEntry() right after values are set.
   */
  virtual void GetEntryAlter(IndicatorDataEntry& _entry, int _timestamp = -1) {
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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) {
    int _ishift = _shift >= 0 ? _shift : itparams.GetShift();
    return GetEntry(_ishift)[_mode];
  }

  /* Setters */

  /**
   * Sets a tick struct with price values.
   *
   * @see: MqlTick.
   */
  void SetTick(MqlTick& _mql_tick, long _timestamp = 0) {
    TickAB<TV> _tick(_mql_tick);
    itdata.Add(_tick, _timestamp);
  }

  /**
   * Sets indicator data source.
   */
  void SetDataSource(IndicatorBase* _indi, int _input_mode = -1) {
    indi_src = _indi;
    Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_SRC_ID), -1);
    Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_SRC_MODE), _input_mode);
  }

  /* Virtual methods */

  /**
   * Returns a tick struct with price values.
   *
   * @see: MqlTick.
   *
   * @return
   *   Returns MqlTick struct with prices of the symbol.
   */
  virtual MqlTick GetTick(int _timestamp = 0) {
    IndicatorDataEntry _entry = GetEntry(_timestamp);
    MqlTick _tick;
    _tick.time = (datetime)_entry.GetTime();
    _tick.bid = _entry[0];
    _tick.ask = _entry[1];
    return _tick;
  }

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
          _result &= !_entry.HasValue<unsigned long>(ULONG_MAX);
          _result &= !_entry.HasValue<unsigned long>(NULL);
        } else {
          _result &= !_entry.HasValue<unsigned int>(UINT_MAX);
          _result &= !_entry.HasValue<unsigned int>(NULL);
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

  /* Callback methods */

  /**
   * Function should return true if resize can be made, or false to overwrite current slot.
   */
  static bool IndicatorTickOverflowListener(ENUM_DICT_OVERFLOW_REASON _reason, int _size, int _num_conflicts) {
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
};

#endif

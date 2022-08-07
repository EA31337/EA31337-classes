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
#ifndef INDICATOR_TICK_H
#define INDICATOR_TICK_H

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Buffer/BufferTick.h"
#include "Indicator.h"
#include "Indicator.struct.h"

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
  string symbol;
  SymbolInfoProp symbol_props;

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
  IndicatorTick(string _symbol, const TS& _itparams, const IndicatorDataParams& _idparams,
                IndicatorBase* _indi_src = NULL, int _indi_mode = 0)
      : Indicator(_itparams, _idparams, _indi_src, _indi_mode) {
    itparams = _itparams;
    if (_indi_src != NULL) {
      SetDataSource(_indi_src, _indi_mode);
    }
    symbol = _symbol;
    Init();
  }
  IndicatorTick(string _symbol, ENUM_INDICATOR_TYPE _itype = INDI_CANDLE, int _shift = 0, string _name = "")
      : Indicator(_itype, _shift, _name) {
    symbol = _symbol;
    Init();
  }

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

  /**
   * Returns time of the bar for a given shift.
   */
  datetime GetBarTime(int _shift = 0) override {
    if (_shift != 0) {
      Print("Error: IndicatorTick::GetBarTime() does not yet support getting entries by shift other than 0!");
      DebugBreak();
    }

    return (datetime)itdata.GetMax();
  }

  /**
   * Gets ask price for a given date and time. Return current ask price if _dt wasn't passed or is 0.
   */
  virtual double GetAsk(datetime _dt = 0) { return GetEntry(_dt).GetValue<double>(INDI_TICK_MODE_PRICE_ASK); }

  /**
   * Gets bid price for a given date and time. Return current bid price if _dt wasn't passed or is 0.
   */
  virtual double GetBid(datetime _dt = 0) { return GetEntry(_dt).GetValue<double>(INDI_TICK_MODE_PRICE_BID); }

  /**
   * Returns value storage of given kind.
   */
  IValueStorage* GetSpecificValueStorage(ENUM_INDI_VS_TYPE _type) override {
    switch (_type) {
      case INDI_VS_TYPE_PRICE_ASK:
        return (IValueStorage*)itdata.GetAskValueStorage();
      case INDI_VS_TYPE_PRICE_BID:
        return (IValueStorage*)itdata.GetBidValueStorage();
      case INDI_VS_TYPE_SPREAD:
        return (IValueStorage*)itdata.GetSpreadValueStorage();
      case INDI_VS_TYPE_VOLUME:
        return (IValueStorage*)itdata.GetVolumeValueStorage();
      case INDI_VS_TYPE_TICK_VOLUME:
        return (IValueStorage*)itdata.GetTickVolumeValueStorage();
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
      case INDI_VS_TYPE_SPREAD:
      case INDI_VS_TYPE_VOLUME:
      case INDI_VS_TYPE_TICK_VOLUME:
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
   * Stores entry in the buffer for later rerieval.
   */
  void StoreEntry(IndicatorDataEntry& _entry) override { itdata.Add(EntryToTick(_entry), _entry.timestamp); }

  /**
   * @todo
   */
  IndicatorDataEntry TickToEntry(long _timestamp, TickAB<TV>& _tick) {
    IndicatorDataEntry _entry(2);
    _entry.timestamp = _timestamp;
    _entry.values[INDI_TICK_MODE_PRICE_ASK] = _tick.ask;
    _entry.values[INDI_TICK_MODE_PRICE_BID] = _tick.bid;
    _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _tick.ask != 0 && _tick.bid != 0);
    return _entry;
  }

  /**
   * @todo
   */
  TickAB<TV> EntryToTick(IndicatorDataEntry& _entry) {
    TickAB<TV> _tick;
    _tick.ask = _entry.GetValue<TV>(INDI_TICK_MODE_PRICE_ASK);
    _tick.bid = _entry.GetValue<TV>(INDI_TICK_MODE_PRICE_BID);
    return _tick;
  }

  /**
   * Returns the indicator's data entry.
   *
   * @see: IndicatorDataEntry.
   *
   * @return
   *   Returns IndicatorDataEntry struct filled with indicator values.
   */
  IndicatorDataEntry GetEntry(long _dt = 0) override {
    ResetLastError();
    long _timestamp;

    if ((long)_dt != 0) {
      _timestamp = (long)_dt;
    } else {
      _timestamp = itdata.GetMax();
    }

    if (itdata.KeyExists(_timestamp)) {
      TickAB<TV> _tick = itdata.GetByKey(_timestamp);
      return TickToEntry(_timestamp, _tick);
    }
    int _max_modes = Get<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES));

    // No tick at given timestamp. Returning invalid entry.
    IndicatorDataEntry _entry(_max_modes);
    GetEntryAlter(_entry, (datetime)_entry.timestamp);

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
  virtual void GetEntryAlter(IndicatorDataEntry& _entry, datetime _time) {
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
    if (_shift != 0) {
      Print("Error: IndicatorTick does not yet support getting entries by shift other than 0!");
      DebugBreak();
      IndicatorDataEntryValue _default;
      return _default;
    }

    int _ishift = _shift >= 0 ? _shift : itparams.GetShift();
    // @todo Support for shift.
    return GetEntry((datetime)0)[_mode];
  }

  /**
   * Gets symbol of the tick.
   */
  string GetSymbol() override { return symbol; }

  /**
   * Gets symbol info for active symbol.
   */
  SymbolInfoProp GetSymbolProps() override {
    if (!symbol_props.initialized) {
      Print(
          "Error: Tried to fetch symbol properties, but they're not yet initialized! Please call "
          "SetSymbolProps(SymbolInfoProp) before trying to use symbol-related information.");
      DebugBreak();
    }
    return symbol_props;
  }

  /**
   * Sets symbol info for symbol attached to the indicator.
   */
  void SetSymbolProps(const SymbolInfoProp& _props) override {
    symbol_props = _props;
    symbol_props.initialized = true;
  }

  /**
   * Traverses source indicators' hierarchy and tries to find IndicatorTick object at the end.
   */
  virtual IndicatorTick* GetTickIndicator() { return THIS_PTR; }

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
    IndicatorDataEntry _entry = GetEntry((datetime)_timestamp);
    MqlTick _tick;
    _tick.time = (datetime)_entry.GetTime();
    _tick.bid = _entry[0];
    _tick.ask = _entry[1];
    return _tick;
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

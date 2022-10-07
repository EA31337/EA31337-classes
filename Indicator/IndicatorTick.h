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
#include "IndicatorTick.provider.h"
#include "TickBarCounter.h"

// Indicator modes.
enum ENUM_INDI_TICK_MODE {
  INDI_TICK_MODE_PRICE_ASK,
  INDI_TICK_MODE_PRICE_BID,
  FINAL_INDI_TICK_MODE_ENTRY,
};

/**
 * Class to deal with tick indicators.
 */
template <typename TS, typename TV, typename TCP>
class IndicatorTick : public Indicator<TS> {
 protected:
  ItemsHistory<TickTAB<TV>, TCP> history;
  TS itparams;
  string symbol;
  SymbolInfoProp symbol_props;
  TickBarCounter counter;

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

    // Ask and Bid price.
    Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES), 2);

    history.SetItemProvider(new ItemsHistoryTickProvider<double>(THIS_PTR));
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
  datetime GetBarTime(int _shift = 0) override { return history.GetItemTimeByShift(_shift); }

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
    Print("IndicatorTick::GetSpecificValueStorage() is no longer available!");
    /*
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
    */
    return nullptr;
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
   * Appends given entry into the history.
   */
  virtual void AppendEntry(IndicatorDataEntry& entry) override {
    // Appending tick into the history.
    history.GetItemProvider() PTR_DEREF OnTick(&history, entry.timestamp * 1000, (float)entry[0], (float)entry[1]);
  };

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
};

#endif

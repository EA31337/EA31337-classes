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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Storage/Dict/Buffer/BufferTick.h"
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
    THIS_ATTR flags &= ~INDI_FLAG_INDEXABLE_BY_SHIFT;
    // We can only index via timestamp.
    THIS_ATTR flags |= INDI_FLAG_INDEXABLE_BY_TIMESTAMP;

    // Ask and Bid price.
    THIS_ATTR Set(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES), (int)2);

    history.SetItemProvider(new ItemsHistoryTickProvider<double>(THIS_PTR));
  }

 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  IndicatorTick(string _symbol, const TS& _itparams, const IndicatorDataParams& _idparams,
                IndicatorData* _indi_src = NULL, int _indi_mode = 0)
      : Indicator<TS>(_itparams, _idparams, _indi_src, _indi_mode) {
    itparams = _itparams;
    if (_indi_src != NULL) {
      THIS_ATTR SetDataSource(_indi_src, _indi_mode);
    }
    symbol = _symbol;
    Init();
  }
  IndicatorTick(string _symbol, ENUM_INDICATOR_TYPE _itype = INDI_CANDLE, int _shift = 0, string _name = "")
      : Indicator<TS>(_itype, _shift, _name) {
    symbol = _symbol;
    Init();
  }

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN; }

  /**
   * Returns time of the bar for a given shift.
   */
  datetime GetBarTime(int _rel_shift = 0) override { return history.GetItemTimeByShift(_rel_shift); }

  /**
   * Gets ask price for a given date and time. Return current ask price if _dt wasn't passed or is 0.
   */
  double GetAsk(int _shift = 0) override {
    IndicatorDataEntryValue _entry = GetEntryValue(INDI_TICK_MODE_PRICE_ASK, _shift);
    return _entry.Get<double>();
  }

  /**
   * Gets bid price for a given date and time. Return current bid price if _dt wasn't passed or is 0.
   */
  double GetBid(int _shift = 0) override {
    IndicatorDataEntryValue _entry = GetEntryValue(INDI_TICK_MODE_PRICE_BID, _shift);
    return _entry.Get<double>();
  }

  /**
   * Returns value storage of given kind.
   */
  IValueStorage* GetSpecificValueStorage(ENUM_INDI_DATA_VS_TYPE _type) override {
    Print("IndicatorTick::GetSpecificValueStorage() is no longer available!");
    /*
    switch (_type) {
      case INDI_DATA_VS_TYPE_PRICE_ASK:
        return (IValueStorage*)itdata.GetAskValueStorage();
      case INDI_DATA_VS_TYPE_PRICE_BID:
        return (IValueStorage*)itdata.GetBidValueStorage();
      case INDI_DATA_VS_TYPE_SPREAD:
        return (IValueStorage*)itdata.GetSpreadValueStorage();
      case INDI_DATA_VS_TYPE_VOLUME:
        return (IValueStorage*)itdata.GetVolumeValueStorage();
      case INDI_DATA_VS_TYPE_TICK_VOLUME:
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
  bool HasSpecificValueStorage(ENUM_INDI_DATA_VS_TYPE _type) override {
    switch (_type) {
      case INDI_DATA_VS_TYPE_PRICE_ASK:
      case INDI_DATA_VS_TYPE_PRICE_BID:
      case INDI_DATA_VS_TYPE_SPREAD:
      case INDI_DATA_VS_TYPE_VOLUME:
      case INDI_DATA_VS_TYPE_TICK_VOLUME:
        return true;
      default:
        break;
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
   * Returns points to ticks history.
   */
  ItemsHistory<TickTAB<TV>, TCP>* GetHistory() { return &history; }

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
  IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _abs_shift = 0) override {
    TickTAB<TV> _tick;

    if (history.TryGetItemByShift(_abs_shift, _tick)) {
      switch (_mode) {
        case INDI_TICK_MODE_PRICE_ASK:
          return _tick.ask;
        case INDI_TICK_MODE_PRICE_BID:
          return _tick.bid;
        default:
          Print("Invalid mode while trying to get entry from IndicatorTick!");
          DebugBreak();
      }
    }

    return DBL_MAX;
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

/**
 * Converts TickAB into IndicatorDataEntry.
 */
template <typename TV>
IndicatorDataEntry TickToEntry(int64 _timestamp, TickAB<TV>& _tick) {
  IndicatorDataEntry _entry(2);
  _entry.timestamp = _timestamp;
  _entry.values[INDI_TICK_MODE_PRICE_ASK] = _tick.ask;
  _entry.values[INDI_TICK_MODE_PRICE_BID] = _tick.bid;
  _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _tick.ask != 0 && _tick.bid != 0);
  return _entry;
}

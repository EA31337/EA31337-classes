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

// Includes.
#include "Deal.enum.h"
#include "Order.struct.h"
#include "Platform.define.h"

/**
 * Extern declarations for C++.
 */

/**
 * Returns number of candles for a given symbol and time-frame.
 */
extern int Bars(CONST_REF_TO_SIMPLE(string) _symbol, ENUM_TIMEFRAMES _tf);

#endif

// Includes.

/**
 * Current platform's static methods.
 */

#include "../Indicator/IndicatorData.h"
#include "../Indicator/tests/classes/IndicatorTfDummy.h"
#include "../Indicators/DrawIndicator.mqh"
#include "../Std.h"
#include "../Storage/Flags.struct.h"

#ifdef __MQLBUILD__
#include "../Indicators/Tick/Indi_TickMt.h"
#define PLATFORM_DEFAULT_INDICATOR_TICK Indi_TickMt
#else
#include "../Indicators/Tick/Indi_TickProvider.h"
#define PLATFORM_DEFAULT_INDICATOR_TICK Indi_TickProvider
#endif
#include "../Exchange/SymbolInfo/SymbolInfo.struct.static.h"

class Platform {
  // Whether Init() was already called.
  static bool initialized;

  // Global tick index.
  static int global_tick_index;

  // Date and time used to determine periods that passed.
  static DateTime time;

  // Merged flags from previous Platform::UpdateTime();
  static unsigned int time_flags;

  // Whether to clear passed periods on consecutive Platform::UpdateTime().
  static bool time_clear_flags;

  // List of added indicators.
  static DictStruct<int64, Ref<IndicatorData>> indis;

  // List of default Candle/Tick indicators.
  static DictStruct<int64, Ref<IndicatorData>> indis_dflt;

  // Result of the last tick.
  static bool last_tick_result;

  // Symbol of the currently ticking indicator.
  static string symbol;

  // Timeframe of the currently ticking indicator.
  static ENUM_TIMEFRAMES period;

 public:
  /**
   * Initializes platform.
   */
  static void Init() {
    if (initialized) {
      // Already initialized.
      return;
    }

    initialized = true;
  }

  /**
   * Returns global tick index.
   */
  static int GetGlobalTickIndex() { return global_tick_index; }

  /**
   * Performs tick on every added indicator.
   */
  static void Tick() {
    // @todo Should update time for each ticking indicator and only when it signal a tick.
    PlatformTime::Tick();
    time.Update();

    // Checking starting periods and updating time to current one.
    time_flags = time.GetStartedPeriods();

    DictStructIterator<int64, Ref<IndicatorData>> _iter;

    last_tick_result = false;

    for (_iter = indis.Begin(); _iter.IsValid(); ++_iter) {
      // Print("Ticking ", _iter.Value() REF_DEREF GetFullName());
      //  Updating current symbol and timeframe to the ones used by ticking indicator and its parents.
      symbol = _iter.Value() REF_DEREF GetSymbol();
      period = _iter.Value() REF_DEREF GetTf();

#ifdef __debug__
      PrintFormat("Tick #%d for %s for symbol %s and period %s", global_tick_index,
                  C_STR(_iter.Value() REF_DEREF GetFullName()), C_STR(symbol), C_STR(ChartTf::TfToString(period)));
#endif

      last_tick_result |= _iter.Value() REF_DEREF Tick(global_tick_index);
    }

    for (_iter = indis_dflt.Begin(); _iter.IsValid(); ++_iter) {
      // Updating current symbol and timeframe to the ones used by ticking indicator and its parents.
      symbol = (_iter.Value() REF_DEREF GetTick(false) != nullptr) ? _iter.Value() REF_DEREF GetSymbol()
                                                                   : PLATFORM_WRONG_SYMBOL;
      period = (_iter.Value() REF_DEREF GetCandle(false) != nullptr) ? _iter.Value() REF_DEREF GetTf()
                                                                     : PLATFORM_WRONG_TIMEFRAME;

#ifdef __debug__
      PrintFormat("Tick #%d for %s for symbol %s and period %s", global_tick_index,
                  C_STR(_iter.Value() REF_DEREF GetFullName()), C_STR(symbol), C_STR(ChartTf::TfToString(period)));
#endif

      last_tick_result |= _iter.Value() REF_DEREF Tick(global_tick_index);
    }

    // Clearing symbol and period in order to signal retrieving symbol/period outside the ticking indicator.
    symbol = PLATFORM_WRONG_SYMBOL;
    period = PLATFORM_WRONG_TIMEFRAME;

    // Will check for new time periods in consecutive Platform::UpdateTime().
    time_clear_flags = true;

    // Started from 0. Will be incremented after each finished tick.
    ++global_tick_index;
  }

  /**
   * Checks whether we had a tick inside previous Tick() invocation.
   */
  static bool HadTick() { return last_tick_result; }

  /**
   * Returns dictionary of added indicators (keyed by unique id).
   */
  static DictStruct<int64, Ref<IndicatorData>> *GetIndicators() { return &indis; }

  /**
   * Adds indicator to be processed by platform.
   */
  static void Add(IndicatorData *_indi) {
    Ref<IndicatorData> _ref = _indi;

    DictStructIterator<int64, Ref<IndicatorData>> _iter;
    for (_iter = indis_dflt.Begin(); _iter.IsValid(); ++_iter) {
      if (_iter.Value() == _ref) {
        Alert("Warning: ", _indi PTR_DEREF GetFullName(),
              " was already added as default candle/tick indicator and shouldn't be added by Platform:Add() as default "
              "indicators are also ticked when calling Platform::Tick().");
        DebugBreak();
      }
    }

    indis.Set(_indi PTR_DEREF GetId(), _ref);
  }

  /**
   * Adds indicator to be processed by platform and tries to initialize its data source(s).
   */
  static void AddWithDefaultBindings(IndicatorData *_indi, string _symbol, ENUM_TIMEFRAMES _tf) {
    Add(_indi);
    BindDefaultDataSource(_indi, _symbol, _tf);
  }

  /**
   * Removes indicator from being processed by platform.
   */
  static void Remove(IndicatorData *_indi) { indis.Unset(_indi PTR_DEREF GetId()); }

  /**
   * Returns date and time used to determine periods that passed.
   */
  static DateTime Time() { return time; }

  /**
   * Returns number of seconds passed from the Unix epoch.
   */
  static datetime Timestamp() { return TimeCurrent(); }

  /**
   * Checks whether it's a new second.
   */
  static bool IsNewSecond() { return (time_flags & DATETIME_SECOND) != 0; }

  /**
   * Checks whether it's a new minute.
   */
  static bool IsNewMinute() { return (time_flags & DATETIME_MINUTE) != 0; }

  /**
   * Checks whether it's a new hour.
   */
  static bool IsNewHour() { return (time_flags & DATETIME_HOUR) != 0; }

  /**
   * Checks whether it's a new day.
   */
  static bool IsNewDay() { return (time_flags & DATETIME_DAY) != 0; }

  /**
   * Checks whether it's a new week.
   */
  static bool IsNewWeek() { return (time_flags & DATETIME_WEEK) != 0; }

  /**
   * Checks whether it's a new month.
   */
  static bool IsNewMonth() { return (time_flags & DATETIME_MONTH) != 0; }

  /**
   * Checks whether it's a new year.
   */
  static bool IsNewYear() { return (time_flags & DATETIME_YEAR) != 0; }

  /**
   * Returns number of candles for a given symbol and time-frame.
   */
  static int Bars(CONST_REF_TO_SIMPLE(string) _symbol, ENUM_TIMEFRAMES _tf) {
    Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
    return 0;
  }

  /**
   * Returns the number of calculated data for the specified indicator.
   */
  static int BarsCalculated(int indicator_handle) {
    Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
    return 0;
  }

  /**
   * Returns id of the current chart.
   */
  static int ChartID() {
    Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
    return 0;
  }

  /**
   * Binds Candle and/or Tick indicator as a source of prices or data for given indicator.
   *
   * Note that some indicators may work on custom set of buffers required from data source and not on Candle or Tick
   * indicator.
   */
  static void BindDefaultDataSource(IndicatorData *_indi, CONST_REF_TO_SIMPLE(string) _symbol, ENUM_TIMEFRAMES _tf) {
    Flags<unsigned int> _suitable_ds_types = _indi PTR_DEREF GetSuitableDataSourceTypes();

    IndicatorData *_default_indi_candle = FetchDefaultCandleIndicator(_symbol, _tf);
    IndicatorData *_default_indi_tick = FetchDefaultTickIndicator(_symbol);

    if (_suitable_ds_types.HasFlag(INDI_SUITABLE_DS_TYPE_EXPECT_NONE)) {
      // There should be no data source, but we have to attach at least a Candle indicator in order to use GetBarTime()
      // and similar methods.
      _indi PTR_DEREF SetDataSource(_default_indi_candle);
    } else if (_suitable_ds_types.HasFlag(INDI_SUITABLE_DS_TYPE_CUSTOM)) {
      if (_indi PTR_DEREF OnCheckIfSuitableDataSource(_default_indi_candle))
        _indi PTR_DEREF SetDataSource(_default_indi_candle);
      else if (_indi PTR_DEREF OnCheckIfSuitableDataSource(_default_indi_tick)) {
        _indi PTR_DEREF SetDataSource(_default_indi_tick);
      } else {
        // We can't attach any default data source as we don't know what type of indicator to create.
        Print("ERROR: Cannot bind default data source for ", _indi PTR_DEREF GetFullName(),
              " as we don't know what type of indicator to create!");
        DebugBreak();
      }
    } else if (_suitable_ds_types.HasFlag(INDI_SUITABLE_DS_TYPE_AP)) {
      // Indicator requires OHLC-compatible data source, Candle indicator would fulfill such requirement.
      _indi PTR_DEREF SetDataSource(_default_indi_candle);
    } else if (_suitable_ds_types.HasFlag(INDI_SUITABLE_DS_TYPE_CANDLE) ||
               _suitable_ds_types.HasFlag(INDI_SUITABLE_DS_TYPE_EXPECT_ANY)) {
      _indi PTR_DEREF SetDataSource(_default_indi_candle);
    } else if (_suitable_ds_types.HasFlag(INDI_SUITABLE_DS_TYPE_TICK)) {
      _indi PTR_DEREF SetDataSource(_default_indi_tick);
    } else {
      Print(
          "Error: Could not bind platform's default data source as neither Candle nor Tick-based indicator are "
          "compatible with the target one.");
      DebugBreak();
    }
  }

  /**
   * Returns default Candle-compatible indicator for current platform for given symbol and TF.
   */
  static IndicatorData *FetchDefaultCandleIndicator(string _symbol, ENUM_TIMEFRAMES _tf) {
    if (_symbol == PLATFORM_WRONG_SYMBOL) {
      Print("Cannot fetch default candle indicator for unknown symbol \"", _symbol, "\" (passed TF value ", (int)_tf,
            ")!");
      DebugBreak();
    }

    if (_tf == PERIOD_CURRENT || _tf == PLATFORM_WRONG_TIMEFRAME) {
      Print("Cannot fetch default candle indicator for unknown period/timeframe (passed symbol \"", _symbol,
            "\", TF value ", (int)_tf, ")!");
      DebugBreak();
    }

    // Candle is per symbol and TF. Single Candle indicator can't handle multiple TFs.
    string _key = Util::MakeKey("PlatformIndicatorCandle", _symbol, (int)_tf);
    IndicatorData *_indi_candle;
    if (!Objects<IndicatorData>::TryGet(_key, _indi_candle)) {
      _indi_candle = Objects<IndicatorData>::Set(_key, new IndicatorTfDummy(_tf));

      // Adding indicator to list of default indicators in order to tick it on every Tick() call.
      Ref<IndicatorData> _ref = _indi_candle;
      indis_dflt.Set(_indi_candle PTR_DEREF GetId(), _ref);

      if (!_indi_candle PTR_DEREF HasDataSource()) {
        // Missing tick indicator.
        _indi_candle PTR_DEREF InjectDataSource(FetchDefaultTickIndicator(_symbol));
      }
#ifdef __debug__
      Print("Added default candle indicator for symbol ", _symbol, " and time-frame ", _tf, ". Now it has symbol ",
            _indi_candle PTR_DEREF GetSymbol(), " and time-frame ", EnumToString(_indi_candle PTR_DEREF GetTf()));
#endif
    }

    return _indi_candle;
  }

  /**
   * Returns default Tick-compatible indicator for current platform for given symbol.
   */
  static IndicatorData *FetchDefaultTickIndicator(string _symbol) {
    if (_symbol == PLATFORM_WRONG_SYMBOL) {
      Alert("Cannot fetch default tick indicator for unknown symbol!");
      DebugBreak();
    }

    string _key = Util::MakeKey("PlatformIndicatorTick", _symbol);
    IndicatorData *_indi_tick;
    if (!Objects<IndicatorData>::TryGet(_key, _indi_tick)) {
      _indi_tick = Objects<IndicatorData>::Set(_key, new PLATFORM_DEFAULT_INDICATOR_TICK(_symbol));
      _indi_tick PTR_DEREF SetSymbolProps(Platform::FetchDefaultSymbolProps(_symbol));

      // Adding indicator to list of default indicators in order to tick it on every Tick() call.
      Ref<IndicatorData> _ref = _indi_tick;
      indis_dflt.Set(_indi_tick PTR_DEREF GetId(), _ref);
    }
    return _indi_tick;
  }

  /**
   * Returns default properties for given symbol for current platform.
   */
  static SymbolInfoProp FetchDefaultSymbolProps(CONST_REF_TO_SIMPLE(string) _symbol) {
    SymbolInfoProp props;
#ifdef __MQLBUILD__
    props.pip_value = SymbolInfoStatic::GetPipValue(_symbol);
    props.digits = SymbolInfoStatic::GetDigits(_symbol);
    props.pip_digits = SymbolInfoStatic::GetPipDigits(_symbol);
    props.pts_per_pip = SymbolInfoStatic::GetPointsPerPip(_symbol);
    props.vol_digits = SymbolInfoStatic::GetVolumeDigits(_symbol);
    props.vol_min = SymbolInfoStatic::GetVolumeMin(_symbol);
    props.vol_max = SymbolInfoStatic::GetVolumeMax(_symbol);
    props.vol_step = SymbolInfoStatic::GetVolumeStep(_symbol);
    props.point_size = SymbolInfoStatic::GetPointSize(_symbol);
    props.tick_size = SymbolInfoStatic::GetTickSize(_symbol);
    props.tick_value = SymbolInfoStatic::GetTickValue(_symbol);
    props.swap_long = SymbolInfoStatic::GetSwapLong(_symbol);
    props.swap_short = SymbolInfoStatic::GetSwapShort(_symbol);
    props.margin_initial = SymbolInfoStatic::GetMarginInit(_symbol);
    props.margin_maintenance = SymbolInfoStatic::GetMarginMaintenance(_symbol);
    props.freeze_level = SymbolInfoStatic::GetFreezeLevel(_symbol);
#endif
    return props;
  }

  /**
   * Prints indicators' values at the given shift.
   */
  static string IndicatorsToString(int _shift = 0) {
    string _result;
    for (DictStructIterator<int64, Ref<IndicatorData>> _iter = indis.Begin(); _iter.IsValid(); ++_iter) {
      IndicatorDataEntry _entry = _iter.Value() REF_DEREF GetEntry(_shift);
      _result += _iter.Value() REF_DEREF GetFullName() + " = " + _entry.ToString<double>() + "\n";
    }
    return _result;
  }

  /**
   * Returns symbol of the currently ticking indicator.
   **/
  static string GetSymbol() {
    if (symbol == PLATFORM_WRONG_SYMBOL) {
      RUNTIME_ERROR("Retrieving symbol outside the OnTick() of the currently ticking indicator is prohibited!");
    }
    return symbol;
  }

  /**
   * Returns timeframe of the currently ticking indicator.
   **/
  static ENUM_TIMEFRAMES GetPeriod() {
    if (period == PLATFORM_WRONG_TIMEFRAME) {
      RUNTIME_ERROR(
          "Retrieving period/timeframe outside the OnTick() of the currently ticking indicator is prohibited!");
    }

    return period;
  }

  /**
   * Returns the point size of the current symbol in the quote currency.
   * @see https://docs.mql4.com/check/point
   */
  static double GetPoint() {
    if (symbol == PLATFORM_WRONG_SYMBOL) {
      RUNTIME_ERROR(
          "Retrieving _Point variable or calling Point() outside the OnTick() of the currently ticking indicator is "
          "prohibited!");
    }

    Alert("Error: Platform::GetPoint() is not yet implemented! Returning 0.01.");
    DebugBreak();
    return 0.01;
  }

  /**
   * Returns the number of decimal digits determining the accuracy of price of the current chart symbol.
   * @see https://docs.mql4.com/check/digits
   */
  static int GetDigits() {
    if (symbol == PLATFORM_WRONG_SYMBOL) {
      RUNTIME_ERROR(
          "Retrieving _Digits variable or calling Digits() outside the OnTick() of the currently ticking indicator is "
          "prohibited!");
    }

    Alert("Error: Platform::GetDigits() is not yet implemented! Returning 2.");
    DebugBreak();
    return 2;
  }

 private:
  /**
   * Sets symbol of the currently ticking indicator.
   **/
  static void SetSymbol(string _symbol) { symbol = _symbol; }

  /**
   * Sets timeframe of the currently ticking indicator.
   **/
  static void SetPeriod(ENUM_TIMEFRAMES _period) { period = _period; }
};

bool Platform::initialized = false;
bool Platform::last_tick_result = false;
DateTime Platform::time = (datetime)0;
unsigned int Platform::time_flags = 0;
bool Platform::time_clear_flags = true;
int Platform::global_tick_index = 0;
string Platform::symbol = PLATFORM_WRONG_SYMBOL;
ENUM_TIMEFRAMES Platform::period = PLATFORM_WRONG_TIMEFRAME;
DictStruct<int64, Ref<IndicatorData>> Platform::indis;
DictStruct<int64, Ref<IndicatorData>> Platform::indis_dflt;

#ifndef __MQL__
// Following methods must be there are they're externed in Platform.extern.h
// and there's no better place for them!

/**
 * Returns number of candles for a given symbol and time-frame.
 */
int Bars(CONST_REF_TO_SIMPLE(string) _symbol, ENUM_TIMEFRAMES _tf) { return Platform::Bars(_symbol, _tf); }

/**
 * Returns the number of calculated data for the specified indicator.
 */
int BarsCalculated(int indicator_handle) { return Platform::BarsCalculated(indicator_handle); }

/**
 * Gets data of a specified buffer of a certain indicator in the necessary quantity.
 */
int CopyBuffer(int indicator_handle, int buffer_num, int start_pos, int count, ARRAY_REF(double, buffer)) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

uint64 PositionGetTicket(int _index) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

int64 PositionGetInteger(ENUM_POSITION_PROPERTY_INTEGER property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

double PositionGetDouble(ENUM_POSITION_PROPERTY_DOUBLE property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

string PositionGetString(ENUM_POSITION_PROPERTY_STRING property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns empty string.");
  return "";
}

int HistoryDealsTotal() {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

uint64 HistoryDealGetTicket(int index) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

int64 HistoryDealGetInteger(uint64 ticket_number, ENUM_DEAL_PROPERTY_INTEGER property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

double HistoryDealGetDouble(uint64 ticket_number, ENUM_DEAL_PROPERTY_DOUBLE property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

string HistoryDealGetString(uint64 ticket_number, ENUM_DEAL_PROPERTY_STRING property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns empty string.");
  return 0;
}

bool OrderSelect(int index, int select, int pool = MODE_TRADES) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool PositionSelectByTicket(int index) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool HistoryOrderSelect(int index) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool OrderSend(const MqlTradeRequest &request, MqlTradeResult &result) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool OrderCheck(const MqlTradeRequest &request, MqlTradeCheckResult &result) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

uint64 OrderGetTicket(int index) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

uint64 HistoryOrderGetTicket(int index) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

bool HistorySelectByPosition(int64 position_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool HistoryDealSelect(uint64 ticket) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

int64 OrderGetInteger(ENUM_ORDER_PROPERTY_INTEGER property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

int64 HistoryOrderGetInteger(uint64 ticket_number, ENUM_ORDER_PROPERTY_INTEGER property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

double OrderGetDouble(ENUM_ORDER_PROPERTY_DOUBLE property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

double HistoryOrderGetDouble(uint64 ticket_number, ENUM_ORDER_PROPERTY_DOUBLE property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

string OrderGetString(ENUM_ORDER_PROPERTY_STRING property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns empty string.");
  return 0;
}

string HistoryOrderGetString(uint64 ticket_number, ENUM_ORDER_PROPERTY_STRING property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns empty string.");
  return 0;
}

int PositionsTotal() {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

bool HistorySelect(datetime from_date, datetime to_date) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return 0;
}

int HistoryOrdersTotal() {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

int OrdersTotal() {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

int CopyOpen(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count, ARRAY_REF(double, arr)) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

int CopyHigh(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count, ARRAY_REF(double, arr)) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

int CopyLow(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count, ARRAY_REF(double, arr)) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

int CopyClose(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count, ARRAY_REF(double, arr)) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

int CopyTickVolume(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count, ARRAY_REF(int64, arr)) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

int CopyRealVolume(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count, ARRAY_REF(int64, arr)) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

double iOpen(string symbol, int timeframe, int shift) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 1.0.");
  return 1.0;
}

double iHigh(string symbol, int timeframe, int shift) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 1.0.");
  return 1.0;
}

double iLow(string symbol, int timeframe, int shift) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 1.0.");
  return 1.0;
}

double iClose(string symbol, int timeframe, int shift) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 1.0.");
  return 1.0;
}

int ChartID() { return Platform::ChartID(); }

bool OrderCalcMargin(ENUM_ORDER_TYPE _action, string _symbol, double _volume, double _price, double &_margin) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

double AccountInfoDouble(ENUM_ACCOUNT_INFO_DOUBLE property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return false;
}

int64 AccountInfoInteger(ENUM_ACCOUNT_INFO_INTEGER property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return false;
}

string AccountInfoInteger(ENUM_ACCOUNT_INFO_STRING property_id) {
  Print("Not yet implemented: ", __FUNCTION__, " returns empty string.");
  return "";
}

string Symbol() {
  Print("Not yet implemented: ", __FUNCTION__, " returns empty string.");
  return "";
}

string ObjectName(int64 _chart_id, int _pos, int _sub_window, int _type) {
  Print("Not yet implemented: ", __FUNCTION__, " returns empty string.");
  return "";
}

int ObjectsTotal(int64 chart_id, int type, int window) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

bool PlotIndexSetString(int plot_index, int prop_id, string prop_value) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool PlotIndexSetInteger(int plot_index, int prop_id, int prop_value) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool ObjectSetInteger(int64 chart_id, string name, ENUM_OBJECT_PROPERTY_INTEGER prop_id, int64 prop_value) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool ObjectSetInteger(int64 chart_id, string name, ENUM_OBJECT_PROPERTY_INTEGER prop_id, int prop_modifier,
                      int64 prop_value) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool ObjectSetDouble(int64 chart_id, string name, ENUM_OBJECT_PROPERTY_DOUBLE prop_id, double prop_value) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool ObjectSetDouble(int64 chart_id, string name, ENUM_OBJECT_PROPERTY_DOUBLE prop_id, int prop_modifier,
                     double prop_value) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool ObjectCreate(int64 _cid, string _name, ENUM_OBJECT _otype, int _swindow, datetime _t1, double _p1) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool ObjectCreate(int64 _cid, string _name, ENUM_OBJECT _otype, int _swindow, datetime _t1, double _p1, datetime _t2,
                  double _p2) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool ObjectMove(int64 chart_id, string name, int point_index, datetime time, double price) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

bool ObjectDelete(int64 chart_id, string name) {
  Print("Not yet implemented: ", __FUNCTION__, " returns false.");
  return false;
}

int ObjectFind(int64 chart_id, string name) {
  Print("Not yet implemented: ", __FUNCTION__, " returns 0.");
  return 0;
}

string TimeToString(datetime value, int mode) {
  static std::stringstream ss;
  ss.clear();
  ss.str("");

  std::time_t time = value;
  std::tm *ptm = std::localtime(&time);
  char date[16], minutes[16], seconds[16];
  std::strftime(date, 32, "%Y.%m.%d", ptm);
  std::strftime(minutes, 32, "%H:%M", ptm);
  std::strftime(seconds, 32, "%S", ptm);

  if (mode & TIME_DATE) ss << date;

  if (mode & TIME_MINUTES) {
    if (mode & TIME_DATE) {
      ss << " ";
    }
    ss << minutes;
  }

  if (mode & TIME_SECONDS) {
    if (mode & TIME_DATE && !(mode & TIME_MINUTES)) {
      ss << " ";
    } else if (mode & TIME_MINUTES) {
      ss << ":";
    }
    ss << seconds;
  }

  return ss.str();
}

bool TimeToStruct(datetime dt, MqlDateTime &dt_struct) {
  time_t now = (time_t)dt;

  tm *ltm = localtime(&now);

  dt_struct.day = ltm->tm_mday;
  dt_struct.day_of_week = ltm->tm_wday;
  dt_struct.day_of_year = ltm->tm_yday;
  dt_struct.hour = ltm->tm_hour;
  dt_struct.min = ltm->tm_min;
  dt_struct.mon = ltm->tm_mon;
  dt_struct.sec = ltm->tm_sec;
  dt_struct.year = ltm->tm_year;

  return true;
}

SymbolGetter::operator string() const { return Platform::GetSymbol(); }

ENUM_TIMEFRAMES Period() { return Platform::GetPeriod(); }

double Point() { return Platform::GetPoint(); }
#define _Point (Point())

int Digits() { return Platform::GetDigits(); }
#define _Digits (Digits())

datetime StructToTime(MqlDateTime &dt_struct) {
  tm ltm;
  ltm.tm_mday = dt_struct.day;
  ltm.tm_wday = dt_struct.day_of_week;
  ltm.tm_yday = dt_struct.day_of_year;
  ltm.tm_hour = dt_struct.hour;
  ltm.tm_min = dt_struct.min;
  ltm.tm_mon = dt_struct.mon;
  ltm.tm_sec = dt_struct.sec;
  ltm.tm_year = dt_struct.year;

  return mktime(&ltm);
}

#endif

/**
 * Will test given indicator class with platform-default data source bindings.
 */
#define TEST_INDICATOR_DEFAULT_BINDINGS_PARAMS(C, PARAMS)                                                             \
  Ref<C> indi = new C(PARAMS);                                                                                        \
                                                                                                                      \
  int OnInit() {                                                                                                      \
    Platform::Init();                                                                                                 \
    Platform::AddWithDefaultBindings(indi.Ptr(), "EURUSD", PERIOD_M1);                                                \
    bool _result = true;                                                                                              \
    assertTrueOrFail(indi REF_DEREF IsValid(), "Error on IsValid!");                                                  \
    return (_result && _LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED);                                    \
  }                                                                                                                   \
                                                                                                                      \
  void OnTick() {                                                                                                     \
    Platform::Tick();                                                                                                 \
    if (Platform::IsNewHour()) {                                                                                      \
      IndicatorDataEntry _entry = indi REF_DEREF GetEntry();                                                          \
      bool _is_ready = indi REF_DEREF Get<bool>(STRUCT_ENUM(IndicatorDataState, INDICATOR_DATA_STATE_PROP_IS_READY)); \
      bool _is_valid = _entry.IsValid();                                                                              \
      Print(indi REF_DEREF ToString(), _is_ready ? " (Ready)" : " (Not yet ready)");                                  \
      if (_is_ready && !_is_valid) {                                                                                  \
        Print(indi REF_DEREF ToString(), " (Invalid entry!)");                                                        \
        assertTrueOrExit(_entry.IsValid(), "Invalid entry!");                                                         \
      }                                                                                                               \
    }                                                                                                                 \
  }

#define TEST_INDICATOR_DEFAULT_BINDINGS(C) TEST_INDICATOR_DEFAULT_BINDINGS_PARAMS(C, )

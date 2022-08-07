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

// Includes.

/**
 * Current platform's static methods.
 */

#include "Flags.h"
#include "Indicator/IndicatorData.h"
#include "Std.h"

#ifdef __MQLBUILD__
#include "Indicator/tests/classes/IndicatorTfDummy.h"
#include "Indicators/Tick/Indi_TickMt.mqh"
#define PLATFORM_DEFAULT_INDICATOR_TICK Indi_TickMt
#else
#error "Platform not supported!
#endif
#include "SymbolInfo.struct.static.h"

class Platform {
  // Whether Init() was already called.
  static bool initialized;

  // Date and time used to determine periods that passed.
  static DateTime time;

  // Merged flags from previous Platform::UpdateTime();
  static unsigned int time_flags;

  // Whether to clear passed periods on consecutive Platform::UpdateTime().
  static bool time_clear_flags;

  // List of added indicators.
  static DictStruct<long, Ref<IndicatorData>> indis;

  // List of default Candle/Tick indicators.
  static DictStruct<long, Ref<IndicatorData>> indis_dflt;

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

    // Starting from current timestamp.
    time.Update();
  }

  /**
   * Performs tick on every added indicator.
   */
  static void Tick() {
    // Checking starting periods and updating time to current one.
    time_flags = time.GetStartedPeriods();
    time.Update();

    DictStructIterator<long, Ref<IndicatorData>> _iter;

    for (_iter = indis.Begin(); _iter.IsValid(); ++_iter) {
      _iter.Value() REF_DEREF Tick();
    }

    for (_iter = indis_dflt.Begin(); _iter.IsValid(); ++_iter) {
      _iter.Value() REF_DEREF Tick();
    }

    // Will check for new time periods in consecutive Platform::UpdateTime().
    time_clear_flags = true;
  }

  /**
   * Returns dictionary of added indicators (keyed by unique id).
   */
  static DictStruct<long, Ref<IndicatorData>> *GetIndicators() { return &indis; }

  /**
   * Adds indicator to be processed by platform.
   */
  static void Add(IndicatorData *_indi) {
    Ref<IndicatorData> _ref = _indi;
    indis.Set(_indi PTR_DEREF GetId(), _ref);
  }

  /**
   * Adds indicator to be processed by platform and tries to initialize its data source(s).
   */
  static void AddWithDefaultBindings(IndicatorData *_indi, CONST_REF_TO(string) _symbol = "",
                                     ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
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
   * Binds Candle and/or Tick indicator as a source of prices or data for given indicator.
   *
   * Note that some indicators may work on custom set of buffers required from data source and not on Candle or Tick
   * indicator.
   */
  static void BindDefaultDataSource(IndicatorData *_indi, CONST_REF_TO(string) _symbol, ENUM_TIMEFRAMES _tf) {
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
  static IndicatorData *FetchDefaultCandleIndicator(string _symbol = "", ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    if (_symbol == "") {
      _symbol = _Symbol;
    }

    if (_tf == PERIOD_CURRENT) {
      _tf = (ENUM_TIMEFRAMES)Period();
    }

    // Candle is per symbol and TF. Single Candle indicator can't handle multiple TFs.
    string _key = Util::MakeKey("PlatformIndicatorCandle", _symbol, (int)_tf);
    IndicatorData *_indi_candle;
    if (!Objects<IndicatorData>::TryGet(_key, _indi_candle)) {
      _indi_candle = Objects<IndicatorData>::Set(_key, new IndicatorTfDummy(_tf));

      // Adding indicator to list of default indicators in order to tick it on every Tick() call.
      Ref<IndicatorData> _ref = _indi_candle;
      indis_dflt.Set(_indi_candle PTR_DEREF GetId(), _ref);
    }

    if (!_indi_candle PTR_DEREF HasDataSource()) {
      // Missing tick indicator.
      _indi_candle PTR_DEREF InjectDataSource(FetchDefaultTickIndicator(_symbol));
    }

    return _indi_candle;
  }

  /**
   * Returns default Tick-compatible indicator for current platform for given symbol.
   */
  static IndicatorData *FetchDefaultTickIndicator(string _symbol = "") {
    if (_symbol == "") {
      _symbol = _Symbol;
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
  static SymbolInfoProp FetchDefaultSymbolProps(CONST_REF_TO(string) _symbol) {
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
    for (DictStructIterator<long, Ref<IndicatorData>> _iter = indis.Begin(); _iter.IsValid(); ++_iter) {
      IndicatorDataEntry _entry = _iter.Value() REF_DEREF GetEntry(_shift);
      _result += _iter.Value() REF_DEREF GetFullName() + " = " + _entry.ToString<double>() + "\n";
    }
    return _result;
  }
};

bool Platform::initialized = false;
DateTime Platform::time = 0;
unsigned int Platform::time_flags = 0;
bool Platform::time_clear_flags = true;
DictStruct<long, Ref<IndicatorData>> Platform::indis;
DictStruct<long, Ref<IndicatorData>> Platform::indis_dflt;

// void OnTimer() { Print("Timer"); Platform::OnTimer(); }

/**
 * Will test given indicator class with platform-default data source bindings.
 */
#define TEST_INDICATOR_DEFAULT_BINDINGS_PARAMS(C, PARAMS)                                                    \
  Ref<C> indi = new C(PARAMS);                                                                               \
                                                                                                             \
  int OnInit() {                                                                                             \
    Platform::Init();                                                                                        \
    Platform::AddWithDefaultBindings(indi.Ptr());                                                            \
    bool _result = true;                                                                                     \
    assertTrueOrFail(indi REF_DEREF IsValid(), "Error on IsValid!");                                         \
    return (_result && _LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED);                           \
  }                                                                                                          \
                                                                                                             \
  void OnTick() {                                                                                            \
    Platform::Tick();                                                                                        \
    if (Platform::IsNewHour()) {                                                                             \
      IndicatorDataEntry _entry = indi REF_DEREF GetEntry();                                                 \
      bool _is_ready = indi REF_DEREF Get<bool>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY)); \
      bool _is_valid = _entry.IsValid();                                                                     \
      Print(indi REF_DEREF ToString(), _is_ready ? "" : " (Not yet ready)");                                 \
      if (_is_ready && !_is_valid) {                                                                         \
        Print(indi REF_DEREF ToString(), " (Invalid entry!)");                                               \
        assertTrueOrExit(_entry.IsValid(), "Invalid entry!");                                                \
      }                                                                                                      \
    }                                                                                                        \
  }

#define TEST_INDICATOR_DEFAULT_BINDINGS(C) TEST_INDICATOR_DEFAULT_BINDINGS_PARAMS(C, )

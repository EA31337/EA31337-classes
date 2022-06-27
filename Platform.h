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
#include "IndicatorBase.h"
#include "Std.h"

#ifdef __MQLBUILD__
#include "Indicator/tests/classes/IndicatorTfDummy.h"
#include "Indicator/tests/classes/IndicatorTickReal.h"
#define PLATFORM_DEFAULT_INDICATOR_TICK IndicatorTickReal
#else
#error "Platform not supported!
#endif

class Platform {
  // Date and time used to determine periods that passed.
  static DateTime time;

  // Merged flags from previous Platform::UpdateTime();
  static unsigned int time_flags;

  // Whether to clear passed periods on consecutive Platform::UpdateTime().
  static bool time_clear_flags;

  // List of added indicators.
  static DictStruct<long, Ref<IndicatorBase>> indis;

 public:
  /**
   * Initializes platform. Sets event timer and so on.
   */
  static void Init() {
    // OnTimer() every second.
    EventSetTimer(1);
  }

  /**
   * Adds indicator to be processed by platform.
   */
  static void Add(IndicatorBase *_indi) {
    Ref<IndicatorBase> _ref = _indi;
    indis.Set(_indi PTR_DEREF GetId(), _ref);
  }

  /**
   * Adds indicator to be processed by platform and tries to initialize its data source(s).
   */
  static void AddWithDefaultBindings(IndicatorBase *_indi, CONST_REF_TO(string) _symbol, ENUM_TIMEFRAMES _tf) {
    Add(_indi);
    BindDefaultDataSource(_indi, _symbol, _tf);
  }

  /**
   * Removes indicator from being processed by platform.
   */
  static void Remove(IndicatorBase *_indi) { indis.Unset(_indi PTR_DEREF GetId()); }

  /**
   * Performs tick on every added indicator.
   */
  static void Tick() {
    for (DictStructIterator<int, Ref<IndicatorBase>> _iter; _iter.IsValid(); ++_iter) {
      _iter.Value() REF_DEREF Tick();
    }
    // Will check for new time periods in consecutive Platform::UpdateTime().
    time_clear_flags = true;
  }

  /**
   * Returns date and time used to determine periods that passed.
   */
  static DateTime Time() { return time; }

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
   * Updates date and time used to determine periods that passed.
   */
  static void UpdateTime() {
    if (time_clear_flags) {
      time_flags = 0;
      time_clear_flags = false;
    }
    // In each second we merge flags returned by DateTime::GetStartedPeriods().
    time_flags |= time.GetStartedPeriods();
    // time_flags |= DATETIME_SECOND;
  }

  /**
   * Processes platform logic every one second.
   */
  static void OnTimer() { UpdateTime(); }

  /**
   * Binds Candle and/or Tick indicator as a source of prices or data for given indicator.
   *
   * Note that some indicators may work on custom set of buffers required from data source and not on Candle or Tick
   * indicator.
   */
  static void BindDefaultDataSource(IndicatorBase *_indi, CONST_REF_TO(string) _symbol, ENUM_TIMEFRAMES _tf) {
    Flags<unsigned int> _suitable_ds_types = _indi PTR_DEREF GetSuitableDataSourceTypes();

    IndicatorBase *_default_indi_candle = FetchDefaultCandleIndicator(_symbol, _tf);
    IndicatorBase *_default_indi_tick = FetchDefaultTickIndicator(_symbol);

    if (_suitable_ds_types.HasFlag(INDI_SUITABLE_DS_TYPE_CUSTOM)) {
      if (_indi PTR_DEREF OnCheckIfSuitableDataSource(_default_indi_tick)) {
        _indi PTR_DEREF InjectDataSource(_default_indi_tick);
      } else if (_indi PTR_DEREF OnCheckIfSuitableDataSource(_default_indi_candle)) {
        _indi PTR_DEREF InjectDataSource(_default_indi_candle);
      } else {
        // We can't attach any default data source as we don't know what type of indicator to create.
        Print("ERROR: Cannot bind default data source for ", _indi PTR_DEREF GetFullName(),
              " as we don't know what type of indicator to create!");
        DebugBreak();
      }
    } else if (_suitable_ds_types.HasFlag(INDI_SUITABLE_DS_TYPE_CANDLE) &&
               !_indi PTR_DEREF HasDataSource(_default_indi_candle)) {
      // Will inject Candle indicator before Tick indicator (if already attached).
      _indi PTR_DEREF InjectDataSource(_default_indi_candle);
    } else if (_suitable_ds_types.HasFlag(INDI_SUITABLE_DS_TYPE_TICK) &&
               !_indi PTR_DEREF HasDataSource(_default_indi_tick)) {
      _indi PTR_DEREF InjectDataSource(_default_indi_tick);
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
  static IndicatorBase *FetchDefaultCandleIndicator(CONST_REF_TO(string) _symbol, ENUM_TIMEFRAMES _tf) {
    // Candle is per symbol and TF. Single Candle indicator can't handle multiple TFs.
    string _key = Util::MakeKey("PlatformIndicatorCandle", _symbol, _tf);
    IndicatorBase *_indi_candle;
    if (!Objects<IndicatorBase>::TryGet(_key, _indi_candle)) {
      _indi_candle = Objects<IndicatorBase>::Set(_key, new IndicatorTfDummy(_tf));
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
  static IndicatorBase *FetchDefaultTickIndicator(CONST_REF_TO(string) _symbol) {
    string _key = Util::MakeKey("PlatformIndicatorTick", _symbol);
    IndicatorBase *_indi_tick;
    if (!Objects<IndicatorBase>::TryGet(_key, _indi_tick)) {
      _indi_tick = Objects<IndicatorBase>::Set(_key, new PLATFORM_DEFAULT_INDICATOR_TICK(_symbol));
    }
    return _indi_tick;
  }
};

DateTime Platform::time;
unsigned int Platform::time_flags = 0;
bool Platform::time_clear_flags = true;
DictStruct<long, Ref<IndicatorBase>> Platform::indis;

void OnTimer() { Platform::OnTimer(); }

/**
 * Will test given indicator class with platform-default data source bindings.
 */
#define TEST_INDICATOR_DEFAULT_BINDINGS(C)                                                        \
                                                                                                  \
  Ref<C> indi = new C();                                                                          \
                                                                                                  \
  int OnInit() {                                                                                  \
    Platform::Init();                                                                             \
    Platform::AddWithDefaultBindings(indi.Ptr(), _Symbol, PERIOD_CURRENT);                        \
    bool _result = true;                                                                          \
    assertTrueOrFail(indi REF_DEREF IsValid(), "Error on IsValid!");                              \
    return (_result && _LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED);                \
  }                                                                                               \
                                                                                                  \
  void OnTick() {                                                                                 \
    Platform::Tick();                                                                             \
    if (Platform::IsNewHour()) {                                                                  \
      Print(indi REF_DEREF ToString());                                                           \
      if (indi REF_DEREF Get<bool>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) { \
        assertTrueOrExit(indi REF_DEREF GetEntry().IsValid(), "Invalid entry!");                  \
      }                                                                                           \
    }                                                                                             \
  }

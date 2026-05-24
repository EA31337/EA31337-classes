//+------------------------------------------------------------------+
//|                                                     FX31337 wasm |
//|                                 Copyright 2022-2022, EA31337 Ltd |
//|                          https://github.com/FX31337/FX31337-wasm |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Tester class. Used for testing indicators. You can add indicators to it and
 * then run ticks. After that, you can retrieve indicator values using
 * GetValues() method.
 */

#ifdef __EMSCRIPTEN__
#include <emscripten/bind.h>
#include <emscripten/emscripten.h>
#endif

//#define __debug__
//#define __debug_indicator__
//#define __debug_emscripten__
//#define __debug_verbose__

// Local includes.
#include "../Indicator/Indicator.h"
#include "../Indicator/tests/classes/IndicatorTfDummy.h"
#include "../Indicator/tests/classes/Indicators.h"
#include "../Indicators/OHLC/Indi_OHLC.mqh"
#include "../Indicators/Oscillator/Indi_RSI.h"
#include "../Indicators/Price/Indi_AppliedPrice.h"
#include "../Indicators/Price/Indi_MA.h"
#include "../Indicators/Tick/Indi_TickProvider.h"
#include "../Platform/Chart/Chart.enum.h"
#include "../Platform/Platform.h"
#include "../Storage/Array.extern.h"
#include "../Storage/Dict/DictStruct.h"
#include "../Tick/Tick.struct.h"
#include "../Tester/TesterValues.h"
#include "../Tester/TesterValuesFetchParams.h"

#define INDICATOR_TEST_SYMBOL "EURUSD"
#define INDICATOR_TEST_TIMEFRAME PERIOD_M1

/*

 Example in JS:

 const tester = new lib.Tester('EURUSD', lib.timeframes.M5);
 const ticks  = new lib.indicators.TickProvider();
 const rsi    = new lib.indicators.RSI(13);

 tester.Add(rsi);

 // Note that all timeframes shares the same ticks and so you may reuse single
 // TickProvider indicator for other Tester instances for the same symbols pair.
 ticks.Add([
   {timestamp: ..., ask: ..., bid: ...},
   {timestamp: ..., ask: ..., bid: ...}
 ]);

 // You can also use tester.RunTick() method in a loop or if you're sure that
 // new tick arrived.
 tester.RunAllTicks();

 for (let indicator of tester.GetIndicatorsInfo()) {
   console.log(`Indicator ${indicator.name}'s has completed. `)
 }

*/



class Tester {
 public:
  /**
   * Constructor.
   */
  Tester() {}

  /**
   * Adds indicator which must previously set its candle/tick sources in order
   * to work.
   */
  static void Add(IndicatorData *_indi) { Platform::Add(_indi); }

  /**
   * Adds indicator using given symbol and timeframe. Uses default Tf and Tick
   * indicator for current platform. Under C++/Emscripten default Tick
   * indicator is TickProvider. Note that you must feed TickProvider for each
   * symbol used.
   *
   * In JS you may retrieve default tick indicator via:
   * lib.Tester.GetDefaultTickIndicator(symbol: string).
   * The same with default candle indicator:
   * lib.Tester.GetDefaultCandleIndicator(symbol: string, tf: lib.timeframes[tf]).
   */
  static void AddPlatformWise(Ref<IndicatorData> _indi, string _symbol, ENUM_TIMEFRAMES _tf) {
    Platform::AddWithDefaultBindings(_indi.Ptr(), _symbol, _tf);

    Indi_TickProvider *_tick_provider = dynamic_cast<Indi_TickProvider *>(Platform::FetchDefaultTickIndicator(_symbol));

    // Feeding with random ticks only if tick provider is empty.
    // @todo Should be moved to Tester::FeedTickProvidersWithRandomTicks() or somewhere else.
    if (_tick_provider != nullptr && _tick_provider PTR_DEREF BufferSize() == 0) {
      FeedTickProvider(_tick_provider);
    }
  }

  /**
   * Calculates "timeFromMs", "timeToMs" and "timeStepSecs" parameters to directly pass them into
   * lib.Tester.GetValues(). Scroll 0.0f = Time for a value of absolute index 0. When Zoom is 1, Scroll determines
   * number of minutes to retrieve. Effective absolute index is: GetIndexByTimeMs(MinuteMs / zoom * scroll).
   * 
   * @todo The code is wrong in time calculations.
   */
  static TesterValuesFetchParams GetTimeByScrollAndZoom(float scroll, float zoom, int visible_intervals) {
    // Base interval for zoom 1 is 1 minute. Zoom 2 means 60s / 2, i.e., 30s.
    // Essentialy the interval is: 1 minute / zoom.
    TesterValuesFetchParams result;
    result.timeFromMs = 60000.0 * scroll * zoom;
    result.timeToMs = 60000.0 * (scroll * visible_intervals) * zoom;
    result.timeStepSecs = (int)(60.0f / zoom);
    return result;
  }

  /**
   * @see Tester::GetValues(int64 _timeFromMs...) below.
   **/
  static TesterValues GetValues(const TesterValuesFetchParams &params, bool _aggregate_no_fits = true) {
    return GetValues(params.timeFromMs, params.timeToMs, params.timeStepSecs, _aggregate_no_fits);
  }

  /**
   * Retrieves chunk of values that fits and don't fit given timeStep, but are
   * between given timeFrom and timeTo.
   *
   * Values chunk contains indicator values aggregated by given number of
   * seconds. When you zoom out the chart, you increase that number of seconds.
   * Each item in the chunk will represent a time-frame being multiplication of
   * the given number of seconds. timeFrom and timeTo parameters is a
   * time-range in ms (BigInt type).
   */
  static TesterValues GetValues(int64 _time_from_ms, int64 _time_to_ms, int _time_step_secs,
                                bool _aggregate_no_fits = true) {
    /*
      Pseudo-code:

      0   60  120 <- Fits to time-step
      |   |   |
       | |   |
       2 50  90 <- Doesn't fit to time-step

      We supports getting values on history and live.

      Getting values that fits time-step is easy. We check time of the last entry and calculate indicies to retrieve
      from given time. Next step is aggregating those values into given time-step. When we have more that one value in
      the same aggregated time, we generate two entries which determines minimum and maximum values.

      Values that don't fit given time-step are those generated by non-TF indicators, e.g., Renko. We may choose to
      aggregate values, so chart will be more clear when zoomed out. Same as fit time-step fit values, when aggregating
      we generate min/max values.

      Seeking over non-TF values must be optimized. We don't want to go over all the values and check their time. To do
      that, we modify IndicatorData and store cache containing times for each N-th value. E.g., we store time for value
      0, 100, 200, 300 and so on. Also, we add new method to IndicatorData, GetValueIndicesRangeAbs(time_from_ms,
      time_to_ms, inclusive_from, inclusive_to) which returns absolute start and end indices of values for the given
      time range. It will use values' time cache. The idea of the cache is to add time when every N-th value is
      generated.

    */

    TesterValues values;

    // Firstly, we need to know which indicators are TF-based and which aren't
    // TF-based. Non TF-based indicators generates values whenever they want,
    // so values from their shifts aren't generated in fixed intervals.
    //
    // All non TF-based indicators have INDI_FLAG_LOOSE_TF_CANDLE_INDICATOR
    // flag set. Such flag have e.g., Renko indicator.

    // Now we traverse indicators added to the Platform class via
    // Tester::Add(...) or via Platform::Add...().

    // First step is to calculate how much of those two types of indicators we
    // have.

    int _num_tf = 0, _num_loose_tf = 0;

    for (DictIteratorBase<long long, Ref<IndicatorData>> _iter = Platform::GetIndicators() PTR_DEREF Begin();
         _iter.IsValid(); ++_iter) {
      IndicatorData *_indi = _iter.Value().Ptr();
      if (_indi PTR_DEREF IsCandleIndicator() || _iter.Value() REF_DEREF IsTickIndicator()) {
        // We don't need values of candle or tick indicators.
        continue;
      }

      bool _is_loose_tf = (_indi PTR_DEREF GetFlags() & INDI_FLAG_LOOSE_TF_CANDLE_INDICATOR) != 0;

      if (_is_loose_tf) {
        ++_num_loose_tf;
      } else {
        ++_num_tf;
      }
    }

    ArrayResize(values.timestep_based, _num_tf);
    ArrayResize(values.loose, _num_loose_tf);

    // Next step is to generate values for each type of indicators.

    for (DictIteratorBase<long long, Ref<IndicatorData>> _iter = Platform::GetIndicators() PTR_DEREF Begin();
         _iter.IsValid(); ++_iter) {
      IndicatorData *_indi = _iter.Value().Ptr();
      if (_indi PTR_DEREF IsCandleIndicator() || _iter.Value() REF_DEREF IsTickIndicator()) {
        // We don't need values of candle or tick indicators.
        continue;
      }

      bool _is_loose_tf = (_indi PTR_DEREF GetFlags() & INDI_FLAG_LOOSE_TF_CANDLE_INDICATOR) != 0;

      if (!_is_loose_tf) {
        // It's a TF-based indicator (fixed interval).
        // Such indicators are based on the assigned TF indicator and TF value
        // will be retrieved from those TF indicators.
        ENUM_TIMEFRAMES _tf = _indi PTR_DEREF GetTf();

        /*
        // Time-frame length in miliseconds.
        int64 _tf_ms = ((int64)ChartTf::TfToMs(_tf));

        // Round time_from down to the nearest TF boundary.
        _time_from_ms = _time_from_ms - (_time_from_ms % _tf_ms);

        // Round time_to up to the end of its TF bar.
        _time_to_ms = _time_to_ms - (_time_to_ms % _tf_ms) + (_tf_ms - 1);

        // In order to get relative indices of values to retrieve, we calculate difference of current value's time
        // (relative index 0) and rounded start time.
        int64 _value_rel_0_time_ms = _indi PTR_DEREF GetBarTime(0);

        // Note that starting index could be negative. That means that we want to retrieve future values.
        int _value_index_from = (int)((_value_rel_0_time_ms - _time_from_ms) / _tf_ms);

        // Note that ending index could be negative. That means that we want to retrieve future values.
        int _value_index_to = (int)((_value_rel_0_time_ms - _time_to_ms) / _tf_ms);

#ifdef __debug_verbose__
        Print("Tester::GetValues(): Will aggregate values for TF ", EnumToString(_tf), ", relative indices from ",
              _value_index_from, " to ", _value_index_to);
#endif

        if (_value_index_from < 0 || _value_index_to < 0) {
          Alert("We don't yet support retrieving future values!");
          DebugBreak();
          return values;
        }
        */

        // Now it's time to retrieve values for the given time range and aggregate them into given time-step.
        REF_TO(TesterValuesColumns) columns = values.timestep_based[_iter.Index()];
        
        columns.indicator_info = TesterIndicatorInfo(_indi PTR_DEREF GetName(), 0, 0, _indi PTR_DEREF GetSymbol(), _tf);

        GetValuesForTimeFrameBasedIndicatorUngrouped(_indi, /*_time_from_ms, _time_to_ms, _time_step_secs*/ columns);

      } else {
        // It's a loose, i.e., non TF-based indicator (values are generated in
        // a non-fixed interval and can we generated anytime). We just traverse
        // values and try to retrieve values for a given time range.
      }
    }

    return values;
  }

  /**
   * Fills _columns.values with one TesterValuesColumnValue per (mode, time-step bucket) for
   * a TF-based indicator. Bars are iterated oldest→newest so value_open = oldest sample and
   * value_close = newest sample within each bucket, matching standard OHLCVA bar semantics.
   *
   * For multi-mode indicators (e.g. MACD) each mode produces its own TesterValuesColumnValue
   * per bucket. The values are pushed in mode order within each bucket:
   *   [mode0 bucket0, mode1 bucket0, ..., mode0 bucket1, mode1 bucket1, ...]
   */
  static void GetValuesForTimeFrameBasedIndicator(IndicatorData *_indi, int64 _time_from_ms, int64 _time_to_ms,
                                                  int _time_step_secs, TesterValuesColumns &_columns) {
  }

  /**
   * Retrieves raw (ungrouped) values of an indicator into _columns.values.
   */
  static void GetValuesForTimeFrameBasedIndicatorUngrouped(IndicatorData *_indi, TesterValuesColumns &_columns) {
    string _indi_name = _indi PTR_DEREF GetName();

    // Iterate oldest→newest (descending bar index = ascending timestamp).
    // Each valid bar produces one TesterValuesColumnValue per output mode.
    for (int _idx = _indi->GetBars() - 1; _idx >= 0; --_idx) {
      IndicatorDataEntry _entry = _indi PTR_DEREF GetEntry(_idx);
      if (!_entry.IsValid()) {
        continue;
      }

      ArrayPush(_columns.values, _entry);
    }
  }

  /**
   * Feeds the given tick provider with ticks parsed from a CSV string.
   *
   * CSV format (no header row): Date,Bid,Ask,Volume,Spread
   * Date format: YYYY.MM.DD HH:MM:SS.mmm (UTC)
   * Volume and Spread columns are accepted but ignored.
   *
   * @param _tick_provider  The TickProvider indicator to feed.
   * @param _csv            Raw CSV text (newline-separated rows, no header).
   */
  static void FeedTickProviderCsv(Ref<Indi_TickProvider> _tick_provider, const string& _csv) {
    ARRAY(TickTAB<double>, _ticks);

    size_t pos = 0;
    const size_t csv_len = _csv.size();

    while (pos < csv_len) {
      size_t nl = _csv.find('\n', pos);
      if (nl == string::npos) nl = csv_len;

      string line = _csv.substr(pos, nl - pos);
      pos = nl + 1;

      // Strip trailing carriage return (Windows line endings).
      if (!line.empty() && line.back() == '\r') line.pop_back();
      if (line.empty()) continue;

      int year = 0, month = 0, day = 0, hour = 0, minute = 0, second = 0, millis = 0;
      double bid = 0.0, ask = 0.0, vol = 0.0, spread = 0.0;

      // Expected format: "2022.02.01 05:00:06.460,1.1243,1.12433,0.90,0.18"
      if (sscanf(line.c_str(), "%d.%d.%d %d:%d:%d.%d,%lf,%lf,%lf,%lf",
                 &year, &month, &day, &hour, &minute, &second, &millis,
                 &bid, &ask, &vol, &spread) < 9) {
        continue;
      }

      struct tm t = {};
      t.tm_year  = year - 1900;
      t.tm_mon   = month - 1;
      t.tm_mday  = day;
      t.tm_hour  = hour;
      t.tm_min   = minute;
      t.tm_sec   = second;
      t.tm_isdst = 0;

      int64 time_ms = (int64)timegm(&t) * 1000LL + (int64)millis;
      ArrayPush(_ticks, TickTAB<double>(time_ms, ask, bid));
    }

    _tick_provider REF_DEREF Feed(_ticks);
    Print("FeedTickProviderCsv: loaded ", ArraySize(_ticks), " ticks.");
  }

  /**
   * Helper function for feeding given tick provider with some random ticks.
   **/
  // Generates a single random TickTAB<double> for a given time.
  static TickTAB<double> RandomizeTick(int64 time_ms) {
    // Use a sinusoidal price to guarantee that RSI oscillates visibly.
    // - Mean price = 1.0, amplitude = 0.3  → range [0.7, 1.3]
    // - One full price cycle = 120 ticks = 40 M1 bars (3 ticks/bar)
    // - RSI period is 13 bars. The half-cycle (20 bars) must be > RSI period so
    //   the SMMA can track each direction change and produce clear oscillations.
    const double _mean        = 1.0;
    const double _amplitude   = 0.3;
    const double _spread      = 0.2;
    const double _pi          = acos(-1.0);
    const int    _cycle_ticks = 120; // ticks per full price cycle (40 M1 bars)
    double _ask = _mean + _amplitude * sin(2.0 * _pi * time_ms / _cycle_ticks);
    double _bid = _ask + _spread;
    return TickTAB<double>(time_ms, _ask, _bid);
  }

  static void FeedTickProvider(Ref<Indi_TickProvider> _tick_provider) {
    Print("Feeding Tick Provider with random values...");
    ARRAY(TickTAB<double>, _ticks);

    // We start at 2000-01-01, but it doesn't matter. We just need to have increasing time for each tick.
    int64 _dt = 946684800;
    for (int i = 0; i < 600; ++i) {
      int64 time_ms = (_dt + i * 20) * 1000;
      ArrayPush(_ticks, RandomizeTick(time_ms));
    }
    _tick_provider REF_DEREF Feed(_ticks);
    Print("Given Tick Provider has now ", _tick_provider REF_DEREF BufferSize(), " random values.");
  }

  static void Init() {
    Platform::Init();

    // Relative Strength Index (RSI).
    // IndiRSIParams rsi_params(10, PRICE_OPEN);
    // Ref<IndicatorData> indi_rsi = new Indi_RSI(rsi_params, IDATA_INDICATOR);
    // AddPlatformWise(indi_rsi.Ptr(), INDICATOR_TEST_SYMBOL, INDICATOR_TEST_TIMEFRAME);
  }

  /**
   * Runs all ticks. Stops thread until all ticks are processed.
   */
  static void RunAllTicks() {
    while (RunTick()) {
      // Ticking all ticks.
    }
  }

  /**
   * Runs a single tick. Returns false if there's no more ticks to process (all
   * tick indicators said there will be no more ticks).
   */
  static bool RunTick() {
    Platform::Tick();

    for (DictStructIterator<long long, Ref<IndicatorData>> _iter = Platform::GetIndicators() PTR_DEREF Begin();
         _iter.IsValid(); ++_iter) {
      if (_iter.Value() REF_DEREF IsCandleIndicator() || _iter.Value() REF_DEREF IsTickIndicator()) {
        // We don't need values of candle or tick indicators.
        continue;
      }

      // Forcing indicator to calculate its value for the current tick.
      IndicatorDataEntry _entry = _iter.Value() REF_DEREF GetEntry();

      if (_entry.IsValid()) {
        Print(TimeCurrent(), ": ", _iter.Value() REF_DEREF GetFullName(), "'s value: ", _entry.ToCSV<double>());
      } else {
        Print(TimeCurrent(), ": ", _iter.Value() REF_DEREF GetFullName(), " requires more ticks.");
      }
    }

    if (!Platform::HadTick()) {
      Print("There are no new ticks to process.");
      return false;
    }

    return true;
  }

  /**
   * Returns list of indicators added for testing.
   */
  static ARRAY_TYPE(Ref<IndicatorData>) GetIndicators() {
    ARRAY(Ref<IndicatorData>, _indis);

    for (DictStructIterator<long long, Ref<IndicatorData>> iter = Platform::GetIndicators() PTR_DEREF Begin();
         iter.IsValid(); ++iter) {
      ArrayPush(_indis, iter.Value());
    }

    return _indis;
  }

  /*
    IndicatorData *_candles = Platform::FetchDefaultCandleIndicator(INDICATOR_TEST_SYMBOL, INDICATOR_TEST_TIMEFRAME);

    Print("Tick processed. Current OHLC = ", C_STR(_candles PTR_DEREF GetOHLC().ToCSV()));

    if (_candles PTR_DEREF IsNewBar()) {
      Print("");
      Print("[ IT WAS NEW BAR ]");
      Print("");

      for (int i = 0; i < indis.Size(); ++i) {
        IndicatorData *_indi = indis[i];

        IndicatorDataEntry _entry(_indi PTR_DEREF GetEntry());

        if (_indi PTR_DEREF Get<bool>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
          if (_entry.IsValid()) {
            PrintFormat("%s: bar %d: %s", C_STR(_indi PTR_DEREF GetFullName()), _candles PTR_DEREF GetBars(),
                        C_STR(_indi PTR_DEREF ToString()));
          }
        }
      }
    }

    return true;
  }

  */
};

#ifdef __EMSCRIPTEN__
#include <emscripten/bind.h>
#include <emscripten/val.h>

// Converts a single IndicatorDataEntry to a plain JS object:
// { timestamp: number, flags: number, values: number[] }
static emscripten::val IndicatorDataEntryToVal(IndicatorDataEntry& entry) {
  emscripten::val obj = emscripten::val::object();
  obj.set("timestamp", emscripten::val(entry.timestamp));
  obj.set("flags",     emscripten::val((unsigned int)entry.flags));
  int size = entry.GetSize();
  emscripten::val vals = emscripten::val::array();
  for (int j = 0; j < size; ++j) {
    vals.call<void>("push", emscripten::val(entry.GetValue<double>(j)));
  }
  obj.set("values", vals);
  return obj;
}

// Converts a TesterValuesColumns to a plain JS object:
// { indicator_info: { name, index, num_values, symbol, tf }, values: IndicatorDataEntry[] }
static emscripten::val TesterValuesColumnsToVal(TesterValuesColumns& cols) {
  emscripten::val result = emscripten::val::object();
  emscripten::val info = emscripten::val::object();
  info.set("name",       emscripten::val(cols.indicator_info.name));
  info.set("index",      emscripten::val(cols.indicator_info.index));
  info.set("num_values", emscripten::val(cols.indicator_info.num_values));
  info.set("symbol",     emscripten::val(cols.indicator_info.symbol));
  info.set("tf",         emscripten::val((int)cols.indicator_info.tf));
  result.set("indicator_info", info);
  emscripten::val values_arr = emscripten::val::array();
  int n = ArraySize(cols.values);
  for (int i = 0; i < n; ++i) {
    values_arr.call<void>("push", IndicatorDataEntryToVal(cols.values[i]));
  }
  result.set("values", values_arr);
  return result;
}

EMSCRIPTEN_BINDINGS(Tester) {
  emscripten::class_<Tester>("Tester")
      .constructor<>()
      .class_function("Init", &Tester::Init)
      .class_function("Add", &Tester::Add, emscripten::allow_raw_pointer<emscripten::arg<0>>())
      .class_function("AddPlatformWise", &Tester::AddPlatformWise)
      .class_function("RunAllTicks", &Tester::RunAllTicks)
      .class_function("RunTick", &Tester::RunTick)
      .class_function("FeedTickProvider", &Tester::FeedTickProvider,
                      emscripten::allow_raw_pointer<emscripten::arg<0>>())
      .class_function("FeedTickProviderCsv", &Tester::FeedTickProviderCsv,
                      emscripten::allow_raw_pointer<emscripten::arg<0>>())
      .class_function("GetTimeByScrollAndZoom", &Tester::GetTimeByScrollAndZoom)
      .class_function("GetValues", emscripten::optional_override(
                                       [](int64 timeFromMs, int64 timeToMs, int timeStepSecs,
                                          bool aggregateNoFits) -> emscripten::val {
                                         TesterValues tv = Tester::GetValues(timeFromMs, timeToMs, timeStepSecs, aggregateNoFits);
                                         emscripten::val result = emscripten::val::object();
                                         emscripten::val ts_arr = emscripten::val::array();
                                         for (int i = 0; i < ArraySize(tv.timestep_based); ++i)
                                           ts_arr.call<void>("push", TesterValuesColumnsToVal(tv.timestep_based[i]));
                                         result.set("timestep_based", ts_arr);
                                         emscripten::val loose_arr = emscripten::val::array();
                                         for (int i = 0; i < ArraySize(tv.loose); ++i)
                                           loose_arr.call<void>("push", TesterValuesColumnsToVal(tv.loose[i]));
                                         result.set("loose", loose_arr);
                                         return result;
                                       }))
      .class_function("GetValuesByParams",
                      emscripten::optional_override([](const TesterValuesFetchParams& params,
                                                       bool aggregateNoFits) -> emscripten::val {
                        TesterValues tv = Tester::GetValues(params, aggregateNoFits);
                        emscripten::val result = emscripten::val::object();
                        emscripten::val ts_arr = emscripten::val::array();
                        for (int i = 0; i < ArraySize(tv.timestep_based); ++i)
                          ts_arr.call<void>("push", TesterValuesColumnsToVal(tv.timestep_based[i]));
                        result.set("timestep_based", ts_arr);
                        emscripten::val loose_arr = emscripten::val::array();
                        for (int i = 0; i < ArraySize(tv.loose); ++i)
                          loose_arr.call<void>("push", TesterValuesColumnsToVal(tv.loose[i]));
                        result.set("loose", loose_arr);
                        return result;
                      }))
      .class_function("GetIndicatorColumnsUngrouped",
                      emscripten::optional_override([](IndicatorData* _indi, int64 timeFromMs,
                                                       int64 timeToMs) -> emscripten::val {
                        ENUM_TIMEFRAMES _tf = _indi PTR_DEREF GetTf();
                        TesterValuesColumns cols;
                        cols.indicator_info = TesterIndicatorInfo(_indi PTR_DEREF GetName(), 0, 0,
                                                                  _indi PTR_DEREF GetSymbol(), _tf);
                        Tester::GetValuesForTimeFrameBasedIndicatorUngrouped(_indi, cols);
                        return TesterValuesColumnsToVal(cols);
                      }),
                      emscripten::allow_raw_pointer<emscripten::arg<0>>())
      .class_function("GetAllIndicatorColumnsUngrouped",
                      emscripten::optional_override([](int64 timeFromMs, int64 timeToMs) -> emscripten::val {
                        emscripten::val result = emscripten::val::array();
                        for (DictIteratorBase<long long, Ref<IndicatorData>> _iter =
                                 Platform::GetIndicators() PTR_DEREF Begin();
                             _iter.IsValid(); ++_iter) {
                          IndicatorData* _indi = _iter.Value().Ptr();
                          if (_indi PTR_DEREF IsCandleIndicator() ||
                              _iter.Value() REF_DEREF IsTickIndicator()) {
                            continue;
                          }
                          ENUM_TIMEFRAMES _tf = _indi PTR_DEREF GetTf();
                          TesterValuesColumns cols;
                          cols.indicator_info = TesterIndicatorInfo(_indi PTR_DEREF GetName(), 0, 0,
                                                                    _indi PTR_DEREF GetSymbol(), _tf);
                          Tester::GetValuesForTimeFrameBasedIndicatorUngrouped(_indi, cols);
                          result.call<void>("push", TesterValuesColumnsToVal(cols));
                        }
                        return result;
                      }));
}

// struct IndicatorData[]
REGISTER_ARRAY_OF(ArrayIndicatorData, Ref<IndicatorData>, "IndicatorDataArray");

// struct TesterValuesColumns[]
REGISTER_ARRAY_OF(ArrayTesterValuesColumns, TesterValuesColumns, "TesterValuesColumnsArray");

// struct TesterValuesFetchParams
EMSCRIPTEN_BINDINGS(TesterValuesFetchParams) {
  emscripten::value_object<TesterValuesFetchParams>("TesterValuesFetchParams")
      .field("timeFromMs", &TesterValuesFetchParams::timeFromMs)
      .field("timeToMs", &TesterValuesFetchParams::timeToMs)
      .field("timeStepSecs", &TesterValuesFetchParams::timeStepSecs);
}

// struct TesterIndicatorInfo
EMSCRIPTEN_BINDINGS(TesterIndicatorInfo) {
  emscripten::value_object<TesterIndicatorInfo>("TesterIndicatorInfo")
      .field("name", &TesterIndicatorInfo::name)
      .field("index", &TesterIndicatorInfo::index)
      .field("num_values", &TesterIndicatorInfo::num_values)
      .field("symbol", &TesterIndicatorInfo::symbol)
      .field("tf", &TesterIndicatorInfo::tf);
}

#endif
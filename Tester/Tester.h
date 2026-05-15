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

#define __debug__
#define __debug_indicator__
#define __debug_emscripten__
#define __debug_verbose__

// Local includes.
#include "../Indicator/Indicator.h"
#include "../Indicator/tests/classes/IndicatorTfDummy.h"
#include "../Indicator/tests/classes/Indicators.h"
#include "../Indicators/Oscillator/Indi_RSI.h"
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

        // Now it's time to retrieve values for the given time range and aggregate them into given time-step.
        REF_TO(TesterValuesColumns) columns = values.timestep_based[_iter.Index()];
        
        columns.indicator_info = TesterIndicatorInfo(_indi PTR_DEREF GetName(), 0, 0, _indi PTR_DEREF GetSymbol(), _tf);

        GetValuesForTimeFrameBasedIndicator(_indi, _time_from_ms, _time_to_ms, _time_step_secs, columns);

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
    ENUM_TIMEFRAMES _tf = _indi PTR_DEREF GetTf();
    int64 _tf_ms       = (int64)ChartTf::TfToMs(_tf);
    int64 _time_step_ms = (int64)_time_step_secs * 1000;

    if (_tf_ms <= 0 || _time_step_ms <= 0) {
      return;
    }

    // Bar index 0 = most recent bar; higher indices are older bars.
    // _time_from_ms is the older boundary  →  higher bar index.
    // _time_to_ms   is the newer boundary  →  lower  bar index.
    int64 _bar0_time_ms  = _indi PTR_DEREF GetBarTime(0);
    int _index_oldest = (int)((_bar0_time_ms - _time_from_ms) / _tf_ms);
    int _index_newest = (int)((_bar0_time_ms - _time_to_ms)   / _tf_ms);

    if (_index_oldest < 0) _index_oldest = 0;
    if (_index_newest < 0) _index_newest = 0;
    // Guarantee oldest has the higher index regardless of parameter order.
    if (_index_oldest < _index_newest) {
      int _tmp    = _index_oldest;
      _index_oldest = _index_newest;
      _index_newest = _tmp;
    }

    // Per-mode OHLCVA aggregators for the current time-step bucket.
    // Mode count is discovered from the first valid entry.
    int _num_modes = 0;
    ARRAY(TesterValuesColumnValue, _bucket_cvs);
    bool _in_bucket   = false;
    int64 _bucket_end_ms = 0;
    string _indi_name = _indi PTR_DEREF GetName();

    // Iterate oldest→newest (descending bar index = ascending timestamp).
    for (int _idx = _index_oldest; _idx >= _index_newest; --_idx) {
      IndicatorDataEntry _entry = _indi PTR_DEREF GetEntry(_idx);
      if (!_entry.IsValid()) {
        continue;
      }

      int64 _entry_time_ms = _indi PTR_DEREF GetBarTime(_idx);

      // Initialise mode count and per-mode aggregators on the first valid entry.
      if (_num_modes == 0) {
        _num_modes = _entry.GetSize();
        if (_num_modes == 0) continue;
        ArrayResize(_bucket_cvs, _num_modes);
      }

      // Flush and advance buckets until this entry fits.
      while (_in_bucket && _entry_time_ms > _bucket_end_ms) {
        if (_bucket_cvs[0].num_values > 0) {
          for (int m = 0; m < _num_modes; ++m) {
            ArrayPush(_columns.values, _bucket_cvs[m]);
          }
        }
        _bucket_end_ms += _time_step_ms;
        for (int m = 0; m < _num_modes; ++m) {
          _bucket_cvs[m] = TesterValuesColumnValue(_indi_name, TYPE_DOUBLE);
        }
      }

      if (!_in_bucket) {
        // Align the first bucket start to the time-step grid relative to _time_from_ms.
        int64 _bucket_start = _time_from_ms + ((_entry_time_ms - _time_from_ms) / _time_step_ms) * _time_step_ms;
        _bucket_end_ms = _bucket_start + _time_step_ms - 1;
        _in_bucket     = true;
        for (int m = 0; m < _num_modes; ++m) {
          _bucket_cvs[m] = TesterValuesColumnValue(_indi_name, TYPE_DOUBLE);
        }
      }

      // Add all modes of this bar into the current bucket.
      int _entry_size = _entry.GetSize();
      for (int m = 0; m < _num_modes && m < _entry_size; ++m) {
        double _val = _entry.GetValue<double>(m);
        _bucket_cvs[m].Add(_val, _entry_time_ms);
      }
    }

    // Flush the last bucket.
    if (_in_bucket && _num_modes > 0 && _bucket_cvs[0].num_values > 0) {
      for (int m = 0; m < _num_modes; ++m) {
        ArrayPush(_columns.values, _bucket_cvs[m]);
      }
    }
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
    for (int i = 0; i < 60; ++i) {
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

// Helper: convert TesterValuesColumnValue to a plain JS object.
static emscripten::val _TesterColumnValueToVal(const TesterValuesColumnValue& v) {
  emscripten::val obj = emscripten::val::object();
  obj.set("name", emscripten::val(v.name));
  obj.set("type", emscripten::val((int)v.type));
  obj.set("time_open_ms", emscripten::val((double)v.time_open_ms));
  obj.set("time_close_ms", emscripten::val((double)v.time_close_ms));
  obj.set("value_open", emscripten::val(v.value_open));
  obj.set("value_high", emscripten::val(v.value_high));
  obj.set("value_low", emscripten::val(v.value_low));
  obj.set("value_close", emscripten::val(v.value_close));
  obj.set("value_avg", emscripten::val(v.value_avg));
  obj.set("num_values", emscripten::val(v.num_values));
  return obj;
}

// Helper: convert TesterValuesColumns to a plain JS object.
static emscripten::val _TesterColumnsToVal(const TesterValuesColumns& c) {
  emscripten::val obj = emscripten::val::object();
  emscripten::val info = emscripten::val::object();
  info.set("name", emscripten::val(c.indicator_info.name));
  info.set("index", emscripten::val(c.indicator_info.index));
  info.set("num_values", emscripten::val(c.indicator_info.num_values));
  info.set("symbol", emscripten::val(c.indicator_info.symbol));
  info.set("tf", emscripten::val((int)c.indicator_info.tf));
  obj.set("indicator_info", info);
  obj.set("time_ms", emscripten::val((double)c.time_ms));
  emscripten::val values_arr = emscripten::val::array();
  for (int i = 0; i < c.values.size(); ++i) {
    values_arr.call<void>("push", _TesterColumnValueToVal(c.values[i]));
  }
  obj.set("values", values_arr);
  return obj;
}

// Helper: convert TesterValues to a plain JS object.
static emscripten::val _TesterValuesToVal(const TesterValues& tv) {
  emscripten::val obj = emscripten::val::object();
  emscripten::val ts_arr = emscripten::val::array();
  for (int i = 0; i < tv.timestep_based.size(); ++i) {
    ts_arr.call<void>("push", _TesterColumnsToVal(tv.timestep_based[i]));
  }
  obj.set("timestep_based", ts_arr);
  emscripten::val loose_arr = emscripten::val::array();
  for (int i = 0; i < tv.loose.size(); ++i) {
    loose_arr.call<void>("push", _TesterColumnsToVal(tv.loose[i]));
  }
  obj.set("loose", loose_arr);
  return obj;
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
      .class_function("GetTimeByScrollAndZoom", &Tester::GetTimeByScrollAndZoom)
      .class_function("GetValues", emscripten::optional_override(
                                       [](int64 timeFromMs, int64 timeToMs, int timeStepSecs,
                                          bool aggregateNoFits) -> emscripten::val {
                                         return _TesterValuesToVal(
                                             Tester::GetValues(timeFromMs, timeToMs, timeStepSecs, aggregateNoFits));
                                       }))
      .class_function("GetValuesByParams",
                      emscripten::optional_override([](const TesterValuesFetchParams& params,
                                                       bool aggregateNoFits) -> emscripten::val {
                        return _TesterValuesToVal(Tester::GetValues(params, aggregateNoFits));
                      }));
}

// struct IndicatorData[]
REGISTER_ARRAY_OF(ArrayIndicatorData, Ref<IndicatorData>, "IndicatorDataArray");

// struct TesterValuesColumns[]
REGISTER_ARRAY_OF(ArrayTesterValuesColumns, TesterValuesColumns, "TesterValuesColumnsArray");

// struct TesterValuesColumnValue[]
REGISTER_ARRAY_OF(ArrayTesterValuesColumnValue, TesterValuesColumnValue, "TesterValuesColumnValueArray");

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

// struct TesterValuesColumnValue
EMSCRIPTEN_BINDINGS(TesterValuesColumnValue) {
  emscripten::value_object<TesterValuesColumnValue>("TesterValuesColumnValue")
      .field("name", &TesterValuesColumnValue::name)
      .field("type", &TesterValuesColumnValue::type)
      .field("time_open_ms", &TesterValuesColumnValue::time_open_ms)
      .field("time_close_ms", &TesterValuesColumnValue::time_close_ms)
      .field("value_open", &TesterValuesColumnValue::value_open)
      .field("value_high", &TesterValuesColumnValue::value_high)
      .field("value_low", &TesterValuesColumnValue::value_low)
      .field("value_close", &TesterValuesColumnValue::value_close)
      .field("value_avg", &TesterValuesColumnValue::value_avg)
      .field("num_values", &TesterValuesColumnValue::num_values);
}

#endif
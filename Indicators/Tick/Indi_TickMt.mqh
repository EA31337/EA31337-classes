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

/**
 * @file
 * Real tick-based indicator.
 */

#ifndef __MQL__
  // Allows the preprocessor to include a header file when it is needed.
  #pragma once
#endif

// Includes.
#include "../../Chart.struct.static.h"
#include "../../Indicator/IndicatorTick.h"
#include "../../Indicator/IndicatorTick.provider.h"

// Structs.
// Params for MT patform's tick-based indicator.
struct Indi_TickMtParams : IndicatorParams {
  Indi_TickMtParams() : IndicatorParams(INDI_TICK) {}
};

// MT platform's tick-based indicator.
class Indi_TickMt : public IndicatorTick<Indi_TickMtParams, double, ItemsHistoryTickProvider<double>> {
  // Caching _to_ms in FetchHistoryByTimeRange() in order to start from last
  // shift and don't loop over the same bars again.
  long _cache_fetch_history_shift_to_ms;
  // Shift to start with if given _to_ms is less that cached _cache_fetch_history_shift_to_ms.
  long _cache_fetch_history_shift_shift;

 public:
  Indi_TickMt(Indi_TickMtParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
              int _indi_src_mode = 0)
      : IndicatorTick(_p.symbol, _p,
                      IndicatorDataParams::GetInstance(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                      _indi_src) {
    Init();
  }
  Indi_TickMt(string _symbol, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
              int _indi_src_mode = 0, string _name = "")
      : IndicatorTick(_symbol, Indi_TickMtParams(),
                      IndicatorDataParams(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode), _indi_src) {
    Init();
  }

  /**
   * Initializes the class.
   */
  void Init() {
    _cache_fetch_history_shift_to_ms = 0;
    _cache_fetch_history_shift_shift = 0;
  }

  string GetName() override { return "Indi_TickMt"; }

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_NONE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN; }

  /**
   * Returns the indicator's struct entry for the given shift.
   *
   * @see: IndicatorDataEntry.
   *
   * @return
   *   Returns IndicatorDataEntry struct filled with indicator values.
   */
  IndicatorDataEntry GetEntry(int _index = 0) override {
    // @todo Use history to check/regenerate tick and return data entry.

    /*
      int _ishift = _index >= 0 ? (int)_index : iparams.GetShift();
      long _bar_time;
      _bar_time = GetBarTime(_ishift);

      TickAB<double> _tick = itdata.GetByKey(_bar_time);
      IndicatorDataEntry _entry = TickToEntry(_bar_time, _tick);

      if (_entry.IsValid()) {
        istate.is_changed = false;
        istate.is_ready = true;
      }

      return _entry;
    }

    void OnBecomeDataSourceFor(IndicatorData *_base_indi) override {
      // Feeding base indicator with historic entries of this indicator.
  #ifdef __debug__
      Print(GetFullName(), " became a data source for ", _base_indi.GetFullName());
  #endif

      _fetch_history_on_first_tick = true;
      */

    IndicatorDataEntry _default;
    return _default;
  }

  /**
   * Fetches historic ticks for a given time range.
   */
  virtual bool FetchHistoryByTimeRange(long _from_ms, long _to_ms, ARRAY_REF(TickTAB<double>, _out_ticks)) {
    ArrayResize(_out_ticks, 0);

#ifdef __MQL4__
    // Searching from current bar to older ones.
    int _shift;

    if (_to_ms <= _cache_fetch_history_shift_to_ms) {
      _shift = _cache_fetch_history_shift_shift;
    } else {
      _shift = 0;
    }

    string _symbol = GetSymbol();

    while (true) {
      double _time = (double)iTime(_symbol, PERIOD_M1, _shift);

      if (_time == 0) {
        // Invalid time.
        break;
      }

      long _time_ms = (long)_time * 1000;

      if (_time_ms > _to_ms) {
        // No yet get into valid time range.
        ++_shift;
        continue;
      }

      if (_time_ms < _from_ms) {
        // No more ticks.
        break;
      }

      TickTAB<double> _tick_o(_time_ms, iOpen(_Symbol, PERIOD_M1, _shift));
      TickTAB<double> _tick_h(_time_ms, iHigh(_Symbol, PERIOD_M1, _shift));
      TickTAB<double> _tick_l(_time_ms, iLow(_Symbol, PERIOD_M1, _shift));
      TickTAB<double> _tick_c(_time_ms, iClose(_Symbol, PERIOD_M1, _shift));
      ArrayPushObject(_out_ticks, _tick_o);
      ArrayPushObject(_out_ticks, _tick_h);
      ArrayPushObject(_out_ticks, _tick_l);
      ArrayPushObject(_out_ticks, _tick_c);
      ++_shift;
    }

    if (_shift != -1) {
      _cache_fetch_history_shift_to_ms = _to_ms;
      _cache_fetch_history_shift_shift = _shift;
    }

    return ArraySize(_out_ticks) != 0;
#else
    static MqlTick _tmp_ticks[];
    ArrayResize(_tmp_ticks, 0);

    int _tries = 10;

    while (_tries > 0) {
      int _num_copied = CopyTicksRange(GetSymbol(), _tmp_ticks, COPY_TICKS_INFO, _from_ms, _to_ms);

      if (_num_copied == -1) {
        ResetLastError();
        Sleep(1000);
        --_tries;
      } else {
        for (int i = 0; i < _num_copied; ++i) {
          TickTAB<double> _tick(_tmp_ticks[i]);
  #ifdef __debug_verbose__
          Print("Fetched tick at ", TimeToString(_tmp_ticks[i].time, TIME_DATE | TIME_MINUTES | TIME_SECONDS), ": ",
                _tmp_ticks[i].ask, ", ", _tmp_ticks[i].bid);
  #endif
          ArrayPushObject(_out_ticks, _tick);
        }

        return true;
      }
    }
#endif

    // To many tries. Probably no ticks at the given range.
    return false;
  }

  /**
   * Fetches historic ticks for a given index (absolute shift) range.
   */
  virtual bool FetchHistoryByIndexRange(int _index_from, int _index_to, ARRAY_REF(TickTAB<double>, _out_ticks)) {
    return false;
  }

  /**
   * Sends historic entries to listening indicators. May be overriden.
   */
  virtual void EmitHistory() {}

  void OnTick(int _global_tick_index) override {
#ifdef __MQL4__
    // Refreshes Ask/Bid constants.
    RefreshRates();
    double _ask = Ask;
    double _bid = Bid;
    long _time = TimeCurrent();
#else

  #ifdef __DISABLE

    static MqlTick _tmp_ticks[];
    // Copying only the last tick.
    int _num_copied = CopyTicks(GetSymbol(), _tmp_ticks, COPY_TICKS_INFO, 0, 1);

    if (_num_copied < 1 || _LastError != 0) {
      Print("Error. Cannot copy MT ticks via CopyTicks(). Error " + IntegerToString(_LastError));
      // DebugBreak();
      // Just emitting zeroes in case of error.
      TickAB<double> _tick(0, 0);
      IndicatorDataEntry _entry(TickToEntry(TimeCurrent(), _tick));
      EmitEntry(_entry);
      // Appending tick into the history.
      AppendEntry(_entry);
      return;
    }

    #ifdef __debug_verbose__
    Print("CpyT: ", TimeToString(_tmp_ticks[0].time, TIME_DATE | TIME_MINUTES | TIME_SECONDS), " = ", _tmp_ticks[0].bid,
          " (", _tmp_ticks[0].time, ")");
    Print("RlCl: ", TimeToString(::iTime(GetSymbol(), PERIOD_CURRENT, 0), TIME_DATE | TIME_MINUTES | TIME_SECONDS),
          " = ", ::iClose(GetSymbol(), PERIOD_CURRENT, 0));
    #endif

    double _ask = _tmp_ticks[0].ask;
    double _bid = _tmp_ticks[0].bid;

  #endif

    MqlTick _tick_data;
    SymbolInfoTick(GetSymbol(), _tick_data);

    double _ask = _tick_data.ask;
    double _bid = _tick_data.bid;

    // long _time = _tmp_ticks[0].time;
    long _time = TimeCurrent();
#endif
    TickAB<double> _tick(_ask, _bid);
    IndicatorDataEntry _entry(TickToEntry(_time, _tick));
    EmitEntry(_entry);
    // Appending tick into the history.
    AppendEntry(_entry);
  }
};

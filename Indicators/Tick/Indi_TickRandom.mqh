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

/**
 * @file
 * Random (mainly for C++ testing) tick-based indicator.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../../Indicator/IndicatorTick.h"
#include "../../Indicator/IndicatorTick.provider.h"

// Structs.
// Params for MT patform's tick-based indicator.
struct Indi_TickRandomParams : IndicatorParams {
  Indi_TickRandomParams() : IndicatorParams(INDI_TICK_RANDOM) {}
};

// MT platform's tick-based indicator.
class Indi_TickRandom : public IndicatorTick<Indi_TickRandomParams, double, ItemsHistoryTickProvider<double>> {
 public:
  Indi_TickRandom(Indi_TickRandomParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                  IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : IndicatorTick(_p.symbol, _p,
                      IndicatorDataParams::GetInstance(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                      _indi_src) {
    Init();
  }
  Indi_TickRandom(string _symbol, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                  int _indi_src_mode = 0, string _name = "")
      : IndicatorTick(_symbol, Indi_TickRandomParams(),
                      IndicatorDataParams(2, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode), _indi_src) {
    Init();
  }

  /**
   * Initializes the class.
   */
  void Init() {}

  string GetName() override { return "Indi_TickRandom"; }

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
   */
  IndicatorDataEntry GetEntry(int _index = 0) override {
    IndicatorDataEntry _default;
    return _default;
  }

  /**
   * Fetches historic ticks for a given time range.
   */
  virtual bool FetchHistoryByTimeRange(long _from_ms, long _to_ms, ARRAY_REF(TickTAB<double>, _out_ticks)) {
    // No history.
    return false;
  }

  void OnTick(int _global_tick_index) override {
    float _ask = 1.0f + (1.0f / 32767 * MathRand());
    float _bid = 1.0f + (1.0f / 32767 * MathRand());
    TickAB<double> _tick(, _bid);
    IndicatorDataEntry _entry(TickToEntry(_time, _tick));
    EmitEntry(_entry);
    // Appending tick into the history.
    AppendEntry(_entry);
  }
};

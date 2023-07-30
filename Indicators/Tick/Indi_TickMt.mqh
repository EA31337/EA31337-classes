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

// Includes.
#include "../../Indicator/IndicatorTick.h"

// Structs.
struct IndiTickMtParams : IndicatorParams {
  string symbol;
  // Struct constructor.
  IndiTickMtParams(string _symbol = NULL, int _shift = 0) : IndicatorParams(INDI_TICK) {
    SetShift(_shift);
    SetSymbol(_symbol);
  };
  IndiTickMtParams(IndiTickMtParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
  // Getters.
  string GetSymbol() { return symbol; }
  // Setters.
  void SetSymbol(string _symbol) { symbol = _symbol; }
};

/**
 * Price Indicator.
 */
class Indi_TickMt : public IndicatorTick<IndiTickMtParams, double> {
 protected:
  MqlTick tick;

 public:
  /**
   * Class constructor.
   */
  Indi_TickMt(IndiTickMtParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
              int _indi_src_mode = 0)
      : IndicatorTick<IndiTickMtParams, double>(_p, IndicatorDataParams::GetInstance(3, TYPE_DOUBLE, _idstype),
                                                _indi_src){};
  Indi_TickMt(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0, string _name = "")
      : IndicatorTick(INDI_TICK, _tf, _shift, _name) {}

  /**
   * Returns the indicator's value.
   */
  IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) {
    if (_shift == 0) {
      // Fetch a current prices of a specified symbol.
      tick = SymbolInfoStatic::GetTick(itparams.GetSymbol());
      switch (_mode) {
        case 0:
          return tick.ask;
        case 1:
          return tick.bid;
        case 2:
#ifdef __MQL4__
          return tick.volume;
#else
          return tick.volume_real;
#endif
      }
      SetUserError(ERR_INVALID_PARAMETER);
    }
    return DBL_MAX;
  }

  /**
   * Alters indicator's struct value.
   *
   * This method allows user to modify the struct entry before it's added to cache.
   * This method is called on GetEntry() right after values are set.
   */
  virtual void GetEntryAlter(IndicatorDataEntry &_entry, int _shift = 0) {
    IndicatorTick<IndiTickMtParams, double>::GetEntryAlter(_entry, _shift);
    _entry.timestamp = _entry.timestamp > 0 ? _entry.timestamp : tick.time;
  };
};

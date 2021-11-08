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
#include "../../BufferStruct.mqh"
#include "../../Indicator.mqh"
#include "../../Storage/Objects.h"

// Structs.
struct IndiTickMtParams : IndicatorParams {
  string symbol;
  // Struct constructor.
  IndiTickMtParams(string _symbol = NULL, int _shift = 0) : IndicatorParams(INDI_TICK, 3, TYPE_DOUBLE) {
    SetShift(_shift);
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
class Indi_TickMt : public Indicator<IndiTickMtParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_TickMt(IndiTickMtParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<IndiTickMtParams>(_p, _indi_src){};
  Indi_TickMt(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_TICK, _tf, _shift){};

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    MqlTick _tick = SymbolInfoStatic::GetTick(_Symbol);
    switch (_mode) {
      case 0:
        return _tick.ask;
      case 1:
        return _tick.bid;
      case 2:
#ifdef __MQL4__
        return _tick.volume;
#else
        return _tick.volume_real;
#endif
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return DBL_MAX;
  }
};

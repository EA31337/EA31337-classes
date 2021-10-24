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
#include "../BufferStruct.mqh"
#include "../Indicator.mqh"

// Structs.
struct IndiPriceChannelParams : IndicatorParams {
  unsigned int period;
  // Struct constructor.
  IndiPriceChannelParams(unsigned int _period = 22, int _shift = 0)
      : IndicatorParams(INDI_PRICE_CHANNEL, 3, TYPE_DOUBLE) {
    period = _period;
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\Price_Channel");
    SetDataSourceType(IDATA_ICUSTOM);
    shift = _shift;
  };
  IndiPriceChannelParams(IndiPriceChannelParams& _params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_PriceChannel : public Indicator<IndiPriceChannelParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_PriceChannel(IndiPriceChannelParams& _p, IndicatorBase* _indi_src = NULL)
      : Indicator<IndiPriceChannelParams>(_p, _indi_src){};
  Indi_PriceChannel(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_PRICE_CHANNEL, _tf){};

  /**
   * Returns the indicator's value.
   */
  virtual double GetValue(int _mode = 0, int _shift = 0) {
    double _value = EMPTY_VALUE;
    switch (iparams.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/,
                         0, _shift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get period.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /* Setters */

  /**
   * Set period.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }
};

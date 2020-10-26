//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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

/*
 * @file
 * Momentum oscillator.
 *
 * It helps identify the strength behind price movement.
 * We can also use to identify when a market is likely to continue in the direction of the main trend.
 * In addition, it can help to identify when the price action is losing steam to prepare for a potential trend reversal.
 */

// Includes.
#include "../Indicator.mqh"
#include "Indi_PriceFeeder.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iMomentum(string _symbol, int _tf, int _period, int _ap, int _shift) {
  return Indi_Momentum::iMomentum(_symbol, (ENUM_TIMEFRAMES)_tf, _period, (ENUM_APPLIED_PRICE)_ap, _shift);
}
#endif

// Structs.
struct MomentumParams : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  void MomentumParams(unsigned int _period, ENUM_APPLIED_PRICE _ap, int _shift = 0)
      : period(_period), applied_price(_ap) {
    itype = INDI_MOMENTUM;
    max_modes = 1;
    shift = _shift;
    SetDataValueType(TYPE_DOUBLE);
  };
  void MomentumParams(MomentumParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Momentum indicator.
 */
class Indi_Momentum : public Indicator {
 protected:
  MomentumParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_Momentum(MomentumParams &_p) : params(_p.period, _p.applied_price, _p.shift), Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_Momentum(MomentumParams &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.period, _p.applied_price, _p.shift), Indicator(INDI_MOMENTUM, _tf) {
    params = _p;
  }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/imomentum
   * - https://www.mql5.com/en/docs/indicators/imomentum
   */
  static double iMomentum(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, ENUM_APPLIED_PRICE _applied_price,
                          int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iMomentum(_symbol, _tf, _period, _applied_price, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iMomentum(_symbol, _tf, _period, _applied_price)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      } else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    int _bars_calc = BarsCalculated(_handle);
    if (GetLastError() > 0) {
      return EMPTY_VALUE;
    } else if (_bars_calc <= 2) {
      SetUserError(ERR_USER_INVALID_BUFF_NUM);
      return EMPTY_VALUE;
    }
    if (CopyBuffer(_handle, 0, _shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  static double iMomentumOnIndicator(Indicator *_indi, string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period,
                                     ENUM_APPLIED_PRICE _applied_price, int _shift = 0) {
    double _indi_value_buffer[], o, h, c, l;

    _period += 1;

    ArrayResize(_indi_value_buffer, _period);

    for (int i = 0; i < (int)_period; i++) {
      _indi.GetValueDouble4(i + _shift, o, h, c, l);
      _indi_value_buffer[i] = Chart::GetAppliedPrice(_applied_price, o, h, c, l);
    }

    double momentum = (_indi_value_buffer[0] / _indi_value_buffer[_period - 1]) * 100;

    return momentum;
  }

  static double iMomentumOnArray(double &array[], int total, int period, int shift) {
#ifdef __MQL4__
    return ::iMomentumOnArray(array, total, period, shift);
#else
    Indi_PriceFeeder indi_price_feeder(array);
    return iMomentumOnIndicator(&indi_price_feeder, NULL, NULL, period, /*unused*/ PRICE_OPEN, shift);
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        // @fixit Somehow shift isn't used neither in MT4 nor MT5.
        _value = Indi_Momentum::iMomentum(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), params.shift + _shift,
                                          GetPointer(this));
        break;
      case IDATA_INDICATOR:
        // @fixit Somehow shift isn't used neither in MT4 nor MT5.
        _value = Indi_Momentum::iMomentumOnIndicator(iparams.indi_data, GetSymbol(), GetTf(), GetPeriod(),
                                                     GetAppliedPrice(), params.shift + _shift);
        if (iparams.is_draw) {
          draw.DrawLineTo(StringFormat("%s", GetName()), GetBarTime(params.shift + _shift), _value, 1);
        }
        break;
    }
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry;
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      _entry.value.SetValue(params.idvtype, GetValue(_shift));
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.value.HasValue(params.idvtype, (double)NULL) &&
                                                   !_entry.value.HasValue(params.idvtype, EMPTY_VALUE));
      if (_entry.IsValid()) idata.Add(_entry, _bar_time);
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value.GetValueDbl(params.idvtype, _mode);
    return _param;
  }

  /* Getters */

  /**
   * Get period value.
   *
   * Averaging period (bars count) for the calculation of the price change.
   */
  unsigned int GetPeriod() { return params.period; }

  /**
   * Get applied price value.
   *
   * The desired price base for calculations.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return params.applied_price; }

  /* Setters */

  /**
   * Set period value.
   *
   * Averaging period (bars count) for the calculation of the price change.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    params.period = _period;
  }

  /**
   * Set applied price value.
   *
   * The desired price base for calculations.
   * @docs
   * - https://docs.mql4.com/constants/indicatorconstants/prices#enum_applied_price_enum
   * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    params.applied_price = _applied_price;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToCSV(params.idvtype); }
};

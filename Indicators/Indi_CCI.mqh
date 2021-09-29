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
#include "../Indicator.mqh"
#include "Indi_MA.mqh"
#include "Indi_Price.mqh"
#include "Indi_PriceFeeder.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iCCI(string _symbol, int _tf, int _period, int _ap, int _shift) {
  return Indi_CCI::iCCI(_symbol, (ENUM_TIMEFRAMES)_tf, _period, (ENUM_APPLIED_PRICE)_ap, _shift);
}
double iCCIOnArray(double &_arr[], int _total, int _period, int _shift) {
  return Indi_CCI::iCCIOnArray(_arr, _total, _period, _shift);
}
#endif

// Structs.
struct CCIParams : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  void CCIParams(unsigned int _period = 14, ENUM_APPLIED_PRICE _applied_price = PRICE_OPEN, int _shift = 0)
      : period(_period), applied_price(_applied_price) {
    itype = INDI_CCI;
    max_modes = 1;
    shift = _shift;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\CCI");
  };
};

/**
 * Implements the Commodity Channel Index indicator.
 */
class Indi_CCI : public Indicator<CCIParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_CCI(CCIParams &_p) : Indicator<CCIParams>(_p) {}
  Indi_CCI(ENUM_TIMEFRAMES _tf) : Indicator(INDI_CCI, _tf) {}

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/icci
   * - https://www.mql5.com/en/docs/indicators/icci
   */
  static double iCCI(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, ENUM_APPLIED_PRICE _applied_price,
                     int _shift = 0, Indicator<CCIParams> *_obj = NULL) {
#ifdef __MQL4__
    return ::iCCI(_symbol, _tf, _period, _applied_price, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iCCI(_symbol, _tf, _period, _applied_price)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      } else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    if (Terminal::IsVisualMode()) {
      // To avoid error 4806 (ERR_INDICATOR_DATA_NOT_FOUND),
      // we check the number of calculated data only in visual mode.
      int _bars_calc = BarsCalculated(_handle);
      if (GetLastError() > 0) {
        return EMPTY_VALUE;
      } else if (_bars_calc <= 2) {
        SetUserError(ERR_USER_INVALID_BUFF_NUM);
        return EMPTY_VALUE;
      }
    }
    if (CopyBuffer(_handle, 0, _shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  static double iCCIOnIndicator(IndicatorBase *_indi, string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period,
                                int _mode, int _shift = 0) {
    _indi.ValidateDataSourceMode(_mode);

    double _indi_value_buffer[];
    IndicatorDataEntry _entry(_indi.GetModeCount());

    ArrayResize(_indi_value_buffer, _period);

    for (int i = _shift; i < (int)_shift + (int)_period; i++) {
      // Getting value from single, selected buffer.
      _indi_value_buffer[i - _shift] = _indi[i].GetValue<double>(_mode);
    }

    double d;
    double d_mul = 0.015 / _period;

    double sp, d_buf, m_buf, cci;

    sp = Indi_MA::SimpleMA(0, _period, _indi_value_buffer);
    d = 0.0;

    for (int j = 0; j < (int)_period; ++j) {
      d += MathAbs(_indi_value_buffer[j] - sp);
    }

    d_buf = d * d_mul;
    m_buf = _indi_value_buffer[0] - sp;

    if (d_buf != 0.0)
      cci = m_buf / d_buf;
    else
      cci = 0.0;

    return cci;
  }

  /**
   * CCI on array.
   */
  static double iCCIOnArray(double &array[], int total, int period, int shift) {
#ifdef __MQL4__
    return ::iCCIOnArray(array, total, period, shift);
#else
    Indi_PriceFeeder indi_price_feeder(array);
    return iCCIOnIndicator(&indi_price_feeder, NULL, NULL, period, /*unused*/ PRICE_OPEN, shift);
#endif
  }

  /**
   * Returns the indicator's value.
   *
   * For IDATA_ICUSTOM mode, use those externs:
   *
   * extern unsigned int period;
   * extern ENUM_APPLIED_PRICE applied_price; // Required only for MQL4.
   *
   * Also, remember to use iparams.SetCustomIndicatorName(name) method to choose
   * indicator name, e.g.,: iparams.SetCustomIndicatorName("Examples\\CCI");
   *
   * Note that in MQL5 Applied Price must be passed as the last parameter
   * (before mode and shift).
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        // @fixit Somehow shift isn't used neither in MT4 nor MT5.
        _value =
            Indi_CCI::iCCI(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _shift /* + iparams.shift*/, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.custom_indi_name, /* [ */ GetPeriod(),
                         GetAppliedPrice() /* ] */, 0, _shift);
        break;
      case IDATA_INDICATOR:
        ValidateSelectedDataSource();

        // @fixit Somehow shift isn't used neither in MT4 nor MT5.
        _value = Indi_CCI::iCCIOnIndicator(GetDataSource(), GetSymbol(), GetTf(), GetPeriod(), GetDataSourceMode(),
                                           _shift /* + iparams.shift*/);
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
    IndicatorDataEntry _entry(iparams.GetMaxModes());
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      _entry.values[0] = GetValue(0);
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE));
      if (_entry.IsValid()) {
        _entry.AddFlags(_entry.GetDataTypeFlag(iparams.GetDataValueType()));
        idata.Add(_entry, _bar_time);
      }
    }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    GetEntry(_shift).values[_mode].Get(_param.double_value);
    return _param;
  }

  /* Getters */

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /**
   * Get applied price value.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return iparams.applied_price; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }

  /**
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};

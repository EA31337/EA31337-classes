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

// Includes.
#include "../Indicator.mqh"

// Structs.
struct CCIParams : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  void CCIParams(unsigned int _period, ENUM_APPLIED_PRICE _applied_price)
      : period(_period), applied_price(_applied_price) {
    itype = INDI_CCI;
    max_modes = 1;
    SetDataValueType(TYPE_DOUBLE);
  };
};

/**
 * Implements the Commodity Channel Index indicator.
 */
class Indi_CCI : public Indicator {
 public:
  CCIParams params;

  /**
   * Class constructor.
   */
  Indi_CCI(CCIParams &_p) : params(_p.period, _p.applied_price), Indicator((IndicatorParams)_p) { params = _p; }
  Indi_CCI(CCIParams &_p, ENUM_TIMEFRAMES _tf) : params(_p.period, _p.applied_price), Indicator(INDI_CCI, _tf) {
    params = _p;
  }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/icci
   * - https://www.mql5.com/en/docs/indicators/icci
   */
  static double iCCI(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period,
                     ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW,
                                                         // PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
                     int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iCCI(_symbol, _tf, _period, _applied_price, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iCCI(_symbol, _tf, _period, _applied_price)) == INVALID_HANDLE) {
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

  /**
   * iCCIOnArray() is based on SMA price and uses High, Low and Close prices.
   * To use CCI on custom, prepared data, use iCCIOnArrayCustom() which expects
   * already SMA-ed input array.
   */
  
  static double iCCIOnArray(double& array[], int total, int period, int shift) {
    int i;
    double sum_tp_n = 0;
    
    double tp = (Chart::iHigh(NULL, 0, shift + i) + Chart::iLow(NULL, 0, shift + i) + Chart::iClose(NULL, 0, shift + i)) / 3;
    
    // TP = (HIGH + LOW + CLOSE) / 3
    for (i = 0; i < period; ++i) {
      
      
    }
     
    // SMA(TP, N) = SUM[TP, N] / N
    double sma_tp_n = sum_tp_n / period;
    
    // D = TP - SMA(TP, N)
    double d = tp / sma_tp_n;
    
    double sum_d_n = 0;
    
    // SMA(D, N) = SUM[D, N] / N
    double sma_d_n = sum_d_n / period;
  
    return 0;    
  }
  
  static double iCCIOnArrayCustom(double& averaged_array[], int total, int period, int shift) {
    return 0;
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
        _value = Indi_CCI::iCCI(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _shift, GetPointer(this));
        break;
      case IDATA_INDICATOR:
//        _value = Indi_CCI::iCCIOnIndicator(GetSymbol(), GetTf(), GetPeriod(), GetAppliedPrice(), _shift, GetPointer(this));
//                                           _shift, GetPointer(this));
        if (iparams.is_draw) {
          draw.DrawLineTo(StringFormat("%s_%s", GetName(), IntegerToString(params.idstype)), GetBarTime(_shift), _value, 1);
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
   */
  unsigned int GetPeriod() { return params.period; }

  /**
   * Get applied price value.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return params.applied_price; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    params.period = _period;
  }

  /**
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    params.applied_price = _applied_price;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.idvtype); }
};

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

// Prevents processing this includes file for the second time.
#ifndef INDI_DEMA_MQH
#define INDI_DEMA_MQH

// Includes.
#include "../Dict.mqh"
#include "../DictObject.mqh"
#include "../Indicator.mqh"
#include "../Refs.mqh"
#include "../String.mqh"
#include "../ValueStorage.h"
#include "../Indicators/Indi_MA.mqh"
#include "../Indicators/Indi_Price.mqh"

// Structs.
struct DEMAParams : IndicatorParams {
  int ma_shift;
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  void DEMAParams(unsigned int _period, int _ma_shift, ENUM_APPLIED_PRICE _ap, int _shift = 0)
      : period(_period), ma_shift(_ma_shift), applied_price(_ap) {
    itype = INDI_DEMA;
    max_modes = 3;
    shift = _shift;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_PRICE);
    SetCustomIndicatorName("Examples\\DEMA");
  };
  void DEMAParams(DEMAParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Moving Average indicator.
 */
class Indi_DEMA : public Indicator {
 protected:
  DEMAParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_DEMA(DEMAParams &_p)
      : params(_p.period, _p.ma_shift, _p.applied_price, _p.shift), Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_DEMA(DEMAParams &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.period, _p.ma_shift, _p.applied_price, _p.shift), Indicator(INDI_DEMA, _tf) {
    params = _p;
  }

  /**
   * Updates the indicator value.
   *
   * @docs
   * - https://www.mql5.com/en/docs/indicators/IDEMA
   */
  static double iDEMA(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, unsigned int _ma_shift,
                      ENUM_APPLIED_PRICE _applied_price, int _shift = 0, int _mode = 0, Indicator *_obj = NULL) {
    ResetLastError();
#ifdef __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iDEMA(_symbol, _tf, _period, _ma_shift, _applied_price)) == INVALID_HANDLE) {
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
    if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#else
  // Returning iDEMAOnIndicator over Indi_Price for a given applied price.
  
  PriceIndiParams _price_params(_applied_price);
  Indi_Price _indi_price(_price_params);
  
  // Cache used to store indicator's buffers for later reuse.
  
  // 
  ValueStorage& _price = _indi_price.GetValueStorage(PRICE_CLOSE);
  IndicatorCalculateCache

  static IndicatorCalculateCache _cache();
  
  int prev_calculated = Indi_DEMA::Calculate(total, cache.prev_calculated, 0, price, cache.buffer1, ma_method, period);
  
  // Note that SetPrevCalculated() reverts back price array to previous "as series" state.
  cache.SetPrevCalculated(price, prev_calculated);

  // Returns value from first calculation buffer (cache's buffer1).
  return cache.GetValue(1, shift + ma_shift);
  

  
  return Indi_DEMA::iDEMAOnIndicator(&_indi_price, _symbol, _tf, _period, _ma_shift, _shift);
#endif
  }

  static double iDEMAOnIndicator(Indicator *_indi, string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _ma_period,
                               unsigned int _ma_shift, int _shift = 0) {
    return 1.0011;
  }
  
  static int Calculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                ValueStorage<double> &price[], int InpPeriodEMA, ValueStorage<double> &DemaBuffer[], ValueStorage<double> &Ema[], ValueStorage<double> &EmaOfEma[])
  {
   if(rates_total<2*InpPeriodEMA-2)
      return(0);

   int start;
   if(prev_calculated==0)
      start=0;
   else
      start=prev_calculated-1;

   Indi_MA::ExponentialMAOnBuffer(rates_total,prev_calculated,0,InpPeriodEMA,price,Ema);

   Indi_MA::ExponentialMAOnBuffer(rates_total,prev_calculated,InpPeriodEMA-1,InpPeriodEMA,Ema,EmaOfEma);

   for(int i=start; i<rates_total && !IsStopped(); i++)
      DemaBuffer[i]=2.0*Ema[i]-EmaOfEma[i];

   return(rates_total);
  }


  /**


  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0, int _mode = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    
    if (params.idstype == IDATA_BUILTIN) {
      IndiPriceParams _price_params();
      Indi_Price _price(_price_params);
    }
    else
    if (params.idstype == IDATA_INDICATOR) {
    }
    
    switch (params.idstype) {
      case IDATA_BUILTIN:
        // We're getting DEMA from Price indicator.
        
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = Indi_DEMA::iDEMA(Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), GetPeriod(),
                                  GetMAShift(), GetAppliedPrice(), _shift, _mode, GetPointer(this));
        break;
      case IDATA_ICUSTOM:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value =
            iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                    params.custom_indi_name, /*[*/ GetPeriod(), GetMAShift(), GetAppliedPrice() /*]*/, _mode, _shift);
        break;
      case IDATA_INDICATOR:
        // Calculating DEMA value from specified indicator.
        
        _value = Indi_DEMA::iDEMAOnIndicator(params.GetTargetIndicator(), Get<string>(CHART_PARAM_SYMBOL),
        Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), GetPeriod(), GetMAShift(), _shift, GetPointer(this));
        /
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
    IndicatorDataEntry _entry(params.max_modes);
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (int _mode = 0; _mode < (int)params.max_modes; _mode++) {
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
      bool _b1 = _entry.values[0] > 0;
      bool _b2 = _entry.values[0] < DBL_MAX;
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _entry.values[0] > 0 && _entry.values[0] < DBL_MAX);
      if (_entry.IsValid()) {
        _entry.AddFlags(_entry.GetDataTypeFlag(params.GetDataValueType()));
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
   *
   * Averaging period for the calculation of the moving average.
   */
  unsigned int GetPeriod() { return params.period; }

  /**
   * Get DEMA shift value.
   *
   * Indicators line offset relate to the chart by timeframe.
   */
  unsigned int GetMAShift() { return params.ma_shift; }

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
   * Averaging period for the calculation of the moving average.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    params.period = _period;
  }

  /**
   * Set DEMA shift value.
   */
  void SetMAShift(int _ma_shift) {
    istate.is_changed = true;
    params.ma_shift = _ma_shift;
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
};
#endif  // INDI_DEMA_MQH

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
#include "../Indicators/Indi_MA.mqh"
#include "../Indicators/Indi_Price.mqh"
#include "../Refs.mqh"
#include "../Storage/Objects.h"
#include "../Storage/ValueStorage.h"
#include "../String.mqh"

// Structs.
struct DEMAParams : IndicatorParams {
  int ma_shift;
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  DEMAParams(unsigned int _period = 14, int _ma_shift = 0, ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0)
      : period(_period), ma_shift(_ma_shift), applied_price(_ap), IndicatorParams(INDI_DEMA, 1, TYPE_DOUBLE) {
    SetCustomIndicatorName("Examples\\DEMA");
    SetDataValueRange(IDATA_RANGE_PRICE);
    SetShift(_shift);
    switch (idstype) {
      case IDATA_ICUSTOM:
        if (custom_indi_name == "") {
          SetCustomIndicatorName("Examples\\DEMA");
        }
        break;
    }
  };
  DEMAParams(DEMAParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements the Moving Average indicator.
 */
class Indi_DEMA : public Indicator<DEMAParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_DEMA(DEMAParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<DEMAParams>(_p, _indi_src) {}
  Indi_DEMA(ENUM_TIMEFRAMES _tf) : Indicator(INDI_DEMA, _tf) {}

  /**
   * Updates the indicator value.
   *
   * @docs
   * - https://www.mql5.com/en/docs/indicators/IDEMA
   */
  static double iDEMA(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, unsigned int _ma_shift,
                      ENUM_APPLIED_PRICE _applied_price, int _shift = 0, int _mode = 0, IndicatorBase *_obj = NULL) {
    ResetLastError();
#ifdef __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
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
    Indi_Price *_indi_price = Indi_Price::GetCached(_symbol, _tf, _shift);
    // Note that _applied_price and Indi_Price mode indices are compatible.
    return Indi_DEMA::iDEMAOnIndicator(_indi_price.GetCache(), _indi_price, 0, _period, _ma_shift, _shift);
#endif
  }

  static double iDEMAOnIndicator(IndicatorCalculateCache<double> *cache, IndicatorBase *_indi, int indi_mode,
                                 unsigned int ma_period, unsigned int ma_shift, int shift) {
    return iDEMAOnArray(_indi.GetValueStorage(indi_mode), 0, ma_period, ma_shift, shift, cache);
  }

  static double iDEMAOnArray(ValueStorage<double> &price, int total, unsigned int ma_period, unsigned int ma_shift,
                             int shift, IndicatorCalculateCache<double> *cache = NULL, bool recalculate = false) {
    if (cache == NULL) {
      Print("iDEMAOnArray() cannot yet work without cache object!");
      DebugBreak();
      return 0.0f;
    }

    cache.SetPriceBuffer(price);

    if (!cache.HasBuffers()) {
      cache.AddBuffer<NativeValueStorage<double>>(3);  // 3 buffers.
    }

    if (recalculate) {
      // We don't want to continue calculations, but to recalculate previous one.
      cache.ResetPrevCalculated();
    }

    cache.SetPrevCalculated(Indi_DEMA::Calculate(cache.GetTotal(), cache.GetPrevCalculated(), 0, cache.GetPriceBuffer(),
                                                 ma_period, cache.GetBuffer<double>(0), cache.GetBuffer<double>(1),
                                                 cache.GetBuffer<double>(2)));

    return cache.GetTailValue<double>(0, ma_shift + shift);
  }

  static int Calculate(const int rates_total, const int prev_calculated, const int begin, ValueStorage<double> &price,
                       int InpPeriodEMA, ValueStorage<double> &DemaBuffer, ValueStorage<double> &Ema,
                       ValueStorage<double> &EmaOfEma) {
    if (rates_total < 2 * InpPeriodEMA - 2) return (0);

    int start;
    if (prev_calculated == 0)
      start = 0;
    else
      start = prev_calculated - 1;

    Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, 0, InpPeriodEMA, price, Ema);

    Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, InpPeriodEMA - 1, InpPeriodEMA, Ema, EmaOfEma);

    for (int i = start; i < rates_total && !IsStopped(); i++) DemaBuffer[i] = 2.0 * Ema[i].Get() - EmaOfEma[i].Get();

    return (rates_total);
  }

  /**
   * Returns the indicator's value.
   */
  virtual double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;

    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        // We're getting DEMA from Price indicator.

        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = Indi_DEMA::iDEMA(_Symbol, GetTf(), GetPeriod(), GetMAShift(), GetAppliedPrice(), _shift, _mode,
                                  GetPointer(this));
        break;
      case IDATA_ICUSTOM:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = iCustom(istate.handle, _Symbol, GetTf(), iparams.custom_indi_name, /*[*/ GetPeriod(), GetMAShift(),
                         GetAppliedPrice() /*]*/, _mode, _shift);
        break;
      case IDATA_INDICATOR:
        // Calculating DEMA value from specified indicator.
        _value = Indi_DEMA::iDEMAOnIndicator(GetCache(), GetDataSource(), GetDataSourceMode(), GetPeriod(),
                                             GetMAShift(), _shift);
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
      for (int _mode = 0; _mode < (int)iparams.GetMaxModes(); _mode++) {
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, IsValidEntry(_entry));
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

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return Indicator<DEMAParams>::IsValidEntry(_entry) && _entry.IsGt<double>(0) && _entry.IsLt<double>(DBL_MAX);
  }

  /* Getters */

  /**
   * Get period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /**
   * Get DEMA shift value.
   *
   * Indicators line offset relate to the chart by timeframe.
   */
  unsigned int GetMAShift() { return iparams.ma_shift; }

  /**
   * Get applied price value.
   *
   * The desired price base for calculations.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return iparams.applied_price; }

  /* Setters */

  /**
   * Set period value.
   *
   * Averaging period for the calculation of the moving average.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }

  /**
   * Set DEMA shift value.
   */
  void SetMAShift(int _ma_shift) {
    istate.is_changed = true;
    iparams.ma_shift = _ma_shift;
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
    iparams.applied_price = _applied_price;
  }
};
#endif  // INDI_DEMA_MQH

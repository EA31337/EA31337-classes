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

// Defines.
#ifdef __MQL5__
#define INDI_DEMA_DEFAULT_IDSTYPE IDATA_BUILTIN
#else
#define INDI_DEMA_DEFAULT_IDSTYPE IDATA_ONCALCULATE
#endif

// Includes.
#include "../Dict.mqh"
#include "../DictObject.mqh"
#include "../Indicator/Indicator.h"
#include "../Refs.mqh"
#include "../Storage/Objects.h"
#include "../Storage/ValueStorage.h"
#include "../String.mqh"
#include "Indi_MA.mqh"
#include "Price/Indi_Price.mqh"

// Structs.
struct IndiDEMAParams : IndicatorParams {
  int ma_shift;
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  IndiDEMAParams(unsigned int _period = 14, int _ma_shift = 0, ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0)
      : period(_period), ma_shift(_ma_shift), applied_price(_ap), IndicatorParams(INDI_DEMA) {
    SetCustomIndicatorName("Examples\\DEMA");
    SetShift(_shift);
    if (custom_indi_name == "") {
      SetCustomIndicatorName("Examples\\DEMA");
    }
  };
  IndiDEMAParams(IndiDEMAParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Moving Average indicator.
 */
class Indi_DEMA : public Indicator<IndiDEMAParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_DEMA(IndiDEMAParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = INDI_DEMA_DEFAULT_IDSTYPE,
            IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src) {}
  Indi_DEMA(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = INDI_DEMA_DEFAULT_IDSTYPE,
            IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(IndiDEMAParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
                  _indi_src) {}

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override {
    return INDI_SUITABLE_DS_TYPE_AP | INDI_SUITABLE_DS_TYPE_BASE_ONLY;
  }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override {
    return IDATA_BUILTIN | IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR;
  }

  /**
   * Updates the indicator value.
   *
   * @docs
   * - https://www.mql5.com/en/docs/indicators/IDEMA
   */
  static double iDEMA(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, unsigned int _ma_shift,
                      ENUM_APPLIED_PRICE _applied_price, int _shift = 0, int _mode = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
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
      return ArraySize(_res) > 0 ? _res[0] : EMPTY_VALUE;
    }
    return _res[0];
#else
    if (_obj == nullptr) {
      Print(
          "Indi_DEMA::iDEMA() can work without supplying pointer to IndicatorData only in MQL5. In this platform the "
          "pointer is required.");
      DebugBreak();
      return 0;
    }

    return iDEMAOnIndicator(_obj, _period, _ma_shift, _applied_price, _mode, _shift);
#endif
  }

  static double iDEMAOnArray(INDICATOR_CALCULATE_PARAMS_SHORT, unsigned int _ma_period, unsigned int _ma_shift,
                             int _mode, int _shift, IndicatorCalculateCache<double> *_cache = NULL,
                             bool _recalculate = false) {
    if (_cache == nullptr) {
      Print("iDEMAOnArray() cannot yet work without cache object!");
      DebugBreak();
      return 0.0f;
    }

    _cache.SetPriceBuffer(_price);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(3);  // 3 buffers.
    }

    if (_recalculate) {
      // We don't want to continue calculations, but to recalculate previous one.
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_DEMA::Calculate(INDICATOR_CALCULATE_GET_PARAMS_SHORT, _cache.GetBuffer<double>(0),
                                                  _cache.GetBuffer<double>(1), _cache.GetBuffer<double>(2),
                                                  _ma_period));

    return _cache.GetTailValue<double>(0, _ma_shift + _shift);
  }

  /**
   * On-indicator version of DEMA.
   */
  static double iDEMAOnIndicator(IndicatorData *_indi, int _period, int _ma_shift, ENUM_APPLIED_PRICE _ap,
                                 int _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT(_indi, _ap, Util::MakeKey(_period, _ma_shift));
    return iDEMAOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_SHORT, _period, _ma_shift, _mode, _shift, _cache);
  }

  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_SHORT, ValueStorage<double> &DemaBuffer,
                       ValueStorage<double> &Ema, ValueStorage<double> &EmaOfEma, int InpPeriodEMA) {
    if (rates_total < 2 * InpPeriodEMA - 1) {
      return 0;
    }

    int start;
    if (prev_calculated == 0)
      start = 0;
    else
      start = prev_calculated - 1;

    Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, 0, InpPeriodEMA, price, Ema);

    Indi_MA::ExponentialMAOnBuffer(rates_total, prev_calculated, InpPeriodEMA - 1, InpPeriodEMA, Ema, EmaOfEma);

    for (int i = start; i < rates_total && !IsStopped(); i++) {
      DemaBuffer[i] = 2.0 * Ema[i].Get() - EmaOfEma[i].Get();
    }

    return (rates_total);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();

    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        // We're getting DEMA from Price indicator.

        _value = Indi_DEMA::iDEMA(GetSymbol(), GetTf(), /*[*/ GetPeriod(), GetMAShift(), GetAppliedPrice() /*]*/,
                                  _ishift, _mode, THIS_PTR);
        break;
      case IDATA_ONCALCULATE:
        _value = Indi_DEMA::iDEMAOnIndicator(GetDataSource(), /*[*/ GetPeriod(), GetMAShift(), GetAppliedPrice() /*]*/,
                                             _mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.custom_indi_name, /*[*/ GetPeriod(), GetMAShift(),
                         GetAppliedPrice() /*]*/, _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        // Calculating DEMA value from specified indicator.
        _value = Indi_DEMA::iDEMAOnIndicator(GetDataSource(), /*[*/ GetPeriod(), GetMAShift(), GetAppliedPrice() /*]*/,
                                             _mode, _ishift);
        break;
    }
    return _value;
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return Indicator<IndiDEMAParams>::IsValidEntry(_entry) && _entry.IsGt<double>(0) && _entry.IsLt<double>(DBL_MAX);
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
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return iparams.applied_price; }

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

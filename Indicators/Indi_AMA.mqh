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
#include "../Indicators/Indi_Price.mqh"
#include "../ValueStorage.h"
#include "../ValueStorage.price.h"

// Structs.
struct IndiAMAParams : IndicatorParams {
  unsigned int period;
  unsigned int fast_period;
  unsigned int slow_period;
  unsigned int ama_shift;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  void IndiAMAParams(int _period = 10, int _fast_period = 2, int _slow_period = 30, int _ama_shift = 0,
                     ENUM_APPLIED_PRICE _ap = PRICE_TYPICAL, int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT,
                     ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN)
      : period(_period),
        fast_period(_fast_period),
        slow_period(_slow_period),
        ama_shift(_ama_shift),
        applied_price(_ap) {
    itype = itype == INDI_NONE ? INDI_AMA : itype;
    SetDataSourceType(_idstype);
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_PRICE);
    SetMaxModes(1);
    SetShift(_shift);
    tf = _tf;
    switch (idstype) {
      case IDATA_ICUSTOM:
        if (custom_indi_name == "") {
          SetCustomIndicatorName("Examples\\AMA");
        }
        break;
      case IDATA_INDICATOR:
        if (GetDataSource() == NULL) {
          SetDataSource(Indi_Price::GetCached(_shift, _tf, _ap, _period), false);
          SetDataSourceMode(0);
        }
        break;
    }
  };
  void IndiAMAParams(IndiAMAParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the AMA indicator.
 */
class Indi_AMA : public Indicator {
 protected:
  IndiAMAParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_AMA(IndiAMAParams &_params) : params(_params.period), Indicator((IndicatorParams)_params) { params = _params; };
  Indi_AMA(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_AMA, _tf) { params.tf = _tf; };

  /**
   * Built-in version of AMA.
   */
  static double iAMA(string _symbol, ENUM_TIMEFRAMES _tf, int _ama_period, int _fast_ema_period, int _slow_ema_period,
                     int _ama_shift, ENUM_APPLIED_PRICE _ap, int _mode = 0, int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(
        ::iAMA(_symbol, _tf, _ama_period, _fast_ema_period, _slow_ema_period, _ama_shift, _ap), _mode, _shift);
#else
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT(
        _symbol, _tf, _ap,
        Util::MakeKey("INDI_AMA", _ama_period, _fast_ema_period, _slow_ema_period, _ama_shift, (int)_ap));
    return iAMAOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_SHORT, _ama_period, _fast_ema_period, _slow_ema_period,
                       _ama_shift, _mode, _shift, _cache);
#endif
  }

  /**
   * Calculates AMA on the array of values.
   */
  static double iAMAOnArray(INDICATOR_CALCULATE_PARAMS_SHORT, int _ama_period, int _fast_ema_period,
                            int _slow_ema_period, int _ama_shift, int _mode, int _shift,
                            IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_price);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(1);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_AMA::Calculate(INDICATOR_CALCULATE_GET_PARAMS_SHORT, _cache.GetBuffer<double>(0),
                                                 _ama_period, _fast_ema_period, _slow_ema_period, _ama_shift));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnInit() method for AMA indicator.
   */
  static void CalculateInit(int InpPeriodAMA, int InpFastPeriodEMA, int InpSlowPeriodEMA, int InpShiftAMA,
                            double &ExtFastSC, double &ExtSlowSC, int &ExtPeriodAMA, int &ExtSlowPeriodEMA,
                            int &ExtFastPeriodEMA) {
    //--- check for input values
    if (InpPeriodAMA <= 0) {
      ExtPeriodAMA = 10;
      PrintFormat(
          "Input parameter InpPeriodAMA has incorrect value (%d). Indicator will use value %d for calculations.",
          InpPeriodAMA, ExtPeriodAMA);
    } else
      ExtPeriodAMA = InpPeriodAMA;
    if (InpSlowPeriodEMA <= 0) {
      ExtSlowPeriodEMA = 30;
      PrintFormat(
          "Input parameter InpSlowPeriodEMA has incorrect value (%d). Indicator will use value %d for calculations.",
          InpSlowPeriodEMA, ExtSlowPeriodEMA);
    } else
      ExtSlowPeriodEMA = InpSlowPeriodEMA;
    if (InpFastPeriodEMA <= 0) {
      ExtFastPeriodEMA = 2;
      PrintFormat(
          "Input parameter InpFastPeriodEMA has incorrect value (%d). Indicator will use value %d for calculations.",
          InpFastPeriodEMA, ExtFastPeriodEMA);
    } else
      ExtFastPeriodEMA = InpFastPeriodEMA;

    //--- calculate ExtFastSC & ExtSlowSC
    ExtFastSC = 2.0 / (ExtFastPeriodEMA + 1.0);
    ExtSlowSC = 2.0 / (ExtSlowPeriodEMA + 1.0);
  }

  /**
   * OnCalculate() method for AMA indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_SHORT, ValueStorage<double> &ExtAMABuffer, int InpPeriodAMA,
                       int InpFastPeriodEMA, int InpSlowPeriodEMA, int InpShiftAMA) {
    double ExtFastSC;
    double ExtSlowSC;
    int ExtPeriodAMA;
    int ExtSlowPeriodEMA;
    int ExtFastPeriodEMA;

    CalculateInit(InpPeriodAMA, InpFastPeriodEMA, InpSlowPeriodEMA, InpShiftAMA, ExtFastSC, ExtSlowSC, ExtPeriodAMA,
                  ExtSlowPeriodEMA, ExtFastPeriodEMA);

    int i;
    //--- check for rates count
    if (rates_total < ExtPeriodAMA + begin) return (0);
    //--- draw begin may be corrected
    if (begin != 0) PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, ExtPeriodAMA + begin);
    //--- detect position
    int pos = prev_calculated - 1;
    //--- first calculations
    if (pos < ExtPeriodAMA + begin) {
      pos = ExtPeriodAMA + begin;
      for (i = 0; i < pos - 1; i++) ExtAMABuffer[i] = 0.0;

      ExtAMABuffer[pos - 1] = price[pos - 1];
    }
    //--- main cycle
    for (i = pos; i < rates_total && !IsStopped(); i++) {
      //--- calculate SSC
      double currentSSC = (CalculateER(i, price, ExtPeriodAMA) * (ExtFastSC - ExtSlowSC)) + ExtSlowSC;
      //--- calculate AMA
      double prevAMA = ExtAMABuffer[i - 1].Get();

      //      Print(price[i].Get(), " == ", iOpen(NULL, 0, 2981 - (i)));

      ExtAMABuffer[i] = MathPow(currentSSC, 2) * (price[i] - prevAMA) + prevAMA;
    }
    //--- return value of prev_calculated for next call
    return (rates_total);
  }

  /**
   * Calculate ER value
   */
  static double CalculateER(const int pos, ValueStorage<double> &price, int ExtPeriodAMA) {
    double signal = MathAbs(price[pos] - price[pos - ExtPeriodAMA]);
    double noise = 0.0;
    for (int delta = 0; delta < ExtPeriodAMA; delta++) noise += MathAbs(price[pos - delta] - price[pos - delta - 1]);
    if (noise != 0.0) return (signal / noise);
    return (0.0);
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_AMA::iAMA(GetSymbol(), GetTf(), /*[*/ GetPeriod(), GetFastPeriod(), GetSlowPeriod(),
                                GetAMAShift(), GetAppliedPrice() /*]*/, _mode, _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.GetCustomIndicatorName(), /*[*/ GetPeriod(),
                         GetFastPeriod(), GetSlowPeriod(), GetAMAShift() /*]*/, _mode, _shift);

        break;
      case IDATA_INDICATOR:
        // @todo
        SetUserError(ERR_INVALID_PARAMETER);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
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
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE));
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
    _param.double_value = GetEntry(_shift)[_mode];
    return _param;
  }

  /* Getters */

  /**
   * Get AMA shift.
   */
  unsigned int GetAMAShift() { return params.ama_shift; }

  /**
   * Get period.
   */
  unsigned int GetPeriod() { return params.period; }

  /**
   * Get fast period.
   */
  unsigned int GetFastPeriod() { return params.fast_period; }

  /**
   * Get slow period.
   */
  unsigned int GetSlowPeriod() { return params.slow_period; }

  /**
   * Get applied price.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return params.applied_price; }

  /* Setters */

  /**
   * Set AMA shift.
   */
  void SetAMAShift(unsigned int _ama_shift) {
    istate.is_changed = true;
    params.ama_shift = _ama_shift;
  }

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    params.period = _period;
  }

  /**
   * Set fast period.
   */
  void SetFastPeriod(unsigned int _fast_period) {
    istate.is_changed = true;
    params.fast_period = _fast_period;
  }

  /**
   * Set slow period.
   */
  void SetSlowPeriod(unsigned int _slow_period) {
    istate.is_changed = true;
    params.slow_period = _slow_period;
  }

  /**
   * Set applied price.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    params.applied_price = _applied_price;
  }
};

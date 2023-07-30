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
#include "../BufferStruct.mqh"
#include "../Indicator/IndicatorTickOrCandleSource.h"
#include "../Indicator/tests/classes/IndicatorTfDummy.h"
#include "../Storage/ValueStorage.h"
#include "../Storage/ValueStorage.price.h"
#include "Price/Indi_Price.mqh"

// Structs.
struct IndiAMAParams : IndicatorParams {
  unsigned int period;
  unsigned int fast_period;
  unsigned int slow_period;
  unsigned int ama_shift;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  IndiAMAParams(int _period = 10, int _fast_period = 2, int _slow_period = 30, int _ama_shift = 0,
                ENUM_APPLIED_PRICE _ap = PRICE_OPEN, int _shift = 0)
      : period(_period),
        fast_period(_fast_period),
        slow_period(_slow_period),
        ama_shift(_ama_shift),
        applied_price(_ap) {
    // Defaulting to on-indicator mode (will use real ticks from platform via IndicatorTickReal).
    SetShift(_shift);
    if (custom_indi_name == "") {
      SetCustomIndicatorName("Examples\\AMA");
    }
  };
  IndiAMAParams(IndiAMAParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  }
};

/**
 * Implements the AMA indicator.
 */
class Indi_AMA : public IndicatorTickOrCandleSource<IndiAMAParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_AMA(IndiAMAParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : IndicatorTickOrCandleSource(
            _p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE, _indi_src_mode),
            _indi_src) {
    iparams.SetIndicatorType(INDI_AMA);
  };
  Indi_AMA(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : IndicatorTickOrCandleSource(INDI_AMA, _tf, _shift){};

  /**
   * Built-in version of AMA.
   */
  static double iAMA(string _symbol, ENUM_TIMEFRAMES _tf, int _ama_period, int _fast_ema_period, int _slow_ema_period,
                     int _ama_shift, ENUM_APPLIED_PRICE _ap, int _mode = 0, int _shift = 0,
                     IndicatorData *_obj = NULL) {
#ifdef __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(
        ::iAMA(_symbol, _tf, _ama_period, _fast_ema_period, _slow_ema_period, _ama_shift, _ap), _mode, _shift);
#else
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT(
        _symbol, _tf, _ap,
        Util::MakeKey("Indi_AMA", _ama_period, _fast_ema_period, _slow_ema_period, _ama_shift, (int)_ap));
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
   * On-indicator version of AMA.
   */
  static double iAMAOnIndicator(IndicatorData *_indi, string _symbol, ENUM_TIMEFRAMES _tf, int _ama_period,
                                int _fast_ema_period, int _slow_ema_period, int _ama_shift, ENUM_APPLIED_PRICE _ap,
                                int _mode = 0, int _shift = 0, IndicatorData *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT_DS_SPECIFIC(
        _indi, _symbol, _tf, _ap,
        Util::MakeKey("Indi_AMA_ON_" + _indi.GetFullName(), _ama_period, _fast_ema_period, _slow_ema_period, _ama_shift,
                      (int)_ap));
    return iAMAOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_SHORT, _ama_period, _fast_ema_period, _slow_ema_period,
                       _ama_shift, _mode, _shift, _cache);
  }

  /**
   * OnInit() method for AMA indicator.
   */
  static void CalculateInit(int InpPeriodAMA, int InpFastPeriodEMA, int InpSlowPeriodEMA, int InpShiftAMA,
                            double &ExtFastSC, double &ExtSlowSC, int &ExtPeriodAMA, int &ExtSlowPeriodEMA,
                            int &ExtFastPeriodEMA) {
    // Check for input values.
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

    // Calculate ExtFastSC & ExtSlowSC.
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

#ifdef __debug__
    for (int x = prev_calculated; x < rates_total; ++x) {
      Print("price[", x, "] = ", price[x].Get(),
            ", O = ", iOpen(Symbol(), PERIOD_CURRENT, Bars(Symbol(), PERIOD_CURRENT) - x - 1));
    }
#endif

    int i;
    // Check for rates count.
    if (rates_total < ExtPeriodAMA + begin) return (0);
    // Draw begin may be corrected.
    if (begin != 0) PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, ExtPeriodAMA + begin);
    // Detect position.
    int pos = prev_calculated - 1;
    // First calculations.
    if (pos < ExtPeriodAMA + begin) {
      pos = ExtPeriodAMA + begin;
      for (i = 0; i < pos - 1; i++) ExtAMABuffer[i] = 0.0;

      ExtAMABuffer[pos - 1] = price[pos - 1];
    }
    // Main cycle.
    for (i = pos; i < rates_total && !IsStopped(); i++) {
      // Calculate SSC.
      double currentSSC = (CalculateER(i, price, ExtPeriodAMA) * (ExtFastSC - ExtSlowSC)) + ExtSlowSC;
      // Calculate AMA.
      double prevAMA = ExtAMABuffer[i - 1].Get();

      ExtAMABuffer[i] = MathPow(currentSSC, 2) * (price[i] - prevAMA) + prevAMA;
    }
    // Return value of prev_calculated for next call.
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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_AMA::iAMA(GetSymbol(), GetTf(), /*[*/ GetPeriod(), GetFastPeriod(), GetSlowPeriod(),
                                GetAMAShift(), GetAppliedPrice() /*]*/, _mode, _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod(),
                         GetFastPeriod(), GetSlowPeriod(), GetAMAShift() /*]*/, _mode, _ishift);

        break;
      case IDATA_INDICATOR:
        _value = Indi_AMA::iAMAOnIndicator(GetDataSource(), GetSymbol(), GetTf(), /*[*/ GetPeriod(), GetFastPeriod(),
                                           GetSlowPeriod(), GetAMAShift(), GetAppliedPrice() /*]*/, _mode, _ishift,
                                           THIS_PTR);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /**
   * Called when data source emits new entry (historic or future one).
   */
  void OnDataSourceEntry(IndicatorDataEntry &entry) override {
    // Just to be able to make a breakpoint here.
    int x = 4;
  };

  /**
   * Called if data source is requested, but wasn't yet set. May be used to initialize indicators that must operate on
   * some data source.
   */
  virtual IndicatorData *OnDataSourceRequest() { return DataSourceRequestReturnDefault(GetAppliedPrice()); }

  /* Getters */

  /**
   * Get AMA shift.
   */
  unsigned int GetAMAShift() { return iparams.ama_shift; }

  /**
   * Get period.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /**
   * Get fast period.
   */
  unsigned int GetFastPeriod() { return iparams.fast_period; }

  /**
   * Get slow period.
   */
  unsigned int GetSlowPeriod() { return iparams.slow_period; }

  /**
   * Get applied price.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return iparams.applied_price; }

  /* Setters */

  /**
   * Set AMA shift.
   */
  void SetAMAShift(unsigned int _ama_shift) {
    istate.is_changed = true;
    iparams.ama_shift = _ama_shift;
  }

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }

  /**
   * Set fast period.
   */
  void SetFastPeriod(unsigned int _fast_period) {
    istate.is_changed = true;
    iparams.fast_period = _fast_period;
  }

  /**
   * Set slow period.
   */
  void SetSlowPeriod(unsigned int _slow_period) {
    istate.is_changed = true;
    iparams.slow_period = _slow_period;
  }

  /**
   * Set applied price.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};

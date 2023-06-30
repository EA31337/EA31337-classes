//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
#include "../Indicator/Indicator.h"
#include "../Storage/Dict/Buffer/BufferStruct.h"
#include "../Storage/ValueStorage.all.h"

// Structs.
struct IndiFrAIndiMAParams : IndicatorParams {
  unsigned int frama_shift;
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;

  // Struct constructor.
  IndiFrAIndiMAParams(int _period = 14, int _frama_shift = 0, ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0)
      : IndicatorParams(INDI_FRAMA) {
    frama_shift = _frama_shift;
    SetCustomIndicatorName("Examples\\FrAMA");
    applied_price = _ap;
    period = _period;
    shift = _shift;
  };
  IndiFrAIndiMAParams(IndiFrAIndiMAParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_FrAMA : public Indicator<IndiFrAIndiMAParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_FrAMA(IndiFrAIndiMAParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
             int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_FrAMA(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
             int _indi_src_mode = 0)
      : Indicator(IndiFrAIndiMAParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_AP; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override {
    return IDATA_BUILTIN | IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR;
  }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiFrAIndiMAParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // FrAMA uses OHLC only.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_OPEN) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_LOW) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_CLOSE);
  }

  /**
   * Built-in version of FrAMA.
   */
  static double iFrAMA(string _symbol, ENUM_TIMEFRAMES _tf, int _ma_period, int _ma_shift, ENUM_APPLIED_PRICE _ap,
                       int _mode = 0, int _rel_shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL__
#ifdef __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iFrAMA(_symbol, _tf, _ma_period, _ma_shift, _ap), _mode,
                                      _obj PTR_DEREF ToAbsShift(_rel_shift));
#else  // __MQL5__
    if (_obj == nullptr) {
      Print(
          "Indi_FrAMA::iFrAMA() can work without supplying pointer to IndicatorData only in MQL5. In this platform the "
          "pointer is required.");
      DebugBreak();
      return 0;
    }
    INDI_REQUIRE_BARS_OR_RETURN_EMPTY(_obj, 2 * _ma_period);
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_obj, Util::MakeKey(_ma_period, _ma_shift, (int)_ap));
    return iFrAMAOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _ma_period, _ma_shift, _ap, _mode,
                         _obj PTR_DEREF ToAbsShift(_rel_shift), _cache);
#endif
#else  // Non-MQL.
    // @todo: Use Platform class.
    RUNTIME_ERROR(
        "Not implemented. Please use an On-Indicator mode and attach "
        "indicator via Platform::Add/AddWithDefaultBindings().");
    return DBL_MAX;
#endif
  }

  /**
   * Calculates FrAMA on the array of values.
   */
  static double iFrAMAOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _ma_period, int _ma_shift, ENUM_APPLIED_PRICE _ap,
                              int _mode, int _abs_shift, IndiBufferCache<double> *_cache, bool _recalculate = false) {
    _cache PTR_DEREF SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache PTR_DEREF HasBuffers()) {
      _cache PTR_DEREF AddBuffer<NativeValueStorage<double>>(1);
    }

    if (_recalculate) {
      _cache PTR_DEREF ResetPrevCalculated();
    }

    _cache PTR_DEREF SetPrevCalculated(Indi_FrAMA::Calculate(
        INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache PTR_DEREF GetBuffer<double>(0), _ma_period, _ma_shift, _ap));

    return _cache PTR_DEREF GetTailValue<double>(_mode, _abs_shift);
  }

  /**
   * On-indicator version of FrAMA.
   */
  static double iFrAMAOnIndicator(IndicatorData *_indi, int _ma_period, int _ma_shift, ENUM_APPLIED_PRICE _ap,
                                  int _mode = 0, int _rel_shift = 0) {
    INDI_REQUIRE_BARS_OR_RETURN_EMPTY(_indi, 2 * _ma_period);
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, Util::MakeKey(_ma_period, _ma_shift, (int)_ap));
    return iFrAMAOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _ma_period, _ma_shift, _ap, _mode,
                         _indi PTR_DEREF ToAbsShift(_rel_shift), _cache);
  }

  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &FrAmaBuffer, int InpPeriodFrAMA,
                       int InpShift, ENUM_APPLIED_PRICE InpAppliedPrice) {
    if (rates_total < 2 * InpPeriodFrAMA) return (0);

    int start, i;
    // Start calculations.
    if (prev_calculated == 0) {
      start = 2 * InpPeriodFrAMA - 1;
      for (i = 0; i <= start; i++)
        FrAmaBuffer[i] = AppliedPriceValueStorage::GetApplied(open, high, low, close, i, InpAppliedPrice);
    } else
      start = prev_calculated - 1;

    // Main cycle.
    double math_log_2 = MathLog(2.0);
    for (i = start; i < rates_total && !IsStopped(); i++) {
      double hi1 = high[iHighest(high, InpPeriodFrAMA, rates_total - i - 1)].Get();
      double lo1 = low[iLowest(low, InpPeriodFrAMA, rates_total - i - 1)].Get();
      double hi2 = high[iHighest(high, InpPeriodFrAMA, rates_total - i + InpPeriodFrAMA - 1)].Get();
      double lo2 = low[iLowest(low, InpPeriodFrAMA, rates_total - i + InpPeriodFrAMA - 1)].Get();
      double hi3 = high[iHighest(high, 2 * InpPeriodFrAMA, rates_total - i - 1)].Get();
      double lo3 = low[iLowest(low, 2 * InpPeriodFrAMA, rates_total - i - 1)].Get();
      double n1 = (hi1 - lo1) / InpPeriodFrAMA;
      double n2 = (hi2 - lo2) / InpPeriodFrAMA;
      double n3 = (hi3 - lo3) / (2 * InpPeriodFrAMA);
      double d = (MathLog(n1 + n2) - MathLog(n3)) / math_log_2;
      double alfa = MathExp(-4.6 * (d - 1.0));
      double _iprice = AppliedPriceValueStorage::GetApplied(open, high, low, close, i, InpAppliedPrice);

      FrAmaBuffer[i] = alfa * _iprice + (1 - alfa) * FrAmaBuffer[i - 1].Get();
    }

    // OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _abs_shift = 0) {
    double _value = EMPTY_VALUE;
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = iFrAMA(GetSymbol(), GetTf(), GetPeriod(), GetFRAMAShift(), GetAppliedPrice(), _mode,
                        ToRelShift(_abs_shift), THIS_PTR);
        break;
      case IDATA_ONCALCULATE:
        _value = iFrAMAOnIndicator(GetDataSource(), GetPeriod(), GetFRAMAShift(), GetAppliedPrice(), _mode,
                                   ToRelShift(_abs_shift));
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod(),
                         GetFRAMAShift() /*]*/, 0, ToRelShift(_abs_shift));
        break;
      case IDATA_INDICATOR:
        _value = iFrAMAOnIndicator(GetDataSource(), GetPeriod(), GetFRAMAShift(), GetAppliedPrice(), _mode,
                                   ToRelShift(_abs_shift));
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

  /**
   * Get FRAMA shift.
   */
  unsigned int GetFRAMAShift() { return iparams.frama_shift; }

  /**
   * Get applied price.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() override { return iparams.applied_price; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }

  /**
   * Set FRAMA shift.
   */
  void SetFRAMAShift(unsigned int _frama_shift) {
    istate.is_changed = true;
    iparams.frama_shift = _frama_shift;
  }

  /**
   * Set applied price.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};

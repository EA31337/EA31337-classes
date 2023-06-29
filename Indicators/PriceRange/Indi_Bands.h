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
#include "../../Indicator/Indicator.h"
#include "../Indi_CCI.mqh"
#include "../Indi_Momentum.mqh"
#include "../Indi_StdDev.mqh"
#include "../Oscillator/Indi_RSI.h"
#include "../Price/Indi_MA.h"
#include "../Price/Indi_Price.h"
#include "Indi_Envelopes.h"

// Indicator line identifiers used in Bands.
enum ENUM_BANDS_LINE {
#ifdef __MQL4__
  BAND_BASE = MODE_MAIN,    // Main line.
  BAND_UPPER = MODE_UPPER,  // Upper limit.
  BAND_LOWER = MODE_LOWER,  // Lower limit.
#else
  BAND_BASE = BASE_LINE,    // Main line.
  BAND_UPPER = UPPER_BAND,  // Upper limit.
  BAND_LOWER = LOWER_BAND,  // Lower limit.
#endif
  FINAL_BANDS_LINE_ENTRY,
};

// Structs.
struct IndiBandsParams : IndicatorParams {
  unsigned int period;
  double deviation;
  unsigned int bshift;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  IndiBandsParams(unsigned int _period = 20, double _deviation = 2, int _bshift = 0,
                  ENUM_APPLIED_PRICE _ap = PRICE_OPEN, int _shift = 0)
      : period(_period), deviation(_deviation), bshift(_bshift), applied_price(_ap), IndicatorParams(INDI_BANDS) {
    shift = _shift;
    SetCustomIndicatorName("Examples\\BB");
  };
  IndiBandsParams(IndiBandsParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Bollinger Bands® indicator.
 */
class Indi_Bands : public Indicator<IndiBandsParams> {
 protected:
  /* Protected methods */

  /**
   * Initialize.
   */
  void Init() { Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES), FINAL_BANDS_LINE_ENTRY); }

 public:
  /**
   * Class constructor.
   */
  Indi_Bands(IndiBandsParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
             int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(FINAL_BANDS_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE,
                                                   _indi_src_mode),
                  _indi_src) {
    Init();
  }
  Indi_Bands(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
             int _indi_src_mode = 0)
      : Indicator(IndiBandsParams(),
                  IndicatorDataParams::GetInstance(FINAL_BANDS_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE,
                                                   _indi_src_mode),
                  _indi_src) {
    Init();
  }

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override {
    return INDI_SUITABLE_DS_TYPE_AP | INDI_SUITABLE_DS_TYPE_BASE_ONLY;
  }

 public:
  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override {
    return IDATA_BUILTIN | IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR;
  }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ibands
   * - https://www.mql5.com/en/docs/indicators/ibands
   */
  static double iBands(string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, double _deviation, int _bands_shift,
                       ENUM_APPLIED_PRICE _applied_price, ENUM_BANDS_LINE _mode = BAND_BASE, int _shift = 0,
                       IndicatorData *_obj = NULL) {
#ifdef __MQL__
#ifdef __MQL4__
    return ::iBands(_symbol, _tf, _period, _deviation, _bands_shift, _applied_price, _mode, _shift);
#else  // __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iBands(_symbol, _tf, _period, _bands_shift, _deviation, _applied_price), _mode,
                                      _shift);
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
   * Calculates Bands on another indicator.
   *
   * Note that "_bands_shift" is used only for drawing.
   */
  static double iBandsOnIndicator(IndicatorData *_indi, unsigned int _period, double _deviation, int _bands_shift,
                                  ENUM_APPLIED_PRICE _ap,
                                  ENUM_BANDS_LINE _mode,  // (MT4/MT5): 0 - MODE_MAIN/BASE_LINE, 1 -
                                                          // MODE_UPPER/UPPER_BAND, 2 - MODE_LOWER/LOWER_BAND
                                  int _rel_shift) {
    INDI_REQUIRE_BARS_OR_RETURN_EMPTY(_indi, _period);
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT(_indi, _ap,
                                                        Util::MakeKey(_period, _deviation, _bands_shift, (int)_ap));
    return iBandsOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_SHORT, _period, _deviation, _bands_shift, _mode,
                         _indi PTR_DEREF ToAbsShift(_rel_shift), _cache);
  }

  static double iBandsOnArray(INDICATOR_CALCULATE_PARAMS_SHORT, int _period, double _deviation, int _bands_shift,
                              int _mode, int _abs_shift, IndiBufferCache<double> *_cache, bool _recalculate = false) {
    _cache PTR_DEREF SetPriceBuffer(_price);

    if (!_cache PTR_DEREF HasBuffers()) {
      _cache PTR_DEREF AddBuffer<NativeValueStorage<double>>(4);
    }

    if (_recalculate) {
      _cache PTR_DEREF ResetPrevCalculated();
    }

    _cache PTR_DEREF SetPrevCalculated(
        Indi_Bands::Calculate(INDICATOR_CALCULATE_GET_PARAMS_SHORT, _cache PTR_DEREF GetBuffer<double>(0),
                              _cache PTR_DEREF GetBuffer<double>(1), _cache PTR_DEREF GetBuffer<double>(2),
                              _cache PTR_DEREF GetBuffer<double>(3), _period, _bands_shift, _deviation));

    return _cache PTR_DEREF GetTailValue<double>(_mode, _abs_shift);
  }

  /**
   * OnCalculate() method for Bands indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_SHORT, ValueStorage<double> &ExtMLBuffer,
                       ValueStorage<double> &ExtTLBuffer, ValueStorage<double> &ExtBLBuffer,
                       ValueStorage<double> &ExtStdDevBuffer, int InpBandsPeriod, int InpBandsShift,
                       double InpBandsDeviations) {
    int ExtBandsPeriod, ExtBandsShift;
    double ExtBandsDeviations;
    int ExtPlotBegin = 0;

    if (InpBandsPeriod < 2) {
      ExtBandsPeriod = 20;
      PrintFormat("Incorrect value for input variable InpBandsPeriod=%d. Indicator will use value=%d for calculations.",
                  InpBandsPeriod, ExtBandsPeriod);
    } else
      ExtBandsPeriod = InpBandsPeriod;
    if (InpBandsShift < 0) {
      ExtBandsShift = 0;
      PrintFormat("Incorrect value for input variable InpBandsShift=%d. Indicator will use value=%d for calculations.",
                  InpBandsShift, ExtBandsShift);
    } else
      ExtBandsShift = InpBandsShift;
    if (InpBandsDeviations == 0.0) {
      ExtBandsDeviations = 2.0;
      PrintFormat(
          "Incorrect value for input variable InpBandsDeviations=%f. Indicator will use value=%f for calculations.",
          InpBandsDeviations, ExtBandsDeviations);
    } else
      ExtBandsDeviations = InpBandsDeviations;

    if (rates_total < ExtPlotBegin) return (0);
    //--- indexes draw begin settings, when we've recieved previous begin
    if (ExtPlotBegin != ExtBandsPeriod + begin) {
      ExtPlotBegin = ExtBandsPeriod + begin;
      PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, ExtPlotBegin);
      PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, ExtPlotBegin);
      PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, ExtPlotBegin);
    }
    //--- starting calculation
    int pos;
    if (prev_calculated > 1)
      pos = prev_calculated - 1;
    else
      pos = 0;
    //--- main cycle
    for (int i = pos; i < rates_total && !IsStopped(); i++) {
      //--- middle line
      ExtMLBuffer[i] = Indi_MA::SimpleMA(i, ExtBandsPeriod, price);
      //--- calculate and write down StdDev
      ExtStdDevBuffer[i] = StdDev_Func(i, price, ExtMLBuffer, ExtBandsPeriod);
      //--- upper line
      ExtTLBuffer[i] = ExtMLBuffer[i] + ExtBandsDeviations * ExtStdDevBuffer[i].Get();
      //--- lower line
      ExtBLBuffer[i] = ExtMLBuffer[i] - ExtBandsDeviations * ExtStdDevBuffer[i].Get();
    }
    //--- OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  static double StdDev_Func(const int position, ValueStorage<double> &price, ValueStorage<double> &ma_price,
                            const int period) {
    double std_dev = 0.0;
    //--- calcualte StdDev
    if (position >= period) {
      for (int i = 0; i < period; i++) std_dev += MathPow(price[position - i] - ma_price[position], 2.0);
      std_dev = MathSqrt(std_dev / period);
    }
    //--- return calculated value
    return (std_dev);
  }

  /**
   * Returns the indicator's value.
   *
   * For IDATA_ICUSTOM mode, use those externs:
   *
   * extern unsigned int period;
   * extern unsigned int bands_shift;
   * extern double deviation;
   * extern ENUM_APPLIED_PRICE applied_price; // Required only for MQL4.
   *
   * Also, remember to use iparams.SetCustomIndicatorName(name) method to choose
   * indicator name, e.g.,: iparams.SetCustomIndicatorName("Examples\\BB");
   *
   * Note that in MQL5 Applied Price must be passed as the last parameter
   * (before mode and shift).
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = BAND_BASE, int _abs_shift = 0) {
    double _value = EMPTY_VALUE;
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_Bands::iBands(GetSymbol(), GetTf(), GetPeriod(), GetDeviation(), GetBandsShift(),
                                    GetAppliedPrice(), (ENUM_BANDS_LINE)_mode, ToRelShift(_abs_shift), THIS_PTR);
        break;
      case IDATA_ONCALCULATE:
      case IDATA_INDICATOR:
        // Calculating bands value from specified indicator.
        _value = Indi_Bands::iBandsOnIndicator(THIS_PTR, GetPeriod(), GetDeviation(), GetBandsShift(),
                                               GetAppliedPrice(), (ENUM_BANDS_LINE)_mode, ToRelShift(_abs_shift));
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.custom_indi_name, /* [ */ GetPeriod(),
                         GetBandsShift(), GetDeviation(), GetAppliedPrice() /* ] */, _mode, ToRelShift(_abs_shift));
        break;
    }
    return _value;
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return !_entry.HasValue((double)NULL) && !_entry.HasValue(EMPTY_VALUE) && _entry.IsGt<double>(0) &&
           _entry.values[(int)BAND_LOWER].GetDbl() < _entry.values[(int)BAND_UPPER].GetDbl();
  }

  /**
   * Provides built-in indicators whose can be used as data source.
   */
  virtual IndicatorData *FetchDataSource(ENUM_INDICATOR_TYPE _id) {
    IndicatorData *_result = NULL;
    if (_id == INDI_BANDS) {
      IndiBandsParams bands_params;
      _result = new Indi_Bands(bands_params);
    } else if (_id == INDI_CCI) {
      IndiCCIParams cci_params;
      _result = new Indi_CCI(cci_params);
    } else if (_id == INDI_ENVELOPES) {
      IndiEnvelopesParams env_params;
      _result = new Indi_Envelopes(env_params);
    } else if (_id == INDI_MOMENTUM) {
      IndiMomentumParams mom_params;
      _result = new Indi_Momentum(mom_params);
    } else if (_id == INDI_MA) {
      IndiMAParams ma_params;
      _result = new Indi_MA(ma_params);
    } else if (_id == INDI_RSI) {
      IndiRSIParams _rsi_params;
      _result = new Indi_RSI(_rsi_params);
    } else if (_id == INDI_STDDEV) {
      IndiStdDevParams stddev_params;
      _result = new Indi_StdDev(stddev_params);
    }

    if (_result != nullptr) {
      _result PTR_DEREF SetDataSource(GetCandle());
      return _result;
    }

    return IndicatorData::FetchDataSource(_id);
  }

  /* Getters */

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /**
   * Get deviation value.
   */
  double GetDeviation() { return iparams.deviation; }

  /**
   * Get bands shift value.
   */
  unsigned int GetBandsShift() { return iparams.bshift; }

  /**
   * Get applied price value.
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
   * Set deviation value.
   */
  void SetDeviation(double _deviation) {
    istate.is_changed = true;
    iparams.deviation = _deviation;
  }

  /**
   * Set bands shift value.
   */
  void SetBandsShift(int _bshift) {
    istate.is_changed = true;
    iparams.bshift = _bshift;
  }

  /**
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }
};

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iBands(string _symbol, int _tf, int _period, double _deviation, int _bands_shift, int _ap, int _mode,
              int _shift) {
  ResetLastError();
  return Indi_Bands::iBands(_symbol, (ENUM_TIMEFRAMES)_tf, _period, _deviation, _bands_shift, (ENUM_APPLIED_PRICE)_ap,
                            (ENUM_BANDS_LINE)_mode, _shift);
}
#endif

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
#include "../Indicator/Indicator.h"
#include "Indi_CCI.mqh"
#include "Indi_Envelopes.mqh"
#include "Indi_MA.mqh"
#include "Indi_Momentum.mqh"
#include "Indi_RSI.mqh"
#include "Indi_StdDev.mqh"
#include "Price/Indi_Price.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iBands(string _symbol, int _tf, int _period, double _deviation, int _bands_shift, int _ap, int _mode,
              int _shift) {
  ResetLastError();
  return Indi_Bands::iBands(_symbol, (ENUM_TIMEFRAMES)_tf, _period, _deviation, _bands_shift, (ENUM_APPLIED_PRICE)_ap,
                            (ENUM_BANDS_LINE)_mode, _shift);
}
double iBandsOnArray(double &_arr[], int _total, int _period, double _deviation, int _bands_shift, int _mode,
                     int _shift) {
  ResetLastError();
  return Indi_Bands::iBandsOnArray(_arr, _total, _period, _deviation, _bands_shift, _mode, _shift);
}
#endif

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
#ifdef __MQL4__
    return ::iBands(_symbol, _tf, _period, _deviation, _bands_shift, _applied_price, _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iBands(_symbol, _tf, _period, _bands_shift, _deviation, _applied_price)) == INVALID_HANDLE) {
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
#endif
  }

  /**
   * Calculates Bands on another indicator.
   */
  static double iBandsOnIndicator(IndicatorData *_target, IndicatorData *_source, string _symbol, ENUM_TIMEFRAMES _tf,
                                  unsigned int _period, double _deviation, int _bands_shift, ENUM_APPLIED_PRICE _ap,
                                  ENUM_BANDS_LINE _mode,  // (MT4/MT5): 0 - MODE_MAIN/BASE_LINE, 1 -
                                                          // MODE_UPPER/UPPER_BAND, 2 - MODE_LOWER/LOWER_BAND
                                  int _shift, IndicatorData *_indi_source = NULL) {
    double _indi_value_buffer[];
    double _std_dev;
    double _line_value;

    ValueStorage<double> *_indi_applied_price = _source PTR_DEREF GetSpecificAppliedPriceValueStorage(_ap, _target);

    // Period can't be higher than number of available bars.
    _period = MathMin(_period, ArraySize(_indi_applied_price));

    ArrayCopy(_indi_value_buffer, _indi_applied_price, 0, _bands_shift + _shift, _period);

    // Base band. Calculating MA from "_period" number of values or less.
    _line_value = Indi_MA::SimpleMA(0, _period, _indi_value_buffer);

    // Standard deviation.
    _std_dev = Indi_StdDev::iStdDevOnArray(_indi_value_buffer, _line_value, _period);

    double _result = EMPTY_VALUE;

    switch (_mode) {
      case BAND_BASE:
        // Already calculated.
        _result = _line_value;
        break;
      case BAND_UPPER:
        _result = _line_value + /* band deviations */ _deviation * _std_dev;
        break;
      case BAND_LOWER:
        _result = _line_value - /* band deviations */ _deviation * _std_dev;
        break;
    }

    return _result;
  }

  static double iBandsOnArray(double &array[], int total, int period, double deviation, int bands_shift, int mode,
                              int shift) {
#ifdef __MQL4__
    return ::iBandsOnArray(array, total, period, deviation, bands_shift, mode, shift);
#else  // __MQL5__
    static Ref<Indi_PriceFeeder> price_feeder = new Indi_PriceFeeder();
    price_feeder REF_DEREF SetPrices(array);
    price_feeder REF_DEREF SetDataSourceAppliedPrice(INDI_VS_TYPE_INDEX_0);
    // First parameter is a pointer to target indicator. It is used to override applied price, so we configure it on the
    // price feeder itself and pass it as both, target and source indicator.
    return iBandsOnIndicator(price_feeder.Ptr(), price_feeder.Ptr(), NULL, NULL, period, deviation, bands_shift,
                             (ENUM_APPLIED_PRICE)0 /* unused */, (ENUM_BANDS_LINE)mode, shift);
#endif
  }

  static double iBandsOnArray2(double &array[], int total, int period, double deviation, int bands_shift, int mode,
                               int shift) {
#ifdef __MQL5__
    // Calculates bollinger bands indicator from array data
    int size = ArraySize(array);
    if (size < period) return false;
    if (period <= 0) return false;

    double ma = Indi_MA::iMAOnArray(array, total, period, 0, MODE_SMA, 0);

    double sum = 0.0, val;
    int i;

    for (i = 0; i < period; i++) {
      val = array[size - i - 1] - ma;
      sum += val * val;
    }

    double dev = deviation * MathSqrt(sum / period);

    switch (mode) {
      case BAND_BASE:
        return ma;
      case BAND_UPPER:
        return ma + dev;
      case BAND_LOWER:
        return ma - dev;
    }

    return DBL_MIN;
#else
    return ::iBandsOnArray(array, total, period, deviation, bands_shift, mode, shift);
#endif
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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = BAND_BASE, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_Bands::iBands(GetSymbol(), GetTf(), GetPeriod(), GetDeviation(), GetBandsShift(),
                                    GetAppliedPrice(), (ENUM_BANDS_LINE)_mode, _ishift, THIS_PTR);
        break;
      case IDATA_ONCALCULATE:
        _value =
            Indi_Bands::iBandsOnIndicator(THIS_PTR, GetDataSource(), GetSymbol(), GetTf(), GetPeriod(), GetDeviation(),
                                          GetBandsShift(), GetAppliedPrice(), (ENUM_BANDS_LINE)_mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.custom_indi_name, /* [ */ GetPeriod(),
                         GetBandsShift(), GetDeviation(), GetAppliedPrice() /* ] */, _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        // Calculating bands value from specified indicator.
        _value = Indi_Bands::iBandsOnIndicator(THIS_PTR, GetDataSource(), GetSymbol(), GetTf(), GetPeriod(),
                                               GetDeviation(), GetBandsShift(), GetAppliedPrice(),
                                               (ENUM_BANDS_LINE)_mode, _ishift, THIS_PTR);
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
      IndiBandsParams bands_params();
      _result = Indi_Bands(bands_params);
    } else if (_id == INDI_CCI) {
      IndiCCIParams cci_params();
      _result = new Indi_CCI(cci_params);
    } else if (_id == INDI_ENVELOPES) {
      IndiEnvelopesParams env_params();
      _result = new Indi_Envelopes(env_params);
    } else if (_id == INDI_MOMENTUM) {
      IndiMomentumParams mom_params();
      _result = new Indi_Momentum(mom_params);
    } else if (_id == INDI_MA) {
      IndiMAParams ma_params();
      _result = new Indi_MA(ma_params);
    } else if (_id == INDI_RSI) {
      IndiRSIParams _rsi_params();
      _result = new Indi_RSI(_rsi_params);
    } else if (_id == INDI_STDDEV) {
      IndiStdDevParams stddev_params();
      _result = new Indi_StdDev(stddev_params);
    }

    if (_result != nullptr) {
      _result.SetDataSource(GetCandle());
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

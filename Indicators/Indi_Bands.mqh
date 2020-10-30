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
#include "Indi_MA.mqh"
#include "Indi_StdDev.mqh"

#ifndef __MQL4__
// Defines global functions (for MQL4 backward compability).
double iBands(string _symbol, int _tf, int _period, double _deviation, int _bands_shift, int _ap, int _mode,
              int _shift) {
  return Indi_Bands::iBands(_symbol, (ENUM_TIMEFRAMES)_tf, _period, _deviation, _bands_shift, (ENUM_APPLIED_PRICE)_ap,
                            (ENUM_BANDS_LINE)_mode, _shift);
}
double iBandsOnArray(double &_arr[], int _total, int _period, double _deviation, int _bands_shift, int _mode,
                     int _shift) {
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
struct BandsParams : IndicatorParams {
  unsigned int period;
  double deviation;
  unsigned int bshift;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructors.
  void BandsParams(unsigned int _period, double _deviation, int _bshift, ENUM_APPLIED_PRICE _ap)
      : period(_period), deviation(_deviation), bshift(_bshift), applied_price(_ap) {
    itype = INDI_BANDS;
    max_modes = FINAL_BANDS_LINE_ENTRY;
    custom_indi_name = "Examples\\BB";
    SetDataValueType(TYPE_DOUBLE);
  };
  void BandsParams(BandsParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Bollinger Bands® indicator.
 */
class Indi_Bands : public Indicator {
 protected:
  // Structs.
  BandsParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_Bands(BandsParams &_p)
      : params(_p.period, _p.deviation, _p.shift, _p.applied_price), Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_Bands(BandsParams &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.period, _p.deviation, _p.shift, _p.applied_price), Indicator(INDI_BANDS, _tf) {
    params = _p;
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
                       Indicator *_obj = NULL) {
    ResetLastError();

#ifdef __MQL4__
    return ::iBands(_symbol, _tf, _period, _deviation, _bands_shift, _applied_price, _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iBands(_symbol, _tf, _period, _bands_shift, _deviation, _applied_price)) == INVALID_HANDLE) {
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
    if (CopyBuffer(_handle, _mode, _shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Calculates Bands on another indicator.
   *
   * When _applied_price is set to -1, method will
   */
  static double iBandsOnIndicator(
      Indicator *_indi, string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _period, double _deviation, int _bands_shift,
      ENUM_BANDS_LINE _mode = BAND_BASE,  // (MT4/MT5): 0 - MODE_MAIN/BASE_LINE, 1 -
                                          // MODE_UPPER/UPPER_BAND, 2 - MODE_LOWER/LOWER_BAND
      int _shift = 0, Indicator *_obj = NULL) {
    double _indi_value_buffer[];
    double _std_dev;
    double _line_value;

    ArrayResize(_indi_value_buffer, _period);

    for (int i = _bands_shift; i < (int)_period; i++) {
      int current_shift = _shift + (i - _bands_shift);
      // Getting current indicator value.
      _indi_value_buffer[i - _bands_shift] = _indi[i - _bands_shift].value.GetValueDbl(_indi.GetIDataType());
    }

    // Base band.
    _line_value = Indi_MA::SimpleMA(_shift, _period, _indi_value_buffer);

    // Standard deviation.
    _std_dev = Indi_StdDev::iStdDevOnArray(_indi_value_buffer, _line_value, _period);

    switch (_mode) {
      case BAND_BASE:
        // Already calculated.
        return _line_value;
      case BAND_UPPER:
        return _line_value + /* band deviations */ _deviation * _std_dev;
      case BAND_LOWER:
        return _line_value - /* band deviations */ _deviation * _std_dev;
    }

    return EMPTY_VALUE;
  }

  static double iBandsOnArray(double &array[], int total, int period, double deviation, int bands_shift, int mode,
                              int shift) {
#ifdef __MQL4__
    return ::iBandsOnArray(array, total, period, deviation, bands_shift, mode, shift);
#else  // __MQL5__
    Indi_PriceFeeder price_feeder(array);
    return iBandsOnIndicator(&price_feeder, NULL, NULL, period, deviation, bands_shift, (ENUM_BANDS_LINE)mode, shift);
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
   * Also, remember to use params.SetCustomIndicatorName(name) method to choose
   * indicator name, e.g.,: params.SetCustomIndicatorName("Examples\\BB");
   *
   * Note that in MQL5 Applied Price must be passed as the last parameter
   * (before mode and shift).
   */
  double GetValue(ENUM_BANDS_LINE _mode, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = Indi_Bands::iBands(GetSymbol(), GetTf(), GetPeriod(), GetDeviation(), GetBandsShift(),
                                    GetAppliedPrice(), _mode, _shift, GetPointer(this));
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.custom_indi_name, /* [ */ GetPeriod(),
                         GetBandsShift(), GetDeviation(), GetAppliedPrice() /* ] */, _mode, _shift);
        break;
      case IDATA_INDICATOR:
        // Calculating bands value from specified indicator.
        _value = Indi_Bands::iBandsOnIndicator(params.indi_data, GetSymbol(), GetTf(), GetPeriod(), GetDeviation(),
                                               GetBandsShift(), _mode, _shift, GetPointer(this));
        break;
    }
    istate.is_changed = false;
    istate.is_ready = _LastError == ERR_NO_ERROR;
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
      _entry.value.SetValue(params.idvtype, GetValue(BAND_BASE, _shift), BAND_BASE);
      _entry.value.SetValue(params.idvtype, GetValue(BAND_UPPER, _shift), BAND_UPPER);
      _entry.value.SetValue(params.idvtype, GetValue(BAND_LOWER, _shift), BAND_LOWER);
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.value.HasValue(params.idvtype, (double)NULL) &&
                                                   !_entry.value.HasValue(params.idvtype, EMPTY_VALUE) &&
                                                   _entry.value.GetMinDbl(params.idvtype) > 0 &&
                                                   _entry.value.GetValueDbl(params.idvtype, BAND_LOWER) <
                                                       _entry.value.GetValueDbl(params.idvtype, BAND_UPPER));
      if (_entry.IsValid()) {
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
    _param.double_value = GetEntry(_shift).value.GetValueDbl(params.idvtype, _mode);
    return _param;
  }

  /* Getters */

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return params.period; }

  /**
   * Get deviation value.
   */
  double GetDeviation() { return params.deviation; }

  /**
   * Get bands shift value.
   */
  unsigned int GetBandsShift() { return params.bshift; }

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
   * Set deviation value.
   */
  void SetDeviation(double _deviation) {
    istate.is_changed = true;
    params.deviation = _deviation;
  }

  /**
   * Set bands shift value.
   */
  void SetBandsShift(int _bshift) {
    istate.is_changed = true;
    params.bshift = _bshift;
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
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToCSV(params.idvtype); }
};

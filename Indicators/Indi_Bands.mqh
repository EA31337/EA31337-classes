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

// Indicator line identifiers used in Bands.
enum ENUM_BANDS_LINE {
#ifdef __MQL4__
  BAND_BASE  = MODE_MAIN,  // Main line.
  BAND_UPPER = MODE_UPPER, // Upper limit.
  BAND_LOWER = MODE_LOWER, // Lower limit.
#else
  BAND_BASE  = BASE_LINE,  // Main line.
  BAND_UPPER = UPPER_BAND, // Upper limit.
  BAND_LOWER = LOWER_BAND, // Lower limit.
#endif
  FINAL_BANDS_LINE_ENTRY,
};

// Structs.
struct BandsEntry : IndicatorEntry {
  double value[FINAL_BANDS_LINE_ENTRY];
  string ToString(int _mode = EMPTY) {
    return StringFormat("%g,%g,%g", value[BAND_LOWER], value[BAND_BASE], value[BAND_UPPER]);
  }
  bool IsValid() {
    double _min_value = fmin(fmin(value[BAND_BASE], value[BAND_LOWER]), value[BAND_UPPER]);
    double _max_value = fmax(fmax(value[BAND_BASE], value[BAND_LOWER]), value[BAND_UPPER]);
    return value[BAND_UPPER] > value[BAND_LOWER] && _min_value > 0 && _max_value != EMPTY_VALUE;
  }
};
struct Bands_Params : IndicatorParams {
 unsigned int period;
 double deviation;
 unsigned int shift;
 ENUM_APPLIED_PRICE applied_price;
 // Constructor.
 void Bands_Params(unsigned int _period, double _deviation, int _shift, ENUM_APPLIED_PRICE _ap)
   : period(_period), deviation(_deviation), shift(_shift), applied_price(_ap) {};
};

/**
 * Implements the Bollinger Bands® indicator.
 */
class Indi_Bands : public Indicator {

 protected:

  // Structs.
  Bands_Params params;

 public:

  /**
   * Class constructor.
   */
  Indi_Bands(Bands_Params &_p, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_p.period, _p.deviation, _p.shift, _p.applied_price),
      Indicator(_iparams, _cparams) { Init(); }
  Indi_Bands(Bands_Params &_p, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_p.period, _p.deviation, _p.shift, _p.applied_price),
      Indicator(INDI_BANDS, _tf) { Init(); }

  /**
   * Initialize parameters.
   */
  void Init() {
    iparams.SetDataType(TYPE_DOUBLE);
    iparams.SetMaxModes(FINAL_BANDS_LINE_ENTRY);
  }

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/ibands
   * - https://www.mql5.com/en/docs/indicators/ibands
   */
  static double iBands(
    string _symbol,
    ENUM_TIMEFRAMES _tf,
    unsigned int _period,
    double _deviation,
    int _bands_shift,
    ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
    ENUM_BANDS_LINE _mode = BAND_BASE, // (MT4/MT5): 0 - MODE_MAIN/BASE_LINE, 1 - MODE_UPPER/UPPER_BAND, 2 - MODE_LOWER/LOWER_BAND
    int _shift = 0,
    Indicator *_obj = NULL
    )
  {
    ResetLastError();
#ifdef __MQL4__
    return ::iBands(_symbol, _tf, _period, _deviation, _bands_shift, _applied_price, _mode, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
      if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iBands(_symbol, _tf, _period, _bands_shift, _deviation, _applied_price)) == INVALID_HANDLE) {
        SetUserError(ERR_USER_INVALID_HANDLE);
        return EMPTY_VALUE;
      }
      else if (Object::IsValid(_obj)) {
        _obj.SetHandle(_handle);
      }
    }
    int _bars_calc = BarsCalculated(_handle);
    if (_bars_calc < 2) {
      SetUserError(ERR_USER_INVALID_BUFF_NUM);
      return EMPTY_VALUE;
    }
    if (CopyBuffer(_handle, _mode, -_shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
    * Returns the indicator's value.
    */
  double GetValue(ENUM_BANDS_LINE _mode, int _shift = 0) {
    double _value = Indi_Bands::iBands(GetSymbol(), GetTf(), GetPeriod(), GetDeviation(), GetBandsShift(), GetAppliedPrice(), _mode, _shift, GetPointer(this));
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.new_params = false;
    return _value;

  }

  /**
   * Returns the indicator's struct value.
   */
  BandsEntry GetEntry(int _shift = 0) {
    BandsEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value[BAND_BASE]  = GetValue(BAND_BASE, _shift);
    _entry.value[BAND_UPPER] = GetValue(BAND_UPPER, _shift);
    _entry.value[BAND_LOWER] = GetValue(BAND_LOWER, _shift);
    if (_entry.IsValid()) { _entry.AddFlags(INDI_ENTRY_FLAG_IS_VALID); }
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value[_mode];
    return _param;
  }

    /* Getters */

    /**
     * Get period value.
     */
    unsigned int GetPeriod() {
      return params.period;
    }

    /**
     * Get deviation value.
     */
    double GetDeviation() {
      return params.deviation;
    }

    /**
     * Get bands shift value.
     */
    unsigned int GetBandsShift() {
      return params.shift;
    }

    /**
     * Get applied price value.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return params.applied_price;
    }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.new_params = true;
    params.period = _period;
  }

  /**
   * Set deviation value.
   */
  void SetDeviation(double _deviation) {
    istate.new_params = true;
    params.deviation = _deviation;
  }

  /**
   * Set bands shift value.
   */
  void SetBandsShift(int _shift) {
    istate.new_params = true;
    params.shift = _shift;
  }

  /**
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.new_params = true;
    params.applied_price = _applied_price;
  }

  /* Printer methods */

  /**
   * Returns the indicator's value in plain format.
   */
  string ToString(int _shift = 0, int _mode = EMPTY) {
    return GetEntry(_shift).ToString(_mode);
  }

};

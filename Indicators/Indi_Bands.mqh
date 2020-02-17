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
struct Bands_Entry {
  double value[FINAL_BANDS_LINE_ENTRY];
  string ToString() {
    return StringFormat("%g,%g,%g", value[BAND_LOWER], value[BAND_BASE], value[BAND_UPPER]);
  }
};
struct Bands_Params {
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
      Indicator(_iparams, _cparams) {};

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
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
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
#ifdef __debug__
      PrintFormat("Failed to copy data from the indicator, error code %d", GetLastError());
#endif
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }
  double GetValue(ENUM_BANDS_LINE _mode, int _shift = 0) {
    iparams.ihandle = new_params ? INVALID_HANDLE : iparams.ihandle;
    double _value = Indi_Bands::iBands(GetSymbol(), GetTf(), GetPeriod(), GetDeviation(), GetBandsShift(), GetAppliedPrice(), _mode, _shift, GetPointer(this));
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;

  }
  Bands_Entry GetValue(int _shift = 0) {
    Bands_Entry _entry;
    _entry.value[BAND_BASE]  = GetValue(BAND_BASE);
    _entry.value[BAND_UPPER] = GetValue(BAND_UPPER);
    _entry.value[BAND_LOWER] = GetValue(BAND_LOWER);
    return _entry;
  }

    /* Getters */

    /**
     * Get period value.
     */
    unsigned int GetPeriod() {
      return this.params.period;
    }

    /**
     * Get deviation value.
     */
    double GetDeviation() {
      return this.params.deviation;
    }

    /**
     * Get bands shift value.
     */
    unsigned int GetBandsShift() {
      return this.params.shift;
    }

    /**
     * Get applied price value.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return this.params.applied_price;
    }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    new_params = true;
    params.period = _period;
  }

  /**
   * Set deviation value.
   */
  void SetDeviation(double _deviation) {
    new_params = true;
    params.deviation = _deviation;
  }

  /**
   * Set bands shift value.
   */
  void SetBandsShift(int _shift) {
    new_params = true;
    params.shift = _shift;
  }

  /**
   * Set applied price value.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    new_params = true;
    params.applied_price = _applied_price;
  }

};

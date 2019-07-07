//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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

// Properties.
#property strict

// Includes.
#include "../Indicator.mqh"

// Indicator line identifiers used in Bands.
enum ENUM_BANDS_LINE {
  BAND_BASE  = #ifdef __MQL4__ MODE_MAIN  #else BASE_LINE  #endif, // Main line.
  BAND_UPPER = #ifdef __MQL4__ MODE_UPPER #else UPPER_BAND #endif, // Upper limit.
  BAND_LOWER = #ifdef __MQL4__ MODE_LOWER #else LOWER_BAND #endif, // Lower limit.
  FINAL_BANDS_LINE_ENTRY,
};

/**
 * Implements the Bollinger Bands® indicator.
 */
class Indi_Bands : public Indicator {

  // Structs.
  struct Bands_Params {
    uint period;
    double deviation;
    uint shift;
    ENUM_APPLIED_PRICE applied_price;
    // Constructor.
    void Bands_Params(uint _period, double _deviation, uint _shift, ENUM_APPLIED_PRICE _ap)
      : period(_period), deviation(_deviation), shift(_shift), applied_price(_ap) {};
  } params;

  struct Bands_Data {
    double value[FINAL_BANDS_LINE_ENTRY];
  };

  public:

    /**
     * Class constructor.
     */
    void Indi_Bands(Bands_Params &_p, IndicatorParams &_iparams, ChartParams &_cparams)
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
      uint _period,
      double _deviation,
      int _bands_shift,
      ENUM_APPLIED_PRICE _applied_price, // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN, PRICE_TYPICAL, PRICE_WEIGHTED
      ENUM_BANDS_LINE _mode = BAND_BASE, // (MT4/MT5): 0 - MODE_MAIN/BASE_LINE, 1 - MODE_UPPER/UPPER_BAND, 2 - MODE_LOWER/LOWER_BAND
      int _shift = 0
      )
    {
      #ifdef __MQL4__
      return ::iBands(_symbol, _tf, _period, _deviation, _bands_shift, _applied_price, _mode, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iBands(_symbol, _tf, _period, _bands_shift, _deviation, _applied_price);
      return CopyBuffer(_handle, _mode, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double GetValue(ENUM_BANDS_LINE _mode, uint _shift = 0) {
      double _value = this.iBands(GetSymbol(), GetTf(), GetPeriod(), GetDeviation(), GetBandsShift(), GetAppliedPrice(), _mode, _shift);
      CheckLastError();
      return _value;
    }
    Bands_Data GetValue(uint _shift = 0) {
      Bands_Data _data;
      _data.value[BAND_BASE]  = GetValue(BAND_BASE);
      _data.value[BAND_UPPER] = GetValue(BAND_UPPER);
      _data.value[BAND_LOWER] = GetValue(BAND_LOWER);
      return _data;
    }

    /* Getters */

    /**
     * Get period value.
     */
    uint GetPeriod() {
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
    uint GetBandsShift() {
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
    void SetPeriod(uint _period) {
      this.params.period = _period;
    }

    /**
     * Set deviation value.
     */
    void SetDeviation(double _deviation) {
      this.params.deviation = _deviation;
    }

    /**
     * Set bands shift value.
     */
    void SetBandsShift(int _shift) {
      this.params.shift = _shift;
    }

    /**
     * Set applied price value.
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      this.params.applied_price = _applied_price;
    }

};

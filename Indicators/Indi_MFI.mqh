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

/**
 * Implements the Money Flow Index indicator.
 */
class Indi_MFI : public Indicator {

  // Structs.
  struct MFI_Params {
    uint ma_period;
    ENUM_APPLIED_VOLUME applied_volume; // Ignored in MT4.
    uint shift;
  };

  // Struct variables.
  MFI_Params params;

  public:

    /**
     * Class constructor.
     */
    void Indi_MFI(MFI_Params &_params) {
      this.params = _params;
    }

    /**
     * Calculates the Money Flow Index indicator and returns its value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/imfi
     * - https://www.mql5.com/en/docs/indicators/imfi
     */
    static double iMFI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        uint _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iMFI(_symbol, _tf, _period, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iMFI(_symbol, _tf, _period, VOLUME_TICK);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    static double iMFI(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        uint _period,
        ENUM_APPLIED_VOLUME _applied_volume, // Not used in MT4.
        uint _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iMFI(_symbol, _tf, _period, 0);
      #else // __MQL5__
      double _res[];
      int _handle = ::iMFI(_symbol, _tf, _period, _applied_volume);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iMFI(uint _shift = 0) {
      #ifdef __MQL4__
      double _value = iMFI(GetSymbol(), GetTf(), GetPeriod(), _shift);
      #else // __MQL5__
      double _value = iMFI(GetSymbol(), GetTf(), GetPeriod(), GetAppliedVolume());
      #endif
      CheckLastError();
      return _value;
    }
    double GetValue() {
      #ifdef __MQL4__
      double _value = iMFI(GetSymbol(), GetTf(), GetPeriod(), GetShift());
      #else // __MQL5__
      double _value = iMFI(GetSymbol(), GetTf(), GetPeriod(), GetAppliedVolume());
      #endif
      CheckLastError();
      return _value;
    }

    /* Getters */

    /**
     * Get period value.
     *
     * Period (amount of bars) for calculation of the indicator.
     */
    uint GetPeriod() {
      return this.params.ma_period;
    }

    /**
     * Get applied volume type.
     *
     * Note: Ignored in MT4.
     */
    ENUM_APPLIED_VOLUME GetAppliedVolume() {
      return this.params.applied_volume;
    }

    /**
     * Get shift value.
     *
     * Index of the value taken from the indicator buffer.
     * Shift relative to the current bar the given amount of periods ago.
     */
    uint GetShift() {
      return this.params.shift;
    }

    /* Setters */

    /**
     * Set period value.
     *
     * Period (amount of bars) for calculation of the indicator.
     */
    void SetPeriod(uint _ma_period) {
      this.params.ma_period = _ma_period;
    }

    /**
     * Set applied volume type.
     *
     * Note: Ignored in MT4.
     *
     * @docs
     * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_volume_enum
     */
    void SetAppliedVolume(ENUM_APPLIED_VOLUME _applied_volume) {
      this.params.applied_volume = _applied_volume;
    }

    /**
     * Set shift value.
     *
     * Index of the value taken from the indicator buffer.
     * Shift relative to the current bar the given amount of periods ago.
     */
    void SetShift(int _shift) {
      this.params.shift = _shift;
    }

};

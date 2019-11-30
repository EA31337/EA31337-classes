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

// Includes.
#include "../Indicator.mqh"

// Structs.
struct OBV_Params {
  ENUM_APPLIED_PRICE applied_price; // MT4 only.
  ENUM_APPLIED_VOLUME applied_volume; // MT5 only.
  // Constructor.
  void OBV_Params(ENUM_APPLIED_VOLUME _av = EMPTY)
    : applied_volume(_av) {};
  void OBV_Params(ENUM_APPLIED_PRICE _ap = EMPTY)
    : applied_price(_ap) {};
};

/**
 * Implements the On Balance Volume indicator.
 */
class Indi_OBV : public Indicator {

public:

    OBV_Params params;

    /**
     * Class constructor.
     */
    Indi_OBV(OBV_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
      : params(#ifdef __MQL4__ _params.applied_price #else _params.applied_volume #endif),
        Indicator(_iparams, _cparams) {};

    /**
     * Returns the indicator value.
     *
     * @docs
     * - https://docs.mql4.com/indicators/iobv
     * - https://www.mql5.com/en/docs/indicators/iobv
     */
    static double iOBV(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        ENUM_APPLIED_PRICE _applied_price, // MT4 only.
        uint _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iOBV(_symbol, _tf, _applied_price, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iOBV(_symbol, _tf, VOLUME_TICK);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    static double iOBV(
        string _symbol,
        ENUM_TIMEFRAMES _tf,
        ENUM_APPLIED_VOLUME _applied_volume, // MT5 only.
        uint _shift = 0
        ) {
      #ifdef __MQL4__
      return ::iOBV(_symbol, _tf, PRICE_CLOSE, _shift);
      #else // __MQL5__
      double _res[];
      int _handle = ::iOBV(_symbol, _tf, _applied_volume);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
      #endif
    }
    double iOBV(int _shift = 0) {
      #ifdef __MQL4__
      double _value = iOBV(GetSymbol(), GetTf(), GetAppliedPrice(), _shift);
      #else // __MQL5__
      double _value = iOBV(GetSymbol(), GetTf(), GetAppliedVolume(), _shift);
      #endif
      CheckLastError();
      return _value;
    }
    double GetValue(uint _shift = 0) {
      #ifdef __MQL4__
      double _value = iOBV(GetSymbol(), GetTf(), GetAppliedPrice(), _shift);
      #else // __MQL5__
      double _value = iOBV(GetSymbol(), GetTf(), GetAppliedVolume(), _shift);
      #endif
      CheckLastError();
      return _value;
    }

    /* Getters */

    /**
     * Get applied price value (MT4 only).
     *
     * The desired price base for calculations.
     */
    ENUM_APPLIED_PRICE GetAppliedPrice() {
      return this.params.applied_price;
    }

    /**
     * Get applied volume type (MT5 only).
     */
    ENUM_APPLIED_VOLUME GetAppliedVolume() {
      return this.params.applied_volume;
    }

    /* Setters */

    /**
     * Set applied price value (MT4 only).
     *
     * The desired price base for calculations.
     * @docs
     * - https://docs.mql4.com/constants/indicatorconstants/prices#enum_applied_price_enum
     * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
     */
    void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
      this.params.applied_price = _applied_price;
    }

    /**
     * Set applied volume type (MT5 only).
     *
     * @docs
     * - https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_volume_enum
     */
    void SetAppliedVolume(ENUM_APPLIED_VOLUME _applied_volume) {
      this.params.applied_volume = _applied_volume;
    }

};

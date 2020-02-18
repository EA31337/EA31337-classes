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

// Structs.
struct MFIEntry : IndicatorEntry {
  double value;
  string ToString() {
    return StringFormat("%g", value);
  }
};
struct MFI_Params {
  unsigned int ma_period;
  ENUM_APPLIED_VOLUME applied_volume; // Ignored in MT4.
  // Constructor.
  void MFI_Params(unsigned int _ma_period, ENUM_APPLIED_VOLUME _av = NULL)
    : ma_period(_ma_period), applied_volume(_av) {};
};

/**
 * Implements the Money Flow Index indicator.
 */
class Indi_MFI : public Indicator {

 protected:

  MFI_Params params;

 public:

  /**
   * Class constructor.
   */
  Indi_MFI(MFI_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_params.ma_period, _params.applied_volume), Indicator(_iparams, _cparams) {};
  Indi_MFI(MFI_Params &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_params.ma_period, _params.applied_volume), Indicator(INDI_MFI, _tf) {};

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
      unsigned int _period,
      int _shift = 0,
      Indicator *_obj = NULL
      ) {
#ifdef __MQL4__
    return ::iMFI(_symbol, _tf, _period, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iMFI(_symbol, _tf, _period, VOLUME_TICK)) == INVALID_HANDLE) {
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
    if (CopyBuffer(_handle, 0, -_shift, 1, _res) < 0) {
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }
  static double iMFI(
      string _symbol,
      ENUM_TIMEFRAMES _tf,
      unsigned int _period,
      ENUM_APPLIED_VOLUME _applied_volume, // Not used in MT4.
      int _shift = 0
      ) {
    #ifdef __MQL4__
    return ::iMFI(_symbol, _tf, _period, 0);
    #else // __MQL5__
    double _res[];
    int _handle = ::iMFI(_symbol, _tf, _period, _applied_volume);
      return CopyBuffer(_handle, 0, _shift, 1, _res) > 0 ? _res[0] : EMPTY_VALUE;
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
#ifdef __MQL4__
    double _value = Indi_MFI::iMFI(GetSymbol(), GetTf(), GetPeriod(), _shift);
#else // __MQL5__
    double _value = Indi_MFI::iMFI(GetSymbol(), GetTf(), GetPeriod(), GetAppliedVolume(), _shift);
#endif
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  MFIEntry GetEntry(int _shift = 0) {
    MFIEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value = GetValue(_shift);
    return _entry;
  }

    /* Getters */

    /**
     * Get period value.
     *
     * Period (amount of bars) for calculation of the indicator.
     */
    unsigned int GetPeriod() {
      return params.ma_period;
    }

    /**
     * Get applied volume type.
     *
     * Note: Ignored in MT4.
     */
    ENUM_APPLIED_VOLUME GetAppliedVolume() {
      return params.applied_volume;
    }

    /* Setters */

    /**
     * Set period value.
     *
     * Period (amount of bars) for calculation of the indicator.
     */
    void SetPeriod(unsigned int _ma_period) {
      new_params = true;
      params.ma_period = _ma_period;
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
      new_params = true;
      params.applied_volume = _applied_volume;
    }

};

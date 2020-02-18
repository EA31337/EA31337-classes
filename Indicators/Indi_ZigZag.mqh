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
struct ZigZagEntry : IndicatorEntry {
  double value;
  string ToString() {
    return StringFormat("%g", value);
  }
};
struct ZigZag_Params {
  unsigned int depth;
  unsigned int deviation;
  unsigned int backstep;
  // Constructor.
  void ZigZag_Params(unsigned int _depth, unsigned int _deviation, unsigned int _backstep)
    : depth(_depth), deviation(_deviation), backstep(_backstep) {};
};

/**
 * Implements ZigZag indicator.
 */
class Indi_ZigZag : public Indicator {

 protected:

  ZigZag_Params params;

 public:

  /**
   * Class constructor.
   */
  Indi_ZigZag(ZigZag_Params &_params, IndicatorParams &_iparams, ChartParams &_cparams)
    : params(_params.depth, _params.deviation, _params.backstep),
      Indicator(_iparams, _cparams) {};
  Indi_ZigZag(ZigZag_Params &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
    : params(_params.depth, _params.deviation, _params.backstep),
      Indicator(INDI_ZIGZAG, _tf) {};

  /**
   * Returns value for ZigZag indicator.
   */
  static double iZigZag(
    string _symbol,
    ENUM_TIMEFRAMES _tf,
    int _depth,
    int _deviation,
    int _backstep,
    int _shift = 0,
    Indicator *_obj = NULL
    )
  {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, "ZigZag", _depth, _deviation, _backstep, 0, _shift);
#else // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iCustom(_symbol, _tf, "Examples\\ZigZag", _depth, _deviation, _backstep)) == INVALID_HANDLE) {
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

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _shift = 0) {
    double _value = Indi_ZigZag::iZigZag(GetSymbol(), GetTf(), GetDepth(), GetDeviation(), GetBackstep(), _shift);
    is_ready = _LastError == ERR_NO_ERROR;
    new_params = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  ZigZagEntry GetEntry(int _shift = 0) {
    ZigZagEntry _entry;
    _entry.value = GetValue(_shift);
    return _entry;
  }

    /* Getters */

    /**
     * Get depth.
     */
    unsigned int GetDepth() {
      return this.params.depth;
    }

    /**
     * Get deviation.
     */
    unsigned int GetDeviation() {
      return this.params.deviation;
    }

    /**
     * Get backstep.
     */
    unsigned int GetBackstep() {
      return this.params.backstep;
    }

    /* Setters */

    /**
     * Set depth.
     */
    void SetDepth(unsigned int _depth) {
      new_params = true;
      this.params.depth = _depth;
    }

    /**
     * Set deviation.
     */
    void SetDeviation(unsigned int _deviation) {
      new_params = true;
      this.params.deviation = _deviation;
    }

    /**
     * Set backstep.
     */
    void SetBackstep(unsigned int _backstep) {
      new_params = true;
      this.params.backstep = _backstep;
    }

};

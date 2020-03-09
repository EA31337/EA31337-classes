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
struct GatorParams : IndicatorParams {
  unsigned int jaw_period;           // Jaw line averaging period.
  unsigned int jaw_shift;            // Jaw line shift.
  unsigned int teeth_period;         // Teeth line averaging period.
  unsigned int teeth_shift;          // Teeth line shift.
  unsigned int lips_period;          // Lips line averaging period.
  unsigned int lips_shift;           // Lips line shift.
  ENUM_MA_METHOD ma_method;          // Averaging method.
  ENUM_APPLIED_PRICE applied_price;  // Applied price.
  // Struct constructor.
  void GatorParams(unsigned int _jp, unsigned int _js, unsigned int _tp, unsigned int _ts, unsigned int _lp,
                   unsigned int _ls, ENUM_MA_METHOD _mm, ENUM_APPLIED_PRICE _ap)
      : jaw_period(_jp),
        jaw_shift(_js),
        teeth_period(_tp),
        teeth_shift(_ts),
        lips_period(_lp),
        lips_shift(_ls),
        ma_method(_mm),
        applied_price(_ap) {
    itype = INDI_GATOR;
    max_modes = FINAL_GATOR_LINE_ENTRY;
    SetDataType(TYPE_DOUBLE);
  };
};

/**
 * Implements the Gator oscillator.
 */
class Indi_Gator : public Indicator {
 protected:
  GatorParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_Gator(GatorParams &_p)
      : params(_p.jaw_period, _p.jaw_shift, _p.teeth_period, _p.teeth_shift, _p.lips_period, _p.lips_shift,
               _p.ma_method, _p.applied_price),
        Indicator((IndicatorParams)_p) {}
  Indi_Gator(GatorParams &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.jaw_period, _p.jaw_shift, _p.teeth_period, _p.teeth_shift, _p.lips_period, _p.lips_shift,
               _p.ma_method, _p.applied_price),
        Indicator(INDI_GATOR, _tf) {}

  /**
   * Returns the indicator value.
   *
   * @docs
   * - https://docs.mql4.com/indicators/igator
   * - https://www.mql5.com/en/docs/indicators/igator
   */
  static double iGator(
      string _symbol, ENUM_TIMEFRAMES _tf, unsigned int _jaw_period, unsigned int _jaw_shift,
      unsigned int _teeth_period, unsigned int _teeth_shift, unsigned int _lips_period, unsigned int _lips_shift,
      ENUM_MA_METHOD _ma_method,          // (MT4/MT5): MODE_SMA, MODE_EMA, MODE_SMMA, MODE_LWMA
      ENUM_APPLIED_PRICE _applied_price,  // (MT4/MT5): PRICE_CLOSE, PRICE_OPEN, PRICE_HIGH, PRICE_LOW, PRICE_MEDIAN,
                                          // PRICE_TYPICAL, PRICE_WEIGHTED
      ENUM_GATOR_LINE _mode,              // (MT4 _mode): 1 - MODE_GATORJAW, 2 - MODE_GATORTEETH, 3 - MODE_GATORLIPS
      int _shift = 0,                     // (MT5 _mode): 0 - GATORJAW_LINE, 1 - GATORTEETH_LINE, 2 - GATORLIPS_LINE
      Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iGator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period, _lips_shift,
                    _ma_method, _applied_price, _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.GetState().GetHandle() : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iGator(_symbol, _tf, _jaw_period, _jaw_shift, _teeth_period, _teeth_shift, _lips_period,
                              _lips_shift, _ma_method, _applied_price)) == INVALID_HANDLE) {
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
   * Returns the indicator's value.
   */
  double GetValue(ENUM_GATOR_LINE _mode, int _shift = 0) {
    ResetLastError();
    istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
    double _value = Indi_Gator::iGator(GetSymbol(), GetTf(), GetJawPeriod(), GetJawShift(), GetTeethPeriod(),
                                       GetTeethShift(), GetLipsPeriod(), GetLipsShift(), GetMAMethod(),
                                       GetAppliedPrice(), _mode, _shift, GetPointer(this));
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    IndicatorDataEntry _entry;
    _entry.timestamp = GetBarTime(_shift);
    _entry.value.SetValue(params.dtype, GetValue(LINE_JAW, _shift), LINE_JAW);
    _entry.value.SetValue(params.dtype, GetValue(LINE_TEETH, _shift), LINE_TEETH);
    _entry.value.SetValue(params.dtype, GetValue(LINE_LIPS, _shift), LINE_LIPS);
    _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID,
      !_entry.value.HasValue(params.dtype, (double) NULL)
      && !_entry.value.HasValue(params.dtype, EMPTY_VALUE)
      && _entry.value.GetMinDbl(params.dtype) > 0
    );
    return _entry;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift).value.GetValueDbl(params.dtype, _mode);
    return _param;
  }

  /* Getters */

  /**
   * Get jaw period value.
   */
  unsigned int GetJawPeriod() { return params.jaw_period; }

  /**
   * Get jaw shift value.
   */
  unsigned int GetJawShift() { return params.jaw_shift; }

  /**
   * Get teeth period value.
   */
  unsigned int GetTeethPeriod() { return params.teeth_period; }

  /**
   * Get teeth shift value.
   */
  unsigned int GetTeethShift() { return params.teeth_shift; }

  /**
   * Get lips period value.
   */
  unsigned int GetLipsPeriod() { return params.lips_period; }

  /**
   * Get lips shift value.
   */
  unsigned int GetLipsShift() { return params.lips_shift; }

  /**
   * Get MA method.
   */
  ENUM_MA_METHOD GetMAMethod() { return params.ma_method; }

  /**
   * Get applied price value.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return params.applied_price; }

  /* Setters */

  /**
   * Set jaw period value.
   */
  void SetJawPeriod(unsigned int _jaw_period) {
    istate.is_changed = true;
    params.jaw_period = _jaw_period;
  }

  /**
   * Set jaw shift value.
   */
  void SetJawShift(unsigned int _jaw_shift) {
    istate.is_changed = true;
    params.jaw_shift = _jaw_shift;
  }

  /**
   * Set teeth period value.
   */
  void SetTeethPeriod(unsigned int _teeth_period) {
    istate.is_changed = true;
    params.teeth_period = _teeth_period;
  }

  /**
   * Set teeth shift value.
   */
  void SetTeethShift(unsigned int _teeth_shift) {
    istate.is_changed = true;
    params.teeth_period = _teeth_shift;
  }

  /**
   * Set lips period value.
   */
  void SetLipsPeriod(unsigned int _lips_period) {
    istate.is_changed = true;
    params.lips_period = _lips_period;
  }

  /**
   * Set lips shift value.
   */
  void SetLipsShift(unsigned int _lips_shift) {
    istate.is_changed = true;
    params.lips_period = _lips_shift;
  }

  /**
   * Set MA method.
   */
  void SetMAMethod(ENUM_MA_METHOD _ma_method) {
    istate.is_changed = true;
    params.ma_method = _ma_method;
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
  string ToString(int _shift = 0) { return GetEntry(_shift).value.ToString(params.dtype); }
};

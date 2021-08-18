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
#include "../Indicator.mqh"

// Enums.
// Indicator mode identifiers used in ZigZag indicator.
enum ENUM_ZIGZAG_LINE { ZIGZAG_BUFFER = 0, ZIGZAG_HIGHMAP = 1, ZIGZAG_LOWMAP = 2, FINAL_ZIGZAG_LINE_ENTRY };

// Structs.
struct ZigZagParams : IndicatorParams {
  unsigned int depth;
  unsigned int deviation;
  unsigned int backstep;
  // Struct constructors.
  void ZigZagParams(unsigned int _depth, unsigned int _deviation, unsigned int _backstep, int _shift = 0)
      : depth(_depth), deviation(_deviation), backstep(_backstep) {
    itype = INDI_ZIGZAG;
    max_modes = FINAL_ZIGZAG_LINE_ENTRY;
    shift = _shift;
    SetDataSourceType(IDATA_ICUSTOM);
    SetCustomIndicatorName("Examples\\ZigZag");
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_PRICE);  // @fixit Draws lines between lowest and highest prices!
  };
  void ZigZagParams(ZigZagParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements ZigZag indicator.
 */
class Indi_ZigZag : public Indicator {
 protected:
  ZigZagParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_ZigZag(ZigZagParams &_p) : params(_p.depth, _p.deviation, _p.backstep), Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_ZigZag(ZigZagParams &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.depth, _p.deviation, _p.backstep), Indicator(INDI_ZIGZAG, _tf) {
    params = _p;
  }

  /**
   * Returns value for ZigZag indicator.
   */
  static double iZigZag(string _symbol, ENUM_TIMEFRAMES _tf, int _depth, int _deviation, int _backstep,
                        ENUM_ZIGZAG_LINE _mode = 0, int _shift = 0, Indicator *_obj = NULL) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, "ZigZag", _depth, _deviation, _backstep, _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iCustom(_symbol, _tf, "Examples\\ZigZag", _depth, _deviation, _backstep)) == INVALID_HANDLE) {
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
      return EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(ENUM_ZIGZAG_LINE _mode, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_BUILTIN:
        break;
      case IDATA_ICUSTOM:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = Indi_ZigZag::iZigZag(Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF), GetDepth(),
                                      GetDeviation(), GetBackstep(), _mode, _shift, GetPointer(this));
        break;
      case IDATA_INDICATOR:
        // @todo: Add custom calculation.
        break;
    }
    istate.is_ready = _value != EMPTY_VALUE && _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry(params.max_modes);
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (int _mode = 0; _mode < (int)params.max_modes; _mode++) {
        _entry.values[_mode] = GetValue((ENUM_ZIGZAG_LINE)_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(EMPTY_VALUE));
      if (_entry.IsValid()) {
        _entry.AddFlags(_entry.GetDataTypeFlag(params.GetDataValueType()));
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
    GetEntry(_shift).values[_mode].Get(_param.double_value);
    return _param;
  }

  /* Getters */

  /**
   * Get depth.
   */
  unsigned int GetDepth() { return params.depth; }

  /**
   * Get deviation.
   */
  unsigned int GetDeviation() { return params.deviation; }

  /**
   * Get backstep.
   */
  unsigned int GetBackstep() { return params.backstep; }

  /* Setters */

  /**
   * Set depth.
   */
  void SetDepth(unsigned int _depth) {
    istate.is_changed = true;
    params.depth = _depth;
  }

  /**
   * Set deviation.
   */
  void SetDeviation(unsigned int _deviation) {
    istate.is_changed = true;
    params.deviation = _deviation;
  }

  /**
   * Set backstep.
   */
  void SetBackstep(unsigned int _backstep) {
    istate.is_changed = true;
    params.backstep = _backstep;
  }
};

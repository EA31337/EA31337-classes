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
#include "../../BufferStruct.mqh"
#include "../../Indicator.mqh"
#include "../../Math.enum.h"

enum ENUM_MATH_OP_MODE { MATH_OP_MODE_BUILTIN, MATH_OP_MODE_CUSTOM_FUNCTION };

typedef double (*MathCustomOpFunction)(double a, double b);

// Structs.
struct MathParams : IndicatorParams {
  ENUM_MATH_OP_MODE op_mode;
  ENUM_MATH_OP op_builtin;
  MathCustomOpFunction op_fn;
  unsigned int mode_1;
  unsigned int mode_2;
  unsigned int shift_1;
  unsigned int shift_2;

  // Struct constructor.
  void MathParams(ENUM_MATH_OP _op = MATH_OP_SUB, unsigned int _mode_1 = 0, unsigned int _mode_2 = 1,
                  unsigned int _shift_1 = 0, unsigned int _shift_2 = 0, int _shift = 0,
                  ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_SPECIAL_MATH;
    max_modes = 1;
    mode_1 = _mode_1;
    mode_2 = _mode_2;
    op_builtin = _op;
    op_mode = MATH_OP_MODE_BUILTIN;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetDataSourceType(IDATA_INDICATOR);
    shift = _shift;
    shift_1 = _shift_1;
    shift_2 = _shift_2;
    tf = _tf;
  };

  // Struct constructor.
  void MathParams(MathCustomOpFunction _op, unsigned int _mode_1 = 0, unsigned int _mode_2 = 1,
                  unsigned int _shift_1 = 0, unsigned int _shift_2 = 0, int _shift = 0,
                  ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_SPECIAL_MATH;
    max_modes = 1;
    mode_1 = _mode_1;
    mode_2 = _mode_2;
    op_fn = _op;
    op_mode = MATH_OP_MODE_CUSTOM_FUNCTION;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetDataSourceType(IDATA_INDICATOR);
    shift = _shift;
    shift_1 = _shift_1;
    shift_2 = _shift_2;
    tf = _tf;
  };

  void MathParams(MathParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Volume Rate of Change indicator.
 */
class Indi_Math : public Indicator {
 protected:
  MathParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_Math(MathParams &_params) : Indicator((IndicatorParams)_params) { params = _params; };
  Indi_Math(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_SPECIAL_MATH, _tf) { params.tf = _tf; };

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_INDICATOR:
        if (GetDataSource() == NULL) {
          Logger().Error(
              "In order use custom indicator as a source, you need to select one using SetIndicatorData() method, "
              "which is a part of MathParams structure.",
              "Indi_Math");
          Alert(
              "Indi_Math: In order use custom indicator as a source, you need to select one using SetIndicatorData() "
              "method, which is a part of MathParams structure.");
          SetUserError(ERR_INVALID_PARAMETER);
          return _value;
        }
        switch (params.op_mode) {
          case MATH_OP_MODE_BUILTIN:
            _value = Indi_Math::iMathOnIndicator(GetDataSource(), Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                                                 /*[*/ GetOpBuiltIn(), GetMode1(), GetMode2(), GetShift1(),
                                                 GetShift2() /*]*/, 0, _shift, &this);
            break;
          case MATH_OP_MODE_CUSTOM_FUNCTION:
            _value = Indi_Math::iMathOnIndicator(GetDataSource(), Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                                                 /*[*/ GetOpFunction(), GetMode1(), GetMode2(), GetShift1(),
                                                 GetShift2() /*]*/, 0, _shift, &this);
            break;
        }
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    istate.is_ready = _LastError == ERR_NO_ERROR;
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
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE));
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
    _param.double_value = GetEntry(_shift)[_mode];
    return _param;
  }

  static double iMathOnIndicator(Indicator *_indi, string _symbol, ENUM_TIMEFRAMES _tf, ENUM_MATH_OP op,
                                 unsigned int _mode_1, unsigned int _mode_2, unsigned int _shift_1,
                                 unsigned int _shift_2, unsigned int _mode, int _shift, Indicator *_obj) {
    double _val_1 = _indi.GetValue<double>(_shift_1, _mode_1);
    double _val_2 = _indi.GetValue<double>(_shift_2, _mode_2);
    return Math::Op(op, _val_1, _val_2);
  }

  static double iMathOnIndicator(Indicator *_indi, string _symbol, ENUM_TIMEFRAMES _tf, MathCustomOpFunction _op,
                                 unsigned int _mode_1, unsigned int _mode_2, unsigned int _shift_1,
                                 unsigned int _shift_2, unsigned int _mode, int _shift, Indicator *_obj) {
    double _val_1 = _indi.GetValue<double>(_shift_1, _mode_1);
    double _val_2 = _indi.GetValue<double>(_shift_2, _mode_2);
    return _op(_val_1, _val_2);
  }

  /* Getters */

  /**
   * Get math operation.
   */
  ENUM_MATH_OP GetOpBuiltIn() { return params.op_builtin; }

  /**
   * Get math operation.
   */
  MathCustomOpFunction GetOpFunction() { return params.op_fn; }

  /**
   * Get mode 1.
   */
  unsigned int GetMode1() { return params.mode_1; }

  /**
   * Get mode 2.
   */
  unsigned int GetMode2() { return params.mode_2; }

  /**
   * Get shift 1.
   */
  unsigned int GetShift1() { return params.shift_1; }

  /**
   * Get shift 2.
   */
  unsigned int GetShift2() { return params.shift_2; }

  /* Setters */

  /**
   * Set math operation.
   */
  void SetOp(ENUM_MATH_OP _op) {
    istate.is_changed = true;
    params.op_builtin = _op;
    params.op_mode = MATH_OP_MODE_BUILTIN;
  }

  /**
   * Set math operation.
   */
  void SetOp(MathCustomOpFunction _op) {
    istate.is_changed = true;
    params.op_fn = _op;
    params.op_mode = MATH_OP_MODE_CUSTOM_FUNCTION;
  }

  /**
   * Set mode 1.
   */
  void SetMode1(unsigned int _mode_1) {
    istate.is_changed = true;
    params.mode_1 = _mode_1;
  }

  /**
   * Set mode 2.
   */
  void SetMode2(unsigned int _mode_2) {
    istate.is_changed = true;
    params.mode_2 = _mode_2;
  }

  /**
   * Set shift 1.
   */
  void SetShift1(unsigned int _shift_1) {
    istate.is_changed = true;
    params.shift_1 = _shift_1;
  }

  /**
   * Set shift 2.
   */
  void SetShift3(unsigned int _shift_2) {
    istate.is_changed = true;
    params.shift_2 = _shift_2;
  }

  /**
   * Whether we can and have to select mode when specifying data source.
   */
  virtual bool IsDataSourceModeSelectable() { return false; }
};

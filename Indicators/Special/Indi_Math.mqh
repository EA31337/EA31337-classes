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
#include "../../Indicator/Indicator.h"
#include "../../Math.enum.h"

enum ENUM_MATH_OP_MODE { MATH_OP_MODE_BUILTIN, MATH_OP_MODE_CUSTOM_FUNCTION };

typedef double (*MathCustomOpFunction)(double a, double b);

// Structs.
struct IndiMathParams : IndicatorParams {
  ENUM_MATH_OP_MODE op_mode;
  ENUM_MATH_OP op_builtin;
  MathCustomOpFunction op_fn;
  unsigned int mode_1;
  unsigned int mode_2;
  unsigned int shift_1;
  unsigned int shift_2;

  // Struct constructor.
  IndiMathParams(ENUM_MATH_OP _op = MATH_OP_SUB, unsigned int _mode_1 = 0, unsigned int _mode_2 = 1,
                 unsigned int _shift_1 = 0, unsigned int _shift_2 = 0, int _shift = 0)
      : IndicatorParams(INDI_SPECIAL_MATH) {
    mode_1 = _mode_1;
    mode_2 = _mode_2;
    op_builtin = _op;
    op_mode = MATH_OP_MODE_BUILTIN;
    shift = _shift;
    shift_1 = _shift_1;
    shift_2 = _shift_2;
  };

  // Struct constructor.
  IndiMathParams(MathCustomOpFunction _op, unsigned int _mode_1 = 0, unsigned int _mode_2 = 1,
                 unsigned int _shift_1 = 0, unsigned int _shift_2 = 0, int _shift = 0)
      : IndicatorParams(INDI_SPECIAL_MATH) {
    mode_1 = _mode_1;
    mode_2 = _mode_2;
    op_fn = _op;
    op_mode = MATH_OP_MODE_CUSTOM_FUNCTION;
    shift = _shift;
    shift_1 = _shift_1;
    shift_2 = _shift_2;
  };
  IndiMathParams(IndiMathParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Volume Rate of Change indicator.
 */
class Indi_Math : public Indicator<IndiMathParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_Math(IndiMathParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_INDICATOR, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  Indi_Math(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_INDICATOR, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(IndiMathParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override {
    return INDI_SUITABLE_DS_TYPE_CUSTOM | INDI_SUITABLE_DS_TYPE_BASE_ONLY;
  }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_INDICATOR; }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiMathParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // RS uses OHLC.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_OPEN) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_LOW) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_CLOSE);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_INDICATOR:
        if (!indi_src.IsSet()) {
          GetLogger().Error(
              "In order use custom indicator as a source, you need to select one using SetIndicatorData() method, "
              "which is a part of IndiMathParams structure.",
              "Indi_Math");
          Alert(
              "Indi_Math: In order use custom indicator as a source, you need to select one using SetIndicatorData() "
              "method, which is a part of IndiMathParams structure.");
          SetUserError(ERR_INVALID_PARAMETER);
          return _value;
        }
        switch (iparams.op_mode) {
          case MATH_OP_MODE_BUILTIN:
            _value = Indi_Math::iMathOnIndicator(GetDataSource(), GetSymbol(), GetTf(),
                                                 /*[*/ GetOpBuiltIn(), GetMode1(), GetMode2(), GetShift1(),
                                                 GetShift2() /*]*/, 0, _ishift, &this);
            break;
          case MATH_OP_MODE_CUSTOM_FUNCTION:
            _value = Indi_Math::iMathOnIndicator(GetDataSource(), GetSymbol(), GetTf(),
                                                 /*[*/ GetOpFunction(), GetMode1(), GetMode2(), GetShift1(),
                                                 GetShift2() /*]*/, 0, _ishift, &this);
            break;
        }
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _value;
  }

  static double iMathOnIndicator(IndicatorData *_indi, string _symbol, ENUM_TIMEFRAMES _tf, ENUM_MATH_OP op,
                                 unsigned int _mode_1, unsigned int _mode_2, unsigned int _shift_1,
                                 unsigned int _shift_2, unsigned int _mode, int _shift, Indi_Math *_obj) {
    double _val_1 = _indi.GetValue<double>(_mode_1, _shift_1);
    double _val_2 = _indi.GetValue<double>(_mode_2, _shift_2);
    return Math::Op(op, _val_1, _val_2);
  }

  static double iMathOnIndicator(IndicatorData *_indi, string _symbol, ENUM_TIMEFRAMES _tf, MathCustomOpFunction _op,
                                 unsigned int _mode_1, unsigned int _mode_2, unsigned int _shift_1,
                                 unsigned int _shift_2, unsigned int _mode, int _shift, Indi_Math *_obj) {
    double _val_1 = _indi.GetValue<double>(_mode_1, _shift_1);
    double _val_2 = _indi.GetValue<double>(_mode_2, _shift_2);
    return _op(_val_1, _val_2);
  }

  /* Getters */

  /**
   * Get math operation.
   */
  ENUM_MATH_OP GetOpBuiltIn() { return iparams.op_builtin; }

  /**
   * Get math operation.
   */
  MathCustomOpFunction GetOpFunction() { return iparams.op_fn; }

  /**
   * Get mode 1.
   */
  unsigned int GetMode1() { return iparams.mode_1; }

  /**
   * Get mode 2.
   */
  unsigned int GetMode2() { return iparams.mode_2; }

  /**
   * Get shift 1.
   */
  unsigned int GetShift1() { return iparams.shift_1; }

  /**
   * Get shift 2.
   */
  unsigned int GetShift2() { return iparams.shift_2; }

  /* Setters */

  /**
   * Set math operation.
   */
  void SetOp(ENUM_MATH_OP _op) {
    istate.is_changed = true;
    iparams.op_builtin = _op;
    iparams.op_mode = MATH_OP_MODE_BUILTIN;
  }

  /**
   * Set math operation.
   */
  void SetOp(MathCustomOpFunction _op) {
    istate.is_changed = true;
    iparams.op_fn = _op;
    iparams.op_mode = MATH_OP_MODE_CUSTOM_FUNCTION;
  }

  /**
   * Set mode 1.
   */
  void SetMode1(unsigned int _mode_1) {
    istate.is_changed = true;
    iparams.mode_1 = _mode_1;
  }

  /**
   * Set mode 2.
   */
  void SetMode2(unsigned int _mode_2) {
    istate.is_changed = true;
    iparams.mode_2 = _mode_2;
  }

  /**
   * Set shift 1.
   */
  void SetShift1(unsigned int _shift_1) {
    istate.is_changed = true;
    iparams.shift_1 = _shift_1;
  }

  /**
   * Set shift 2.
   */
  void SetShift3(unsigned int _shift_2) {
    istate.is_changed = true;
    iparams.shift_2 = _shift_2;
  }

  /**
   * Whether we can and have to select mode when specifying data source.
   */
  virtual bool IsDataSourceModeSelectable() { return false; }
};

//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
#include "../BufferStruct.mqh"
#include "../Indicator/IndicatorTickOrCandleSource.h"
#include "../Storage/ValueStorage.all.h"

// Structs.
struct IndiASIParams : IndicatorParams {
  unsigned int period;
  double mpc;
  // Struct constructor.
  IndiASIParams(double _mpc = 300.0, int _shift = 0) : IndicatorParams(INDI_ASI, PERIOD_CURRENT) {
    SetCustomIndicatorName("Examples\\ASI");
    mpc = _mpc;
    shift = _shift;
  };
  IndiASIParams(IndiASIParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_ASI : public IndicatorTickOrCandleSource<IndiASIParams> {
 protected:
  /* Protected methods */

  /**
   * Initialize.
   */
  void Init() {
    if (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE)) == IDATA_BUILTIN) {
      Set<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE), IDATA_ONCALCULATE);
    }
  }

 public:
  /**
   * Class constructor.
   */
  Indi_ASI(IndiASIParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_ONCALCULATE, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : IndicatorTickOrCandleSource(
            _p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
            _indi_src) {
    Init();
  };
  Indi_ASI(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : IndicatorTickOrCandleSource(INDI_ASI, _tf, _shift) {
    Init();
  };

  /**
   * Built-in version of ASI.
   */
  static double iASI(string _symbol, ENUM_TIMEFRAMES _tf, double _mpc, int _mode = 0, int _shift = 0,
                     IndicatorData *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_symbol, _tf, Util::MakeKey("Indi_ASI", _mpc));
    return iASIOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mpc, _mode, _shift, _cache);
  }

  /**
   * Calculates ASI on the array of values.
   */
  static double iASIOnArray(INDICATOR_CALCULATE_PARAMS_LONG, double _mpc, int _mode, int _shift,
                            IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(3);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_ASI::Calculate(INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0),
                                                 _cache.GetBuffer<double>(1), _cache.GetBuffer<double>(2), _mpc));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * On-indicator version of ASI.
   */
  static double iASIOnIndicator(IndicatorData *_indi, string _symbol, ENUM_TIMEFRAMES _tf, double _mpc, int _mode = 0,
                                int _shift = 0, IndicatorData *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG_DS(_indi, _symbol, _tf,
                                                          Util::MakeKey("Indi_ASI_ON_" + _indi.GetFullName(), _mpc));
    return iASIOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mpc, _mode, _shift, _cache);
  }

  /**
   * OnInit() method for ASI indicator.
   */
  static void CalculateInit(double InpT, double &ExtTpoints, double &ExtT) {
    // Check for input value.
    if (MathAbs(InpT) > 1e-7)
      ExtT = InpT;
    else {
      ExtT = 300.0;
      PrintFormat("Input parameter T has wrong value. Indicator will use T = %f.", ExtT);
    }
    // Calculate ExtTpoints value.
    if (_Point > 1e-7)
      ExtTpoints = ExtT * _Point;
    else
      ExtTpoints = ExtT * MathPow(10, -_Digits);
  }

  /**
   * OnCalculate() method for ASI indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtASIBuffer,
                       ValueStorage<double> &ExtSIBuffer, ValueStorage<double> &ExtTRBuffer, double InpT) {
    double ExtTpoints, ExtT;

    CalculateInit(InpT, ExtTpoints, ExtT);

    if (rates_total < 2) return (0);
    // Start calculation.
    int pos = prev_calculated - 1;
    // Correct position, when it's first iteration.
    if (pos <= 0) {
      pos = 1;
      ExtASIBuffer[0] = 0.0;
      ExtSIBuffer[0] = 0.0;
      ExtTRBuffer[0] = high[0] - low[0];
    }
    // Main cycle.
    for (int i = pos; i < rates_total && !IsStopped(); i++) {
      // Get some data.
      double dPrevClose = close[i - 1].Get();
      double dPrevOpen = open[i - 1].Get();
      double dClose = close[i].Get();
      double dHigh = high[i].Get();
      double dLow = low[i].Get();
      // Fill TR buffer.
      ExtTRBuffer[i] = MathMax(dHigh, dPrevClose) - MathMin(dLow, dPrevClose);
      double ER = 0.0;
      if (!(dPrevClose >= dLow && dPrevClose <= dHigh)) {
        if (dPrevClose > dHigh) ER = MathAbs(dHigh - dPrevClose);
        if (dPrevClose < dLow) ER = MathAbs(dLow - dPrevClose);
      }
      double K = MathMax(MathAbs(dHigh - dPrevClose), MathAbs(dLow - dPrevClose));
      double SH = MathAbs(dPrevClose - dPrevOpen);
      double R = ExtTRBuffer[i] - 0.5 * ER + 0.25 * SH;
      // Calculate SI value.
      if (R == 0.0 || ExtTpoints == 0.0)
        ExtSIBuffer[i] = 0.0;
      else
        ExtSIBuffer[i] = 50 * (dClose - dPrevClose + 0.5 * (dClose - open[i].Get()) + 0.25 * (dPrevClose - dPrevOpen)) *
                         (K / ExtTpoints) / R;
      // Write down ASI buffer value.
      ExtASIBuffer[i] = ExtASIBuffer[i - 1] + ExtSIBuffer[i];
    }
    // OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(),
                         /*[*/ GetMaximumPriceChanging() /*]*/, 0, _ishift);
        break;
      case IDATA_ONCALCULATE: {
        INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(GetSymbol(), GetTf(),
                                                           Util::MakeKey("Indi_ASI", GetMaximumPriceChanging()));
        _value =
            iASIOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, GetMaximumPriceChanging(), _mode, _ishift, _cache);
      } break;
      case IDATA_INDICATOR:
        _value = Indi_ASI::iASIOnIndicator(GetDataSource(), GetSymbol(), GetTf(), /*[*/ GetMaximumPriceChanging() /*]*/,
                                           _mode, _ishift, THIS_PTR);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get maximum price changing value.
   */
  double GetMaximumPriceChanging() { return iparams.mpc; }

  /* Setters */

  /**
   * Set maximum price changing value.
   */
  void GetMaximumPriceChanging(double _mpc) {
    istate.is_changed = true;
    iparams.mpc = _mpc;
  }
};

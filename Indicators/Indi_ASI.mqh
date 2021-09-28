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
#include "../BufferStruct.mqh"
#include "../Indicator.mqh"
#include "../Storage/ValueStorage.all.h"

// Structs.
struct ASIParams : IndicatorParams {
  unsigned int period;
  double mpc;
  // Struct constructor.
  void ASIParams(double _mpc = 300.0, int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    itype = INDI_ASI;
    max_modes = 1;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\ASI");
    SetDataSourceType(IDATA_BUILTIN);
    mpc = _mpc;
    shift = _shift;
    tf = _tf;
  };
  void ASIParams(ASIParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_ASI : public Indicator<ASIParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_ASI(ASIParams &_params) : iparams(_params.mpc), Indicator<ASIParams>(_params){};
  Indi_ASI(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_ASI, _tf){};

  /**
   * Built-in version of ASI.
   */
  static double iASI(string _symbol, ENUM_TIMEFRAMES _tf, double _mpc, int _mode = 0, int _shift = 0,
                     Indicator<ASIParams> *_obj = NULL) {
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
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_ASI::iASI(GetSymbol(), GetTf(), /*[*/ GetMaximumPriceChanging() /*]*/, _mode, _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(),
                         /*[*/ GetMaximumPriceChanging() /*]*/, 0, _shift);
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
    IndicatorDataEntry _entry(iparams.GetMaxModes());
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (int _mode = 0; _mode < (int)iparams.GetMaxModes(); _mode++) {
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE));
      if (_entry.IsValid()) {
        _entry.AddFlags(_entry.GetDataTypeFlag(iparams.GetDataValueType()));
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

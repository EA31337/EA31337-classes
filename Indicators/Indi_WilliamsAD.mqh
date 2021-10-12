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
struct WilliamsADParams : IndicatorParams {
  // Struct constructor.
  void WilliamsADParams(int _shift = 0) : IndicatorParams(INDI_WILLIAMS_AD, 1, TYPE_DOUBLE) {
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\W_AD");
    shift = _shift;
  };
};

/**
 * Implements the Volume Rate of Change indicator.
 */
class Indi_WilliamsAD : public Indicator<WilliamsADParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_WilliamsAD(WilliamsADParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<WilliamsADParams>(_p, _indi_src){};
  Indi_WilliamsAD(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_WILLIAMS_AD, _tf){};

  /**
   * Built-in version of Williams' AD.
   */
  static double iWAD(string _symbol, ENUM_TIMEFRAMES _tf, int _mode = 0, int _shift = 0, IndicatorBase *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_symbol, _tf, "Indi_WilliamsAD");
    return iWADOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mode, _shift, _cache);
  }

  /**
   * Calculates William's AD on the array of values.
   */
  static double iWADOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _mode, int _shift,
                            IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(1);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(
        Indi_WilliamsAD::Calculate(INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0)));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for Williams' AD indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtWADBuffer) {
    if (rates_total < 2) return (0);
    int pos = prev_calculated - 1;
    if (pos < 1) {
      pos = 1;
      ExtWADBuffer[0] = 0.0;
    }
    // Main cycle.
    for (int i = pos; i < rates_total && !IsStopped(); i++) {
      // Get data.
      double hi = high[i].Get();
      double lo = low[i].Get();
      double cl = close[i].Get();
      double prev_cl = close[i - 1].Get();
      // Calculate TRH and TRL.
      double trh = MathMax(hi, prev_cl);
      double trl = MathMin(lo, prev_cl);
      // Calculate WA/D.
      if (IsEqualDoubles(cl, prev_cl, _Point)) {
        ExtWADBuffer[i] = ExtWADBuffer[i - 1];
      } else {
        ExtWADBuffer[i] = (cl > prev_cl) ? ExtWADBuffer[i - 1] + cl - trl : ExtWADBuffer[i - 1] + cl - trh;
      }
    }
    // OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  static bool IsEqualDoubles(double d1, double d2, double epsilon) {
    if (epsilon < 0.0) epsilon = -epsilon;
    if (epsilon > 0.1) epsilon = 0.00001;
    double diff = d1 - d2;
    if (diff > epsilon || diff < -epsilon) {
      return (false);
    }
    return true;
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_WilliamsAD::iWAD(GetSymbol(), GetTf(), _mode, _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), 0, _shift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    istate.is_ready = _LastError == ERR_NO_ERROR;
    istate.is_changed = false;
    return _value;
  }

  /**
   * Returns the indicator's entry value.
   */
  MqlParam GetEntryValue(int _shift = 0, int _mode = 0) {
    MqlParam _param = {TYPE_DOUBLE};
    _param.double_value = GetEntry(_shift)[_mode];
    return _param;
  }
};

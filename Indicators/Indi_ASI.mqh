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
#include "../Indicator/Indicator.h"
#include "../Storage/ValueStorage.all.h"

// Structs.
struct IndiASIParams : IndicatorParams {
  unsigned int period;
  double mpc;
  // Struct constructor.
  IndiASIParams(double _mpc = 300.0, int _shift = 0) : IndicatorParams(INDI_ASI) {
    SetCustomIndicatorName("Examples\\ASI");
    mpc = _mpc;
    shift = _shift;
  };
};

/**
 * Implements the Bill Williams' Accelerator/Decelerator oscillator.
 */
class Indi_ASI : public Indicator<IndiASIParams> {
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
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {
    Init();
  };
  Indi_ASI(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_ONCALCULATE, IndicatorData *_indi_src = NULL,
           int _indi_src_mode = 0)
      : Indicator(IndiASIParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {
    Init();
  };

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override {
    return INDI_SUITABLE_DS_TYPE_CUSTOM | INDI_SUITABLE_DS_TYPE_BASE_ONLY;
  }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR; }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiASIParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }
    // RS uses OHLC.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_OPEN) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_LOW) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_CLOSE);
  }

  /**
   * OnCalculate-based version of ASI as there is no built-in one.
   */
  static double iASI(IndicatorData *_indi, double _mpc, int _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, Util::MakeKey(_mpc));
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

    // Print("- ASI cycle " + IntegerToString(pos) + " - " + IntegerToString(rates_total));

    // Main cycle.
    for (int i = pos; i < rates_total && !IsStopped(); i++) {
      // Get some data.

      // Print("Prev: "+ StringifyOHLC(open, high, low, close, i-3));
      // Print("Prev: "+ StringifyOHLC(open, high, low, close, i-2));
      // Print("Prev: "+ StringifyOHLC(open, high, low, close, i-1));
      // Print("Curr: "+ StringifyOHLC(open, high, low, close, i));

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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(),
                         /*[*/ GetMaximumPriceChanging() /*]*/, 0, _ishift);
        break;
      case IDATA_ONCALCULATE:
        _value = Indi_ASI::iASI(THIS_PTR, GetMaximumPriceChanging(), _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_ASI::iASI(THIS_PTR, GetMaximumPriceChanging(), _mode, _ishift);
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

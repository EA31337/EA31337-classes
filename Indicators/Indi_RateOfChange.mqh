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

// Structs.
struct RateOfChangeParams : IndicatorParams {
  unsigned int period;
  ENUM_APPLIED_PRICE applied_price;
  // Struct constructor.
  void RateOfChangeParams(int _period = 12, ENUM_APPLIED_PRICE _ap = PRICE_CLOSE, int _shift = 0,
                          ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    applied_price = _ap;
    itype = INDI_RATE_OF_CHANGE;
    max_modes = 1;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetCustomIndicatorName("Examples\\ROC");
    SetDataSourceType(IDATA_BUILTIN);
    period = _period;
    shift = _shift;
    tf = _tf;
  };
  void RateOfChangeParams(RateOfChangeParams &_params, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) {
    this = _params;
    tf = _tf;
  };
};

/**
 * Implements the Rate of Change indicator.
 */
class Indi_RateOfChange : public Indicator<RateOfChangeParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_RateOfChange(RateOfChangeParams &_params) : Indicator<RateOfChangeParams>(_params){};
  Indi_RateOfChange(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_RATE_OF_CHANGE, _tf){};

  /**
   * Built-in version of Rate of Change.
   */
  static double iROC(string _symbol, ENUM_TIMEFRAMES _tf, int _period, ENUM_APPLIED_PRICE _ap, int _mode = 0,
                     int _shift = 0, Indicator<RateOfChangeParams> *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT(_symbol, _tf, _ap,
                                                        Util::MakeKey("Indi_RateOfChange", _period, (int)_ap));
    return iROCOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_SHORT, _period, _mode, _shift, _cache);
  }

  /**
   * Calculates Rate of Change on the array of values.
   */
  static double iROCOnArray(INDICATOR_CALCULATE_PARAMS_SHORT, int _period, int _mode, int _shift,
                            IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_price);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(1);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(
        Indi_RateOfChange::Calculate(INDICATOR_CALCULATE_GET_PARAMS_SHORT, _cache.GetBuffer<double>(0), _period));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for Rate of Change indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_SHORT, ValueStorage<double> &ExtRocBuffer, int ExtRocPeriod) {
    if (rates_total < ExtRocPeriod) return (0);
    // Preliminary calculations.
    int pos = prev_calculated - 1;
    if (pos < ExtRocPeriod) pos = ExtRocPeriod;
    // The main loop of calculations.
    for (int i = pos; i < rates_total && !IsStopped(); i++) {
      if (price[i] == 0.0)
        ExtRocBuffer[i] = 0.0;
      else
        ExtRocBuffer[i] = (price[i] - price[i - ExtRocPeriod]) / price[i].Get() * 100;
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
        _value = Indi_RateOfChange::iROC(GetSymbol(), GetTf(), /*[*/ GetPeriod(), GetAppliedPrice() /*]*/, _mode,
                                         _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/,
                         0, _shift);
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
   * Get applied price.
   */
  ENUM_APPLIED_PRICE GetAppliedPrice() { return iparams.applied_price; }

  /**
   * Get period.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /* Setters */

  /**
   * Set applied price.
   */
  void SetAppliedPrice(ENUM_APPLIED_PRICE _applied_price) {
    istate.is_changed = true;
    iparams.applied_price = _applied_price;
  }

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }
};

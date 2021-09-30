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

/*
 * @file
 * Heiken Ashi indicator.
 *
 * Doesn't give independent signals. Is used to define volatility (trend strength).
 */

// Includes.
#include "../Indicator.mqh"
#include "../Storage/ValueStorage.all.h"

// Enums.
enum ENUM_HA_MODE {
#ifdef __MQL4__
  HA_HIGH = 0,
  HA_LOW = 1,
  HA_OPEN = 2,
  HA_CLOSE = 3,
#else
  HA_OPEN = 0,
  HA_HIGH = 1,
  HA_LOW = 2,
  HA_CLOSE = 3,
#endif
  FINAL_HA_MODE_ENTRY
};

// Structs.
struct HeikenAshiParams : IndicatorParams {
  // Struct constructors.
  void HeikenAshiParams(int _shift = 0) {
    itype = INDI_HEIKENASHI;
    max_modes = FINAL_HA_MODE_ENTRY;
    SetDataValueType(TYPE_DOUBLE);
    SetDataValueRange(IDATA_RANGE_MIXED);  // @fixit It draws candles!
#ifdef __MQL4__
    SetCustomIndicatorName("Heiken Ashi");
#else
    SetCustomIndicatorName("Examples\\Heiken_Ashi");
#endif
    shift = _shift;
  };
};

/**
 * Implements the Heiken-Ashi indicator.
 */
class Indi_HeikenAshi : public Indicator<HeikenAshiParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_HeikenAshi(HeikenAshiParams &_p) : Indicator<HeikenAshiParams>(_p) {}
  Indi_HeikenAshi(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_HEIKENASHI, _tf) {}

  /**
   * Returns value for iHeikenAshi indicator.
   */
  static double iCustomLegacyHeikenAshi(string _symbol, ENUM_TIMEFRAMES _tf, string _name, int _mode, int _shift = 0,
                                        IndicatorBase *_obj = NULL) {
#ifdef __MQL4__
    // Low and High prices could be in reverse order when using MT4's built-in indicator, so we need to retrieve both
    // and return correct one.
    if (_mode == HA_HIGH || _mode == HA_LOW) {
      double low = ::iCustom(_symbol, _tf, "Heiken Ashi", HA_LOW, _shift);
      double high = ::iCustom(_symbol, _tf, "Heiken Ashi", HA_HIGH, _shift);

      switch (_mode) {
        case HA_HIGH:
          return MathMax(low, high);
        case HA_LOW:
          return MathMin(low, high);
      }
    }
    return ::iCustom(_symbol, _tf, "Heiken Ashi", _mode, _shift);
#else  // __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    ResetLastError();
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iCustom(_symbol, _tf, "Examples\\Heiken_Ashi")) == INVALID_HANDLE) {
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
   * "Built-in" version of Heiken Ashi.
   */
  static double iHeikenAshi(string _symbol, ENUM_TIMEFRAMES _tf, int _mode = 0, int _shift = 0,
                            Indi_HeikenAshi *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_symbol, _tf, "Indi_HeikenAshi");
    return iHeikenAshiOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _mode, _shift, _cache);
  }

  /**
   * Calculates Heiken Ashi on the array of values.
   */
  static double iHeikenAshiOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _mode, int _shift,
                                   IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(1 + 4);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_HeikenAshi::Calculate(
        INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0), _cache.GetBuffer<double>(1),
        _cache.GetBuffer<double>(2), _cache.GetBuffer<double>(3), _cache.GetBuffer<double>(4)));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for Mass Index indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtLBuffer,
                       ValueStorage<double> &ExtHBuffer, ValueStorage<double> &ExtOBuffer,
                       ValueStorage<double> &ExtCBuffer, ValueStorage<double> &ExtColorBuffer) {
    int start;
    // Preliminary calculations.
    if (prev_calculated == 0) {
      ExtLBuffer[0] = low[0];
      ExtHBuffer[0] = high[0];
      ExtOBuffer[0] = open[0];
      ExtCBuffer[0] = close[0];
      start = 1;
    } else
      start = prev_calculated - 1;

    // The main loop of calculations.
    for (int i = start; i < rates_total && !IsStopped(); i++) {
      double ha_open = (ExtOBuffer[i - 1] + ExtCBuffer[i - 1]) / 2;
      double ha_close = (open[i].Get() + high[i].Get() + low[i].Get() + close[i].Get()) / 4;
      double ha_high = MathMax(high[i].Get(), MathMax(ha_open, ha_close));
      double ha_low = MathMin(low[i].Get(), MathMin(ha_open, ha_close));

      ExtLBuffer[i] = ha_low;
      ExtHBuffer[i] = ha_high;
      ExtOBuffer[i] = ha_open;
      ExtCBuffer[i] = ha_close;

      // Set candle color.
      ExtColorBuffer[i] = (ha_open < ha_close) ? 0.0 : 1.0;
    }
    return (rates_total);
  }

  /**
   * Returns the indicator's value.
   */
  double GetValue(ENUM_HA_MODE _mode, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        _value = Indi_HeikenAshi::iHeikenAshi(GetSymbol(), GetTf(), _mode, _shift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode, _shift);
        break;
      case IDATA_ICUSTOM_LEGACY:
        istate.handle = istate.is_changed ? INVALID_HANDLE : istate.handle;
        _value = Indi_HeikenAshi::iCustomLegacyHeikenAshi(GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode,
                                                          _shift, THIS_PTR);
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
        _entry.values[_mode] = GetValue((ENUM_HA_MODE)_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, !_entry.HasValue<double>(NULL) &&
                                                   !_entry.HasValue<double>(EMPTY_VALUE) && _entry.IsGt<double>(0) &&
                                                   _entry.values[HA_LOW].GetDbl() < _entry.values[HA_HIGH].GetDbl());
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
    GetEntry(_shift).values[_mode].Get(_param.double_value);
    return _param;
  }
};

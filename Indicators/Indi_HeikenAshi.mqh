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
#include "../Indicator/Indicator.h"
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
struct IndiHeikenAshiParams : IndicatorParams {
  // Struct constructors.
  IndiHeikenAshiParams(int _shift = 0) : IndicatorParams(INDI_HEIKENASHI) {
    if (custom_indi_name == "") {
#ifdef __MQL4__
      SetCustomIndicatorName("Heiken Ashi");
#else
      SetCustomIndicatorName("Examples\\Heiken_Ashi");
#endif
    }
    shift = _shift;
  };
  IndiHeikenAshiParams(IndiHeikenAshiParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Heiken-Ashi indicator.
 */
class Indi_HeikenAshi : public Indicator<IndiHeikenAshiParams> {
 protected:
  /* Protected methods */

  /**
   * Initialize.
   */
  void Init() { Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES), FINAL_HA_MODE_ENTRY); }

 public:
  /**
   * Class constructor.
   */
  Indi_HeikenAshi(IndiHeikenAshiParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                  IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(FINAL_HA_MODE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE,
                                                   _indi_src_mode),
                  _indi_src) {
    Init();
  }
  Indi_HeikenAshi(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                  int _indi_src_mode = 0)
      : Indicator(IndiHeikenAshiParams(),
                  IndicatorDataParams::GetInstance(FINAL_HA_MODE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE,
                                                   _indi_src_mode),
                  _indi_src) {}

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_CUSTOM; }

 public:
  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override {
    return IDATA_BUILTIN | IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR;
  }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiHeikenAshiParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // HA uses OHLC only.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_OPEN) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_LOW) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_CLOSE);
  }

  /**
   * Returns value for iHeikenAshi indicator.
   */
  static double iCustomLegacyHeikenAshi(string _symbol, ENUM_TIMEFRAMES _tf, string _name, int _mode, int _shift = 0,
                                        IndicatorData *_obj = NULL) {
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
      return ArraySize(_res) > 0 ? _res[0] : EMPTY_VALUE;
    }
    return _res[0];
#endif
  }

  /**
   * OnCalculate-based version of Color Heiken Ashi as there is no built-in one.
   */
  static double iHeikenAshi(IndicatorData *_indi, int _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, "");
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
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtOBuffer,
                       ValueStorage<double> &ExtHBuffer, ValueStorage<double> &ExtLBuffer,
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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = HA_OPEN, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
      case IDATA_ONCALCULATE:
#ifdef __MQL4__
        // Converting MQL4's enum into MQL5 one, as OnCalculate uses further one.
        switch (_mode) {
          case HA_OPEN:
            _mode = (ENUM_HA_MODE)0;
            break;
          case HA_HIGH:
            _mode = (ENUM_HA_MODE)1;
            break;
          case HA_LOW:
            _mode = (ENUM_HA_MODE)2;
            break;
          case HA_CLOSE:
            _mode = (ENUM_HA_MODE)3;
            break;
        }
#endif
        _value = Indi_HeikenAshi::iHeikenAshi(THIS_PTR, _mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode, _ishift);
        break;
      case IDATA_ICUSTOM_LEGACY:
        _value = Indi_HeikenAshi::iCustomLegacyHeikenAshi(GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), _mode,
                                                          _ishift, THIS_PTR);
        break;
      case IDATA_INDICATOR:
        _value = Indi_HeikenAshi::iHeikenAshi(THIS_PTR, _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return !_entry.HasValue<double>(NULL) && !_entry.HasValue<double>(EMPTY_VALUE) && _entry.IsGt<double>(0) &&
           _entry.values[(int)HA_LOW].GetDbl() < _entry.values[(int)HA_HIGH].GetDbl();
  }
};

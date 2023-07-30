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
#include "../Storage/ValueStorage.h"
#include "../Storage/ValueStorage.price.h"
#include "../Storage/ValueStorage.spread.h"
#include "../Storage/ValueStorage.tick_volume.h"
#include "../Storage/ValueStorage.time.h"
#include "../Storage/ValueStorage.volume.h"
#include "../Util.h"
#include "Indi_ADX.mqh"
#include "Price/Indi_Price.mqh"

// Structs.
struct IndiADXWParams : IndiADXParams {
  // Struct constructor.
  IndiADXWParams(int _period = 14, ENUM_APPLIED_PRICE _ap = PRICE_TYPICAL, int _shift = 0,
                 ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
      : IndiADXParams(_period, _ap, _shift, _tf) {
    itype = itype == INDI_NONE || itype == INDI_ADX ? INDI_ADXW : itype;
    if (custom_indi_name == "" || custom_indi_name == "Examples\\ADX") {
      SetCustomIndicatorName("Examples\\ADXW");
    }
  };
  IndiADXWParams(IndiADXWParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * Implements the Average Directional Movement Index indicator by Welles Wilder.
 */
class Indi_ADXW : public IndicatorTickOrCandleSource<IndiADXWParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_ADXW(IndiADXWParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : IndicatorTickOrCandleSource(_p,
                                    IndicatorDataParams::GetInstance(FINAL_INDI_ADX_LINE_ENTRY, TYPE_DOUBLE, _idstype,
                                                                     IDATA_RANGE_RANGE, _indi_src_mode),
                                    _indi_src){};
  Indi_ADXW(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0)
      : IndicatorTickOrCandleSource(INDI_ADXW, _tf, _shift){};

  /**
   * Built-in version of ADX Wilder.
   */
  static double iADXWilder(string _symbol, ENUM_TIMEFRAMES _tf, int _ma_period, int _mode = LINE_MAIN_ADX,
                           int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iADXWilder(_symbol, _tf, _ma_period), _mode, _shift);
#else
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_symbol, _tf, Util::MakeKey("Indi_ADXW", _ma_period));
    return iADXWilderOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _ma_period, _mode, _shift, _cache);
#endif
  }

  /**
   * Calculates ADX Wilder on the array of values.
   */
  static double iADXWilderOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _period, int _mode, int _shift,
                                  IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(3 + 7);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_ADXW::Calculate(
        INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0), _cache.GetBuffer<double>(1),
        _cache.GetBuffer<double>(2), _cache.GetBuffer<double>(3), _cache.GetBuffer<double>(4),
        _cache.GetBuffer<double>(5), _cache.GetBuffer<double>(6), _cache.GetBuffer<double>(7),
        _cache.GetBuffer<double>(8), _cache.GetBuffer<double>(9), _period));

    // Returns value from the first calculation buffer.
    // Returns first value for as-series array or last value for non-as-series array.
    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * On-indicator version of ADX Wilder.
   */
  static double iADXWilderOnIndicator(IndicatorData *_indi, string _symbol, ENUM_TIMEFRAMES _tf, int _period,
                                      int _mode = 0, int _shift = 0, IndicatorData *_obj = NULL) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG_DS(
        _indi, _symbol, _tf, Util::MakeKey("Indi_ADXW_ON_" + _indi.GetFullName(), _period));
    return iADXWilderOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _period, _mode, _shift, _cache);
  }

  /**
   * OnCalculate() method for ADXW indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &_adxw_buff,
                       ValueStorage<double> &_pdi_buff, ValueStorage<double> &_ndi_buff,
                       ValueStorage<double> &_pds_buff, ValueStorage<double> &_nds_buff,
                       ValueStorage<double> &_pdb_buff, ValueStorage<double> &_nd_buff, ValueStorage<double> &_tr_buff,
                       ValueStorage<double> &_atr_buff, ValueStorage<double> &_dx_buff, int _adxw_period) {
    int i;
    // Checking for bars count.
    if (rates_total < _adxw_period) return (0);
    // Detect start position.
    int start;
    if (prev_calculated > 1)
      start = prev_calculated - 1;
    else {
      start = 1;
      for (i = 0; i < _adxw_period; i++) {
        _adxw_buff[i] = 0;
        _pdi_buff[i] = 0;
        _ndi_buff[i] = 0;
        _pds_buff[i] = 0;
        _nds_buff[i] = 0;
        _pdb_buff[i] = 0;
        _nd_buff[i] = 0;
        _tr_buff[i] = 0;
        _atr_buff[i] = 0;
        _dx_buff[i] = 0;
      }
    }
    for (i = start; i < rates_total && !IsStopped(); i++) {
      // Get some data.
      double high_price = high[i].Get();
      double prev_high = high[i - 1].Get();
      double low_price = low[i].Get();
      double prev_low = low[i - 1].Get();
      double prev_close = close[i - 1].Get();
      // Fill main positive and main negative buffers.
      double tmp_pos = high_price - prev_high;
      double tmp_neg = prev_low - low_price;
      if (tmp_pos < 0.0) tmp_pos = 0.0;
      if (tmp_neg < 0.0) tmp_neg = 0.0;
      if (tmp_neg == tmp_pos) {
        tmp_neg = 0.0;
        tmp_pos = 0.0;
      } else {
        if (tmp_pos < tmp_neg)
          tmp_pos = 0.0;
        else
          tmp_neg = 0.0;
      }
      _pdb_buff[i] = tmp_pos;
      _nd_buff[i] = tmp_neg;
      // Define TR.
      double tr = MathMax(MathMax(MathAbs(high_price - low_price), MathAbs(high_price - prev_close)),
                          MathAbs(low_price - prev_close));
      // Write down TR to TR buffer.
      _tr_buff[i] = tr;
      // Fill smoothed positive and negative buffers and TR buffer.
      if (i < _adxw_period) {
        _atr_buff[i] = 0.0;
        _pdi_buff[i] = 0.0;
        _ndi_buff[i] = 0.0;
      } else {
        _atr_buff[i] = SmoothedMA(i, _adxw_period, _atr_buff[i - 1].Get(), _tr_buff);
        _pds_buff[i] = SmoothedMA(i, _adxw_period, _pds_buff[i - 1].Get(), _pdb_buff);
        _nds_buff[i] = SmoothedMA(i, _adxw_period, _nds_buff[i - 1].Get(), _nd_buff);
      }
      // Calculate PDI and NDI buffers.
      if (_atr_buff[i] != 0.0) {
        _pdi_buff[i] = 100.0 * _pds_buff[i].Get() / _atr_buff[i].Get();
        _ndi_buff[i] = 100.0 * _nds_buff[i].Get() / _atr_buff[i].Get();
      } else {
        _pdi_buff[i] = 0.0;
        _ndi_buff[i] = 0.0;
      }
      // Calculate DX buffer.
      double dTmp = _pdi_buff[i] + _ndi_buff[i];
      if (dTmp != 0.0)
        dTmp = 100.0 * MathAbs((_pdi_buff[i] - _ndi_buff[i]) / dTmp);
      else
        dTmp = 0.0;
      _dx_buff[i] = dTmp;
      // Fill ADXW buffer as smoothed DX buffer.
      _adxw_buff[i] = SmoothedMA(i, _adxw_period, _adxw_buff[i - 1].Get(), _dx_buff);
    }
    // OnCalculate done. Return new prev_calculated.
    return (rates_total);
  }

  /**
   * Smoothed Moving Average.
   */
  static double SmoothedMA(const int position, const int period, const double prev_value, ValueStorage<double> &price) {
    double result = 0.0;
    // Check period.
    if (period > 0 && period <= (position + 1)) {
      if (position == period - 1) {
        for (int i = 0; i < period; i++) result += price[position - i].Get();

        result /= period;
      }

      result = (prev_value * (period - 1) + price[position].Get()) / period;
    }

    return (result);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = LINE_MAIN_ADX, int _shift = 0) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_ADXW::iADXWilder(GetSymbol(), GetTf(), GetPeriod(), _mode, _ishift, THIS_PTR);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/,
                         _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_ADXW::iADXWilderOnIndicator(GetDataSource(), GetSymbol(), GetTf(), /*[*/ GetPeriod() /*]*/, _mode,
                                                  _ishift, THIS_PTR);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /* Getters */

  /**
   * Get period value.
   */
  unsigned int GetPeriod() { return iparams.period; }

  /* Setters */

  /**
   * Set period value.
   */
  void SetPeriod(unsigned int _period) {
    istate.is_changed = true;
    iparams.period = _period;
  }
};

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
#include "../Storage/ValueStorage.applied_price.h"
#include "../Storage/ValueStorage.h"
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
  IndiADXWParams(int _period = 14, ENUM_APPLIED_PRICE _ap = PRICE_TYPICAL, int _shift = 0)
      : IndiADXParams(_period, _ap, _shift) {
    itype = itype == INDI_NONE || itype == INDI_ADX ? INDI_ADXW : itype;
    if (custom_indi_name == "") {
      SetCustomIndicatorName("Examples\\ADXW");
    }
  };
};

/**
 * Implements the Average Directional Movement Index indicator by Welles Wilder.
 */
class Indi_ADXW : public Indicator<IndiADXWParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_ADXW(IndiADXWParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(FINAL_INDI_ADX_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_RANGE,
                                                   _indi_src_mode),
                  _indi_src){};

  Indi_ADXW(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(IndiADXWParams(),
                  IndicatorDataParams::GetInstance(FINAL_INDI_ADX_LINE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_RANGE,
                                                   _indi_src_mode),
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
  unsigned int GetPossibleDataModes() override {
    return IDATA_BUILTIN | IDATA_ONCALCULATE | IDATA_ICUSTOM | IDATA_INDICATOR;
  }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiADXWParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // RS uses OHLC.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_OPEN) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_LOW) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_CLOSE);
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) { return _entry.IsWithinRange(0.0, 100.0); }

  /**
   * Built-in or OnCalculate-based version of ADX Wilder.
   */
  static double iADXWilder(string _symbol, ENUM_TIMEFRAMES _tf, int _ma_period, int _mode = LINE_MAIN_ADX,
                           int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL5__
    INDICATOR_BUILTIN_CALL_AND_RETURN(::iADXWilder(_symbol, _tf, _ma_period), _mode, _shift);
#else
    if (_obj == nullptr) {
      Print(
          "Indi_ADXW::iADXWilder() can work without supplying pointer to IndicatorData only in MQL5. In this platform "
          "the pointer is required.");
      DebugBreak();
      return 0;
    }
    return iADXWilder(_obj, _ma_period, _mode, _shift);
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
  static double iADXWilder(IndicatorData *_indi, int _period, int _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, Util::MakeKey(_period));
    return iADXWilderOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _period, _mode, _shift, _cache);
  }

  /**
   * OnCalculate() method for ADXW indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ExtADXWBuffer,
                       ValueStorage<double> &ExtPDIBuffer, ValueStorage<double> &ExtNDIBuffer,
                       ValueStorage<double> &ExtPDSBuffer, ValueStorage<double> &ExtNDSBuffer,
                       ValueStorage<double> &ExtPDBuffer, ValueStorage<double> &ExtNDBuffer,
                       ValueStorage<double> &ExtTRBuffer, ValueStorage<double> &ExtATRBuffer,
                       ValueStorage<double> &ExtDXBuffer, int ExtADXWPeriod) {
    int i;
    // Checking for bars count.
    if (rates_total < ExtADXWPeriod) return (0);
    // Detect start position.
    int start;
    if (prev_calculated > 1)
      start = prev_calculated - 1;
    else {
      start = 1;
      for (i = 0; i < ExtADXWPeriod; i++) {
        ExtADXWBuffer[i] = 0;
        ExtPDIBuffer[i] = 0;
        ExtNDIBuffer[i] = 0;
        ExtPDSBuffer[i] = 0;
        ExtNDSBuffer[i] = 0;
        ExtPDBuffer[i] = 0;
        ExtNDBuffer[i] = 0;
        ExtTRBuffer[i] = 0;
        ExtATRBuffer[i] = 0;
        ExtDXBuffer[i] = 0;
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
      ExtPDBuffer[i] = tmp_pos;
      ExtNDBuffer[i] = tmp_neg;
      // Define TR.
      double tr = MathMax(MathMax(MathAbs(high_price - low_price), MathAbs(high_price - prev_close)),
                          MathAbs(low_price - prev_close));
      // Write down TR to TR buffer.
      ExtTRBuffer[i] = tr;
      // Fill smoothed positive and negative buffers and TR buffer.
      if (i < ExtADXWPeriod) {
        ExtATRBuffer[i] = 0.0;
        ExtPDIBuffer[i] = 0.0;
        ExtNDIBuffer[i] = 0.0;
      } else {
        ExtATRBuffer[i] = SmoothedMA(i, ExtADXWPeriod, ExtATRBuffer[i - 1].Get(), ExtTRBuffer);
        ExtPDSBuffer[i] = SmoothedMA(i, ExtADXWPeriod, ExtPDSBuffer[i - 1].Get(), ExtPDBuffer);
        ExtNDSBuffer[i] = SmoothedMA(i, ExtADXWPeriod, ExtNDSBuffer[i - 1].Get(), ExtNDBuffer);
      }
      // Calculate PDI and NDI buffers.
      if (ExtATRBuffer[i] != 0.0) {
        ExtPDIBuffer[i] = 100.0 * ExtPDSBuffer[i].Get() / ExtATRBuffer[i].Get();
        ExtNDIBuffer[i] = 100.0 * ExtNDSBuffer[i].Get() / ExtATRBuffer[i].Get();
      } else {
        ExtPDIBuffer[i] = 0.0;
        ExtNDIBuffer[i] = 0.0;
      }
      // Calculate DX buffer.
      double dTmp = ExtPDIBuffer[i] + ExtNDIBuffer[i];
      if (dTmp != 0.0)
        dTmp = 100.0 * MathAbs((ExtPDIBuffer[i] - ExtNDIBuffer[i]) / dTmp);
      else
        dTmp = 0.0;
      ExtDXBuffer[i] = dTmp;
      // Fill ADXW buffer as smoothed DX buffer.
      ExtADXWBuffer[i] = SmoothedMA(i, ExtADXWPeriod, ExtADXWBuffer[i - 1].Get(), ExtDXBuffer);
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
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = LINE_MAIN_ADX, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
        _value = Indi_ADXW::iADXWilder(GetSymbol(), GetTf(), GetPeriod(), _mode, _ishift, THIS_PTR);
        break;
      case IDATA_ONCALCULATE:
        _value = Indi_ADXW::iADXWilder(THIS_PTR, GetPeriod(), _mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetPeriod() /*]*/,
                         _mode, _ishift);
        break;
      case IDATA_INDICATOR:
        _value = Indi_ADXW::iADXWilder(THIS_PTR, GetPeriod(), _mode, _ishift);
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

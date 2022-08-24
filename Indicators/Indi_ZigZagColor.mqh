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
#include "Indi_ZigZag.mqh"

// Structs.
struct IndiZigZagColorParams : IndicatorParams {
  unsigned int depth;
  unsigned int deviation;
  unsigned int backstep;

  // Struct constructor.
  IndiZigZagColorParams(unsigned int _depth = 12, unsigned int _deviation = 5, unsigned int _backstep = 3,
                        int _shift = 0)
      : IndicatorParams(INDI_ZIGZAG_COLOR) {
    backstep = _backstep;
    depth = _depth;
    deviation = _deviation;
    SetCustomIndicatorName("Examples\\ZigZagColor");
    shift = _shift;
  };
  IndiZigZagColorParams(IndiZigZagColorParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Volume Rate of Change indicator.
 */
class Indi_ZigZagColor : public Indicator<IndiZigZagColorParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_ZigZagColor(IndiZigZagColorParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN,
                   IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(
            _p, IndicatorDataParams::GetInstance(3, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE_ON_SIGNAL, _indi_src_mode),
            _indi_src){};
  Indi_ZigZagColor(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
                   int _indi_src_mode = 0)
      : Indicator(
            IndiZigZagColorParams(),
            IndicatorDataParams::GetInstance(3, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE_ON_SIGNAL, _indi_src_mode),
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
  unsigned int GetPossibleDataModes() override { return IDATA_ICUSTOM | IDATA_ONCALCULATE; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiZigZagColorParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // ZigZagColor uses only high and low prices.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_LOW);
  }

  /**
   * Returns value for ZigZag Color indicator.
   */
  static double iZigZagColor(IndicatorData *_indi, int _depth, int _deviation, int _backstep,
                             ENUM_ZIGZAG_LINE _mode = 0, int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, Util::MakeKey(_depth, _deviation, _backstep));
    return iZigZagColorOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _depth, _deviation, _backstep, _mode, _shift,
                               _cache);
  }

  /**
   * Calculates ZigZag Color on the array of values.
   */
  static double iZigZagColorOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _depth, int _deviation, int _backstep,
                                    int _mode, int _shift, IndicatorCalculateCache<double> *_cache,
                                    bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(3 + 2);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_ZigZagColor::Calculate(INDICATOR_CALCULATE_GET_PARAMS_LONG,
                                                         _cache.GetBuffer<double>(0), _cache.GetBuffer<double>(1),
                                                         _cache.GetBuffer<double>(2), _cache.GetBuffer<double>(3),
                                                         _cache.GetBuffer<double>(4), _depth, _deviation, _backstep));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for ZigZag Color indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ZigzagPeakBuffer,
                       ValueStorage<double> &ZigzagBottomBuffer, ValueStorage<double> &HighMapBuffer,
                       ValueStorage<double> &LowMapBuffer, ValueStorage<double> &ColorBuffer, int InpDepth,
                       int InpDeviation, int InpBackstep) {
    int ExtRecalc = 3;

    if (rates_total < 100) return 0;
    int i, start = 0;
    int extreme_counter = 0, extreme_search = Extremum;
    int shift, back = 0, last_high_pos = 0, last_low_pos = 0;
    double val = 0, res = 0;
    double cur_low = 0, cur_high = 0, last_high = 0, last_low = 0;
    // Initialize variables.
    if (prev_calculated == 0) {
      ArrayInitialize(ZigzagPeakBuffer, 0.0);
      ArrayInitialize(ZigzagBottomBuffer, 0.0);
      ArrayInitialize(HighMapBuffer, 0.0);
      ArrayInitialize(LowMapBuffer, 0.0);
      // Start calculation from bar number InpDepth.
      start = InpDepth - 1;
    }
    if (prev_calculated > 0) {
      // ZigZag was already calculated before.
      i = rates_total - 1;
      // Search for the third extremum from the last uncompleted bar.
      while (extreme_counter < ExtRecalc && i > rates_total - 100) {
        res = (ZigzagPeakBuffer[i] + ZigzagBottomBuffer[i]);
        if (res != 0) extreme_counter++;
        i--;
      }
      i++;
      start = i;
      // Type of extremum we search for.
      if (LowMapBuffer[i] != 0) {
        cur_low = LowMapBuffer[i].Get();
        extreme_search = Peak;
      } else {
        cur_high = HighMapBuffer[i].Get();
        extreme_search = Bottom;
      }
      // Clear indicator values.
      for (i = start + 1; i < rates_total && !IsStopped(); i++) {
        ZigzagPeakBuffer[i] = 0.0;
        ZigzagBottomBuffer[i] = 0.0;
        LowMapBuffer[i] = 0.0;
        HighMapBuffer[i] = 0.0;
      }
    }
    // Search for high and low extremes.
    for (shift = start; shift < rates_total && !IsStopped(); shift++) {
      // Low.
      val = Indi_ZigZag::Lowest(low, InpDepth, shift);
      if (val == last_low)
        val = 0.0;
      else {
        last_low = val;
        if ((low[shift] - val) > (InpDeviation * _Point))
          val = 0.0;
        else {
          for (back = InpBackstep; back >= 1 && shift >= back; back--) {
            res = LowMapBuffer[shift - back].Get();
            //---
            if ((res != 0) && (res > val)) LowMapBuffer[shift - back] = 0.0;
          }
        }
      }
      if (low[shift] == val)
        LowMapBuffer[shift] = val;
      else
        LowMapBuffer[shift] = 0.0;
      // High.
      val = Indi_ZigZag::Highest(high, InpDepth, shift);
      if (val == last_high)
        val = 0.0;
      else {
        last_high = val;
        if ((val - high[shift].Get()) > (InpDeviation * _Point))
          val = 0.0;
        else {
          for (back = InpBackstep; back >= 1 && shift >= back; back--) {
            res = HighMapBuffer[shift - back].Get();
            //---
            if ((res != 0) && (res < val)) HighMapBuffer[shift - back] = 0.0;
          }
        }
      }
      if (high[shift] == val)
        HighMapBuffer[shift] = val;
      else
        HighMapBuffer[shift] = 0.0;
    }
    // Set last values.
    if (extreme_search == 0) {
      // Undefined values.
      last_low = 0;
      last_high = 0;
    } else {
      last_low = cur_low;
      last_high = cur_high;
    }
    // Final selection of extreme points for ZigZag.
    for (shift = start; shift < rates_total && !IsStopped(); shift++) {
      res = 0.0;
      switch (extreme_search) {
        case Extremum:
          if (last_low == 0 && last_high == 0) {
            if (HighMapBuffer[shift] != 0) {
              last_high = high[shift].Get();
              last_high_pos = shift;
              extreme_search = -1;
              ZigzagPeakBuffer[shift] = last_high;
              ColorBuffer[shift] = 0;
              res = 1;
            }
            if (LowMapBuffer[shift] != 0) {
              last_low = low[shift].Get();
              last_low_pos = shift;
              extreme_search = 1;
              ZigzagBottomBuffer[shift] = last_low;
              ColorBuffer[shift] = 1;
              res = 1;
            }
          }
          break;
        case Peak:
          if (LowMapBuffer[shift] != 0.0 && LowMapBuffer[shift] < last_low && HighMapBuffer[shift] == 0.0) {
            ZigzagBottomBuffer[last_low_pos] = 0.0;
            last_low_pos = shift;
            last_low = LowMapBuffer[shift].Get();
            ZigzagBottomBuffer[shift] = last_low;
            ColorBuffer[shift] = 1;
            res = 1;
          }
          if (HighMapBuffer[shift] != 0.0 && LowMapBuffer[shift] == 0.0) {
            last_high = HighMapBuffer[shift].Get();
            last_high_pos = shift;
            ZigzagPeakBuffer[shift] = last_high;
            ColorBuffer[shift] = 0;
            extreme_search = Bottom;
            res = 1;
          }
          break;
        case Bottom:
          if (HighMapBuffer[shift] != 0.0 && HighMapBuffer[shift] > last_high && LowMapBuffer[shift] == 0.0) {
            ZigzagPeakBuffer[last_high_pos] = 0.0;
            last_high_pos = shift;
            last_high = HighMapBuffer[shift].Get();
            ZigzagPeakBuffer[shift] = last_high;
            ColorBuffer[shift] = 0;
          }
          if (LowMapBuffer[shift] != 0.0 && HighMapBuffer[shift] == 0.0) {
            last_low = LowMapBuffer[shift].Get();
            last_low_pos = shift;
            ZigzagBottomBuffer[shift] = last_low;
            ColorBuffer[shift] = 1;
            extreme_search = Peak;
          }
          break;
        default:
          return (rates_total);
      }
    }

    return rates_total;
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_ONCALCULATE:
        _value = Indi_ZigZagColor::iZigZagColor(THIS_PTR, GetDepth(), GetDeviation(), GetBackstep(),
                                                (ENUM_ZIGZAG_LINE)_mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(),
                         /*[*/ GetDepth(), GetDeviation(), GetBackstep() /*]*/, _mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _value;
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) { return _entry.values[0].Get<double>() != EMPTY_VALUE; }

  /* Getters */

  /**
   * Get depth.
   */
  unsigned int GetDepth() { return iparams.depth; }

  /**
   * Get deviation.
   */
  unsigned int GetDeviation() { return iparams.deviation; }

  /**
   * Get backstep.
   */
  unsigned int GetBackstep() { return iparams.backstep; }

  /* Setters */

  /**
   * Set depth.
   */
  void SetDepth(unsigned int _depth) {
    istate.is_changed = true;
    iparams.depth = _depth;
  }

  /**
   * Set deviation.
   */
  void SetDeviation(unsigned int _deviation) {
    istate.is_changed = true;
    iparams.deviation = _deviation;
  }

  /**
   * Set backstep.
   */
  void SetBackstep(unsigned int _backstep) {
    istate.is_changed = true;
    iparams.backstep = _backstep;
  }
};

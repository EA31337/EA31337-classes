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
#include "../Indicator/Indicator.h"
#include "../Storage/ValueStorage.all.h"

// Defines.
#ifdef __MQL4__
#define INDI_ZIGZAG_PATH "ZigZag"
#else
#define INDI_ZIGZAG_PATH "Examples\\ZigZag"
#endif

// Enums.
// Indicator mode identifiers used in ZigZag indicator.
enum ENUM_ZIGZAG_LINE { ZIGZAG_BUFFER = 0, ZIGZAG_HIGHMAP = 1, ZIGZAG_LOWMAP = 2, FINAL_ZIGZAG_LINE_ENTRY };

// Structs.
struct IndiZigZagParams : IndicatorParams {
  unsigned int depth;
  unsigned int deviation;
  unsigned int backstep;
  // Struct constructors.
  IndiZigZagParams(unsigned int _depth = 12, unsigned int _deviation = 5, unsigned int _backstep = 3, int _shift = 0)
      : depth(_depth), deviation(_deviation), backstep(_backstep), IndicatorParams(INDI_ZIGZAG) {
    shift = _shift;
    SetCustomIndicatorName(INDI_ZIGZAG_PATH);
  };
  IndiZigZagParams(IndiZigZagParams &_params) { THIS_REF = _params; };
};

enum EnSearchMode {
  Extremum = 0,  // searching for the first extremum
  Peak = 1,      // searching for the next ZigZag peak
  Bottom = -1    // searching for the next ZigZag bottom
};

/**
 * Implements ZigZag indicator.
 */
class Indi_ZigZag : public Indicator<IndiZigZagParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_ZigZag(IndiZigZagParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
              int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(FINAL_ZIGZAG_LINE_ENTRY, TYPE_DOUBLE, _idstype,
                                                   IDATA_RANGE_PRICE_ON_SIGNAL),
                  _indi_src) {}
  Indi_ZigZag(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
              int _indi_src_mode = 0)
      : Indicator(IndiZigZagParams(),
                  IndicatorDataParams::GetInstance(FINAL_ZIGZAG_LINE_ENTRY, TYPE_DOUBLE, _idstype,
                                                   IDATA_RANGE_PRICE_ON_SIGNAL),
                  _indi_src) {}
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
#ifdef __MQL__
    return IDATA_ICUSTOM | IDATA_ONCALCULATE | IDATA_INDICATOR;
#else
    return IDATA_ONCALCULATE | IDATA_INDICATOR | IDATA_ICUSTOM;
#endif
  }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiZigZagParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // ZigZag uses only high and low prices.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_LOW);
  }

  /**
   * Returns value for ZigZag indicator.
   */
  static double iCustomZigZag(string _symbol, ENUM_TIMEFRAMES _tf, string _name, int _depth, int _deviation,
                              int _backstep, ENUM_ZIGZAG_LINE _mode = 0, int _shift = 0, IndicatorData *_obj = NULL) {
#ifdef __MQL5__
    int _handle = Object::IsValid(_obj) ? _obj.Get<int>(IndicatorState::INDICATOR_STATE_PROP_HANDLE) : NULL;
    double _res[];
    if (_handle == NULL || _handle == INVALID_HANDLE) {
      if ((_handle = ::iCustom(_symbol, _tf, _name, _depth, _deviation, _backstep)) == INVALID_HANDLE) {
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
#else
    return ::iCustom(_symbol, _tf, _name, _depth, _deviation, _backstep, _mode, _shift);
#endif
  }

  /**
   * Returns value for ZigZag indicator.
   */
  static double iZigZag(IndicatorData *_indi, int _depth, int _deviation, int _backstep, ENUM_ZIGZAG_LINE _mode = 0,
                        int _shift = 0) {
    INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(_indi, Util::MakeKey(_depth, _deviation, _backstep));
    return iZigZagOnArray(INDICATOR_CALCULATE_POPULATED_PARAMS_LONG, _depth, _deviation, _backstep, _mode, _shift,
                          _cache);
  }

  /**
   * Calculates ZigZag on the array of values.
   */
  static double iZigZagOnArray(INDICATOR_CALCULATE_PARAMS_LONG, int _depth, int _deviation, int _backstep, int _mode,
                               int _shift, IndicatorCalculateCache<double> *_cache, bool _recalculate = false) {
    _cache.SetPriceBuffer(_open, _high, _low, _close);

    if (!_cache.HasBuffers()) {
      _cache.AddBuffer<NativeValueStorage<double>>(1 + 2);
    }

    if (_recalculate) {
      _cache.ResetPrevCalculated();
    }

    _cache.SetPrevCalculated(Indi_ZigZag::Calculate(INDICATOR_CALCULATE_GET_PARAMS_LONG, _cache.GetBuffer<double>(0),
                                                    _cache.GetBuffer<double>(1), _cache.GetBuffer<double>(2), _depth,
                                                    _deviation, _backstep));

    return _cache.GetTailValue<double>(_mode, _shift);
  }

  /**
   * OnCalculate() method for ZigZag indicator.
   */
  static int Calculate(INDICATOR_CALCULATE_METHOD_PARAMS_LONG, ValueStorage<double> &ZigZagBuffer,
                       ValueStorage<double> &HighMapBuffer, ValueStorage<double> &LowMapBuffer, int InpDepth,
                       int InpDeviation, int InpBackstep) {
    int ExtRecalc = 3;

    if (rates_total < 100) return (0);
    //---
    int i = 0;
    int start = 0, extreme_counter = 0, extreme_search = Extremum;
    int shift = 0, back = 0, last_high_pos = 0, last_low_pos = 0;
    double val = 0, res = 0;
    double curlow = 0, curhigh = 0, last_high = 0, last_low = 0;
    // Initializing.
    if (prev_calculated == 0) {
      ArrayInitialize(ZigZagBuffer, 0.0);
      ArrayInitialize(HighMapBuffer, 0.0);
      ArrayInitialize(LowMapBuffer, 0.0);
      start = InpDepth;
    }

    // ZigZag was already calculated before.
    if (prev_calculated > 0) {
      i = rates_total - 1;
      // Searching for the third extremum from the last uncompleted bar.
      while (extreme_counter < ExtRecalc && i > rates_total - 100) {
        res = ZigZagBuffer[i].Get();
        if (res != 0.0) extreme_counter++;
        i--;
      }
      i++;
      start = i;

      // What type of extremum we search for.
      if (LowMapBuffer[i] != 0.0) {
        curlow = LowMapBuffer[i].Get();
        extreme_search = Peak;
      } else {
        curhigh = HighMapBuffer[i].Get();
        extreme_search = Bottom;
      }
      // Clear indicator values.
      for (i = start + 1; i < rates_total && !IsStopped(); i++) {
        ZigZagBuffer[i] = 0.0;
        LowMapBuffer[i] = 0.0;
        HighMapBuffer[i] = 0.0;
      }
    }

    // Searching for high and low extremes.
    for (shift = start; shift < rates_total && !IsStopped(); shift++) {
      // Low.
      val = low[Lowest(low, InpDepth, shift)].Get();
      if (val == last_low) {
        val = 0.0;
      } else {
        last_low = val;
        if ((low[shift] - val) > InpDeviation * _Point) {
          val = 0.0;
        } else {
          for (back = InpBackstep; back >= 1 && shift >= back; back--) {
            res = LowMapBuffer[shift - back].Get();
            if ((res != 0) && (res > val)) LowMapBuffer[shift - back] = 0.0;
          }
        }
      }
      LowMapBuffer[shift] = (low[shift] == val) ? val : 0.0;
      // High.
      val = high[Highest(high, InpDepth, shift)].Get();
      if (val == last_high) {
        val = 0.0;
      } else {
        last_high = val;
        if ((val - high[shift].Get()) > InpDeviation * _Point) {
          val = 0.0;
        } else {
          for (back = InpBackstep; back >= 1 && shift >= back; back--) {
            res = HighMapBuffer[shift - back].Get();
            if ((res != 0) && (res < val)) HighMapBuffer[shift - back] = 0.0;
          }
        }
      }
      HighMapBuffer[shift] = (high[shift] == val) ? val : 0.0;
    }

    // Set last values.
    if (extreme_search == 0) {
      // Undefined values.
      last_low = 0.0;
      last_high = 0.0;
    } else {
      last_low = curlow;
      last_high = curhigh;
    }

    // Final selection of extreme points for ZigZag.
    for (shift = start; shift < rates_total && !IsStopped(); shift++) {
      res = 0.0;
      switch (extreme_search) {
        case Extremum:
          if (last_low == 0.0 && last_high == 0.0) {
            if (HighMapBuffer[shift] != 0) {
              last_high = high[shift].Get();
              last_high_pos = shift;
              extreme_search = Bottom;
              ZigZagBuffer[shift] = last_high;
              res = 1;
            }
            if (LowMapBuffer[shift] != 0.0) {
              last_low = low[shift].Get();
              last_low_pos = shift;
              extreme_search = Peak;
              ZigZagBuffer[shift] = last_low;
              res = 1;
            }
          }
          break;
        case Peak:
          if (LowMapBuffer[shift] != 0.0 && LowMapBuffer[shift] < last_low && HighMapBuffer[shift] == 0.0) {
            ZigZagBuffer[last_low_pos] = 0.0;
            last_low_pos = shift;
            last_low = LowMapBuffer[shift].Get();
            ZigZagBuffer[shift] = last_low;
            res = 1;
          }
          if (HighMapBuffer[shift] != 0.0 && LowMapBuffer[shift] == 0.0) {
            last_high = HighMapBuffer[shift].Get();
            last_high_pos = shift;
            ZigZagBuffer[shift] = last_high;
            extreme_search = Bottom;
            res = 1;
          }
          break;
        case Bottom:
          if (HighMapBuffer[shift] != 0.0 && HighMapBuffer[shift] > last_high && LowMapBuffer[shift] == 0.0) {
            ZigZagBuffer[last_high_pos] = 0.0;
            last_high_pos = shift;
            last_high = HighMapBuffer[shift].Get();
            ZigZagBuffer[shift] = last_high;
          }
          if (LowMapBuffer[shift] != 0.0 && HighMapBuffer[shift] == 0.0) {
            last_low = LowMapBuffer[shift].Get();
            last_low_pos = shift;
            ZigZagBuffer[shift] = last_low;
            extreme_search = Peak;
          }
          break;
        default:
          return (rates_total);
      }
    }

    // Return value of prev_calculated for next call.
    return (rates_total);
  }

  /**
   * Search for the index of the highest bar.
   */
  static int Highest(ValueStorage<double> &array, const int depth, const int start) {
    if (start < 0) return (0);

    double max = array[start].Get();
    int index = start;
    // Start searching.
    for (int i = start - 1; i > start - depth && i >= 0; i--) {
      if (array[i] > max) {
        index = i;
        max = array[i].Get();
      }
    }
    // Return index of the highest bar.
    return index;
  }

  /**
   * Search for the index of the lowest bar.
   */
  static int Lowest(ValueStorage<double> &array, const int depth, const int start) {
    if (start < 0) return (0);

    double min = array[start].Get();
    int index = start;
    // Start searching.
    for (int i = start - 1; i > start - depth && i >= 0; i--) {
      if (array[i] < min) {
        index = i;
        min = array[i].Get();
      }
    }
    // Return index of the lowest bar.
    return index;
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_BUILTIN:
      case IDATA_ONCALCULATE:
        _value = iZigZag(THIS_PTR, GetDepth(), GetDeviation(), GetBackstep(), (ENUM_ZIGZAG_LINE)_mode, _ishift);
        break;
      case IDATA_ICUSTOM:
        _value =
            Indi_ZigZag::iCustomZigZag(GetSymbol(), GetTf(), iparams.GetCustomIndicatorName(), /*[*/ GetDepth(),
                                       GetDeviation(), GetBackstep() /*]*/, (ENUM_ZIGZAG_LINE)_mode, _ishift, THIS_PTR);
        break;
      case IDATA_INDICATOR:
        _value = iZigZag(THIS_PTR, GetDepth(), GetDeviation(), GetBackstep(), (ENUM_ZIGZAG_LINE)_mode, _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) { return !_entry.HasValue<double>(EMPTY_VALUE); }

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

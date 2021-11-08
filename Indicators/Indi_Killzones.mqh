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
#include "../Indicator.mqh"
#include "../Market.struct.h"

// Defines enumerations.
enum ENUM_INDI_KILLZONES_MODE {
  INDI_KILLZONES_MODE_CHICAGO_HIGH = 0,
  INDI_KILLZONES_MODE_CHICAGO_LOW,
  INDI_KILLZONES_MODE_FRANKFURT_HIGH,
  INDI_KILLZONES_MODE_FRANKFURT_LOW,
  INDI_KILLZONES_MODE_HONGKONG_HIGH,
  INDI_KILLZONES_MODE_HONGKONG_LOW,
  INDI_KILLZONES_MODE_LONDON_HIGH,
  INDI_KILLZONES_MODE_LONDON_LOW,
  INDI_KILLZONES_MODE_NEWYORK_HIGH,
  INDI_KILLZONES_MODE_NEWYORK_LOW,
  INDI_KILLZONES_MODE_SYDNEY_HIGH,
  INDI_KILLZONES_MODE_SYDNEY_LOW,
  INDI_KILLZONES_MODE_TOKYO_HIGH,
  INDI_KILLZONES_MODE_TOKYO_LOW,
  INDI_KILLZONES_MODE_WELLINGTON_HIGH,
  INDI_KILLZONES_MODE_WELLINGTON_LOW,
  FINAL_INDI_KILLZONES_MODE_ENTRY,
};

// Defines structs.
struct IndiKillzonesParams : IndicatorParams {
  ENUM_PP_TYPE method;  // Pivot point calculation method.
  // Struct constructor.
  IndiKillzonesParams(int _shift = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT)
      : IndicatorParams(INDI_PIVOT, FINAL_INDI_KILLZONES_MODE_ENTRY, TYPE_FLOAT) {
    SetDataValueRange(IDATA_RANGE_MIXED);
    SetDataSourceType(IDATA_CHART);
    SetShift(_shift);
    tf = _tf;
  };
  IndiKillzonesParams(IndiKillzonesParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

struct Indi_Killzones_Time : MarketTimeForex {
  float highs[FINAL_INDI_KILLZONES_MODE_ENTRY / 2], lows[FINAL_INDI_KILLZONES_MODE_ENTRY / 2];
  datetime reset_last;
  Indi_Killzones_Time() : reset_last(0), MarketTimeForex(::TimeGMT()) {
    ArrayFill(highs, 0, ArraySize(highs), 0.0f);
    ArrayFill(lows, 0, ArraySize(lows), 0.0f);
  }
  bool CheckHours(int _index) {
    bool _result = MarketTimeForex::CheckHours(1 << _index);
    if (!_result) {
      Reset(_index);
    }
    return _result;
  }
  float GetHigh(int _index) { return highs[_index]; }
  float GetLow(int _index) { return lows[_index]; }
  void Reset(int _index) {
    highs[_index] = 0.0f;
    lows[_index] = 0.0f;
  }
  void Update(float _value, int _index) {
    highs[_index] = _value > highs[_index] ? _value : highs[_index];
    lows[_index] = _value < lows[_index] || lows[_index] == 0.0f ? _value : lows[_index];
  }
};

/**
 * Implements Pivot Detector.
 */
class Indi_Killzones : public Indicator<IndiKillzonesParams> {
 protected:
  Indi_Killzones_Time ikt;

 public:
  /**
   * Class constructor.
   */
  Indi_Killzones(IndiKillzonesParams &_p, IndicatorBase *_indi_src = NULL)
      : Indicator<IndiKillzonesParams>(_p, _indi_src) {}
  Indi_Killzones(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0) : Indicator(INDI_KILLZONES, _tf, _shift) {}

  /**
   * Returns the indicator's value.
   */
  IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    float _value = FLT_MAX;
    int _index = (int)_mode / 2;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_BUILTIN:
        // Builtin mode not supported.
        SetUserError(ERR_INVALID_PARAMETER);
        break;
      case IDATA_CHART:
        ikt.Set(::TimeGMT());
        if (ikt.CheckHours(_index)) {
          // Pass values to check for new highs or lows.
          ikt.Update(_mode % 2 == 0 ? (float)GetHigh(_ishift) : (float)GetLow(_ishift), _index);
        }
        // Set a final value.
        _value = _mode % 2 == 0 ? ikt.GetHigh(_index) : ikt.GetLow(_index);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _value;
  }

  /**
   * Checks if value is valid.
   */
  bool IsValidValue(float _value, unsigned int _mode = 0, int _shift = 0) { return _value > 0.0f; }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return _entry.IsGe<float>(0) && !_entry.HasValue<float>(FLT_MAX);
  }

  /* Getters */

  /**
   * Get pivot point calculation method.
   */
  ENUM_PP_TYPE GetMethod() { return iparams.method; }

  /* Setters */

  /**
   * Set pivot point calculation method.
   */
  void SetMethod(ENUM_PP_TYPE _method) {
    istate.is_changed = true;
    iparams.method = _method;
  }

  /**
   * Whether we can and have to select mode when specifying data source.
   */
  virtual bool IsDataSourceModeSelectable() { return false; }
};

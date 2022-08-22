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

/**
 * @file
 * Includes Indicator's signal structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward declaration.
struct ChartParams;
struct IndicatorDataEntry;
struct IndicatorDataParams;
struct IndicatorParams;

// Includes.
#include "Indicator.struct.h"

/* Structure for indicator signals. */
struct IndicatorSignal {
  /* Define enumeration for indicator signals. */
  enum ENUM_INDICATOR_SIGNAL {
    INDICATOR_SIGNAL_NONE = 0 << 0,        // (None)
    INDICATOR_SIGNAL_CROSSOVER = 1 << 0,   // Values crossed over.
    INDICATOR_SIGNAL_DIVERGENCE = 1 << 1,  // Divergence between values and prices.
    INDICATOR_SIGNAL_GT_PRICE = 1 << 2,    // Last value greater than price.
    INDICATOR_SIGNAL_INC = 1 << 3,         // Last value increased.
    INDICATOR_SIGNAL_LAST2SAME = 1 << 4,   // Last 2 values are in the same direction.
    INDICATOR_SIGNAL_PEAK = 1 << 5,        // Last value is at peak.
    INDICATOR_SIGNAL_VOLATILE = 1 << 6,    // Last value change is more volatile.
  };

  unsigned int signals;  // Store signals (@see: ENUM_INDICATOR_SIGNAL).

  // Constructors.
  IndicatorSignal(int _signals = 0) : signals(_signals) {}
  IndicatorSignal(ARRAY_REF(IndicatorDataEntry, _data), IndicatorDataParams &_idp, string _symbol, ENUM_TIMEFRAMES _tf,
                  int _m1 = 0, int _m2 = 0)
      : signals(0) {
    CalcSignals(_data, _idp, _symbol, _tf, _m1, _m2);
  }
  // Main methods.
  // Calculate signal values.
  void CalcSignals(ARRAY_REF(IndicatorDataEntry, _data), IndicatorDataParams &_idp, string _symbol, ENUM_TIMEFRAMES _tf,
                   int _m1 = 0, int _m2 = 0) {
    int _size = ArraySize(_data);
    // INDICATOR_SIGNAL_CROSSOVER
    bool _is_cross = false;
    if (_m1 != _m2) {
      bool _is_cross_dl = (_data[0][_m2] - _data[0][_m1]) < 0 && (_data[_size - 1][_m2] - _data[_size - 1][_m1] > 0);
      bool _is_cross_up = (_data[0][_m2] - _data[0][_m1]) > 0 && (_data[_size - 1][_m2] - _data[_size - 1][_m1] < 0);
      _is_cross = _is_cross_dl || _is_cross_up;
    } else {
      if (_size >= 4) {
        // @todo
      }
    }
    SetSignal(INDICATOR_SIGNAL_CROSSOVER, _is_cross);
    // INDICATOR_SIGNAL_DIVERGENCE
    int _shift0 = ChartStatic::iBarShift(_symbol, _tf, _data[0].timestamp);
    int _shift1 = ChartStatic::iBarShift(_symbol, _tf, _data[_size - 1].timestamp);
    double _price_w0 = ChartStatic::iPrice(PRICE_WEIGHTED, _symbol, _tf, _shift0);
    double _price_w1 = ChartStatic::iPrice(PRICE_WEIGHTED, _symbol, _tf, _shift1);
    SetSignal(INDICATOR_SIGNAL_DIVERGENCE,
              ((_price_w0 - _price_w1 > 0) && (_data[0][_m1] - _data[_size - 1][_m1]) < 0) ||
                  ((_price_w0 - _price_w1) < 0 && (_data[0][_m1] - _data[_size - 1][_m1]) > 0));
    // INDICATOR_SIGNAL_GT_PRICE
    bool _v_gt_p = false;
    if (_idp.Get<ENUM_IDATA_VALUE_RANGE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDVRANGE)) == IDATA_RANGE_PRICE) {
      _v_gt_p = _data[0][_m1] > _price_w0 || _data[0][_m2] > _price_w0;
    } else {
      // @todo
    }
    SetSignal(INDICATOR_SIGNAL_GT_PRICE, _v_gt_p);
    // INDICATOR_SIGNAL_INC
    SetSignal(INDICATOR_SIGNAL_INC, _data[0][_m1] > _data[1][_m1]);
    // INDICATOR_SIGNAL_LAST2SAME
    if (_size > 2) {
      bool _is_dec = _data[0][_m1] < _data[1][_m1] && _data[1][_m1] < _data[2][_m1];
      bool _is_inc = _data[0][_m1] > _data[1][_m1] && _data[1][_m1] > _data[2][_m1];
      SetSignal(INDICATOR_SIGNAL_LAST2SAME, _is_dec || _is_inc);
    }
    // INDICATOR_SIGNAL_PEAK
    bool _is_peak_max = true, _is_peak_min = true;
    for (int j = 1; j < _size && (_is_peak_max || _is_peak_min); j++) {
      _is_peak_max &= _data[0][_m1] > _data[j][_m1];
      _is_peak_min &= _data[0][_m1] < _data[j][_m1];
    }
    SetSignal(INDICATOR_SIGNAL_PEAK, _is_peak_max || _is_peak_min);
    // INDICATOR_SIGNAL_VOLATILE
    bool _is_vola = true;
    double _diff0 = fabs(_data[0][_m1] - _data[1][_m1]);
    for (int k = 1; k < _size - 1 && _is_vola; k++) {
      _is_vola &= _diff0 > fabs(_data[k][_m1] - _data[k + 1][_m1]);
    }
    SetSignal(INDICATOR_SIGNAL_VOLATILE, _is_vola);
  }
  // Signal methods for bitwise operations.
  /* Getters */
  bool CheckSignals(unsigned int _flags) { return (signals & _flags) != 0; }
  bool CheckSignalsXor(unsigned int _flags) { return (signals ^ _flags) != 0; }
  bool CheckSignalsAll(unsigned int _flags) { return (signals & _flags) == _flags; }
  bool CheckSignalsXorAll(unsigned int _flags) { return (signals ^ _flags) == _flags; }
  unsigned int GetSignals() { return signals; }
  /* Setters */
  void AddSignals(unsigned int _flags) { signals |= _flags; }
  void RemoveSignals(unsigned int _flags) { signals &= ~_flags; }
  void SetSignal(ENUM_INDICATOR_SIGNAL _flag, bool _value = true) {
    if (_value) {
      AddSignals(_flag);
    } else {
      RemoveSignals(_flag);
    }
  }
  void SetSignals(unsigned int _flags) { signals = _flags; }
  // Serializers.
  SerializerNodeType Serialize(Serializer &_s) {
    // _s.Pass(this, "signals", signals, SERIALIZER_FIELD_FLAG_DYNAMIC | SERIALIZER_FIELD_FLAG_FEATURE);
    int _size = sizeof(int) * 8;
    for (int i = 0; i < _size; i++) {
      int _value = CheckSignals(1 << i) ? 1 : 0;
      _s.Pass(this, (string)(i + 1), _value, SERIALIZER_FIELD_FLAG_DYNAMIC | SERIALIZER_FIELD_FLAG_FEATURE);
    }
    return SerializerNodeObject;
  }
};

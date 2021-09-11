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
struct IndicatorParams;

// Includes.
#include "Chart.struct.h"

/* Structure for strategy price stops. */
struct StrategyPriceStop {
  /* Define enumeration for strategy price stops. */
  enum ENUM_STRATEGY_PRICE_STOP {
    STRATEGY_PRICE_STOP_NONE = 0 << 0,                  // (None)
    STRATEGY_PRICE_STOP_INDI_PEAK = 1 << 0,             // Indicator value peak.
    STRATEGY_PRICE_STOP_INDI_PRICE = 1 << 1,            // Indicator value.
    STRATEGY_PRICE_STOP_PRICE = 1 << 2,                 // Price value.
    STRATEGY_PRICE_STOP_PRICE_PEAK = 1 << 3,            // Price value peak.
    STRATEGY_PRICE_STOP_PRICE_PP = 1 << 4,              // Price value of Pivot res/sup.
    STRATEGY_PRICE_STOP_VALUE_ADD_PRICE_DIFF = 1 << 5,  // Add price difference.
    STRATEGY_PRICE_STOP_VALUE_ADD_RANGE = 1 << 6,       // Add candle range to the trail value.
    // STRATEGY_PRICE_STOP_INDI_CHG_PCT = 1 << 0,  // Indicator value change (%).
  };

  float ivalue;         // Indicator price value.
  unsigned int method;  // Store price stop methods (@see: ENUM_STRATEGY_PRICE_STOP).
  // unsigned int mode[2]; // Indicator modes to use.
  ChartParams cparams;
  // IndicatorDataEntry idata[];
  // IndicatorParams iparams;

  /* Constructors */
  void StrategyPriceStop(int _method = 0, float _ivalue = 0) : method(_method), ivalue(_ivalue) {}
  // Main methods.
  // Calculate price stop value.
  float GetValue(int _shift = 0, int _direction = -1, float _min_trade_dist = 0.0f) {
    float _result = ivalue, _trail = _min_trade_dist;
    BarOHLC _ohlc0 = Chart::GetOHLC(cparams.tf.GetTf(), 0, cparams.symbol);
    BarOHLC _ohlc1 = Chart::GetOHLC(cparams.tf.GetTf(), _shift, cparams.symbol);
    if (CheckMethod(STRATEGY_PRICE_STOP_INDI_PRICE)) {
      _result = ivalue;
    }
    if (CheckMethod(STRATEGY_PRICE_STOP_PRICE)) {
      // Use price as a base line for the stop value.
      float _price;
      ENUM_APPLIED_PRICE _ap = PRICE_WEIGHTED;
      if (CheckMethod(STRATEGY_PRICE_STOP_PRICE_PEAK)) {
        // On peak, use low or high prices instead.
        _ap = _direction > 0 ? PRICE_HIGH : PRICE_LOW;
      }
      _price = (float)ChartStatic::iPrice(_ap, cparams.symbol, cparams.tf.GetTf(), _shift);
      _result = _direction > 0 ? fmax(_price, _result) : fmin(_price, _result);
    }
    if (CheckMethod(STRATEGY_PRICE_STOP_PRICE_PP)) {
      float _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4;
      float _prices[4];
      _prices[0] = _ohlc0.GetClose();
      _prices[1] = _direction > 0 ? _ohlc0.GetHigh() : _ohlc0.GetLow();
      _prices[2] = _direction > 0 ? _ohlc1.GetHigh() : _ohlc1.GetLow();
      _prices[3] = _ohlc1.GetOpen();
      BarOHLC _ohlc_pp(_prices, _ohlc0.GetTime());
      _ohlc_pp.GetPivots(PP_CLASSIC, _pp, _r1, _r2, _r3, _r4, _s1, _s2, _s3, _s4);
      _result = _direction > 0 ? fmax(_r1, _result) : fmin(_s1, _result);
    }
    if (CheckMethod(STRATEGY_PRICE_STOP_VALUE_ADD_PRICE_DIFF)) {
      _trail += fabs(_ohlc0.GetPivot() - _ohlc1.GetPivot());
    }
    if (CheckMethod(STRATEGY_PRICE_STOP_VALUE_ADD_RANGE)) {
      _trail += _ohlc1.GetRange();
    }
    _result = _result > 0 ? (_direction > 0 ? _result + _trail : _result - _trail) : 0;
    return _result;
  }
  /* Setters */
  void SetChartParams(ChartParams &_cparams) { cparams = _cparams; }
  void SetIndicatorPriceValue(float _ivalue) { ivalue = _ivalue; }
  /*
  void SetIndicatorDataEntry(IndicatorDataEntry &_data[]) {
    int _asize = ArraySize(idata);
    for (int i = 0; i < _asize; i++) {
      idata[i] = _data[i];
    }
  }
  void SetIndicatorParams(IndicatorParams &_iparams, int _m1 = 0, int _m2 = 0) {
    iparams = _iparams;
    mode[0] = _m1;
    mode[1] = _m2;
  }
  */
  /* Flag getters */
  bool CheckMethod(unsigned int _flags) { return (method & _flags) != 0; }
  bool CheckMethodsXor(unsigned int _flags) { return (method ^ _flags) != 0; }
  bool CheckMethodAll(unsigned int _flags) { return (method & _flags) == _flags; }
  bool CheckMethodXorAll(unsigned int _flags) { return (method ^ _flags) == _flags; }
  unsigned int GetMethod() { return method; }
  /* Flag setters */
  void AddMethod(unsigned int _flags) { method |= _flags; }
  void RemoveMethod(unsigned int _flags) { method &= ~_flags; }
  void SetMethod(ENUM_STRATEGY_PRICE_STOP _flag, bool _value = true) {
    if (_value) {
      AddMethod(_flag);
    } else {
      RemoveMethod(_flag);
    }
  }
  void SetMethod(unsigned int _flags) { method = _flags; }
  /* Serializers */
  SerializerNodeType Serialize(Serializer &_s) {
    int _size = sizeof(int) * 8;
    for (int i = 0; i < _size; i++) {
      int _value = CheckMethod(1 << i) ? 1 : 0;
      _s.Pass(this, (string)(i + 1), _value, SERIALIZER_FIELD_FLAG_DYNAMIC | SERIALIZER_FIELD_FLAG_FEATURE);
    }
    return SerializerNodeObject;
  }
};

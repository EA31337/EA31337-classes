//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Stores values fetchable and storeable in native arrays or custom data storages.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Prevents processing this includes file multiple times.
#ifndef VALUE_STORAGE_H
#define VALUE_STORAGE_H

// Defines.
#define INDICATOR_BUFFER_VALUE_STORAGE_HISTORY \
  100  // Number of entries the value storage buffer will be initialized with.

#define INDICATOR_CALCULATE_PARAMS_LONG                                                                                \
  ValueStorage<datetime> &_time, ValueStorage<double> &_open, ValueStorage<double> &_high, ValueStorage<double> &_low, \
      ValueStorage<double> &_close, ValueStorage<long> &_tick_volume, ValueStorage<long> &_volume,                     \
      ValueStorage<long> &_spread

#define INDICATOR_CALCULATE_PARAMS_SHORT ValueStorage<double> &_price

#define INDICATOR_CALCULATE_METHOD_PARAMS_LONG                                                                \
  const int rates_total, const int prev_calculated, ValueStorage<datetime> &time, ValueStorage<double> &open, \
      ValueStorage<double> &high, ValueStorage<double> &low, ValueStorage<double> &close,                     \
      ValueStorage<long> &tick_volume, ValueStorage<long> &volume, ValueStorage<long> &spread

#define INDICATOR_CALCULATE_METHOD_PARAMS_SHORT \
  const int rates_total, const int prev_calculated, const int begin, ValueStorage<double> &price

#define INDICATOR_CALCULATE_GET_PARAMS_LONG                                                                    \
  _cache.GetTotal(), _cache.GetPrevCalculated(), _time, _cache.GetPriceBuffer(PRICE_OPEN),                     \
      _cache.GetPriceBuffer(PRICE_HIGH), _cache.GetPriceBuffer(PRICE_LOW), _cache.GetPriceBuffer(PRICE_CLOSE), \
      _tick_volume, _volume, _spread

#define INDICATOR_CALCULATE_GET_PARAMS_SHORT _cache.GetTotal(), _cache.GetPrevCalculated(), 0, _cache.GetPriceBuffer()

#define INDICATOR_CALCULATE_POPULATE_CACHE(SYMBOL, TF, KEY)                                              \
  IndicatorCalculateCache<double> *_cache;                                                               \
  string _key = Util::MakeKey(SYMBOL, (int)TF, KEY);                                                     \
  if (!Objects<IndicatorCalculateCache<double>>::TryGet(_key, _cache)) {                                 \
    _cache = Objects<IndicatorCalculateCache<double>>::Set(_key, new IndicatorCalculateCache<double>()); \
  }

#define INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(SYMBOL, TF, KEY)                     \
  ValueStorage<datetime> *_time = TimeValueStorage::GetInstance(SYMBOL, TF);                    \
  ValueStorage<long> *_tick_volume = TickVolumeValueStorage::GetInstance(SYMBOL, TF);           \
  ValueStorage<long> *_volume = VolumeValueStorage::GetInstance(SYMBOL, TF);                    \
  ValueStorage<long> *_spread = SpreadValueStorage::GetInstance(SYMBOL, TF);                    \
  ValueStorage<double> *_price_open = PriceValueStorage::GetInstance(SYMBOL, TF, PRICE_OPEN);   \
  ValueStorage<double> *_price_high = PriceValueStorage::GetInstance(SYMBOL, TF, PRICE_HIGH);   \
  ValueStorage<double> *_price_low = PriceValueStorage::GetInstance(SYMBOL, TF, PRICE_LOW);     \
  ValueStorage<double> *_price_close = PriceValueStorage::GetInstance(SYMBOL, TF, PRICE_CLOSE); \
  INDICATOR_CALCULATE_POPULATE_CACHE(SYMBOL, TF, KEY)

#define INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT(SYMBOL, TF, APPLIED_PRICE, KEY) \
  ValueStorage<double> *_price = PriceValueStorage::GetInstance(SYMBOL, TF, APPLIED_PRICE); \
  INDICATOR_CALCULATE_POPULATE_CACHE(SYMBOL, TF, KEY)

#define INDICATOR_CALCULATE_POPULATED_PARAMS_LONG \
  _time, _price_open, _price_high, _price_low, _price_close, _tick_volume, _volume, _spread

#define INDICATOR_CALCULATE_POPULATED_PARAMS_SHORT _price

// Includes.
#include "Array.mqh"
#include "IValueStorage.h"
#include "Util.h"
#include "ValueStorage.accessor.h"

/**
 * Value storage settable/gettable via indexation operator.
 */
template <typename C>
class ValueStorage : public IValueStorage {
 public:
  /**
   * Indexation operator.
   */
  ValueStorageAccessor<C> operator[](int _index) {
    ValueStorageAccessor<C> _accessor(THIS_PTR, _index);
    return _accessor;
  }

  /**
   * Destructor.
   */
  virtual ~ValueStorage() {}

  /**
   * Initializes storage with given value.
   */
  virtual void Initialize(C _value) {}

  /**
   * Fetches value from a given shift. Takes into consideration as-series flag.
   */
  virtual C Fetch(int _shift) {
    Alert(__FUNCSIG__, " is not supported!");
    DebugBreak();
    return (C)0;
  }

  /**
   * Fetches value from the end of the array (assumes as-series storage).
   */
  virtual C FetchSeries(int _shift) { return Fetch(ArraySize(THIS_REF) - _shift - 1); }

  /**
   * Stores value at a given shift. Takes into consideration as-series flag.
   */
  virtual void Store(int _shift, C _value) {
    Alert(__FUNCSIG__, " is not supported!");
    DebugBreak();
  }
};

/**
 * ValueStorage-compatible wrapper for ArrayInitialize.
 */
template <typename C>
void ArrayInitialize(ValueStorage<C> &_storage, C _value) {
  _storage.Initialize(_value);
}

/**
 * ValueStorage-compatible wrapper for ArrayCopy.
 */
template <typename C, typename D>
int ArrayCopy(D &_target[], ValueStorage<C> &_source, int _dst_start = 0, int _src_start = 0, int count = WHOLE_ARRAY) {
  if (count == WHOLE_ARRAY) {
    count = ArraySize(_source);
  }

  if (ArrayGetAsSeries(_target)) {
    if ((ArraySize(_target) == 0 && _dst_start != 0) ||
        (ArraySize(_target) != 0 && ArraySize(_target) < _dst_start + count)) {
      // The receiving array is declared as AS_SERIES, and it is of insufficient size.
      SetUserError(ERR_SMALL_ASSERIES_ARRAY);
      ArrayResize(_target, 0);
      return 0;
    }
  }

  int _pre_fill = _dst_start;

  count = MathMin(count, ArraySize(_source) - _src_start);

  int _dst_required_size = _dst_start + count;

  if (ArraySize(_target) < _dst_required_size) {
    ArrayResize(_target, _dst_required_size, 32);
  }

  int _num_copied, t, s;

  for (_num_copied = 0, t = _dst_start, s = _src_start; _num_copied < count; ++_num_copied, ++t, ++s) {
    if (s >= ArraySize(_source)) {
      // No more data to copy.
      break;
    }

    bool _reverse = ArrayGetAsSeries(_target) != ArrayGetAsSeries(_source);

    int _source_idx = _reverse ? (ArraySize(_source) - s - 1 + _src_start) : s;

    _target[t] = _source[_source_idx].Get();
  }

  return _num_copied;
}

double iPrice(int _shift, ValueStorage<double> &_open, ValueStorage<double> &_high, ValueStorage<double> &_low,
              ValueStorage<double> &_close, ENUM_APPLIED_PRICE _ap) {
  switch (_ap) {
    case PRICE_OPEN:
      return _open.FetchSeries(_shift);
    case PRICE_HIGH:
      return _high.FetchSeries(_shift);
    case PRICE_LOW:
      return _low.FetchSeries(_shift);
    case PRICE_CLOSE:
      return _close.FetchSeries(_shift);
  }
  Alert("Wrong applied price for ValueStorage-based iPrice()!");
  DebugBreak();
  return 0;
}

/**
 * iHigest() version working on ValueStorage.
 */
int iHighest(ValueStorage<double> &_price, int _count = WHOLE_ARRAY, int _start = 0) {
  if (_count == WHOLE_ARRAY) {
    _count = ArraySize(_price);
  }

  int _peak_idx = _start;
  double _peak_val = _price.FetchSeries(_start);

  for (int i = _start; i < _count; ++i) {
    double _value = _price.FetchSeries(i);

    if (_value > _peak_val) {
      _peak_val = _value;
      _peak_idx = i;
    }
  }

  return _peak_idx;
}

/**
 * iLowest() version working on ValueStorage.
 */
int iLowest(ValueStorage<double> &_price, int _count = WHOLE_ARRAY, int _start = 0) {
  if (_count == WHOLE_ARRAY) {
    _count = ArraySize(_price);
  }

  int _peak_idx = _start;
  double _peak_val = _price.FetchSeries(_start);

  for (int i = _start; i < _count; ++i) {
    double _value = _price.FetchSeries(i);

    if (_value < _peak_val) {
      _peak_val = _value;
      _peak_idx = i;
    }
  }

  return _peak_idx;
}

#endif  // STRATEGY_MQH

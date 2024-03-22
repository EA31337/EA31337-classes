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

// Includes.
#include "../SerializerConversions.h"
#include "../Util.h"
#include "Objects.h"

// Enumeration for iPeak().
enum ENUM_IPEAK { IPEAK_LOWEST, IPEAK_HIGHEST };

// Defines.
#define INDICATOR_BUFFER_VALUE_STORAGE_HISTORY \
  300  // Number of entries the value storage buffer will be initialized with.

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

#define INDICATOR_CALCULATE_POPULATE_CACHE(INDI, KEY)                                                    \
  IndicatorCalculateCache<double> *_cache;                                                               \
  string _key = Util::MakeKey(INDI PTR_DEREF GetId(), KEY);                                              \
  if (!Objects<IndicatorCalculateCache<double>>::TryGet(_key, _cache)) {                                 \
    _cache = Objects<IndicatorCalculateCache<double>>::Set(_key, new IndicatorCalculateCache<double>()); \
  }

/**
 * Note that INDI is used as target indicator and source indicator is searched
 * by GetSuitableDataSource(). Would be better to differentiate target and
 * source indicator in order user wanted to run INDI on custom data source
 * (the one that doesn't exist in the hierarchy).
 */
#define INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_SHORT(INDI, APPLIED_PRICE, KEY)                                 \
  ValueStorage<double> *_price;                                                                                       \
  if (INDI PTR_DEREF GetSuitableDataSource() PTR_DEREF HasSpecificAppliedPriceValueStorage(APPLIED_PRICE, INDI)) {    \
    _price =                                                                                                          \
        INDI PTR_DEREF GetSuitableDataSource() PTR_DEREF GetSpecificAppliedPriceValueStorage(APPLIED_PRICE, INDI);    \
  } else {                                                                                                            \
    Print("Source indicator ", INDI PTR_DEREF GetFullName(),                                                          \
          " cannot be used as it doesn't provide a single buffer to be used by target indicator! You may try to set " \
          "applied price/data source mode and try again. AP passed by params: ",                                      \
          EnumToString(INDI PTR_DEREF GetAppliedPrice()),                                                             \
          ", AP overriden: ", EnumToString(INDI PTR_DEREF GetDataSourceAppliedType()));                               \
    DebugBreak();                                                                                                     \
  }                                                                                                                   \
  INDICATOR_CALCULATE_POPULATE_CACHE(INDI, KEY)

#define INDICATOR_CALCULATE_POPULATE_PARAMS_AND_CACHE_LONG(INDI, KEY)                                   \
  IndicatorData *_suitable_ds = INDI PTR_DEREF GetSuitableDataSource();                                 \
  ValueStorage<datetime> *_time =                                                                       \
      (ValueStorage<datetime> *)_suitable_ds PTR_DEREF GetSpecificValueStorage(INDI_VS_TYPE_TIME);      \
  ValueStorage<long> *_tick_volume =                                                                    \
      (ValueStorage<long> *)_suitable_ds PTR_DEREF GetSpecificValueStorage(INDI_VS_TYPE_TICK_VOLUME);   \
  ValueStorage<long> *_volume =                                                                         \
      (ValueStorage<long> *)_suitable_ds PTR_DEREF GetSpecificValueStorage(INDI_VS_TYPE_VOLUME);        \
  ValueStorage<long> *_spread =                                                                         \
      (ValueStorage<long> *)_suitable_ds PTR_DEREF GetSpecificValueStorage(INDI_VS_TYPE_SPREAD);        \
  ValueStorage<double> *_price_open =                                                                   \
      (ValueStorage<double> *)_suitable_ds PTR_DEREF GetSpecificValueStorage(INDI_VS_TYPE_PRICE_OPEN);  \
  ValueStorage<double> *_price_high =                                                                   \
      (ValueStorage<double> *)_suitable_ds PTR_DEREF GetSpecificValueStorage(INDI_VS_TYPE_PRICE_HIGH);  \
  ValueStorage<double> *_price_low =                                                                    \
      (ValueStorage<double> *)_suitable_ds PTR_DEREF GetSpecificValueStorage(INDI_VS_TYPE_PRICE_LOW);   \
  ValueStorage<double> *_price_close =                                                                  \
      (ValueStorage<double> *)_suitable_ds PTR_DEREF GetSpecificValueStorage(INDI_VS_TYPE_PRICE_CLOSE); \
  INDICATOR_CALCULATE_POPULATE_CACHE(INDI, KEY)

#define INDICATOR_CALCULATE_POPULATED_PARAMS_LONG \
  _time, _price_open, _price_high, _price_low, _price_close, _tick_volume, _volume, _spread

#define INDICATOR_CALCULATE_POPULATED_PARAMS_SHORT _price

// Includes.
#include "../Array.mqh"
#include "../Util.h"
#include "IValueStorage.h"
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
    Alert("Fetching data by shift is not supported from this value storage!");
    DebugBreak();
    return (C)0;
  }

  /**
   * Fetches value from a given datetime. Takes into consideration as-series flag.
   */
  virtual C Fetch(datetime _dt) {
    Alert("Fetching data by datetime is not supported from this value storage!");
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

  /**
   * Inserts new value at the end of the buffer. If buffer works as As-Series,
   * then new value will act as the one at index 0.
   */
  virtual void Append(C _value) {
    Alert(__FUNCSIG__, " does not implement Append()!");
    DebugBreak();
  }

  /**
   * Sets buffer drawing attributes. Currently does nothing.
   */
  bool PlotIndexSetInteger(int prop_id, int prop_modifier_or_value, int prop_value) {
    // @todo Implementation.
    return true;
  }
};

template <typename C>
string StringifyOHLC(ValueStorage<C> &_open, ValueStorage<C> &_high, ValueStorage<C> &_low, ValueStorage<C> &_close,
                     int _shift = 0) {
  C _o = _open[_shift].Get();
  C _h = _high[_shift].Get();
  C _l = _low[_shift].Get();
  C _c = _close[_shift].Get();
  return IntegerToString(_shift) + ": " + Util::MakeKey(_o, _h, _l, _c);
}

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

/**
 * iHigest() version working on ValueStorage.
 */
int iHighest(ValueStorage<double> &_price, int _count = WHOLE_ARRAY, int _start = 0) {
  return iPeak(_price, _count, _start, IPEAK_HIGHEST);
}

/**
 * iLowest() version working on ValueStorage.
 */
int iLowest(ValueStorage<double> &_price, int _count = WHOLE_ARRAY, int _start = 0) {
  return iPeak(_price, _count, _start, IPEAK_LOWEST);
}

/**
 * iLowest() version working on ValueStorage.
 */
int iPeak(ValueStorage<double> &_price, int _count, int _start, ENUM_IPEAK _type) {
  int _price_size = ArraySize(_price);

  if (_count == WHOLE_ARRAY) {
    _count = _price_size;
  }

  int _peak_idx = _start;
  double _peak_val = 0;

  switch (_type) {
    case IPEAK_LOWEST:
      _peak_val = DBL_MAX;
      break;
    case IPEAK_HIGHEST:
      _peak_val = -DBL_MAX;
      break;
  }

  for (int i = _start; (i < _start + _count) && (i < _price_size); ++i) {
    double _value = _price.FetchSeries(i);

    bool _cond = false;

    switch (_type) {
      case IPEAK_LOWEST:
        _cond = _value < _peak_val;
        break;
      case IPEAK_HIGHEST:
        _cond = _value > _peak_val;
        break;
    }

    if (_cond) {
      _peak_val = _value;
      _peak_idx = i;
    }
  }

  return _price_size - _peak_idx - 1;
}

#endif  // VALUE_STORAGE_H

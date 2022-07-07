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
 * Base interface for Indicator<T> class.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward declaration.
class Chart;

// Includes.
#include "Array.mqh"
#include "BufferStruct.mqh"
#include "Chart.mqh"
#include "Chart.struct.tf.h"
#include "ChartBase.h"
#include "ChartMt.h"
#include "DateTime.mqh"
#include "DrawIndicator.mqh"
#include "Flags.h"
#include "Indicator.define.h"
#include "Indicator.enum.h"
#include "Indicator.struct.cache.h"
#include "Indicator.struct.h"
#include "Indicator.struct.serialize.h"
#include "Indicator.struct.signal.h"
#include "Log.mqh"
#include "Object.mqh"
#include "Refs.mqh"
#include "Serializer.mqh"
#include "SerializerCsv.mqh"
#include "SerializerJson.mqh"
#include "Storage/ValueStorage.h"
#include "Storage/ValueStorage.indicator.h"
#include "Storage/ValueStorage.native.h"
#include "Util.h"

/**
 * Class to deal with indicators.
 */
class IndicatorBase : public Object {
 protected:
  IndicatorState istate;
  void* mydata;
  bool is_fed;                                     // Whether calc_start_bar is already calculated.
  int calc_start_bar;                              // Index of the first valid bar (from 0).
  DictStruct<int, Ref<IndicatorBase>> indicators;  // Indicators list keyed by id.
  bool indicator_builtin;
  ARRAY(IValueStorage*, value_storages);
  Ref<IndicatorBase> indi_src;  // // Indicator used as data source.
  IndicatorCalculateCache<double> cache;
  ARRAY(WeakRef<IndicatorBase>, listeners);  // List of indicators that listens for events from this one.
  long last_tick_time;                       // Time of the last Tick() call.
  int flags;                                 // Flags such as INDI_FLAG_INDEXABLE_BY_SHIFT.
  Ref<Log> logger;
  ENUM_INDI_VS_TYPE retarget_ap_av;  // Value storage type to be used as applied price/volume.
  DrawIndicator draw;
  bool do_draw;

 public:
  /* Indicator enumerations */

  /*
   * Default enumerations:
   *
   * ENUM_MA_METHOD values:
   *   0: MODE_SMA (Simple averaging)
   *   1: MODE_EMA (Exponential averaging)
   *   2: MODE_SMMA (Smoothed averaging)
   *   3: MODE_LWMA (Linear-weighted averaging)
   */

  /* Special methods */

  /**
   * Class constructor.
   */
  IndicatorBase() : indi_src(NULL), draw(THIS_PTR) {
    // By default, indicator is indexable only by shift and data source must be also indexable by shift.
    flags = INDI_FLAG_INDEXABLE_BY_SHIFT | INDI_FLAG_SOURCE_REQ_INDEXABLE_BY_SHIFT;
    calc_start_bar = 0;
    is_fed = false;
    indi_src = NULL;
    last_tick_time = 0;
    retarget_ap_av = INDI_VS_TYPE_NONE;
    do_draw = false;
  }

  /**
   * Class deconstructor.
   */
  virtual ~IndicatorBase() {
    ReleaseHandle();

    for (int i = 0; i < ArraySize(value_storages); ++i) {
      if (value_storages[i] != NULL) {
        delete value_storages[i];
      }
    }
  }

  /* Operator overloading methods */

  /**
   * Access indicator entry data using [] operator via shift.
   */
  IndicatorDataEntry operator[](int _index) {
    if (!bool(flags | INDI_FLAG_INDEXABLE_BY_SHIFT)) {
      Print(GetFullName(), " is not indexable by shift!");
      DebugBreak();
      IndicatorDataEntry _default;
      return _default;
    }
    return GetEntry(_index);
  }

  /**
   * Access indicator entry data using [] operator via datetime.
   */
  IndicatorDataEntry operator[](datetime _dt) {
    if (!bool(flags | INDI_FLAG_INDEXABLE_BY_TIMESTAMP)) {
      Print(GetFullName(), " is not indexable by timestamp!");
      DebugBreak();
      IndicatorDataEntry _default;
      return _default;
    }
    return GetEntry(_dt);
  }

  IndicatorDataEntry operator[](ENUM_INDICATOR_INDEX _index) { return GetEntry((int)_index); }

  /* Buffer methods */

  virtual string CacheKey() { return GetName(); }

  /**
   * Initializes a cached proxy between i*OnArray() methods and OnCalculate()
   * used by custom indicators.
   *
   * Note that OnCalculateProxy() method sets incoming price array as not
   * series. It will be reverted back by SetPrevCalculated(). It is because
   * OnCalculate() methods assumes that prices are set as not series.
   *
   * For real example how you can use this method, look at
   * Indi_MA::iMAOnArray() method.
   *
   * Usage:
   *
   * static double iFooOnArray(double &price[], int total, int period,
   *   int foo_shift, int foo_method, int shift, string cache_name = "")
   * {
   *  if (cache_name != "") {
   *   String cache_key;
   *   cache_key.Add(cache_name);
   *   cache_key.Add(period);
   *   cache_key.Add(foo_method);
   *
   *   Ref<IndicatorCalculateCache> cache = Indicator::OnCalculateProxy(cache_key.ToString(), price, total);
   *
   *   int prev_calculated =
   *     Indi_Foo::Calculate(total, cache.Ptr().prev_calculated, 0, price, cache.Ptr().buffer1, ma_method, period);
   *
   *   cache.Ptr().SetPrevCalculated(price, prev_calculated);
   *
   *   return cache.Ptr().GetValue(1, shift + ma_shift);
   *  }
   *  else {
   *    // Default iFooOnArray.
   *  }
   *
   *  WARNING: Do not use shifts when creating cache_key, as this will create many invalid buffers.
   */
  /*
  static IndicatorCalculateCache OnCalculateProxy(string key, double& price[], int& total) {
    if (total == 0) {
      total = ArraySize(price);
    }

    // Stores previously calculated value.
    static DictStruct<string, IndicatorCalculateCache> cache;

    unsigned int position;
    IndicatorCalculateCache cache_item;

    if (cache.KeyExists(key, position)) {
      cache_item = cache.GetByKey(key);
    } else {
      IndicatorCalculateCache cache_item_new(1, ArraySize(price));
      cache_item = cache_item_new;
      cache.Set(key, cache_item);
    }

    // Number of bars available in the chart. Same as length of the input `array`.
    int rates_total = ArraySize(price);

    int begin = 0;

    cache_item.Resize(rates_total);

    cache_item.price_was_as_series = ArrayGetAsSeries(price);
    ArraySetAsSeries(price, false);

    return cache_item;
  }
  */

  /**
   * Gets indicator data from a buffer and copy into struct array.
   *
   * @return
   * Returns true of successful copy.
   * Returns false on invalid values.
   */
  bool CopyEntries(IndicatorDataEntry& _data[], int _count, int _start_shift = 0) {
    bool _is_valid = true;
    if (ArraySize(_data) < _count) {
      _is_valid &= ArrayResize(_data, _count) > 0;
    }
    for (int i = 0; i < _count; i++) {
      IndicatorDataEntry _entry = GetEntry(_start_shift + i);
      _is_valid &= _entry.IsValid();
      _data[i] = _entry;
    }
    return _is_valid;
  }

  /**
   * Gets indicator data from a buffer and copy into array of values.
   *
   * @return
   * Returns true of successful copy.
   * Returns false on invalid values.
   */
  template <typename T>
  bool CopyValues(T& _data[], int _count, int _start_shift = 0, int _mode = 0) {
    bool _is_valid = true;
    if (ArraySize(_data) < _count) {
      _count = ArrayResize(_data, _count);
      _count = _count > 0 ? _count : ArraySize(_data);
    }
    for (int i = 0; i < _count; i++) {
      IndicatorDataEntry _entry = GetEntry(_start_shift + i);
      _is_valid &= _entry.IsValid();
      _data[i] = (T)_entry[_mode];
    }
    return _is_valid;
  }

  /**
   * Validates currently selected indicator used as data source.
   */
  void ValidateSelectedDataSource() {
    if (HasDataSource()) {
      ValidateDataSource(THIS_PTR, GetDataSourceRaw());
    }
  }

  /**
   * Loads and validates built-in indicators whose can be used as data source.
   */
  virtual void ValidateDataSource(IndicatorBase* _target, IndicatorBase* _source) {}

  /**
   * Checks whether indicator have given mode index.
   *
   * If given mode is -1 (default one) and indicator has exactly one mode, then mode index will be replaced by 0.
   */
  virtual void ValidateDataSourceMode(int& _out_mode) {}

  /**
   * Provides built-in indicators whose can be used as data source.
   */
  virtual IndicatorBase* FetchDataSource(ENUM_INDICATOR_TYPE _id) { return NULL; }

  /**
   * Returns the most parent data source.
   */
  IndicatorBase* GetOuterDataSource() {
    if (!HasDataSource()) return THIS_PTR;

    return GetDataSource() PTR_DEREF GetOuterDataSource();
  }

  /**
   * Returns currently selected data source without any validation.
   */
  IndicatorBase* GetDataSourceRaw() { return indi_src.Ptr(); }

  /**
   * Returns given data source type. Used by i*OnIndicator methods if indicator's Calculate() uses other indicators.
   */
  IndicatorBase* GetDataSource(ENUM_INDICATOR_TYPE _type) {
    IndicatorBase* _result = NULL;
    if (indicators.KeyExists((int)_type)) {
      _result = indicators[(int)_type].Ptr();
    } else {
      Ref<IndicatorBase> _indi = FetchDataSource(_type);
      if (!_indi.IsSet()) {
        Alert(GetFullName(), " does not define required indicator type ", EnumToString(_type), " for symbol ",
              GetSymbol(), ", and timeframe ", GetTf(), "!");
        DebugBreak();
      } else {
        indicators.Set((int)_type, _indi);
        _result = _indi.Ptr();
      }
    }
    return _result;
  }

  /**
   * Called if data source is requested, but wasn't yet set. May be used to initialize indicators that must operate on
   * some data source.
   */
  virtual IndicatorBase* OnDataSourceRequest() {
    Print("In order to use IDATA_INDICATOR mode for indicator ", GetFullName(),
          " without explicitly selecting an indicator, ", GetFullName(),
          " must override OnDataSourceRequest() method and return new instance of data source to be used by default.");
    DebugBreak();
    return NULL;
  }

  /**
   * Creates default, tick based indicator for given applied price.
   */
  virtual IndicatorBase* DataSourceRequestReturnDefault(int _applied_price) {
    //    DebugBreak();
    return NULL;
  }

  /* Getters */

  /**
   * Gets OHLC price values.
   */
  virtual BarOHLC GetOHLC(int _shift = 0) { return GetCandle() PTR_DEREF GetOHLC(_shift); }

  /**
   * Gets ask price for a given date and time. Return current ask price if _dt wasn't passed or is 0.
   */
  virtual double GetAsk(datetime _dt = 0) { return GetTick() PTR_DEREF GetAsk(_dt); }

  /**
   * Gets bid price for a given date and time. Return current bid price if _dt wasn't passed or is 0.
   */
  virtual double GetBid(datetime _dt = 0) { return GetTick() PTR_DEREF GetBid(_dt); }

  /**
   * Get current (or by given date and time) open price depending on the operation type.
   */
  double GetOpenOffer(ENUM_ORDER_TYPE _cmd, datetime _dt = 0) {
    // Use the right open price at opening of a market order. For example:
    // - When selling, only the latest Bid prices can be used.
    // - When buying, only the latest Ask prices can be used.
    return _cmd == ORDER_TYPE_BUY ? GetAsk(_dt) : GetBid(_dt);
  }

  /**
   * Get current close price depending on the operation type.
   */
  double GetCloseOffer(ENUM_ORDER_TYPE _cmd) { return _cmd == ORDER_TYPE_BUY ? GetBid() : GetAsk(); }

  /**
   * Gets open price for a given, optional shift.
   */
  virtual double GetOpen(int _shift = 0) { return GetCandle() PTR_DEREF GetOpen(_shift); }

  /**
   * Gets high price for a given, optional shift.
   */
  virtual double GetHigh(int _shift = 0) { return GetCandle() PTR_DEREF GetHigh(_shift); }

  /**
   * Gets low price for a given, optional shift.
   */
  virtual double GetLow(int _shift = 0) { return GetCandle() PTR_DEREF GetLow(_shift); }

  /**
   * Gets close price for a given, optional shift.
   */
  virtual double GetClose(int _shift = 0) { return GetCandle() PTR_DEREF GetClose(_shift); }

  /**
   * Returns time of the bar for a given shift.
   */
  virtual datetime GetBarTime(int _shift = 0) { return GetCandle() PTR_DEREF GetBarTime(_shift); }

  /**
   * Returns time of the last bar.
   */
  virtual datetime GetLastBarTime() { return GetCandle() PTR_DEREF GetLastBarTime(); }

  /**
   * Returns the current price value given applied price type, symbol and timeframe.
   */
  virtual double GetPrice(ENUM_APPLIED_PRICE _ap, int _shift = 0) {
    return GetCandle() PTR_DEREF GetPrice(_ap, _shift);
  }

  /**
   * Returns spread for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual long GetSpread(int _shift = 0) { return GetCandle() PTR_DEREF GetSpread(_shift); }

  /**
   * Returns spread in pips.
   */
  virtual double GetSpreadInPips(int _shift = 0) {
    return (GetAsk() - GetBid()) * pow(10, GetSymbolProps().GetPipDigits());
  }

  /**
   * Returns tick volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual long GetTickVolume(int _shift = 0) { return GetCandle() PTR_DEREF GetTickVolume(_shift); }

  /**
   * Returns volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  virtual long GetVolume(int _shift = 0) { return GetCandle() PTR_DEREF GetVolume(_shift); }

  /**
   * Returns the shift of the maximum value over a specific number of periods depending on type.
   */
  virtual int GetHighest(int type, int _count = WHOLE_ARRAY, int _start = 0) {
    return GetCandle() PTR_DEREF GetHighest(type, _count, _start);
  }

  /**
   * Returns the shift of the minimum value over a specific number of periods depending on type.
   */
  virtual int GetLowest(int type, int _count = WHOLE_ARRAY, int _start = 0) {
    return GetCandle() PTR_DEREF GetLowest(type, _count, _start);
  }

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  virtual unsigned int GetSuitableDataSourceTypes() { return 0; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  virtual unsigned int GetPossibleDataModes() { return 0; }

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  virtual bool OnCheckIfSuitableDataSource(IndicatorBase* _ds) {
    Flags<unsigned int> _suitable_types = GetSuitableDataSourceTypes();

    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_EXPECT_NONE)) {
      return false;
    }

    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_AP)) {
      ENUM_INDI_VS_TYPE _requested_vs_type = GetAppliedPriceValueStorageType();
      return _ds PTR_DEREF HasSpecificValueStorage(_requested_vs_type);
    }

    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_AV)) {
      ENUM_INDI_VS_TYPE _requested_vs_type = GetAppliedVolumeValueStorageType();
      return _ds PTR_DEREF HasSpecificValueStorage(_requested_vs_type);
    }

    return false;
  }

  /**
   * Returns applied price as set by the indicator's params.
   */
  virtual ENUM_APPLIED_PRICE GetAppliedPrice() {
    Print("Error: GetAppliedPrice() was requested by ", GetFullName(), ", but it does not implement it!");
    DebugBreak();
    return (ENUM_APPLIED_PRICE)-1;
  }

  /**
   * Returns applied volume as set by the indicator's params.
   */
  virtual ENUM_APPLIED_VOLUME GetAppliedVolume() {
    Print("Error: GetAppliedVolume() was requested by ", GetFullName(), ", but it does not implement it!");
    DebugBreak();
    return (ENUM_APPLIED_VOLUME)-1;
  }

  /**
   * Returns value storage's buffer type from this indicator's applied price (indicator must override GetAppliedPrice()
   * method!).
   */
  virtual ENUM_INDI_VS_TYPE GetAppliedPriceValueStorageType() {
    if (retarget_ap_av != INDI_VS_TYPE_NONE) {
      // User wants to use custom value storage type as applied price.
      return retarget_ap_av;
    }

    switch (GetAppliedPrice()) {
      case PRICE_ASK:
        return INDI_VS_TYPE_PRICE_ASK;
      case PRICE_BID:
        return INDI_VS_TYPE_PRICE_BID;
      case PRICE_OPEN:
        return INDI_VS_TYPE_PRICE_OPEN;
      case PRICE_HIGH:
        return INDI_VS_TYPE_PRICE_HIGH;
      case PRICE_LOW:
        return INDI_VS_TYPE_PRICE_LOW;
      case PRICE_CLOSE:
        return INDI_VS_TYPE_PRICE_CLOSE;
      case PRICE_MEDIAN:
        return INDI_VS_TYPE_PRICE_MEDIAN;
      case PRICE_TYPICAL:
        return INDI_VS_TYPE_PRICE_TYPICAL;
      case PRICE_WEIGHTED:
        return INDI_VS_TYPE_PRICE_WEIGHTED;
    }

    Print("Error: ", GetFullName(), " has not supported applied price set: ", EnumToString(GetAppliedPrice()), "!");
    DebugBreak();
    return (ENUM_INDI_VS_TYPE)-1;
  }

  /**
   * Returns value storage's buffer type from this indicator's applied volume (indicator must override
   * GetAppliedVolume() method!).
   */
  virtual ENUM_INDI_VS_TYPE GetAppliedVolumeValueStorageType() {
    if (retarget_ap_av != INDI_VS_TYPE_NONE) {
      // User wants to use custom value storage type as applied volume.
      return retarget_ap_av;
    }

    switch (GetAppliedVolume()) {
      case VOLUME_TICK:
        return INDI_VS_TYPE_TICK_VOLUME;
      case VOLUME_REAL:
        return INDI_VS_TYPE_VOLUME;
    }

    Print("Error: ", GetFullName(), " has not supported applied volume set: ", EnumToString(GetAppliedVolume()), "!");
    DebugBreak();
    return (ENUM_INDI_VS_TYPE)-1;
  }

  /**
   * Uses custom value storage type as applied price.
   */
  void SetDataSourceAppliedPrice(ENUM_INDI_VS_TYPE _vs_type) {
    // @todo Check if given value storage is of compatible type (double)!
    retarget_ap_av = _vs_type;
  }

  /**
   * Uses custom value storage type as applied volume.
   */
  void SetDataSourceAppliedVolume(ENUM_INDI_VS_TYPE _vs_type) {
    // @todo Check if given value storage is of compatible type (long)!
    retarget_ap_av = _vs_type;
  }

  /**
   * Gets value storage type previously set by SetDataSourceAppliedPrice() or SetDataSourceAppliedVolume().
   */
  ENUM_INDI_VS_TYPE GetDataSourceAppliedType() { return retarget_ap_av; }

  /**
   * Checks whether there is attached suitable data source (if required).
   */
  bool HasSuitableDataSource() {
    Flags<unsigned int> _flags = GetSuitableDataSourceTypes();
    return !_flags.HasFlag(INDI_SUITABLE_DS_TYPE_EXPECT_NONE) && GetSuitableDataSource(false) != nullptr;
  }

  /**
   * Returns best suited data source for this indicator.
   */
  virtual IndicatorBase* GetSuitableDataSource(bool _warn_if_not_found = true) {
    Flags<unsigned int> _suitable_types = GetSuitableDataSourceTypes();
    IndicatorBase* _curr_indi;

    // There shouldn't be any attached data source.
    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_EXPECT_NONE) && GetDataSource() != nullptr) {
      if (_warn_if_not_found) {
        Print("Error: ", GetFullName(), " doesn't support attaching data source, but has one attached!");
        DebugBreak();
      }
      return nullptr;
    }

    // Custom set of required buffers. Will invoke virtual OnCheckIfSuitableDataSource().
    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_CUSTOM)) {
      // Searching suitable data source in hierarchy.
      for (_curr_indi = GetDataSource(false); _curr_indi != nullptr;
           _curr_indi = _curr_indi PTR_DEREF GetDataSource(false)) {
        if (OnCheckIfSuitableDataSource(_curr_indi)) return _curr_indi;

        if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_BASE_ONLY)) {
          // Directly connected data source must be suitable, so we stops for loop.
          if (_warn_if_not_found) {
            Print("Error: ", GetFullName(),
                  " requested custom type of data source to be directly connected to this indicator, but none "
                  "satisfies the requirements!");
            DebugBreak();
          }
          return nullptr;
        }
      }

      if (_warn_if_not_found) {
        Print("Error: ", GetFullName(),
              " requested custom type of indicator as data source, but there is none in the hierarchy which satisfies "
              "the requirements!");
        DebugBreak();
      }
      return nullptr;
    }

    // Requires Candle-compatible indicator in the hierarchy.
    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_CANDLE)) {
      if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_BASE_ONLY)) {
        // Candle indicator must be directly connected to this indicator as its data source.
        _curr_indi = GetDataSource(false);

        if (_curr_indi == nullptr || !_curr_indi PTR_DEREF IsCandleIndicator()) {
          if (_warn_if_not_found) {
            Print("Error: ", GetFullName(),
                  " must have Candle-compatible indicator directly conected as a data source! We don't search for it "
                  "further in the hierarchy.");
            DebugBreak();
          }
          return nullptr;
        }

        return _curr_indi;
      } else {
        // Candle indicator must be in the data source hierarchy.
        _curr_indi = GetCandle(false);

        if (_curr_indi != nullptr) return _curr_indi;

        if (!_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_TICK)) {
          if (_warn_if_not_found) {
            Print("Error: ", GetFullName(),
                  " requested Candle-compatible type of indicator as data source, but there is none in the hierarchy!");
            DebugBreak();
          }
          return nullptr;
        }
      }
    }

    // Requires Tick-compatible indicator in the hierarchy.
    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_TICK)) {
      if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_BASE_ONLY)) {
        // Tick indicator must be directly connected to this indicator as its data source.
        _curr_indi = GetDataSource(false);

        if (_curr_indi == nullptr || !_curr_indi PTR_DEREF IsTickIndicator()) {
          if (_warn_if_not_found) {
            Print("Error: ", GetFullName(),
                  " must have Tick-compatible indicator directly conected as a data source! We don't search for it "
                  "further in the hierarchy.");
            DebugBreak();
          }
        }

        return _curr_indi;
      } else {
        _curr_indi = GetTick(false);
        if (_curr_indi != nullptr) return _curr_indi;

        if (_warn_if_not_found) {
          Print("Error: ", GetFullName(), " must have Tick-compatible indicator in the data source hierarchy!");
          DebugBreak();
        }
        return nullptr;
      }
    }

    // Requires a single buffered or OHLC-compatible indicator (targetted via applied price) in the hierarchy.
    if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_AP)) {
      // Applied price is defined by this indicator, so it must override GetAppliedPrice().
      ENUM_INDI_VS_TYPE _requested_vs_type = GetAppliedPriceValueStorageType();

      // Searching for given buffer type in the hierarchy.
      for (_curr_indi = GetDataSource(false); _curr_indi != nullptr;
           _curr_indi = _curr_indi PTR_DEREF GetDataSource(false)) {
        if (_curr_indi PTR_DEREF HasSpecificValueStorage(_requested_vs_type)) {
          return _curr_indi;
        }

        if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_BASE_ONLY)) {
          // Directly connected data source must have given data storage buffer, so we stops for loop.
          if (_warn_if_not_found) {
            Print("Error: ", GetFullName(),
                  " requested directly connected data source to contain value storage of type ",
                  EnumToString(_requested_vs_type), ", but there is no such data storage!");
            DebugBreak();
          }
          return nullptr;
        }
      }

      if (_warn_if_not_found) {
        Print("Error: ", GetFullName(), " requested that there is data source that contain value storage of type ",
              EnumToString(_requested_vs_type), " in the hierarchy, but there is no such data source!");
        DebugBreak();
      }
      return nullptr;
    }

    // Requires a single buffered or OHLC-compatible indicator (targetted via applied price or volume) in the hierarchy.
    if (_suitable_types.HasAnyFlag(INDI_SUITABLE_DS_TYPE_AP | INDI_SUITABLE_DS_TYPE_AV)) {
      ENUM_INDI_VS_TYPE _requested_vs_type = (ENUM_INDI_VS_TYPE)-1;

      if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_AP)) {
        // Applied price is defined by this indicator, so it must override GetAppliedPrice().
        _requested_vs_type = GetAppliedPriceValueStorageType();
      } else if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_AV)) {
        // Applied volume is defined by this indicator, so it must override GetAppliedVolume().
        _requested_vs_type = GetAppliedVolumeValueStorageType();
      }

      // Searching for given buffer type in the hierarchy.
      for (_curr_indi = GetDataSource(false); _curr_indi != nullptr;
           _curr_indi = _curr_indi PTR_DEREF GetDataSource(false)) {
        if (_curr_indi PTR_DEREF HasSpecificValueStorage(_requested_vs_type)) {
          return _curr_indi;
        }

        if (_suitable_types.HasFlag(INDI_SUITABLE_DS_TYPE_BASE_ONLY)) {
          // Directly connected data source must have given data storage buffer, so we stops for loop.
          if (_warn_if_not_found) {
            Print("Error: ", GetFullName(),
                  " requested directly connected data source to contain value storage of type ",
                  EnumToString(_requested_vs_type), ", but there is no such data storage!");
            DebugBreak();
          }
          return nullptr;
        }
      }

      if (_warn_if_not_found) {
        Print("Error: ", GetFullName(), " requested that there is data source that contain value storage of type ",
              EnumToString(_requested_vs_type), " in the hierarchy, but there is no such data source!");
        DebugBreak();
      }
      return nullptr;
    }

    if (_warn_if_not_found) {
      Print("Error: ", GetFullName(),
            " must have data source, but its configuration leave us without suitable one. Please override "
            "GetSuitableDataSourceTypes() method so it will return suitable data source types!");
      DebugBreak();
    }

    return nullptr;
  }

  /**
   * Returns the number of bars on the chart.
   */
  virtual int GetBars() { return GetCandle() PTR_DEREF GetBars(); }

  /**
   * Returns index of the current bar.
   */
  virtual int GetBarIndex() { return GetCandle() PTR_DEREF GetBarIndex(); }

  /**
   * Returns current tick index (incremented every OnTick()).
   */
  virtual int GetTickIndex() { return GetTick() PTR_DEREF GetTickIndex(); }

  /**
   * Check if there is a new bar to parse.
   */
  virtual bool IsNewBar() { return GetCandle() PTR_DEREF IsNewBar(); }

  /**
   * Search for a bar by its time.
   *
   * Returns the index of the bar which covers the specified time.
   */
  virtual int GetBarShift(datetime _time, bool _exact = false) {
    return GetTick() PTR_DEREF GetBarShift(_time, _exact);
  }

  /**
   * Get peak price at given number of bars.
   *
   * In case of error, check it via GetLastError().
   */
  virtual double GetPeakPrice(int _bars, int _mode, int _index) {
    return GetTick() PTR_DEREF GetPeakPrice(_bars, _mode, _index);
  }

  /**
   * Returns indicator's flags.
   */
  int GetFlags() { return flags; }

  /**
   * Returns buffers' cache.
   */
  IndicatorCalculateCache<double>* GetCache() { return &cache; }

  /**
   * Gets an indicator's state property value.
   */
  template <typename T>
  T Get(STRUCT_ENUM(IndicatorState, ENUM_INDICATOR_STATE_PROP) _prop) {
    return istate.Get<T>(_prop);
  }

  /**
   * Returns logger.
   */
  Log* GetLogger() {
    if (!logger.IsSet()) {
      logger = new Log();
    }
    return logger.Ptr();
  }

  /**
   * Gets number of modes available to retrieve by GetValue().
   */
  virtual int GetModeCount() { return 0; }

  /* Getters */

  /**
   * Whether data source is selected.
   */
  virtual bool HasDataSource(bool _try_initialize = false) { return false; }

  /**
   * Whether given data source is in the hierarchy.
   */
  bool HasDataSource(IndicatorBase* _indi) {
    if (THIS_PTR == _indi) return true;

    if (HasDataSource(true)) {
      return GetDataSourceRaw() PTR_DEREF HasDataSource(_indi);
    }

    return false;
  }

  /**
   * Returns currently selected data source doing validation.
   */
  virtual IndicatorBase* GetDataSource(bool _validate = true) { return NULL; }

  /**
   * Checks whether there is Candle-featured in the hierarchy.
   */
  bool HasCandleInHierarchy() { return GetCandle(false) != nullptr; }

  /**
   * Checks whether there is Tick-featured in the hierarchy.
   */
  bool HasTickInHierarchy() { return GetTick(false) != nullptr; }

  /**
   * Checks whether current indicator has all buffers required to be a Candle-compatible indicator.
   */
  bool IsCandleIndicator() {
    return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_OPEN) && HasSpecificValueStorage(INDI_VS_TYPE_PRICE_HIGH) &&
           HasSpecificValueStorage(INDI_VS_TYPE_PRICE_LOW) && HasSpecificValueStorage(INDI_VS_TYPE_PRICE_CLOSE) &&
           HasSpecificValueStorage(INDI_VS_TYPE_SPREAD) && HasSpecificValueStorage(INDI_VS_TYPE_TICK_VOLUME) &&
           HasSpecificValueStorage(INDI_VS_TYPE_TIME) && HasSpecificValueStorage(INDI_VS_TYPE_VOLUME);
  }

  /**
   * Checks whether current indicator has all buffers required to be a Tick-compatible indicator.
   */
  bool IsTickIndicator() {
    return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_ASK) && HasSpecificValueStorage(INDI_VS_TYPE_PRICE_BID) &&
           HasSpecificValueStorage(INDI_VS_TYPE_SPREAD) && HasSpecificValueStorage(INDI_VS_TYPE_VOLUME) &&
           HasSpecificValueStorage(INDI_VS_TYPE_TICK_VOLUME);
  }

  /**
   * Traverses source indicators' hierarchy and tries to find OHLC-featured
   * indicator. IndicatorCandle satisfies such requirements.
   */
  virtual IndicatorBase* GetCandle(bool _warn_if_not_found = true, IndicatorBase* _originator = nullptr) {
    if (_originator == nullptr) {
      _originator = THIS_PTR;
    }
    if (IsCandleIndicator()) {
      return THIS_PTR;
    } else if (HasDataSource()) {
      return GetDataSource() PTR_DEREF GetCandle(_warn_if_not_found, _originator);
    } else {
      // _indi_src == NULL.
      if (_warn_if_not_found) {
        Print(
            "Can't find Candle-compatible indicator (which have storage buffers for: Open, High, Low, Close, Spread, "
            "Tick Volume, Time, Volume) in the "
            "hierarchy of ",
            _originator PTR_DEREF GetFullName(), "!");
        DebugBreak();
      }
      return NULL;
    }
  }

  /**
   * Traverses source indicators' hierarchy and tries to find Ask, Bid, Spread,
   * Volume and Tick Volume-featured indicator. IndicatorTick satisfies such
   * requirements.
   */
  virtual IndicatorBase* GetTick(bool _warn_if_not_found = true) {
    if (IsTickIndicator()) {
      return THIS_PTR;
    } else if (HasDataSource()) {
      return GetDataSource() PTR_DEREF GetTick();
    }

    // No IndicatorTick compatible indicator found in hierarchy.
    if (_warn_if_not_found) {
      Print(
          "Can't find Tick-compatible indicator (which have storage buffers for: Ask, Bid, Spread, Volume, Tick "
          "Volume) in the hierarchy!");
      DebugBreak();
    }
    return NULL;
  }

  /**
   * Get indicator type.
   */
  virtual ENUM_INDICATOR_TYPE GetType() { return INDI_NONE; }

  /**
   * Get data type of indicator.
   */
  virtual ENUM_DATATYPE GetDataType() { return (ENUM_DATATYPE)-1; }

  /**
   * Get name of the indicator.
   */
  virtual string GetName() { return EnumToString(GetType()); }

  /**
   * Get full name of the indicator (with "over ..." part).
   */
  virtual string GetFullName() { return GetName(); }

  /**
   * Get more descriptive name of the indicator.
   */
  virtual string GetDescriptiveName() { return GetName(); }

  /**
   * Returns symbol and optionally TF to be used e.g., to identify
   */
  string GetSymbolTf(string _separator = "@") {
    if (!HasCandleInHierarchy()) {
      return "";
    }

    // Symbol is available throught Tick indicator at the end of the hierarchy.
    string _res = GetSymbol();

    if (HasCandleInHierarchy()) {
      // TF is available throught Candle indicator at the end of the hierarchy.
      _res += _separator + ChartTf::TfToString(GetTf());
    }

    return _res;
  }

  /* Setters */

  /**
   * Sets whether indicator's buffers should be drawn on the chart.
   */
  void SetDraw(bool _value, color _color = clrAquamarine, int _window = 0) {
    draw.SetEnabled(_value);
    draw.SetColorLine(_color);
    draw.SetWindow(_window);
  }

  /**
   * Adds event listener.
   */
  void AddListener(IndicatorBase* _indi) {
    WeakRef<IndicatorBase> _ref = _indi;
    ArrayPushObject(listeners, _ref);
  }

  /**
   * Removes event listener.
   */
  void RemoveListener(IndicatorBase* _indi) {
    WeakRef<IndicatorBase> _ref = _indi;
    Util::ArrayRemoveFirst(listeners, _ref);
  }

  /**
   * Sets indicator data source.
   */
  virtual void SetDataSource(IndicatorBase* _indi, int _input_mode = -1) = NULL;

  /**
   * Injects data source between this indicator and its data source.
   */
  void InjectDataSource(IndicatorBase* _indi) {
    if (_indi == THIS_PTR) {
      // Indicator already injected.
      return;
    }

    IndicatorBase* _previous_ds = GetDataSource(false);

    SetDataSource(_indi);

    if (_previous_ds != nullptr) {
      _indi PTR_DEREF SetDataSource(_previous_ds);
    }
  }

  /**
   * Sets name of the indicator.
   */
  virtual void SetName(string _name) {}

  /**
   * Sets indicator's handle.
   *
   * Note: Not supported in MT4.
   */
  virtual void SetHandle(int _handle) {}

  /* Other methods */

  /**
   * Releases indicator's handle.
   *
   * Note: Not supported in MT4.
   */
  void ReleaseHandle() {
#ifdef __MQL5__
    if (istate.handle != INVALID_HANDLE) {
      IndicatorRelease(istate.handle);
    }
#endif
    istate.handle = INVALID_HANDLE;
    istate.is_changed = true;
  }

  /**
   * Checks whether indicator have given mode (max_modes is greater that given mode).
   */
  bool HasValueStorage(int _mode = 0) { return _mode < GetModeCount(); }

  /**
   * Returns value storage for a given mode.
   */
  virtual IValueStorage* GetValueStorage(int _mode = 0) {
    if (_mode >= ArraySize(value_storages)) {
      ArrayResize(value_storages, _mode + 1);
    }

    if (value_storages[_mode] == nullptr) {
      value_storages[_mode] = new IndicatorBufferValueStorage<double>(THIS_PTR, _mode);
    }
    return value_storages[_mode];
  }

  /**
   * Initializes value storage to be later accessed via GetValueStorage() for a given mode.
   */
  void SetValueStorage(int _mode, IValueStorage* _storage) {
    if (_mode >= ArraySize(value_storages)) {
      ArrayResize(value_storages, _mode + 1);
    }

    if (value_storages[_mode] != NULL) {
      delete value_storages[_mode];
    }

    value_storages[_mode] = _storage;
  }

  /**
   * Returns value storage of given kind.
   */
  virtual IValueStorage* GetSpecificValueStorage(ENUM_INDI_VS_TYPE _type) {
    // Maybe indexed value storage? E.g., INDI_VS_TYPE_INDEX_0.
    if ((int)_type >= INDI_VS_TYPE_INDEX_FIRST && (int)_type <= INDI_VS_TYPE_INDEX_LAST) {
      if (HasValueStorage((int)_type - INDI_VS_TYPE_INDEX_FIRST)) {
        return GetValueStorage((int)_type - INDI_VS_TYPE_INDEX_FIRST);
      }
    }

    Print("Error: ", GetFullName(), " indicator has no storage type ", EnumToString(_type), "!");
    DebugBreak();
    return NULL;
  }

  /**
   * Returns value storage to be used for given applied price or applied price overriden by target indicator via
   * SetDataSourceAppliedPrice().
   */
  virtual ValueStorage<double>* GetSpecificAppliedPriceValueStorage(ENUM_APPLIED_PRICE _ap,
                                                                    IndicatorBase* _target = nullptr) {
    if (_target != nullptr) {
      if (_target PTR_DEREF GetDataSourceAppliedType() != INDI_VS_TYPE_NONE) {
        // User wants to use custom value storage type as applied price, so we forcefully override AP given as the
        // parameter.
        // @todo Check for value storage compatibility (double).
        return (ValueStorage<double>*)GetSpecificValueStorage(_target PTR_DEREF GetDataSourceAppliedType());
      }
    }

    switch (_ap) {
      case PRICE_ASK:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_VS_TYPE_PRICE_ASK);
      case PRICE_BID:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_VS_TYPE_PRICE_BID);
      case PRICE_OPEN:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_VS_TYPE_PRICE_OPEN);
      case PRICE_HIGH:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_VS_TYPE_PRICE_HIGH);
      case PRICE_LOW:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_VS_TYPE_PRICE_LOW);
      case PRICE_CLOSE:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_VS_TYPE_PRICE_CLOSE);
      case PRICE_MEDIAN:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_VS_TYPE_PRICE_MEDIAN);
      case PRICE_TYPICAL:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_VS_TYPE_PRICE_TYPICAL);
      case PRICE_WEIGHTED:
        return (ValueStorage<double>*)GetSpecificValueStorage(INDI_VS_TYPE_PRICE_WEIGHTED);
      default:
        Print("Error: Invalid applied price " + EnumToString(_ap) +
              ", only PRICE_(OPEN|HIGH|LOW|CLOSE|MEDIAN|TYPICAL|WEIGHTED) are currently supported by "
              "IndicatorBase::GetSpecificAppliedPriceValueStorage()!");
        DebugBreak();
        return NULL;
    }
  }

  virtual bool HasSpecificAppliedPriceValueStorage(ENUM_APPLIED_PRICE _ap, IndicatorBase* _target = nullptr) {
    if (_target != nullptr) {
      if (_target PTR_DEREF GetDataSourceAppliedType() != INDI_VS_TYPE_NONE) {
        // User wants to use custom value storage type as applied price, so we forcefully override AP given as the
        // parameter.
        // @todo Check for value storage compatibility (double).
        return HasSpecificValueStorage(_target PTR_DEREF GetDataSourceAppliedType());
      }
    }

    switch (_ap) {
      case PRICE_ASK:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_ASK);
      case PRICE_BID:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_BID);
      case PRICE_OPEN:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_OPEN);
      case PRICE_HIGH:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_HIGH);
      case PRICE_LOW:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_LOW);
      case PRICE_CLOSE:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_CLOSE);
      case PRICE_MEDIAN:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_MEDIAN);
      case PRICE_TYPICAL:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_TYPICAL);
      case PRICE_WEIGHTED:
        return HasSpecificValueStorage(INDI_VS_TYPE_PRICE_WEIGHTED);
      default:
        Print("Error: Invalid applied price " + EnumToString(_ap) +
              ", only PRICE_(OPEN|HIGH|LOW|CLOSE|MEDIAN|TYPICAL|WEIGHTED) are currently supported by "
              "IndicatorBase::HasSpecificAppliedPriceValueStorage()!");
        DebugBreak();
        return false;
    }
  }

  /**
   * Checks whether indicator support given value storage type.
   */
  virtual bool HasSpecificValueStorage(ENUM_INDI_VS_TYPE _type) {
    // Maybe indexed value storage? E.g., INDI_VS_TYPE_INDEX_0.
    if ((int)_type >= INDI_VS_TYPE_INDEX_FIRST && (int)_type <= INDI_VS_TYPE_INDEX_LAST) {
      return HasValueStorage((int)_type - INDI_VS_TYPE_INDEX_FIRST);
    }
    return false;
  }

  template <typename T>
  T GetValue(int _mode = 0, int _index = 0) {
    T _out;
    GetEntryValue(_mode, _index).Get(_out);
    return _out;
  }

  /**
   * Returns values for a given shift.
   *
   * Note: Remember to check if shift exists by HasValidEntry(shift).
   */
  template <typename T>
  bool GetValues(int _index, T& _out1, T& _out2) {
    IndicatorDataEntry _entry = GetEntry(_index);
    _out1 = _entry.values[0];
    _out2 = _entry.values[1];
    bool _result = GetLastError() != 4401;
    ResetLastError();
    return _result;
  }

  template <typename T>
  bool GetValues(int _index, T& _out1, T& _out2, T& _out3) {
    IndicatorDataEntry _entry = GetEntry(_index);
    _out1 = _entry.values[0];
    _out2 = _entry.values[1];
    _out3 = _entry.values[2];
    bool _result = GetLastError() != 4401;
    ResetLastError();
    return _result;
  }

  template <typename T>
  bool GetValues(int _index, T& _out1, T& _out2, T& _out3, T& _out4) {
    IndicatorDataEntry _entry = GetEntry(_index);
    _out1 = _entry.values[0];
    _out2 = _entry.values[1];
    _out3 = _entry.values[2];
    _out4 = _entry.values[3];
    bool _result = GetLastError() != 4401;
    ResetLastError();
    return _result;
  }

  void Tick() {
    long _current_time = TimeCurrent();

    if (last_tick_time == _current_time) {
      // We've already ticked.
      return;
    }

    last_tick_time = _current_time;

    // Checking and potentially initializing new data source.
    if (HasDataSource(true) != NULL) {
      // Ticking data source if not yet ticked.
      GetDataSource().Tick();
    }

    // Also ticking all used indicators if they've not yet ticked.
    for (DictStructIterator<int, Ref<IndicatorBase>> iter = indicators.Begin(); iter.IsValid(); ++iter) {
      iter.Value().Ptr().Tick();
    }

    // Drawing maybe?
    if (draw.GetEnabled()) {
      for (int i = 0; i < GetModeCount(); ++i) {
        draw.DrawLineTo(GetFullName() + "_" + IntegerToString(i), GetBarTime(0), GetEntry(0)[i]);
      }
    }

    // Overridable OnTick() method.
    OnTick();
  }

  virtual void OnTick() {}

  /* Data representation methods */

  /* Virtual methods */

  /**
   * Returns the indicator's struct value.
   */
  virtual IndicatorDataEntry GetEntry(int _index = 0) {
    Print(GetFullName(),
          " must implement IndicatorDataEntry IndicatorBase::GetEntry(int _shift) in order to use GetEntry(int "
          "_shift) or _indi[int _shift] subscript operator!");
    DebugBreak();
    IndicatorDataEntry _default;
    return _default;
  }

  /**
   * Returns the indicator's struct value.
   */
  virtual IndicatorDataEntry GetEntry(datetime _dt) {
    Print(GetFullName(),
          " must implement IndicatorDataEntry IndicatorBase::GetEntry(datetime _dt) in order to use GetEntry(datetime "
          "_dt) or _indi[datetime _dt] subscript operator!");
    DebugBreak();
    IndicatorDataEntry _default;
    return _default;
  }

  /**
   * Alters indicator's struct value.
   *
   * This method allows user to modify the struct entry before it's added to cache.
   * This method is called on GetEntry() right after values are set.
   */
  virtual void GetEntryAlter(IndicatorDataEntry& _entry) {}

  // virtual ENUM_IDATA_VALUE_RANGE GetIDataValueRange() = NULL;

  /**
   * Returns the indicator's entry value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) = NULL;

  /**
   * Sends entry to listening indicators.
   */
  void EmitEntry(IndicatorDataEntry& entry) {
    for (int i = 0; i < ArraySize(listeners); ++i) {
      if (listeners[i].ObjectExists()) {
        listeners[i].Ptr().OnDataSourceEntry(entry);
      }
    }
  }

  /**
   * Stores entry in the buffer for later rerieval.
   */
  virtual void StoreEntry(IndicatorDataEntry& entry) {}

  /**
   * Sends historic entries to listening indicators. May be overriden.
   */
  virtual void EmitHistory() {}

  /**
   * Called when data source emits new entry (historic or future one).
   */
  virtual void OnDataSourceEntry(IndicatorDataEntry& entry){};

  /**
   * Called when indicator became a data source for other indicator.
   */
  virtual void OnBecomeDataSourceFor(IndicatorBase* _base_indi){};

  /**
   * Called when user tries to set given data source. Could be used to check if indicator implements all required value
   * storages.
   */
  virtual bool OnValidateDataSource(IndicatorBase* _ds, string& _reason) {
    _reason = "Indicator " + GetName() + " does not implement OnValidateDataSource()";
    return false;
  }

  /**
   * Returns indicator value for a given shift and mode.
   */
  // virtual double GetValue(int _shift = 0, int _mode = 0) = NULL;

  /**
   * Checks whether indicator has a valid value for a given shift.
   */
  /*
  virtual bool HasValidEntry(int _index = 0) {
    unsigned int position;
    long bar_time = GetBarTime(_index);
    return bar_time > 0 && idata.KeyExists(bar_time, position) ? idata.GetByPos(position).IsValid() : false;
  }
  */

  /**
   * Returns stored data in human-readable format.
   */
  // virtual bool ToString() = NULL; // @fixme?

  /**
   * Whether we can and have to select mode when specifying data source.
   */
  virtual bool IsDataSourceModeSelectable() { return true; }

  /**
   * Update indicator.
   */
  virtual bool Update() {
    // @todo
    return false;
  };

  /**
   * Returns the indicator's value in plain format.
   */
  virtual string ToString(int _index = 0) {
    IndicatorDataEntry _entry = GetEntry(_index);
    int _serializer_flags = SERIALIZER_FLAG_SKIP_HIDDEN | SERIALIZER_FLAG_INCLUDE_DEFAULT |
                            SERIALIZER_FLAG_INCLUDE_DYNAMIC | SERIALIZER_FLAG_INCLUDE_FEATURE;

    IndicatorDataEntry _stub_entry;
    _stub_entry.AddFlags(_entry.GetFlags());
    SerializerConverter _stub = SerializerConverter::MakeStubObject(_stub_entry, _serializer_flags, _entry.GetSize());
    return SerializerConverter::FromObject(_entry, _serializer_flags).ToString<SerializerCsv>(0, &_stub);
  }

  int GetBarsCalculated() {
    int _bars = Bars(GetSymbol(), GetTf());

    if (!is_fed) {
      // Calculating start_bar.
      for (; calc_start_bar < _bars; ++calc_start_bar) {
        // Iterating from the oldest or previously iterated.
        IndicatorDataEntry _entry = GetEntry(_bars - calc_start_bar - 1);

        if (_entry.IsValid()) {
          // From this point we assume that future entries will be all valid.
          is_fed = true;
          return _bars - calc_start_bar;
        }
      }
    }

    if (!is_fed) {
      Print("Can't find valid bars for ", GetFullName());
      return 0;
    }

    // Assuming all entries are calculated (even if have invalid values).
    return _bars;
  }

  /**
   * Gets indicator's symbol.
   */
  virtual string GetSymbol() { return GetTick() PTR_DEREF GetSymbol(); }

  /**
   * Gets symbol info for active symbol.
   */
  virtual SymbolInfoProp GetSymbolProps() { return GetTick() PTR_DEREF GetSymbolProps(); }

  /**
   * Sets symbol info for symbol attached to the indicator.
   */
  virtual void SetSymbolProps(const SymbolInfoProp& _props) {}

  /**
   * Gets indicator's time-frame.
   */
  virtual ENUM_TIMEFRAMES GetTf() { return GetCandle() PTR_DEREF GetTf(); }

  /* Defines MQL backward compatible methods */

  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, DUMMY);
#endif
  }

  template <typename A>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a);
#endif
  }

  template <typename A, typename B>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b);
#endif
  }

  template <typename A, typename B, typename C>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, int _mode,
                 int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c);
#endif
  }

  template <typename A, typename B, typename C, typename D>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, int _mode,
                 int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e,
                 int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, I _i, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h COMMA _i);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, I _i, J _j, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h COMMA _i COMMA _j);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J, typename K>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, I _i, J _j, K _k, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h COMMA _i COMMA _j COMMA _k);
#endif
  }

  template <typename A, typename B, typename C, typename D, typename E, typename F, typename G, typename H, typename I,
            typename J, typename K, typename L, typename M>
  double iCustom(int& _handle, string _symbol, ENUM_TIMEFRAMES _tf, string _name, A _a, B _b, C _c, D _d, E _e, F _f,
                 G _g, H _h, I _i, J _j, K _k, L _l, M _m, int _mode, int _shift) {
#ifdef __MQL4__
    return ::iCustom(_symbol, _tf, _name, _a, _b, _c, _d, _e, _f, _g, _h, _i, _j, _k, _l, _m, _mode, _shift);
#else  // __MQL5__
    ICUSTOM_DEF(;, COMMA _a COMMA _b COMMA _c COMMA _d COMMA _e COMMA _f COMMA _g COMMA _h COMMA _i COMMA _j COMMA _k
                       COMMA _l COMMA _m);
#endif
  }
};

/**
 * CopyBuffer() method to be used on Indicator instance with ValueStorage buffer.
 *
 * Note that data will be copied so that the oldest element will be located at the start of the physical memory
 * allocated for the array
 */
template <typename T>
int CopyBuffer(IndicatorBase* _indi, int _mode, int _start, int _count, ValueStorage<T>& _buffer, int _rates_total) {
  int _num_copied = 0;
  int _buffer_size = ArraySize(_buffer);

  if (_buffer_size < _rates_total) {
    _buffer_size = ArrayResize(_buffer, _rates_total);
  }

  for (int i = _start; i < _count; ++i) {
    IndicatorDataEntry _entry = _indi.GetEntry(i);

    if (!_entry.IsValid()) {
      break;
    }

    T _value = _entry.GetValue<T>(_mode);

    //    Print(_value);

    _buffer[_buffer_size - i - 1] = _value;
    ++_num_copied;
  }

  return _num_copied;
}

/**
 * BarsCalculated()-compatible method to be used on Indicator instance.
 */
int BarsCalculated(IndicatorBase* _indi) { return _indi.GetBarsCalculated(); }

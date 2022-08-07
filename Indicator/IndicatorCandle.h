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

// Ignore processing of this file if already included.
#ifndef INDICATOR_CANDLE_H
#define INDICATOR_CANDLE_H

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Buffer/BufferCandle.h"
#include "../Candle.struct.h"
#include "../Storage/ValueStorage.price_median.h"
#include "../Storage/ValueStorage.price_typical.h"
#include "../Storage/ValueStorage.price_weighted.h"
#include "../Storage/ValueStorage.spread.h"
#include "../Storage/ValueStorage.tick_volume.h"
#include "../Storage/ValueStorage.time.h"
#include "../Storage/ValueStorage.volume.h"
#include "Indicator.h"
#include "TickBarCounter.h"

// Indicator modes.
enum ENUM_INDI_CANDLE_MODE {
  INDI_CANDLE_MODE_PRICE_OPEN,
  INDI_CANDLE_MODE_PRICE_HIGH,
  INDI_CANDLE_MODE_PRICE_LOW,
  INDI_CANDLE_MODE_PRICE_CLOSE,
  INDI_CANDLE_MODE_SPREAD,
  INDI_CANDLE_MODE_TICK_VOLUME,
  INDI_CANDLE_MODE_TIME,
  INDI_CANDLE_MODE_VOLUME,
  FINAL_INDI_CANDLE_MODE_ENTRY,
  // Following modes are dynamically calculated.
  INDI_CANDLE_MODE_PRICE_MEDIAN,
  INDI_CANDLE_MODE_PRICE_TYPICAL,
  INDI_CANDLE_MODE_PRICE_WEIGHTED,
};

/**
 * Class to deal with candle indicators.
 */
template <typename TS, typename TV>
class IndicatorCandle : public Indicator<TS> {
 protected:
  BufferCandle<TV> icdata;
  TickBarCounter counter;

 protected:
  /* Protected methods */

  /**
   * Initialize class.
   *
   * Called on constructor.
   */
  void Init() {
    // Along with indexing by shift, we can also index via timestamp!
    flags |= INDI_FLAG_INDEXABLE_BY_TIMESTAMP;
    icdata.AddFlags(DICT_FLAG_FILL_HOLES_UNSORTED);
    icdata.SetOverflowListener(IndicatorCandleOverflowListener, 10);
    Set<int>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_MAX_MODES), FINAL_INDI_CANDLE_MODE_ENTRY);
  }

 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  IndicatorCandle(const TS& _icparams, const IndicatorDataParams& _idparams, IndicatorBase* _indi_src = NULL,
                  int _indi_mode = 0)
      : Indicator(_icparams, _idparams, _indi_src, _indi_mode) {
    Init();
  }
  IndicatorCandle(ENUM_INDICATOR_TYPE _itype = INDI_CANDLE, int _shift = 0, string _name = "")
      : Indicator(_itype, _shift, _name) {
    Init();
  }

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override {
    return INDI_SUITABLE_DS_TYPE_TICK | INDI_SUITABLE_DS_TYPE_BASE_ONLY;
  }

  /* Getters */

  /**
   * Gets open price for a given, optional shift.
   */
  double GetOpen(int _shift = 0) override { return GetOHLC(_shift).open; }

  /**
   * Gets high price for a given, optional shift.
   */
  double GetHigh(int _shift = 0) override { return GetOHLC(_shift).high; }

  /**
   * Gets low price for a given, optional shift.
   */
  double GetLow(int _shift = 0) override { return GetOHLC(_shift).low; }

  /**
   * Gets close price for a given, optional shift.
   */
  double GetClose(int _shift = 0) override { return GetOHLC(_shift).close; }

  /**
   * Returns the current price value given applied price type, symbol and timeframe.
   */
  double GetPrice(ENUM_APPLIED_PRICE _ap, int _shift = 0) override { return GetOHLC(_shift).GetAppliedPrice(_ap); }

  /**
   * Returns current bar index (incremented every OnTick() if IsNewBar() is true).
   */
  int GetBarIndex() override { return counter.GetBarIndex(); }

  /**
   * Returns the number of bars on the chart.
   */
  int GetBars() override { return (int)icdata.Size(); }

  /**
   * Returns current tick index (incremented every OnTick()).
   */
  int GetTickIndex() override { return counter.GetTickIndex(); }

  /**
   * Check if there is a new bar to parse.
   */
  bool IsNewBar() override { return counter.is_new_bar; }

  /* Virtual method implementations */

  /**
   * Traverses source indicators' hierarchy and tries to find OHLC-featured
   * indicator. IndicatorCandle satisfies such requirements.
   */
  IndicatorData* GetCandle(bool _warn_if_not_found = true, IndicatorData* _originator = nullptr) override {
    // We are the candle indicator!
    return THIS_PTR;
  }

  /**
   * Gets OHLC price values.
   */
  BarOHLC GetOHLC(int _shift = 0) override {
    datetime _bar_time = GetBarTime(_shift);
    BarOHLC _ohlc;

    if ((long)_bar_time != 0) {
      CandleOCTOHLC<TV> candle = icdata.GetByKey((long)_bar_time);
      _ohlc.open = (float)candle.open;
      _ohlc.high = (float)candle.high;
      _ohlc.low = (float)candle.low;
      _ohlc.close = (float)candle.close;
      _ohlc.time = _bar_time;
    }

#ifdef __debug_verbose__
    Print("Fetching OHLC #", _shift, " from ", TimeToString(_ohlc.time, TIME_DATE | TIME_MINUTES | TIME_SECONDS));
    Print("^- ", _ohlc.open, ", ", _ohlc.high, ", ", _ohlc.low, ", ", _ohlc.close);
#endif

    return _ohlc;
  }

  /**
   * Returns volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  long GetVolume(int _shift = 0) override {
    datetime _bar_time = GetBarTime(_shift);

    if ((long)_bar_time == 0) {
      return 0;
    }

    CandleOCTOHLC<TV> candle = icdata.GetByKey((long)_bar_time);
    return candle.volume;
  }

  /**
   * Returns spread for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  long GetSpread(int _shift = 0) override { return 0; }

  /**
   * Returns tick volume value for the bar.
   *
   * If local history is empty (not loaded), function returns 0.
   */
  long GetTickVolume(int _shift = 0) override { return GetVolume(); }

  /**
   * Returns the indicator's data entry.
   *
   * @see: IndicatorDataEntry.
   *
   * @return
   *   Returns IndicatorDataEntry struct filled with indicator values.
   */
  IndicatorDataEntry GetEntry(long _index = -1) override {
    ResetLastError();
    int _ishift = _index >= 0 ? (int)_index : iparams.GetShift();
    long _candle_time = GetBarTime(_ishift);
    CandleOCTOHLC<TV> _candle;
    _candle = icdata.GetByKey(_candle_time);

    if (!_candle.IsValid()) {
      // No candle found.
      DebugBreak();
      Print(GetFullName(), ": Missing candle at shift ", _index, " (",
            TimeToString(_candle_time, TIME_DATE | TIME_MINUTES | TIME_SECONDS), "). Lowest timestamp in history is ",
            icdata.GetMin());
    }

    return CandleToEntry(_candle_time, _candle);
  }

  /**
   * Returns value storage for a given mode.
   */
  IValueStorage* GetValueStorage(int _mode = 0) override {
    if (_mode >= ArraySize(value_storages)) {
      ArrayResize(value_storages, _mode + 1);
    }

    if (!value_storages[_mode].IsSet()) {
      // Buffer not yet created.
      switch (_mode) {
        case INDI_CANDLE_MODE_PRICE_OPEN:
        case INDI_CANDLE_MODE_PRICE_HIGH:
        case INDI_CANDLE_MODE_PRICE_LOW:
        case INDI_CANDLE_MODE_PRICE_CLOSE:
          value_storages[_mode] = new IndicatorBufferValueStorage<double>(THIS_PTR, _mode);
          break;
        case INDI_CANDLE_MODE_SPREAD:
        case INDI_CANDLE_MODE_TICK_VOLUME:
        case INDI_CANDLE_MODE_VOLUME:
          value_storages[_mode] = new IndicatorBufferValueStorage<long>(THIS_PTR, _mode);
          break;
        case INDI_CANDLE_MODE_TIME:
          value_storages[_mode] = new IndicatorBufferValueStorage<datetime>(THIS_PTR, _mode);
          break;
        case INDI_CANDLE_MODE_PRICE_MEDIAN:
          value_storages[_mode] = new PriceMedianValueStorage(THIS_PTR);
          break;
        case INDI_CANDLE_MODE_PRICE_TYPICAL:
          value_storages[_mode] = new PriceTypicalValueStorage(THIS_PTR);
          break;
        case INDI_CANDLE_MODE_PRICE_WEIGHTED:
          value_storages[_mode] = new PriceWeightedValueStorage(THIS_PTR);
          break;
        default:
          Print("ERROR: Unsupported value storage mode ", _mode);
          DebugBreak();
      }
    }

    return value_storages[_mode].Ptr();
  }

  /**
   * Function should return true if resize can be made, or false to overwrite current slot.
   */
  static bool IndicatorCandleOverflowListener(ENUM_DICT_OVERFLOW_REASON _reason, int _size, int _num_conflicts) {
    switch (_reason) {
      case DICT_OVERFLOW_REASON_FULL:
        // We allow resize if dictionary size is less than 86400 slots.
        return _size < 86400;
      case DICT_OVERFLOW_REASON_TOO_MANY_CONFLICTS:
      default:
        // When there is too many conflicts, we just reject doing resize, so first conflicting slot will be reused.
        break;
    }
    return false;
  }

  /**
   * Sends historic entries to listening indicators. May be overriden.
   */
  void EmitHistory() override {
    for (DictStructIterator<long, CandleOCTOHLC<TV>> iter(icdata.Begin()); iter.IsValid(); ++iter) {
      IndicatorDataEntry _entry = CandleToEntry(iter.Key(), iter.Value());
      EmitEntry(_entry);
    }
  }

  /**
   * Converts candle into indicator's data entry.
   */
  IndicatorDataEntry CandleToEntry(long _timestamp, CandleOCTOHLC<TV>& _candle) {
    IndicatorDataEntry _entry(FINAL_INDI_CANDLE_MODE_ENTRY);
    _entry.timestamp = _timestamp;
    _entry.values[INDI_CANDLE_MODE_PRICE_OPEN] = _candle.open;
    _entry.values[INDI_CANDLE_MODE_PRICE_HIGH] = _candle.high;
    _entry.values[INDI_CANDLE_MODE_PRICE_LOW] = _candle.low;
    _entry.values[INDI_CANDLE_MODE_PRICE_CLOSE] = _candle.close;
    _entry.values[INDI_CANDLE_MODE_SPREAD] = 0.1;  // @todo
    _entry.values[INDI_CANDLE_MODE_TICK_VOLUME] = _candle.volume;
    _entry.values[INDI_CANDLE_MODE_TIME] = _timestamp;
    _entry.values[INDI_CANDLE_MODE_VOLUME] = _candle.volume;

    // @todo We may consider adding these three buffers directly.
    // BarOHLC _ohlc(_candle.open, _candle.high, _candle.low, _candle.close);
    // _entry.values[INDI_CANDLE_MODE_PRICE_MEDIAN] = _ohlc.GetMedian();
    // _entry.values[INDI_CANDLE_MODE_PRICE_TYPICAL] = _ohlc.GetTypical();
    // _entry.values[INDI_CANDLE_MODE_PRICE_WEIGHTED] = _ohlc.GetWeighted();

    _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _candle.IsValid());
    return _entry;
  }

  /**
   * Adds tick's price to the matching candle and updates its OHLC values.
   */
  void UpdateCandle(long _tick_timestamp, double _price) {
    long _candle_timestamp = CalcCandleTimestamp(_tick_timestamp);

#ifdef __debug_verbose__
    Print("Updating candle for ", GetFullName(), " at candle ",
          TimeToString(_candle_timestamp, TIME_DATE | TIME_MINUTES | TIME_SECONDS), " from tick at ",
          TimeToString(_tick_timestamp, TIME_DATE | TIME_MINUTES | TIME_SECONDS), ": ", _price);
#endif

    CandleOCTOHLC<double> _candle(_price, _price, _price, _price, _tick_timestamp, _tick_timestamp);
    if (icdata.KeyExists(_candle_timestamp)) {
      // Candle already exists.
      _candle = icdata.GetByKey(_candle_timestamp);

#ifdef __debug_verbose__
      Print("Candle was ", _candle.ToCSV());
#endif

      _candle.Update(_tick_timestamp, _price);

#ifdef __debug_verbose__
      Print("Candle is  ", _candle.ToCSV());
#endif
    }

    icdata.Add(_candle, _candle_timestamp);
  }

  /**
   * Calculates candle's timestamp from tick's timestamp.
   */
  long CalcCandleTimestamp(long _tick_timestamp) {
    return _tick_timestamp - _tick_timestamp % (iparams.GetSecsPerCandle());
  }

  /**
   * Called when data source emits new entry (historic or future one).
   */
  void OnDataSourceEntry(IndicatorDataEntry& entry) override {
    // Updating candle from bid price.
    UpdateCandle(entry.timestamp, entry[1]);

    // Updating tick & bar indices.
    counter.OnTick(CalcCandleTimestamp(entry.timestamp));
  };

  /**
   * Returns value storage of given kind.
   */
  IValueStorage* GetSpecificValueStorage(ENUM_INDI_VS_TYPE _type) override {
    switch (_type) {
      case INDI_VS_TYPE_PRICE_OPEN:
        return GetValueStorage(INDI_CANDLE_MODE_PRICE_OPEN);
      case INDI_VS_TYPE_PRICE_HIGH:
        return GetValueStorage(INDI_CANDLE_MODE_PRICE_HIGH);
      case INDI_VS_TYPE_PRICE_LOW:
        return GetValueStorage(INDI_CANDLE_MODE_PRICE_LOW);
      case INDI_VS_TYPE_PRICE_CLOSE:
        return GetValueStorage(INDI_CANDLE_MODE_PRICE_CLOSE);
      case INDI_VS_TYPE_PRICE_MEDIAN:
        return GetValueStorage(INDI_CANDLE_MODE_PRICE_MEDIAN);
      case INDI_VS_TYPE_PRICE_TYPICAL:
        return GetValueStorage(INDI_CANDLE_MODE_PRICE_TYPICAL);
      case INDI_VS_TYPE_PRICE_WEIGHTED:
        return GetValueStorage(INDI_CANDLE_MODE_PRICE_WEIGHTED);
      case INDI_VS_TYPE_SPREAD:
        return GetValueStorage(INDI_CANDLE_MODE_SPREAD);
      case INDI_VS_TYPE_TICK_VOLUME:
        return GetValueStorage(INDI_CANDLE_MODE_TICK_VOLUME);
      case INDI_VS_TYPE_TIME:
        return GetValueStorage(INDI_CANDLE_MODE_TIME);
      case INDI_VS_TYPE_VOLUME:
        return GetValueStorage(INDI_CANDLE_MODE_VOLUME);
      default:
        // Trying in parent class.
        return Indicator<TS>::GetSpecificValueStorage(_type);
    }
  }

  /**
   * Checks whether indicator support given value storage type.
   */
  bool HasSpecificValueStorage(ENUM_INDI_VS_TYPE _type) override {
    switch (_type) {
      case INDI_VS_TYPE_PRICE_OPEN:
      case INDI_VS_TYPE_PRICE_HIGH:
      case INDI_VS_TYPE_PRICE_LOW:
      case INDI_VS_TYPE_PRICE_CLOSE:
      case INDI_VS_TYPE_PRICE_MEDIAN:
      case INDI_VS_TYPE_PRICE_TYPICAL:
      case INDI_VS_TYPE_PRICE_WEIGHTED:
      case INDI_VS_TYPE_SPREAD:
      case INDI_VS_TYPE_TICK_VOLUME:
      case INDI_VS_TYPE_TIME:
      case INDI_VS_TYPE_VOLUME:
        return true;
      default:
        // Trying in parent class.
        return Indicator<TS>::HasSpecificValueStorage(_type);
    }
  }

  string CandlesToString() {
    string _result;
    for (DictStructIterator<long, CandleOCTOHLC<TV>> iter(icdata.Begin()); iter.IsValid(); ++iter) {
      IndicatorDataEntry _entry = CandleToEntry(iter.Key(), iter.Value());
      _result += IntegerToString(iter.Key()) + ": " + _entry.ToString<double>() + "\n";
    }
    return _result;
  }

  /* Virtual methods */
};

#endif  // INDICATOR_CANDLE_H

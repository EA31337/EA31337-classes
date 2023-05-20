//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
#include "../Indicator.mqh"

// Indicator modes.
enum ENUM_INDI_CANDLE_MODE {
  INDI_CANDLE_MODE_PRICE_OPEN,
  INDI_CANDLE_MODE_PRICE_HIGH,
  INDI_CANDLE_MODE_PRICE_LOW,
  INDI_CANDLE_MODE_PRICE_CLOSE,
  INDI_CANDLE_MODE_SPREAD,
  INDI_CANDLE_MODE_TICK_VOLUME,
  INDI_CANDLE_MODE_VOLUME,
  FINAL_INDI_CANDLE_MODE_ENTRY,
};

/**
 * Class to deal with candle indicators.
 */
template <typename TS, typename TV>
class IndicatorCandle : public Indicator<TS> {
 protected:
  BufferCandle<TV> icdata;

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
  IndicatorCandle(ENUM_INDICATOR_TYPE _itype = INDI_CANDLE, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0,
                  string _name = "")
      : Indicator(_itype, _tf, _shift, _name) {
    Init();
  }

  /* Virtual method implementations */

  /**
   * Returns the indicator's data entry.
   *
   * @see: IndicatorDataEntry.
   *
   * @return
   *   Returns IndicatorDataEntry struct filled with indicator values.
   */
  IndicatorDataEntry GetEntry(int _index = -1) override {
    ResetLastError();
    unsigned int _ishift = _index >= 0 ? _index : iparams.GetShift();
    long _candle_time = CalcCandleTimestamp(GetBarTime(_ishift));
    long _curr_candle_time;
    CandleOCTOHLC<TV> _candle;

    // Trying current and older shifts.
    if (icdata.Size() > 0) {
      int i = 0;
      while (true) {
        _curr_candle_time = CalcCandleTimestamp(GetBarTime(i++));

        if (_curr_candle_time < icdata.GetMin()) {
          // There is no older entries.
          break;
        }

        _candle = icdata.GetByKey(_curr_candle_time);

        if (_candle.IsValid()) {
          break;
        }
      }
    }

    if (!_candle.IsValid()) {
      // Giving up.
      DebugBreak();
      Print(GetFullName(), ": Missing candle after thorough search at shift ", _index, " (", TimeToString(_candle_time),
            "). Lowest timestamp in history is ", icdata.GetMin());
    }

    return CandleToEntry(_candle_time, _candle);
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
    IndicatorDataEntry _entry(4);
    _entry.timestamp = _timestamp;
    _entry.values[0] = _candle.open;
    _entry.values[1] = _candle.high;
    _entry.values[2] = _candle.low;
    _entry.values[3] = _candle.close;
    _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _candle.IsValid());
    return _entry;
  }

  /**
   * Adds tick's price to the matching candle and updates its OHLC values.
   */
  void UpdateCandle(long _tick_timestamp, double _price) {
    long _candle_timestamp = CalcCandleTimestamp(_tick_timestamp);

#ifdef __debug_verbose__
    Print("Updating candle for ", GetFullName(), " at candle ", TimeToString(_candle_timestamp), " from tick at ",
          TimeToString(_tick_timestamp));
#endif

    CandleOCTOHLC<double> _candle(_price, _price, _price, _price, _tick_timestamp, _tick_timestamp);
    if (icdata.KeyExists(_candle_timestamp)) {
      // Candle already exists.
      _candle = icdata.GetByKey(_candle_timestamp);
      _candle.Update(_tick_timestamp, _price);
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
      case INDI_VS_TYPE_SPREAD:
        return GetValueStorage(INDI_CANDLE_MODE_SPREAD);
      case INDI_VS_TYPE_TICK_VOLUME:
        return GetValueStorage(INDI_CANDLE_MODE_TICK_VOLUME);
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
  bool HasSpecificValueStorage(ENUM_INDI_VS_TYPE _type) {
    switch (_type) {
      case INDI_VS_TYPE_PRICE_OPEN:
      case INDI_VS_TYPE_PRICE_HIGH:
      case INDI_VS_TYPE_PRICE_LOW:
      case INDI_VS_TYPE_PRICE_CLOSE:
      case INDI_VS_TYPE_SPREAD:
      case INDI_VS_TYPE_TICK_VOLUME:
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

#endif

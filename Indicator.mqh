//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                            Copyright 2016, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

// Includes.
#include "Arrays.mqh"
#include "Indicators.mqh"
#include "Log.mqh"
#include "Market.mqh"

// Properties.
#property strict

// Defines.
#define ArrayResizeLeft(_arr, _new_size, _reserve_size) \
  ArraySetAsSeries(_arr, true); \
  if (ArrayResize(_arr, _new_size, _reserve_size) < 0) { return false; } \
  ArraySetAsSeries(_arr, false);

/**
 * Class to deal with indicators.
 */
class Indicator {

protected:

  // Enums.
  enum ENUM_DATA_TYPE { DT_BOOL = 0, DT_DBL = 1, DT_INT = 2 };

  // Structs.
  struct IndicatorParams {
    int handle;            // Indicator handle.
    ENUM_S_INDICATOR type; // Type of indicator.
    // MqlParam params[];     // Indicator parameters.
  };
  struct IndicatorValue {
    datetime dt;
    int key;
    MqlParam value; // Contains value based on the data type (real, integer or string type).
  };

  // Struct variables.
  IndicatorParams params;  // Indicator parameters.
  // Basic variables.
  uint max_buffers;        // Number of buffers to store.
  int arr_keys[];          // Keys.
  datetime _last_bar_time; // Last parsed bar time.

  // Struct variables.
  IndicatorValue data[];

  // Enum variables.
  //bool i_data_type[DT_INTEGERS + 1]; // Type of stored data.

  // Logging.
  Log *logger;
  Market *market;
  Timeframe *tf;

public:

  // Enums.
  enum ENUM_INDICATOR_INDEX {
    // Define indicator constants.
    CURR = 0,
    PREV = 1,
    FAR  = 2,
    FINAL_ENUM_INDICATOR_INDEX // Should be the last one. Used to calculate the number of enum items.
  };


  /**
   * Class constructor.
   */
  void Indicator(IndicatorParams &_params, Timeframe *_tf = NULL, Market *_market = NULL, Log *_log = NULL, uint _max_buffers = FINAL_ENUM_INDICATOR_INDEX) :
      // params(_params),
      tf(_tf != NULL ? _tf : new Timeframe(PERIOD_CURRENT)),
      max_buffers(_max_buffers),
      market(_market != NULL ? _market : new Market(_Symbol)),
      logger(_log != NULL ? _log : new Log(V_ERROR))
  {
    params = _params;
  }

  /**
   * Class deconstructor.
   */
  void ~Indicator() {
    logger.FlushAll();
    delete logger;
    delete market;
    delete tf;
  }

  /**
   * Store a new indicator value.
   */
  bool NewValue(double _value, int _key = 0, datetime _bar_time = NULL, bool _force = false) {
    uint _size = ArraySize(data);
    _bar_time = _bar_time == NULL ? Timeframe::iTime(market.GetSymbol(), tf.GetTf(), 0) : _bar_time;
    uint _shift = tf.iBarShift(tf.GetTf(), _bar_time);
    if (data[0].dt == _bar_time) {
      if (_force) {
        ReplaceValueByShift(_value, _shift, _key);
      }
      return true;
    }
    if (_size <= max_buffers) {
      ArrayResize(data, ++_size, max_buffers);
    } else {
      // Remove one element from the right.
      ArrayResizeLeft(data, _size - 1, _size * max_buffers);
    }
    // Add new element to the left.
    ArrayResizeLeft(data, _size + 1, _size * max_buffers);
    data[_size].key = _key;
    data[_size].value.type = TYPE_DOUBLE;
    data[_size].value.double_value = _value;
    _last_bar_time = fmax(_bar_time, _last_bar_time);
    /*
    // i_data_type[DT_DOUBLES] = true;
    */
    return true;
  }

  /**
   * Get the recent value given the key and index.
   */
  double GetValue(int _key = 0,  uint _shift = 0, double _type = NULL) {
    uint _index = GetIndexByKey(_key, _shift);
    return _index >= 0 ? data[_index].value.double_value : NULL;
  }
  long GetValue(int _key = 0,  uint _shift = 0, long _type = NULL) {
    uint _index = GetIndexByKey(_key, _shift);
    return _index >= 0 ? data[_index].value.integer_value : NULL;
  }
  bool GetValue(int _key = 0,  uint _shift = 0, bool _type = NULL) {
    uint _index = GetIndexByKey(_key, _shift);
    return _index >= 0 ? (bool) data[_index].value.integer_value : NULL;
  }
  string GetValue(int _key = 0,  uint _shift = 0, string _type = NULL) {
    uint _index = GetIndexByKey(_key, _shift);
    return _index >= 0 ? data[_index].value.string_value : NULL;
  }

  /**
   * Get indicator key by index.
   */
  int GetKeyByIndex(uint _index) {
    return data[_index].key;
  }

  /**
   * Get data value by index.
   */
   /*
  bool GetValueByIndex(uint _index, const ENUM_DATATYPE _type = TYPE_BOOL, bool &_value) {
    switch (data[_index].value.type) {
      case TYPE_BOOL:
        return (bool) data[_index].value.integer_value;
      case TYPE_DOUBLE:
        return (double) data[_index].value.double_value;
      case TYPE_INT:
      case TYPE_UINT:
      case TYPE_LONG:
      case TYPE_ULONG:
      case TYPE_DATETIME:
        return (int) data[_index].value.integer_value;
      default:
        return data[_index].value.integer_value;
    }
  }*/
  double GetValueByIndex(uint _index, double &_value, const ENUM_DATATYPE _type = TYPE_DOUBLE) {
    return (double) (_value = data[_index].value.double_value);
  }
  ulong GetValueByIndex(uint _index, ulong &_value, const ENUM_DATATYPE _type = TYPE_ULONG) {
    return (ulong) (_value = data[_index].value.integer_value);
  }
  long GetValueByIndex(uint _index, long &_value, const ENUM_DATATYPE _type = TYPE_LONG) {
    return (long) (_value = data[_index].value.integer_value);
  }
  bool GetValueByIndex(uint _index, bool &_value, const ENUM_DATATYPE _type = TYPE_BOOL) {
    return (bool) (_value = data[_index].value.integer_value);
  }

  /**
   * Replace the value given the key and index.
   */
  bool ReplaceValueByShift(double _val, uint _shift, int _key = 0) {
    datetime _bar_time = tf.iTime(_shift);
    for (int i = 0; i < ArraySize(data); i++) {
      if (data[i].dt == _bar_time && data[i].key == _key) {
        data[i].value.double_value = _val;
        return true;
      }
    }
    return false;
  }

  /**
   * Replace the value given the key and index.
   */
  bool ReplaceValueByDatetime(double _val, datetime _dt, int _key = 0) {
    for (int i = 0; i < ArraySize(data); i++) {
      if (data[i].dt == _dt && data[i].key == _key) {
        data[i].value.double_value = _val;
        return true;
      }
    }
    return false;
  }

  /**
   * Get data array index based on the key and index.
   */
  uint GetIndexByKey(int _key = 0, uint _shift = 0) {
    datetime _bar_time = tf.iTime(_shift);
    for (int i = 0; i < ArraySize(data); i++) {
      if (data[i].dt == _bar_time && data[i].key == _key) {
        return i;
      }
    }
    return -1;
  }

  /**
   * Get time of the last bar which was parsed.
   */
  datetime GetLastBarTime() {
    return _last_bar_time;
  }

  /**
   * Print stored data.
   */
  string ToString(uint _limit = 0) {
    string _out = "";
    for (uint i = 0; i < fmax(ArraySize(data), _limit); i++) {
      // @todo
      // _out += StringFormat("%s:%s; ", GetKeyByIndex(i), GetValueByIndex(i));
    }
    return _out;
  }

  /**
   * Print stored data.
   */
  void PrintData(uint _limit = 0) {
    Print(ToString(_limit));
  }

  /**
   * Update indicator.
   */
  bool Update() {
    return true;
  }

private:

  /**
   * Returns index for given key.
   *
   * If key does not exist, create one.
   */
  uint GetKeyIndex(int _key) {
    for (int i = 0; i < ArraySize(arr_keys); i++) {
      if (arr_keys[i] == _key) {
        return i;
      }
    }
    return AddKey(_key);
  }

  /**
   * Add new data key and return its index.
   */
  uint AddKey(int _key) {
    uint _size = ArraySize(arr_keys);
    ArrayResize(arr_keys, _size + 1, 5);
    arr_keys[_size] = _key;
    return _size;
  }

  /**
   * Checks whether given key exists.
   */
  bool KeyExists(int _key) {
    for (int i = 0; i < ArraySize(arr_keys); i++) {
      if (arr_keys[i] == _key) {
        return true;
      }
    }
    return false;
  }
};
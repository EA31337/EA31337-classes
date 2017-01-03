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
#include "Log.mqh"

// Properties.
#property strict

// Defines.
#define ArrayResizeLeft(_arr, _new_size, _reserve_size) \
  ArraySetAsSeries(_arr, True); \
  if (ArrayResize(_arr, _new_size, _reserve_size) < 0) { return False; } \
  ArraySetAsSeries(_arr, False);

/**
 * Class to deal with indicators.
 */
class Indicator {

protected:

  // Structs.
  struct BValue {
    datetime dt;
    bool val;
  };
  struct DValue {
    datetime dt;
    double val;
  };
  struct IValue {
    datetime dt;
    int val;
  };

  // Enums.
  enum ENUM_DATA_TYPE { DT_BOOLS = 0, DT_DOUBLES = 1, DT_INTEGERS = 2 };

  // Basic variables.
  string i_name;           // Name of the strategy.
  ENUM_TIMEFRAMES i_tf ;   // Timeframe to operate on.
  string i_symbol;         // Symbol pair.
  uint i_max_buffers;      // Number of buffers to store.
  int i_keys[];            // Keys.
  datetime _last_bar_time; // Last parsed bar time.

  // Struct variables.
  BValue data_b[1][1];
  DValue data_d[1][1];
  IValue data_i[1][1];

  // Enum variables.
  bool i_data_type[DT_INTEGERS + 1]; // Type of stored data.

  // Logging.
  Log *logger;

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
  void Indicator(string _name, const ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, uint _max_buffers = FINAL_ENUM_INDICATOR_INDEX, string _symbol = NULL) :
      i_name(_name),
      i_tf(_tf),
      i_max_buffers(_max_buffers),
      i_symbol(_symbol)
  {
    logger = new Log(V_ERROR);
  }

  /**
   * Class deconstructor.
   */
  void ~Indicator() {
    logger.FlushAll();
  }

  /**
   * Store a new indicator value.
   */
  bool NewValue(double _value, int _key = 0, datetime _bar_time = NULL, bool _force = False) {
    uint _size = ArraySize(data_d);
    uint _size2 = ArrayRange(data_d, 1);
    uint _index = GetKeyIndex(_key);
    _bar_time = _bar_time == NULL ? iTime(i_symbol, i_tf, 0) : _bar_time;
    if (data_d[_index][0].dt == _bar_time) {
      if (_force) {
        data_d[_index][0].val = _value;
      }
      return True;
    }
    if (_size > i_max_buffers) {
      ArrayResizeLeft(data_d, _size2 - 1, _size2 * i_max_buffers);
    }
    // Add new element to the left.
    ArrayResizeLeft(data_d, _size2 + 1, _size2 * i_max_buffers);
    data_d[_index][0].dt = _bar_time;
    data_d[_index][0].val = _value;
    _last_bar_time = fmax(_bar_time, _last_bar_time);
    i_data_type[DT_DOUBLES] = True;
    return True;
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
  void PrintData(uint _limit = 0) {
    /*
    if (i_data_type[DT_BOOLS]) {
      // @todo
    }
    if (i_data_type[DT_DOUBLES]) {
      // @todo
    }
    if (i_data_type[DT_INTEGERS]) {
      // @todo
    }
    */
  }
private:

  /**
   * Returns index for given key.
   *
   * If key does not exist, create one.
   */
  uint GetKeyIndex(int _key) {
    for (int i = 0; i < ArraySize(i_keys); i++) {
      if (i_keys[i] == _key) {
        return i;
      }
    }
    return AddKey(_key);
  }

  /**
   * Add new data key and return its index.
   */
  uint AddKey(int _key) {
    uint _size = ArraySize(i_keys);
    ArrayResize(i_keys, _size + 1, 5);
    i_keys[_size] = _key;
    return _size;
  }

  /**
   * Checks whether given key exists.
   */
  bool KeyExists(int _key) {
    for (int i = 0; i < ArraySize(i_keys); i++) {
      if (i_keys[i] == _key) {
        return True;
      }
    }
    return False;
  }
};
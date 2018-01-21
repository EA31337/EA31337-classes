//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2018, 31337 Investments Ltd |
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

// Properties.
#property strict

// Includes.
#include "Array.mqh"
#include "Chart.mqh"
#include "Indicators.mqh"

// Globals enums.
// Define type of indicators.
enum ENUM_S_INDICATOR {
  //S_IND_AC         = 01, // Accelerator Oscillator
  //S_IND_AD         = 02, // Accumulation/Distribution
  //S_IND_ADX        = 03, // Average Directional Index
  //S_IND_ADXW       = 04, // ADX by Welles Wilder
  //S_IND_ALLIGATOR  = 05, // Alligator
  //S_IND_AMA        = 06, // Adaptive Moving Average
  //S_IND_AO         = 07, // Awesome Oscillator
  //S_IND_ATR        = 08, // Average True Range
  //S_IND_BANDS      = 09, // Bollinger Bands
  //S_IND_BEARS      = 10, // Bears Power
  //S_IND_BULLS      = 11, // Bulls Power
  //S_IND_BWMFI      = 12, // Market Facilitation Index
  //S_IND_CCI        = 13, // Commodity Channel Index
  //S_IND_CHAIKIN    = 14, // Chaikin Oscillator
  //S_IND_CUSTOM     = 15, // Custom indicator
  //S_IND_DEMA       = 16, // Double Exponential Moving Average
  //S_IND_DEMARKER   = 17, // DeMarker
  //S_IND_ENVELOPES  = 18, // Envelopes
  //S_IND_FORCE      = 19, // Force Index
  //S_IND_FRACTALS   = 20, // Fractals
  //S_IND_FRAMA      = 21, // Fractal Adaptive Moving Average
  //S_IND_GATOR      = 22, // Gator Oscillator
  //S_IND_ICHIMOKU   = 23, // Ichimoku Kinko Hyo
  S_IND_MA         = 24, // Moving Average
  S_IND_MACD       = 25, // MACD
  //S_IND_MFI        = 26, // Money Flow Index
  //S_IND_MOMENTUM   = 27, // Momentum
  //S_IND_OBV        = 28, // On Balance Volume
  //S_IND_OSMA       = 29, // OsMA
  //S_IND_RSI        = 30, // Relative Strength Index
  //S_IND_RVI        = 31, // Relative Vigor Index
  //S_IND_SAR        = 32, // Parabolic SAR
  //S_IND_STDDEV     = 33, // Standard Deviation
  //S_IND_STOCHASTIC = 34, // Stochastic Oscillator
  //S_IND_TEMA       = 35, // Triple Exponential Moving Average
  //S_IND_TRIX       = 36, // Triple Exponential Moving Averages Oscillator
  //S_IND_VIDYA      = 37, // Variable Index Dynamic Average
  //S_IND_VOLUMES    = 38, // Volumes
  //S_IND_WPR        = 39, // Williams' Percent Range
  S_IND_NONE       = 40  // (None)
};

// Defines.
#define ArrayResizeLeft(_arr, _new_size, _reserve_size) \
  ArraySetAsSeries(_arr, true); \
  if (ArrayResize(_arr, _new_size, _reserve_size) < 0) { return false; } \
  ArraySetAsSeries(_arr, false);

/**
 * Class to deal with indicators.
 */
class Indicator : public Chart {

protected:

  // Enums.
  enum ENUM_DATA_TYPE { DT_BOOL = 0, DT_DBL = 1, DT_INT = 2 };

  // Structs.
  struct IndicatorParams {
    int handle;            // Indicator handle.
    uint max_buffers;       // Max buffers to store.
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
  int arr_keys[];          // Keys.
  datetime _last_bar_time; // Last parsed bar time.

  // Struct variables.
  IndicatorValue data[];

  // Enum variables.
  //bool i_data_type[DT_INTEGERS + 1]; // Type of stored data.

  // Logging.
  // Log *logger;
  // Market *market;

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
   *
   * ENUM_APPLIED_PRICE values:
   *   0: PRICE_CLOSE (Close price)
   *   1: PRICE_OPEN (Open price)
   *   2: PRICE_HIGH (The maximum price for the period)
   *   3: PRICE_LOW (The minimum price for the period)
   *   4: PRICE_MEDIAN (Median price) = (high + low)/2
   *   5: PRICE_TYPICAL (Typical price) = (high + low + close)/3
   *   6: PRICE_WEIGHTED (Average price) = (high + low + close + close)/4
   *
   */

  // Define indicator index.
  enum ENUM_INDICATOR_INDEX {
    CURR = 0,
    PREV = 1,
    FAR  = 2,
    FINAL_ENUM_INDICATOR_INDEX // Should be the last one. Used to calculate the number of enum items.
  };
  // @see: https://docs.mql4.com/constants/indicatorconstants/lines
  // @see: https://www.mql5.com/en/docs/constants/indicatorconstants/lines
  // Indicator line identifiers used in Envelopes and Fractals indicators.
  enum ENUM_LO_UP_LINE {
    LINE_UPPER  = #ifdef __MQL4__ MODE_UPPER #else UPPER_LINE #endif, // Upper line.
    LINE_LOWER  = #ifdef __MQL4__ MODE_LOWER #else LOWER_LINE #endif, // Bottom line.
  };
  // Indicator line identifiers used in Alligator indicator.
  enum ENUM_ALLIGATOR {
    JAW   = #ifdef __MQL4__ MODE_GATORJAW   #else GATORJAW_LINE   #endif, // Jaw line.
    TEETH = #ifdef __MQL4__ MODE_GATORTEETH #else GATORTEETH_LINE #endif, // Teeth line.
    LIPS  = #ifdef __MQL4__ MODE_GATORLIPS  #else GATORLIPS_LINE  #endif, // Lips line.
  };
  // Indicator line identifiers used in ADX indicator.
  enum ENUM_ADX {
    ADX_MAIN    = #ifdef __MQL4__ MODE_MAIN    #else MAIN_LINE    #endif, // Base indicator line.
    ADX_PLUSDI  = #ifdef __MQL4__ MODE_PLUSDI  #else PLUSDI_LINE  #endif, // +DI indicator line.
    ADX_MINUSDI = #ifdef __MQL4__ MODE_MINUSDI #else MINUSDI_LINE #endif, // -DI indicator line.
  };
  // Indicator line identifiers used in Bands.
  enum ENUM_BANDS {
    BANDS_BASE  = #ifdef __MQL4__ MODE_MAIN  #else BASE_LINE  #endif, // Main line.
    BANDS_UPPER = #ifdef __MQL4__ MODE_UPPER #else UPPER_BAND #endif, // Upper limit.
    BANDS_LOWER = #ifdef __MQL4__ MODE_LOWER #else LOWER_BAND #endif, // Lower limit.
  };
  // Indicator line identifiers used in MACD, RVI and Stochastic indicators.
  enum ENUM_SIGNAL_LINE {
    LINE_MAIN   = #ifdef __MQL4__ MODE_MAIN   #else MAIN_LINE   #endif, // Main line.
    LINE_SIGNAL = #ifdef __MQL4__ MODE_SIGNAL #else SIGNAL_LINE #endif, // Signal line.
  };
  #ifdef __MQL4__
    // Ichimoku Kinko Hyo identifiers used in Ichimoku indicator.
    enum ENUM_ICHIMOKU {
      TENKANSEN_LINE   = MODE_TENKANSEN,   // Tenkan-sen.
      KIJUNSEN_LINE    = MODE_KIJUNSEN,    // Kijun-sen.
      SENKOUSPANA_LINE = MODE_SENKOUSPANA, // Senkou Span A.
      SENKOUSPANB_LINE = MODE_SENKOUSPANB, // Senkou Span B.
      CHIKOUSPAN_LINE  = MODE_CHIKOUSPAN,  // Chikou Span.
    };
  #endif

  /**
   * Class constructor.
   */
  void Indicator(IndicatorParams &_params) {
    params = _params;
    params.max_buffers = params.max_buffers > 0 ? params.max_buffers : 5;
    //params.logger = params.logger == NULL ? new Log(V_INFO) : params.logger;
  }

  /**
   * Class deconstructor.
   */
  void ~Indicator() {
  }

  /**
   * Store a new indicator value.
   */
  bool Add(double _value, int _key = 0, datetime _bar_time = NULL, bool _force = false) {
    uint _size = ArraySize(data);
    _bar_time = _bar_time == NULL ? iTime(GetSymbol(), GetTf(), 0) : _bar_time;
    uint _shift = GetBarShift(GetTf(), _bar_time);
    if (data[0].dt == _bar_time) {
      if (_force) {
        ReplaceValueByShift(_value, _shift, _key);
      }
      return true;
    }
    if (_size <= params.max_buffers) {
      ArrayResize(data, ++_size, params.max_buffers);
    } else {
      // Remove one element from the right.
      ArrayResizeLeft(data, _size - 1, _size * params.max_buffers);
    }
    // Add new element to the left.
    ArrayResizeLeft(data, _size + 1, _size * params.max_buffers);
    data[_size].key = _key;
    data[_size].value.type = TYPE_DOUBLE;
    data[_size].value.double_value = _value;
    _last_bar_time = fmax(_bar_time, _last_bar_time);
    return true;
  }

  /**
   * Get the recent value given the key and index.
   */
  double GetValue(uint _shift = 0, int _key = 0, double _type = NULL) {
    uint _index = GetIndexByKey(_key, _shift);
    return _index >= 0 ? data[_index].value.double_value : NULL;
  }
  long GetValue(uint _shift = 0, int _key = 0, long _type = NULL) {
    uint _index = GetIndexByKey(_key, _shift);
    return _index >= 0 ? data[_index].value.integer_value : NULL;
  }
  bool GetValue(uint _shift = 0, int _key = 0, bool _type = NULL) {
    uint _index = GetIndexByKey(_key, _shift);
    return _index >= 0 ? (bool) data[_index].value.integer_value : NULL;
  }
  string GetValue(uint _shift = 0, int _key = 0, string _type = NULL) {
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
    datetime _bar_time = GetBarTime(_shift);
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
    datetime _bar_time = GetBarTime(_shift);
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
   * Get name of the indicator.
   */
  string GetName() {
    return params.type != NULL ? EnumToString(params.type) : "Custom";
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

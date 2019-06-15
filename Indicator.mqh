//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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

// Properties.
#property strict

// Ignore processing of this file if already included.
#ifndef INDICATOR_MQH
#define INDICATOR_MQH

// Forward declaration.
class Chart;

// Includes.
#include "Array.mqh"
#include "Chart.mqh"

// Globals enums.
// Define type of indicators.
enum ENUM_INDICATOR_TYPE {
  INDI_AC         = 01, // Accelerator Oscillator
  INDI_AD         = 02, // Accumulation/Distribution
  INDI_ADX        = 03, // Average Directional Index
  INDI_ADXW       = 04, // ADX by Welles Wilder
  INDI_ALLIGATOR  = 05, // Alligator
  INDI_AMA        = 06, // Adaptive Moving Average
  INDI_AO         = 07, // Awesome Oscillator
  INDI_ATR        = 08, // Average True Range
  INDI_BANDS      = 09, // Bollinger Bands
  INDI_BEARS      = 10, // Bears Power
  INDI_BULLS      = 11, // Bulls Power
  INDI_BWMFI      = 12, // Market Facilitation Index
  INDI_CCI        = 13, // Commodity Channel Index
  INDI_CHAIKIN    = 14, // Chaikin Oscillator
  INDI_CUSTOM     = 15, // Custom indicator
  INDI_DEMA       = 16, // Double Exponential Moving Average
  INDI_DEMARKER   = 17, // DeMarker
  INDI_ENVELOPES  = 18, // Envelopes
  INDI_FORCE      = 19, // Force Index
  INDI_FRACTALS   = 20, // Fractals
  INDI_FRAMA      = 21, // Fractal Adaptive Moving Average
  INDI_GATOR      = 22, // Gator Oscillator
  INDI_ICHIMOKU   = 23, // Ichimoku Kinko Hyo
  INDI_MA         = 24, // Moving Average
  INDI_MACD       = 25, // MACD
  INDI_MFI        = 26, // Money Flow Index
  INDI_MOMENTUM   = 27, // Momentum
  INDI_OBV        = 28, // On Balance Volume
  INDI_OSMA       = 29, // OsMA
  INDI_RSI        = 30, // Relative Strength Index
  INDI_RVI        = 31, // Relative Vigor Index
  INDI_SAR        = 32, // Parabolic SAR
  INDI_STDDEV     = 33, // Standard Deviation
  INDI_STOCHASTIC = 34, // Stochastic Oscillator
  INDI_TEMA       = 35, // Triple Exponential Moving Average
  INDI_TRIX       = 36, // Triple Exponential Moving Averages Oscillator
  INDI_VIDYA      = 37, // Variable Index Dynamic Average
  INDI_VOLUMES    = 38, // Volumes
  INDI_WPR        = 39, // Williams' Percent Range
  INDI_ZIGZAG     = 40, // ZigZag
  INDI_NONE       = 41  // (None)
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
    uint max_buffers;           // Max buffers to store.
    int handle;                // Indicator handle.
    ENUM_INDICATOR_TYPE itype; // Type of indicator.
    ENUM_DATATYPE       dtype; // Value type.
    IndicatorParams() : max_buffers(5) {}
    void SetSize(int _size) {max_buffers = _size;}
  };

  // Struct variables.
  IndicatorParams iparams;  // Indicator parameters.

  // Variables.
  string name;
  MqlParam data[][2];
  datetime dt[][2];
  int index, series, direction;
  ulong total;

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

  /* Common indicator line identifiers */

  // @see: https://docs.mql4.com/constants/indicatorconstants/lines
  // @see: https://www.mql5.com/en/docs/constants/indicatorconstants/lines

  // Indicator line identifiers used in Envelopes and Fractals indicators.
  enum ENUM_LO_UP_LINE {
    LINE_UPPER  = #ifdef __MQL4__ MODE_UPPER #else UPPER_LINE #endif, // Upper line.
    LINE_LOWER  = #ifdef __MQL4__ MODE_LOWER #else LOWER_LINE #endif, // Bottom line.
    FINAL_LO_UP_LINE_ENTRY,
  };

  // Indicator line identifiers used in Gator and Alligator indicators.
  enum ENUM_GATOR_LINE {
    LINE_JAW   = #ifdef __MQL4__ MODE_GATORJAW   #else GATORJAW_LINE   #endif, // Jaw line.
    LINE_TEETH = #ifdef __MQL4__ MODE_GATORTEETH #else GATORTEETH_LINE #endif, // Teeth line.
    LINE_LIPS  = #ifdef __MQL4__ MODE_GATORLIPS  #else GATORLIPS_LINE  #endif, // Lips line.
    FINAL_GATOR_LINE_ENTRY,
  };

  // Indicator line identifiers used in MACD, RVI and Stochastic indicators.
  enum ENUM_SIGNAL_LINE {
    LINE_MAIN   = #ifdef __MQL4__ MODE_MAIN   #else MAIN_LINE   #endif, // Main line.
    LINE_SIGNAL = #ifdef __MQL4__ MODE_SIGNAL #else SIGNAL_LINE #endif, // Signal line.
    FINAL_SIGNAL_LINE_ENTRY,
  };

  #ifdef __MQL4__
  // The volume type is used in calculations.
  // For MT4, we define it for backward compability.
  // @docs: https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
  enum ENUM_APPLIED_VOLUME {
    VOLUME_TICK = 0,
    VOLUME_REAL = 1
  };
  #endif

  /**
   * Class constructor.
   */
  void Indicator(
    const IndicatorParams &_params,
    ENUM_TIMEFRAMES _tf = NULL,
    string _symbol = NULL
    ) :
      total(0),
      direction(1),
      index(-1),
      series(1),
      name(""),
      Chart(_tf, _symbol)
    {
    iparams = _params;
    iparams.max_buffers = fmin(iparams.max_buffers, 1);
    name = name == "" ? EnumToString(iparams.itype) : name;
    SetBufferSize(iparams.max_buffers);
  }
  void Indicator()
    :
    total(0),
    direction(1),
    index(-1),
    series(1)
  {
    iparams.max_buffers = 5;
    SetBufferSize(iparams.max_buffers);
  }

  /* Getters */

  /**
   * Get the recent value given based on the shift.
   */
  MqlParam GetValue(uint _shift = 0) {
    if (IsValidShift(_shift)) {
      uint _index = this.index - _shift * direction;
      uint _series = IsValidIndex(_index) ? this.series : fabs(this.series - 1);
      _index = IsValidIndex(_index) ? _index : _index - _shift * -direction;
      return data[_index][_series];
    }
    else {
      return GetEmpty();
    }
  }

  /**
   * Get datetime of the last value.
   */
  datetime GetTime(uint _index = 0) {
    return dt[_index][series];
  }

  /**
   * Get value type of indicator.
   */
  ENUM_DATATYPE GetType() {
    return iparams.dtype;
  }

  /**
   * Get empty value.
   */
  MqlParam GetEmpty() {
    MqlParam empty;
    empty.integer_value = 0;
    empty.double_value = 0;
    empty.string_value = "";
    return empty;
  }

  /**
   * Get total values added.
   */
  ulong GetTotal() {
    return total;
  }

  /**
   * Set size of the buffer.
   */
  uint GetBufferSize() {
    return iparams.max_buffers;
  }

  /**
   * Get name of the indicator.
   */
  string GetName() {
    return name;
  }

  /* Setters */

  /**
   * Store a new indicator value.
   */
  void AddValue(MqlParam &_entry, datetime _dt = NULL) {
    SetIndex();
    data[this.index][this.series] = _entry;
    dt[this.index][this.series] = _dt;
    total++;
  }

  /**
   * Set index and series for the next value.
   */
  void SetIndex() {
    this.index += 1 * this.direction;
    if (!IsValidIndex(this.index)) {
      this.direction = -this.direction;
      this.index += 1 * this.direction;
      this.series = this.series == 0 ? 1 : 0;
    }
  }

  /**
   * Get index for the given shift.
   */
  uint GetIndex(uint _shift = 0) {
    return this.index - _shift * this.direction;
  }

  /**
   * Set size of the buffer.
   */
  void SetBufferSize(uint _size = 5) {
    ArrayResize(data, iparams.max_buffers);
    ArrayResize(dt,   iparams.max_buffers);
    ArrayInitialize(dt, 0);
  }

  /**
   * Set name of the indicator.
   */
  void SetName(string _name) {
    name = _name;
  }

  /**
   * Print stored data.
   */
  string ToString(uint _limit = 0) {
    string _out = "";
    /*
    for (uint i = 0; i < fmax(ArraySize(idata.data), _limit); i++) {
      // @todo
      // _out += StringFormat("%s:%s; ", GetKeyByIndex(i), GetValueByIndex(i));
    }
    */
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
  virtual bool Update();

private:

  /* State methods */

  /**
   * Check if given index is within valid range.
   */
  bool IsValidIndex(int _index) {
    return _index >= 0 && (uint) _index < iparams.max_buffers;
  }

  /**
   * Check if given shift is within valid range.
   */
  bool IsValidShift(uint _shift) {
    return _shift < iparams.max_buffers && _shift < this.total;
  }

};
#endif

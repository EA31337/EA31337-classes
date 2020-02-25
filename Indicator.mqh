//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
#ifndef INDICATOR_MQH
#define INDICATOR_MQH

// Forward declaration.
class Chart;

// Includes.
#include "Array.mqh"
#include "Chart.mqh"
#include "DateTime.mqh"
#include "Math.mqh"

// Globals enums.
// Define type of indicators.
enum ENUM_INDICATOR_TYPE {
  INDI_AC         =  1, // Accelerator Oscillator
  INDI_AD         =  2, // Accumulation/Distribution
  INDI_ADX        =  3, // Average Directional Index
  INDI_ADXW       =  4, // ADX by Welles Wilder
  INDI_ALLIGATOR  =  5, // Alligator
  INDI_AMA        =  6, // Adaptive Moving Average
  INDI_AO         =  7, // Awesome Oscillator
  INDI_ATR        =  8, // Average True Range
  INDI_BANDS      =  9, // Bollinger Bands
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
  INDI_HEIKENASHI = 23, // Heiken Ashi
  INDI_ICHIMOKU   = 24, // Ichimoku Kinko Hyo
  INDI_MA         = 25, // Moving Average
  INDI_MACD       = 26, // MACD
  INDI_MFI        = 27, // Money Flow Index
  INDI_MOMENTUM   = 28, // Momentum
  INDI_OBV        = 29, // On Balance Volume
  INDI_OSMA       = 30, // OsMA
  INDI_RSI        = 31, // Relative Strength Index
  INDI_RVI        = 32, // Relative Vigor Index
  INDI_SAR        = 33, // Parabolic SAR
  INDI_STDDEV     = 34, // Standard Deviation
  INDI_STOCHASTIC = 35, // Stochastic Oscillator
  INDI_TEMA       = 36, // Triple Exponential Moving Average
  INDI_TRIX       = 37, // Triple Exponential Moving Averages Oscillator
  INDI_VIDYA      = 38, // Variable Index Dynamic Average
  INDI_VOLUMES    = 39, // Volumes
  INDI_WPR        = 40, // Williams' Percent Range
  INDI_ZIGZAG     = 41, // ZigZag
  INDI_NONE       = 42  // (None)
};

// Define indicator index.
enum ENUM_INDICATOR_INDEX {
 CURR = 0,
 PREV = 1,
 FAR  = 2,
 FINAL_ENUM_INDICATOR_INDEX = 3// Should be the last one. Used to calculate the number of enum items.
};

/* Common indicator line identifiers */

// @see: https://docs.mql4.com/constants/indicatorconstants/lines
// @see: https://www.mql5.com/en/docs/constants/indicatorconstants/lines

#ifndef __MQLBUILD__
// Indicator constants.
// @docs
// - https://www.mql5.com/en/docs/constants/indicatorconstants/lines
// Identifiers of indicator lines permissible when copying values of iMACD(), iRVI() and iStochastic().
#define MAIN_LINE   0  // Main line.
#define SIGNAL_LINE 1  // Signal line.
// Identifiers of indicator lines permissible when copying values of ADX() and ADXW().
#define MAIN_LINE    0 // Main line.
#define PLUSDI_LINE  1 // Line +DI.
#define MINUSDI_LINE 2 // Line -DI.
// Identifiers of indicator lines permissible when copying values of iBands().
#define BASE_LINE  0   // Main line.
#define UPPER_BAND 1   // Upper limit.
#define LOWER_BAND 2   // Lower limit.
// Identifiers of indicator lines permissible when copying values of iEnvelopes() and iFractals().
#define UPPER_LINE 0   // Upper line.
#define LOWER_LINE 1   // Bottom line.
// Identifiers of indicator lines permissible when copying values of iGator().
#define UPPER_HISTOGRAM 0 // Upper histogram.
#define LOWER_HISTOGRAM 2 // Bottom histogram.
// Identifiers of indicator lines permissible when copying values of iAlligator().
#define GATORJAW_LINE   0 // Jaw line.
#define GATORTEETH_LINE 1 // Teeth line.
#define GATORLIPS_LINE  2 // Lips line.
// Identifiers of indicator lines permissible when copying values of iIchimoku().
#define TENKANSEN_LINE   0 // Tenkan-sen line.
#define KIJUNSEN_LINE    1 // Kijun-sen line.
#define SENKOUSPANA_LINE 2 // Senkou Span A line.
#define SENKOUSPANB_LINE 3 // Senkou Span B line.
#define CHIKOUSPAN_LINE  4 // Chikou Span line.
#endif

// Indicator line identifiers used in Envelopes and Fractals indicators.
enum ENUM_LO_UP_LINE {
#ifdef __MQL4__
  LINE_UPPER  = MODE_UPPER, // Upper line.
  LINE_LOWER  = MODE_LOWER, // Bottom line.
#else
  LINE_UPPER  = UPPER_LINE, // Upper line.
  LINE_LOWER  = LOWER_LINE, // Bottom line.
#endif
  FINAL_LO_UP_LINE_ENTRY,
};

// Indicator line identifiers used in Gator and Alligator indicators.
enum ENUM_GATOR_LINE {
#ifdef __MQL4__
 LINE_JAW   = MODE_GATORJAW,   // Jaw line.
 LINE_TEETH = MODE_GATORTEETH, // Teeth line.
 LINE_LIPS  = MODE_GATORLIPS,  // Lips line.
#else
 LINE_JAW   = GATORJAW_LINE,   // Jaw line.
 LINE_TEETH = GATORTEETH_LINE, // Teeth line.
 LINE_LIPS  = GATORLIPS_LINE,  // Lips line.
#endif
 FINAL_GATOR_LINE_ENTRY,
};

// Indicator line identifiers used in MACD, RVI and Stochastic indicators.
enum ENUM_SIGNAL_LINE {
#ifdef __MQL4__
 LINE_MAIN   = MODE_MAIN,   // Main line.
 LINE_SIGNAL = MODE_SIGNAL, // Signal line.
#else
 LINE_MAIN   = MAIN_LINE,   // Main line.
 LINE_SIGNAL = SIGNAL_LINE, // Signal line.
#endif
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

// Indicator entry flags.
enum INDICATOR_ENTRY_FLAGS {
  INDI_ENTRY_FLAG_NONE = 0,
  INDI_ENTRY_FLAG_IS_VALID = 1,
  INDI_ENTRY_FLAG_RESERVED1 = 2,
  INDI_ENTRY_FLAG_RESERVED2 = 4,
  INDI_ENTRY_FLAG_RESERVED3 = 8
};

// Defines.
#define ArrayResizeLeft(_arr, _new_size, _reserve_size) \
  ArraySetAsSeries(_arr, true); \
  if (ArrayResize(_arr, _new_size, _reserve_size) < 0) { return false; } \
  ArraySetAsSeries(_arr, false);

// Structs.
struct IndicatorEntry {
  unsigned char flags; // Indicator entry flags.
  long timestamp; // Timestamp of the entry's bar.
  void IndicatorEntry() : flags(INDI_ENTRY_FLAG_NONE), timestamp(0) {}
  bool IsValidFlag() { return bool(flags & INDI_ENTRY_FLAG_IS_VALID); }
  int GetDayOfYear() { return DateTime::TimeDayOfYear(timestamp); }
  int GetMonth() { return DateTime::TimeMonth(timestamp); }
  int GetYear() { return DateTime::TimeYear(timestamp); }
  void AddFlags(unsigned char _flags) { flags |= _flags; }
  void RemoveFlags(unsigned char _flags) { flags &= ~_flags; }
  void SetFlags(unsigned char _flags) { flags = _flags; }
};
struct IndicatorParams : ChartParams {
  string name;               // Name of the indicator.
  unsigned int max_modes;    // Max supported indicator modes (per entry).
  unsigned int max_buffers;  // Max buffers to store.
  ENUM_INDICATOR_TYPE itype; // Type of indicator.
  ENUM_DATATYPE       dtype; // Value type.
  // Constructor.
  IndicatorParams(ENUM_INDICATOR_TYPE _itype = INDI_NONE, ENUM_DATATYPE _dtype = TYPE_DOUBLE, string _name = "")
    : name(_name), itype(_itype), dtype(_dtype) {};
  IndicatorParams(string _name, ENUM_DATATYPE _dtype = TYPE_DOUBLE)
    : name(_name), dtype(_dtype) {};
  // Struct methods.
  void SetDataType(ENUM_DATATYPE _dtype = TYPE_DOUBLE) { dtype = _dtype; }
  void SetIndicator(ENUM_INDICATOR_TYPE _itype) {
    itype = _itype;
  }
  void SetMaxModes(int _max_modes) { max_modes = _max_modes; }
  void SetName(string _name) { name = _name; };
  void SetSize(int _size) { max_buffers = _size; };
};
struct IndicatorState {
  int handle;      // Indicator handle (MQL5 only).
  bool is_changed; // Set when params has been recently changed.
  bool is_ready;   // Set when indicator is ready (has valid values).
  void IndicatorState() : handle(INVALID_HANDLE), is_changed(true), is_ready(false) {}
  int GetHandle() { return handle; }
  bool IsChanged() { return is_changed; }
  bool IsReady() { return is_ready; }
};

#ifndef __MQLBUILD__
//
// Data type identifiers.
// @docs
// - https://www.mql5.com/en/docs/constants/indicatorconstants/enum_datatype
enum ENUM_DATATYPE {
  TYPE_BOOL,
  TYPE_CHAR,
  TYPE_UCHAR,
  TYPE_SHORT,
  TYPE_USHORT,
  TYPE_COLOR,
  TYPE_INT,
  TYPE_UINT,
  TYPE_DATETIME,
  TYPE_LONG,
  TYPE_ULONG,
  TYPE_FLOAT,
  TYPE_DOUBLE,
  TYPE_STRING
}
//
// The structure of input parameters of indicators.
// @docs
// - https://www.mql5.com/en/docs/constants/structures/mqlparam
struct MqlParam {
  ENUM_DATATYPE type;  // Type of the input parameter, value of ENUM_DATATYPE.
  long integer_value;  // Field to store an integer type.
  double double_value; // Field to store a double type.
  string string_value; // Field to store a string type.
};
//
// Empty value in an indicator buffer.
// @docs
// - https://docs.mql4.com/constants/namedconstants/otherconstants
// - https://www.mql5.com/en/docs/constants/namedconstants/otherconstants
#define EMPTY_VALUE DBL_MAX
#endif

/**
 * Class to deal with indicators.
 */
class Indicator : public Chart {

protected:

  // Structs.
  IndicatorParams iparams;
  IndicatorState istate;
  void *mydata;

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

  /**
   * Class constructor.
   */
  Indicator(IndicatorParams &_iparams) : Chart((ChartParams) _iparams)
  {
    iparams = _iparams;
    SetName(_iparams.name != "" ? _iparams.name : EnumToString(iparams.itype));
  }
  Indicator(const IndicatorParams &_iparams, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Chart(_tf)
  {
    iparams = _iparams;
    SetName(_iparams.name != "" ? _iparams.name : EnumToString(iparams.itype));
  }
  Indicator(ENUM_INDICATOR_TYPE _itype, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, string _name = "") : Chart(_tf)
  {
    iparams.SetIndicator(_itype);
    SetName(_name != "" ? _name : EnumToString(iparams.itype));
  }

  /**
   * Class deconstructor.
   */
  ~Indicator() {
  }

  /* Getters */

  /**
   * Get indicator type.
   */
  ENUM_INDICATOR_TYPE GetIndicatorType() {
    return iparams.itype;
  }

  /**
   * Get data type of indicator.
   */
  ENUM_DATATYPE GetDataType() {
    return iparams.dtype;
  }

  /**
   * Get name of the indicator.
   */
  string GetName() {
    return iparams.name;
  }

  /**
   * Get indicator's state.
   */
  IndicatorState GetState() {
    return istate;
  }

  /* Other methods */

  /* Setters */

  /**
   * Sets name of the indicator.
   */
  void SetName(string _name) {
    iparams.SetName(_name);
  }

  /**
   * Sets indicator's handle.
   *
   * Note: Not supported in MT4.
   */
  void SetHandle(int _handle) {
    istate.handle = _handle;
    istate.is_changed = true;
  }

  /* Data representation methods */

  /* Virtual methods */

  /**
   * Returns stored data in human-readable format.
   */
  //virtual bool ToString();

  /**
   * Update indicator.
   */
  virtual bool Update();

  /**
   * Returns the indicator's struct value.
   */
  //virtual IndicatorEntry GetEntry(int _shift = 0);

  /**
   * Returns the indicator's entry value.
   */
  virtual MqlParam GetEntryValue(int _shift = 0, int _mode = 0) = NULL;

  /**
   * Returns the indicator's value in plain format.
   */
  virtual string ToString(int _shift = 0, int _mode = EMPTY) = NULL;

};
#endif

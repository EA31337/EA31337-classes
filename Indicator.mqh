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
#include "BufferStruct.mqh"
#include "Chart.mqh"
#include "DateTime.mqh"
#include "DrawIndicator.mqh"
#include "Math.mqh"

// Define macros.
#define METHOD(method, no) ((method & (1 << no)) == 1 << no)

// Globals enums.
// Defines indicator conditions.
enum ENUM_INDICATOR_CONDITION {
  INDI_COND_ENTRY_IS_MAX = 1, // Indicator entry value is maximum.
  INDI_COND_ENTRY_IS_MIN = 2, // Indicator entry value is minimum.
  INDI_COND_ENTRY_GT_AVG = 3, // Indicator entry value is greater than average.
  INDI_COND_ENTRY_GT_MED = 4, // Indicator entry value is greater than median.
  INDI_COND_ENTRY_LT_AVG = 5, // Indicator entry value is lesser than average.
  INDI_COND_ENTRY_LT_MED = 6, // Indicator entry value is lesser than median.
  FINAL_INDICATOR_CONDITION_ENTRY = 7
};

// Define type of indicators.
enum ENUM_INDICATOR_TYPE {
  INDI_NONE = 0,            // (None)
  INDI_AC,                  // Accelerator Oscillator
  INDI_AD,                  // Accumulation/Distribution
  INDI_ADX,                 // Average Directional Index
  INDI_ADXW,                // ADX by Welles Wilder
  INDI_ALLIGATOR,           // Alligator
  INDI_AMA,                 // Adaptive Moving Average
  INDI_AO,                  // Awesome Oscillator
  INDI_ATR,                 // Average True Range
  INDI_BANDS,               // Bollinger Bands
  INDI_BANDS_ON_PRICE,      // Bollinger Bands (on Price)
  INDI_BEARS,               // Bears Power
  INDI_BULLS,               // Bulls Power
  INDI_BWMFI,               // Market Facilitation Index
  INDI_CCI,                 // Commodity Channel Index
  INDI_CCI_ON_PRICE,        // Commodity Channel Index (CCI) (on Price)
  INDI_CHAIKIN,             // Chaikin Oscillator
  INDI_CUSTOM,              // Custom indicator
  INDI_DEMA,                // Double Exponential Moving Average
  INDI_DEMARKER,            // DeMarker
  INDI_DEMO,                // Demo/Dummy Indicator
  INDI_ENVELOPES,           // Envelopes
  INDI_ENVELOPES_ON_PRICE,  // Evelopes (on Price)
  INDI_FORCE,               // Force Index
  INDI_FRACTALS,            // Fractals
  INDI_FRAMA,               // Fractal Adaptive Moving Average
  INDI_GATOR,               // Gator Oscillator
  INDI_HEIKENASHI,          // Heiken Ashi
  INDI_ICHIMOKU,            // Ichimoku Kinko Hyo
  INDI_MA,                  // Moving Average
  INDI_MACD,                // MACD
  INDI_MA_ON_PRICE,         // Moving Average (on Price).
  INDI_MFI,                 // Money Flow Index
  INDI_MOMENTUM,            // Momentum
  INDI_MOMENTUM_ON_PRICE,   // Momentum (on Price)
  INDI_OBV,                 // On Balance Volume
  INDI_OSMA,                // OsMA
  INDI_PRICE,               // Price Indicator
  INDI_PRICE_FEEDER,        // Indicator which returns prices from custom array
  INDI_RSI,                 // Relative Strength Index
  INDI_RSI_ON_PRICE,        // Relative Strength Index (RSI) (on Price)
  INDI_RVI,                 // Relative Vigor Index
  INDI_SAR,                 // Parabolic SAR
  INDI_STDDEV,              // Standard Deviation
  INDI_STDDEV_ON_MA_SMA,    // Standard Deviation on Moving Average in SMA mode
  INDI_STDDEV_ON_PRICE,     // Standard Deviation (on Price)
  INDI_STDDEV_SMA_ON_PRICE, // Standard Deviation in SMA mode (on Price)
  INDI_STOCHASTIC,          // Stochastic Oscillator
  INDI_TEMA,                // Triple Exponential Moving Average
  INDI_TRIX,                // Triple Exponential Moving Averages Oscillator
  INDI_VIDYA,               // Variable Index Dynamic Average
  INDI_VOLUMES,             // Volumes
  INDI_WPR,                 // Williams' Percent Range
  INDI_ZIGZAG,              // ZigZag
  FINAL_INDICATOR_TYPE_ENTRY
};

// Defines type of source data for indicator.
enum ENUM_IDATA_SOURCE_TYPE {
  IDATA_BUILTIN,   // Use builtin function.
  IDATA_ICUSTOM,   // Use custom indicator file (iCustom).
  IDATA_INDICATOR  // Use indicator class as source of data with custom calculation.
};

// Defines type of value for indicator storage.
enum ENUM_IDATA_VALUE_TYPE { TNONE, TDBL1, TDBL2, TDBL3, TDBL4, TDBL5, TINT1, TINT2, TINT3, TINT4, TINT5 };

// Define indicator index.
enum ENUM_INDICATOR_INDEX {
  CURR = 0,
  PREV = 1,
  PPREV = 2,
  FINAL_ENUM_INDICATOR_INDEX = 3  // Should be the last one. Used to calculate the number of enum items.
};

/* Common indicator line identifiers */

// @see: https://docs.mql4.com/constants/indicatorconstants/lines
// @see: https://www.mql5.com/en/docs/constants/indicatorconstants/lines

#ifndef __MQLBUILD__
// Indicator constants.
// @docs
// - https://www.mql5.com/en/docs/constants/indicatorconstants/lines
// Identifiers of indicator lines permissible when copying values of iMACD(), iRVI() and iStochastic().
#define MAIN_LINE 0    // Main line.
#define SIGNAL_LINE 1  // Signal line.
// Identifiers of indicator lines permissible when copying values of ADX() and ADXW().
#define MAIN_LINE 0     // Main line.
#define PLUSDI_LINE 1   // Line +DI.
#define MINUSDI_LINE 2  // Line -DI.
// Identifiers of indicator lines permissible when copying values of iBands().
#define BASE_LINE 0   // Main line.
#define UPPER_BAND 1  // Upper limit.
#define LOWER_BAND 2  // Lower limit.
// Identifiers of indicator lines permissible when copying values of iEnvelopes() and iFractals().
#define UPPER_LINE 0  // Upper line.
#define LOWER_LINE 1  // Bottom line.
#endif

// Indicator line identifiers used in Envelopes and Fractals indicators.
enum ENUM_LO_UP_LINE {
#ifdef __MQL4__
  LINE_UPPER = MODE_UPPER,  // Upper line.
  LINE_LOWER = MODE_LOWER,  // Bottom line.
#else
  LINE_UPPER = UPPER_LINE,  // Upper line.
  LINE_LOWER = LOWER_LINE,  // Bottom line.
#endif
  FINAL_LO_UP_LINE_ENTRY,
};

// Indicator line identifiers used in MACD, RVI and Stochastic indicators.
enum ENUM_SIGNAL_LINE {
#ifdef __MQL4__
  // @see: https://docs.mql4.com/constants/indicatorconstants/lines
  LINE_MAIN = MODE_MAIN,      // Main line.
  LINE_SIGNAL = MODE_SIGNAL,  // Signal line.
#else
  // @see: https://www.mql5.com/en/docs/constants/indicatorconstants/lines
  LINE_MAIN = MAIN_LINE,      // Main line.
  LINE_SIGNAL = SIGNAL_LINE,  // Signal line.
#endif
  FINAL_SIGNAL_LINE_ENTRY,
};

#ifdef __MQL4__
// The volume type is used in calculations.
// For MT4, we define it for backward compability.
// @docs: https://www.mql5.com/en/docs/constants/indicatorconstants/prices#enum_applied_price_enum
enum ENUM_APPLIED_VOLUME { VOLUME_TICK = 0, VOLUME_REAL = 1 };
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
#define ArrayResizeLeft(_arr, _new_size, _reserve_size)  \
  ArraySetAsSeries(_arr, true);                          \
  if (ArrayResize(_arr, _new_size, _reserve_size) < 0) { \
    return false;                                        \
  }                                                      \
  ArraySetAsSeries(_arr, false);

// Forward declarations.
class DrawIndicator;
class Indicator;

// Structs.
struct IndicatorDataEntry {
  unsigned char flags;  // Indicator entry flags.
  long timestamp;       // Timestamp of the entry's bar.
  union IndicatorDataEntryValue {
    double tdbl, tdbl2[2], tdbl3[3], tdbl4[4], tdbl5[5];
    int tint, tint2[2], tint3[3], tint4[4], tint5[5];
    // Operator overloading methods.
    double operator[](int _index) { return tdbl5[_index]; }
    // Other methods.
    double GetMinDbl(ENUM_IDATA_VALUE_TYPE _idvtype) {
      switch (_idvtype) {
        case TDBL1: return tdbl;
        case TDBL2: return fmin(tdbl2[0], tdbl2[1]);
        case TDBL3: return fmin(fmin(tdbl3[0], tdbl3[1]), tdbl3[2]);
        case TDBL4: return fmin(fmin(fmin(tdbl4[0], tdbl4[1]), tdbl4[2]), tdbl4[3]);
        case TDBL5: return fmin(fmin(fmin(fmin(tdbl5[0], tdbl5[1]), tdbl5[2]), tdbl5[3]), tdbl5[4]);
        case TINT1: return (double) tint;
        case TINT2: return (double) fmin(tint2[0], tint2[1]);
        case TINT3: return (double) fmin(fmin(tint3[0], tint3[1]), tint3[2]);
        case TINT4: return (double) fmin(fmin(fmin(tint4[0], tint4[1]), tint4[2]), tint4[3]);
        case TINT5: return (double) fmin(fmin(fmin(fmin(tint5[0], tint5[1]), tint5[2]), tint5[3]), tint5[4]);
      }
      return DBL_MIN;
    }
    int GetMinInt(ENUM_IDATA_VALUE_TYPE _idvtype) {
      switch (_idvtype) {
        case TDBL1: return (int) tdbl;
        case TDBL2: return (int) fmin(tdbl2[0], tdbl2[1]);
        case TDBL3: return (int) fmin(fmin(tdbl3[0], tdbl3[1]), tdbl3[2]);
        case TDBL4: return (int) fmin(fmin(fmin(tdbl4[0], tdbl4[1]), tdbl4[2]), tdbl4[3]);
        case TDBL5: return (int) fmin(fmin(fmin(fmin(tdbl4[0], tdbl4[1]), tdbl4[2]), tdbl4[3]), tdbl4[4]);
        case TINT1: return tint;
        case TINT2: return fmin(tint2[0], tint2[1]);
        case TINT3: return fmin(fmin(tint3[0], tint3[1]), tint3[2]);
        case TINT4: return fmin(fmin(fmin(tint4[0], tint4[1]), tint4[2]), tint4[3]);
        case TINT5: return fmin(fmin(fmin(fmin(tint4[0], tint4[1]), tint4[2]), tint4[3]), tint4[4]);
      }
      return INT_MIN;
    }
    double GetMaxDbl(ENUM_IDATA_VALUE_TYPE _idvtype) {
      switch (_idvtype) {
        case TDBL1: return tdbl;
        case TDBL2: return fmax(tdbl2[0], tdbl2[1]);
        case TDBL3: return fmax(fmax(tdbl3[0], tdbl3[1]), tdbl3[2]);
        case TDBL4: return fmax(fmax(fmax(tdbl4[0], tdbl4[1]), tdbl4[2]), tdbl4[3]);
        case TDBL5: return fmax(fmax(fmax(fmax(tdbl5[0], tdbl5[1]), tdbl5[2]), tdbl5[3]), tdbl5[4]);
        case TINT1: return (double) tint;
        case TINT2: return (double) fmax(tint2[0], tint2[1]);
        case TINT3: return (double) fmax(fmax(tint3[0], tint3[1]), tint3[2]);
        case TINT4: return (double) fmax(fmax(fmax(tint4[0], tint4[1]), tint4[2]), tint4[3]);
        case TINT5: return (double) fmax(fmax(fmax(fmax(tint5[0], tint5[1]), tint5[2]), tint5[3]), tint5[4]);
      }
      return DBL_MIN;
    }
    int GetMaxInt(ENUM_IDATA_VALUE_TYPE _idvtype) {
      switch (_idvtype) {
        case TDBL1: return (int) tdbl;
        case TDBL2: return (int) fmax(tdbl2[0], tdbl2[1]);
        case TDBL3: return (int) fmax(fmax(tdbl3[0], tdbl3[1]), tdbl3[2]);
        case TDBL4: return (int) fmax(fmax(fmax(tdbl4[0], tdbl4[1]), tdbl4[2]), tdbl4[3]);
        case TDBL5: return (int) fmax(fmax(fmax(fmax(tdbl5[0], tdbl5[1]), tdbl5[2]), tdbl5[3]), tdbl5[4]);
        case TINT1: return tint;
        case TINT2: return fmax(tint2[0], tint2[1]);
        case TINT3: return fmax(fmax(tint3[0], tint3[1]), tint3[2]);
        case TINT4: return fmax(fmax(fmax(tint4[0], tint4[1]), tint4[2]), tint4[3]);
        case TINT5: return fmax(fmax(fmax(fmax(tint5[0], tint5[1]), tint5[2]), tint5[3]), tint5[4]);
      }
      return INT_MIN;
    }
    double GetValueDbl(ENUM_IDATA_VALUE_TYPE _idvtype, int _index = 0) {
      switch (_idvtype) {
        case TDBL1: return tdbl;
        case TDBL2: return tdbl2[_index];
        case TDBL3: return tdbl3[_index];
        case TDBL4: return tdbl4[_index];
        case TDBL5: return tdbl5[_index];
        case TINT1: return (double) tint;
        case TINT2: return (double) tint2[_index];
        case TINT3: return (double) tint3[_index];
        case TINT4: return (double) tint4[_index];
        case TINT5: return (double) tint5[_index];
      }
      return WRONG_VALUE;
    }
    int GetValueInt(ENUM_IDATA_VALUE_TYPE _idvtype, int _index = 0) {
      switch (_idvtype) {
        case TDBL1: return (int) tdbl;
        case TDBL2: return (int) tdbl2[_index];
        case TDBL3: return (int) tdbl3[_index];
        case TDBL4: return (int) tdbl4[_index];
        case TDBL5: return (int) tdbl5[_index];
        case TINT1: return tint;
        case TINT2: return tint2[_index];
        case TINT3: return tint3[_index];
        case TINT4: return tint4[_index];
        case TINT5: return tint5[_index];
      }
      return WRONG_VALUE;
    }
    template <typename VType>
    bool HasValue(ENUM_IDATA_VALUE_TYPE _idvtype, VType _value) {
      switch (_idvtype) {
        case TDBL1: return tdbl == _value;
        case TDBL2: return tdbl2[0] == _value || tdbl2[1] == _value;
        case TDBL3: return tdbl3[0] == _value || tdbl3[1] == _value || tdbl3[2] == _value;
        case TDBL4: return tdbl4[0] == _value || tdbl4[1] == _value || tdbl4[2] == _value || tdbl4[3] == _value;
        case TDBL5: return tdbl5[0] == _value || tdbl5[1] == _value || tdbl5[2] == _value || tdbl5[3] == _value || tdbl5[4] == _value;
        case TINT1: return tint == _value;
        case TINT2: return tint2[0] == _value || tint2[1] == _value;
        case TINT3: return tint3[0] == _value || tint3[1] == _value || tint3[2] == _value;
        case TINT4: return tint4[0] == _value || tint4[1] == _value || tint4[2] == _value || tint4[3] == _value;
        case TINT5: return tint5[0] == _value || tint5[1] == _value || tint5[2] == _value || tint5[3] == _value || tint5[4] == _value;
      }
      return false;
    }
    void SetValue(ENUM_IDATA_VALUE_TYPE _idvtype, double _value, int _index = 0) {
      switch (_idvtype) {
        case TDBL1: tdbl = _value; break;
        case TDBL2: tdbl2[_index] = _value; break;
        case TDBL3: tdbl3[_index] = _value; break;
        case TDBL4: tdbl4[_index] = _value; break;
        case TDBL5: tdbl5[_index] = _value; break;
        case TINT1: tint = (int) _value; break;
        case TINT2: tint2[_index] = (int) _value; break;
        case TINT3: tint3[_index] = (int) _value; break;
        case TINT4: tint4[_index] = (int) _value; break;
        case TINT5: tint5[_index] = (int) _value; break;
      }
    }
    void SetValue(ENUM_IDATA_VALUE_TYPE _idvtype, int _value, int _index = 0) {
      switch (_idvtype) {
        case TDBL1: tdbl = (double) _value; break;
        case TDBL2: tdbl2[_index] = (double) _value; break;
        case TDBL3: tdbl3[_index] = (double) _value; break;
        case TDBL4: tdbl4[_index] = (double) _value; break;
        case TDBL5: tdbl5[_index] = (double) _value; break;
        case TINT1: tint = _value; break;
        case TINT2: tint2[_index] = _value; break;
        case TINT3: tint3[_index] = _value; break;
        case TINT4: tint4[_index] = _value; break;
        case TINT5: tint5[_index] = _value; break;
      }
    }
    string ToString(ENUM_IDATA_VALUE_TYPE _idvtype) {
      switch (_idvtype) {
        case TDBL1: return StringFormat("%g", tdbl);
        case TDBL2: return StringFormat("%g,%g", tdbl2[0], tdbl2[1]);
        case TDBL3: return StringFormat("%g,%g,%g", tdbl3[0], tdbl3[1], tdbl3[2]);
        case TDBL4: return StringFormat("%g,%g,%g,%g", tdbl4[0], tdbl4[1], tdbl4[2], tdbl4[3]);
        case TDBL5: return StringFormat("%g,%g,%g,%g,%g", tdbl5[0], tdbl5[1], tdbl5[2], tdbl5[3], tdbl5[4]);
        case TINT1: return StringFormat("%d", tint);
        case TINT2: return StringFormat("%d,%d", tint2[0], tint2[1]);
        case TINT3: return StringFormat("%d,%d,%g", tint3[0], tint3[1], tint3[2]);
        case TINT4: return StringFormat("%d,%d,%d,%d", tint4[0], tint4[1], tint4[2], tint4[3]);
        case TINT5: return StringFormat("%d,%d,%d,%d,%g", tint5[0], tint5[1], tint5[2], tint5[3], tint5[4]);
      }
      return "n/a";
    }
  } value;
  // Special methods.
  void IndicatorDataEntry() : flags(INDI_ENTRY_FLAG_NONE), timestamp(0) {}
  // Operator overloading methods.
  double operator[](int _index) { return value[_index]; }
  // Other methods.
  bool IsValid() { return bool(flags & INDI_ENTRY_FLAG_IS_VALID); }
  int GetDayOfYear() { return DateTime::TimeDayOfYear(timestamp); }
  int GetMonth() { return DateTime::TimeMonth(timestamp); }
  int GetYear() { return DateTime::TimeYear(timestamp); }
  void AddFlags(unsigned char _flags) { flags |= _flags; }
  void RemoveFlags(unsigned char _flags) { flags &= ~_flags; }
  void SetFlag(INDICATOR_ENTRY_FLAGS _flag, bool _value) { if (_value) AddFlags(_flag); else RemoveFlags(_flag); }
  void SetFlags(unsigned char _flags) { flags = _flags; }
};
struct IndicatorParams : ChartParams {
  string name;                // Name of the indicator.
  unsigned int max_modes;     // Max supported indicator modes (values per entry).
  unsigned int max_buffers;   // Max buffers to store.
  ENUM_INDICATOR_TYPE itype;  // Type of indicator.
  ENUM_IDATA_SOURCE_TYPE idstype; // Indicator data source type.
  ENUM_IDATA_VALUE_TYPE idvtype;  // Indicator data value type.
  ENUM_DATATYPE dtype;        // General type of stored values (DTYPE_DOUBLE, DTYPE_INT).
  Indicator* indi_data;       // Indicator to be used as data source.
  bool indi_data_ownership;   // Whether this indicator should delete given indicator at the end.
  color indi_color;           // Indicator color.
  int indi_mode;              // Index of indicator data to be used as data source.
  bool is_draw;               // Draw active.
  int draw_window;            // Drawing window.
  /* Special methods */
  // Constructor.
  IndicatorParams(ENUM_INDICATOR_TYPE _itype = INDI_NONE, ENUM_IDATA_VALUE_TYPE _idvtype = TDBL1, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, string _name = "")
      : name(_name), max_modes(1), max_buffers(10), idstype(_idstype), itype(_itype), is_draw(false), indi_color(clrNONE), indi_mode(0), indi_data_ownership(true),
      draw_window(0) {
    SetDataValueType(_idvtype);
    SetDataSourceType(_idstype);
  };
  IndicatorParams(string _name, ENUM_IDATA_VALUE_TYPE _idvtype = TDBL1, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN)
    : name(_name), max_modes(1), max_buffers(10), idstype(_idstype), is_draw(false), indi_color(clrNONE), indi_mode(0), indi_data_ownership(true),
      draw_window(0) {
    SetDataValueType(_idvtype);
    SetDataSourceType(_idstype);
  };
  /* Getters */
  color GetIndicatorColor() { return indi_color; }
  int GetMaxModes() { return (int) max_modes; }
  ENUM_IDATA_SOURCE_TYPE GetIDataSourceType() { return idstype; }
  ENUM_IDATA_VALUE_TYPE GetIDataValueType() { return idvtype; }
  /* Setters */
  void SetDataSourceType(ENUM_IDATA_SOURCE_TYPE _idstype) { idstype = _idstype; }
  void SetDataValueType(ENUM_IDATA_VALUE_TYPE _idata_type) {
    idvtype = _idata_type;
    dtype = idvtype >= TINT1 && idvtype <= TINT5 ? TYPE_INT : TYPE_DOUBLE;
  }
  void SetDataValueType(ENUM_DATATYPE _datatype) {
    dtype = _datatype;
    switch (max_modes) {
      case 1: idvtype = _datatype == TYPE_DOUBLE ? TDBL1 : TINT1; break;
      case 2: idvtype = _datatype == TYPE_DOUBLE ? TDBL2 : TINT2; break;
      case 3: idvtype = _datatype == TYPE_DOUBLE ? TDBL3 : TINT3; break;
      case 4: idvtype = _datatype == TYPE_DOUBLE ? TDBL4 : TINT4; break;
      case 5: idvtype = _datatype == TYPE_DOUBLE ? TDBL5 : TINT5; break;
    }
  }
  void SetDraw(bool _draw = true, int _window = 0) { is_draw = _draw; draw_window = _window; }
  void SetDraw(color _clr, int _window = 0) { is_draw = true; indi_color = _clr; draw_window = _window; }
  void SetIndicatorColor(color _clr) { indi_color = _clr; }
  void SetIndicatorData(Indicator *_indi, bool take_ownership = true) { if (indi_data != NULL && indi_data_ownership) { delete indi_data; }; indi_data = _indi; idstype = IDATA_INDICATOR; indi_data_ownership = take_ownership; }
  void SetIndicatorMode(int mode) { indi_mode = mode; }
  int GetIndicatorMode() { return indi_mode; }
  void SetIndicatorType(ENUM_INDICATOR_TYPE _itype) { itype = _itype; }
  void SetMaxModes(int _max_modes) { max_modes = _max_modes; }
  void SetName(string _name) { name = _name; };
  void SetSize(int _size) { max_buffers = _size; };
};
struct IndicatorState {
  int handle;       // Indicator handle (MQL5 only).
  bool is_changed;  // Set when params has been recently changed.
  bool is_ready;    // Set when indicator is ready (has valid values).
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
  ENUM_DATATYPE type;   // Type of the input parameter, value of ENUM_DATATYPE.
  long integer_value;   // Field to store an integer type.
  double double_value;  // Field to store a double type.
  string string_value;  // Field to store a string type.
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
  BufferStruct<IndicatorDataEntry> idata;
  DrawIndicator *draw;
  IndicatorParams iparams;
  IndicatorState istate;
  void *mydata;
  bool is_feeding; // Whether FeedHistoryEntries is already working.


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

  /* Special methods */

  /**
   * Class constructor.
   */
  Indicator(IndicatorParams &_iparams) : Chart((ChartParams)_iparams), draw(NULL), is_feeding(false) {
    iparams = _iparams;
    SetName(_iparams.name != "" ? _iparams.name : EnumToString(iparams.itype));
    InitDraw();
  }
  Indicator(const IndicatorParams &_iparams, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Chart(_tf), draw(NULL), is_feeding(false) {
    iparams = _iparams;
    SetName(_iparams.name != "" ? _iparams.name : EnumToString(iparams.itype));
    InitDraw();
  }
  Indicator(ENUM_INDICATOR_TYPE _itype, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, string _name = "") : Chart(_tf), draw(NULL), is_feeding(false) {
    iparams.SetIndicatorType(_itype);
    SetName(_name != "" ? _name : EnumToString(iparams.itype));
    InitDraw();
  }

  /**
   * Class deconstructor.
   */
  ~Indicator() {
    ReleaseHandle();
    DeinitDraw();
    if (iparams.indi_data != NULL && iparams.indi_data_ownership) {
      delete iparams.indi_data;
    }
  }

  /* Init methods */

  /**
   * Initialize indicator data drawing on custom data.
   */
  bool InitDraw() {
    if (iparams.is_draw && !Object::IsValid(draw)) {
      draw = new DrawIndicator(&this);
      draw.SetColorLine(iparams.indi_color);
    }
    return iparams.is_draw;
  }

  /* Deinit methods */

  /**
   * Deinitialize drawing.
   */
  void DeinitDraw() {
    if (draw) {
      delete draw;
    }
  }

  /* Operator overloading methods */

  /**
   * Access indicator entry data using [] operator.
   */
  IndicatorDataEntry operator[](int _shift) { return GetEntry(_shift); }
  IndicatorDataEntry operator[](ENUM_INDICATOR_INDEX _shift) { return GetEntry(_shift); }
  IndicatorDataEntry operator[](datetime _dt) { return idata[_dt]; }

  /**
   * Returns the lowest value.
   */
  double GetMinDbl(int start_bar, int count = WHOLE_ARRAY) {
    double min = NULL;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value = GetEntry(shift).value.GetMinDbl(iparams.idvtype);
      if (min == NULL || value < min) {
        min = value;
      }
    }

    return min;
  }

  /**
   * Returns the lowest bar's index (shift).
   */
  int GetLowest(int count = WHOLE_ARRAY, int start_bar = 0) {
    int min_idx = -1;
    double min = NULL;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value = GetEntry(shift).value.GetMinDbl(iparams.idvtype);
      if (min == NULL || value < min) {
        min = value;
        min_idx = shift;
      }
    }

    return min_idx;
  }

  /**
   * Returns the highest value.
   */
  double GetMaxDbl(int start_bar = 0, int count = WHOLE_ARRAY) {
    double max = NULL;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value = GetEntry(shift).value.GetMaxDbl(iparams.idvtype);
      if (max == NULL || value > max) {
        max = value;
      }
    }

    return max;
  }

  /**
   * Returns the highest bar's index (shift).
   */
  int GetHighest(int count = WHOLE_ARRAY, int start_bar = 0) {
    int max_idx = -1;
    double max = NULL;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value = GetEntry(shift).value.GetMaxDbl(iparams.idvtype);
      if (max == NULL || value > max) {
        max = value;
        max_idx = shift;
      }
    }

    return max_idx;
  }

  /**
   * Returns average value.
   */
  double GetAvgDbl(int start_bar, ENUM_IDATA_VALUE_TYPE data_type, int count = WHOLE_ARRAY) {
    int num_values = 0;
    double sum = 0;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      double value_min = GetEntry(shift).value.GetMinDbl(iparams.idvtype);
      double value_max = GetEntry(shift).value.GetMaxDbl(iparams.idvtype);

      sum += value_min + value_max;
      num_values += 2;
    }

    return sum / num_values;
  }

  /**
   * Returns median of values.
   */
  double GetMedDbl(int start_bar, int count = WHOLE_ARRAY) {
    double array[];

    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);
    int num_bars = last_bar - start_bar + 1;
    int index = 0;

    ArrayResize(array, num_bars);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      IndicatorDataEntry entry = GetEntry(shift);

      for (int type_size = int(iparams.dtype - TDBL1); type_size <= (int)iparams.dtype; ++type_size)
        array[index++] = entry.value.GetValueDbl(iparams.idvtype, int(type_size - TDBL1));
    }

    ArraySort(array);

    double median;

    int len = ArraySize(array);

    if (len % 2 == 0)
      median = (array[len / 2] + array[(len / 2) - 1]) / 2;
    else
      median = array[len / 2];

    return median;
  }

  /**
   * Returns the lowest value.
   */
  int GetMinInt(int start_bar, int count = WHOLE_ARRAY) {
    int min = NULL;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      int value = GetEntry(shift).value.GetMinInt(iparams.idvtype);
      if (min == NULL || value < min) {
        min = value;
      }
    }

    return min;
  }

  /**
   * Returns the highest value.
   */
  int GetMaxInt(int start_bar, int count = WHOLE_ARRAY) {
    int max = NULL;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      int value = GetEntry(shift).value.GetMaxInt(iparams.idvtype);
      if (max == NULL || value > max) {
        max = value;
      }
    }

    return max;
  }

  /**
   * Returns average value.
   */
  int GetAvgInt(int start_bar, ENUM_IDATA_VALUE_TYPE data_type, int count = WHOLE_ARRAY) {
    int num_values = 0;
    int sum = 0;
    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      int value_min = GetEntry(shift).value.GetMinInt(iparams.idvtype);
      int value_max = GetEntry(shift).value.GetMaxInt(iparams.idvtype);

      sum += value_min + value_max;
      num_values += 2;
    }

    return sum / num_values;
  }

  /**
   * Returns median of values.
   */
  int GetMedInt(int start_bar, int count = WHOLE_ARRAY) {
    int array[];

    int last_bar = count == WHOLE_ARRAY ? (int)(GetBarShift(GetLastBarTime())) : (start_bar + count - 1);
    int num_bars = last_bar - start_bar + 1;
    int index = 0;

    ArrayResize(array, num_bars);

    for (int shift = start_bar; shift <= last_bar; ++shift) {
      IndicatorDataEntry entry = GetEntry(shift);

      for (int type_size = int(iparams.dtype - TINT1); type_size <= (int)iparams.dtype; ++type_size)
        array[index++] = entry.value.GetValueInt(iparams.idvtype, int(type_size - TINT1));
    }

    ArraySort(array);

    int median;

    int len = ArraySize(array);

    if (len % 2 == 0)
      median = (array[len / 2] + array[(len / 2) - 1]) / 2;
    else
      median = array[len / 2];

    return median;
  }

  /* Getters */

  /**
   * Get indicator's params.
   */
  IndicatorParams GetParams() { return iparams; }

  /**
   * Get indicator type.
   */
  ENUM_INDICATOR_TYPE GetIndicatorType() { return iparams.itype; }

  /**
   * Get pointer to data of indicator.
   */
  BufferStruct<IndicatorDataEntry> *GetData() { return GetPointer(idata); }

  /**
   * Get data type of indicator.
   */
  ENUM_DATATYPE GetDataType() { return iparams.dtype; }

  /**
   * Get data type of indicator.
   */
  ENUM_IDATA_VALUE_TYPE GetIDataType() { return iparams.idvtype; }

  /**
   * Get name of the indicator.
   */
  string GetName() { return iparams.name; }

  /**
   * Get indicator's state.
   */
  IndicatorState GetState() { return istate; }

  /* Setters */

  /**
   * Sets name of the indicator.
   */
  void SetName(string _name) { iparams.SetName(_name); }

  /**
   * Sets indicator's handle.
   *
   * Note: Not supported in MT4.
   */
  void SetHandle(int _handle) {
    istate.handle = _handle;
    istate.is_changed = true;
  }

  /* Conditions */

  /**
   * Checks for indicator condition.
   *
   * @param ENUM_INDICATOR_CONDITION _cond
   *   Indicator condition.
   * @param MqlParam[] _args
   *   Condition arguments.
   * @return
   *   Returns true when the condition is met.
   */
  bool Condition(ENUM_INDICATOR_CONDITION _cond, MqlParam &_args[]) {
    switch (_cond) {
      case INDI_COND_ENTRY_IS_MAX:
        // @todo: Add arguments, check if the entry value is max.
        return false;
      case INDI_COND_ENTRY_IS_MIN:
        // @todo: Add arguments, check if the entry value is min.
        return false;
      case INDI_COND_ENTRY_GT_AVG:
        // @todo: Add arguments, check if...
        // Indicator entry value is greater than average.
        return false;
      case INDI_COND_ENTRY_GT_MED:
        // @todo: Add arguments, check if...
        // Indicator entry value is greater than median.
        return false;
      case INDI_COND_ENTRY_LT_AVG:
        // @todo: Add arguments, check if...
        // Indicator entry value is lesser than average.
        return false;
      case INDI_COND_ENTRY_LT_MED:
        // @todo: Add arguments, check if...
        // Indicator entry value is lesser than median.
        return false;
      default:
        logger.Error(StringFormat("Invalid indicator condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }
  bool Condition(ENUM_INDICATOR_CONDITION _cond) {
    MqlParam _args[] = {};
    return Indicator::Condition(_cond, _args);
  }

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
   * Checks whether indicator has a valid value for a given shift.
   */
  virtual bool HasValidEntry(int _shift = 0) {
    unsigned int position;
    long bar_time = GetBarTime(_shift);

    if (idata.KeyExists(bar_time, position)) {
      return idata.GetByPos(position).IsValid();
    }

    return false;
  }

  /**
   * Adds entry to the indicator's buffer. Invalid entry won't be added.
   */
  bool AddEntry(IndicatorDataEntry& entry, int _shift = 0) {
    if (!entry.IsValid())
      return false;

    datetime timestamp = GetBarTime(_shift);
    entry.timestamp = timestamp;
    idata.Add(entry, timestamp);

    return true;
  }

  /**
   * Returns shift at which the last known valid entry exists for a given
   * period (or from the start, when period is not specified).
   */
  bool GetLastValidEntryShift(int& out_shift, int period = 0) {
    out_shift = 0;

    while (true) {
      if ((period != 0 && out_shift >= period) || !HasValidEntry(out_shift + 1))
        return out_shift > 0; // Current shift is always invalid.

      ++out_shift;
    }

    return out_shift > 0;
  }

  /**
   * Returns shift at which the oldest known valid entry exists for a given
   * period (or from the start, when period is not specified).
   */
  bool GetOldestValidEntryShift(int& out_shift, int& out_num_valid, int shift = 0, int period = 0) {
    bool found = false;
    // Counting from previous up to previous - period.
    for (out_shift = shift + 1; out_shift < shift + period + 1; ++out_shift) {
      if (!HasValidEntry(out_shift)) {
        --out_shift;
        out_num_valid = out_shift - shift;
        return found;
      }
      else
        found = true;
    }

    --out_shift;
    out_num_valid = out_shift - shift;
    return found;
  }

  /**
   * Checks whether indicator has valid at least given number of last entries
   * (counting from given shift or 0).
   */
  bool HasAtLeastValidLastEntries(int period, int shift = 0) {
    for (int i = 0; i < period; ++i)
      if (!HasValidEntry(shift + i))
        return false;

    return true;
  }
  
  /**
   *
   */
  void FeedHistoryEntries(int period, int shift = 0) {
    if (is_feeding) {
      // Avoiding forever loop.
      return;
    }
      
    is_feeding = true;
    
    for (int i = shift + period; i > shift; --i) {
      GetEntry(i);
    }
    
    is_feeding = false;
  }

  /**
   * Returns double value for a given shift. Remember to check if shift exists
   * by HasValidEntry(shift).
   */
  double GetValueDouble(int _shift, int _mode = -1) {
    double value = GetEntry(_shift).value.GetValueDbl(iparams.idvtype, _mode != -1 ? _mode : iparams.indi_mode);

    ResetLastError();

    return value;
  }

  /**
   * Returns double values for a given shift. Remember to check if shift exists
   * by HasValidEntry(shift).
   */
  bool GetValueDouble2(int _shift, double& mode1, double& mode2) {
    IndicatorDataEntry entry = GetEntry(_shift);
    mode1 = entry.value.GetValueDbl(iparams.idvtype, 0);
    mode2 = entry.value.GetValueDbl(iparams.idvtype, 1);

    bool success = GetLastError() != 4401;

    ResetLastError();

    return success;
  }

  /**
   * Returns double values for a given shift. Remember to check if shift exists
   * by HasValidEntry(shift).
   */
  bool GetValueDouble3(int _shift, double& mode1, double& mode2, double& mode3) {
    IndicatorDataEntry entry = GetEntry(_shift);
    mode1 = entry.value.GetValueDbl(iparams.idvtype, 0);
    mode2 = entry.value.GetValueDbl(iparams.idvtype, 1);
    mode3 = entry.value.GetValueDbl(iparams.idvtype, 2);

    bool success = GetLastError() != 4401;

    ResetLastError();

    return success;
  }

  /**
   * Returns double values for a given shift. Remember to check if shift exists
   * by HasValidEntry(shift).
   */
  bool GetValueDouble4(int _shift, double& mode1, double& mode2, double& mode3, double& mode4) {
    IndicatorDataEntry entry = GetEntry(_shift);
    mode1 = entry.value.GetValueDbl(iparams.idvtype, 0);
    mode2 = entry.value.GetValueDbl(iparams.idvtype, 1);
    mode3 = entry.value.GetValueDbl(iparams.idvtype, 2);
    mode4 = entry.value.GetValueDbl(iparams.idvtype, 3);

    bool success = GetLastError() != 4401;

    ResetLastError();

    return success;
  }
  
  virtual void OnTick() {
    Chart::OnTick();

    if (iparams.is_draw) {
      //Print("Drawing ", GetName(), iparams.indi_data != NULL ? (" (over " + iparams.indi_data.GetName() + ")") : "");
      for (int i = 0; i < (int)iparams.max_modes; ++i)
        draw.DrawLineTo(GetName() + "_" + IntegerToString(i) + "_" + IntegerToString(iparams.indi_mode), GetBarTime(0), GetValueDouble(0, i), iparams.draw_window);
    }
  }


  /* Data representation methods */

  /* Virtual methods */

  /**
   * Returns stored data in human-readable format.
   */
  // virtual bool ToString() = NULL; // @fixme?

  /**
   * Update indicator.
   */
  virtual bool Update();

  /**
   * Returns the indicator's struct value.
   */
  virtual IndicatorDataEntry GetEntry(int _shift = 0) = NULL;

  /**
   * Returns the indicator's entry value.
   */
  virtual MqlParam GetEntryValue(int _shift = 0, int _mode = 0) = NULL;

  /**
   * Returns the indicator's value in plain format.
   */
  virtual string ToString(int _shift = 0) = NULL;
};
#endif

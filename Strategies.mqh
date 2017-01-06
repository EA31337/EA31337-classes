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
#include "Math.mqh"
#include "Timeframe.mqh"

// Properties.
#property strict

// Include strategies.
#include <EA31337-strategies\MA\MA.mqh>

// Globals enums.
enum ENUM_STRATEGY {
  S_NONE          = 29, // (None)
  // AC         =  0, // AC
  // AD         =  1, // AD
  // ADX        =  2, // ADX
  ALLIGATOR  =  3, // Alligator
  // ATR        =  4, // ATR
  // AWESOME    =  5, // Awesome
  BANDS      =  6, // Bands
  // BBPOWER    =  7, // BBPower
  // BWMFI      =  8, // BWMFI
  // CCI        =  9, // CCI
  DEMARKER   = 10, // DeMarker
  ENVELOPES  = 11, // Envelopes
  // FORCE      = 12, // Force
  FRACTALS   = 13, // Fractals
  // GATOR      = 14, // Gator
  // ICHIMOKU   = 15, // Ichimoku
  MA         = 16, // MA
  MACD       = 17, // MACD
  // MFI        = 18, // MFI
  // MOMENTUM   = 19, // Momentum
  // OBV        = 20, // OBV
  // OSMA       = 21, // OSMA
  RSI        = 22, // RSI
  // RVI        = 23, // RVI
  SAR        = 24, // SAR
  // STDDEV     = 25, // StdDev
  // STOCHASTIC = 26, // Stochastic
  WPR        = 27, // WPR
  // ZIGZAG     = 28, // ZigZag
};

enum ENUM_TRAIL_TYPE { // Define type of trailing types.
  T_NONE               =   0, // None
  T1_FIXED             =   1, // Fixed
  T2_FIXED             =  -1, // Bi-way: Fixed
  T1_OPEN_PREV         =   2, // Previous open
  T2_OPEN_PREV         =  -2, // Bi-way: Previous open
  T1_2_BARS_PEAK       =   3, // 2 bars peak
  T2_2_BARS_PEAK       =  -3, // Bi-way: 2 bars peak
  T1_5_BARS_PEAK       =   4, // 5 bars peak
  T2_5_BARS_PEAK       =  -4, // Bi-way: 5 bars peak
  T1_10_BARS_PEAK      =   5, // 10 bars peak
  T2_10_BARS_PEAK      =  -5, // Bi-way: 10 bars peak
  T1_50_BARS_PEAK      =   6, // 50 bars peak
  T2_50_BARS_PEAK      =  -6, // Bi-way: 50 bars peak
  T1_150_BARS_PEAK     =   7, // 150 bars peak
  T2_150_BARS_PEAK     =  -7, // Bi-way: 150 bars peak
  T1_HALF_200_BARS     =   8, // 200 bars half price
  T2_HALF_200_BARS     =  -8, // Bi-way: 200 bars half price
  T1_HALF_PEAK_OPEN    =   9, // Half price peak
  T2_HALF_PEAK_OPEN    =  -9, // Bi-way: Half price peak
  T1_MA_F_PREV         =  10, // MA Fast Prev
  T2_MA_F_PREV         = -10, // Bi-way: MA Fast Prev
  T1_MA_F_FAR          =  11, // MA Fast Far
  T2_MA_F_FAR          = -11, // Bi-way: MA Fast Far
  T1_MA_F_TRAIL        =  12, // MA Fast+Trail
  T2_MA_F_TRAIL        = -12, // Bi-way: MA Fast+Trail
  T1_MA_F_FAR_TRAIL    =  13, // MA Fast Far+Trail
  T2_MA_F_FAR_TRAIL    = -13, // Bi-way: MA Fast Far+Trail
  T1_MA_M              =  14, // MA Med
  T2_MA_M              = -14, // Bi-way: MA Med
  T1_MA_M_FAR          =  15, // MA Med Far
  T2_MA_M_FAR          = -15, // Bi-way: MA Med Far
  T1_MA_M_LOW          =  16, // MA Med Low
  T2_MA_M_LOW          = -16, // Bi-way: MA Med Low
  T1_MA_M_TRAIL        =  17, // MA Med+Trail
  T2_MA_M_TRAIL        = -17, // Bi-way: MA Med+Trail
  T1_MA_M_FAR_TRAIL    =  18, // MA Med Far+Trail
  T2_MA_M_FAR_TRAIL    = -18, // Bi-way: MA Med Far+Trail
  T1_MA_S              =  19, // MA Slow
  T2_MA_S              = -19, // Bi-way: MA Slow
  T1_MA_S_FAR          =  20, // MA Slow Far
  T2_MA_S_FAR          = -20, // Bi-way: MA Slow Far
  T1_MA_S_TRAIL        =  21, // MA Slow+Trail
  T2_MA_S_TRAIL        = -21, // Bi-way: MA Slow+Trail
  T1_MA_FMS_PEAK       =  22, // MA F+M+S Peak
  T2_MA_FMS_PEAK       = -22, // Bi-way: MA F+M+S Peak
  T1_SAR               =  23, // SAR
  T2_SAR               = -23, // Bi-way: SAR
  T1_SAR_PEAK          =  24, // SAR Peak
  T2_SAR_PEAK          = -24, // Bi-way: SAR Peak
  T1_BANDS             =  25, // Bands
  T2_BANDS             = -25, // Bi-way: Bands
  T1_BANDS_PEAK        =  26, // Bands Peak
  T2_BANDS_PEAK        = -26, // Bi-way: Bands Peak
  T1_ENVELOPES         =  27, // Envelopes
  T2_ENVELOPES         = -27, // Bi-way: Envelopes
};

// User input.
#ifdef __input__ extern #endif string __EA_Strategies_Active__ = "-- Active Strategies per timeframe --"; // >>> ACTIVE STRATEGIES <<<
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M01_Active; // Active strategy for M1
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M02_Active; // Active strategy for M2
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M03_Active; // Active strategy for M3
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M04_Active; // Active strategy for M4
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M05_Active; // Active strategy for M5
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M06_Active; // Active strategy for M6
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M10_Active; // Active strategy for M10
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M12_Active; // Active strategy for M12
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M15_Active; // Active strategy for M15
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M20_Active; // Active strategy for M20
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M30_Active; // Active strategy for M30
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H01_Active; // Active strategy for H1
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H02_Active; // Active strategy for H2
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H03_Active; // Active strategy for H3
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H04_Active; // Active strategy for H4
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H06_Active; // Active strategy for H6
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H08_Active; // Active strategy for H8
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H12_Active; // Active strategy for H12
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_D01_Active; // Active strategy for D1
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_W01_Active; // Active strategy for W1
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_MN1_Active; // Active strategy for MN1
#ifdef __input__ extern #endif string __EA_Strategies_SL__ = "-- Strategies Stop Loss --"; // >>> STOP LOSS <<<
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M01_SL; // Stop Loss for M1 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M02_SL; // Stop Loss for M2 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M03_SL; // Stop Loss for M3 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M04_SL; // Stop Loss for M4 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M05_SL; // Stop Loss for M5 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M06_SL; // Stop Loss for M6 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M10_SL; // Stop Loss for M10 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M12_SL; // Stop Loss for M12 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M15_SL; // Stop Loss for M15 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M20_SL; // Stop Loss for M20 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M30_SL; // Stop Loss for M30 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H01_SL; // Stop Loss for H1 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H02_SL; // Stop Loss for H2 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H03_SL; // Stop Loss for H3 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H04_SL; // Stop Loss for H4 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H06_SL; // Stop Loss for H6 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H08_SL; // Stop Loss for H8 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H12_SL; // Stop Loss for H12 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_D01_SL; // Stop Loss for D1 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_W01_SL; // Stop Loss for W1 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_MN1_SL; // Stop Loss for MN1 strategy
#ifdef __input__ extern #endif string __EA_Strategies_TP__ = "-- Strategies Take Profit --"; // >>> TAKE PROFIT <<<
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M01_TP; // Take Profit for M1 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M02_TP; // Take Profit for M2 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M03_TP; // Take Profit for M3 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M04_TP; // Take Profit for M4 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M05_TP; // Take Profit for M5 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M06_TP; // Take Profit for M6 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M10_TP; // Take Profit for M10 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M12_TP; // Take Profit for M12 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M15_TP; // Take Profit for M15 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M20_TP; // Take Profit for M20 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M30_TP; // Take Profit for M30 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H01_TP; // Take Profit for H1 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H02_TP; // Take Profit for H2 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H03_TP; // Take Profit for H3 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H04_TP; // Take Profit for H4 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H06_TP; // Take Profit for H6 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H08_TP; // Take Profit for H8 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H12_TP; // Take Profit for H12 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_D01_TP; // Take Profit for D1 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_W01_TP; // Take Profit for W1 strategy
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_MN1_TP; // Take Profit for MN1 strategy

/**
 * Class for strategy features.
 */
class Strategies {

protected:

  Strategy *strategy[];

public:

  /**
   * Class constructor.
   */
  void Strategies(ulong _tf_filter = 0, uint _magic_no = 31337) {
    ENUM_STRATEGY sid;
    for (int i_tf = 0; i_tf < ArraySize(arr_tf); i_tf++ ) {
      if (_tf_filter == 0 || _tf_filter % PeriodSeconds(arr_tf[i_tf]) * 60 == 0) {
        sid = GetSidByTf(arr_tf[i_tf]);
        AddStrategy(GetClassBySid(sid, arr_tf[i_tf], _magic_no));
      }
    }
  }

  /**
   * Add a new strategy.
   */
  bool AddStrategy(Strategy *_new_s) {
    uint _size = ArraySize(strategy);
    if (ArrayResize(strategy, _size + 1, FINAL_ENUM_TIMEFRAMES_INDEX) < 0) {
      return false;
    }
    strategy[_size] = _new_s;
    return true;
  }

  /**
   * Disable specific strategy.
   */
  void DisableStrategy(Strategy *_s) {
    _s.Disable();
  }

  /**
   * Get strategy id by timeframe.
   */
  ENUM_STRATEGY GetSidByTf(ENUM_TIMEFRAMES _tf) {
    switch (_tf) {
      case PERIOD_M1:  return Strategy_M01_Active;
      case PERIOD_M2:  return Strategy_M02_Active;
      case PERIOD_M3:  return Strategy_M03_Active;
      case PERIOD_M4:  return Strategy_M04_Active;
      case PERIOD_M5:  return Strategy_M05_Active;
      case PERIOD_M6:  return Strategy_M06_Active;
      case PERIOD_M10: return Strategy_M10_Active;
      case PERIOD_M12: return Strategy_M12_Active;
      case PERIOD_M15: return Strategy_M15_Active;
      case PERIOD_M20: return Strategy_M20_Active;
      case PERIOD_M30: return Strategy_M30_Active;
      case PERIOD_H1:  return Strategy_H01_Active;
      case PERIOD_H2:  return Strategy_H02_Active;
      case PERIOD_H3:  return Strategy_H03_Active;
      case PERIOD_H4:  return Strategy_H04_Active;
      case PERIOD_H6:  return Strategy_H06_Active;
      case PERIOD_H8:  return Strategy_H08_Active;
      case PERIOD_H12: return Strategy_H12_Active;
      case PERIOD_D1:  return Strategy_D01_Active;
      case PERIOD_W1:  return Strategy_W01_Active;
      case PERIOD_MN1: return Strategy_MN1_Active;
      default:         return S_NONE;
    }
  }
  
  Strategy *GetClassBySid(ENUM_STRATEGY _sid, ENUM_TIMEFRAMES _tf, uint _magic_no) {
    switch(_sid) {
      // case AC: S_AC;
      // case AD: S_AD;
      // case ADX: S_ADX;
      //  case ALLIGATOR: return new Alligator();
      // case ATR: S_ATR;
      // case AWESOME: S_AWESOME;
      //  case BANDS: return new Bands();
      // case BBPOWER: S_BBPOWER;
      // case BWMFI: S_BWMFI;
      // case CCI: S_CCI;
      //  case DEMARKER: return new DeMarker();
      //  case ENVELOPES: return new Envelopes();
      // case FORCE: S_FORCE;
      //  case FRACTALS: return new Fractals();
      // case GATOR: S_GATOR;
      // case ICHIMOKU: S_ICHIMOKU;
      case MA: return new S_MA("MA", _tf, _magic_no + _sid);
      //  case MACD: return new MACD();
      // case MFI: S_MFI;
      // case MOMENTUM: S_MOMENTUM;
      // case OBV: S_OBV;
      // case OSMA: S_OSMA;
      //  case RSI: return new RSI();
      // case RVI: S_RVI;
      //  case SAR: return new SAR();
      // case STDDEV: S_STDDEV;
      // case STOCHASTIC: S_STOCHASTIC;
      //  case WPR: return new WPR();
      // case ZIGZAG: S_ZIGZAG;
      case S_NONE:
      default:
        return NULL;
    }
  }
  /*
  bool InitStrategy(ENUM_STRATEGY sid, ENUM_TIMEFRAMES tf) {
  }
  */

};

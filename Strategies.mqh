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

// Includes.
#include "Indicators.mqh"
#include "Log.mqh"
#include "Math.mqh"
#include "Order.mqh"
#include "Chart.mqh"
#include "Strategy.mqh"

// Properties.
#property strict

// Globals enums.
enum ENUM_STRATEGY { // Define list of strategies.
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

/*
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
*/

// User input.
#ifdef __input__ extern #endif string __EA_Strategies_Active__ = "-- Active Strategies per timeframe --"; // >>> ACTIVE STRATEGIES <<<
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M01_Active = S_NONE; // Strategy M01 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M02_Active = S_NONE; // Strategy M02 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M03_Active = S_NONE; // Strategy M03 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M04_Active = S_NONE; // Strategy M04 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M05_Active = S_NONE; // Strategy M05 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M06_Active = S_NONE; // Strategy M06 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M10_Active = S_NONE; // Strategy M10 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M12_Active = S_NONE; // Strategy M12 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M15_Active = S_NONE; // Strategy M15 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M20_Active = S_NONE; // Strategy M20 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_M30_Active = S_NONE; // Strategy M30 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H01_Active = S_NONE; // Strategy H01 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H02_Active = S_NONE; // Strategy H02 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H03_Active = S_NONE; // Strategy H03 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H04_Active = S_NONE; // Strategy H04 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H06_Active = S_NONE; // Strategy H06 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H08_Active = S_NONE; // Strategy H08 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_H12_Active = S_NONE; // Strategy H12 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_D01_Active = S_NONE; // Strategy D01 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_W01_Active = S_NONE; // Strategy W01 - Active
#ifdef __input__ input #endif ENUM_STRATEGY Strategy_MN1_Active = S_NONE; // Strategy MN1 - Active
#ifdef __input__ extern #endif string __EA_Strategies_SL__ = "-- Strategies Stop Loss --"; // >>> STOP LOSS <<<
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M01_SL = S_IND_NONE; // Strategy M01 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M02_SL = S_IND_NONE; // Strategy M02 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M03_SL = S_IND_NONE; // Strategy M03 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M04_SL = S_IND_NONE; // Strategy M04 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M05_SL = S_IND_NONE; // Strategy M05 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M06_SL = S_IND_NONE; // Strategy M06 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M10_SL = S_IND_NONE; // Strategy M10 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M12_SL = S_IND_NONE; // Strategy M12 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M15_SL = S_IND_NONE; // Strategy M15 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M20_SL = S_IND_NONE; // Strategy M20 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M30_SL = S_IND_NONE; // Strategy M30 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H01_SL = S_IND_NONE; // Strategy H01 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H02_SL = S_IND_NONE; // Strategy H02 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H03_SL = S_IND_NONE; // Strategy H03 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H04_SL = S_IND_NONE; // Strategy H04 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H06_SL = S_IND_NONE; // Strategy H06 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H08_SL = S_IND_NONE; // Strategy H08 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H12_SL = S_IND_NONE; // Strategy H12 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_D01_SL = S_IND_NONE; // Strategy D01 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_W01_SL = S_IND_NONE; // Strategy W01 - Stop Loss
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_MN1_SL = S_IND_NONE; // Strategy MN1 - Stop Loss
#ifdef __input__ extern #endif string __EA_Strategies_TP__ = "-- Strategies Take Profit --"; // >>> TAKE PROFIT <<<
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M01_TP = S_IND_NONE; // Strategy M01 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M02_TP = S_IND_NONE; // Strategy M02 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M03_TP = S_IND_NONE; // Strategy M03 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M04_TP = S_IND_NONE; // Strategy M04 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M05_TP = S_IND_NONE; // Strategy M05 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M06_TP = S_IND_NONE; // Strategy M06 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M10_TP = S_IND_NONE; // Strategy M10 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M12_TP = S_IND_NONE; // Strategy M12 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M15_TP = S_IND_NONE; // Strategy M15 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M20_TP = S_IND_NONE; // Strategy M20 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_M30_TP = S_IND_NONE; // Strategy M30 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H01_TP = S_IND_NONE; // Strategy H01 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H02_TP = S_IND_NONE; // Strategy H02 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H03_TP = S_IND_NONE; // Strategy H03 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H04_TP = S_IND_NONE; // Strategy H04 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H06_TP = S_IND_NONE; // Strategy H06 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H08_TP = S_IND_NONE; // Strategy H08 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_H12_TP = S_IND_NONE; // Strategy H12 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_D01_TP = S_IND_NONE; // Strategy D01 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_W01_TP = S_IND_NONE; // Strategy W01 - Take Profit
#ifdef __input__ input #endif ENUM_INDICATOR_TYPE Strategy_MN1_TP = S_IND_NONE; // Strategy MN1 - Take Profit

// Include strategies.
#include <EA31337-strategies\MA\S_MA.mqh>
#include <EA31337-strategies\MACD\S_MACD.mqh>

/**
 * Class for strategy features.
 */
class Strategies : public Trade {

protected:

  // Structs.
  struct StrategiesParams {
    ulong tf_filter;      // Timeframe filter.
    uint magic_no_start;  // Starting magic number.
  };
  // Class variables.
  //Market *market;
  Strategy *strategy[];
  // Struct variables.
  StrategiesParams s_params;

  // Variables.
  datetime suspended_till; // End time of trade suspension.

public:

  /**
   * Class constructor.
   */
  void Strategies(StrategiesParams &_params, TradeParams &_trade_params)
    :
    // market(_market != NULL ? _market : new Market(_Symbol)),
    // logger(_log != NULL ? _log : new Log(V_INFO)),
    Trade(_trade_params),
    suspended_till(0)
  {
    ENUM_STRATEGY sid;
    s_params = _params;
    for (int i_tf = 0; i_tf < ArraySize(arr_tf); i_tf++ ) {
      if (s_params.tf_filter == 0 || s_params.tf_filter % PeriodSeconds(arr_tf[i_tf]) * 60 == 0) {
        sid = GetSidByTf(arr_tf[i_tf]);
        if (sid != S_NONE) {
          StrategyParams _strategy;
          _strategy.enabled = true;
          _strategy.magic_no = s_params.magic_no_start + sid;
          _strategy.weight = 1.0;
          AddStrategy(InitClassBySid(sid, _strategy));
        }
      }
    }
  }

  /**
   * Class deconstructor.
   */
  void ~Strategies() {
    for (int i = 0; i < ArraySize(strategy); i++) {
      delete strategy[i];
    }
  }

  /**
   * Add a new strategy.
   */
  bool Signal(MqlTradeRequest &_trade) {
    double _weight = 0;
    Strategy *_trade_strategy = NULL;
    ENUM_ORDER_TYPE _cmd = NULL;
    if (IsSuspended()) {
      return NULL;
    }
    for (int _sid = 0; _sid < ArraySize(strategy); _sid++) {
      if (strategy[_sid].Signal(ORDER_TYPE_BUY) && strategy[_sid].GetWeight() > _weight) {
        _trade_strategy = strategy[_sid];
        _cmd = ORDER_TYPE_BUY;
        _weight = strategy[_sid].GetWeight();
      }
      else if (strategy[_sid].Signal(ORDER_TYPE_SELL) && strategy[_sid].GetWeight() > _weight) {
        _trade_strategy = strategy[_sid];
        _cmd = ORDER_TYPE_SELL;
        _weight = strategy[_sid].GetWeight();
      }
    }
    return SetTrade(_cmd, _trade_strategy, _trade);
  }

  /**
   * Returns a trade request for the given strategy.
   */
  bool SetTrade(ENUM_ORDER_TYPE _cmd, Strategy *_strategy, MqlTradeRequest &_trade) {
    if (_cmd == NULL || _strategy == NULL) {
      return false;
    }
    _trade.action       = TRADE_ACTION_DEAL;
    _trade.magic        = _strategy.GetMagicNo();
    _trade.symbol       = _strategy.MarketInfo().GetSymbol();
    _trade.volume       = _strategy.GetLotSize() * _strategy.GetLotSizeFactor();
    _trade.price        = _strategy.MarketInfo().GetOpenOffer(_cmd);
    //_request.stoplimit? // StopLimit level of the order.
    _trade.sl           = _strategy.GetSlMethod();
    _trade.tp           = _strategy.GetTpMethod();
    //_request.deviation? // Maximal possible deviation from the requested price.
    _trade.type         = _cmd;
    // _request.type_filling = Order::GetOrderFilling(_request.symbol); // @todo?
    // _request.type_time // Order expiration type.
    _trade.comment     = _strategy.GetOrderComment();
    // _request.expiration;       // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type.
    // _request.position;         // Position ticket.
    // _request.position_by;      // The ticket of an opposite position.
    return (_trade.action == TRADE_ACTION_DEAL);
  }

  /**
   * Add a new strategy.
   */
  bool AddStrategy(Strategy *_new_s) {
    uint _size = ArraySize(strategy);
    if (_new_s != NULL && _new_s.Init()) {
      if (ArrayResize(strategy, _size + 1, FINAL_ENUM_TIMEFRAMES_INDEX) < 0) {
        return false;
      }
      strategy[_size] = _new_s;
      return true;
    }
    else {
      Logger().Error("Cannot add the strategy", _new_s != NULL ? _new_s.GetName() : "None");
      return false;
    }
  }

  /**
   * Disable specific strategy.
   */
  void DisableStrategy(Strategy *_s) {
    _s.Disable();
  }

  /**
   * Suspend trading till the given period.
   */
  void SuspendTrading(datetime _dtime) {
    suspended_till = _dtime;
  }

  /**
   * Check if trading is suspended.
   */
  bool IsSuspended() {
    return suspended_till > TimeCurrent();
  }

  /**
   * Get strategy enum by timeframe.
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

  /**
   * Get take profit indicator enum by timeframe.
   */
  ENUM_INDICATOR_TYPE GetIndicatorTpByTf(ENUM_TIMEFRAMES _tf) {
    switch (_tf) {
      case PERIOD_M1:  return Strategy_M01_TP;
      case PERIOD_M2:  return Strategy_M02_TP;
      case PERIOD_M3:  return Strategy_M03_TP;
      case PERIOD_M4:  return Strategy_M04_TP;
      case PERIOD_M5:  return Strategy_M05_TP;
      case PERIOD_M6:  return Strategy_M06_TP;
      case PERIOD_M10: return Strategy_M10_TP;
      case PERIOD_M12: return Strategy_M12_TP;
      case PERIOD_M15: return Strategy_M15_TP;
      case PERIOD_M20: return Strategy_M20_TP;
      case PERIOD_M30: return Strategy_M30_TP;
      case PERIOD_H1:  return Strategy_H01_TP;
      case PERIOD_H2:  return Strategy_H02_TP;
      case PERIOD_H3:  return Strategy_H03_TP;
      case PERIOD_H4:  return Strategy_H04_TP;
      case PERIOD_H6:  return Strategy_H06_TP;
      case PERIOD_H8:  return Strategy_H08_TP;
      case PERIOD_H12: return Strategy_H12_TP;
      case PERIOD_D1:  return Strategy_D01_TP;
      case PERIOD_W1:  return Strategy_W01_TP;
      case PERIOD_MN1: return Strategy_MN1_TP;
      default:         return S_IND_NONE;
    }
  }

  /**
   * Get stop loss indicator enum by timeframe.
   */
  ENUM_INDICATOR_TYPE GetIndicatorSlByTf(ENUM_TIMEFRAMES _tf) {
    switch (_tf) {
      case PERIOD_M1:  return Strategy_M01_SL;
      case PERIOD_M2:  return Strategy_M02_SL;
      case PERIOD_M3:  return Strategy_M03_SL;
      case PERIOD_M4:  return Strategy_M04_SL;
      case PERIOD_M5:  return Strategy_M05_SL;
      case PERIOD_M6:  return Strategy_M06_SL;
      case PERIOD_M10: return Strategy_M10_SL;
      case PERIOD_M12: return Strategy_M12_SL;
      case PERIOD_M15: return Strategy_M15_SL;
      case PERIOD_M20: return Strategy_M20_SL;
      case PERIOD_M30: return Strategy_M30_SL;
      case PERIOD_H1:  return Strategy_H01_SL;
      case PERIOD_H2:  return Strategy_H02_SL;
      case PERIOD_H3:  return Strategy_H03_SL;
      case PERIOD_H4:  return Strategy_H04_SL;
      case PERIOD_H6:  return Strategy_H06_SL;
      case PERIOD_H8:  return Strategy_H08_SL;
      case PERIOD_H12: return Strategy_H12_SL;
      case PERIOD_D1:  return Strategy_D01_SL;
      case PERIOD_W1:  return Strategy_W01_SL;
      case PERIOD_MN1: return Strategy_MN1_SL;
      default:         return S_IND_NONE;
    }
  }

  Strategy *InitClassBySid(const ENUM_STRATEGY _sid, StrategyParams &_params) {
    Strategy *_res = NULL;
    _params.name = new String(EnumToString(_sid));
    _params.trade = (Trade *) GetPointer(this);
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
      case MA:   _res = (S_MA *) new S_MA(_params);
      case MACD: _res = (S_MACD *) new S_MACD(_params);
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
      /*
      s_enabled(_params.enabled),
      s_suspended(false),
      s_name(_name),
      s_magic_no(_magic_no),
      s_lot_size(_lot_size),
      s_weight(_weight),
      s_spread_limit(_spread_limit),
      s_symbol(_symbol != NULL ? _symbol : _Symbol),
      s_pattern_method(0),
      s_open_level(0.0),
      s_tp_method(0),
      s_sl_method(0),
      s_tp_max(0),
      s_sl_max(0),
      s_lot_factor(GetLotSizeFactor()),
      s_avg_spread(GetCurrSpread()),
      market(new Market(_symbol)),
      logger(new Log(_log_level)),
      timeframe(new Chart(_tf))*/
  }
  /*
  bool InitStrategy(ENUM_STRATEGY sid, ENUM_TIMEFRAMES tf) {
  }
  */

};

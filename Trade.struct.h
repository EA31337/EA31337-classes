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

/**
 * @file
 * Includes Trade's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Forward declarations.
struct TradeStats;

// Includes.
#include "DateTime.mqh"
#include "Trade.enum.h"

/* Structure for trade parameters. */
struct TradeParams {
  float lot_size;        // Default lot size.
  float risk_margin;     // Maximum account margin to risk (in %).
  string order_comment;  // Order comment.
  unsigned int limits_stats[FINAL_ENUM_TRADE_STAT_TYPE][FINAL_ENUM_TRADE_STAT_PERIOD];
  unsigned int slippage;     // Value of the maximum price slippage in points.
  unsigned long magic_no;    // Unique magic number used for the trading.
  unsigned short bars_min;   // Minimum bars to trade.
  ENUM_LOG_LEVEL log_level;  // Log verbosity level.
  // Constructors.
  TradeParams(float _lot_size = 0, float _risk_margin = 1.0, unsigned int _slippage = 50)
      : bars_min(100),
        order_comment(""),
        lot_size(_lot_size),
        magic_no(rand()),
        risk_margin(_risk_margin),
        slippage(_slippage) {
    SetLimits(0);
  }
  TradeParams(unsigned long _magic_no, ENUM_LOG_LEVEL _ll = V_INFO)
      : bars_min(100), lot_size(0), order_comment(""), log_level(_ll), magic_no(_magic_no) {}
  TradeParams(TradeParams &_tparams) { this = _tparams; }
  // Deconstructor.
  ~TradeParams() {}
  // Getters.
  template <typename T>
  T Get(ENUM_TRADE_PARAM _param) {
    switch (_param) {
      case TRADE_PARAM_BARS_MIN:
        return (T)bars_min;
      case TRADE_PARAM_LOT_SIZE:
        return (T)lot_size;
      case TRADE_PARAM_MAGIC_NO:
        return (T)magic_no;
      case TRADE_PARAM_ORDER_COMMENT:
        return (T)order_comment;
      case TRADE_PARAM_RISK_MARGIN:
        return (T)risk_margin;
      case TRADE_PARAM_SLIPPAGE:
        return (T)slippage;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  float GetRiskMargin() { return risk_margin; }
  unsigned int GetLimits(ENUM_TRADE_STAT_TYPE _type, ENUM_TRADE_STAT_PERIOD _period) {
    return limits_stats[(int)_type][(int)_period];
  }
  unsigned short GetBarsMin() { return bars_min; }
  // State checkers.
  bool IsLimitGe(ENUM_TRADE_STAT_TYPE _type, ARRAY_REF(unsigned int, _value)) {
    // Is limit greater or equal than given value for given array of types.
    for (int p = 0; p < FINAL_ENUM_TRADE_STAT_PERIOD; p++) {
      if (_value[p] > 0 && IsLimitGe(_type, (ENUM_TRADE_STAT_PERIOD)p, _value[p])) {
        return true;
      }
    }
    return false;
  }
  bool IsLimitGe(ENUM_TRADE_STAT_TYPE _type, ENUM_TRADE_STAT_PERIOD _period, unsigned int _value) {
    // Is limit greater or equal than given value for given type and period.
#ifdef __debug__
    Print("Checking for trade limit. Limit for type ", EnumToString(_type), " and period ", EnumToString(_period),
          " is ", limits_stats[_type][_period], ". Current trades = ", _value);
#endif
    return limits_stats[(int)_type][(int)_period] > 0 && _value >= limits_stats[(int)_type][(int)_period];
  }
  bool IsLimitGe(TradeStats &_stats) {
    // @todo: Improve code performance.
    for (ENUM_TRADE_STAT_TYPE t = 0; t < FINAL_ENUM_TRADE_STAT_TYPE; t++) {
      for (ENUM_TRADE_STAT_PERIOD p = 0; p < FINAL_ENUM_TRADE_STAT_PERIOD; p++) {
        unsigned int _stat_value = _stats.GetOrderStats(t, p);
        if (_stat_value > 0 && IsLimitGe(t, p, _stat_value)) {
          return true;
        }
      }
    }
    return false;
  }
  // Setters.
  template <typename T>
  void Set(ENUM_TRADE_PARAM _param, T _value) {
    switch (_param) {
      case TRADE_PARAM_BARS_MIN:
        bars_min = (unsigned short)_value;
        return;
      case TRADE_PARAM_LOT_SIZE:
        lot_size = (float)_value;
        return;
      case TRADE_PARAM_MAGIC_NO:
        magic_no = (unsigned long)_value;
        return;
      case TRADE_PARAM_ORDER_COMMENT:
        order_comment = (string)_value;
        return;
      case TRADE_PARAM_RISK_MARGIN:
        risk_margin = (float)_value;
        return;
      case TRADE_PARAM_SLIPPAGE:
        slippage = (unsigned int)_value;
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void Set(ENUM_TRADE_PARAM _enum_param, MqlParam &_mql_param) {
    if (_mql_param.type == TYPE_DOUBLE || _mql_param.type == TYPE_FLOAT) {
      Set(_enum_param, _mql_param.double_value);
    } else {
      Set(_enum_param, _mql_param.integer_value);
    }
  }
  void SetBarsMin(unsigned short _value) { bars_min = _value; }
  void SetLimits(ENUM_TRADE_STAT_TYPE _type, ENUM_TRADE_STAT_PERIOD _period, uint _value = 0) {
    // Set new trading limits for the given type and period.
#ifdef __debug__
    Print("Setting trade limit for type ", EnumToString(_type), " and period ", EnumToString(_period), " to ", _value);
#endif
    limits_stats[(int)_type][(int)_period] = _value;
  }
  void SetLimits(ENUM_TRADE_STAT_PERIOD _period, uint _value = 0) {
    // Set new trading limits for the given period.
    for (int t = 0; t < FINAL_ENUM_TRADE_STAT_TYPE; t++) {
#ifdef __debug__
      Print("Setting trade limit for type ", EnumToString((ENUM_TRADE_STAT_TYPE)t), " and period ",
            EnumToString(_period), " to ", _value);
#endif
      limits_stats[(int)t][(int)_period] = _value;
    }
  }
  void SetLimits(ENUM_TRADE_STAT_TYPE _type, uint _value = 0) {
    // Set new trading limits for the given type.
    for (ENUM_TRADE_STAT_PERIOD p = 0; p < FINAL_ENUM_TRADE_STAT_PERIOD; p++) {
      limits_stats[(int)_type][(int)p] = _value;
    }
  }
  void SetLimits(uint _value = 0) {
    // Set new trading limits for all types and periods.
    // Zero value is for no limits.
    for (ENUM_TRADE_STAT_TYPE t = 0; t < FINAL_ENUM_TRADE_STAT_TYPE; t++) {
      for (ENUM_TRADE_STAT_PERIOD p = 0; p < FINAL_ENUM_TRADE_STAT_PERIOD; p++) {
        limits_stats[(int)t][(int)p] = _value;
      }
    }
  }
  void SetLotSize(float _lot_size) { lot_size = _lot_size; }
  void SetMagicNo(unsigned long _mn) { magic_no = _mn; }
  void SetRiskMargin(float _value) { risk_margin = _value; }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer &_s) {
    _s.Pass(THIS_REF, "lot_size", lot_size);
    _s.Pass(THIS_REF, "magic", magic_no);
    _s.Pass(THIS_REF, "risk_margin", risk_margin);
    _s.Pass(THIS_REF, "slippage", slippage);
    return SerializerNodeObject;
  }
} trade_params_defaults;

/* Structure for trade statistics. */
struct TradeStats {
  DateTime dt[FINAL_ENUM_TRADE_STAT_TYPE][FINAL_ENUM_TRADE_STAT_PERIOD];
  unsigned int order_stats[FINAL_ENUM_TRADE_STAT_TYPE][FINAL_ENUM_TRADE_STAT_PERIOD];
  // Struct constructors.
  TradeStats() { ResetStats(); }
  // Check statistics for new periods
  void Check() {}
  /* Getters */
  // Get order stats for the given type and period.
  unsigned int GetOrderStats(ENUM_TRADE_STAT_TYPE _type, ENUM_TRADE_STAT_PERIOD _period, bool _reset = true) {
#ifdef __debug__
    Print("GetOrderStats: type ", EnumToString(_type), ", period ", EnumToString(_period), ", reset = ", _reset);
#endif
    if (_reset && _period > TRADE_STAT_ALL) {
      unsigned int _periods_started = dt[(int)_type][(int)_period].GetStartedPeriods(true, false);
#ifdef __debug__
      Print("GetOrderStats: _periods_started = ", _periods_started);
#endif
      if (_periods_started >= DATETIME_HOUR) {
        ResetStats(_type, _period, _periods_started);
      }
    }
    return order_stats[(int)_type][(int)_period];
  }
  /* Setters */
  // Add value for the given type and period.
  void Add(ENUM_TRADE_STAT_TYPE _type, int _value = 1) {
    for (int p = 0; p < FINAL_ENUM_TRADE_STAT_PERIOD; p++) {
      order_stats[(int)_type][(int)p] += _value;
    }
  }
  /* Reset stats for the given periods. */
  void ResetStats(ENUM_TRADE_STAT_TYPE _type, ENUM_TRADE_STAT_PERIOD _period, unsigned int _periods) {
    if ((_periods & DATETIME_HOUR) != 0) {
      ResetStats(TRADE_STAT_PER_HOUR);
    }
    if ((_periods & DATETIME_DAY) != 0) {
      ResetStats(TRADE_STAT_PER_DAY);
    }
    if ((_periods & DATETIME_WEEK) != 0) {
      ResetStats(TRADE_STAT_PER_WEEK);
    }
    if ((_periods & DATETIME_MONTH) != 0) {
      ResetStats(TRADE_STAT_PER_MONTH);
    }
    if ((_periods & DATETIME_YEAR) != 0) {
      ResetStats(TRADE_STAT_PER_YEAR);
    }
  }
  /* Reset stats for the given type and period. */
  void ResetStats(ENUM_TRADE_STAT_TYPE _type, ENUM_TRADE_STAT_PERIOD _period) {
    order_stats[(int)_type][(int)_period] = 0;
  }
  /* Reset stats for the given period. */
  void ResetStats(ENUM_TRADE_STAT_PERIOD _period) {
    for (ENUM_TRADE_STAT_TYPE t = 0; t < FINAL_ENUM_TRADE_STAT_TYPE; t++) {
      order_stats[(int)t][(int)_period] = 0;
#ifdef __debug__
      Print("Resetting trade counter for type ", EnumToString(t), " and  period ", EnumToString(_period));
#endif
      dt[(int)t][(int)_period].GetStartedPeriods(true, true);
    }
  }
  /* Reset stats for the given type. */
  void ResetStats(ENUM_TRADE_STAT_TYPE _type) {
    for (ENUM_TRADE_STAT_PERIOD p = 0; p < FINAL_ENUM_TRADE_STAT_PERIOD; p++) {
      order_stats[(int)_type][(int)p] = 0;
#ifdef __debug__
      Print("Resetting trade counter for type ", EnumToString(_type), " and  period ", EnumToString(p));
#endif
      dt[(int)_type][(int)p].GetStartedPeriods(true, true);
    }
  }
  /* Reset all stats. */
  void ResetStats() {
    for (ENUM_TRADE_STAT_TYPE t = 0; t < FINAL_ENUM_TRADE_STAT_TYPE; t++) {
      for (ENUM_TRADE_STAT_PERIOD p = 0; p < FINAL_ENUM_TRADE_STAT_PERIOD; p++) {
        order_stats[(int)t][(int)p] = 0;
#ifdef __debug__
        Print("Resetting trade counter for type ", EnumToString(t), " and  period ", EnumToString(p));
#endif
        dt[(int)t][(int)p].GetStartedPeriods(true, true);
      }
    }
  }
};

/* Structure for trade states. */
struct TradeStates {
 protected:
  datetime last_check;
  unsigned int states;

 protected:
  // Protected methods.
  void UpdateCheck() {
    // Refresh timestamp for the last access.
    last_check = TimeCurrent();
  }

 public:
  // Struct constructor.
  TradeStates() : last_check(0), states(0) {}
  // Getters.
  bool Get(ENUM_TRADE_STATE _prop) { return CheckState(_prop); }
  int GetLastCheckDiff() { return (int)(TimeCurrent() - last_check); }
  static string GetStateMessage(ENUM_TRADE_STATE _state) {
    switch (_state) {
      case TRADE_STATE_BARS_NOT_ENOUGH:
        return "Not enough bars to trade";
      case TRADE_STATE_HEDGE_NOT_ALLOWED:
        return "Hedging not allowed by broker";
      case TRADE_STATE_MARGIN_MAX_HARD:
        return "Hard limit of trade margin reached";
      case TRADE_STATE_MARGIN_MAX_SOFT:
        return "Soft limit of trade margin reached";
      case TRADE_STATE_MARKET_CLOSED:
        return "Trade market closed";
      case TRADE_STATE_MONEY_NOT_ENOUGH:
        return "Not enough money to trade";
      case TRADE_STATE_ORDERS_ACTIVE:
        return "New orders has been placed";
      case TRADE_STATE_ORDERS_MAX_HARD:
        return "Soft limit of maximum orders reached";
      case TRADE_STATE_ORDERS_MAX_SOFT:
        return "Hard limit of maximum orders reached";
      case TRADE_STATE_PERIOD_LIMIT_REACHED:
        return "Per period limit reached";
      case TRADE_STATE_SPREAD_TOO_HIGH:
        return "Spread too high";
      case TRADE_STATE_TRADE_NOT_ALLOWED:
        return "Trade not allowed";
      case TRADE_STATE_TRADE_NOT_POSSIBLE:
        return "Trade not possible";
      case TRADE_STATE_TRADE_TERMINAL_BUSY:
        return "Terminal context busy";
      case TRADE_STATE_TRADE_TERMINAL_OFFLINE:
        return "Terminal offline";
      case TRADE_STATE_TRADE_TERMINAL_SHUTDOWN:
        return "Terminal is shutting down";
    }
    return "Unknown!";
  }
  unsigned int GetStates() {
    UpdateCheck();
    return states;
  }
  // Struct methods for bitwise operations.
  bool CheckState(unsigned int _states) { return (states & _states) != 0 || states == _states; }
  bool CheckStatesAll(unsigned int _states) { return (states & _states) == _states; }
  static bool CheckState(unsigned int _states1, unsigned int _states2) {
    return (_states2 & _states1) != 0 || _states2 == _states1;
  }
  void AddState(unsigned int _states) { states |= _states; }
  void RemoveState(unsigned int _states) { states &= ~_states; }
  void SetState(ENUM_TRADE_STATE _state, bool _value = true) {
    if (_value) {
      AddState(_state);
    } else {
      RemoveState(_state);
    }
  }
  void SetState(unsigned int _states) { states = _states; }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer &_s) {
    int _size = sizeof(int) * 8;
    for (int i = 0; i < _size; i++) {
      int _value = CheckState(1 << i) ? 1 : 0;
      _s.Pass(THIS_REF, (string)(i + 1), _value, SERIALIZER_FIELD_FLAG_DYNAMIC);
    }
    return SerializerNodeObject;
  }
};

// Structure for trade static methods.
struct TradeStatic {
  /**
   * Returns the number of active orders/positions.
   *
   * @docs
   * - https://docs.mql4.com/trading/orderstotal
   * - https://www.mql5.com/en/docs/trading/positionstotal
   *
   */
  static int TotalActive() {
#ifdef __MQL4__
    return ::OrdersTotal();
#else
    return ::PositionsTotal();
#endif
  }
};

// Structure for trade history static methods.
struct TradeHistoryStatic {
  /**
   * Returns the number of closed orders in the account history loaded into the terminal.
   */
  static int HistoryOrdersTotal() {
#ifdef __MQL4__
    return ::OrdersHistoryTotal();
#else
    ::HistorySelect(0, ::TimeCurrent());  // @todo: Use DateTimeStatic().
    return ::HistoryOrdersTotal();
#endif
  }
};

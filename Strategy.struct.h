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
 * Includes Strategy's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Serializer/Serializer.h"
#include "Strategy.enum.h"
#include "Strategy.struct.pricestop.h"
#include "Task/Task.struct.h"

// Forward class declaration.
class Strategy;
class Trade;

/* Structure for strategy parameters. */
struct StgParams {
  // Strategy config parameters.
  bool is_enabled;                 // State of the strategy (whether enabled or not).
  bool is_suspended;               // State of the strategy (whether suspended or not)
  bool is_boosted;                 // State of the boost feature (to increase lot size).
  float weight;                    // Weight of the strategy.
  long order_close_time;           // Order close time in mins (>0) or bars (<0).
  float order_close_loss;          // Order close loss (in pips).
  float order_close_profit;        // Order close profit (in pips).
  int signal_open_method;          // Signal open method.
  float signal_open_level;         // Signal open level.
  int signal_open_filter_method;   // Signal open filter method.
  int signal_open_filter_time;     // Signal open filter time.
  int signal_open_boost;           // Signal open boost method (for lot size increase).
  int signal_close_method;         // Signal close method.
  float signal_close_level;        // Signal close level.
  int signal_close_filter_method;  // Signal close filter method.
  int signal_close_filter_time;    // Signal close filter method.
  int price_profit_method;         // Price profit method.
  float price_profit_level;        // Price profit level.
  int price_stop_method;           // Price stop method.
  float price_stop_level;          // Price stop level.
  int tick_filter_method;          // Tick filter.
  float trend_threshold;           // Trend strength threshold.
  float lot_size;                  // Lot size to trade.
  float lot_size_factor;           // Lot size multiplier factor.
  float max_risk;                  // Maximum risk to take (1.0 = normal, 2.0 = 2x).
  float max_spread;                // Maximum spread to trade (in pips).
  int tp_max;                      // Hard limit on maximum take profit (in pips).
  int sl_max;                      // Hard limit on maximum stop loss (in pips).
  int type;                        // Strategy type (@see: ENUM_STRATEGY).
  long id;                         // Unique identifier of the strategy.
  datetime refresh_time;           // Order refresh frequency (in sec).
  short shift;                     // Shift (relative to the current bar, 0 - default)
  ChartTf tf;                      // Main timeframe where strategy operates on.
  // Constructor.
  StgParams()
      : id(rand()),
        is_enabled(true),
        is_suspended(false),
        is_boosted(true),
        order_close_time(0),
        order_close_loss(0.0f),
        order_close_profit(0.0f),
        weight(0),
        signal_open_method(0),
        signal_open_level(0),
        signal_open_filter_method(0),
        signal_open_filter_time(0),
        signal_open_boost(0),
        signal_close_method(0),
        signal_close_level(0),
        signal_close_filter_method(0),
        signal_close_filter_time(0),
        price_profit_method(0),
        price_profit_level(0),
        price_stop_method(0),
        price_stop_level(0),
        tick_filter_method(0),
        trend_threshold(0.4f),
        lot_size(0),
        lot_size_factor(1.0),
        max_risk(1.0),
        max_spread(0.0),
        shift(0),
        tp_max(0),
        sl_max(0),
        type(0),
        refresh_time(0) {}
  StgParams(int _som, int _sofm, float _sol, int _sob, int _scm, int _scfm, float _scl, int _psm, float _psl, int _tfm,
            float _ms, short _s = 0)
      : id(rand()),
        order_close_loss(0.0f),
        order_close_profit(0.0f),
        order_close_time(0),
        signal_open_method(_som),
        signal_open_filter_method(_sofm),
        signal_open_level(_sol),
        signal_open_boost(_sob),
        signal_close_method(_scm),
        signal_close_filter_method(_scfm),
        signal_close_filter_time(0),
        signal_close_level(_scl),
        price_profit_method(_psm),
        price_profit_level(_psl),
        price_stop_method(_psm),
        price_stop_level(_psl),
        tick_filter_method(_tfm),
        shift(_s),
        is_enabled(true),
        is_suspended(false),
        is_boosted(true),
        weight(0),
        lot_size(0),
        lot_size_factor(1.0),
        max_risk(1.0),
        max_spread(0.0),
        tp_max(0),
        sl_max(0),
        type(0),
        refresh_time(0) {}
  StgParams(StgParams &_stg_params) { this = _stg_params; }
  // Deconstructor.
  ~StgParams() {}

  // Getters.
  template <typename T>
  T Get(ENUM_STRATEGY_PARAM _param) {
    switch (_param) {
      case STRAT_PARAM_ID:
        return (T)id;
      case STRAT_PARAM_LS:
        return (T)lot_size;
      case STRAT_PARAM_LSF:
        return (T)lot_size_factor;
      case STRAT_PARAM_MAX_RISK:
        return (T)max_risk;
      case STRAT_PARAM_MAX_SPREAD:
        return (T)max_spread;
      case STRAT_PARAM_SOL:
        return (T)signal_open_level;
      case STRAT_PARAM_SCL:
        return (T)signal_close_level;
      case STRAT_PARAM_PPL:
        return (T)price_profit_level;
      case STRAT_PARAM_PSL:
        return (T)price_stop_level;
      case STRAT_PARAM_OCL:
        return (T)order_close_loss;
      case STRAT_PARAM_OCP:
        return (T)order_close_profit;
      case STRAT_PARAM_OCT:
        return (T)order_close_time;
      case STRAT_PARAM_SOM:
        return (T)signal_open_method;
      case STRAT_PARAM_SOFM:
        return (T)signal_open_filter_method;
      case STRAT_PARAM_SOFT:
        return (T)signal_open_filter_time;
      case STRAT_PARAM_SOB:
        return (T)signal_open_boost;
      case STRAT_PARAM_SCFM:
        return (T)signal_close_filter_method;
      case STRAT_PARAM_SCFT:
        return (T)signal_close_filter_time;
      case STRAT_PARAM_SCM:
        return (T)signal_close_method;
      case STRAT_PARAM_SHIFT:
        return (T)shift;
      case STRAT_PARAM_PPM:
        return (T)price_profit_method;
      case STRAT_PARAM_PSM:
        return (T)price_stop_method;
      case STRAT_PARAM_TFM:
        return (T)tick_filter_method;
      case STRAT_PARAM_TYPE:
        return (T)type;
      case STRAT_PARAM_WEIGHT:
        return (T)weight;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return WRONG_VALUE;
  }
  bool IsBoosted() { return is_boosted; }
  bool IsEnabled() { return is_enabled; }
  bool IsSuspended() { return is_suspended; }
  // Setters.
  template <typename T>
  void Set(ENUM_STRATEGY_PARAM _param, T _value) {
    switch (_param) {
      case STRAT_PARAM_ID:  // ID (magic number).
        id = (long)_value;
        return;
      case STRAT_PARAM_LS:  // Lot size
        lot_size = (float)_value;
        return;
      case STRAT_PARAM_LSF:  // Lot size factor
        lot_size_factor = (float)_value;
        return;
      case STRAT_PARAM_MAX_RISK:
        max_risk = (float)_value;
        return;
      case STRAT_PARAM_MAX_SPREAD:
        max_spread = (float)_value;
        return;
      case STRAT_PARAM_SHIFT:  // Shift
        shift = (short)_value;
        return;
      case STRAT_PARAM_SOL:  // Signal open level
        signal_open_level = (float)_value;
        return;
      case STRAT_PARAM_SCL:  // Signal close level
        signal_close_level = (float)_value;
        return;
      case STRAT_PARAM_PPL:  // Signal profit level
        price_profit_level = (float)_value;
        return;
      case STRAT_PARAM_PSL:  // Price stop level
        price_stop_level = (float)_value;
        return;
      case STRAT_PARAM_OCL:  // Order close loss
        order_close_loss = (float)_value;
        return;
      case STRAT_PARAM_OCP:  // Order close profit
        order_close_profit = (float)_value;
        return;
      case STRAT_PARAM_OCT:  // Order close time
        order_close_time = (long)_value;
        return;
      case STRAT_PARAM_SOM:  // Signal open method
        signal_open_method = (int)_value;
        return;
      case STRAT_PARAM_SOFM:  // Signal open filter method
        signal_open_filter_method = (int)_value;
        return;
      case STRAT_PARAM_SOFT:  // Signal open filter time
        signal_open_filter_time = (int)_value;
        return;
      case STRAT_PARAM_SOB:  // Signal open boost method
        signal_open_boost = (int)_value;
        return;
      case STRAT_PARAM_SCFM:  // Signal close filter method
        signal_close_filter_method = (int)_value;
        return;
      case STRAT_PARAM_SCFT:  // Signal close filter time
        signal_close_filter_time = (int)_value;
        return;
      case STRAT_PARAM_SCM:  // Signal close method
        signal_close_method = (int)_value;
        return;
      case STRAT_PARAM_PPM:  // Signal profit method
        price_profit_method = (int)_value;
        return;
      case STRAT_PARAM_PSM:  // Price stop method
        price_stop_method = (int)_value;
        return;
      case STRAT_PARAM_TFM:  // Tick filter method
        tick_filter_method = (int)_value;
        return;
      case STRAT_PARAM_TYPE:
        // Strategy type.
        type = (int)_value;
        return;
      case STRAT_PARAM_WEIGHT:  // Weight
        weight = (float)_value;
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void Set(ENUM_STRATEGY_PARAM _enum_param, MqlParam &_mql_param) {
    if (_mql_param.type == TYPE_DOUBLE || _mql_param.type == TYPE_FLOAT) {
      Set(_enum_param, _mql_param.double_value);
    } else {
      Set(_enum_param, _mql_param.integer_value);
    }
  }
  void SetId(long _id) { id = _id; }
  void SetStops(Strategy *_sl = NULL, Strategy *_tp = NULL) {
    // @todo: To remove.
  }
  void SetSignals(int _som, float _sol, int _sofm, int _sob, int _csm, float _cl) {
    signal_open_method = _som;
    signal_open_level = _sol;
    signal_open_filter_method = _sofm;
    signal_open_boost = _sob;
    signal_close_method = _csm;
    signal_close_level = _cl;
  }
  void Enabled(bool _is_enabled) { is_enabled = _is_enabled; };
  void Suspended(bool _is_suspended) { is_suspended = _is_suspended; };
  void Boost(bool _is_boosted) { is_boosted = _is_boosted; };
  // Printers.
  string ToString() {
    // SerializerConverter _stub = SerializerConverter::MakeStubObject<StrategySignal>(SERIALIZER_FLAG_SKIP_HIDDEN);
    return SerializerConverter::FromObject(THIS_REF, SERIALIZER_FIELD_FLAG_DEFAULT | SERIALIZER_FLAG_SKIP_HIDDEN)
        .ToString<SerializerJson>(SERIALIZER_JSON_NO_WHITESPACES);
  }

  // Serializers.
  SERIALIZER_EMPTY_STUB;
  SerializerNodeType Serialize(Serializer &s) {
    s.Pass(THIS_REF, "is_enabled", is_enabled);
    s.Pass(THIS_REF, "is_suspended", is_suspended);
    s.Pass(THIS_REF, "is_boosted", is_boosted);
    s.Pass(THIS_REF, "id", id);
    s.Pass(THIS_REF, "weight", weight);
    s.Pass(THIS_REF, "ocl", order_close_loss);
    s.Pass(THIS_REF, "ocp", order_close_profit);
    s.Pass(THIS_REF, "oct", order_close_time);
    s.Pass(THIS_REF, "shift", shift);
    s.Pass(THIS_REF, "som", signal_open_method);
    s.Pass(THIS_REF, "sol", signal_open_level);
    s.Pass(THIS_REF, "sofm", signal_open_filter_method);
    s.Pass(THIS_REF, "soft", signal_open_filter_time);
    s.Pass(THIS_REF, "sob", signal_open_boost);
    s.Pass(THIS_REF, "scm", signal_close_method);
    s.Pass(THIS_REF, "scfm", signal_close_filter_method);
    s.Pass(THIS_REF, "scft", signal_close_filter_time);
    s.Pass(THIS_REF, "scl", signal_close_level);
    s.Pass(THIS_REF, "ppm", price_profit_method);
    s.Pass(THIS_REF, "ppl", price_profit_level);
    s.Pass(THIS_REF, "psm", price_stop_method);
    s.Pass(THIS_REF, "psl", price_stop_level);
    s.Pass(THIS_REF, "tfm", tick_filter_method);
    s.Pass(THIS_REF, "tt", trend_threshold);
    s.Pass(THIS_REF, "ls", lot_size);
    s.Pass(THIS_REF, "lsf", lot_size_factor);
    s.Pass(THIS_REF, "max_risk", max_risk);
    s.Pass(THIS_REF, "max_spread", max_spread);
    s.Pass(THIS_REF, "tp_max", tp_max);
    s.Pass(THIS_REF, "sl_max", sl_max);
    s.Pass(THIS_REF, "refresh_time", refresh_time);
    // @todo
    // Ref<Log> logger;           // Reference to Log object.
    // Trade *trade;              // Pointer to Trade class.
    // Indicator *data;           // Pointer to Indicator class.
    // Strategy *sl, *tp;         // References to Strategy class (stop-loss and profit-take).
    return SerializerNodeObject;
  }
} stg_params_defaults;

/* Structure for strategy's param values. */
struct Stg_Params {
  string symbol;
  ENUM_TIMEFRAMES tf;
  Stg_Params() : symbol(_Symbol), tf((ENUM_TIMEFRAMES)_Period) {}
};

/* Structure for strategy's process results. */
struct StgProcessResult {
  float boost_factor;                  // Boost factor used.
  float lot_size;                      // Lot size used.
  unsigned int last_error;             // Last error code.
  unsigned short pos_updated;          // Number of positions updated.
  unsigned short stops_invalid_sl;     // Number of invalid stop-loss values.
  unsigned short stops_invalid_tp;     // Number of invalid take-profit values.
  unsigned short tasks_processed;      // Task processed.
  unsigned short tasks_processed_not;  // Task not processed.
  // Struct constructor.
  StgProcessResult() { Reset(); }
  // Getters.
  float GetBoostFactor() { return boost_factor; }
  float GetLotSize() { return lot_size; }
  string ToString() { return StringFormat("%d,%d,%d,%d", pos_updated, stops_invalid_sl, stops_invalid_tp, last_error); }
  // Setters.
  void ProcessLastError() { last_error = fmax(last_error, Terminal::GetLastError()); }
  void Reset() {
    pos_updated = stops_invalid_sl = stops_invalid_tp = 0;
    last_error = ERR_NO_ERROR;
  }
  void SetBoostFactor(float _value) { boost_factor = _value; }
  void SetLotSize(float _value) { lot_size = _value; }
  // Serializers.
  SERIALIZER_EMPTY_STUB;
  SerializerNodeType Serialize(Serializer &_s) {
    _s.Pass(THIS_REF, "boost_factor", boost_factor, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "lot_size", lot_size, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "last_error", last_error, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "pos_updated", pos_updated, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "stops_invalid_sl", stops_invalid_sl, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "stops_invalid_tp", stops_invalid_tp, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "tasks_processed", tasks_processed, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "tasks_processed_not", tasks_processed_not, SERIALIZER_FIELD_FLAG_DYNAMIC);
    return SerializerNodeObject;
  }
};

/* Struture for strategy statistics */
struct StgStats {
  unsigned int orders_open;  // Number of current opened orders.
  unsigned int errors;       // Count reported errors.
};

/* Structure for strategy's statistical periods. */
struct StgStatsPeriod {
  // Statistics variables.
  unsigned int orders_total;  // Number of total opened orders.
  unsigned int orders_won;    // Number of total won orders.
  unsigned int orders_lost;   // Number of total lost orders.
  double avg_spread;          // Average spread.
  double net_profit;          // Total net profit.
  double gross_profit;        // Total gross profit.
  double gross_loss;          // Total gross loss.
  double profit_factor;       // Profit factor.
  // Getters.
  string ToCSV() {
    return StringFormat("%d,%d,%d,%g,%g,%g,%g,%g", orders_total, orders_won, orders_lost, avg_spread, net_profit,
                        gross_profit, gross_loss, profit_factor);
  }
};

/* Structure for strategy's entry values. */
struct StgEntry {
  unsigned short signals;
  StgStatsPeriod stats_period[FINAL_ENUM_STRATEGY_STATS_PERIOD];
  string ToCSV() {
    return StringFormat("%s,%s,%s,%s", stats_period[(int)EA_STATS_DAILY].ToCSV(),
                        stats_period[(int)EA_STATS_WEEKLY].ToCSV(), stats_period[(int)EA_STATS_MONTHLY].ToCSV(),
                        stats_period[(int)EA_STATS_TOTAL].ToCSV());
  }
  // Struct setters.
  void SetStats(StgStatsPeriod &_stats, ENUM_STRATEGY_STATS_PERIOD _period) { stats_period[(int)_period] = _stats; }
  // Serializers.
  SERIALIZER_EMPTY_STUB
  SerializerNodeType Serialize(Serializer &_s) {
    // _s.Pass(THIS_REF, "signals", (int) signals);
    return SerializerNodeObject;
  }
};

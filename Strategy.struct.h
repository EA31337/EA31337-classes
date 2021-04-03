//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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

// Includes.
#include "Serializer.mqh"
#include "Strategy.enum.h"
#include "Task.struct.h"

// Forward class declaration.
class Indicator;
class Strategy;
class Trade;

/* Structure for strategy parameters. */
struct StgParams {
  // Strategy config parameters.
  bool is_enabled;                                     // State of the strategy (whether enabled or not).
  bool is_suspended;                                   // State of the strategy (whether suspended or not)
  bool is_boosted;                                     // State of the boost feature (to increase lot size).
  long id;                                             // Identification number of the strategy.
  unsigned long magic_no;                              // Magic number of the strategy.
  float weight;                                        // Weight of the strategy.
  int order_close_time;                                // Order close time in mins (>0) or bars (<0)
  int signal_open_method;                              // Signal open method.
  float signal_open_level;                             // Signal open level.
  int signal_open_filter;                              // Signal open filter method.
  int signal_open_boost;                               // Signal open boost method (for lot size increase).
  int signal_close_method;                             // Signal close method.
  float signal_close_level;                            // Signal close level.
  int price_profit_method;                             // Price profit method.
  float price_profit_level;                            // Price profit level.
  int price_stop_method;                               // Price stop method.
  float price_stop_level;                              // Price stop level.
  int tick_filter_method;                              // Tick filter.
  float trend_threshold;                               // Trend strength threshold.
  float lot_size;                                      // Lot size to trade.
  float lot_size_factor;                               // Lot size multiplier factor.
  float max_risk;                                      // Maximum risk to take (1.0 = normal, 2.0 = 2x).
  float max_spread;                                    // Maximum spread to trade (in pips).
  int tp_max;                                          // Hard limit on maximum take profit (in pips).
  int sl_max;                                          // Hard limit on maximum stop loss (in pips).
  datetime refresh_time;                               // Order refresh frequency (in sec).
  short shift;                                         // Shift (relative to the current bar, 0 - default)
  Ref<Log> logger;                                     // Reference to Log object.
  Trade *trade;                                        // Pointer to Trade class.
  DictStruct<int, Ref<Indicator>> indicators_managed;  // Indicators list keyed by id.
  Dict<int, Indicator *> indicators_unmanaged;         // Indicators list keyed by id.
  // Constructor.
  StgParams(Trade *_trade = NULL)
      : trade(_trade),
        is_enabled(true),
        is_suspended(false),
        is_boosted(true),
        order_close_time(0),
        magic_no(rand()),
        weight(0),
        signal_open_method(0),
        signal_open_level(0),
        signal_open_filter(0),
        signal_open_boost(0),
        signal_close_method(0),
        signal_close_level(0),
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
        tp_max(0),
        sl_max(0),
        refresh_time(0),
        logger(new Log) {
    InitLotSize();
  }
  StgParams(int _som, int _sof, float _sol, int _sob, int _scm, float _scl, int _psm, float _psl, int _tfm, float _ms,
            short _s = 0, int _oct = 0)
      : signal_open_method(_som),
        signal_open_filter(_sof),
        signal_open_level(_sol),
        signal_open_boost(_sob),
        signal_close_method(_scm),
        signal_close_level(_scl),
        price_profit_method(_psm),
        price_profit_level(_psl),
        price_stop_method(_psm),
        price_stop_level(_psl),
        tick_filter_method(_tfm),
        shift(_s),
        order_close_time(_oct),
        is_enabled(true),
        is_suspended(false),
        is_boosted(true),
        magic_no(rand()),
        weight(0),
        lot_size(0),
        lot_size_factor(1.0),
        max_risk(1.0),
        max_spread(0.0),
        tp_max(0),
        sl_max(0),
        refresh_time(0),
        logger(new Log) {
    InitLotSize();
  }
  StgParams(StgParams &_stg_params) { this = _stg_params; }
  // Deconstructor.
  ~StgParams() {}
  // Struct methods.
  void InitLotSize() {
    if (Object::IsValid(trade)) {
      lot_size = (float)GetChart().GetVolumeMin();
    }
  }
  // Getters.
  Chart *GetChart() { return Object::IsValid(trade) ? trade.Chart() : NULL; }
  Log *GetLog() { return logger.Ptr(); }
  bool IsBoosted() { return is_boosted; }
  bool IsEnabled() { return is_enabled; }
  bool IsSuspended() { return is_suspended; }
  Indicator *GetIndicator(int _id = 0) {
    if (indicators_managed.KeyExists(_id)) {
      return indicators_managed[_id].Ptr();
    } else if (indicators_unmanaged.KeyExists(_id)) {
      return indicators_unmanaged[_id];
    }

    Alert("Missing indicator id ", _id);
    return NULL;
  }
  float GetLotSize() { return lot_size; }
  float GetLotSizeFactor() { return lot_size_factor; }
  float GetLotSizeWithFactor() { return lot_size * lot_size_factor; }
  float GetMaxRisk() { return max_risk; }
  float GetMaxSpread() { return max_spread; }
  float GetProperty(ENUM_STRATEGY_PROP_DBL _prop_id) {
    switch (_prop_id) {
      case STRAT_PROP_LS:
        return lot_size;
      case STRAT_PROP_LSF:
        return lot_size_factor;
      case STRAT_PROP_SOL:
        return signal_open_level;
      case STRAT_PROP_SCL:
        return signal_close_level;
      case STRAT_PROP_PPL:
        return price_profit_level;
      case STRAT_PROP_PSL:
        return price_stop_level;
    }
    return NULL;
  }
  int GetOrderCloseTime() { return order_close_time; }
  int GetProperty(ENUM_STRATEGY_PROP_INT _prop_id) {
    switch (_prop_id) {
      case STRAT_PROP_OCT:
        return order_close_time;
      case STRAT_PROP_SOM:
        return signal_open_method;
      case STRAT_PROP_SOF:
        return signal_open_filter;
      case STRAT_PROP_SOB:
        return signal_open_boost;
      case STRAT_PROP_SCM:
        return signal_close_method;
      case STRAT_PROP_PPM:
        return price_profit_method;
      case STRAT_PROP_PSM:
        return price_stop_method;
      case STRAT_PROP_TFM:
        return tick_filter_method;
    }
    return NULL;
  }
  int GetShift() { return shift; }
  // Setters.
  void SetId(long _id) { id = _id; }
  void SetIndicator(Indicator *_indi, bool _managed = true, int _id = 0) {
    if (_managed) {
      Ref<Indicator> _ref = _indi;
      indicators_managed.Set(_id, _ref);
    } else {
      indicators_unmanaged.Set(_id, _indi);
    }
  }
  void SetLotSize(float _lot_size) { lot_size = _lot_size; }
  void SetLotSizeFactor(float _lot_size_factor) { lot_size_factor = _lot_size_factor; }
  void SetMagicNo(unsigned long _mn) { magic_no = _mn; }
  void SetOrderCloseTime(int _value) { order_close_time = _value; }
  void SetProperty(ENUM_STRATEGY_PROP_DBL _prop_id, float _value) {
    switch (_prop_id) {
      case STRAT_PROP_LS:  // Lot size
        lot_size = _value;
        break;
      case STRAT_PROP_LSF:  // Lot size factor
        lot_size_factor = _value;
        break;
      case STRAT_PROP_SOL:  // Signal open level
        signal_open_level = _value;
        break;
      case STRAT_PROP_SCL:  // Signal close level
        signal_close_level = _value;
        break;
      case STRAT_PROP_PPL:  // Signal profit level
        price_profit_level = _value;
        break;
      case STRAT_PROP_PSL:  // Price stop level
        price_stop_level = _value;
        break;
    }
  }
  void SetProperty(ENUM_STRATEGY_PROP_INT _prop_id, int _value) {
    switch (_prop_id) {
      case STRAT_PROP_OCT:  // Order close time
        order_close_time = _value;
        break;
      case STRAT_PROP_SOM:  // Signal open method
        signal_open_method = _value;
        break;
      case STRAT_PROP_SOF:  // Signal open filter
        signal_open_filter = _value;
        break;
      case STRAT_PROP_SOB:  // Signal open boost method
        signal_open_boost = _value;
        break;
      case STRAT_PROP_SCM:  // Signal close method
        signal_close_method = _value;
        break;
      case STRAT_PROP_PPM:  // Signal profit method
        price_profit_method = _value;
        break;
      case STRAT_PROP_PSM:  // Price stop method
        price_stop_method = _value;
        break;
      case STRAT_PROP_TFM:  // Tick filter method
        tick_filter_method = _value;
        break;
    }
  }
  void SetStops(Strategy *_sl = NULL, Strategy *_tp = NULL) {
    // @todo: To remove.
  }
  void SetTf(ENUM_TIMEFRAMES _tf, string _symbol = NULL) { trade = new Trade(_tf, _symbol); }
  void SetShift(short _shift) { shift = _shift; }
  void SetSignals(int _open_method, float _open_level, int _open_filter, int _open_boost, int _close_method,
                  float _close_level) {
    signal_open_method = _open_method;
    signal_open_level = _open_level;
    signal_open_filter = _open_filter;
    signal_open_boost = _open_boost;
    signal_close_method = _close_method;
    signal_close_level = _close_level;
  }
  void SetPriceProfitLevel(float _level) { price_profit_level = _level; }
  void SetPriceProfitMethod(int _method) { price_profit_method = _method; }
  void SetPriceStopLevel(float _level) { price_stop_level = _level; }
  void SetPriceStopMethod(int _method) { price_stop_method = _method; }
  void SetTickFilter(int _method) { tick_filter_method = _method; }
  void SetTrade(Trade *_trade) {
    Object::Delete(trade);
    trade = _trade;
  }
  void SetMaxSpread(float _spread) { max_spread = _spread; }
  void SetMaxRisk(float _risk) { max_risk = _risk; }
  void Enabled(bool _is_enabled) { is_enabled = _is_enabled; };
  void Suspended(bool _is_suspended) { is_suspended = _is_suspended; };
  void Boost(bool _is_boosted) { is_boosted = _is_boosted; };
  void DeleteObjects() {
    Object::Delete(trade);
    for (DictIterator<string, DrawPoint> iter = indicators_unmanaged.Begin(); iter.IsValid(); ++iter) {
      delete iter.Value();
    }
  }
  // Printers.
  string ToString() {
    return StringFormat("Enabled:%s;Suspended:%s;Boosted:%s;Id:%d,MagicNo:%d;Weight:%.2f;" + "SOM:%d,SOL:%.2f;" +
                            "SCM:%d,SCL:%.2f;" + "PSM:%d,PSL:%.2f;" + "LS:%.2f(Factor:%.2f);MS:%.2f;",
                        // @todo: "Data:%s;SL/TP-Strategy:%s/%s",
                        is_enabled ? "Yes" : "No", is_suspended ? "Yes" : "No", is_boosted ? "Yes" : "No", id, magic_no,
                        weight, signal_open_method, signal_open_level, signal_close_method, signal_close_level,
                        price_stop_method, price_stop_level, lot_size, lot_size_factor, max_spread
                        // @todo: data, sl, tp
    );
  }

  // Serializers.
  SERIALIZER_EMPTY_STUB;
  SerializerNodeType Serialize(Serializer &s) {
    s.Pass(this, "is_enabled", is_enabled);
    s.Pass(this, "is_suspended", is_suspended);
    s.Pass(this, "is_boosted", is_boosted);
    s.Pass(this, "id", id);
    s.Pass(this, "magic", magic_no);
    s.Pass(this, "weight", weight);
    s.Pass(this, "oct", order_close_time);
    s.Pass(this, "shift", shift);
    s.Pass(this, "som", signal_open_method);
    s.Pass(this, "sol", signal_open_level);
    s.Pass(this, "sof", signal_open_filter);
    s.Pass(this, "sob", signal_open_boost);
    s.Pass(this, "scm", signal_close_method);
    s.Pass(this, "scl", signal_close_level);
    s.Pass(this, "ppm", price_profit_method);
    s.Pass(this, "ppl", price_profit_level);
    s.Pass(this, "psm", price_stop_method);
    s.Pass(this, "psl", price_stop_level);
    s.Pass(this, "tfm", tick_filter_method);
    s.Pass(this, "tt", trend_threshold);
    s.Pass(this, "ls", lot_size);
    s.Pass(this, "lsf", lot_size_factor);
    s.Pass(this, "max_risk", max_risk);
    s.Pass(this, "max_spread", max_spread);
    s.Pass(this, "tp_max", tp_max);
    s.Pass(this, "sl_max", sl_max);
    s.Pass(this, "refresh_time", refresh_time);
    // @todo
    // Ref<Log> logger;           // Reference to Log object.
    // Trade *trade;              // Pointer to Trade class.
    // Indicator *data;           // Pointer to Indicator class.
    // Strategy *sl, *tp;         // References to Strategy class (stop-loss and profit-take).
    return SerializerNodeObject;
  }
};

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
    _s.Pass(this, "boost_factor", boost_factor, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(this, "lot_size", lot_size, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(this, "last_error", last_error, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(this, "pos_updated", pos_updated, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(this, "stops_invalid_sl", stops_invalid_sl, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(this, "stops_invalid_tp", stops_invalid_tp, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(this, "tasks_processed", tasks_processed, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(this, "tasks_processed_not", tasks_processed_not, SERIALIZER_FIELD_FLAG_DYNAMIC);
    return SerializerNodeObject;
  }
};

/* Structure for strategy's signals. */
struct StrategySignal {
  unsigned int signals;  // Store signals (@see: ENUM_STRATEGY_SIGNAL_FLAG).
  // Signal methods for bitwise operations.
  /* Getters */
  bool CheckSignals(unsigned int _flags) { return (signals & _flags) != 0; }
  bool CheckSignalsAll(unsigned int _flags) { return (signals & _flags) == _flags; }
  unsigned int GetSignals() { return signals; }
  /* Setters */
  void AddSignals(unsigned int _flags) { signals |= _flags; }
  void RemoveSignals(unsigned int _flags) { signals &= ~_flags; }
  void SetSignal(ENUM_STRATEGY_SIGNAL_FLAG _flag, bool _value = true) {
    if (_value) {
      AddSignals(_flag);
    } else {
      RemoveSignals(_flag);
    }
  }
  void SetSignals(unsigned int _flags) { signals = _flags; }
  // Serializers.
  SERIALIZER_EMPTY_STUB;
  SerializerNodeType Serialize(Serializer &_s) {
    // _s.Pass(this, "signals", signals, SERIALIZER_FIELD_FLAG_DYNAMIC);
    int _size = sizeof(int) * 8;
    for (int i = 0; i < _size; i++) {
      int _value = CheckSignals(1 << i) ? 1 : 0;
      _s.Pass(this, (string)(i + 1), _value, SERIALIZER_FIELD_FLAG_DYNAMIC);
    }
    return SerializerNodeObject;
  }
};

/* Struture for strategy statistics */
struct StgStats {
  uint orders_open;  // Number of current opened orders.
  uint errors;       // Count reported errors.
};

/* Structure for strategy's statistical periods. */
struct StgStatsPeriod {
  // Statistics variables.
  uint orders_total;     // Number of total opened orders.
  uint orders_won;       // Number of total won orders.
  uint orders_lost;      // Number of total lost orders.
  double avg_spread;     // Average spread.
  double net_profit;     // Total net profit.
  double gross_profit;   // Total gross profit.
  double gross_loss;     // Total gross loss.
  double profit_factor;  // Profit factor.
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
    return StringFormat("%s,%s,%s,%s", stats_period[EA_STATS_DAILY].ToCSV(), stats_period[EA_STATS_WEEKLY].ToCSV(),
                        stats_period[EA_STATS_MONTHLY].ToCSV(), stats_period[EA_STATS_TOTAL].ToCSV());
  }
  // Struct setters.
  void SetStats(StgStatsPeriod &_stats, ENUM_STRATEGY_STATS_PERIOD _period) { stats_period[_period] = _stats; }
  // Serializers.
  SERIALIZER_EMPTY_STUB
  SerializerNodeType Serialize(Serializer &_s) {
    // _s.Pass(this, "signals", (int) signals);
    return SerializerNodeObject;
  }
};

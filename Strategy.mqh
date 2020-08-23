//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Prevents processing this includes file for the second time.
#ifndef STRATEGY_MQH
#define STRATEGY_MQH

// Includes.
#include "Dict.mqh"
#include "Indicator.mqh"
#include "Object.mqh"
#include "String.mqh"
#include "Trade.mqh"

// Defines.
#ifndef __noinput__
#define INPUT extern
#else
#define INPUT static
#endif

// Enums.
// EA actions.
enum ENUM_STRATEGY_ACTION {
  STRAT_ACTION_DISABLE = 0,  // Disables Strategy.
  STRAT_ACTION_ENABLE,       // Enables Strategy.
  STRAT_ACTION_SUSPEND,      // Suspend Strategy.
  STRAT_ACTION_UNSUSPEND,    // Unsuspend Strategy.
  FINAL_STRATEGY_ACTION_ENTRY
};

// EA conditions.
enum ENUM_STRATEGY_CONDITION {
  STRAT_COND_IS_ENABLED = 1,  // When Strategy is enabled.
  STRAT_COND_IS_SUSPENDED,    // When Strategy is suspended.
  FINAL_STRATEGY_CONDITION_ENTRY
};

/**
 * Implements strategy class.
 */
class Strategy;

struct StgParams {
  // Strategy config parameters.
  bool is_enabled;           // State of the strategy (whether enabled or not).
  bool is_suspended;         // State of the strategy (whether suspended or not)
  bool is_boosted;           // State of the boost feature (to increase lot size).
  long id;                   // Identification number of the strategy.
  unsigned long magic_no;    // Magic number of the strategy.
  float weight;              // Weight of the strategy.
  int shift;                 // Shift (relative to the current bar, 0 - default)
  int signal_open_method;    // Signal open method.
  float signal_open_level;   // Signal open level.
  int signal_open_filter;    // Signal open filter method.
  int signal_open_boost;     // Signal open boost method (for lot size increase).
  int signal_close_method;   // Signal close method.
  float signal_close_level;  // Signal close level.
  int price_limit_method;    // Price limit method.
  float price_limit_level;   // Price limit level.
  int tick_filter_method;    // Tick filter.
  float lot_size;            // Lot size to trade.
  float lot_size_factor;     // Lot size multiplier factor.
  float max_risk;            // Maximum risk to take (1.0 = normal, 2.0 = 2x).
  float max_spread;          // Maximum spread to trade (in pips).
  int tp_max;                // Hard limit on maximum take profit (in pips).
  int sl_max;                // Hard limit on maximum stop loss (in pips).
  datetime refresh_time;     // Order refresh frequency (in sec).
  Ref<Log> logger;           // Reference to Log object.
  Trade *trade;              // Pointer to Trade class.
  Indicator *data;           // Pointer to Indicator class.
  Strategy *sl, *tp;         // Pointers to Strategy class (stop-loss and profit-take).
  // Constructor.
  StgParams(Trade *_trade = NULL, Indicator *_data = NULL, Strategy *_sl = NULL, Strategy *_tp = NULL)
      : trade(_trade),
        data(_data),
        sl(_sl),
        tp(_tp),
        is_enabled(true),
        is_suspended(false),
        is_boosted(true),
        magic_no(rand()),
        weight(0),
        signal_open_method(0),
        signal_open_level(0),
        signal_open_filter(0),
        signal_open_boost(0),
        signal_close_method(0),
        signal_close_level(0),
        price_limit_method(0),
        price_limit_level(0),
        tick_filter_method(0),
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
  StgParams(int _som, int _sof, float _sol, int _sob, int _scm, float _scl, int _plm, float _pll, int _tfm, float _ms,
            int _s = 0)
      : signal_open_method(_som),
        signal_open_filter(_sof),
        signal_open_level(_sol),
        signal_open_boost(_sob),
        signal_close_method(_scm),
        signal_close_level(_scl),
        price_limit_method(_plm),
        price_limit_level(_pll),
        tick_filter_method(_tfm),
        shift(_s),
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
  float GetLotSize() { return lot_size; }
  float GetLotSizeFactor() { return lot_size_factor; }
  float GetLotSizeWithFactor() { return lot_size * lot_size_factor; }
  float GetMaxRisk() { return max_risk; }
  float GetMaxSpread() { return max_spread; }
  bool IsBoosted() { return is_boosted; }
  bool IsEnabled() { return is_enabled; }
  bool IsSuspended() { return is_suspended; }
  // Setters.
  void SetId(long _id) { id = _id; }
  void SetIndicator(Indicator *_indi) { data = _indi; }
  void SetLotSize(float _lot_size) { lot_size = _lot_size; }
  void SetLotSizeFactor(float _lot_size_factor) { lot_size_factor = _lot_size_factor; }
  void SetMagicNo(unsigned long _mn) { magic_no = _mn; }
  void SetStops(Strategy *_sl = NULL, Strategy *_tp = NULL) {
    sl = _sl;
    tp = _tp;
  }
  void SetTf(ENUM_TIMEFRAMES _tf, string _symbol = NULL) { trade = new Trade(_tf, _symbol); }
  void SetSignals(int _open_method, float _open_level, int _open_filter, int _open_boost, int _close_method,
                  float _close_level) {
    signal_open_method = _open_method;
    signal_open_level = _open_level;
    signal_open_filter = _open_filter;
    signal_open_boost = _open_boost;
    signal_close_method = _close_method;
    signal_close_level = _close_level;
  }
  void SetPriceLimits(int _method, float _level) {
    price_limit_method = _method;
    price_limit_level = _level;
  }
  void SetTickFilter(int _method) { tick_filter_method = _method; }
  void SetMaxSpread(float _spread) { max_spread = _spread; }
  void SetMaxRisk(float _risk) { max_risk = _risk; }
  void Enabled(bool _is_enabled) { is_enabled = _is_enabled; };
  void Suspended(bool _is_suspended) { is_suspended = _is_suspended; };
  void Boost(bool _is_boosted) { is_boosted = _is_boosted; };
  void DeleteObjects() {
    Object::Delete(data);
    Object::Delete(sl);
    Object::Delete(tp);
    Object::Delete(trade);
  }
  // Printers.
  string ToString() {
    return StringFormat("Enabled:%s;Suspended:%s;Boosted:%s;Id:%d,MagicNo:%d;Weight:%.2f;" + "SOM:%d,SOL:%.2f;" +
                            "SCM:%d,SCL:%.2f;" + "PLM:%d,PLL:%.2f;" + "LS:%.2f(Factor:%.2f);MS:%.2f;",
                        // @todo: "Data:%s;SL/TP-Strategy:%s/%s",
                        is_enabled ? "Yes" : "No", is_suspended ? "Yes" : "No", is_boosted ? "Yes" : "No", id, magic_no,
                        weight, signal_open_method, signal_open_level, signal_close_method, signal_close_level,
                        price_limit_method, price_limit_level, lot_size, lot_size_factor, max_spread
                        // @todo: data, sl, tp
    );
  }
};

// Defines struct for individual strategy's param values.
struct Stg_Params {
  string symbol;
  ENUM_TIMEFRAMES tf;
  Stg_Params() : symbol(_Symbol), tf((ENUM_TIMEFRAMES)_Period) {}
};

// Defines struct to store results for signal processing.
struct StgProcessResult {
  unsigned int pos_closed;        // Number of positions closed.
  unsigned int pos_opened;        // Number of positions opened.
  unsigned int pos_updated;       // Number of positions updated.
  unsigned int stops_invalid_sl;  // Number of invalid stop-loss values.
  unsigned int stops_invalid_tp;  // Number of invalid take-profit values;
  unsigned int last_error;        // Last error code.
  StgProcessResult() { Reset(); }
  void ProcessLastError() { last_error = fmax(last_error, Terminal::GetLastError()); }
  void Reset() {
    pos_closed = pos_opened = pos_updated = stops_invalid_sl = stops_invalid_tp = 0;
    last_error = ERR_NO_ERROR;
  }
  string ToString() {
    return StringFormat("%d,%d,%d,%d,%d,%d", pos_closed, pos_opened, pos_updated, stops_invalid_sl, stops_invalid_tp,
                        last_error);
  }
};

class Strategy : public Object {
  // Enums.
  enum ENUM_OPEN_METHOD {
    OPEN_METHOD1 = 1,      // Method #1.
    OPEN_METHOD2 = 2,      // Method #2.
    OPEN_METHOD3 = 4,      // Method #3.
    OPEN_METHOD4 = 8,      // Method #4.
    OPEN_METHOD5 = 16,     // Method #5.
    OPEN_METHOD6 = 32,     // Method #6.
    OPEN_METHOD7 = 64,     // Method #7.
    OPEN_METHOD8 = 128,    // Method #8.
    OPEN_METHOD9 = 256,    // Method #9.
    OPEN_METHOD10 = 512,   // Method #10.
    OPEN_METHOD11 = 1024,  // Method #11.
    OPEN_METHOD12 = 2048   // Method #12.
  };
  enum ENUM_STRATEGY_STATS_PERIOD {
    EA_STATS_DAILY,
    EA_STATS_WEEKLY,
    EA_STATS_MONTHLY,
    EA_STATS_TOTAL,
    FINAL_ENUM_STRATEGY_STATS_PERIOD
  };

  // Structs.

 protected:
  Dict<string, double> *ddata;
  Dict<string, int> *idata;
  Dict<int, int> *iidata;
  StgParams sparams;
  StgProcessResult sresult;

 private:
  // Strategy statistics.
  struct StgStats {
    uint orders_open;  // Number of current opened orders.
    uint errors;       // Count reported errors.
  } stats;

  // Strategy statistics per period.
  struct StgStatsPeriod {
    // Statistics variables.
    uint orders_total;     // Number of total opened orders.
    uint orders_won;       // Number of total won orders.
    uint orders_lost;      // Number of total lost orders.
    double profit_factor;  // Profit factor.
    double avg_spread;     // Average spread.
    double net_profit;     // Total net profit.
    double gross_profit;   // Total gross profit.
    double gross_loss;     // Total gross profit.
  } stats_period[FINAL_ENUM_STRATEGY_STATS_PERIOD];

 protected:
  // Base variables.
  string name;
  // Other variables.
  int filter_method[];    // Filter method to consider the trade.
  int open_condition[];   // Open conditions.
  int close_condition[];  // Close conditions.

 public:
  /* Special methods */

  /**
   * Class constructor.
   */
  Strategy(const StgParams &_sparams, string _name = "")
      : ddata(new Dict<string, double>), idata(new Dict<string, int>), iidata(new Dict<int, int>) {
    // Assign struct.
    // We don't want objects which were instantiated by default.
    sparams.DeleteObjects();
    sparams = _sparams;

    // Initialize variables.
    name = _name;

    // Link log instances.
    Logger().Link(sparams.trade.Logger());

    // Statistics variables.
    UpdateOrderStats(EA_STATS_DAILY);
    UpdateOrderStats(EA_STATS_WEEKLY);
    UpdateOrderStats(EA_STATS_MONTHLY);
    UpdateOrderStats(EA_STATS_TOTAL);
  }

  /**
   * Class copy constructor.
   */
  Strategy(const Strategy &_strat) {
    // @todo
    sparams = _strat.GetParams();
    // ...
  }

  /**
   * Class deconstructor.
   */
  ~Strategy() {
    sparams.DeleteObjects();
    Object::Delete(ddata);
    Object::Delete(idata);
    Object::Delete(iidata);
  }

  /* Processing methods */

  /**
   * Process strategy's signals.
   *
   * Call this method for every new bar.
   *
   * @return
   *   Returns StgProcessResult struct.
   */
  StgProcessResult ProcessSignals() {
    float _boost_factor = 1.0, _lot_size = 0;
    if (SignalOpen(ORDER_TYPE_BUY, sparams.signal_open_method, sparams.signal_open_level) &&
        SignalOpenFilter(ORDER_TYPE_BUY, sparams.signal_open_filter)) {
      _boost_factor = sparams.IsBoosted() ? SignalOpenBoost(ORDER_TYPE_BUY, sparams.signal_open_boost) : 1.0f;
      _lot_size = sparams.GetLotSizeWithFactor();
      if (OrderOpen(ORDER_TYPE_BUY, _lot_size * _boost_factor, GetOrderOpenComment("SignalOpen"))) {
        sresult.pos_opened++;
      }
    }
    sresult.ProcessLastError();
    if (SignalOpen(ORDER_TYPE_SELL, sparams.signal_open_method, sparams.signal_open_level) &&
        SignalOpenFilter(ORDER_TYPE_SELL, sparams.signal_open_filter)) {
      _boost_factor = sparams.IsBoosted() ? SignalOpenBoost(ORDER_TYPE_SELL, sparams.signal_open_boost) : 1.0f;
      _lot_size = sparams.GetLotSizeWithFactor();
      if (OrderOpen(ORDER_TYPE_SELL, _lot_size * _boost_factor, GetOrderOpenComment("SignalOpen"))) {
        sresult.pos_opened++;
      }
    }
    if (sparams.trade.HasActiveOrders()) {
      sresult.ProcessLastError();
      if (SignalClose(ORDER_TYPE_BUY, sparams.signal_close_method, sparams.signal_close_level)) {
        if (sparams.trade.OrdersCloseViaCmd(ORDER_TYPE_BUY, GetOrderCloseComment("SignalClose")) > 0) {
          sresult.pos_closed++;
        }
      }
      sresult.ProcessLastError();
      if (SignalClose(ORDER_TYPE_SELL, sparams.signal_close_method, sparams.signal_close_level)) {
        if (sparams.trade.OrdersCloseViaCmd(ORDER_TYPE_SELL, GetOrderCloseComment("SignalClose")) > 0) {
          sresult.pos_closed++;
        }
      }
    }
    sresult.ProcessLastError();
    return sresult;
  }

  /**
   * Process strategy's orders.
   *
   * Call this method for every new bar.
   *
   * @return
   *   Returns StgProcessResult struct.
   */
  StgProcessResult ProcessOrders() {
    bool sl_valid, tp_valid;
    double sl_new, tp_new;
    Ref<Order> _order;
    DictStruct<long, Ref<Order>> *_orders_active = sparams.trade.GetOrdersActive();
    for (DictStructIterator<long, Ref<Order>> iter = _orders_active.Begin(); iter.IsValid(); ++iter) {
      _order = iter.Value();
      if (_order.Ptr().IsOpen()) {
        sl_new =
            PriceLimit(_order.Ptr().OrderType(), ORDER_TYPE_SL, sparams.price_limit_method, sparams.price_limit_level);
        tp_new =
            PriceLimit(_order.Ptr().OrderType(), ORDER_TYPE_TP, sparams.price_limit_method, sparams.price_limit_level);
        sl_new = Market().NormalizeSLTP(sl_new, _order.Ptr().GetRequest().type, ORDER_TYPE_SL);
        tp_new = Market().NormalizeSLTP(tp_new, _order.Ptr().GetRequest().type, ORDER_TYPE_TP);
        sl_valid = sparams.trade.ValidSL(sl_new, _order.Ptr().GetRequest().type);
        tp_valid = sparams.trade.ValidTP(tp_new, _order.Ptr().GetRequest().type);
        _order.Ptr().OrderModify(
            sl_valid && sl_new > 0 ? Market().NormalizePrice(sl_new) : _order.Ptr().GetStopLoss(),
            tp_valid && tp_new > 0 ? Market().NormalizePrice(tp_new) : _order.Ptr().GetTakeProfit());
        sresult.stops_invalid_sl += (int)sl_valid;
        sresult.stops_invalid_tp += (int)tp_valid;
      } else {
        sparams.trade.OrderMoveToHistory(_order.Ptr());
      }
    }
    sresult.ProcessLastError();
    return sresult;
  }

  /**
   * Process strategy's signals and orders.
   *
   * Call this method for every new bar.
   *
   * @return
   *   Returns StgProcessResult struct.
   */
  StgProcessResult Process() {
    sresult.last_error = ERR_NO_ERROR;
    ProcessSignals();
    ProcessOrders();
    return sresult;
  }

  /* State checkers */

  /**
   * Validate strategy's timeframe and parameters.
   *
   * @return
   *   Returns true when strategy params are valid, otherwise false.
   */
  bool IsValid() {
    return Object::IsValid(sparams.trade) && Object::IsValid(sparams.GetChart()) && sparams.GetChart().IsValidTf();
  }

  /**
   * Check state of the strategy.
   */
  bool IsEnabled() { return sparams.IsEnabled(); }

  /**
   * Check suspension status of the strategy.
   */
  bool IsSuspended() { return sparams.IsSuspended(); }

  /**
   * Check state of the strategy.
   */
  bool IsBoostEnabled() { return sparams.IsBoosted(); }

  /* Class getters */

  /**
   * Returns strategy's market class.
   */
  Market *Market() { return sparams.trade.Market(); }

  /**
   * Returns strategy's indicator data class.
   */
  Indicator *Data() { return sparams.data; }

  /**
   * Returns strategy's log class.
   */
  Log *Logger() { return sparams.logger.Ptr(); }

  /**
   * Returns handler to the strategy's trading class.
   */
  Trade *Trade() { return sparams.trade; }

  /**
   * Returns access to Chart information.
   */
  Chart *Chart() { return sparams.GetChart(); }

  /**
   * Returns handler to the strategy's indicator class.
   */
  Indicator *Indicator() { return sparams.data; }

  /* Struct getters */

  /**
   * Gets result of the last signal processing.
   */
  StgProcessResult GetProcessResult() { return sresult; }

  /* Getters */

  /**
   * Get strategy's name.
   */
  string GetName() { return name; }

  /**
   * Get strategy's ID.
   */
  virtual long GetId() { return sparams.id; }

  /**
   * Get strategy's weight.
   *
   * Note: Implementation of inherited method.
   */
  virtual double GetWeight() { return sparams.weight; }

  /**
   * Get strategy's magic number.
   */
  unsigned long GetMagicNo() { return sparams.magic_no; }

  /**
   * Get strategy's timeframe.
   */
  ENUM_TIMEFRAMES GetTf() { return sparams.GetChart().GetTf(); }

  /**
   * Get strategy's signal open method.
   */
  int GetSignalOpenMethod() { return sparams.signal_open_method; }

  /**
   * Get strategy's signal open level.
   */
  double GetSignalOpenLevel() { return sparams.signal_open_level; }

  /**
   * Get strategy's signal close method.
   */
  int GetSignalCloseMethod() { return sparams.signal_close_method; }

  /**
   * Get strategy's signal close level.
   */
  double GetSignalCloseLevel() { return sparams.signal_close_level; }

  /**
   * Get strategy's price limit method.
   */
  int GetPriceLimitMethod() { return sparams.signal_close_method; }

  /**
   * Get strategy's price limit level.
   */
  double GetPriceLimitLevel() { return sparams.signal_close_level; }

  /**
   * Get strategy's order open comment.
   */
  string GetOrderOpenComment(string _prefix = "", string _suffix = "") {
    return StringFormat("%s%s[%s];s:%gp%s", _prefix != "" ? _prefix + ": " : "", name, sparams.GetChart().TfToString(),
                        GetCurrSpread(), _suffix != "" ? "| " + _suffix : "");
  }

  /**
   * Get strategy's order close comment.
   */
  string GetOrderCloseComment(string _prefix = "", string _suffix = "") {
    return StringFormat("%s%s[%s];s:%gp%s", _prefix != "" ? _prefix + ": " : "", name, sparams.GetChart().TfToString(),
                        GetCurrSpread(), _suffix != "" ? "| " + _suffix : "");
  }

  /**
   * Get strategy orders currently open.
   */
  uint GetOrdersOpen() {
    // UpdateOrderStats(EA_STATS_TOTAL);
    // @todo
    return stats.orders_open;
  }

  /**
   * Get strategy's params.
   */
  StgParams GetParams() const { return sparams; }

  /**
   * Gets data.
   */
  Dict<string, double> *GetDataSD() { return ddata; }
  Dict<string, int> *GetDataSI() { return idata; }
  Dict<int, int> *GetDataII() { return iidata; }

  /* Statistics */

  /**
   * Gets strategy orders total opened.
   */
  uint GetOrdersTotal(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].orders_total;
  }

  /**
   * Gets strategy orders won.
   */
  uint GetOrdersWon(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].orders_won;
  }

  /**
   * Gets strategy orders lost.
   */
  uint GetOrdersLost(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].orders_lost;
  }

  /**
   * Gets strategy net profit.
   */
  double GetNetProfit(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].net_profit;
  }

  /**
   * Gets strategy gross profit.
   */
  double GetGrossProfit(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].gross_profit;
  }

  /**
   * Gets strategy gross loss.
   */
  double GetGrossLoss(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].gross_loss;
  }

  /**
   * Gets the average spread of the strategy (in pips).
   */
  double GetAvgSpread(ENUM_STRATEGY_STATS_PERIOD _period = EA_STATS_TOTAL) {
    UpdateOrderStats(_period);
    return stats_period[_period].avg_spread;
  }

  /* Setters */

  /**
   * Sets strategy's name.
   */
  void SetName(string _name) { name = _name; }

  /**
   * Sets strategy's ID.
   */
  void SetId(long _id) {
    sparams.id = _id;
    ((Object *)GetPointer(this)).SetId(_id);
  }

  /**
   * Sets strategy's weight.
   */
  void SetWeight(float _weight) { sparams.weight = _weight; }

  /**
   * Sets strategy's magic number.
   */
  void SetMagicNo(unsigned long _magic_no) { sparams.magic_no = _magic_no; }

  /**
   * Sets strategy's signal open method.
   */
  void SetSignalOpenMethod(int _method) { sparams.signal_open_method = _method; }

  /**
   * Sets strategy's signal open level.
   */
  void SetSignalOpenLevel(float _level) { sparams.signal_open_level = _level; }

  /**
   * Sets strategy's signal close method.
   */
  void SetSignalCloseMethod(int _method) { sparams.signal_close_method = _method; }

  /**
   * Sets strategy's signal close level.
   */
  void SetSignalCloseLevel(float _level) { sparams.signal_close_level = _level; }

  /**
   * Sets strategy's price limit method.
   */
  void SetPriceLimitMethod(int _method) { sparams.signal_close_method = _method; }

  /**
   * Sets strategy's price limit level.
   */
  void SetPriceLimitLevel(float _level) { sparams.signal_close_level = _level; }

  /**
   * Enable/disable the strategy.
   */
  void Enabled(bool _enable = true) { sparams.Enabled(_enable); }

  /**
   * Suspend the strategy.
   */
  void Suspended(bool _suspended = true) { sparams.Suspended(_suspended); }

  /**
   * Sets initial data.
   */
  void SetData(Dict<string, double> *_ddata) {
    delete ddata;
    ddata = _ddata;
  }
  void SetData(Dict<string, int> *_idata) {
    delete idata;
    idata = _idata;
  }
  void SetData(Dict<int, int> *_iidata) {
    delete iidata;
    iidata = _iidata;
  }

  /* Static setters */

  /**
   * Sets initial params based on the timeframe.
   */
  template <typename T>
  static void SetParamsByTf(T &_result, ENUM_TIMEFRAMES _tf, T &_m1, T &_m5, T &_m15, T &_m30, T &_h1, T &_h4, T &_h8) {
    switch (_tf) {
      case PERIOD_M1: {
        _result = _m1;
        break;
      }
      case PERIOD_M5: {
        _result = _m5;
        break;
      }
      case PERIOD_M15: {
        _result = _m15;
        break;
      }
      case PERIOD_M30: {
        _result = _m30;
        break;
      }
      case PERIOD_H1: {
        _result = _h1;
        break;
      }
      case PERIOD_H4: {
        _result = _h4;
        break;
      }
      case PERIOD_H8: {
        _result = _h8;
        break;
      }
    }
  }

  /* Calculation methods */

  /**
   * Get lot size factor.
   */
  double UpdateLotSizeFactor() { return 1.0; }

  /**
   * Update order stat variables.
   */
  void UpdateOrderStats(ENUM_STRATEGY_STATS_PERIOD _period) {
    // @todo: Implement support for _period.
    static datetime _last_update = TimeCurrent();
    if (_last_update > TimeCurrent() - sparams.refresh_time) {
      return;  // Do not update too often.
    }
    unsigned int _total = 0, _won = 0, _lost = 0, _open = 0;
    int i;
    double _gross_profit = 0, _gross_loss = 0, _net_profit = 0, _order_profit = 0;
    datetime _order_datetime;
    for (i = 0; i < Trade::OrdersTotal(); i++) {
      // @todo: Select order.
      if (Market().GetSymbol() == Order::OrderSymbol() && sparams.magic_no == Order::OrderMagicNumber()) {
        _total++;
        _order_profit = Order::OrderProfit() - Order::OrderCommission() - Order::OrderSwap();
        _net_profit += _order_profit;
        if (Order::OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
          _open++;
        } else {
          _order_datetime = (datetime)OrderGetInteger(ORDER_TIME_DONE);
          // s_daily_net_profit += @todo;
          // s_weekly_net_profit += @todo;
          // s_monhtly_net_profit += @todo;
          if (_order_profit > 0) {
            _won++;
            _gross_profit += _order_profit;
          } else {
            _lost++;
            _gross_loss += _order_profit;
          }
        }
      }
    }
    // stats.orders_open = _open;
    stats_period[_period].orders_won = _won;
    stats_period[_period].orders_lost = _lost;
    stats_period[_period].orders_total = _total;
    stats_period[_period].net_profit = _net_profit;
    stats_period[_period].gross_profit = _gross_loss;
    stats_period[_period].gross_loss = _gross_profit;
    // stats_period[_period].profit_factor = _profit_factor;
    _last_update = TimeCurrent();
  }

  /**
   * Get profit factor of the strategy.
   */
  double GetProfitFactor() {
    // @todo
    return 0.0;
  }

  /**
   * Get current spread (in pips).
   */
  double GetCurrSpread() { return sparams.GetChart().GetSpreadInPips(); }

  /**
   * Convert timeframe constant to index value.
   */
  uint TfToIndex(ENUM_TIMEFRAMES _tf) { return Chart::TfToIndex(_tf); }

  /**
   * Class constructor.
   */
  /*
  bool Strategy() {

    // Trading variables.
    s_lot_size = si_lot_size;
    s_lot_factor = GetLotSizeFactor();
    s_avg_spread = GetCurrSpread();
    s_tp_max = 0;
    s_sl_max = 0;

    // Statistics variables.
    s_orders_open         = GetOrdersOpen();
    s_orders_total        = GetOrdersTotal();
    s_orders_won          = GetOrdersWon();
    s_orders_lost         = GetOrdersLost();
    s_profit_factor       = GetProfitFactor();
    s_avg_spread          = GetAvgSpread();
    s_total_net_profit    = GetTotalNetProfit();
    s_total_gross_profit  = GetTotalGrossProfit();
    s_total_gross_loss    = GetTotalGrossLoss();
    s_daily_net_profit    = GetDailyNetProfit();
    s_weekly_net_profit   = GetWeeklyNetProfit();
    s_monhtly_net_profit  = GetMonthlyNetProfit();

    // Other variables.
    s_refresh_time        = 10;
  }
  */

  /**
   * Initialize strategy.
   */
  bool Init() {
    if (!sparams.GetChart().IsValidTf()) {
      Logger().Warning(StringFormat("Could not initialize %s since %s timeframe is not active!", GetName(),
                                    sparams.GetChart().TfToString()),
                       __FUNCTION__ + ": ");
      return false;
    }
    return true;
  }

  /* Orders methods */

  /**
   * Open an order.
   */
  bool OrderOpen(ENUM_ORDER_TYPE _cmd, double _lot_size = 0, string _comment = "") {
    bool _result = false;
    MqlTradeRequest _request = {0};
    _request.action = TRADE_ACTION_DEAL;
    _request.comment = _comment;
    _request.deviation = 10;
    _request.magic = GetMagicNo();
    _request.price = Market().GetOpenOffer(_cmd);
    _request.symbol = Market().GetSymbol();
    _request.type = _cmd;
    _request.type_filling = Order::GetOrderFilling(_request.symbol);
    _request.volume = _lot_size > 0 ? _lot_size : fmax(sparams.GetLotSize(), Market().GetVolumeMin());
    ResetLastError();
    Order *_order = new Order(_request);
    _result = sparams.trade.OrderAdd(_order);
    if (_result) {
      OnOrderOpen(_order);
    }
    return _result;
  }

  /* Conditions and actions */

  /**
   * Checks for Strategy condition.
   *
   * @param ENUM_STRATEGY_CONDITION _cond
   *   Strategy condition.
   * @return
   *   Returns true when the condition is met.
   */
  bool Condition(ENUM_STRATEGY_CONDITION _cond) {
    switch (_cond) {
      case STRAT_COND_IS_ENABLED:
        return sparams.IsEnabled();
      case STRAT_COND_IS_SUSPENDED:
        return sparams.IsSuspended();
      default:
        Logger().Error(StringFormat("Invalid EA condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }

  /**
   * Execute Strategy action.
   *
   * @param ENUM_STRATEGY_ACTION _action
   *   Strategy action to execute.
   * @param MqlParam _args
   *   Trade action arguments.
   * @return
   *   Returns true when the action has been executed successfully.
   */
  bool ExecuteAction(ENUM_STRATEGY_ACTION _action, MqlParam &_args[]) {
    bool _result = true;
    switch (_action) {
      case STRAT_ACTION_DISABLE:
        sparams.Enabled(false);
        return true;
      case STRAT_ACTION_ENABLE:
        sparams.Enabled(true);
        return true;
      case STRAT_ACTION_SUSPEND:
        sparams.Suspended(true);
        return true;
      case STRAT_ACTION_UNSUSPEND:
        sparams.Suspended(false);
        return true;
      default:
        Logger().Error(StringFormat("Invalid Strategy action: %s!", EnumToString(_action), __FUNCTION_LINE__));
        return false;
    }
    return _result;
  }
  bool ExecuteAction(ENUM_STRATEGY_ACTION _action) {
    MqlParam _args[] = {};
    return Strategy::ExecuteAction(_action, _args);
  }

  /* Printers methods */

  /**
   * Prints strategy's details.
   */
  string ToString() { return StringFormat("%s: %s", GetName(), sparams.ToString()); }

  /* Virtual methods */

  /**
   * Event on strategy's order open.
   *
   * @param
   *   _order Order Instance of order which got opened.
   */
  virtual void OnOrderOpen(const Order &_order) {
    if (Logger().GetLevel() >= V_INFO) {
      Logger().Info(_order.ToString(), (string) _order.GetTicket());
    }
  }

  /**
   * Filters strategy's market tick.
   *
   * @param
   *   _method - signal method to filter a tick (bitwise AND operation)
   *
   * @result bool
   *   Returns true when tick should be processed, otherwise false.
   */
  virtual bool TickFilter(const MqlTick &_tick, const int _method) {
    static MqlTick _last_tick = {0};
    bool _res = _method == 0;
    if (_method != 0) {
      if (METHOD(_method, 0)) {  // 1
        // Process open price ticks.
        _res |= _last_tick.time < sparams.GetChart().GetBarTime();
      }
      if (METHOD(_method, 1)) {  // 2
        // Process close price ticks.
        _res |= (sparams.GetChart().GetClose() == _tick.bid);
      }
      if (METHOD(_method, 2)) {  // 4
        // Process low and high ticks.
        _res |= _tick.bid >= sparams.GetChart().GetHigh() || _tick.bid <= sparams.GetChart().GetLow();
      }
      if (METHOD(_method, 3)) {  // 8
        // Process only unique ticks (avoid duplicates).
        _res |= _tick.bid != _last_tick.bid && _tick.ask != _last_tick.ask;
      }
      if (METHOD(_method, 4)) {  // 16
        // Process ticks in the middle of the bar.
        _res |= (sparams.GetChart().iTime() + (sparams.GetChart().GetPeriodSeconds() / 2)) == TimeCurrent();
      }
      if (METHOD(_method, 5)) {  // 32
        // Process on every minute.
        _res |= TimeCurrent() % 60 == 0;
      }
      if (METHOD(_method, 6)) {  // 64
        // Process every 10th of the bar.
        _res |= TimeCurrent() % (int)(sparams.GetChart().GetPeriodSeconds() / 10) == 0;
      }
      if (METHOD(_method, 7)) {  // 128
        // Process every second.
        _res |= (sparams.GetChart().iTime() == TimeCurrent());
      }
    }
    _last_tick = _tick;
    return _res;
  }
  virtual bool TickFilter(const MqlTick &_tick) { return TickFilter(_tick, sparams.tick_filter_method); }

  /**
   * Checks strategy's trade open signal.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _method - signal method to open a trade (bitwise AND operation)
   *   _level  - signal level to open a trade (bitwise AND operation)
   *
   * @result bool
   *   Returns true when trade should be opened, otherwise false.
   */
  virtual bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f) = NULL;

  /**
   * Checks strategy's trade open signal additional filter.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _method - signal method to filter a trade (bitwise AND operation)
   *
   * @result bool
   *   Returns true when trade should be opened, otherwise false.
   */
  virtual bool SignalOpenFilter(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = true;
    if (_method != 0) {
      if (METHOD(_method, 0)) _result &= !sparams.trade.HasBarOrder(_cmd);
      // if (METHOD(_method, 0)) _result &= Trade().IsTrend(_cmd);
      // if (METHOD(_method, 1)) _result &= Trade().IsPivot(_cmd);
      // if (METHOD(_method, 2)) _result &= Trade().IsPeakHours(_cmd);
      // if (METHOD(_method, 3)) _result &= Trade().IsRoundNumber(_cmd);
      // if (METHOD(_method, 4)) _result &= Trade().IsHedging(_cmd);
      // if (METHOD(_method, 5)) _result &= Trade().IsPeakBar(_cmd);
    }
    return _result;
  }

  /**
   * Gets strategy's lot size boost for the open signal.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _method - boost method (bitwise AND operation)
   *
   * @result double
   *   Returns lot size multiplier (0.0 = normal, 0.1 = 1/10, 1.0 = normal, 2.0 = 2x).
   *   Range: between 0.0 and (max_risk * 2).
   */
  virtual float SignalOpenBoost(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    float _result = 1.0;
    if (_method != 0) {
      // if (METHOD(_method, 0)) if (Trade().IsTrend(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 1)) if (Trade().IsPivot(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 2)) if (Trade().IsPeakHours(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 3)) if (Trade().IsRoundNumber(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 4)) if (Trade().IsHedging(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 5)) if (Trade().IsPeakBar(_cmd)) _result *= 1.1;
    }
    return _result;
  }

  /**
   * Checks strategy's trade close signal.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _method - signal method to close a trade (bitwise AND operation)
   *   _level  - signal level to close a trade (bitwise AND operation)
   *
   * @result bool
   *   Returns true when trade should be closed, otherwise false.
   */
  virtual bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level);
  }

  /**
   * Gets price limit value.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _mode   - mode for price limit value (ORDER_TYPE_TP or ORDER_TYPE_SL)
   *   _method - method to calculate the price limit
   *   _level  - level value to use for calculation
   *
   * @result bool
   *   Returns current stop loss value when _mode is ORDER_TYPE_SL and profit take when _mode is ORDER_TYPE_TP.
   */
  virtual float PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0,
                           float _level = 0.0f) = NULL;
};
#endif  // STRATEGY_MQH

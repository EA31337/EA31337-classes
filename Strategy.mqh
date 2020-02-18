//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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
#include "Condition.mqh"
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

/**
 * Implements strategy class.
 */
class Strategy;

struct StgParams {
  // Strategy config parameters.
  bool             enabled;              // State of the strategy (whether enabled or not).
  bool             suspended;            // State of the strategy (whether suspended or not)
  bool             boost;                // State of the boost feature (to increase lot size).
  long             id;                   // Identification number of the strategy.
  unsigned long    magic_no;             // Magic number of the strategy.
  double           weight;               // Weight of the strategy.
  int              signal_open_method;   // Signal open method.
  double           signal_open_level;    // Signal open level.
  int              signal_open_filter;   // Signal open filter method.
  int              signal_open_boost;    // Signal open boost method (for lot size increase).
  int              signal_close_method;  // Signal close method.
  double           signal_close_level;   // Signal close level.
  int              price_limit_method;   // Price limit method.
  double           price_limit_level;    // Price limit level.
  double           lot_size;             // Lot size to trade.
  double           lot_size_factor;      // Lot size multiplier factor.
  double           max_risk;             // Maximum risk to take (1.0 = normal, 2.0 = 2x).
  double           max_spread;           // Maximum spread to trade (in pips).
  int              tp_max;               // Hard limit on maximum take profit (in pips).
  int              sl_max;               // Hard limit on maximum stop loss (in pips).
  datetime         refresh_time;         // Order refresh frequency (in sec).
  Chart            *chart;               // Pointer to Chart class.
  Log              *logger;              // Pointer to Log class.
  Trade            *trade;               // Pointer to Trade class.
  Indicator        *data;                // Pointer to Indicator class.
  Strategy         *sl, *tp;             // Pointers to Strategy class (stop-loss and profit-take).
  // Constructor.
  StgParams(Trade *_trade = NULL, Indicator *_data = NULL, Strategy *_sl = NULL, Strategy *_tp = NULL) :
    trade(_trade),
    chart(Object::IsValid(_trade) ? _trade.Chart() : NULL),
    data(_data),
    enabled(true),
    suspended(false),
    boost(true),
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
    lot_size(Object::IsValid(chart) ? chart.GetVolumeMin() : 0),
    lot_size_factor(1.0),
    max_risk(1.0),
    max_spread(0.0),
    tp_max(0),
    sl_max(0),
    refresh_time(0),
    logger(new Log)
    {}
  // Deconstructor.
  ~StgParams() {}
  // Struct methods.
  void SetId(long _id) { id = _id; }
  void SetMagicNo(unsigned long _mn) { magic_no = _mn; }
  void SetTf(ENUM_TIMEFRAMES _tf, string _symbol = NULL) {
    trade = new Trade(_tf, _symbol);
  }
  void SetSignals(int _open_method, double _open_level, int _open_filter, int _open_boost, int _close_method, double _close_level)
  {
    signal_open_method = _open_method;
    signal_open_level = _open_level;
    signal_open_filter = _open_filter;
    signal_open_boost = _open_boost;
    signal_close_method = _close_method;
    signal_close_level = _close_level;
  }
  void SetPriceLimits(int _method, double _level) {
    price_limit_method = _method;
    price_limit_level = _level;
  }
  void SetMaxSpread(double _spread) {
    max_spread = _spread;
  }
  void SetMaxRisk(double _risk) {
    max_risk = _risk;
  }
  void Enabled(bool _is_enabled) { enabled = _is_enabled; };
  void Suspended(bool _is_suspended) { suspended = _is_suspended; };
  void Boost(bool _is_boosted) { boost = _is_boosted; };
  void DeleteObjects() {
    delete data;
    delete sl;
    delete tp;
    delete chart;
    delete logger;
    delete trade;
  }
 string ToString() {
   return StringFormat("Enabled:%s;Suspended:%s;Id:%d,MagicNo:%d;Weight:%.2f;" +
     "SOM:%d,SOL:%.2f;" +
     "SCM:%d,SCL:%.2f;" +
     "PLM:%d,PLL:%.2f;" +
     "LS:%.2f(Factor:%.2f);MS:%.2f;",
     // @todo: "Data:%s;SL/TP-Strategy:%s/%s",
     enabled ? "Yes" : "No",
     suspended ? "Yes" : "No",
     id, magic_no, weight,
     signal_open_method, signal_open_level,
     signal_close_method, signal_close_level,
     price_limit_method, price_limit_level,
     lot_size, lot_size_factor, max_spread
     // @todo: data, sl, tp
     );
 }
};

// Defines struct for individual strategy's param values.
struct Stg_Params {
  string symbol;
  ENUM_TIMEFRAMES tf;
  Stg_Params() : symbol(_Symbol), tf((ENUM_TIMEFRAMES) _Period) {}
};

// Defines struct to store results for signal processing.
struct StgProcessResult {
  unsigned int  pos_closed;  // Number of positions closed.
  unsigned int  pos_opened;  // Number of positions opened.
  unsigned int  pos_updated; // Number of positions updated.
  unsigned int  last_error;  // Last error code.
  StgProcessResult()
    : pos_closed(0), pos_opened(0), pos_updated(0), last_error(ERR_NO_ERROR)
    {}
};

class Strategy : public Object {

  // Enums.
  enum ENUM_OPEN_METHOD {
    OPEN_METHOD1  =    1, // Method #1.
    OPEN_METHOD2  =    2, // Method #2.
    OPEN_METHOD3  =    4, // Method #3.
    OPEN_METHOD4  =    8, // Method #4.
    OPEN_METHOD5  =   16, // Method #5.
    OPEN_METHOD6  =   32, // Method #6.
    OPEN_METHOD7  =   64, // Method #7.
    OPEN_METHOD8  =  128, // Method #8.
    OPEN_METHOD9  =  256, // Method #9.
    OPEN_METHOD10 =  512, // Method #10.
    OPEN_METHOD11 = 1024, // Method #11.
    OPEN_METHOD12 = 2048  // Method #12.
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
    uint    orders_open;        // Number of current opened orders.
    uint    errors;             // Count reported errors.
  } stats;

  // Strategy statistics per period.
  struct StgStatsPeriod {
    // Statistics variables.
    uint    orders_total;       // Number of total opened orders.
    uint    orders_won;         // Number of total won orders.
    uint    orders_lost;        // Number of total lost orders.
    double  profit_factor;      // Profit factor.
    double  avg_spread;         // Average spread.
    double  net_profit;         // Total net profit.
    double  gross_profit;       // Total gross profit.
    double  gross_loss;         // Total gross profit.
  } stats_period[FINAL_ENUM_STRATEGY_STATS_PERIOD];

  protected:

  // Base variables.
  string name;
  // Other variables.
  int    filter_method[];   // Filter method to consider the trade.
  int    open_condition[];  // Open conditions.
  int    close_condition[]; // Close conditions.
  // Date time variables.
  // Includes.
  // Class variables.

  public:

  /**
   * Class constructor.
   */
  Strategy(const StgParams &_sparams, string _name = "")
    :
    ddata(new Dict<string, double>),
    idata(new Dict<string, int>),
    iidata(new Dict<int, int>)
  {
    // Assign struct.
    sparams.DeleteObjects();
    sparams = _sparams;

    // Initialize variables.
    name = _name;

    // Link log instances.
    sparams.logger.Link(sparams.trade.Logger());

    // Statistics variables.
    UpdateOrderStats(EA_STATS_DAILY);
    UpdateOrderStats(EA_STATS_WEEKLY);
    UpdateOrderStats(EA_STATS_MONTHLY);
    UpdateOrderStats(EA_STATS_TOTAL);
  }

  /**
   * Class deconstructor.
   */
  ~Strategy() {
    sparams.DeleteObjects();
    delete ddata;
    delete idata;
    delete iidata;
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
    StgProcessResult _result;
    double _boost_factor = 1.0;
    _result.last_error = ERR_NO_ERROR;
    if (SignalOpen(ORDER_TYPE_BUY, sparams.signal_open_method, sparams.signal_open_level)
        && SignalOpenFilter(ORDER_TYPE_BUY, sparams.signal_open_filter)) {
      _boost_factor = sparams.boost ? SignalOpenBoost(ORDER_TYPE_BUY, sparams.signal_open_boost) : GetLotSize();
      if (OrderOpen(ORDER_TYPE_BUY, _boost_factor, GetOrderOpenComment("SignalOpen"))) {
        _result.pos_opened++;
      }
      else {
        _result.last_error = fmax(_result.last_error, Terminal::GetLastError());
      }
    }
    if (SignalOpen(ORDER_TYPE_SELL, sparams.signal_open_method, sparams.signal_open_level)
        && SignalOpenFilter(ORDER_TYPE_SELL, sparams.signal_open_filter)) {
      _boost_factor = sparams.boost ? SignalOpenBoost(ORDER_TYPE_SELL, sparams.signal_open_boost) : GetLotSize();
      if (OrderOpen(ORDER_TYPE_SELL, _boost_factor, GetOrderOpenComment("SignalOpen"))) {
        _result.pos_opened++;
      }
      else {
        _result.last_error = fmax(_result.last_error, Terminal::GetLastError());
      }
    }
    if (SignalClose(ORDER_TYPE_BUY, sparams.signal_close_method, sparams.signal_close_level) && Trade().GetOrdersOpened() > 0) {
      if (Trade().OrderCloseViaCmd(ORDER_TYPE_BUY, GetOrderCloseComment("SignalClose")) > 0) {
        _result.pos_closed++;
      } else {
        _result.last_error = fmax(_result.last_error, Terminal::GetLastError());
      }
    }
    if (SignalClose(ORDER_TYPE_SELL, sparams.signal_close_method, sparams.signal_close_level) && Trade().GetOrdersOpened() > 0) {
      if (Trade().OrderCloseViaCmd(ORDER_TYPE_SELL, GetOrderCloseComment("SignalClose")) > 0) {
        _result.pos_closed++;
      } else {
        _result.last_error = fmax(_result.last_error, Terminal::GetLastError());
      }
    }
    sresult = _result;
    return _result;
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
    StgProcessResult _result;
    Collection *_orders = Trade().Orders();
    Order *_order;
    for (_order = _orders.GetFirstItem(); Object::IsValid(_order); _order = _orders.GetNextItem()) {
      sl_new = PriceLimit(_order.OrderType(), ORDER_TYPE_SL, sparams.price_limit_method, sparams.price_limit_level);
      tp_new = PriceLimit(_order.OrderType(), ORDER_TYPE_TP, sparams.price_limit_method, sparams.price_limit_level);
      sl_new = Market().NormalizeSLTP(sl_new, _order.GetRequest().type, ORDER_SL);
      tp_new = Market().NormalizeSLTP(tp_new, _order.GetRequest().type, ORDER_TP);
      sl_valid = Trade().ValidSL(sl_new, _order.GetRequest().type);
      tp_valid = Trade().ValidTP(tp_new, _order.GetRequest().type);
      _order.OrderModify(
        sl_valid && sl_new > 0 ? Market().NormalizePrice(sl_new) : _order.GetStopLoss(),
        tp_valid && tp_new > 0 ? Market().NormalizePrice(tp_new) : _order.GetTakeProfit()
      );
    }
    return _result;
  }

  /* State checkers */

  /**
   * Validate strategy's timeframe and parameters.
   *
   * @return
   *   Returns true when strategy params are valid, otherwise false.
   */
  bool IsValid() {
    return Object::IsValid(sparams.trade) && Object::IsValid(sparams.chart) && sparams.chart.IsValidTf();
  }

  /**
   * Check state of the strategy.
   */
  bool IsEnabled() {
    return sparams.enabled;
  }

  /**
   * Check suspension status of the strategy.
   */
  bool IsSuspended() {
    return sparams.suspended;
  }

  /**
   * Check state of the strategy.
   */
  bool IsBoostEnabled() {
    return sparams.boost;
  }

  /* Class getters */

  /**
   * Returns strategy's market class.
   */
  Market *Market() {
    return sparams.trade.Market();
  }

  /**
   * Returns strategy's indicator data class.
   */
  Indicator *Data() {
    return sparams.data;
  }

  /**
   * Returns strategy's log class.
   */
  Log *Logger() {
    return sparams.logger;
  }

  /**
   * Returns handler to the strategy's trading class.
   */
  Trade *Trade() {
    return sparams.trade;
  }

  /**
   * Returns access to Chart information.
   */
  Chart *Chart() {
    return sparams.chart;
  }

  /**
   * Returns handler to the strategy's indicator class.
   */
  Indicator *Indicator() {
    return sparams.data;
  }

  /* Struct getters */

  /**
   * Gets result of the last signal processing.
   */
  StgProcessResult GetProcessResult() {
    return sresult;
  }

  /* Getters */

  /**
   * Get strategy's name.
   */
  string GetName() {
    return name;
  }

  /**
   * Get strategy's ID.
   */
  long GetId() {
    return sparams.id;
  }

  /**
   * Get strategy's weight.
   *
   * Note: Implementation of inherited method.
   */
  virtual double GetWeight() {
    return sparams.weight;
  }

  /**
   * Get strategy's magic number.
   */
  unsigned long GetMagicNo() {
    return sparams.magic_no;
  }

  /**
   * Get strategy's timeframe.
   */
  ENUM_TIMEFRAMES GetTf() {
    return sparams.chart.GetTf();
  }

  /**
   * Get strategy's signal open method.
   */
  int GetSignalOpenMethod() {
    return sparams.signal_open_method;
  }

  /**
   * Get strategy's signal open level.
   */
  double GetSignalOpenLevel() {
    return sparams.signal_open_level;
  }

  /**
   * Get strategy's signal close method.
   */
  int GetSignalCloseMethod() {
    return sparams.signal_close_method;
  }

  /**
   * Get strategy's signal close level.
   */
  double GetSignalCloseLevel() {
    return sparams.signal_close_level;
  }

  /**
   * Get strategy's price limit method.
   */
  int GetPriceLimitMethod() {
    return sparams.signal_close_method;
  }

  /**
   * Get strategy's price limit level.
   */
  double GetPriceLimitLevel() {
    return sparams.signal_close_level;
  }

  /**
   * Get strategy's order open comment.
   */
  string GetOrderOpenComment(string _prefix = "", string _suffix = "") {
    return StringFormat("%s%s[%s];s:%gp%s",
      _prefix != "" ? _prefix + ": " : "",
      name, sparams.chart.TfToString(), GetCurrSpread(),
      _suffix != "" ? "| " + _suffix : ""
    );
  }

  /**
   * Get strategy's order close comment.
   */
  string GetOrderCloseComment(string _prefix = "", string _suffix = "") {
    return StringFormat("%s%s[%s];s:%gp%s",
      _prefix != "" ? _prefix + ": " : "",
      name, sparams.chart.TfToString(), GetCurrSpread(),
      _suffix != "" ? "| " + _suffix  : ""
    );
  }

  /**
   * Get strategy's lot size.
   */
  double GetLotSize() {
    return sparams.lot_size * sparams.lot_size_factor;
  }

  /**
   * Get strategy's lot size factor.
   */
  double GetLotSizeFactor() {
    return sparams.lot_size_factor;
  }

  /**
   * Get strategy's max risk.
   */
  double GetMaxRisk() {
    return sparams.max_risk;
  }

  /**
   * Get strategy's max spread.
   */
  double GetMaxSpread() {
    return sparams.max_spread;
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
   * Gets data.
   */
  Dict<string, double> *GetDataSD() {
    return ddata;
  }
  Dict<string, int> *GetDataSI() {
    return idata;
  }
  Dict<int, int> *GetDataII() {
    return iidata;
  }

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
  void SetName(string _name) {
    name = _name;
  }

  /**
   * Sets strategy's ID.
   */
  void SetId(long _id) {
    sparams.id = _id;
    ((Object *) GetPointer(this)).SetId(_id);
  }

  /**
   * Sets strategy's weight.
   */
  void SetWeight(double _weight) {
    sparams.weight = _weight;
  }

  /**
   * Sets strategy's magic number.
   */
  void SetMagicNo(ulong _magic_no) {
    sparams.magic_no = _magic_no;
  }

  /**
   * Sets strategy's signal open method.
   */
  void SetSignalOpenMethod(int _method) {
    sparams.signal_open_method = _method;
  }

  /**
   * Sets strategy's signal open level.
   */
  void  SetSignalOpenLevel(double _level) {
    sparams.signal_open_level = _level;
  }

  /**
   * Sets strategy's signal close method.
   */
  void SetSignalCloseMethod(int _method) {
    sparams.signal_close_method = _method;
  }

  /**
   * Sets strategy's signal close level.
   */
  void SetSignalCloseLevel(double _level) {
    sparams.signal_close_level = _level;
  }

  /**
   * Sets strategy's price limit method.
   */
  void SetPriceLimitMethod(int _method) {
    sparams.signal_close_method = _method;
  }

  /**
   * Sets strategy's price limit level.
   */
  void SetPriceLimitLevel(double _level) {
    sparams.signal_close_level = _level;
  }

  /**
   * Enable/disable the strategy.
   */
  void Enabled(bool _enable = true) {
    sparams.enabled = _enable;
  }

  /**
   * Suspend the strategy.
   */
  void Suspended(bool _suspended = true) {
    sparams.suspended = _suspended;
  }

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
  static void SetParamsByTf(T &_result, ENUM_TIMEFRAMES _tf,
                            T &_m1, T &_m5, T &_m15, T &_m30,
                            T &_h1, T &_h4, T &_h8) {
    switch (_tf) {
      case PERIOD_M1: { _result = _m1; break; }
      case PERIOD_M5: { _result = _m5; break; }
      case PERIOD_M15: { _result = _m15; break; }
      case PERIOD_M30: { _result = _m30; break; }
      case PERIOD_H1: { _result = _h1; break; }
      case PERIOD_H4: { _result = _h4; break; }
      case PERIOD_H8: { _result = _h8; break; }
    }
  }

  /* Calculation methods */

  /**
   * Get lot size factor.
   */
  double UpdateLotSizeFactor() {
    return 1.0;
  }

  /**
   * Update order stat variables.
   */
  void UpdateOrderStats(ENUM_STRATEGY_STATS_PERIOD _period) {
    // @todo: Implement support for _period.
    static datetime _last_update = TimeCurrent();
    if (_last_update > TimeCurrent() - sparams.refresh_time) {
      return; // Do not update too often.
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
          _order_datetime = (datetime) OrderGetInteger(ORDER_TIME_DONE);
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
    stats_period[_period].gross_loss   = _gross_profit;
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
  double GetCurrSpread() {
    return sparams.chart.GetSpreadInPips();
  }

  /**
   * Convert timeframe constant to index value.
   */
  uint TfToIndex(ENUM_TIMEFRAMES _tf) {
    return Chart::TfToIndex(_tf);
  }

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
    if (!sparams.chart.IsValidTf()) {
      Logger().Warning(StringFormat("Could not initialize %s since %s timeframe is not active!", GetName(), sparams.chart.TfToString()), __FUNCTION__ + ": ");
      return false;
    }
    return true;
  }

  /* Orders methods */

  /**
   * Open an order.
   */
  bool OrderOpen(ENUM_ORDER_TYPE _cmd, double _lot_size = 0, string _comment = "") {
    MqlTradeRequest _request = {0};
    _request.action = TRADE_ACTION_DEAL;
    _request.comment = _comment;
    _request.deviation = 10;
    _request.magic = GetMagicNo();
    _request.price = Market().GetOpenOffer(_cmd);
    _request.symbol = Market().GetSymbol();
    _request.type = _cmd;
    _request.type_filling = SymbolInfo::GetFillingMode(_request.symbol);
    _request.volume = _lot_size > 0 ? _lot_size : GetLotSize();
    return Trade().OrderAdd(new Order(_request));
  }

  /* Printers methods */

  /**
   * Prints strategy's details.
   */
  string ToString() {
    return
      StringFormat("%s: %s",
        GetName(), sparams.ToString()
      );
  }

  /* Virtual methods */

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
  virtual bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) = NULL;

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
  virtual bool SignalOpenFilter(ENUM_ORDER_TYPE _cmd, int _method = 0) = NULL;

  /**
   * Gets strategy's lot size boost for the open signal (when enabled).
   *
   * @param
   *   _cmd    - type of trade order command
   *   _method - boost method (bitwise AND operation)
   *
   * @result double
   *   Returns lot size multiplier (0.0 = normal, 0.1 = 1/10, 1.0 = normal, 2.0 = 2x).
   *   Range: between 0.0 and (max_risk * 2).
   */
  virtual double SignalOpenBoost(ENUM_ORDER_TYPE _cmd, int _method = 0) = NULL;

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
  virtual bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) = NULL;

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
  virtual double PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, double _level = 0.0) = NULL;

};
#endif // STRATEGY_MQH

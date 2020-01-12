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
  #ifdef __MQLBUILD__
    #define INPUT extern static
  #else
    #define INPUT extern
  #endif
#else
#define INPUT static
#endif

// Defines modes for price limit values (such as Take Profit or Stop Loss).
enum ENUM_STG_PRICE_LIMIT_MODE {
  LIMIT_VALUE_PROFIT,
  LIMIT_VALUE_STOP
};

/**
 * Implements strategy class.
 */
class Strategy;

struct StgParams {
  // Strategy config parameters.
  bool             enabled;              // State of the strategy (enabled or disabled).
  bool             suspended;            // State of the strategy.
  long             id;                   // Identification number of the strategy.
  unsigned long    magic_no;             // Magic number of the strategy.
  double           weight;               // Weight of the strategy.
  int              signal_open_method;   // Signal open method.
  double           signal_open_level;    // Signal open level.
  int              signal_close_method;  // Signal close method.
  double           signal_close_level;   // Signal close level.
  int              price_limit_method;   // Price limit method.
  double           price_limit_level;    // Price limit level.
  double           lot_size;             // Lot size to trade.
  double           lot_size_factor;      // Lot size multiplier factor.
  double           max_spread;           // Maximum spread to trade (in pips).
  int              tp_max;               // Hard limit on maximum take profit (in pips).
  int              sl_max;               // Hard limit on maximum stop loss (in pips).
  datetime         refresh_time;         // Order refresh frequency (in sec).
  Log              *logger;              // Pointer to Log class.
  Trade            *trade;               // Pointer to Trade class.
  Indicator        *data;                // Pointer to Indicator class.
  Strategy         *sl, *tp;             // Pointers to Strategy class (stop-loss and profit-take).
  // Constructor.
  StgParams(Trade *_trade = NULL, Indicator *_data = NULL, Strategy *_sl = NULL, Strategy *_tp = NULL) :
    trade(_trade),
    data(_data),
    enabled(true),
    suspended(false),
    magic_no(rand()),
    weight(0),
    signal_open_method(0),
    signal_open_level(0),
    signal_close_method(0),
    signal_close_level(0),
    price_limit_method(0),
    price_limit_level(0),
    lot_size(0),
    lot_size_factor(1.0),
    max_spread(0),
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
  void SetSignals(int _open_method, double _open_level, int _close_method, double _close_level)
  {
    signal_open_method = _open_method;
    signal_open_level = _open_level;
    signal_close_method = _close_method;
    signal_close_level = _close_level;
  }
  void SetPriceLimits(int _method, double _level) {
    price_limit_method = _method;
    price_limit_level = _level;
  }
 void SetMaxSpread(double _max_spread) {
   max_spread = _max_spread;
 }
 void Enabled(bool _enabled) { enabled = _enabled; };
 void Suspended(bool _suspended) { suspended = _suspended; };
 void DeleteObjects() {
   delete data;
   delete sl;
   delete tp;
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
  unsigned int  pos_updated; // Number of positions opened.
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
  /*
  struct StgTradeRequest {
    Strategy                     *strategy;         // Strategy pointer.
    ENUM_TRADE_REQUEST_ACTIONS    action;           // Trade operation type.
    ulong                         magic;            // Expert Advisor ID (magic number).
    ulong                         order;            // Order ticket.
    String                       *symbol;           // Trade symbol.
    double                        volume;           // Requested volume for a deal in lots.
    double                        price;            // Price.
    double                        stoplimit;        // StopLimit level of the order.
    double                        sl;               // Stop Loss level of the order.
    double                        tp;               // Take Profit level of the order.
    ulong                         deviation;        // Maximal possible deviation from the requested price.
    ENUM_ORDER_TYPE               type;             // Order type.
    ENUM_ORDER_TYPE_FILLING       type_filling;     // Order execution type.
    ENUM_ORDER_TYPE_TIME          type_time;        // Order expiration type.
    datetime                      expiration;       // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type.
    String                       *comment;          // Order comment.
    ulong                         position;         // Position ticket.
    ulong                         position_by;      // The ticket of an opposite position.
  };
  */

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
    idata(new Dict<string, int>)
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
    // Remove class variables.
    //Print(__FUNCTION__, ": ", params.data.id);
    sparams.DeleteObjects();
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
    _result.last_error = ERR_NO_ERROR;
    if (SignalOpen(ORDER_TYPE_BUY)) {
      if (OrderOpen(ORDER_TYPE_BUY)) {
        _result.pos_opened++;
      }
      else {
        _result.last_error = fmax(_result.last_error, Terminal::GetLastError());
      }
    }
    if (SignalOpen(ORDER_TYPE_SELL)) {
      if (OrderOpen(ORDER_TYPE_SELL)) {
        _result.pos_opened++;
      }
      else {
        _result.last_error = fmax(_result.last_error, Terminal::GetLastError());
      }
    }
    if (SignalClose(ORDER_TYPE_BUY) && this.Trade().GetOrdersOpened() > 0) {
      if (this.Trade().OrderCloseViaCmd(ORDER_TYPE_BUY) > 0) {
        _result.pos_closed++;
      } else {
        _result.last_error = fmax(_result.last_error, Terminal::GetLastError());
      }
    }
    if (SignalClose(ORDER_TYPE_SELL) && this.Trade().GetOrdersOpened() > 0) {
      if (this.Trade().OrderCloseViaCmd(ORDER_TYPE_SELL) > 0) {
        _result.pos_closed++;
      } else {
        _result.last_error = fmax(_result.last_error, Terminal::GetLastError());
      }
    }
    sresult = _result;
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
    return Object::IsValid(sparams.trade)
      && this.Chart().IsValidTf();
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
    return sparams.trade.Chart();
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
    return this.Chart().GetTf();
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
   * Get strategy's order comment.
   */
  string GetOrderComment() {
    return StringFormat("%s:%s; spread %gpips",
      GetName(), GetTf(), GetCurrSpread()
    );
  }

  /**
   * Get strategy's lot size.
   */
  double GetLotSize() {
    return sparams.lot_size;
  }

  /**
   * Get strategy's lot size factor.
   */
  double GetLotSizeFactor() {
    return sparams.lot_size_factor;
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
      if (this.Market().GetSymbol() == Order::OrderSymbol() && sparams.magic_no == Order::OrderMagicNumber()) {
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
    return this.Chart().GetSpreadInPips();
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
  bool Strategy(
      string si_name,
      int si_magic_no,
      double si_lot_size,
      double si_weight = 1.0,
      int si_spread_limit = 10.0,
      string si_symbol = NULL
      ) {

    // Basic strategy variables.
    s_name = si_name;
    s_magic_no = si_magic_no;
    s_weight = si_weight;
    s_enabled = true;
    s_suspended = false;

    // Trading variables.
    s_symbol = si_symbol != NULL ? si_symbol : Symbol();
    s_lot_size = si_lot_size;
    s_lot_factor = GetLotSizeFactor();
    s_avg_spread = GetCurrSpread();
    s_spread_limit = si_spread_limit;
    s_pattern_method = 0;
    s_open_level = 0.0;
    s_tp_method = 0;
    s_sl_method = 0;
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
    if (!this.Chart().IsValidTf()) {
      Logger().Warning(StringFormat("Could not initialize %s since %s timeframe is not active!", GetName(), this.Chart().TfToString()), __FUNCTION__ + ": ");
      return false;
    }
    return true;
  }

  /* Orders methods */

  /**
   * Open an order.
   */
  bool OrderOpen(ENUM_ORDER_TYPE _cmd) {
    MqlTradeRequest _request = {0};
    _request.action = TRADE_ACTION_DEAL;
    _request.comment = StringFormat("%s", name);
    _request.deviation = 10;
    _request.magic = GetMagicNo();
    _request.price = this.Market().GetOpenOffer(_cmd);
    _request.symbol = this.Market().GetSymbol();
    _request.type = _cmd;
    _request.type_filling = SymbolInfo::GetFillingMode(_request.symbol);
    _request.volume = this.Market().GetVolumeMin();
    return this.Trade().OrderAdd(new Order(_request));
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
   *   Returns true to when trade should be opened, otherwise false.
   */
  virtual bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) = NULL;

  /**
   * Checks strategy's trade close signal.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _method - signal method to close a trade (bitwise AND operation)
   *   _level  - signal level to close a trade (bitwise AND operation)
   *
   * @result bool
   *   Returns true to when trade should be closed, otherwise false.
   */
  virtual bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) = NULL;

  /**
   * Gets price limit value.
   *
   * @param
   *   _cmd    - type of trade order command
   *   _mode   - mode for price limit value (LIMIT_VALUE_PROFIT or LIMIT_VALUE_STOP)
   *   _method - method to calculate the price limit
   *   _level  - level value to use for calculation
   *
   * @result bool
   *   Returns current stop loss value when _mode is LIMIT_VALUE_STOP and profit take when _mode is LIMIT_VALUE_PROFIT.
   */
  virtual double PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_STG_PRICE_LIMIT_MODE _mode, int _method = 0, double _level = 0.0) = NULL;

};
#endif // STRATEGY_MQH

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

// Forward declaration.
class Trade;

// Includes.
#include "Account.mqh"
#include "Chart.mqh"
#include "Collection.mqh"
#include "Convert.mqh"
#include "Math.mqh"
#include "Object.mqh"

/**
 * Trade class
 */
#ifndef TRADE_MQH
#define TRADE_MQH

// Enums.
// Trade actions.
enum ENUM_TRADE_ACTION {
  TRADE_ACTION_ORDERS_CLOSE_ALL          = 1, // Close open sell orders
  TRADE_ACTION_ORDERS_CLOSE_IN_TREND     = 2, // Close open orders in trend
  TRADE_ACTION_ORDERS_CLOSE_IN_TREND_NOT = 3, // Close open orders NOT in trend
  TRADE_ACTION_ORDERS_CLOSE_TYPE_BUY     = 4, // Close open buy orders
  TRADE_ACTION_ORDERS_CLOSE_TYPE_SELL    = 5, // Close open sell orders
  //TRADE_ACTION_ORDERS_REMOVE_ALL_PENDING,
  FINAL_ENUM_TRADE_ACTION_ENTRY = 6
};
// Trade conditions.
enum ENUM_TRADE_CONDITION {
  TRADE_COND_ALLOWED_NOT           = 1, // When trade is not allowed
  //TRADE_ORDER_CONDS_IN_TREND       = 2, // Open orders with trend
  //TRADE_ORDER_CONDS_IN_TREND_NOT   = 3, // Open orders against trend
  FINAL_ENUM_TRADE_CONDITION_ENTRY = 4
};

// Structs.
struct TradeParams {
  double            risk_margin; // Maximum account margin to risk (in %).
  // Classes.
  Account          *account;   // Pointer to Account class.
  Chart            *chart;     // Pointer to Chart class.
  Log              *logger;    // Pointer to Log class.
  unsigned int      slippage;   // Value of the maximum price slippage in points.
  //Market          *market;     // Pointer to Market class.
  //void Init(TradeParams &p) { slippage = p.slippage; account = p.account; chart = p.chart; }
  // Constructor.
  TradeParams() {}
  TradeParams(Account *_account, Chart *_chart, Log *_log, double _risk_margin = 1.0, unsigned int _slippage = 50) :
    account(_account),
    chart(_chart),
    logger(_log),
    risk_margin(_risk_margin),
    slippage(_slippage) {}
  // Deconstructor.
  ~TradeParams() {
  }
  // Struct methods.
  void DeleteObjects() {
    Object::Delete(account);
    Object::Delete(chart);
    Object::Delete(logger);
  }
};

class Trade {

private:

  Collection *orders;
  Collection *orders_history;
  TradeParams tparams;
  Order *order_last;

public:

  /**
   * Class constructor.
   */
  Trade() : tparams(new Account, new Chart, new Log) {};
  Trade(ENUM_TIMEFRAMES _tf, string _symbol = NULL)
    : tparams(new Account, new Chart(_tf, _symbol), new Log),
      orders(new Collection()),
      order_last(NULL)
    {};
  Trade(TradeParams &_params)
    : tparams(_params.account, _params.chart, _params.logger, _params.slippage) {};

  /**
   * Class copy constructor.
   */
  Trade(const Trade &_trade) {
    tparams = _trade.GetParams();
  }

  /**
   * Class deconstructor.
   */
  void ~Trade() {
    tparams.DeleteObjects();
    Object::Delete(orders);
  }

  /* Getters */

  /**
   * Gets params.
   *
   * @return
   *   Returns Trade's params.
   */
  TradeParams GetParams() const {
    return tparams;
  }

  /**
   * Get number of orders opened.
   *
   * @return
   *   Return number of orders opened.
   */
  long GetOrdersOpened() {
    return orders.GetSize();
  }

  /**
   * Get number of orders closed.
   *
   * @return
   *   Return number of orders closed.
   */
  long GetOrdersClosed() {
    return orders_history.GetSize();
  }

  /**
   * Check if it is possible to trade.
   */
  bool TradeAllowed() {
    bool _result = true;
    if (tparams.chart.GetBars() < 100) {
      Logger().Error("Bars less than 100, not trading yet.");
      _result = false;
    }
    /* Terminal checks */
    if (Terminal::IsTradeContextBusy()) {
      Logger().Error("Trade context is temporary busy.");
      _result = false;
    }
    // Check if the EA is allowed to trade and trading context is not busy, otherwise returns false.
    // OrderSend(), OrderClose(), OrderCloseBy(), OrderModify(), OrderDelete() trading functions
    //   changing the state of a trading account can be called only if trading by Expert Advisors
    //   is allowed (the "Allow live trading" checkbox is enabled in the Expert Advisor or script properties).
    else if (Terminal::IsRealtime() && !Terminal::IsTradeAllowed()) {
      Logger().Error("Trade is not allowed at the moment, check the settings!");
      _result = false;
    }
    else if (Terminal::IsRealtime() && !Terminal::IsConnected()) {
      Logger().Error("Terminal is not connected!");
      _result = false;
    }
    else if (IsStopped()) {
      Logger().Error("Terminal is stopping!");
      _result = false;
    }
    else if (Terminal::IsRealtime() && !Terminal::IsTradeAllowed()) {
      Logger().Error("Trading is not allowed. Market may be closed or choose the right symbol. Otherwise contact your broker.");
      _result = false;
    }
    else if (Terminal::IsRealtime() && !Terminal::IsExpertEnabled()) {
      Logger().Error("You need to enable: 'Enable Expert Advisor'/'AutoTrading'.");
      _result = false;
    }
    /* Account checks */
    // Check the permission to trade for the current account.
    if (!Account::IsTradeAllowed()) {
      Logger().Error("Trade is not allowed for this account!");
      _result = false;
    }
    return _result;
  }

  /**
   * Calculates the margin required for the specified order type.
   *
   * Note: It not taking into account current pending orders and open positions.
   *
   * @return
   *  The function returns true in case of success; otherwise it returns false.
   *
   * @see: https://www.mql5.com/en/docs/trading/ordercalcmargin
   */
  bool OrderCalcMargin(
    ENUM_ORDER_TYPE       _action,           // type of order
    string                _symbol,           // symbol name
    double                _volume,           // volume
    double                _price,            // open price
    double&               _margin            // variable for obtaining the margin value
    ) {
    #ifdef __MQL4__
    // @fixme: Not implemented yet.
    return false;
    #else // __MQL5__
    return OrderCalcMargin(_action, _symbol, _volume, _price, _margin);
    #endif
  }

  /**
   * Free margin required for opening a position with the volume of one lot in the appropriate direction.
   */
  static double GetMarginRequired(string _symbol, ENUM_ORDER_TYPE _cmd = ORDER_TYPE_BUY) {
    #ifdef __MQL4__
    return MarketInfo(_symbol, MODE_MARGINREQUIRED);
    #else
    // @see: https://www.mql5.com/ru/forum/170952/page9#comment_4134898
    double MarginInit, MarginMain;
    const bool _rates = SymbolInfoMarginRate(_symbol, _cmd, MarginInit, MarginMain);
    return _rates ? (MarginInit * SymbolInfo::GetAsk(_symbol) * SymbolInfo::GetTickValue(_symbol)) / (SymbolInfo::GetTickValue(_symbol) * Account::AccountLeverage()) : 0;
    #endif
  }
  double GetMarginRequired(ENUM_ORDER_TYPE _cmd = ORDER_TYPE_BUY) {
    return GetMarginRequired(Market().GetSymbol(), _cmd);
  }

  /* Lot size methods */

  /**
   * Calculate the maximal lot size for the given stop loss value and risk margin.
   *
   * @param double sl
   *   Stop loss to calculate the lot size for.
   * @param string symbol
   *   Symbol pair.
   *
   * @return
   *   Returns maximum safe lot size value.
   *
   * @see: https://www.mql5.com/en/code/8568
   */
  double GetMaxLotSize(double _sl, ENUM_ORDER_TYPE _cmd = NULL) {
    _cmd = _cmd == NULL ? Order::OrderType() : _cmd;
    double risk_amount = Account().GetTotalBalance() / 100 * tparams.risk_margin;
    double _ticks = fabs(_sl - Market().GetOpenOffer(_cmd)) / Market().GetTickSize();
    double lot_size1 = fmin(_sl, _ticks) > 0 ? risk_amount / (_sl * (_ticks / 100.0)) : 1;
    lot_size1 *= Market().GetVolumeMin();
    // double lot_size2 = 1 / (Market().GetTickValue() * sl / risk_margin);
    // PrintFormat("SL=%g: 1 = %g, 2 = %g", sl, lot_size1, lot_size2);
    return Chart().NormalizeLots(lot_size1);
  }
  double GetMaxLotSize(unsigned int _pips, ENUM_ORDER_TYPE _cmd = NULL) {
    return GetMaxLotSize(CalcOrderSLTP(_pips, _cmd, ORDER_TYPE_SL));
  }

  /**
   * Validate Take Profit value for the order.
   */
  bool ValidTP(double _value, ENUM_ORDER_TYPE _cmd) {
    bool _valid = _value >= 0;
    double _price = Market().GetOpenOffer(_cmd);
    switch (_cmd) {
      case OP_BUY: {
        return _value > _price && Convert::GetValueDiffInPips(_value, _price) > Market().GetTradeDistanceInPips();
      }
      case OP_SELL: {
        return _value < _price && Convert::GetValueDiffInPips(_price, _value) > Market().GetTradeDistanceInPips();
      }
    }
    return false;
  }

  /**
   * Validate Stop Loss value for the order.
   */
  bool ValidSL(double _value, ENUM_ORDER_TYPE _cmd) {
    bool _valid = _value >= 0;
    double _price = Market().GetOpenOffer(_cmd);
    switch (_cmd) {
      case OP_BUY: {
        return _value < _price && Convert::GetValueDiffInPips(_price, _value) > Market().GetTradeDistanceInPips();
      }
      case OP_SELL: {
        return _value > _price && Convert::GetValueDiffInPips(_value, _price) > Market().GetTradeDistanceInPips();
      }
    }
    return false;
  }

 /**
  * Optimize lot size for open based on the consecutive wins and losses.
  *
  * @param
  *   lots (double)
  *     Base lot size.
  *   win_factor (double)
  *     Lot size increase factor (in %) multiplied by consecutive wins.
  *   loss_factor (double)
  *     Lot size increase factor (in %) multiplied by consecutive losses.
  *   ols_orders (double)
  *     Maximum number of recent orders to check for consecutive wins/losses.
  *   symbol (string)
  *     Optional symbol name if different than current.
  */
  double OptimizeLotSize(double lots, double win_factor = 1.0, double loss_factor = 1.0, int ols_orders = 100, string _symbol = NULL) {

    double lotsize = lots;
    int    wins = 0,  losses = 0; // Number of consequent losing orders.
    int    twins = 0, tlosses = 0; // Total number of consequent losing orders.
    if (win_factor == 0 && loss_factor == 0) {
      return lotsize;
    }
    // Calculate number of wins and losses orders without a break.
    #ifdef __MQL5__
    /* @fixme: Rewrite without using CDealInfo.
    CDealInfo deal;
    HistorySelect(0, TimeCurrent()); // Select history for access.
    */
    #endif
    int _orders = Account::OrdersHistoryTotal();
    for (int i = _orders - 1; i >= fmax(0, _orders - ols_orders); i--) {
      #ifdef __MQL5__
      /* @fixme: Rewrite without using CDealInfo.
      deal.Ticket(HistoryDealGetTicket(i));
      if (deal.Ticket() == 0) {
        Print(__FUNCTION__, ": Error in history!");
        break;
      }
      if (deal.Symbol() != Market().GetSymbol()) continue;
      double profit = deal.Profit();
      */
      double profit = 0;
      #else
      if (Order::OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false) {
        Print(__FUNCTION__, ": Error in history!");
        break;
      }
      if (Order::OrderSymbol() != Symbol() || Order::OrderType() > ORDER_TYPE_SELL) continue;
      double profit = Order::OrderProfit();
      #endif
      if (profit > 0.0) {
        losses = 0;
        wins++;
      } else {
        wins = 0;
        losses++;
      }
      twins = fmax(wins, twins);
      tlosses = fmax(losses, tlosses);
    }
    lotsize = twins   > 1 ? lotsize + (lotsize / 100 * win_factor * twins): lotsize;
    lotsize = tlosses > 1 ? lotsize + (lotsize / 100 * loss_factor * tlosses) : lotsize;
    return Market().NormalizeLots(lotsize);
  }

  /**
   * Calculate size of the lot based on the free margin or balance.
   */
  double CalcLotSize(
    double _risk_margin = 1,  // Risk margin in %.
    double _risk_ratio = 1.0, // Risk ratio factor.
    uint   _method = 0        // Method of calculation (0-3).
    ) {

    double _lot_size = Market().GetVolumeMin();
    double _avail_amount = _method % 2 == 0 ? Account().GetMarginAvail() : Account().GetTotalBalance();
    if (_method == 0 || _method == 1) {
      _lot_size = Market().NormalizeLots(
        _avail_amount / fmax(0.00001, GetMarginRequired() * _risk_ratio) / 100 * _risk_ratio
      );
    } else {
      double _risk_amount = _avail_amount / 100 * _risk_margin;
      double _risk_value = Convert::MoneyToValue(_risk_amount, Market().GetVolumeMin(), Market().GetSymbol());
      double _tick_value = Market().GetTickSize();
      _lot_size = Market().NormalizeLots(_risk_value * _tick_value * _risk_ratio);
    }
    return _lot_size;
  }

  /* Orders methods */

  /**
   * Open an order.
   */
  bool OrderAdd(Order *_order) {
    unsigned int _last_error = _order.GetData().last_error;
    Logger().Link(_order.GetData().logger);
    switch (_last_error) {
      case ERR_NO_ERROR:
        orders.Add(_order);
        order_last = _order;
        // Trigger: OnOrder();
        return true;
      default:
        Logger().Error("Cannot add order!", __FUNCTION_LINE__, StringFormat("Code: %d, Msg: %s", _last_error, Terminal::GetErrorText(_last_error)));
        return false;
    }
    return false;
  }

  /**
   * Returns the number of market and pending orders.
   *
   * @see:
   * - https://www.mql5.com/en/docs/trading/orderstotal
   * - https://www.mql5.com/en/docs/trading/positionstotal
   */
  static int OrdersTotal() {
    #ifdef __MQL4__
      return ::OrdersTotal();
    #else
      return ::OrdersTotal() + ::PositionsTotal();
    #endif
  }

  /* Orders close methods */

  /**
   * Close all orders.
   *
   * Note: It will only affect trades managed by this class instance.
   *
   * @return
   *   Returns number of successfully closed trades.
   *   On error, returns -1.
   */
  int OrdersCloseAll(string _comment = "") {
    int _oid = 0, _closed = 0;
    Order *_order;
    _comment = _comment != "" ? _comment : __FUNCTION__;
    for (_oid = 0; _oid < orders.GetSize(); _oid++) {
      _order = ((Order *) orders.GetByIndex(_oid));
      if (_order.IsOpen()) {
        if (!_order.OrderClose(_comment)) {
          Logger().AddLastError(__FUNCTION_LINE__, _order.GetData().last_error);
          return -1;
        }
        order_last = _order;
      }
    }
    return _closed;
  }

  /**
   * Close orders by order type.
   *
   * @return
   *   Returns number of successfully closed trades.
   *   On error, returns -1.
   */
  int OrdersCloseViaCmd(ENUM_ORDER_TYPE _cmd, string _comment = "") {
    int _oid = 0, _closed = 0;
    Order *_order;
    _comment = _comment != "" ? _comment : __FUNCTION__;
    for (_oid = 0; _oid < orders.GetSize(); _oid++) {
      _order = ((Order *) orders.GetByIndex(_oid));
      if (_order.GetRequest().type == _cmd && _order.IsOpen()) {
        if (!_order.OrderClose(_comment)) {
          Logger().Error("Error while closing order!", __FUNCTION_LINE__, StringFormat("Code: %d", _order.GetData().last_error));
          return -1;
        }
        order_last = _order;
      }
    }
    return _closed;
  }

  /**
   * Close orders based on the property value.
   *
   * Note: It will only affect trades managed by this class instance.
   *
   * @return
   *   Returns number of successfully closed trades.
   *   On error, returns -1.
   */
  int OrdersCloseViaProp(ENUM_ORDER_PROPERTY_INTEGER _prop, long _value, string _comment = "") {
    int _oid = 0, _closed = 0;
    Order *_order;
    _comment = _comment != "" ? _comment : __FUNCTION__;
    for (_oid = 0; _oid < orders.GetSize(); _oid++) {
      _order = ((Order *) orders.GetByIndex(_oid));
      if (_order.IsOpen() && _order.OrderGet(_prop) == _value) {
        if (!_order.OrderClose(_comment)) {
          Logger().AddLastError(__FUNCTION_LINE__, _order.GetData().last_error);
          return -1;
        }
        order_last = _order;
      }
    }
    return _closed;
  }

  /**
   * Calculate available lot size given the risk margin.
   */
  uint CalcMaxLotSize(double risk_margin = 1.0) {
    double _avail_margin = Account().AccountAvailMargin();
    double _opened_lots = Trades().GetOpenLots();
    // @todo
    return 0;
  }

  /**
   * Calculate number of allowed orders to open.
   */
  unsigned long CalcMaxOrders(double volume_size, double _risk_ratio = 1.0, long prev_max_orders = 0, long hard_limit = 0, bool smooth = true) {
    double _avail_margin = fmin(Account().GetMarginFree(), Account().GetBalance() + Account().GetCredit());
    if (_avail_margin == 0 || volume_size == 0) {
      return 0;
    }
    double _margin_required = GetMarginRequired();
    double _avail_orders = _avail_margin / _margin_required / volume_size;
    long new_max_orders = (long) (_avail_orders * _risk_ratio);
    if (hard_limit > 0) new_max_orders = fmin(hard_limit, new_max_orders);
    if (smooth && new_max_orders > prev_max_orders) {
      // Increase the limit smoothly.
      return (prev_max_orders + new_max_orders) / 2;
    } else {
      return new_max_orders;
    }
  }

    /* TP/SL methods */

    /**
     * Returns maximal order stop loss value given the risk margin (in %).
     *
     * @param int cmd
     *   Trade command (e.g. OP_BUY/OP_SELL).
     * @param double lot_size
     *   Lot size to take into account.
     * @param double risk_margin
     *   Maximum account margin to risk (in %).
     * @return
     *   Returns maximum stop loss price value for the given symbol.
     */
    double GetMaxSLTP(ENUM_ORDER_TYPE _cmd = NULL, double _lot_size = 0, ENUM_ORDER_TYPE_VALUE _mode = ORDER_TYPE_SL, double _risk_margin = 1.0) {
      double _price = _cmd == NULL ? Order::OrderOpenPrice() : Market().GetOpenOffer(_cmd);
      // For the new orders, use the available margin for calculation, otherwise use the account balance.
      double _margin = Convert::MoneyToValue((_cmd == NULL ? Account().GetMarginAvail() : Account().GetTotalBalance()) / 100 * _risk_margin, _lot_size, Market().GetSymbol());
      _cmd = _cmd == NULL ? Order::OrderType() : _cmd;
      _lot_size = _lot_size <= 0 ? fmax(Order::OrderLots(), Market().GetVolumeMin()) : _lot_size;
      return _price
        + Chart().GetTradeDistanceInValue()
        // + Convert::MoneyToValue(AccountInfo().GetTotalBalance() / 100 * _risk_margin, _lot_size)
        // + Convert::MoneyToValue(AccountInfo().GetMarginAvail() / 100 * _risk_margin, _lot_size)
        + _margin
        * Order::OrderDirection(_cmd, _mode);
    }
    double GetMaxSL(ENUM_ORDER_TYPE _cmd = NULL, double _lot_size = 0, double _risk_margin = 1.0) {
      return GetMaxSLTP(_cmd, _lot_size, ORDER_TYPE_SL, _risk_margin);
    }
    double GetMaxTP(ENUM_ORDER_TYPE _cmd = NULL, double _lot_size = 0, double _risk_margin = 1.0) {
      return GetMaxSLTP(_cmd, _lot_size, ORDER_TYPE_TP, _risk_margin);
    }

    /**
     * Returns value of stop loss for the new order given the pips value.
     */
    double CalcOrderSLTP(
      double _value,                    // Value in pips.
      ENUM_ORDER_TYPE _cmd,             // Order type (e.g. buy or sell).
      ENUM_ORDER_TYPE_VALUE _mode       // Type of value (stop loss or take profit).
    ) {
      double _price = _cmd == NULL ? Order::OrderOpenPrice() : Market().GetOpenOffer(_cmd);
      _cmd = _cmd == NULL ? Order::OrderType() : _cmd;
      // PrintFormat("#%d: %s/%s: %g (%g/%g) + %g * %g * %g = %g", Order::OrderTicket(), EnumToString(_cmd), EnumToString(_mode), _price, Bid, Ask, _value, Market().GetPipSize(), Order::OrderDirection(_cmd, _mode), Market().GetOpenOffer(_cmd) + _value * Market().GetPipSize() * Order::OrderDirection(_cmd, _mode));
      return _value > 0 ? _price + _value * Market().GetPipSize() * Order::OrderDirection(_cmd, _mode) : 0;
    }
    double CalcOrderSL(double _value, ENUM_ORDER_TYPE _cmd) {
      return CalcOrderSLTP(_value, _cmd, ORDER_TYPE_SL);
    }
    double CalcOrderTP(double _value, ENUM_ORDER_TYPE _cmd) {
      return CalcOrderSLTP(_value, _cmd, ORDER_TYPE_TP);
    }

    /**
     * Returns safer SL/TP based on the two SL or TP input values.
     */
    double GetSaferSLTP(double _value1, double _value2, ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode) {
      if (_value1 <= 0 || _value2 <= 0) {
        return Market().NormalizeSLTP(fmax(_value1, _value2), _cmd, _mode);
      }
      switch (_cmd) {
        case ORDER_TYPE_BUY_LIMIT:
        case ORDER_TYPE_BUY:
          switch (_mode) {
            case ORDER_TYPE_SL: return Market().NormalizeSLTP(_value1 > _value2 ? _value1 : _value2, _cmd, _mode);
            case ORDER_TYPE_TP: return Market().NormalizeSLTP(_value1 < _value2 ? _value1 : _value2, _cmd, _mode);
            default: Logger().Error(StringFormat("Invalid mode: %s!", EnumToString(_mode), __FUNCTION__));
          }
          break;
        case ORDER_TYPE_SELL_LIMIT:
        case ORDER_TYPE_SELL:
          switch (_mode) {
            case ORDER_TYPE_SL: return Market().NormalizeSLTP(_value1 < _value2 ? _value1 : _value2, _cmd, _mode);
            case ORDER_TYPE_TP: return Market().NormalizeSLTP(_value1 > _value2 ? _value1 : _value2, _cmd, _mode);
            default: Logger().Error(StringFormat("Invalid mode: %s!", EnumToString(_mode), __FUNCTION__));
          }
          break;
        default: Logger().Error(StringFormat("Invalid order type: %s!", EnumToString(_cmd), __FUNCTION__));
      }
      return EMPTY_VALUE;
    }
    double GetSaferSLTP(double _value1, double _value2, double _value3, ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode) {
      return GetSaferSLTP(GetSaferSLTP(_value1, _value2, _cmd, _mode), _value3, _cmd, _mode);
    }
    double GetSaferSL(double _value1, double _value2, ENUM_ORDER_TYPE _cmd) {
      return GetSaferSLTP(_value1, _value2, _cmd, ORDER_TYPE_SL);
    }
    double GetSaferSL(double _value1, double _value2, double _value3, ENUM_ORDER_TYPE _cmd) {
      return GetSaferSLTP(GetSaferSLTP(_value1, _value2, _cmd, ORDER_TYPE_SL), _value3, _cmd, ORDER_TYPE_SL);
    }
    double GetSaferTP(double _value1, double _value2, ENUM_ORDER_TYPE _cmd) {
      return GetSaferSLTP(_value1, _value2, _cmd, ORDER_TYPE_TP);
    }
    double GetSaferTP(double _value1, double _value2, double _value3, ENUM_ORDER_TYPE _cmd) {
      return GetSaferSLTP(GetSaferSLTP(_value1, _value2, _cmd, ORDER_TYPE_TP), _value3, _cmd, ORDER_TYPE_TP);
    }

    /**
     * Calculates the best SL/TP value for the order given the limits.
     */
    double CalcBestSLTP(
      double _value,                      // Suggested value.
      double _max_pips,                   // Maximal amount of pips.
      ENUM_ORDER_TYPE_VALUE _mode,        // Type of value (stop loss or take profit).
      ENUM_ORDER_TYPE _cmd = NULL,        // Order type (e.g. buy or sell).
      double _lot_size = 0                // Lot size of the order.
    ) {
      double _max_value1 = _max_pips > 0 ? CalcOrderSLTP(_max_pips, _cmd, _mode) : 0;
      double _max_value2 = tparams.risk_margin > 0 ? GetMaxSLTP(_cmd, _lot_size, _mode) : 0;
      double _res = Market().NormalizePrice(GetSaferSLTP(_value, _max_value1, _max_value2, _cmd, _mode));
      // PrintFormat("%s/%s: Value: %g", EnumToString(_cmd), EnumToString(_mode), _value);
      // PrintFormat("%s/%s: Max value 1: %g", EnumToString(_cmd), EnumToString(_mode), _max_value1);
      // PrintFormat("%s/%s: Max value 2: %g", EnumToString(_cmd), EnumToString(_mode), _max_value2);
      // PrintFormat("%s/%s: Result: %g", EnumToString(_cmd), EnumToString(_mode), _res);
      return _res;
    }

  /* Trend methods */

  /**
   * Calculates the current market trend.
   *
   * @param
   *   method (int)
   *    Bitwise trend method to use.
   *   tf (ENUM_TIMEFRAMES)
   *     Frequency based on the given timeframe. Use NULL for the current.
   *   symbol (string)
   *     Symbol pair to check against it.
   *   simple (bool)
   *     If true, use simple trend calculation.
   *
   * @return
   *   Returns positive value for bullish, negative for bearish, zero for neutral market trend.
   *
   * @todo: Improve number of increases for bull/bear variables.
   */
  double GetTrend(int method, ENUM_TIMEFRAMES _tf = NULL, bool simple = false) {
    static datetime _last_trend_check = 0;
    static double _last_trend = 0;
    string symbol = Market().GetSymbol();
    if (_last_trend_check == Chart().GetBarTime(_tf)) {
      return _last_trend;
    }
    double bull = 0, bear = 0;
    int _counter = 0;

    if (simple && method != 0) {
      if ((method &   1) != 0)  {
        if (Chart().GetOpen(PERIOD_MN1, 0) > Chart().GetClose(PERIOD_MN1, 1)) bull++;
        if (Chart().GetOpen(PERIOD_MN1, 0) < Chart().GetClose(PERIOD_MN1, 1)) bear++;
      }
      if ((method &   2) != 0)  {
        if (Chart().GetOpen(PERIOD_W1, 0) > Chart().GetClose(PERIOD_W1, 1)) bull++;
        if (Chart().GetOpen(PERIOD_W1, 0) < Chart().GetClose(PERIOD_W1, 1)) bear++;
      }
      if ((method &   4) != 0)  {
        if (Chart().GetOpen(PERIOD_D1, 0) > Chart().GetClose(PERIOD_D1, 1)) bull++;
        if (Chart().GetOpen(PERIOD_D1, 0) < Chart().GetClose(PERIOD_D1, 1)) bear++;
      }
      if ((method &   8) != 0)  {
        if (Chart().GetOpen(PERIOD_H4, 0) > Chart().GetClose(PERIOD_H4, 1)) bull++;
        if (Chart().GetOpen(PERIOD_H4, 0) < Chart().GetClose(PERIOD_H4, 1)) bear++;
      }
      if ((method &   16) != 0)  {
        if (Chart().GetOpen(PERIOD_H1, 0) > Chart().GetClose(PERIOD_H1, 1)) bull++;
        if (Chart().GetOpen(PERIOD_H1, 0) < Chart().GetClose(PERIOD_H1, 1)) bear++;
      }
      if ((method &   32) != 0)  {
        if (Chart().GetOpen(PERIOD_M30, 0) > Chart().GetClose(PERIOD_M30, 1)) bull++;
        if (Chart().GetOpen(PERIOD_M30, 0) < Chart().GetClose(PERIOD_M30, 1)) bear++;
      }
      if ((method &   64) != 0)  {
        if (Chart().GetOpen(PERIOD_M15, 0) > Chart().GetClose(PERIOD_M15, 1)) bull++;
        if (Chart().GetOpen(PERIOD_M15, 0) < Chart().GetClose(PERIOD_M15, 1)) bear++;
      }
      if ((method &  128) != 0)  {
        if (Chart().GetOpen(PERIOD_M5, 0) > Chart().GetClose(PERIOD_M5, 1)) bull++;
        if (Chart().GetOpen(PERIOD_M5, 0) < Chart().GetClose(PERIOD_M5, 1)) bear++;
      }
      //if (Chart().GetOpen(PERIOD_H12, 0) > Chart().GetClose(PERIOD_H12, 1)) bull++;
      //if (Chart().GetOpen(PERIOD_H12, 0) < Chart().GetClose(PERIOD_H12, 1)) bear++;
      //if (Chart().GetOpen(PERIOD_H8, 0) > Chart().GetClose(PERIOD_H8, 1)) bull++;
      //if (Chart().GetOpen(PERIOD_H8, 0) < Chart().GetClose(PERIOD_H8, 1)) bear++;
      //if (Chart().GetOpen(PERIOD_H6, 0) > Chart().GetClose(PERIOD_H6, 1)) bull++;
      //if (Chart().GetOpen(PERIOD_H6, 0) < Chart().GetClose(PERIOD_H6, 1)) bear++;
      //if (Chart().GetOpen(PERIOD_H2, 0) > Chart().GetClose(PERIOD_H2, 1)) bull++;
      //if (Chart().GetOpen(PERIOD_H2, 0) < Chart().GetClose(PERIOD_H2, 1)) bear++;
    } else if (method != 0) {
      if ((method %   1) == 0)  {
        for (_counter = 0; _counter < 3; _counter++) {
          if (Chart().GetOpen(PERIOD_MN1, _counter) > Chart().GetClose(PERIOD_MN1, _counter + 1)) bull += 30;
          else if (Chart().GetOpen(PERIOD_MN1, _counter) < Chart().GetClose(PERIOD_MN1, _counter + 1)) bear += 30;
        }
      }
      if ((method %   2) == 0)  {
        for (_counter = 0; _counter < 8; _counter++) {
          if (Chart().GetOpen(PERIOD_W1, _counter) > Chart().GetClose(PERIOD_W1, _counter + 1)) bull += 7;
          else if (Chart().GetOpen(PERIOD_W1, _counter) < Chart().GetClose(PERIOD_W1, _counter + 1)) bear += 7;
        }
      }
      if ((method %   4) == 0)  {
        for (_counter = 0; _counter < 7; _counter++) {
          if (Chart().GetOpen(PERIOD_D1, _counter) > Chart().GetClose(PERIOD_D1, _counter + 1)) bull += 1440/1440;
          else if (Chart().GetOpen(PERIOD_D1, _counter) < Chart().GetClose(PERIOD_D1, _counter + 1)) bear += 1440/1440;
        }
      }
      if ((method %   8) == 0)  {
        for (_counter = 0; _counter < 24; _counter++) {
          if (Chart().GetOpen(PERIOD_H4, _counter) > Chart().GetClose(PERIOD_H4, _counter + 1)) bull += 240/1440;
          else if (Chart().GetOpen(PERIOD_H4, _counter) < Chart().GetClose(PERIOD_H4, _counter + 1)) bear += 240/1440;
        }
      }
      if ((method %   16) == 0)  {
        for (_counter = 0; _counter < 24; _counter++) {
          if (Chart().GetOpen(PERIOD_H1, _counter) > Chart().GetClose(PERIOD_H1, _counter + 1)) bull += 60/1440;
          else if (Chart().GetOpen(PERIOD_H1, _counter) < Chart().GetClose(PERIOD_H1, _counter + 1)) bear += 60/1440;
        }
      }
      if ((method %   32) == 0)  {
        for (_counter = 0; _counter < 48; _counter++) {
          if (Chart().GetOpen(PERIOD_M30, _counter) > Chart().GetClose(PERIOD_M30, _counter + 1)) bull += 30/1440;
          else if (Chart().GetOpen(PERIOD_M30, _counter) < Chart().GetClose(PERIOD_M30, _counter + 1)) bear += 30/1440;
        }
      }
      if ((method %   64) == 0)  {
        for (_counter = 0; _counter < 96; _counter++) {
          if (Chart().GetOpen(PERIOD_M15, _counter) > Chart().GetClose(PERIOD_M15, _counter + 1)) bull += 15/1440;
          else if (Chart().GetOpen(PERIOD_M15, _counter) < Chart().GetClose(PERIOD_M15, _counter + 1)) bear += 15/1440;
        }
      }
      if ((method %  128) == 0)  {
        for (_counter = 0; _counter < 288; _counter++) {
          if (Chart().GetOpen(PERIOD_M5, _counter) > Chart().GetClose(PERIOD_M5, _counter + 1)) bull += 5/1440;
          else if (Chart().GetOpen(PERIOD_M5, _counter) < Chart().GetClose(PERIOD_M5, _counter + 1)) bear += 5/1440;
        }
      }
    }
    _last_trend = (bull - bear);
    _last_trend_check = Chart().GetBarTime(_tf, 0);
    Logger().Debug(StringFormat("%s: %g", __FUNCTION__, _last_trend));
    return _last_trend;
  }

  /**
   * Get the current market trend.
   *
   * @param
   *   method (int)
   *    Bitwise trend method to use.
   *   tf (ENUM_TIMEFRAMES)
   *     Frequency based on the given timeframe. Use NULL for the current.
   *   symbol (string)
   *     Symbol pair to check against it.
   *   simple (bool)
   *     If true, use simple trend calculation.
   *
   * @return
   *   Returns Buy operation for bullish, Sell for bearish, otherwise NULL for neutral market trend.
   */
  ENUM_ORDER_TYPE GetTrendOp(int method, ENUM_TIMEFRAMES _tf = NULL, bool simple = false) {
    double _curr_trend = GetTrend(method, _tf, simple);
    return _curr_trend == 0 ? (ENUM_ORDER_TYPE) (ORDER_TYPE_BUY + ORDER_TYPE_SELL) : (_curr_trend > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
  }

  /* State checkers */

  /**
   * Checks if trading is allowed for the current terminal, account and running program.
   */
  bool IsTradeAllowed() {
    return Terminal().CheckPermissionToTrade() && Account().IsExpertEnabled() && Account().IsTradeAllowed();
  }

  /**
   * Check the limit on the number of active pending orders.
   *
   * Validate whether the amount of open and pending orders
   * has reached the limit set by the broker.
   *
   * @see: https://www.mql5.com/en/articles/2555#account_limit_pending_orders
   */
  bool IsOrderAllowed() {
    return (OrdersTotal() < Account().GetLimitOrders());
  }

  /* Conditions */

  /**
   * Checks for trade condition.
   *
   * @param ENUM_TRADE_CONDITION _cond
   *   Trade condition.
   * @param MqlParam[] _args
   *   Condition arguments.
   * @return
   *   Returns true when the condition is met.
   */
  bool Condition(ENUM_TRADE_CONDITION _cond, MqlParam &_args[]) {
    switch (_cond) {
      case TRADE_COND_ALLOWED_NOT:
        return !IsTradeAllowed();
      //case TRADE_ORDER_CONDS_IN_TREND:
      //case TRADE_ORDER_CONDS_IN_TREND_NOT:
      default:
        Logger().Error(StringFormat("Invalid trade condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }
  bool Condition(ENUM_TRADE_CONDITION _cond) {
    MqlParam _args[] = {};
    return Trade::Condition(_cond, _args);
  }

  /* Actions */

  /**
   * Execute trade action.
   *
   * @param ENUM_TRADE_ACTION _action
   *   Trade action to execute.
   * @param MqlParam _args
   *   Trade action arguments.
   * @return
   *   Returns true when the condition is met.
   */
  bool ExecuteAction(ENUM_TRADE_ACTION _action, MqlParam &_args[]) {
    double arg1 = (ArraySize(_args) > 0 && _args[0].type == TYPE_DOUBLE) ? _args[0].double_value : 0;
    switch (_action) {
      case TRADE_ACTION_ORDERS_CLOSE_ALL:
        return OrdersCloseAll() >= 0;
      case TRADE_ACTION_ORDERS_CLOSE_IN_TREND:
        return OrdersCloseViaCmd(GetTrendOp(0)) >= 0;
      case TRADE_ACTION_ORDERS_CLOSE_IN_TREND_NOT:
        return OrdersCloseViaCmd(Order::NegateOrderType(GetTrendOp(0))) >= 0;
      case TRADE_ACTION_ORDERS_CLOSE_TYPE_BUY:
        return OrdersCloseViaCmd(ORDER_TYPE_BUY) >= 0;
      case TRADE_ACTION_ORDERS_CLOSE_TYPE_SELL:
        return OrdersCloseViaCmd(ORDER_TYPE_SELL) >= 0;
      default:
        Logger().Error(StringFormat("Invalid trade action: %s!", EnumToString(_action), __FUNCTION_LINE__));
        return false;
    }
  }
  bool ExecuteAction(ENUM_TRADE_ACTION _action) {
    MqlParam _args[] = {};
    return Trade::ExecuteAction(_action, _args);
  }

  /* Printer methods */

  /**
   * Returns textual representation of the Trade class.
   */
  string ToString() {
    return StringFormat(
      "Margin required: %g/lot",
      GetMarginRequired()
      );
  }

  /* Class handlers */

  /**
   * Returns pointer to Account class.
   */
  Account *Account() {
    return tparams.account;
  }

  /**
   * Returns pointer to Orders collection.
   */
  Collection *Orders() {
    return orders;
  }

  /**
   * Returns pointer to account's trades.
   */
  Orders *Trades() {
    return tparams.account.Trades();
  }

  /**
   * Return pointer to Market class.
   */
  Market *Market() {
    return (Market *) GetPointer(tparams.chart);
  }

  /**
   * Returns pointer to Chart class.
   */
  Chart *Chart() {
    return tparams.chart;
  }

  /**
   * Returns pointer to the Terminal class.
   */
  Terminal *Terminal() {
    return (Terminal *) GetPointer(tparams.chart);
  }

  /**
   * Returns pointer to Log class.
   */
  Log *Logger() {
    return tparams.logger;
  }

};
#endif // TRADE_MQH

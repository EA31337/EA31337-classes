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

// Forward declaration.
class Trade;

/**
 * Trade class
 */
#ifndef TRADE_MQH
#define TRADE_MQH

// Includes.
#include "Account.mqh"
#include "Action.enum.h"
#include "Chart.mqh"
#include "Condition.enum.h"
#include "Convert.mqh"
#include "DictStruct.mqh"
#include "Math.h"
#include "Object.mqh"
#include "Order.mqh"
#include "OrderQuery.h"
#include "Trade.enum.h"
#include "Trade.struct.h"

class Trade {
 public:
  Account account;
  Ref<Chart> chart;
  DictStruct<long, Ref<Order>> orders_active;
  DictStruct<long, Ref<Order>> orders_history;
  DictStruct<long, Ref<Order>> orders_pending;
  Log logger;           // Trade logger.
  TradeParams tparams;  // Trade parameters.
  TradeStates tstates;  // Trade states.
  TradeStats tstats;    // Trade statistics.

 protected:
  string name;
  Ref<Order> order_last;
  // Strategy *strategy;  // Optional pointer to Strategy class.

 public:
  /**
   * Class constructor.
   */
  Trade() : chart(new Chart()), order_last(NULL) {
    SetName();
    OrdersLoadByMagic(tparams.magic_no);
  };
  Trade(TradeParams &_tparams, ChartParams &_cparams)
      : chart(new Chart(_cparams)), tparams(_tparams), order_last(NULL) {
    SetName();
    OrdersLoadByMagic(tparams.magic_no);
  };

  /**
   * Class copy constructor.
   */
  Trade(const Trade &_trade) {
    tparams = _trade.tparams;
    tstats = _trade.tstats;
    tstates = _trade.tstates;
  }

  /**
   * Class deconstructor.
   */
  void ~Trade() {}

  /* Getters */

  /**
   * Gets an account parameter value of double type.
   */
  template <typename T>
  T Get(ENUM_ACCOUNT_INFO_DOUBLE _param) {
    return account.Get<T>(_param);
  }

  /**
   * Gets a trade state value.
   */
  template <typename T>
  T Get(ENUM_TRADE_STATE _prop) {
    return tstates.Get(_prop);
  }

  /**
   * Gets a trade parameter value.
   */
  template <typename T>
  T Get(ENUM_TRADE_PARAM _param) {
    return tparams.Get<T>(_param);
  }

  /**
   * Gets a chart parameter value.
   */
  template <typename T>
  T Get(ENUM_CHART_PARAM _param) {
    return GetChart().Get<T>(_param);
  }

  /**
   * Gets name of trade instance.
   */
  string GetName() const { return name; }

  /**
   * Gets the last order.
   */
  Order *GetOrderLast() { return order_last.Ptr(); }

  /**
   * Gets copy of params.
   *
   * @return
   *   Returns structure for Trade's params.
   */
  TradeParams GetParams() const { return tparams; }

  /**
   * Gets copy of states.
   *
   * @return
   *   Returns structure for Trade's states.
   */
  TradeStates GetStates() const { return tstates; }

  /**
   * Gets copy of stats.
   *
   * @return
   *   Returns structure for Trade's stats.
   */
  TradeStats GetStats() const { return tstats; }

  /**
   * Gets list of active orders.
   *
   * @return
   *   Returns DictStruct's of active orders.
   */
  DictStruct<long, Ref<Order>> *GetOrdersActive() { return &orders_active; }

  /**
   * Gets list of history orders.
   *
   * @return
   *   Returns DictStruct's of orders from history.
   */
  DictStruct<long, Ref<Order>> *GetOrdersHistory() { return &orders_history; }

  /**
   * Gets list of pending orders.
   *
   * @return
   *   Returns DictStruct's of pending orders.
   */
  DictStruct<long, Ref<Order>> *GetOrdersPending() { return &orders_pending; }

  /**
   * Get a trade request.
   *
   * @return
   *   Returns true on successful request.
   */
  MqlTradeRequest GetTradeOpenRequest(ENUM_ORDER_TYPE _type, float _volume = 0, long _magic = 0, string _comment = "") {
    // Create a request.
    MqlTradeRequest _request = {(ENUM_TRADE_REQUEST_ACTIONS)0};
    _request.action = TRADE_ACTION_DEAL;
    _request.comment = _comment;
    _request.deviation = 10;
    _request.magic = _magic > 0 ? _magic : tparams.Get<long>(TRADE_PARAM_MAGIC_NO);
    _request.symbol = GetChart().Get<string>(CHART_PARAM_SYMBOL);
    _request.price = SymbolInfoStatic::GetOpenOffer(_request.symbol, _type);
    _request.type = _type;
    _request.type_filling = Order::GetOrderFilling(_request.symbol);
    _request.volume = _volume > 0 ? _volume : tparams.Get<float>(TRADE_PARAM_LOT_SIZE);
    _request.volume = NormalizeLots(fmax(_request.volume, SymbolInfoStatic::GetVolumeMin(_request.symbol)));
    return _request;
  }

  /* Setters */

  /**
   * Gets a trade parameter value.
   */
  template <typename T>
  void Set(ENUM_TRADE_PARAM _param, T _value) {
    tparams.Set<T>(_param, _value);
  }

  /**
   * Sets default name of trade instance.
   */
  void SetName() {
    name = StringFormat("%s@%s", GetChart().Get<string>(CHART_PARAM_SYMBOL),
                        ChartTf::TfToString(GetChart().Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF)));
  }

  /**
   * Sets name of trade instance.
   */
  void SetName(string _name) { name = _name; }

  // void SetStrategy(Strategy *_strategy) { strategy = _strategy; }

  /* State methods */

  /**
   * Check whether the price is in its peak for the current period.
   */
  bool IsPeak(ENUM_ORDER_TYPE _cmd, int _shift = 0) {
    bool _result = false;
    double _high = GetChart().GetHigh(_shift + 1);
    double _low = GetChart().GetLow(_shift + 1);
    double _open = GetChart().GetOpenOffer(_cmd);
    if (_low != _high) {
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          _result = _open > _high;
          break;
        case ORDER_TYPE_SELL:
          _result = _open < _low;
          break;
      }
    }
    return _result;
  }

  /**
   * Checks if the current price is in pivot point level given the order type.
   */
  bool IsPivot(ENUM_ORDER_TYPE _cmd, int _shift = 0) {
    bool _result = false;
    double _high = GetChart().GetHigh(_shift + 1);
    double _low = GetChart().GetLow(_shift + 1);
    double _close = GetChart().GetClose(_shift + 1);
    if (_close > 0 && _low != _high) {
      float _pp = (float)(_high + _low + _close) / 3;
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          _result = GetChart().GetOpenOffer(_cmd) > _pp;
          break;
        case ORDER_TYPE_SELL:
          _result = GetChart().GetOpenOffer(_cmd) < _pp;
          break;
      }
    }
    return _result;
  }

  /**
   * Check if trading is allowed.
   */
  bool IsTradeAllowed() {
    UpdateStates();
    return !tstates.CheckState(TRADE_STATE_TRADE_CANNOT);
  }

  /**
   * Check if trading is recommended.
   */
  bool IsTradeRecommended() {
    UpdateStates();
    return !tstates.CheckState(TRADE_STATE_TRADE_WONT);
  }

  /**
   * Check if trading instance is valid.
   */
  bool IsValid() { return GetChart().IsValidTf(); }

  /**
   * Check if this trade instance has active orders.
   */
  bool HasActiveOrders() { return orders_active.Size() > 0; }

  /**
   * Check if current bar has active order.
   */
  bool HasBarOrder(ENUM_ORDER_TYPE _cmd) {
    bool _result = false;
    Ref<Order> _order = order_last;

    if (_order.IsSet() && _order.Ptr().Get<ENUM_ORDER_TYPE>(ORDER_TYPE) == _cmd &&
        _order.Ptr().Get<long>(ORDER_TIME_SETUP) > GetChart().GetBarTime()) {
      _result = true;
    }

    if (!_result) {
      for (DictStructIterator<long, Ref<Order>> iter = orders_active.Begin(); iter.IsValid(); ++iter) {
        _order = iter.Value();
        if (_order.Ptr().Get<ENUM_ORDER_TYPE>(ORDER_TYPE) == _cmd &&
            _order.Ptr().Get<long>(ORDER_TIME_SETUP) > GetChart().GetBarTime()) {
          _result = true;
          break;
        }
      }
    }
    return _result;
  }

  /**
   * Checks if we have already better priced opened order.
   */
  bool HasOrderBetter(ENUM_ORDER_TYPE _cmd) {
    bool _result = false;
    Ref<Order> _order = order_last;
    OrderData _odata;
    double _price_curr = GetChart().GetOpenOffer(_cmd);

    if (_order.IsSet() && _order.Ptr().IsOpen()) {
      if (_odata.Get<ENUM_ORDER_TYPE>(ORDER_TYPE) == _cmd) {
        switch (_cmd) {
          case ORDER_TYPE_BUY:
            _result |= _odata.Get<float>(ORDER_PRICE_OPEN) <= _price_curr;
            break;
          case ORDER_TYPE_SELL:
            _result |= _odata.Get<float>(ORDER_PRICE_OPEN) >= _price_curr;
            break;
        }
      }
    }

    if (!_result) {
      for (DictStructIterator<long, Ref<Order>> iter = orders_active.Begin(); iter.IsValid() && !_result; ++iter) {
        _order = iter.Value();
        if (_order.IsSet() && _order.Ptr().IsOpen()) {
          if (_odata.Get<ENUM_ORDER_TYPE>(ORDER_TYPE) == _cmd) {
            switch (_cmd) {
              case ORDER_TYPE_BUY:
                _result |= _odata.Get<float>(ORDER_PRICE_OPEN) <= _price_curr;
                break;
              case ORDER_TYPE_SELL:
                _result |= _odata.Get<float>(ORDER_PRICE_OPEN) >= _price_curr;
                break;
            }
          }
        }
      }
    }
    return _result;
  }

  /**
   * Checks if we have already order with the opposite type.
   */
  bool HasOrderOppositeType(ENUM_ORDER_TYPE _cmd) {
    bool _result = false;
    Ref<Order> _order = order_last;
    OrderData _odata;
    double _price_curr = GetChart().GetOpenOffer(_cmd);

    if (_order.IsSet()) {
      _result = _odata.Get<ENUM_ORDER_TYPE>(ORDER_TYPE) != _cmd;
    }

    if (!_result) {
      for (DictStructIterator<long, Ref<Order>> iter = orders_active.Begin(); iter.IsValid() && !_result; ++iter) {
        _order = iter.Value();
        if (_order.IsSet()) {
          _result = _odata.Get<ENUM_ORDER_TYPE>(ORDER_TYPE) != _cmd;
          if (_result) {
            _result = _odata.Get<ENUM_ORDER_TYPE>(ORDER_TYPE) != _cmd;
            break;
          }
        }
      }
    }
    return _result;
  }

  /**
   * Checks if the trade has the given state.
   *
   * @param _state State to check.
   *
   * @return
   *   Returns true when in that state.
   */
  bool HasState(ENUM_TRADE_STATE _state) { return tstates.CheckState(_state); }

  /* Calculation methods */

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
  static bool OrderCalcMargin(ENUM_ORDER_TYPE _action,  // type of order
                              string _symbol,           // symbol name
                              double _volume,           // volume
                              double _price,            // open price
                              double &_margin           // variable for obtaining the margin value
  ) {
#ifdef __MQL4__
    // @todo: To test.
    _margin = GetMarginRequired(_symbol, _action);
    return _margin > 0;
#else  // __MQL5__
    return ::OrderCalcMargin(_action, _symbol, _volume, _price, _margin);
#endif
  }

  /**
   * Free margin required for opening a position with the volume of one lot in the appropriate direction.
   */
  static float GetMarginRequired(string _symbol, ENUM_ORDER_TYPE _cmd = ORDER_TYPE_BUY) {
#ifdef __MQL4__
    return MarketInfo(_symbol, MODE_MARGINREQUIRED);
#else
    // https://www.mql5.com/ru/forum/170952/page9#comment_4134898
    // https://www.mql5.com/en/docs/trading/ordercalcmargin
    double _margin_req;
    bool _result = Trade::OrderCalcMargin(_cmd, _symbol, 1, SymbolInfoStatic::GetAsk(_symbol), _margin_req);
    return _result ? (float)_margin_req : 0;
#endif
  }
  float GetMarginRequired(ENUM_ORDER_TYPE _cmd = ORDER_TYPE_BUY) {
    return GetMarginRequired(GetChart().GetSymbol(), _cmd);
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
    double risk_amount = account.GetTotalBalance() / 100 * tparams.risk_margin;
    double _ticks = fabs(_sl - GetChart().GetOpenOffer(_cmd)) / GetChart().GetTickSize();
    double lot_size1 = fmin(_sl, _ticks) > 0 ? risk_amount / (_sl * (_ticks / 100.0)) : 1;
    lot_size1 *= GetChart().GetVolumeMin();
    // double lot_size2 = 1 / (GetChart().GetTickValue() * sl / risk_margin);
    // PrintFormat("SL=%g: 1 = %g, 2 = %g", sl, lot_size1, lot_size2);
    return NormalizeLots(lot_size1);
  }
  double GetMaxLotSize(unsigned int _pips, ENUM_ORDER_TYPE _cmd = NULL) {
    return GetMaxLotSize(CalcOrderSLTP(_pips, _cmd, ORDER_TYPE_SL));
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
  double OptimizeLotSize(double lots, double win_factor = 1.0, double loss_factor = 1.0, int ols_orders = 100,
                         string _symbol = NULL) {
    double lotsize = lots;
    int wins = 0, losses = 0;    // Number of consequent losing orders.
    int twins = 0, tlosses = 0;  // Total number of consequent losing orders.
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
    int _orders = TradeHistoryStatic::HistoryOrdersTotal();
    for (int i = _orders - 1; i >= fmax(0, _orders - ols_orders); i--) {
#ifdef __MQL5__
      /* @fixme: Rewrite without using CDealInfo.
      deal.Ticket(HistoryDealGetTicket(i));
      if (deal.Ticket() == 0) {
        Print(__FUNCTION__, ": Error in history!");
        break;
      }
      if (deal.Symbol() != GetChart().GetSymbol()) continue;
      double profit = deal.Profit();
      */
      double profit = 0;
#else
      if (Order::OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false) {
        Print(__FUNCTION__, ": Error in history!");
        break;
      }
      if (Order::OrderSymbol() != Symbol() || Order::OrderType() > ORDER_TYPE_SELL) continue;
      double profit = OrderStatic::Profit();
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
    lotsize = twins > 1 ? lotsize + (lotsize / 100 * win_factor * twins) : lotsize;
    lotsize = tlosses > 1 ? lotsize + (lotsize / 100 * loss_factor * tlosses) : lotsize;
    return NormalizeLots(lotsize);
  }

  /**
   * Calculate size of the lot based on the free margin or balance.
   *
   * @param
   *   _risk_margin (double) Risk margin in %.
   *   ...
   *
   * @return
   *   Returns calculated lot size (volume).
   */
  float CalcLotSize(float _risk_margin = 1,   // Risk margin in %.
                    float _risk_ratio = 1.0,  // Risk ratio factor.
                    uint _orders_avg = 10,    // Number of orders to use for the calculation.
                    uint _method = 0          // Method of calculation (0-3).
  ) {
    float _avail_amount = _method % 2 == 0 ? account.GetMarginAvail() : account.GetTotalBalance();
    float _lot_size_min = (float)GetChart().GetVolumeMin();
    float _lot_size = _lot_size_min;
    float _risk_value = (float)account.GetLeverage();
    if (_method == 0 || _method == 1) {
      float _margin_req = GetMarginRequired();
      if (_margin_req > 0) {
        _lot_size = _avail_amount / _margin_req * _risk_ratio;
        _lot_size /= _risk_value * _risk_ratio * _orders_avg;
      }
    } else {
      float _risk_amount = _avail_amount / 100 * _risk_margin;
      float _money_value = Convert::MoneyToValue(_risk_amount, _lot_size_min, GetChart().GetSymbol());
      float _tick_value = GetChart().GetTickSize();
      // @todo: Improves calculation logic.
      _lot_size = _money_value * _tick_value * _risk_ratio / _risk_value / 100;
    }
    _lot_size = (float)fmin(_lot_size, GetChart().GetVolumeMax());
    return (float)NormalizeLots(_lot_size);
  }

  /* Orders methods */

  /**
   * Open an order.
   */
  bool OrderAdd(Order *_order) {
    bool _result = false;
    unsigned int _last_error = _order.Get<unsigned int>(ORDER_PROP_LAST_ERROR);
    logger.Link(_order.GetLogger());
    Ref<Order> _ref_order = _order;
    switch (_last_error) {
      case 69539:
        logger.Error("Error while opening an order!", __FUNCTION_LINE__,
                     StringFormat("Code: %d, Msg: %s", _last_error, Terminal::GetErrorText(_last_error)));
        tstats.Add(TRADE_STAT_ORDERS_ERRORS);
        // Pass-through.
      case ERR_NO_ERROR:
        orders_active.Set(_order.Get<ulong>(ORDER_PROP_TICKET), _ref_order);
        order_last = _order;
        tstates.AddState(TRADE_STATE_ORDERS_ACTIVE);
        tstats.Add(TRADE_STAT_ORDERS_OPENED);
        // Trigger: OnOrder();
        _result = true;
        break;
      case TRADE_RETCODE_INVALID:
        logger.Error("Cannot process order!", __FUNCTION_LINE__,
                     StringFormat("Code: %d, Msg: %s", _last_error, Terminal::GetErrorText(_last_error)));
        break;
      default:
        logger.Error("Cannot add order!", __FUNCTION_LINE__,
                     StringFormat("Code: %d, Msg: %s", _last_error, Terminal::GetErrorText(_last_error)));
        tstats.Add(TRADE_STAT_ORDERS_ERRORS);
        _result = false;
        break;
    }
    UpdateStates(true);
    return _result;
  }

  /**
   * Moves active order to history.
   */
  bool OrderMoveToHistory(Order *_order) {
    _order.Refresh(true);
    orders_active.Unset(_order.Get<ulong>(ORDER_PROP_TICKET));
    Ref<Order> _ref_order = _order;
    bool result = orders_history.Set(_order.Get<ulong>(ORDER_PROP_TICKET), _ref_order);
    /* @todo
    if (strategy != NULL) {
      strategy.OnOrderClose(_order);
    }
    */
    // Update stats.
    tstats.Add(TRADE_STAT_ORDERS_CLOSED);
    // Update states.
    tstates.SetState(TRADE_STATE_ORDERS_ACTIVE, orders_active.Size() > 0);
    tstates.RemoveState(TRADE_STATE_ORDERS_MAX_HARD);
    tstates.RemoveState(TRADE_STATE_ORDERS_MAX_SOFT);
    return result;
  }
  bool OrderMoveToHistory(unsigned long _ticket) {
    Ref<Order> _order = orders_active.GetByKey(_ticket);
    return OrderMoveToHistory(_order.Ptr());
  }

  /**
   * Refresh active orders.
   */
  bool RefreshActiveOrders(bool _force = true, bool _first_close = false) {
    bool _result = true;
    for (DictStructIterator<long, Ref<Order>> iter = orders_active.Begin(); iter.IsValid(); ++iter) {
      Ref<Order> _order = iter.Value();
      if (_order.IsSet()) {
        _order.Ptr().Refresh(_force);
        if (_order.Ptr().IsClosed()) {
          _result &= OrderMoveToHistory(_order.Ptr());
          if (_first_close) {
            break;
          }
        }
      }
    }
    return _result;
  }

  /**
   * Sends a trade request.
   */
  bool RequestSend(MqlTradeRequest &_request, OrderParams &_oparams) {
    bool _result = false;
    switch (_request.action) {
      case TRADE_ACTION_CLOSE_BY:
        break;
      case TRADE_ACTION_DEAL:
        if (!IsTradeRecommended()) {
          // logger.Warning("Trade not recommended!", __FUNCTION_LINE__, (string)tstates.GetStates());
          return _result;
        } else if (account.GetAccountFreeMarginCheck(_request.type, _request.volume) == 0) {
          logger.Error("No free margin to open a new trade!", __FUNCTION_LINE__);
        }
        break;
      case TRADE_ACTION_MODIFY:
        break;
      case TRADE_ACTION_PENDING:
        break;
      case TRADE_ACTION_REMOVE:
        break;
      case TRADE_ACTION_SLTP:
        break;
    }
    Order *_order = new Order(_request, _oparams);
    _result = OrderAdd(_order);
    if (_result) {
      OnOrderOpen(_order);
    }
    return _result;
  }
  bool RequestSend(MqlTradeRequest &_request) {
    OrderParams _oparams;
    return RequestSend(_request, _oparams);
  }

  /**
   * Loads an existing order.
   */
  bool OrderLoad(Order *_order) {
    bool _result = false;
    Ref<Order> _order_ref = _order;
    if (_order.IsOpen()) {
      // @todo: _order.IsPending()?
      _result &= orders_active.Set(_order.Get<long>(ORDER_PROP_TICKET), _order_ref);
    } else {
      _result &= orders_history.Set(_order.Get<long>(ORDER_PROP_TICKET), _order_ref);
    }
    return _result && GetLastError() == ERR_NO_ERROR;
  }

  /**
   * Loads active orders by magic number.
   */
  bool OrdersLoadByMagic(unsigned long _magic_no) {
    ResetLastError();
    int _total_active = TradeStatic::TotalActive();
    for (int pos = 0; pos < _total_active; pos++) {
      if (OrderStatic::SelectByPosition(pos)) {
        if (OrderStatic::MagicNumber() == _magic_no) {
          unsigned long _ticket = OrderStatic::Ticket();
          Ref<Order> _order = new Order(_ticket);
          orders_active.Set(_ticket, _order);
        }
      }
    }
    return GetLastError() == ERR_NO_ERROR;
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
  int OrdersCloseAll(ENUM_ORDER_REASON_CLOSE _reason = ORDER_REASON_CLOSED_ALL, string _comment = "") {
    int _oid = 0, _closed = 0;
    Ref<Order> _order;
    _comment = _comment != "" ? _comment : __FUNCTION__;
    for (DictStructIterator<long, Ref<Order>> iter = orders_active.Begin(); iter.IsValid(); ++iter) {
      _order = iter.Value();
      if (_order.Ptr().IsOpen()) {
        _order.Ptr().Refresh();
        if (_order.Ptr().OrderClose(_reason, _comment)) {
          _closed++;
          OrderMoveToHistory(_order.Ptr());
          order_last = _order;
        } else {
          logger.AddLastError(__FUNCTION_LINE__, _order.Ptr().Get<ulong>(ORDER_PROP_LAST_ERROR));
          return -1;
        }
      }
      OrderMoveToHistory(_order.Ptr());
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
  int OrdersCloseViaCmd(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_REASON_CLOSE _reason = ORDER_REASON_CLOSED_UNKNOWN,
                        string _comment = "") {
    int _oid = 0, _closed = 0;
    Ref<Order> _order;
    _comment = _comment != "" ? _comment : __FUNCTION__;
    for (DictStructIterator<long, Ref<Order>> iter = orders_active.Begin(); iter.IsValid(); ++iter) {
      _order = iter.Value();
      if (_order.Ptr().IsOpen()) {
        _order.Ptr().Refresh();
        if (_order.Ptr().GetRequest().type == _cmd) {
          if (_order.Ptr().OrderClose(_reason, _comment)) {
            _closed++;
            OrderMoveToHistory(_order.Ptr());
            order_last = _order;
          } else {
            logger.Error("Error while closing order!", __FUNCTION_LINE__,
                         StringFormat("Code: %d", _order.Ptr().Get<ulong>(ORDER_PROP_LAST_ERROR)));
            return -1;
          }
          order_last = _order;
        }
      } else {
        OrderMoveToHistory(_order.Ptr());
      }
    }
    return _closed;
  }

  /**
   * Close orders based on the property value and math condition.
   *
   * Note: It will only affect trades managed by this class instance.
   *
   * @return
   *   Returns number of successfully closed trades.
   *   On error, returns -1.
   */
  template <typename E, typename T>
  int OrdersCloseViaProp(E _prop, T _value, ENUM_MATH_CONDITION _op,
                         ENUM_ORDER_REASON_CLOSE _reason = ORDER_REASON_CLOSED_UNKNOWN, string _comment = "") {
    int _oid = 0, _closed = 0;
    Ref<Order> _order;
    _comment = _comment != "" ? _comment : __FUNCTION__;
    for (DictStructIterator<long, Ref<Order>> iter = orders_active.Begin(); iter.IsValid(); ++iter) {
      _order = iter.Value();
      if (_order.Ptr().IsOpen()) {
        _order.Ptr().Refresh();
        if (Math::Compare(_order.Ptr().Get<T>((E)_prop), _value, _op)) {
          if (_order.Ptr().OrderClose(_reason, _comment)) {
            _closed++;
            OrderMoveToHistory(_order.Ptr());
            order_last = _order;
          } else {
            logger.AddLastError(__FUNCTION_LINE__, _order.Ptr().Get<ulong>(ORDER_PROP_LAST_ERROR));
            return -1;
          }
        }
      } else {
        OrderMoveToHistory(_order.Ptr());
      }
    }
    return _closed;
  }

  /**
   * Close orders based on the two property values of the same type and math condition.
   *
   * Note: It will only affect trades managed by this class instance.
   *
   * @return
   *   Returns number of successfully closed trades.
   *   On error, returns -1.
   */
  template <typename E, typename T>
  int OrdersCloseViaProp2(E _prop1, T _value1, E _prop2, T _value2, ENUM_MATH_CONDITION _op,
                          ENUM_ORDER_REASON_CLOSE _reason = ORDER_REASON_CLOSED_UNKNOWN, string _comment = "") {
    int _oid = 0, _closed = 0;
    Ref<Order> _order;
    _comment = _comment != "" ? _comment : __FUNCTION__;
    for (DictStructIterator<long, Ref<Order>> iter = orders_active.Begin(); iter.IsValid(); ++iter) {
      _order = iter.Value();
      if (_order.Ptr().IsOpen()) {
        _order.Ptr().Refresh();
        if (Math::Compare(_order.Ptr().Get<T>((E)_prop1), _value1, _op) &&
            Math::Compare(_order.Ptr().Get<T>((E)_prop2), _value2, _op)) {
          if (!_order.Ptr().OrderClose(_reason, _comment)) {
            logger.AddLastError(__FUNCTION_LINE__, _order.Ptr().Get<unsigned int>(ORDER_PROP_LAST_ERROR));
            return -1;
          }
          order_last = _order;
          _closed++;
        }
      } else {
        OrderMoveToHistory(_order.Ptr());
      }
    }
    return _closed;
  }

  /**
   * Calculate available lot size given the risk margin.
   */
  /* @fixme
  uint CalcMaxLotSize(double risk_margin = 1.0) {
    double _avail_margin = account.AccountAvailMargin();
    double _opened_lots = GetTrades().GetOpenLots();
    // @todo
    return 0;
  }
  */

  /**
   * Calculate number of allowed orders to open.
   */
  unsigned long CalcMaxOrders(float volume_size, float _risk_ratio = 1.0, long prev_max_orders = 0, long hard_limit = 0,
                              bool smooth = true) {
    float _avail_margin = fmin(account.GetMarginFree(), account.GetBalance() + account.GetCredit());
    if (_avail_margin == 0 || volume_size == 0) {
      return 0;
    }
    float _margin_required = GetMarginRequired();
    float _avail_orders = _avail_margin / _margin_required / volume_size;
    long new_max_orders = (long)(_avail_orders * _risk_ratio);
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
   * Calculates the best SL/TP value for the order given the limits.
   */
  float CalcBestSLTP(float _value,                 // Suggested value.
                     float _max_pips,              // Maximal amount of pips.
                     ENUM_ORDER_TYPE_VALUE _mode,  // Type of value (stop loss or take profit).
                     ENUM_ORDER_TYPE _cmd = NULL,  // Order type (e.g. buy or sell).
                     float _lot_size = 0           // Lot size of the order.
  ) {
    float _max_value1 = _max_pips > 0 ? CalcOrderSLTP(_max_pips, _cmd, _mode) : 0;
    float _max_value2 = tparams.risk_margin > 0 ? GetMaxSLTP(_cmd, _lot_size, _mode) : 0;
    float _res = (float)GetChart().NormalizePrice(GetSaferSLTP(_value, _max_value1, _max_value2, _cmd, _mode));
    // PrintFormat("%s/%s: Value: %g", EnumToString(_cmd), EnumToString(_mode), _value);
    // PrintFormat("%s/%s: Max value 1: %g", EnumToString(_cmd), EnumToString(_mode), _max_value1);
    // PrintFormat("%s/%s: Max value 2: %g", EnumToString(_cmd), EnumToString(_mode), _max_value2);
    // PrintFormat("%s/%s: Result: %g", EnumToString(_cmd), EnumToString(_mode), _res);
    return _res;
  }

  /**
   * Returns value of stop loss for the new order given the pips value.
   */
  float CalcOrderSLTP(float _value,                // Value in pips.
                      ENUM_ORDER_TYPE _cmd,        // Order type (e.g. buy or sell).
                      ENUM_ORDER_TYPE_VALUE _mode  // Type of value (stop loss or take profit).
  ) {
    double _price = _cmd == NULL ? Order::OrderOpenPrice() : GetChart().GetOpenOffer(_cmd);
    _cmd = _cmd == NULL ? Order::OrderType() : _cmd;
    // PrintFormat("#%d: %s/%s: %g (%g/%g) + %g * %g * %g = %g", Order::OrderTicket(), EnumToString(_cmd),
    // EnumToString(_mode), _price, Bid, Ask, _value, GetChart().GetPipSize(), Order::OrderDirection(_cmd, _mode),
    // GetChart().GetOpenOffer(_cmd) + _value * GetChart().GetPipSize() * Order::OrderDirection(_cmd, _mode));
    return _value > 0 ? float(_price + _value * GetChart().GetPipSize() * Order::OrderDirection(_cmd, _mode)) : 0;
  }
  float CalcOrderSL(float _value, ENUM_ORDER_TYPE _cmd) { return CalcOrderSLTP(_value, _cmd, ORDER_TYPE_SL); }
  float CalcOrderTP(float _value, ENUM_ORDER_TYPE _cmd) { return CalcOrderSLTP(_value, _cmd, ORDER_TYPE_TP); }

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
  float GetMaxSLTP(ENUM_ORDER_TYPE _cmd = NULL, float _lot_size = 0, ENUM_ORDER_TYPE_VALUE _mode = ORDER_TYPE_SL,
                   float _risk_margin = 1.0) {
    double _price = _cmd == NULL ? Order::OrderOpenPrice() : GetChart().GetOpenOffer(_cmd);
    // For the new orders, use the available margin for calculation, otherwise use the account balance.
    float _margin = Convert::MoneyToValue(
        (_cmd == NULL ? account.GetMarginAvail() : account.GetTotalBalance()) / 100 * _risk_margin, _lot_size,
        GetChart().GetSymbol());
    _cmd = _cmd == NULL ? Order::OrderType() : _cmd;
    // @fixme
    // _lot_size = _lot_size <= 0 ? fmax(Order::OrderLots(), GetChart().GetVolumeMin()) : _lot_size;
    return (float)_price +
           GetTradeDistanceInValue()
           // + Convert::MoneyToValue(account.GetTotalBalance() / 100 * _risk_margin, _lot_size)
           // + Convert::MoneyToValue(account.GetMarginAvail() / 100 * _risk_margin, _lot_size)
           + _margin * Order::OrderDirection(_cmd, _mode);
  }
  float GetMaxSL(ENUM_ORDER_TYPE _cmd = NULL, float _lot_size = 0, float _risk_margin = 1.0) {
    return GetMaxSLTP(_cmd, _lot_size, ORDER_TYPE_SL, _risk_margin);
  }
  float GetMaxTP(ENUM_ORDER_TYPE _cmd = NULL, float _lot_size = 0, float _risk_margin = 1.0) {
    return GetMaxSLTP(_cmd, _lot_size, ORDER_TYPE_TP, _risk_margin);
  }

  /**
   * Returns safer SL/TP based on the two SL or TP input values.
   */
  double GetSaferSLTP(double _value1, double _value2, ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode) {
    if (_value1 <= 0 || _value2 <= 0) {
      return NormalizeSLTP(fmax(_value1, _value2), _cmd, _mode);
    }
    switch (_cmd) {
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_BUY:
        switch (_mode) {
          case ORDER_TYPE_SL:
            return NormalizeSLTP(_value1 > _value2 ? _value1 : _value2, _cmd, _mode);
          case ORDER_TYPE_TP:
            return NormalizeSLTP(_value1 < _value2 ? _value1 : _value2, _cmd, _mode);
          default:
            logger.Error(StringFormat("Invalid mode: %s!", EnumToString(_mode), __FUNCTION__));
        }
        break;
      case ORDER_TYPE_SELL_LIMIT:
      case ORDER_TYPE_SELL:
        switch (_mode) {
          case ORDER_TYPE_SL:
            return NormalizeSLTP(_value1 < _value2 ? _value1 : _value2, _cmd, _mode);
          case ORDER_TYPE_TP:
            return NormalizeSLTP(_value1 > _value2 ? _value1 : _value2, _cmd, _mode);
          default:
            logger.Error(StringFormat("Invalid mode: %s!", EnumToString(_mode), __FUNCTION__));
        }
        break;
      default:
        logger.Error(StringFormat("Invalid order type: %s!", EnumToString(_cmd), __FUNCTION__));
    }
    return EMPTY_VALUE;
  }
  double GetSaferSLTP(double _value1, double _value2, double _value3, ENUM_ORDER_TYPE _cmd,
                      ENUM_ORDER_TYPE_VALUE _mode) {
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
   * Get a market distance in points.
   *
   * Minimal permissible distance value in points for StopLoss/TakeProfit.
   *
   * This is due that at placing of a pending order, the open price cannot be too close to the market.
   * The minimal distance of the pending price from the current market one in points can be obtained
   * using the MarketInfo() function with the MODE_STOPLEVEL parameter.
   * Related error messages:
   *   Error 130 (ERR_INVALID_STOPS) happens In case of false open price of a pending order.
   *   Error 145 (ERR_TRADE_MODIFY_DENIED) happens when modification of order was too close to market.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  static long GetTradeDistanceInPts(string _symbol) {
    return fmax(SymbolInfoStatic::GetTradeStopsLevel(_symbol), SymbolInfoStatic::GetFreezeLevel(_symbol));
  }
  long GetTradeDistanceInPts() { return GetTradeDistanceInPts(GetChart().GetSymbol()); }

  /**
   * Get a market distance in pips.
   *
   * Minimal permissible distance value in pips for StopLoss/TakeProfit.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  static double GetTradeDistanceInPips(string _symbol) {
    unsigned int _pts_per_pip = SymbolInfoStatic::GetPointsPerPip(_symbol);
    return (double)(_pts_per_pip > 0 ? (GetTradeDistanceInPts(_symbol) / _pts_per_pip) : 0);
  }
  double GetTradeDistanceInPips() { return GetTradeDistanceInPips(GetChart().GetSymbol()); }

  /**
   * Get a market gap in value.
   *
   * Minimal permissible distance value in value for StopLoss/TakeProfit.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  static double GetTradeDistanceInValue(string _symbol) {
    return Trade::GetTradeDistanceInPts(_symbol) * SymbolInfoStatic::GetPointSize(_symbol);
  }
  float GetTradeDistanceInValue() { return (float)GetTradeDistanceInValue(GetChart().GetSymbol()); }

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
    string symbol = GetChart().GetSymbol();
    if (_last_trend_check == Chart().GetBarTime(_tf)) {
      return _last_trend;
    }
    double bull = 0, bear = 0;
    int _counter = 0;

    if (simple && method != 0) {
      if ((method & 1) != 0) {
        if (Chart().GetOpen(PERIOD_MN1, 0) > Chart().GetClose(PERIOD_MN1, 1)) bull++;
        if (Chart().GetOpen(PERIOD_MN1, 0) < Chart().GetClose(PERIOD_MN1, 1)) bear++;
      }
      if ((method & 2) != 0) {
        if (Chart().GetOpen(PERIOD_W1, 0) > Chart().GetClose(PERIOD_W1, 1)) bull++;
        if (Chart().GetOpen(PERIOD_W1, 0) < Chart().GetClose(PERIOD_W1, 1)) bear++;
      }
      if ((method & 4) != 0) {
        if (Chart().GetOpen(PERIOD_D1, 0) > Chart().GetClose(PERIOD_D1, 1)) bull++;
        if (Chart().GetOpen(PERIOD_D1, 0) < Chart().GetClose(PERIOD_D1, 1)) bear++;
      }
      if ((method & 8) != 0) {
        if (Chart().GetOpen(PERIOD_H4, 0) > Chart().GetClose(PERIOD_H4, 1)) bull++;
        if (Chart().GetOpen(PERIOD_H4, 0) < Chart().GetClose(PERIOD_H4, 1)) bear++;
      }
      if ((method & 16) != 0) {
        if (Chart().GetOpen(PERIOD_H1, 0) > Chart().GetClose(PERIOD_H1, 1)) bull++;
        if (Chart().GetOpen(PERIOD_H1, 0) < Chart().GetClose(PERIOD_H1, 1)) bear++;
      }
      if ((method & 32) != 0) {
        if (Chart().GetOpen(PERIOD_M30, 0) > Chart().GetClose(PERIOD_M30, 1)) bull++;
        if (Chart().GetOpen(PERIOD_M30, 0) < Chart().GetClose(PERIOD_M30, 1)) bear++;
      }
      if ((method & 64) != 0) {
        if (Chart().GetOpen(PERIOD_M15, 0) > Chart().GetClose(PERIOD_M15, 1)) bull++;
        if (Chart().GetOpen(PERIOD_M15, 0) < Chart().GetClose(PERIOD_M15, 1)) bear++;
      }
      if ((method & 128) != 0) {
        if (Chart().GetOpen(PERIOD_M5, 0) > Chart().GetClose(PERIOD_M5, 1)) bull++;
        if (Chart().GetOpen(PERIOD_M5, 0) < Chart().GetClose(PERIOD_M5, 1)) bear++;
      }
      // if (Chart().GetOpen(PERIOD_H12, 0) > Chart().GetClose(PERIOD_H12, 1)) bull++;
      // if (Chart().GetOpen(PERIOD_H12, 0) < Chart().GetClose(PERIOD_H12, 1)) bear++;
      // if (Chart().GetOpen(PERIOD_H8, 0) > Chart().GetClose(PERIOD_H8, 1)) bull++;
      // if (Chart().GetOpen(PERIOD_H8, 0) < Chart().GetClose(PERIOD_H8, 1)) bear++;
      // if (Chart().GetOpen(PERIOD_H6, 0) > Chart().GetClose(PERIOD_H6, 1)) bull++;
      // if (Chart().GetOpen(PERIOD_H6, 0) < Chart().GetClose(PERIOD_H6, 1)) bear++;
      // if (Chart().GetOpen(PERIOD_H2, 0) > Chart().GetClose(PERIOD_H2, 1)) bull++;
      // if (Chart().GetOpen(PERIOD_H2, 0) < Chart().GetClose(PERIOD_H2, 1)) bear++;
    } else if (method != 0) {
      if ((method % 1) == 0) {
        for (_counter = 0; _counter < 3; _counter++) {
          if (Chart().GetOpen(PERIOD_MN1, _counter) > Chart().GetClose(PERIOD_MN1, _counter + 1))
            bull += 30;
          else if (Chart().GetOpen(PERIOD_MN1, _counter) < Chart().GetClose(PERIOD_MN1, _counter + 1))
            bear += 30;
        }
      }
      if ((method % 2) == 0) {
        for (_counter = 0; _counter < 8; _counter++) {
          if (Chart().GetOpen(PERIOD_W1, _counter) > Chart().GetClose(PERIOD_W1, _counter + 1))
            bull += 7;
          else if (Chart().GetOpen(PERIOD_W1, _counter) < Chart().GetClose(PERIOD_W1, _counter + 1))
            bear += 7;
        }
      }
      if ((method % 4) == 0) {
        for (_counter = 0; _counter < 7; _counter++) {
          if (Chart().GetOpen(PERIOD_D1, _counter) > Chart().GetClose(PERIOD_D1, _counter + 1))
            bull += 1440 / 1440;
          else if (Chart().GetOpen(PERIOD_D1, _counter) < Chart().GetClose(PERIOD_D1, _counter + 1))
            bear += 1440 / 1440;
        }
      }
      if ((method % 8) == 0) {
        for (_counter = 0; _counter < 24; _counter++) {
          if (Chart().GetOpen(PERIOD_H4, _counter) > Chart().GetClose(PERIOD_H4, _counter + 1))
            bull += 240 / 1440;
          else if (Chart().GetOpen(PERIOD_H4, _counter) < Chart().GetClose(PERIOD_H4, _counter + 1))
            bear += 240 / 1440;
        }
      }
      if ((method % 16) == 0) {
        for (_counter = 0; _counter < 24; _counter++) {
          if (Chart().GetOpen(PERIOD_H1, _counter) > Chart().GetClose(PERIOD_H1, _counter + 1))
            bull += 60 / 1440;
          else if (Chart().GetOpen(PERIOD_H1, _counter) < Chart().GetClose(PERIOD_H1, _counter + 1))
            bear += 60 / 1440;
        }
      }
      if ((method % 32) == 0) {
        for (_counter = 0; _counter < 48; _counter++) {
          if (Chart().GetOpen(PERIOD_M30, _counter) > Chart().GetClose(PERIOD_M30, _counter + 1))
            bull += 30 / 1440;
          else if (Chart().GetOpen(PERIOD_M30, _counter) < Chart().GetClose(PERIOD_M30, _counter + 1))
            bear += 30 / 1440;
        }
      }
      if ((method % 64) == 0) {
        for (_counter = 0; _counter < 96; _counter++) {
          if (Chart().GetOpen(PERIOD_M15, _counter) > Chart().GetClose(PERIOD_M15, _counter + 1))
            bull += 15 / 1440;
          else if (Chart().GetOpen(PERIOD_M15, _counter) < Chart().GetClose(PERIOD_M15, _counter + 1))
            bear += 15 / 1440;
        }
      }
      if ((method % 128) == 0) {
        for (_counter = 0; _counter < 288; _counter++) {
          if (Chart().GetOpen(PERIOD_M5, _counter) > Chart().GetClose(PERIOD_M5, _counter + 1))
            bull += 5 / 1440;
          else if (Chart().GetOpen(PERIOD_M5, _counter) < Chart().GetClose(PERIOD_M5, _counter + 1))
            bear += 5 / 1440;
        }
      }
    }
    _last_trend = (bull - bear);
    _last_trend_check = Chart().GetBarTime(_tf, 0);
    logger.Debug(StringFormat("%s: %g", __FUNCTION__, _last_trend));
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
    return _curr_trend == 0 ? (ENUM_ORDER_TYPE)(ORDER_TYPE_BUY + ORDER_TYPE_SELL)
                            : (_curr_trend > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
  }

  /* Trade states */

  /**
   * Update trade states.
   *
   * @param _force Whether to force the update
   *
   * @return
   *   Returns true on no errors.
   *
   */
  bool UpdateStates(bool _force = false) {
    static datetime _last_check = 0;
    static unsigned int _states_prev = tstates.GetStates();
    ResetLastError();
    if (_force || _last_check + 60 < TimeCurrent()) {
      // Infrequent checks (each minute).
      /* Limit checks */
      tstates.SetState(TRADE_STATE_PERIOD_LIMIT_REACHED, tparams.IsLimitGe(tstats));
      /* Margin checks */
      tstates.SetState(TRADE_STATE_MARGIN_MAX_SOFT, tparams.GetRiskMargin() > 0
                                                        // Check if maximum margin allowed to use is reached.
                                                        && account.GetMarginUsedInPct() > tparams.GetRiskMargin());
      /* Money checks */
      tstates.SetState(TRADE_STATE_MONEY_NOT_ENOUGH, account.GetMarginFreeInPct() <= 0.1);
      /* Orders checks */
      tstates.SetState(TRADE_STATE_ORDERS_ACTIVE, orders_active.Size() > 0);
      // Check the limit on the number of active pending orders has reached the limit set by the broker.
      // @see: https://www.mql5.com/en/articles/2555#account_limit_pending_orders
      tstates.SetState(TRADE_STATE_ORDERS_MAX_HARD, OrdersTotal() == account.GetLimitOrders());
      // @todo: TRADE_STATE_ORDERS_MAX_SOFT
      tstates.SetState(TRADE_STATE_TRADE_NOT_POSSIBLE,
                       // Check if the EA trading is enabled.
                       (account.IsExpertEnabled() || !Terminal::IsRealtime())
                           // Check if there is a permission to trade.
                           && Terminal::CheckPermissionToTrade()
                           // Check if auto trading is enabled.
                           && (Terminal::IsRealtime() && !Terminal::IsExpertEnabled()));
      /* Chart checks */
      tstates.SetState(TRADE_STATE_BARS_NOT_ENOUGH, GetChart().GetBars() < tparams.GetBarsMin());
      /* Terminal checks */
      tstates.SetState(TRADE_STATE_TRADE_NOT_ALLOWED,
                       // Check if real trading is allowed.
                       (Terminal::IsRealtime() && !Terminal::IsTradeAllowed())
                           // Check the permission to trade for the current account.
                           && !Account::IsTradeAllowed());
      tstates.SetState(TRADE_STATE_TRADE_TERMINAL_BUSY, Terminal::IsTradeContextBusy());
      _last_check = TimeCurrent();
      /* Terminal checks */
      // Check if terminal is connected.
      tstates.SetState(TRADE_STATE_TRADE_TERMINAL_OFFLINE, Terminal::IsRealtime() && !Terminal::IsConnected());
      // Check if terminal is stopping.
      tstates.SetState(TRADE_STATE_TRADE_TERMINAL_SHUTDOWN, IsStopped());
      // Check for new states.
      if (tstates.GetStates() != _states_prev) {
        for (int _bi = 0; _bi < sizeof(int) * 8; _bi++) {
          bool _enabled = tstates.CheckState(1 << _bi) > TradeStates::CheckState(1 << _bi, _states_prev);
          if (_enabled && (ENUM_TRADE_STATE)(1 << _bi) != TRADE_STATE_ORDERS_ACTIVE) {
            logger.Warning(TradeStates::GetStateMessage((ENUM_TRADE_STATE)(1 << _bi)), GetName());
          }
        }
        _states_prev = tstates.GetStates();
      }
    }
    return GetLastError() == ERR_NO_ERROR;
  }

  /* Normalization methods */

  /**
   * Normalize lot size.
   */
  double NormalizeLots(double _lots, bool _ceil = false) {
    double _lot_size = _lots;
    double _vol_min = GetChart().GetVolumeMin();
    double _vol_step = GetChart().GetVolumeStep() > 0.0 ? GetChart().GetVolumeStep() : _vol_min;
    if (_vol_step > 0) {
      // Related: http://forum.mql4.com/47988
      double _precision = 1 / _vol_step;
      // Edge case when step is higher than minimum.
      _lot_size = _ceil ? ceil(_lots * _precision) / _precision : floor(_lots * _precision) / _precision;
      double _min_lot = fmax(GetChart().GetVolumeMin(), GetChart().GetVolumeStep());
      _lot_size = fmin(fmax(_lot_size, _min_lot), GetChart().GetVolumeMax());
    }
    return NormalizeDouble(_lot_size, Math::FloatDigits(_vol_min));
  }

  /**
   * Normalize SL/TP values.
   */
  double NormalizeSLTP(double _value, ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode) {
    if (_value == 0) {
      // Do not normalize on zero.
      return _value;
    }
    switch (_cmd) {
      // Buying is done at the Ask price.
      // The TakeProfit and StopLoss levels must be at the distance
      // of at least SYMBOL_TRADE_STOPS_LEVEL points from the Bid price.
      case ORDER_TYPE_BUY:
        switch (_mode) {
          // Bid - StopLoss >= SYMBOL_TRADE_STOPS_LEVEL (minimum trade distance)
          case ORDER_TYPE_SL:
            return fmin(_value, GetChart().GetBid() - GetTradeDistanceInValue());
          // TakeProfit - Bid >= SYMBOL_TRADE_STOPS_LEVEL (minimum trade distance)
          case ORDER_TYPE_TP:
            return fmax(_value, GetChart().GetBid() + GetTradeDistanceInValue());
          default:
            logger.Error(StringFormat("Invalid mode: %s!", EnumToString(_mode), __FUNCTION__));
        }
        break;
      // Selling is done at the Bid price.
      // The TakeProfit and StopLoss levels must be at the distance
      // of at least SYMBOL_TRADE_STOPS_LEVEL points from the Ask price.
      case ORDER_TYPE_SELL:
        switch (_mode) {
          // StopLoss - Ask >= SYMBOL_TRADE_STOPS_LEVEL (minimum trade distance)
          case ORDER_TYPE_SL:
            return fmax(_value, GetChart().GetAsk() + GetTradeDistanceInValue());
          // Ask - TakeProfit >= SYMBOL_TRADE_STOPS_LEVEL (minimum trade distance)
          case ORDER_TYPE_TP:
            return fmin(_value, GetChart().GetAsk() - GetTradeDistanceInValue());
          default:
            logger.Error(StringFormat("Invalid mode: %s!", EnumToString(_mode), __FUNCTION__));
        }
        break;
      default:
        logger.Error(StringFormat("Invalid order type: %s!", EnumToString(_cmd), __FUNCTION__));
    }
    return NULL;
  }
  double NormalizeSL(double _value, ENUM_ORDER_TYPE _cmd) {
    return _value > 0 ? GetChart().NormalizePrice(NormalizeSLTP(_value, _cmd, ORDER_TYPE_SL)) : 0;
  }
  double NormalizeTP(double _value, ENUM_ORDER_TYPE _cmd) {
    return _value > 0 ? GetChart().NormalizePrice(NormalizeSLTP(_value, _cmd, ORDER_TYPE_TP)) : 0;
  }

  /* Validation methods */

  /**
   * Validate whether trade operation is permitted.
   *
   * @param int cmd
   *   Trade command.
   * @param int price
   *   Take profit or stop loss price value.

   * @return
   *   Returns true when trade operation is allowed.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  double IsValidOrderPrice(ENUM_ORDER_TYPE _cmd, double price) {
    double distance = GetTradeDistanceInValue();
    // bool result;
    switch (_cmd) {
      case ORDER_TYPE_BUY_STOP:
        // OpenPrice-Ask >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
      case ORDER_TYPE_BUY_LIMIT:
        // Ask-OpenPrice >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
      case ORDER_TYPE_BUY:
        // Bid-OpenPrice >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
      case ORDER_TYPE_SELL_LIMIT:
        // OpenPrice-Bid >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
      case ORDER_TYPE_SELL_STOP:
        // Bid-OpenPrice >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
      case ORDER_TYPE_SELL:
        // SL-Ask >= StopLevel && Ask-TP >= StopLevel
        // OpenPrice-Ask >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
        // PrintFormat("%g > %g", fmin(fabs(GetBid() - price), fabs(GetAsk() - price)), distance);
        return price > 0 && fmin(fabs(GetChart().GetBid() - price), fabs(GetChart().GetAsk() - price)) > distance;
      default:
        return (true);
    }
  }

  /**
   * Validate Stop Loss value for the order.
   */
  bool IsValidOrderSL(double _value, ENUM_ORDER_TYPE _cmd, double _value_prev = WRONG_VALUE, bool _locked = false) {
    bool _is_valid = _value >= 0 && _value != _value_prev;
    if (_value == 0 && _value == _value_prev) {
      return _is_valid;
    }
    double _min_distance = GetTradeDistanceInPips();
    double _price = GetChart().GetOpenOffer(_cmd);
    unsigned int _digits = GetChart().GetDigits();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _is_valid &= _value < _price && Convert::GetValueDiffInPips(_price, _value, true, _digits) > _min_distance;
        break;
      case ORDER_TYPE_SELL:
        _is_valid &= _value > _price && Convert::GetValueDiffInPips(_value, _price, true, _digits) > _min_distance;
        break;
      default:
        _is_valid &= false;
        break;
    }
    if (_is_valid && _value_prev > 0) {
      _is_valid &= Convert::GetValueDiffInPips(_value, _value_prev, true, _digits) > GetTradeDistanceInPips();
    }
#ifdef __debug__
    if (!_is_valid) {
      PrintFormat("%s(): Invalid stop for %s! Value: %g, price: %g", __FUNCTION__, EnumToString(_cmd), _value, _price);
    }
#endif
    if (_is_valid && _value_prev > 0 && _locked) {
      _is_valid &= _cmd == ORDER_TYPE_BUY && _value > _value_prev;
      _is_valid &= _cmd == ORDER_TYPE_SELL && _value < _value_prev;
    }
    return _is_valid;
  }

  /**
   * Validate whether trade operation is permitted.
   *
   * @param int cmd
   *   Trade command.
   * @param int sl
   *   Stop loss price value.
   * @param int tp
   *   Take profit price value.
   * @param string symbol
   *   Currency symbol.
   * @return
   *   Returns true when trade operation is allowed.
   *
   * @see: https://book.mql4.com/appendix/limits
   * @see: https://www.mql5.com/en/articles/2555#invalid_SL_TP_for_position
   */
  double IsValidOrderSLTP(ENUM_ORDER_TYPE _cmd, double sl, double tp) {
    double ask = GetChart().GetAsk();
    double bid = GetChart().GetBid();
    double openprice = GetChart().GetOpenOffer(_cmd);
    double closeprice = GetChart().GetCloseOffer(_cmd);
    // The minimum distance of SYMBOL_TRADE_STOPS_LEVEL taken into account.
    double distance = GetTradeDistanceInValue();
    // bool result;
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Buying is done at the Ask price.
        // Requirements for Minimum Distance Limitation:
        // - Bid - StopLoss >= StopLevel  && TakeProfit - Bid >= StopLevel
        // - Bid - StopLoss > FreezeLevel && TakeProfit - Bid > FreezeLevel
        /*
        result = sl > 0 && tp > 0 && bid - sl >= distance && tp - bid >= distance;
        PrintFormat("1. Buy: (%g - %g) = %g >= %g; %s", Bid, sl, (bid - sl), distance, result ? "true" : "false");
        PrintFormat("2. Buy: (%g - %g) = %g >= %g; %s", tp, Bid, (tp - Bid), distance, result ? "true" : "false");
        */
        // The TakeProfit and StopLoss levels must be at the distance of at least SYMBOL_TRADE_STOPS_LEVEL points from
        // the Bid price.
        return sl > 0 && tp > 0 && bid - sl >= distance && tp - bid >= distance;
      case ORDER_TYPE_SELL:
        // Selling is done at the Bid price.
        // Requirements for Minimum Distance Limitation:
        // - StopLoss - Ask >= StopLevel  && Ask - TakeProfit >= StopLevel
        // - StopLoss - Ask > FreezeLevel && Ask - TakeProfit > FreezeLevel
        /*
        result = sl > 0 && tp > 0 && sl - ask > distance && ask - tp > distance;
        PrintFormat("1. Sell: (%g - %g) = %g >= %g; %s",
          sl, Ask, (sl - Ask), distance, result ? "true" : "false");
        PrintFormat("2. Sell: (%g - %g) = %g >= %g; %s",
          Ask, tp, (ask - tp), distance, result ? "true" : "false");
        */
        // The TakeProfit and StopLoss levels must be at the distance of at least SYMBOL_TRADE_STOPS_LEVEL points from
        // the Ask price.
        return sl > 0 && tp > 0 && sl - ask > distance && ask - tp > distance;
      case ORDER_TYPE_BUY_LIMIT:
        // Requirements when performing trade operations:
        // - Ask-OpenPrice >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
        // - Open Price of a Pending Order is Below the current Ask price.
        // - Ask price reaches open price.
        return ask - openprice >= distance && openprice - sl >= distance && tp - openprice >= distance;
      case ORDER_TYPE_SELL_LIMIT:
        // Requirements when performing trade operations:
        // - OpenPrice-Bid >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
        // - Open Price of a Pending Order is Above the current Bid price.
        // - Bid price reaches open price.
        return openprice - bid >= distance && sl - openprice >= distance && openprice - tp >= distance;
      case ORDER_TYPE_BUY_STOP:
        // Requirements when performing trade operations:
        // - OpenPrice-Ask >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
        // - Open Price of a Pending Order is Above the current Ask price.
        // - Ask price reaches open price.
        return openprice - ask >= distance && openprice - sl >= distance && tp - openprice >= distance;
      case ORDER_TYPE_SELL_STOP:
        // Requirements when performing trade operations:
        // - Bid-OpenPrice >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
        // - Open Price of a Pending Order is Below the current Bid price.
        // - Bid price reaches open price.
        return bid - openprice >= distance && sl - openprice >= distance && openprice - tp >= distance;
      default:
        return (true);
    }
  }

  /**
   * Validate Take Profit value for the order.
   */
  bool IsValidOrderTP(double _value, ENUM_ORDER_TYPE _cmd, double _value_prev = WRONG_VALUE, bool _locked = false) {
    bool _is_valid = _value >= 0 && _value != _value_prev;
    if (_value == 0 && _value == _value_prev) {
      return _is_valid;
    }
    double _min_distance = GetTradeDistanceInPips();
    double _price = GetChart().GetOpenOffer(_cmd);
    unsigned int _digits = GetChart().GetDigits();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _is_valid &= _value > _price && Convert::GetValueDiffInPips(_value, _price, true, _digits) > _min_distance;
        break;
      case ORDER_TYPE_SELL:
        _is_valid &= _value < _price && Convert::GetValueDiffInPips(_price, _value, true, _digits) > _min_distance;
        break;
      default:
        _is_valid &= false;
        break;
    }
    if (_is_valid && _value_prev > 0) {
      _is_valid &= Convert::GetValueDiffInPips(_value, _value_prev, true, _digits) > GetTradeDistanceInPips();
    }
#ifdef __debug__
    if (!_is_valid) {
      PrintFormat("%s(): Invalid stop for %s! Value: %g, price: %g", __FUNCTION__, EnumToString(_cmd), _value, _price);
    }
#endif
    if (_is_valid && _value_prev > 0 && _locked) {
      _is_valid &= _cmd == ORDER_TYPE_BUY && _value < _value_prev;
      _is_valid &= _cmd == ORDER_TYPE_SELL && _value > _value_prev;
    }
    return _is_valid;
  }

  /* Event methods */

  /**
   * Event on trade's order open.
   *
   * @param
   *   _order Order instance of order which got opened.
   */
  virtual void OnOrderOpen(const Order &_order) {
    if (logger.GetLevel() >= V_INFO) {
      // logger.Info(_order.ToString(), (string)_order.Get<ulong>(ORDER_TICKET)); // @fixme
      ResetLastError();  // @fixme: Error 69539
    }
  }

  /**
   * Event on new time periods.
   *
   * @param
   *   _periods unsigned short
   *   List of periods which started. See: ENUM_DATETIME_UNIT.
   */
  virtual void OnPeriod(unsigned int _periods = DATETIME_NONE) {
    if ((_periods & DATETIME_MINUTE) != 0) {
      // New minute started.
#ifndef __optimize__
      if (Terminal::IsRealtime()) {
        logger.Flush();
      }
#endif
    }
    if ((_periods & DATETIME_HOUR) != 0) {
      // New hour started.
    }
    if ((_periods & DATETIME_DAY) != 0) {
      // New day started.
#ifndef __optimize__
      logger.Flush();
#endif
    }
    if ((_periods & DATETIME_WEEK) != 0) {
      // New week started.
    }
    if ((_periods & DATETIME_MONTH) != 0) {
      // New month started.
    }
    if ((_periods & DATETIME_YEAR) != 0) {
      // New year started.
    }
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
  bool CheckCondition(ENUM_TRADE_CONDITION _cond, DataParamEntry &_args[]) {
    long _arg1l = ArraySize(_args) > 0 ? DataParamEntry::ToInteger(_args[0]) : WRONG_VALUE;
    long _arg2l = ArraySize(_args) > 1 ? DataParamEntry::ToInteger(_args[1]) : WRONG_VALUE;
    switch (_cond) {
      case TRADE_COND_ACCOUNT:
        return account.CheckCondition((ENUM_ACCOUNT_CONDITION)_args[0].integer_value);
      case TRADE_COND_ALLOWED_NOT:
        return !IsTradeAllowed();
      case TRADE_COND_HAS_STATE:
        _arg1l = _arg1l != WRONG_VALUE ? _arg1l : 0;
        return HasState((ENUM_TRADE_STATE)_arg1l);
      case TRADE_COND_IS_ORDER_LIMIT:
        return tparams.IsLimitGe(tstats);
      case TRADE_COND_IS_PEAK:
        _arg1l = _arg1l != WRONG_VALUE ? _arg1l : 0;
        _arg2l = _arg2l != WRONG_VALUE ? _arg2l : 0;
        return IsPeak((ENUM_ORDER_TYPE)_arg1l, (int)_arg2l);
      case TRADE_COND_IS_PIVOT:
        _arg1l = _arg1l != WRONG_VALUE ? _arg1l : 0;
        _arg2l = _arg2l != WRONG_VALUE ? _arg2l : 0;
        return IsPivot((ENUM_ORDER_TYPE)_arg1l, (int)_arg2l);
      // case TRADE_ORDER_CONDS_IN_TREND:
      // case TRADE_ORDER_CONDS_IN_TREND_NOT:
      default:
        logger.Error(StringFormat("Invalid trade condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }
  bool CheckCondition(ENUM_TRADE_CONDITION _cond, long _arg1) {
    ARRAY(DataParamEntry, _args);
    DataParamEntry _param1 = _arg1;
    ArrayPushObject(_args, _param1);
    return Trade::CheckCondition(_cond, _args);
  }
  bool CheckCondition(ENUM_TRADE_CONDITION _cond) {
    ARRAY(DataParamEntry, _args);
    return Trade::CheckCondition(_cond, _args);
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
  bool ExecuteAction(ENUM_TRADE_ACTION _action, DataParamEntry &_args[]) {
    bool _result = true;
    Ref<OrderQuery> _oquery_ref;
    if (Get<bool>(TRADE_STATE_ORDERS_ACTIVE)) {
      _oquery_ref = OrderQuery::GetInstance(orders_active);
    }
    switch (_action) {
      case TRADE_ACTION_CALC_LOT_SIZE:
        tparams.Set(TRADE_PARAM_LOT_SIZE, CalcLotSize(tparams.Get<float>(TRADE_PARAM_RISK_MARGIN)));
        return tparams.Get<float>(TRADE_PARAM_LOT_SIZE) > 0;
      case TRADE_ACTION_ORDER_CLOSE_LEAST_LOSS:
        // @todo
        if (Get<bool>(TRADE_STATE_ORDERS_ACTIVE) && orders_active.Size() > 0) {
          RefreshActiveOrders(true, true);
          _result = false;
        }
        break;
      case TRADE_ACTION_ORDER_CLOSE_LEAST_PROFIT:
        // @todo
        if (Get<bool>(TRADE_STATE_ORDERS_ACTIVE) && orders_active.Size() > 0) {
          RefreshActiveOrders(true, true);
          _result = false;
        }
        break;
      case TRADE_ACTION_ORDER_CLOSE_MOST_LOSS:
        if (Get<bool>(TRADE_STATE_ORDERS_ACTIVE) && orders_active.Size() > 0) {
          _result &= _oquery_ref.Ptr()
                         .FindByPropViaOp<ENUM_ORDER_PROPERTY_CUSTOM, float>(ORDER_PROP_PROFIT,
                                                                             STRUCT_ENUM(OrderQuery, ORDER_QUERY_OP_LT))
                         .Ptr()
                         .OrderClose(ORDER_REASON_CLOSED_BY_ACTION);
          RefreshActiveOrders(true, true);
        }
        break;
      case TRADE_ACTION_ORDER_CLOSE_MOST_PROFIT:
        if (Get<bool>(TRADE_STATE_ORDERS_ACTIVE) && orders_active.Size() > 0) {
          _result &= _oquery_ref.Ptr()
                         .FindByPropViaOp<ENUM_ORDER_PROPERTY_CUSTOM, float>(ORDER_PROP_PROFIT,
                                                                             STRUCT_ENUM(OrderQuery, ORDER_QUERY_OP_GT))
                         .Ptr()
                         .OrderClose(ORDER_REASON_CLOSED_BY_ACTION);
          RefreshActiveOrders(true, true);
        }
        break;
      case TRADE_ACTION_ORDER_OPEN:
        return RequestSend(GetTradeOpenRequest((ENUM_ORDER_TYPE)_args[0].integer_value));
      case TRADE_ACTION_ORDERS_CLOSE_ALL:
        if (Get<bool>(TRADE_STATE_ORDERS_ACTIVE)) {
          _result &= OrdersCloseAll(ORDER_REASON_CLOSED_BY_ACTION) >= 0;
          RefreshActiveOrders(true);
        }
        break;
      case TRADE_ACTION_ORDERS_CLOSE_IN_PROFIT:
        if (Get<bool>(TRADE_STATE_ORDERS_ACTIVE)) {
          _result &= OrdersCloseViaProp<ENUM_ORDER_PROPERTY_CUSTOM, int>(
                         ORDER_PROP_PROFIT_PIPS, (int)chart.Ptr().GetSpreadInPips(), MATH_COND_GT,
                         ORDER_REASON_CLOSED_BY_ACTION) >= 0;
          RefreshActiveOrders(true);
        }
        break;
      case TRADE_ACTION_ORDERS_CLOSE_IN_TREND:
        if (Get<bool>(TRADE_STATE_ORDERS_ACTIVE)) {
          _result &= OrdersCloseViaCmd(GetTrendOp(0), ORDER_REASON_CLOSED_BY_ACTION) >= 0;
          RefreshActiveOrders(true);
        }
        break;
      case TRADE_ACTION_ORDERS_CLOSE_IN_TREND_NOT:
        if (Get<bool>(TRADE_STATE_ORDERS_ACTIVE)) {
          _result &= OrdersCloseViaCmd(Order::NegateOrderType(GetTrendOp(0)), ORDER_REASON_CLOSED_BY_ACTION) >= 0;
          RefreshActiveOrders(true);
        }
        break;
      case TRADE_ACTION_ORDERS_CLOSE_BY_TYPE:
        if (Get<bool>(TRADE_STATE_ORDERS_ACTIVE)) {
          _result &= OrdersCloseViaCmd((ENUM_ORDER_TYPE)_args[0].integer_value, ORDER_REASON_CLOSED_BY_ACTION) >= 0;
          RefreshActiveOrders(true);
        }
        break;
      case TRADE_ACTION_ORDERS_LIMIT_SET:
        // Sets the new limits.
        tparams.SetLimits((ENUM_TRADE_STAT_TYPE)_args[0].integer_value, (ENUM_TRADE_STAT_PERIOD)_args[1].integer_value,
                          (int)_args[2].integer_value);
        // Verify the new limits.
        return tparams.GetLimits((ENUM_TRADE_STAT_TYPE)_args[0].integer_value,
                                 (ENUM_TRADE_STAT_PERIOD)_args[1].integer_value) == _args[2].integer_value;
      case TRADE_ACTION_STATE_ADD:
        tstates.AddState((unsigned int)_args[0].integer_value);
      default:
        logger.Error(StringFormat("Invalid trade action: %s!", EnumToString(_action), __FUNCTION_LINE__));
        _result = false;
        break;
    }
    return _result && GetLastError() == ERR_NO_ERROR;
  }
  bool ExecuteAction(ENUM_TRADE_ACTION _action) {
    DataParamEntry _args[];
    return Trade::ExecuteAction(_action, _args);
  }
  bool ExecuteAction(ENUM_TRADE_ACTION _action, long _arg1) {
    ARRAY(DataParamEntry, _args);
    DataParamEntry _param1 = _arg1;
    ArrayPushObject(_args, _param1);
    return Trade::ExecuteAction(_action, _args);
  }
  bool ExecuteAction(ENUM_TRADE_ACTION _action, long _arg1, long _arg2) {
    ARRAY(DataParamEntry, _args);
    DataParamEntry _param1 = _arg1;
    DataParamEntry _param2 = _arg2;
    ArrayPushObject(_args, _param1);
    ArrayPushObject(_args, _param2);
    return Trade::ExecuteAction(_action, _args);
  }

  /* Printer methods */

  /**
   * Returns textual representation of the Trade class.
   */
  string ToString() { return StringFormat("Margin required: %g/lot", GetMarginRequired()); }

  /* Class handlers */

  /**
   * Returns pointer to Chart class.
   */
  Chart *GetChart() { return chart.Ptr(); }

  /**
   * Returns pointer to Log class.
   */
  Log *GetLogger() { return GetPointer(logger); }

  /* Serializers */

  /**
   * Returns serialized representation of the object instance.
   */
  SerializerNodeType Serialize(Serializer &_s) {
    // ChartEntry _centry = GetEntry();
    // _s.PassStruct(THIS_REF, "chart-entry", _centry, SERIALIZER_FIELD_FLAG_DYNAMIC);
    return SerializerNodeObject;
  }
};
#endif  // TRADE_MQH

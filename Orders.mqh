//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                           Copyright 2016, 31337 Investments Ltd. |
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
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

// Class dependencies.
#ifdef __MQL5__
class CDealInfo;
#endif

// Includes.
#include "Account.mqh"
#include "Errors.mqh"
#include "Order.mqh"
#ifdef __MQL5__
#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
#endif

/**
 * Class to provide methods to deal with the orders.
 */
class Orders {
protected:
  // Structs.
  struct TPositionCount {
    int buy_count;
    int sell_count;
  };
  struct TDealTime {
    datetime buy_time;
    datetime sell_time;
  };
  // Class variables.
  Log *logger;
  Market *market;
  #ifdef __MQL5__
  CTrade ctrade;
  CPositionInfo position_info;
  #endif
  // Struct variables.
  Order *orders[];
  Order *orders_fake[];
  Order *history[];

public:
    // Enums.
#ifdef __MQL4__
    enum ENUM_POSITION_TYPE {
      POSITION_TYPE_BUY,
      POSITION_TYPE_SELL,
    };
#endif

  /**
   * Class constructor.
   */
  void Orders(Market *_market = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) :
    market(_market != NULL ? _market : new Market),
    logger(new Log(V_INFO))
  {
  }

  /**
   * Class deconstructor.
   */
  void ~Orders() {
    delete logger;
    delete market;
  }

  /**
   * Returns the number of market and pending orders.
   *
   * @see:
   * - https://www.mql5.com/en/docs/trading/orderstotal
   * - https://www.mql5.com/en/docs/trading/positionstotal
   */
  static uint OrdersTotal() {
    return #ifdef __MQL4__ ::OrdersTotal(); #else ::OrdersTotal() + ::PositionsTotal(); #endif
  }

  /**
   * Returns the number of closed orders in the account history loaded into the terminal.
   */
  static int OrdersHistoryTotal() {
    return #ifdef __MQL4__ ::OrdersHistoryTotal(); #else ::HistoryOrdersTotal(); #endif
  }

  /* Order selection methods */

  Order *SelectByTicket(ulong _ticket) {
    if (Order::OrderSelect(_ticket, SELECT_BY_TICKET, MODE_TRADES) || Order::OrderSelect(_ticket, SELECT_BY_TICKET, MODE_HISTORY)) {
      uint _size = ArraySize(orders);
      for (uint _pos = _size; _pos >= 0; _pos--) {
        if (orders[_pos].GetTicket() == _ticket) {
          return orders[_pos];
        }
      }
      ArrayResize(orders, _size + 1, 100);
      return orders[_size] = new Order(_ticket, market, logger);
    }
    else {
      for (uint _pos = ArraySize(orders_fake); _pos >= 0; _pos--) {
        if (orders_fake[_pos].GetTicket() == _ticket) {
          return orders[_pos];
        }
      }
      }
    logger.Error(StringFormat("Cannot select order (ticket=#%d)!", _ticket), __FUNCTION__);
    return NULL;
  }

  /* State checking */

  /**
   * Check the limit on the number of active pending orders.
   *
   * Validate whether the amount of open and pending orders
   * has reached the limit set by the broker.
   *
   * @see: https://www.mql5.com/en/articles/2555#account_limit_pending_orders
   */
  bool IsNewOrderAllowed() {
    uint _max_orders = (int) AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
    return _max_orders == 0 ? true : (OrdersTotal() < _max_orders);
  }

  /* Calculation and parsing methods */

  /**
   * Calculate number of allowed orders to open.
   */
  uint CalcMaxOrders(double volume_size, double _risk_ratio = 1.0, uint prev_max_orders = 0, uint hard_limit = 0, bool smooth = true) {
    double _avail_margin = fmin(Account::AccountFreeMargin(), Account::AccountBalance() + Account::AccountCredit());
    double _margin_required = market.GetMarginRequired();
    double _avail_orders = _avail_margin / _margin_required / volume_size;
    uint new_max_orders = (int) (_avail_orders * _risk_ratio);
    if (hard_limit > 0) new_max_orders = fmin(hard_limit, new_max_orders);
    if (smooth && new_max_orders > prev_max_orders) {
      // Increase the limit smoothly.
      return (prev_max_orders + new_max_orders) / 2;
    } else {
      return new_max_orders;
    }
  }

  /**
   * Calculate number of lots for open positions.
   */
  static double GetOpenLots(string symbol = NULL, long magic_number = 0, int magic_range = 0) {
    double total_lots = 0;
    // @todo: Convert to MQL5.
    symbol = symbol != NULL ? symbol : _Symbol;
    for (uint i = 0; i < OrdersTotal(); i++) {
      if (Order::OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) break;
      if (Order::OrderSymbol() == symbol) {
        if ((magic_number > 0)
            && (Order::OrderMagicNumber() < magic_number || Order::OrderMagicNumber() > magic_number + magic_range)) {
          continue;
        }
        // This calculates the total no of lots opened in current orders.
        total_lots += Order::OrderLots();
      }
    }
    return total_lots;
  }

  /**
   * Calculate sum of all stop loss or profit take points of opened orders.
   *
   * @return
   *   Returns sum of all stop loss or profit take points
   *   from all opened orders for the given symbol.
   */
  double TotalSLTP(ENUM_ORDER_TYPE _cmd = NULL, bool sl = true) {
    double total_buy_sl = 0, total_buy_tp = 0;
    double total_sell_sl = 0, total_sell_tp = 0;
    // @todo: Convert to MQL5.
    for (uint i = 0; i < OrdersTotal(); i++) {
      if (!Order::OrderSelect(i)) {
        logger.Error(StringFormat("OrderSelect (%d) returned the error", i), __FUNCTION__, Errors::GetErrorText(GetLastError()));
        break;
      }
      if (Order::OrderSymbol() == market.GetSymbol()) {
        double order_tp = Order::OrderTakeProfit();
        double order_sl = Order::OrderStopLoss();
        switch (Order::OrderType()) {
          case ORDER_TYPE_BUY:
            order_tp = order_tp == 0 ? Timeframe::iHigh(Order::OrderSymbol(), PERIOD_W1, 0) : order_tp;
            order_sl = order_sl == 0 ? Timeframe::iLow(Order::OrderSymbol(), PERIOD_W1, 0) : order_sl;
            total_buy_sl += Order::OrderLots() * (Order::OrderOpenPrice() - order_sl);
            total_buy_tp += Order::OrderLots() * (order_tp - Order::OrderOpenPrice());
            // PrintFormat("%s:%d/%d: OP_BUY: TP=%g, SL=%g, total: %g/%g", __FUNCTION__, i, OrdersTotal(), order_tp, order_sl, total_buy_sl, total_buy_tp);
            break;
          case ORDER_TYPE_SELL:
            order_tp = order_tp == 0 ? Timeframe::iLow(Order::OrderSymbol(), PERIOD_W1, 0) : order_tp;
            order_sl = order_sl == 0 ? Timeframe::iHigh(Order::OrderSymbol(), PERIOD_W1, 0) : order_sl;
            total_sell_sl += Order::OrderLots() * (order_sl - Order::OrderOpenPrice());
            total_sell_tp += Order::OrderLots() * (Order::OrderOpenPrice() - order_tp);
            // PrintFormat("%s:%d%d: OP_SELL: TP=%g, SL=%g, total: %g/%g", __FUNCTION__, i, OrdersTotal(), order_tp, order_sl, total_sell_sl, total_sell_tp);
            break;
        }
      }
    }
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        return sl ? total_buy_sl : total_buy_tp;
      case ORDER_TYPE_SELL:
        return sl ? total_sell_sl : total_sell_tp;
      default:
        return sl ? fabs(total_buy_sl - total_sell_sl) : fabs(total_buy_tp - total_sell_tp);
    }
  }

  /**
   * Get sum of total stop loss values of opened orders.
   */
  double TotalSL(ENUM_ORDER_TYPE _cmd = NULL) {
    return TotalSLTP(_cmd, true);
  }

  /**
   * Get sum of total take profit values of opened orders.
   *
   * @return
   *   Returns total take profit points.
   */
  double TotalTP(ENUM_ORDER_TYPE _cmd = NULL) {
    return TotalSLTP(_cmd, false);
  }

  /**
   * Get ratio of total stop loss points.
   *
   * @return
   *   Returns ratio between 0 and 1.
   */
  double RatioSL(ENUM_ORDER_TYPE _cmd = NULL) {
    return 1.0 / fmax(TotalSL(_cmd) + TotalTP(_cmd), 0.01) * TotalSL(_cmd);
  }

  /**
   * Get ratio of total profit take points.
   *
   * @return
   *   Returns ratio between 0 and 1.
   */
  double RatioTP(ENUM_ORDER_TYPE _cmd = NULL) {
    return 1.0 / fmax(TotalSL(_cmd) + TotalTP(_cmd), 0.01) * TotalTP(_cmd);
  }

  /**
   * Calculate sum of all lots of opened orders.
   *
   * @return
   *   Returns sum of all lots from all opened orders.
   */
  double TotalLots(ENUM_ORDER_TYPE _cmd = NULL) {
    double buy_lots = 0, sell_lots = 0;
    // @todo: Convert to MQL5.
    for (uint i = 0; i < OrdersTotal(); i++) {
      if (!Order::OrderSelect(i)) {
        logger.Error(StringFormat("OrderSelect (%d) returned the error", i), __FUNCTION__, Errors::GetErrorText(GetLastError()));
        break;
      }
      if (Order::OrderSymbol() == market.GetSymbol()) {
        switch (Order::OrderType()) {
          case ORDER_TYPE_BUY:
            buy_lots += Order::OrderLots();
            break;
          case ORDER_TYPE_SELL:
            sell_lots += Order::OrderLots();
            break;
        }
      }
    }
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        return buy_lots;
      case ORDER_TYPE_SELL:
        return sell_lots;
      default:
        return buy_lots + sell_lots;
    }
  }

  /**
   * Get order type based on the majority of opened orders.
   *
   * @return
   *   Returns order type of majority of opened orders. Otherwise NULL.
   */
  ENUM_ORDER_TYPE GetOrderTypeByOrders() {
    double _buy_lots = TotalLots(ORDER_TYPE_BUY);
    double _sell_lots = TotalLots(ORDER_TYPE_SELL);
    if (_buy_lots > 0 && _buy_lots > _sell_lots) {
      return ORDER_TYPE_BUY;
    }
    else if (_sell_lots > 0 && _sell_lots > _buy_lots) {
      return ORDER_TYPE_SELL;
    }
    else {
      return NULL;
    }
  }

  /**
   * Close all orders.
   *
   * @return
   *   Returns true on success.
   */
  bool OrdersCloseAll(
    const string _symbol = NULL,
    const ENUM_POSITION_TYPE _type = -1,
    const int _magic = -1)
  {
#ifdef __MQL4__

    //---
    if (!(_type == POSITION_TYPE_BUY || _type == POSITION_TYPE_SELL || _type == -1)) {
      return (false);
    }

    bool result = true;
    uint total = OrdersTotal();
    for (uint i = total - 1; i >= 0; i--) {

      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
        return (false);
      }

      int order_type = OrderType();

      if((_symbol == NULL || OrderSymbol() ==_symbol) &&
          ((_type == -1 && (order_type == OP_BUY || order_type == OP_SELL)) || order_type == _type) &&
          (_magic == -1 || OrderMagicNumber()==_magic))
      {
        string o_symbol = OrderSymbol();

        uint _digits = market.GetSymbolDigits();
        bool res_one = false;
        int attempts = 10;
        while (attempts > 0) {
          ResetLastError();

          if(IsTradeContextBusy())
          {
            Sleep(500);
            attempts--;
            continue;
          }

          RefreshRates();

          double close_price=0.0;
          if(order_type==OP_BUY)
            close_price=SymbolInfoDouble(o_symbol,SYMBOL_BID);
          if(order_type==OP_SELL)
            close_price=SymbolInfoDouble(o_symbol,SYMBOL_ASK);

          //---
          int slippage=(int)SymbolInfoInteger(o_symbol,SYMBOL_SPREAD);

          //---
          if (OrderClose(OrderTicket(), OrderLots(), close_price, slippage)) {
            res_one = true;
            break;
          }
          else {
            /*
               ENUM_ERROR_LEVEL level=PrintError(_LastError);
               if(level==LEVEL_ERROR)
               {
               Sleep(TRADE_PAUSE_LONG);
               break;
               }
             */
          }
          attempts--;
        }

        result &= res_one;
      }
    }

#endif

#ifdef __MQL5__
    uint total = PositionsTotal();
    for (uint i = total - 1; i >= 0; i--) {
      if (!position_info.SelectByIndex(i))
        return(false);

      //--- check symbol
      if(_symbol != NULL && position_info.Symbol() != _symbol)
        continue;

      //--- check type
      if(_type != -1 && position_info.PositionType() != _type)
        continue;

      //--- check magic
      if(_magic != -1 && position_info.Magic() != _magic)
        continue;

      //---
      ctrade.SetTypeFilling(Order::GetOrderFilling((string) position_info.Symbol()));
      if (!ctrade.PositionClose(position_info.Ticket(), market.GetSpreadInPts())) {
        logger.Error(ctrade.ResultRetcodeDescription());
      }
    }
#endif
    //---
    return(true);
  }

  /**
   * Get time of the last deal.
   *
   * @return
   *   Returns true on success.
   */
  bool DealLastTime(TDealTime &last_time, const string _symbol, const int _magic) {
    last_time.buy_time = 0;
    last_time.sell_time = 0;
    //---
#ifdef __MQL4__
    int orders_total = OrdersHistoryTotal();
    for (int i = orders_total - 1; i >= 0; i--) {
      if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
        return(false);
      }

      if(_symbol != NULL && OrderSymbol() != _symbol)
        continue;
      if(_magic!=-1 && OrderMagicNumber() != _magic)
        continue;
      //---
      if(OrderType() == OP_BUY &&
          last_time.buy_time == 0)
        last_time.buy_time = OrderOpenTime();
      //---
      if(OrderType() == OP_SELL &&
          last_time.sell_time == 0)
        last_time.sell_time = OrderOpenTime();
      //---
      break;
    }
#else // __MQL5__
    CDealInfo deal;

    if(!HistorySelect(0,TimeCurrent()))
      return(false);

    int total = HistoryDealsTotal();
    for(int i=total-1; i>=0; i--)
    {
      if(!deal.SelectByIndex(i))
        return(false);

      if(deal.Symbol()!=_Symbol)
        continue;

      if(deal.Entry()==DEAL_ENTRY_IN)
      {
        //---
        if(deal.DealType()==DEAL_TYPE_BUY &&
            last_time.buy_time==0)
        {
          last_time.buy_time=deal.Time();
          if(last_time.sell_time>0)
            break;
        }

        //---
        if(deal.DealType()==DEAL_TYPE_SELL &&
            last_time.sell_time==0)
        {
          last_time.sell_time=deal.Time();
          if(last_time.buy_time>0)
            break;
        }

      }
    }
#endif
    return(true);
  }

  /**
   * Get total of open positions.
   *
   * @return
   *   Returns true on success.
   */
  bool PositonTotal(TPositionCount &count, const int _magic = 0) {

    ResetLastError();

    count.buy_count=0;
    count.sell_count=0;

    #ifdef __MQL4__
    uint total = OrdersTotal();
    for (uint i = 0; i < total; i++) {
      if (!Order::OrderSelect(i, SELECT_BY_POS)) {
        return false;
      }

      if (Order::OrderSymbol() != market.GetSymbol())
        continue;

      if (_magic != -1 && Order::OrderMagicNumber() != _magic)
        continue;

      if (Order::OrderType() == OP_BUY)
        count.buy_count++;

      if (Order::OrderType() == OP_SELL)
        count.sell_count++;
    }
    #else // __MQL5__
    CPositionInfo pos;
    int total = PositionsTotal();
    for(int i=0; i<total; i++) {
      if (!pos.SelectByIndex(i)) {
        return (false);
      }
      //---
      if((pos.Symbol() == symbol || symbol == NULL) &&
          (pos.Magic() == _magic  || _magic ==-1)) {
        if(pos.PositionType() == POSITION_TYPE_BUY) {
          count.buy_count++;
        }
        if(pos.PositionType() == POSITION_TYPE_SELL) {
          count.sell_count++;
        }
      }
    }
    #endif
    return (true);
  }

  /**
   * Count open positions by order type.
   */
  static uint GetOrdersByType(ENUM_ORDER_TYPE _cmd, string _symbol = NULL) {
    uint _counter = 0;
    _symbol = _symbol != NULL ? _symbol : _Symbol;
    for (uint i = 0; i < OrdersTotal(); i++) {
      if (Order::OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) break;
      if (Order::OrderSymbol() == _symbol) {
         if(Order::OrderType() == _cmd) _counter++;
       }
    }
    return _counter;
  }

  /**
   * Get realized P&L (Profit and Loss).
   */
  /*
  double GetRealizedPL() const {
    double profit = 0;
    for (int i = 0; i <= numberOrders; ++i) {
      if (this.orders[i].getOrderType() == ORDER_FINAL) {
        // @todo
        // profit += this.orders[i].getOrderProfit();
      }
    }
    return profit;
  }
  */

  /**
   * Get unrealized P&L (Profit and Loss).
   *
   * A reflection of what profit or loss
   * that could be realized if the position were closed at that time.
   */
  /*
  double GetUnrealizedPL() const {
    double profit = 0;
    for (int i = 0; i <= numberOrders; ++i) {
      if (this.orders[i].getOrderType() != ORDER_FINAL) {
        profit += this.orders[i].getOrderProfit();
      }
    }
    return profit;
  }

  double GetTotalEquity() const {
    double profit = 0;
    for (int i = 0; i <= numberOrders; ++i) {
      profit += this.orders[i].GetOrderProfit();
    }
    return profit;
  }

  double GetTotalCommission() const {
    double commission = 0;
    for (int i = 0; i <= numberOrders; ++i) {
      commission += this.orders[i].GetOrderCommission();
    }
    return commission;
  }

  double GetTotalSwap() const {
    double swap = 0;
    for (int i = 0; i <= numberOrders; ++i) {
      swap += this.orders[i].GetOrderSwap();
    }
    return swap;
  }
  */

};
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

// Forward declarations.
class Orders;

// Includes.
#include "Account.mqh"
#include "Chart.mqh"
#include "Log.mqh"
#include "Math.h"
#include "Order.mqh"
#include "Terminal.mqh"

/* Defines */

// Index in the order pool.
#ifndef SELECT_BY_POS
#define SELECT_BY_POS 0
#endif

// Index by the order ticket.
#ifndef SELECT_BY_TICKET
#define SELECT_BY_TICKET 1
#endif

// Delay pauses between operations.
#define TRADE_PAUSE_SHORT 500
#define TRADE_PAUSE_LONG 5000

/**
 * Class to provide methods to deal with the orders.
 */
#ifndef ORDERS_MQH

// Enums.
enum ENUM_ORDERS_POOL {
  ORDERS_POOL_TRADES = MODE_TRADES,    // Trading pool (opened and pending orders).
  ORDERS_POOL_HISTORY = MODE_HISTORY,  // History pool (closed and canceled order).
  ORDERS_POOL_DUMMY = 3                // Dummy pool for testing purposes.
};

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
#ifdef __MQL5__
// CTrade ctrade; // @removeme
// CPositionInfo position_info; // @removeme
#endif
  // Enum variables.
  ENUM_ORDERS_POOL pool;
  // Struct variables.
  Order *orders[];
  // Class variables.
  Ref<Log> logger;
  // Market *market;

 public:
  /**
   * Class constructor.
   */
  Orders(ENUM_ORDERS_POOL _pool, Log *_log = NULL) : pool(_pool), logger(_log != NULL ? _log : new Log) {}

  /**
   * Class deconstructor.
   */
  ~Orders() {
    for (int i = 0; i < ArraySize(orders); ++i) delete orders[i];
  }

  Log *Logger() { return logger.Ptr(); }

  /**
   * Open a new order.
   */
  bool NewOrder(MqlTradeRequest &_req, MqlTradeResult &_res) {
    int _size = ArraySize(orders);
    if (ArrayResize(orders, _size + 1, 100)) {
      orders[_size] = new Order(_req);
      return true;
    } else {
      Logger().Error("Cannot allocate the memory.", __FUNCTION__);
      return false;
    }
  }

  /* Order selection methods */

  /**
   * Finds order in the selected pool.
   */
  Order *SelectOrder(ulong _ticket) {
    for (uint _pos = ArraySize(orders); _pos >= 0; _pos--) {
      if (orders[_pos].Get<ulong>(ORDER_PROP_TICKET) == _ticket) {
        return orders[_pos];
      }
    }
    return NULL;
  }

  /**
   * Select order object by ticket.
   */
  Order *SelectByTicket(ulong _ticket) {
    Order *_order = SelectOrder(_ticket);
    if (_order != NULL) {
      return _order;
    } else if ((pool == ORDERS_POOL_TRADES && Order::TryOrderSelect(_ticket, SELECT_BY_TICKET, MODE_TRADES)) ||
               (pool == ORDERS_POOL_HISTORY && Order::TryOrderSelect(_ticket, SELECT_BY_TICKET, MODE_HISTORY))) {
      uint _size = ArraySize(orders);
      ArrayResize(orders, _size + 1, 100);
      return orders[_size] = new Order(_ticket);
    }
    Logger().Error(StringFormat("Cannot select order (ticket=#%d)!", _ticket), __FUNCTION__);
    return NULL;
  }

  /* Calculation and parsing methods */

  /**
   * Calculate number of lots for open positions.
   */
  static double GetOpenLots(string _symbol = NULL, long magic_number = 0, int magic_range = 0) {
    double total_lots = 0;
    // @todo: Convert to MQL5.
    _symbol = _symbol != NULL ? _symbol : _Symbol;
    for (int i = 0; i < OrdersTotal(); i++) {
      if (Order::TryOrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) break;
      if (Order::OrderSymbol() == _symbol) {
        if ((magic_number > 0) &&
            (Order::OrderMagicNumber() < magic_number || Order::OrderMagicNumber() > magic_number + magic_range)) {
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
  static double TotalSLTP(ENUM_ORDER_TYPE _cmd = NULL, bool sl = true) {
    double total_buy_sl = 0, total_buy_tp = 0;
    double total_sell_sl = 0, total_sell_tp = 0;
    // @todo: Convert to MQL5.
    for (int i = 0; i < OrdersTotal(); i++) {
      if (!Order::TryOrderSelect(i, SELECT_BY_POS)) {
        // Logger().Error(StringFormat("OrderSelect (%d) returned the error", i), __FUNCTION__,
        // Terminal::GetErrorText(GetLastError()));
        break;
      }
      if (Order::OrderSymbol() == _Symbol) {
        double order_tp = Order::OrderTakeProfit();
        double order_sl = Order::OrderStopLoss();
        switch (Order::OrderType()) {
          case ORDER_TYPE_BUY:
            order_tp = order_tp == 0 ? ChartStatic::iHigh(Order::OrderSymbol(), PERIOD_W1, 0) : order_tp;
            order_sl = order_sl == 0 ? ChartStatic::iLow(Order::OrderSymbol(), PERIOD_W1, 0) : order_sl;
            total_buy_sl += Order::OrderLots() * (Order::OrderOpenPrice() - order_sl);
            total_buy_tp += Order::OrderLots() * (order_tp - Order::OrderOpenPrice());
            // PrintFormat("%s:%d/%d: OP_BUY: TP=%g, SL=%g, total: %g/%g", __FUNCTION__, i, OrdersTotal(), order_tp,
            // order_sl, total_buy_sl, total_buy_tp);
            break;
          case ORDER_TYPE_SELL:
            order_tp = order_tp == 0 ? ChartStatic::iLow(Order::OrderSymbol(), PERIOD_W1, 0) : order_tp;
            order_sl = order_sl == 0 ? ChartStatic::iHigh(Order::OrderSymbol(), PERIOD_W1, 0) : order_sl;
            total_sell_sl += Order::OrderLots() * (order_sl - Order::OrderOpenPrice());
            total_sell_tp += Order::OrderLots() * (Order::OrderOpenPrice() - order_tp);
            // PrintFormat("%s:%d%d: OP_SELL: TP=%g, SL=%g, total: %g/%g", __FUNCTION__, i, OrdersTotal(), order_tp,
            // order_sl, total_sell_sl, total_sell_tp);
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
  double TotalSL(ENUM_ORDER_TYPE _cmd = NULL) { return TotalSLTP(_cmd, true); }

  /**
   * Get sum of total take profit values of opened orders.
   *
   * @return
   *   Returns total take profit points.
   */
  double TotalTP(ENUM_ORDER_TYPE _cmd = NULL) { return TotalSLTP(_cmd, false); }

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
    for (int i = 0; i < OrdersTotal(); i++) {
      if (!Order::OrderSelect(i, SELECT_BY_POS)) {
        Logger().Error(StringFormat("OrderSelect (%d) returned the error", i), __FUNCTION__,
                       Terminal::GetErrorText(GetLastError()));
        break;
      }
      if (Order::OrderSymbol() == _Symbol) {
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
    } else if (_sell_lots > 0 && _sell_lots > _buy_lots) {
      return ORDER_TYPE_SELL;
    } else {
      return NULL;
    }
  }

  /**
   * Close all orders.
   *
   * @return
   *   Returns true on success.
   */
  bool OrdersCloseAll(const string _symbol = NULL, const ENUM_POSITION_TYPE _type = (ENUM_POSITION_TYPE)-1,
                      const int _magic = -1) {
#ifdef __MQL4__

    //---
    if (!(_type == POSITION_TYPE_BUY || _type == POSITION_TYPE_SELL || _type == -1)) {
      return (false);
    }

    bool result = true;
    uint total = OrdersTotal();
    for (uint i = total - 1; i >= 0; i--) {
      if (!Order::TryOrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
        return (false);
      }

      int order_type = OrderType();

      if ((_symbol == NULL || OrderSymbol() == _symbol) &&
          ((_type == -1 && (order_type == OP_BUY || order_type == OP_SELL)) || order_type == _type) &&
          (_magic == -1 || OrderMagicNumber() == _magic)) {
        string o_symbol = OrderSymbol();

        uint _digits = SymbolInfoStatic::GetDigits(o_symbol);
        bool res_one = false;
        int attempts = 10;
        while (attempts > 0) {
          ResetLastError();

          if (IsTradeContextBusy()) {
            Sleep(500);
            attempts--;
            continue;
          }

          RefreshRates();

          double close_price = 0.0;
          if (order_type == OP_BUY) {
            close_price = SymbolInfoStatic::GetBid(o_symbol);
          }
          if (order_type == OP_SELL) {
            close_price = SymbolInfoStatic::GetAsk(o_symbol);
          }

          //---
          uint slippage = SymbolInfoStatic::GetSpread(o_symbol);

          //---
          if (OrderClose(OrderTicket(), OrderLots(), close_price, slippage)) {
            res_one = true;
            break;
          } else {
            Logger().AddLastError();
            Sleep(TRADE_PAUSE_LONG);
            break;
          }
          attempts--;
        }

        result &= res_one;
      }
    }

#endif

#ifdef __MQL5__
    uint total = PositionsTotal();
    /* @fixme
    for (uint i = total - 1; i >= 0; i--) {
      if (!position_info.SelectByIndex(i))
        return(false);

      //--- check symbol
      if (_symbol != NULL && position_info.Symbol() != _symbol)
        continue;

      //--- check type
      if (_type != -1 && position_info.PositionType() != _type)
        continue;

      //--- check magic
      if (_magic != -1 && position_info.Magic() != _magic)
        continue;

      //---
      ctrade.SetTypeFilling(Order::GetOrderFilling((string) position_info.Symbol()));
      if (!ctrade.PositionClose(position_info.Ticket(), market.GetSpreadInPts())) {
        Logger().Error(ctrade.ResultRetcodeDescription());
      }
    }
    */
#endif
    //---
    return (true);
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
    int orders_total = TradeHistoryStatic::HistoryOrdersTotal();
    for (int i = orders_total - 1; i >= 0; i--) {
      if (!Order::TryOrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
        return (false);
      }

      if (_symbol != NULL && OrderSymbol() != _symbol) continue;
      if (_magic != -1 && OrderMagicNumber() != _magic) continue;
      //---
      if (OrderType() == OP_BUY && last_time.buy_time == 0) last_time.buy_time = OrderOpenTime();
      //---
      if (OrderType() == OP_SELL && last_time.sell_time == 0) last_time.sell_time = OrderOpenTime();
      //---
      break;
    }
#else  // __MQL5__
/* @fixme: Rewrite without using CDealInfo.
    CDealInfo deal;

    if (!HistorySelect(0, TimeCurrent()))
      return(false);

    int total = HistoryDealsTotal();
    for (int i = total - 1; i >= 0; i--) {
      if (!deal.SelectByIndex(i))
        return(false);

      if (deal.Symbol() != _Symbol)
        continue;

      if (deal.Entry() == DEAL_ENTRY_IN) {
        //---
        if (deal.DealType() == DEAL_TYPE_BUY &&
            last_time.buy_time == 0) {
          last_time.buy_time = deal.Time();
          if (last_time.sell_time>0)
            break;
        }

        //---
        if (deal.DealType() == DEAL_TYPE_SELL &&
            last_time.sell_time == 0)
        {
          last_time.sell_time = deal.Time();
          if (last_time.buy_time > 0)
            break;
        }

      }
    }
*/
#endif
    return (true);
  }

  /**
   * Get total of open positions.
   *
   * @return
   *   Returns true on success.
   */
  /*
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
      if ((pos.Symbol() == symbol || symbol == NULL) &&
          (pos.Magic() == _magic  || _magic ==-1)) {
        if (pos.PositionType() == POSITION_TYPE_BUY) {
          count.buy_count++;
        }
        if (pos.PositionType() == POSITION_TYPE_SELL) {
          count.sell_count++;
        }
      }
    }
    #endif
    return (true);
  }
  */

  /**
   * Count open positions by order type.
   */
  static uint GetOrdersByType(ENUM_ORDER_TYPE _cmd, string _symbol = NULL) {
    uint _counter = 0;
    _symbol = _symbol != NULL ? _symbol : _Symbol;
    for (int i = 0; i < OrdersTotal(); i++) {
      if (Order::TryOrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false) break;
      if (Order::OrderSymbol() == _symbol) {
        if (Order::OrderType() == _cmd) _counter++;
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
#define ORDERS_MQH
#endif

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

// Includes.
#include "Account.mqh"
#include "Order.mqh"

// Properties.
#property strict

/**
 * Class to provide methods to deal with the orders.
 */
class Orders {
  public:
    // Structs.
    struct TPositionCount {
      int buy_count;
      int sell_count;
    };
    struct TDealTime {
      datetime buy_time;
      datetime sell_time;
    };
    // Enums.
#ifdef __MQL4__
    enum ENUM_POSITION_TYPE {
      POSITION_TYPE_BUY,
      POSITION_TYPE_SELL,
    };
#endif

    /**
     * Check the limit on the number of active pending orders.
     *
     * Validate whether the amount of open and pending orders
     * has reached the limit set by the broker.
     *
     * @see: https://www.mql5.com/en/articles/2555#account_limit_pending_orders
     */
    static bool IsNewOrderAllowed() {
      int _max_orders = (int) AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
      return _max_orders == 0 ? True : OrdersTotal() < _max_orders;
    }

    /**
     * Calculate number of allowed orders to open.
     */
    static uint CalcMaxOrders(double volume_size, double _risk_ratio = 1.0, uint prev_max_orders = 0, uint hard_limit = 0, bool smooth = True, string symbol = NULL) {
      double _avail_margin = fmin(Account::AccountFreeMargin(), Account::AccountBalance() + Account::AccountCredit());
      double _margin_required = MarketInfo(symbol, MODE_MARGINREQUIRED);
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
    static double GetOpenLots(string symbol = NULL, int magic_number = 0, int magic_range = 0) {
      double total_lots = 0;
      // @todo: Convert to MQL5.
      symbol = symbol != NULL ? symbol : _Symbol;
      for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == False) break;
        if (OrderSymbol() == symbol) {
          if ((magic_number > 0)
              && (OrderMagicNumber() < magic_number || OrderMagicNumber() > magic_number + magic_range)) {
            continue;
          }
          // This calculates the total no of lots opened in current orders.
          total_lots += OrderLots();
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
    static double TotalSLTP(int op = EMPTY, string symbol = NULL, bool sl = True) {
      double total_buy_sl = 0, total_buy_tp = 0;
      double total_sell_sl = 0, total_sell_tp = 0;
      // @todo: Convert to MQL5.
      for (int i = 0; i < OrdersTotal(); i++) {
        if (!Order::OrderSelect(i)) {
          Print(i, ": OrderSelect returned the error of: ", GetLastError());
          break;
        }
        if (symbol == NULL || OrderSymbol() == symbol) {
          double order_tp = OrderTakeProfit();
          double order_sl = OrderStopLoss();
          switch (OrderType()) {
            case OP_BUY:
              order_tp = order_tp == 0 ? iHigh(OrderSymbol(), PERIOD_W1, 0) : order_tp;
              order_sl = order_sl == 0 ? iLow(OrderSymbol(), PERIOD_W1, 0) : order_sl;
              total_buy_sl += OrderLots() * (OrderOpenPrice() - order_sl);
              total_buy_tp += OrderLots() * (order_tp - OrderOpenPrice());
              // PrintFormat("%s:%d/%d: OP_BUY: TP=%g, SL=%g, total: %g/%g", __FUNCTION__, i, OrdersTotal(), order_tp, order_sl, total_buy_sl, total_buy_tp);
              break;
            case OP_SELL:
              order_tp = order_tp == 0 ? iLow(OrderSymbol(), PERIOD_W1, 0) : order_tp;
              order_sl = order_sl == 0 ? iHigh(OrderSymbol(), PERIOD_W1, 0) : order_sl;
              total_sell_sl += OrderLots() * (order_sl - OrderOpenPrice());
              total_sell_tp += OrderLots() * (OrderOpenPrice() - order_tp);
              // PrintFormat("%s:%d%d: OP_SELL: TP=%g, SL=%g, total: %g/%g", __FUNCTION__, i, OrdersTotal(), order_tp, order_sl, total_sell_sl, total_sell_tp);
              break;
          }
        }
      }
      switch (op) {
        case OP_BUY:
          return sl ? total_buy_sl : total_buy_tp;
        case OP_SELL:
          return sl ? total_sell_sl : total_sell_tp;
        case EMPTY:
        default:
          return sl ? fabs(total_buy_sl - total_sell_sl) : fabs(total_buy_tp - total_sell_tp);
      }
    }

    /**
     * Get sum of total stop loss values of opened orders.
     */
    static double TotalSL(int op = EMPTY, string symbol = NULL) {
      return TotalSLTP(op, symbol, True);
    }

    /**
     * Get sum of total take profit values of opened orders.
     *
     * @return
     *   Returns total take profit points.
     */
    static double TotalTP(int op = EMPTY, string symbol = NULL) {
      return TotalSLTP(op, symbol, False);
    }

    /**
     * Get ratio of total stop loss points.
     *
     * @return
     *   Returns ratio between 0 and 1.
     */
    static double RatioSL(int op = EMPTY, string symbol = NULL) {
      return 1.0 / fmax(TotalSL(op, symbol) + TotalTP(op, symbol), 0.01) * TotalSL(op, symbol);
    }

    /**
     * Get ratio of total profit take points.
     *
     * @return
     *   Returns ratio between 0 and 1.
     */
    static double RatioTP(int op = EMPTY, string symbol = NULL) {
      return 1.0 / fmax(TotalSL(op, symbol) + TotalTP(op, symbol), 0.01) * TotalTP(op, symbol);
    }

    /**
     * Close all orders.
     *
     * @return
     *   Returns True on success.
     */
    bool OrdersCloseAll(const string              _symbol=NULL,
        const ENUM_POSITION_TYPE  _type=-1,
        const int                 _magic=-1)
    {
#ifdef __MQL4__

      //---
      if(!(_type==POSITION_TYPE_BUY || _type==POSITION_TYPE_SELL || _type==-1))
      {
        return(false);
      }

      bool result=true;
      int total=OrdersTotal();
      for(int i=total-1; i>=0; i--)
      {

        if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
          return(false);
        }

        int order_type=OrderType();

        if((_symbol==NULL || OrderSymbol()==_symbol) &&
            ((_type==-1 && (order_type==OP_BUY || order_type==OP_SELL)) || order_type==_type) &&
            (_magic==-1 || OrderMagicNumber()==_magic))
        {
          string symbol=OrderSymbol();

          int _digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
          int _coef_point=1;
          if(_digits==3 || _digits==5)
            _coef_point=10;

          bool res_one=false;
          int attempts=10;
          while(attempts>0)
          {
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
              close_price=SymbolInfoDouble(symbol,SYMBOL_BID);
            if(order_type==OP_SELL)
              close_price=SymbolInfoDouble(symbol,SYMBOL_ASK);

            //---
            int slippage=(int)SymbolInfoInteger(symbol,SYMBOL_SPREAD);

            //---
            if(OrderClose(OrderTicket(),OrderLots(),close_price,slippage))
            {
              res_one=true;
              break;
            }
            else
            {
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

          if(!res_one)
            result=false;
        }
      }

#endif

#ifdef __MQL5__
      CTrade trade;
      CPositionInfo position;

      int total=PositionsTotal();
      for(int i=total-1;i>=0;i--)
      {
        if(!position.SelectByIndex(i))
          return(false);

        //--- check symbol
        if(_symbol!=NULL && position.Symbol()!=_symbol)
          continue;

        //--- check type
        if(_type!=-1 && position.PositionType()!=_type)
          continue;

        //--- check magic
        if(_magic!=-1 && position.Magic()!=_magic)
          continue;

        //---
        long slippage=SymbolInfoInteger(position.Symbol(),SYMBOL_SPREAD);

        trade.SetTypeFilling(GetTypeFilling(position.Symbol()));

        if(!trade.PositionClose(position.Ticket(),slippage))
          Print(trade.ResultRetcodeDescription());
      }
#endif
      //---
      return(true);
    }

    /**
     * Get time of the last deal.
     *
     * @return
     *   Returns True on success.
     */
    bool DealLastTime(TDealTime &last_time, const string _symbol, const int _magic) {
      last_time.buy_time = 0;
      last_time.sell_time = 0;
      //---
#ifdef __MQL4__
      int orders_total=OrdersHistoryTotal();
      for(int i=orders_total-1; i>=0; i--)
      {
        if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
          return(false);

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

      int total=HistoryDealsTotal();
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
     *   Returns True on success.
     */
    bool PositonTotal(TPositionCount &count, const string _symbol = NULL, const int _magic = 0) {

      ResetLastError();

      count.buy_count=0;
      count.sell_count=0;

#ifdef __MQL4__
      int total= OrdersTotal();
      for(int i=0;i<total;i++) {
        if(!OrderSelect(i,SELECT_BY_POS))
          return(false);

        if(_symbol!=NULL && OrderSymbol()!=_symbol)
          continue;

        if(_magic!=-1 && OrderMagicNumber()!=_magic)
          continue;

        if(OrderType()==OP_BUY)
          count.buy_count++;

        if(OrderType()==OP_SELL)
          count.sell_count++;
      }
#else // __MQL5__
      CPositionInfo pos;
      int total=PositionsTotal();
      for(int i=0; i<total; i++)
      {
        if(!pos.SelectByIndex(i))
          return(false);
        //---
        if((pos.Symbol()== _symbol || _symbol==NULL) &&
            (pos.Magic() == _magic  || _magic ==-1))
        {
          if(pos.PositionType()==POSITION_TYPE_BUY)
            count.buy_count++;
          if(pos.PositionType()==POSITION_TYPE_SELL)
            count.sell_count++;
        }
      }
#endif
      return (True);
    }
};

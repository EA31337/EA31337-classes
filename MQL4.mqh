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
 * Provide backward compatibility for MQL4 in MT5/MQL5.
 */

// Prevents processing this includes file for the second time.
#ifndef MQL4_MQH
#define MQL4_MQH

//+------------------------------------------------------------------+
//| Declaration of constants
//+------------------------------------------------------------------+

// Index in the order pool.
#ifndef SELECT_BY_POS
#define SELECT_BY_POS 0
#endif

// Some of standard MQL4 constants are absent in MQL5, therefore they should be declared as below.
#ifdef __MQL5__
#define show_inputs script_show_inputs
// --
#define extern input
// --
#define init OnInit
// --

// Defines macros for MQL5.
/* @fixme: Conflicts with SymbolInfo::Ask() method.
#define Ask SymbolInfo::GetAsk(_Symbol)
#define Bid SymbolInfo::GetAsk(_Symbol)
//#define Bid (::SymbolInfoDouble(_Symbol, ::SYMBOL_BID))
//#define Ask (::SymbolInfoDouble(_Symbol, ::SYMBOL_ASK))
*/

// Defines macros for MQL5.
/* @fixme: error: macro too complex
#define Day(void) DateTime::Day()
#define DayOfWeek(void) SymbolInfo::DayOfWeek()
#define DayOfYear(void) SymbolInfo::DayOfYear()
*/

// Define boolean values.
#define True true
#define False false
#define TRUE true
#define FALSE false
// --
/* @fixme: If this is defined, cannot call: DateTime::TimeToStr().
#ifndef TimeToStr
#define TimeToStr(time_value, flags) TimeToString(time_value, flags)
#endif
*/
// --
#define CurTime TimeCurrent
// --
#define LocalTime TimeLocal

#ifndef TRADE_ACTION_CLOSE_BY
#define TRADE_ACTION_CLOSE_BY 1
#endif

//+------------------------------------------------------------------+
//| Includes.
//+------------------------------------------------------------------+

/**
 * Returns market data about securities.
 */
/*
#include "Market.mqh"
double MarketInfo(string _symbol, int _type) {
  return Market::MarketInfo(_symbol, _type);
}
*/

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringSetChar(const string &String_Var, const int iPos, const ushort Value) {
  string Str = String_Var;

  ::StringSetCharacter(Str, iPos, Value);

  return (Str);
}

#endif  // __MQL5__

#ifdef __MQL5__
#ifndef __MT4ORDERS__

#define __MT4ORDERS__

#define RESERVE_SIZE 1000
#define DAY (24 * 3600)
#define HISTORY_PAUSE (MT4HISTORY::IsTester ? 0 : 5)

class MT4HISTORY {
 private:
  static const bool IsTester;

  long Tickets[];
  uint Amount;

  datetime LastTime;

  int LastTotalDeals;
  int LastTotalOrders;

  datetime LastInitTime;

#define GETNEXTPOS_FUNCTION(NAME)                                           \
  static int GetNextPosMT4##NAME(int iPos) {                                \
    const int Total = ::History##NAME##sTotal();                            \
                                                                            \
    while (iPos < Total) {                                                  \
      if (MT4HISTORY::IsMT4##NAME(::History##NAME##GetTicket(iPos))) break; \
                                                                            \
      iPos++;                                                               \
    }                                                                       \
                                                                            \
    return (iPos);                                                          \
  }

  GETNEXTPOS_FUNCTION(Order)
  GETNEXTPOS_FUNCTION(Deal)

#undef GETNEXTPOS_FUNCTION

  bool RefreshHistory(void) {
    bool Res = false;

    const datetime LastTimeCurrent = ::TimeCurrent();

    if ((!MT4HISTORY::IsTester) && (LastTimeCurrent >= this.LastInitTime + DAY)) {
      this.LastTime = 0;

      this.LastTotalOrders = 0;
      this.LastTotalDeals = 0;

      this.Amount = 0;

      ::ArrayResize(this.Tickets, this.Amount, RESERVE_SIZE);

      this.LastInitTime = LastTimeCurrent;
    }

    if (::HistorySelect(this.LastTime, ::MathMax(LastTimeCurrent, this.LastTime) + DAY))  // Daily stock.
    {
      const int TotalOrders = ::HistoryOrdersTotal();
      const int TotalDeals = ::HistoryDealsTotal();

      Res = ((TotalOrders != this.LastTotalOrders) || (TotalDeals != this.LastTotalDeals));

      if (Res) {
        int iOrder = MT4HISTORY::GetNextPosMT4Order(this.LastTotalOrders);
        int iDeal = MT4HISTORY::GetNextPosMT4Deal(this.LastTotalDeals);

        long TimeOrder = (iOrder < TotalOrders)
                             ? ::HistoryOrderGetInteger(::HistoryOrderGetTicket(iOrder), ORDER_TIME_DONE /*_MSC*/)
                             : LONG_MAX;  // ORDER_TIME_DONE_MSC returns zero in the tester (build 1470).
        long TimeDeal = (iDeal < TotalDeals)
                            ? ::HistoryDealGetInteger(::HistoryDealGetTicket(iDeal), DEAL_TIME /*_MSC*/)
                            : LONG_MAX;

        while ((iDeal < TotalDeals) || (iOrder < TotalOrders))
          if (TimeOrder < TimeDeal) {
            this.Amount = ::ArrayResize(this.Tickets, this.Amount + 1, RESERVE_SIZE);

            this.Tickets[this.Amount - 1] = -(long)::HistoryOrderGetTicket(iOrder);

            iOrder = MT4HISTORY::GetNextPosMT4Order(iOrder + 1);

            TimeOrder = (iOrder < TotalOrders)
                            ? ::HistoryOrderGetInteger(::HistoryOrderGetTicket(iOrder), ORDER_TIME_DONE /*_MSC*/)
                            : LONG_MAX;  // ORDER_TIME_DONE_MSC returns zero in the tester (build 1470).
          } else {
            this.Amount = ::ArrayResize(this.Tickets, this.Amount + 1, RESERVE_SIZE);

            this.Tickets[this.Amount - 1] = (long)::HistoryDealGetTicket(iDeal);

            iDeal = MT4HISTORY::GetNextPosMT4Deal(iDeal + 1);

            TimeDeal = (iDeal < TotalDeals) ? ::HistoryDealGetInteger(::HistoryDealGetTicket(iDeal), DEAL_TIME /*_MSC*/)
                                            : LONG_MAX;
          }

        TimeOrder = (TotalOrders > 0)
                        ? ::HistoryOrderGetInteger(::HistoryOrderGetTicket(TotalOrders - 1), ORDER_TIME_DONE /*_MSC*/)
                        : 0;
        TimeDeal =
            (TotalDeals > 0) ? ::HistoryDealGetInteger(::HistoryDealGetTicket(TotalDeals - 1), DEAL_TIME /*_MSC*/) : 0;

        const long MaxTime = ::MathMax(TimeOrder, TimeDeal);

        this.LastTotalOrders = 0;
        this.LastTotalDeals = 0;

        if (LastTimeCurrent - HISTORY_PAUSE > MaxTime)
          this.LastTime = LastTimeCurrent - HISTORY_PAUSE;
        else {
          this.LastTime = (datetime)MaxTime;

          if (TimeOrder == MaxTime)
            for (int i = TotalOrders - 1; i >= 0; i--) {
              if (TimeOrder > ::HistoryOrderGetInteger(::HistoryOrderGetTicket(i), ORDER_TIME_DONE /*_MSC*/)) break;

              this.LastTotalOrders++;
            }

          if (TimeDeal == MaxTime)
            for (int i = TotalDeals - 1; i >= 0; i--) {
              if (TimeDeal != ::HistoryDealGetInteger(::HistoryDealGetTicket(TotalDeals - 1), DEAL_TIME /*_MSC*/))
                break;

              this.LastTotalDeals++;
            }
        }
      } else if (LastTimeCurrent - HISTORY_PAUSE > this.LastTime) {
        this.LastTime = LastTimeCurrent - HISTORY_PAUSE;

        this.LastTotalOrders = 0;
        this.LastTotalDeals = 0;
      }
    }

    return (Res);
  }

 public:
  static bool IsMT4Deal(const ulong Ticket) {
    const ENUM_DEAL_TYPE Type = (ENUM_DEAL_TYPE)::HistoryDealGetInteger(Ticket, DEAL_TYPE);

    return (((Type != DEAL_TYPE_BUY) && (Type != DEAL_TYPE_SELL)) ||
            ((ENUM_DEAL_ENTRY)::HistoryDealGetInteger(Ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT));
  }

  static bool IsMT4Order(const ulong Ticket) {
    return ((::HistoryOrderGetDouble(Ticket, ORDER_VOLUME_CURRENT) > 0) ||
            (::HistoryOrderGetInteger(Ticket, ORDER_POSITION_ID) == 0));
  }

  MT4HISTORY(void) : Amount(0), LastTime(0), LastTotalDeals(0), LastTotalOrders(0), LastInitTime(0) {
    ::ArrayResize(this.Tickets, this.Amount, RESERVE_SIZE);

    this.RefreshHistory();
  }

  int GetAmount(void) {
    this.RefreshHistory();

    return ((int)this.Amount);
  }

  long operator[](const uint Pos) {
    long Res = 0;

    if (Pos >= this.Amount) {
      this.RefreshHistory();

      if (Pos < this.Amount) Res = this.Tickets[Pos];
    } else
      Res = this.Tickets[Pos];

    return (Res);
  }
};

static const bool MT4HISTORY::IsTester = (::MQLInfoInteger(MQL_TESTER) || ::MQLInfoInteger(MQL_OPTIMIZATION) ||
                                          ::MQLInfoInteger(MQL_VISUAL_MODE) || ::MQLInfoInteger(MQL_FRAME_MODE));

#undef HISTORY_PAUSE
#undef DAY
#undef RESERVE_SIZE

struct MT4_ORDER {
  int Ticket;
  int Type;

  double Lots;

  string Symbol;
  string Comment;

  double OpenPrice;
  datetime OpenTime;

  double StopLoss;
  double TakeProfit;

  double ClosePrice;
  datetime CloseTime;

  datetime Expiration;

  int MagicNumber;

  double Profit;

  double Commission;
  double Swap;

  string ToString(void) const {
    static const string Types[] = {"buy", "sell", "buy limit", "sell limit", "buy stop", "sell stop", "balance"};
    const int digits = (int)::SymbolInfoInteger(this.Symbol, SYMBOL_DIGITS);

    return ("#" + (string)this.Ticket + " " + (string)this.OpenTime + " " +
            ((this.Type < ::ArraySize(Types)) ? Types[this.Type] : "unknown") + " " + ::DoubleToString(this.Lots, 2) +
            " " + this.Symbol + " " + ::DoubleToString(this.OpenPrice, digits) + " " +
            ::DoubleToString(this.StopLoss, digits) + " " + ::DoubleToString(this.TakeProfit, digits) + " " +
            ((this.CloseTime > 0) ? ((string)this.CloseTime + " ") : "") + ::DoubleToString(this.ClosePrice, digits) +
            " " + ::DoubleToString(this.Commission, 2) + " " + ::DoubleToString(this.Swap, 2) + " " +
            ::DoubleToString(this.Profit, 2) + " " + ((this.Comment == "") ? "" : (this.Comment + " ")) +
            (string)this.MagicNumber + (((this.Expiration > 0) ? (" expiration " + (string)this.Expiration) : "")));
  }
};

class MT4ORDERS {
 private:
  static MT4_ORDER Order;
  static MT4HISTORY History;

  static const bool IsTester;

  static ulong GetPositionDealIn(const ulong PositionIdentifier = 0) {
    ulong Ticket = 0;

    if ((PositionIdentifier == 0) ? ::HistorySelectByPosition(::PositionGetInteger(POSITION_IDENTIFIER))
                                  : ::HistorySelectByPosition(PositionIdentifier)) {
      const int Total = ::HistoryDealsTotal();

      for (int i = 0; i < Total; i++) {
        const ulong TicketDeal = ::HistoryDealGetTicket(i);

        if (TicketDeal > 0)
          if ((ENUM_DEAL_ENTRY)::HistoryDealGetInteger(TicketDeal, DEAL_ENTRY) == DEAL_ENTRY_IN) {
            Ticket = TicketDeal;

            break;
          }
      }
    }

    return (Ticket);
  }

  static double GetPositionCommission(void) {
    double Commission = ::PositionGetDouble(POSITION_COMMISSION);

    if (Commission == 0) {
      const ulong Ticket = MT4ORDERS::GetPositionDealIn();

      if (Ticket > 0) {
        const double LotsIn = ::HistoryDealGetDouble(Ticket, DEAL_VOLUME);

        if (LotsIn > 0)
          Commission = ::HistoryDealGetDouble(Ticket, DEAL_COMMISSION) * ::PositionGetDouble(POSITION_VOLUME) / LotsIn;
      }
    }

    return (Commission);
  }

  static string GetPositionComment(void) {
    string comment = ::PositionGetString(POSITION_COMMENT);

    if (comment == "") {
      const ulong Ticket = MT4ORDERS::GetPositionDealIn();

      if (Ticket > 0) comment = ::HistoryDealGetString(Ticket, DEAL_COMMENT);
    }

    return (comment);
  }

  static void GetPositionData(void) {
    MT4ORDERS::Order.Ticket = (int)::PositionGetInteger(POSITION_TICKET);
    MT4ORDERS::Order.Type = (int)::PositionGetInteger(POSITION_TYPE);

    MT4ORDERS::Order.Lots = ::PositionGetDouble(POSITION_VOLUME);

    MT4ORDERS::Order.Symbol = ::PositionGetString(POSITION_SYMBOL);
    MT4ORDERS::Order.Comment = MT4ORDERS::GetPositionComment();

    MT4ORDERS::Order.OpenPrice = ::PositionGetDouble(POSITION_PRICE_OPEN);
    MT4ORDERS::Order.OpenTime = (datetime)::PositionGetInteger(POSITION_TIME);

    MT4ORDERS::Order.StopLoss = ::PositionGetDouble(POSITION_SL);
    MT4ORDERS::Order.TakeProfit = ::PositionGetDouble(POSITION_TP);

    MT4ORDERS::Order.ClosePrice = ::PositionGetDouble(POSITION_PRICE_CURRENT);
    MT4ORDERS::Order.CloseTime = 0;

    MT4ORDERS::Order.Expiration = 0;

    MT4ORDERS::Order.MagicNumber = (int)::PositionGetInteger(POSITION_MAGIC);

    MT4ORDERS::Order.Profit = ::PositionGetDouble(POSITION_PROFIT);

    MT4ORDERS::Order.Commission = MT4ORDERS::GetPositionCommission();
    MT4ORDERS::Order.Swap = ::PositionGetDouble(POSITION_SWAP);

    return;
  }

  static void GetOrderData(void) {
    MT4ORDERS::Order.Ticket = (int)::OrderGetInteger(ORDER_TICKET);
    MT4ORDERS::Order.Type = (int)::OrderGetInteger(ORDER_TYPE);

    MT4ORDERS::Order.Lots = ::OrderGetDouble(ORDER_VOLUME_CURRENT);

    MT4ORDERS::Order.Symbol = ::OrderGetString(ORDER_SYMBOL);
    MT4ORDERS::Order.Comment = ::OrderGetString(ORDER_COMMENT);

    MT4ORDERS::Order.OpenPrice = ::OrderGetDouble(ORDER_PRICE_OPEN);
    MT4ORDERS::Order.OpenTime = (datetime)::OrderGetInteger(ORDER_TIME_SETUP);

    MT4ORDERS::Order.StopLoss = ::OrderGetDouble(ORDER_SL);
    MT4ORDERS::Order.TakeProfit = ::OrderGetDouble(ORDER_TP);

    MT4ORDERS::Order.ClosePrice = ::OrderGetDouble(ORDER_PRICE_CURRENT);
    MT4ORDERS::Order.CloseTime = (datetime)::OrderGetInteger(ORDER_TIME_DONE);

    MT4ORDERS::Order.Expiration = (datetime)::OrderGetInteger(ORDER_TIME_EXPIRATION);

    MT4ORDERS::Order.MagicNumber = (int)::OrderGetInteger(ORDER_MAGIC);

    MT4ORDERS::Order.Profit = 0;

    MT4ORDERS::Order.Commission = 0;
    MT4ORDERS::Order.Swap = 0;

    return;
  }

  static void GetHistoryOrderData(const ulong Ticket) {
    MT4ORDERS::Order.Ticket = (int)::HistoryOrderGetInteger(Ticket, ORDER_TICKET);
    MT4ORDERS::Order.Type = (int)::HistoryOrderGetInteger(Ticket, ORDER_TYPE);

    MT4ORDERS::Order.Lots = ::HistoryOrderGetDouble(Ticket, ORDER_VOLUME_CURRENT);

    if (MT4ORDERS::Order.Lots == 0) MT4ORDERS::Order.Lots = ::HistoryOrderGetDouble(Ticket, ORDER_VOLUME_INITIAL);

    MT4ORDERS::Order.Symbol = ::HistoryOrderGetString(Ticket, ORDER_SYMBOL);
    MT4ORDERS::Order.Comment = ::HistoryOrderGetString(Ticket, ORDER_COMMENT);

    MT4ORDERS::Order.OpenPrice = ::HistoryOrderGetDouble(Ticket, ORDER_PRICE_OPEN);
    MT4ORDERS::Order.OpenTime = (datetime)::HistoryOrderGetInteger(Ticket, ORDER_TIME_SETUP);

    MT4ORDERS::Order.StopLoss = ::HistoryOrderGetDouble(Ticket, ORDER_SL);
    MT4ORDERS::Order.TakeProfit = ::HistoryOrderGetDouble(Ticket, ORDER_TP);

    MT4ORDERS::Order.ClosePrice = 0;
    MT4ORDERS::Order.CloseTime = (datetime)::HistoryOrderGetInteger(Ticket, ORDER_TIME_DONE);

    MT4ORDERS::Order.Expiration = (datetime)::HistoryOrderGetInteger(Ticket, ORDER_TIME_EXPIRATION);

    MT4ORDERS::Order.MagicNumber = (int)::HistoryOrderGetInteger(Ticket, ORDER_MAGIC);

    MT4ORDERS::Order.Profit = 0;

    MT4ORDERS::Order.Commission = 0;
    MT4ORDERS::Order.Swap = 0;

    return;
  }

  static void GetHistoryPositionData(const ulong Ticket) {
    MT4ORDERS::Order.Ticket = (int)::HistoryDealGetInteger(Ticket, DEAL_TICKET);
    MT4ORDERS::Order.Type = (int)::HistoryDealGetInteger(Ticket, DEAL_TYPE);

    if ((MT4ORDERS::Order.Type > OP_SELL))
      MT4ORDERS::Order.Type += (OP_BALANCE - OP_SELL - 1);
    else
      MT4ORDERS::Order.Type = 1 - MT4ORDERS::Order.Type;

    MT4ORDERS::Order.Lots = ::HistoryDealGetDouble(Ticket, DEAL_VOLUME);

    MT4ORDERS::Order.Symbol = ::HistoryDealGetString(Ticket, DEAL_SYMBOL);
    MT4ORDERS::Order.Comment = ::HistoryDealGetString(Ticket, DEAL_COMMENT);

    MT4ORDERS::Order.OpenPrice = ::HistoryDealGetDouble(Ticket, DEAL_PRICE);
    MT4ORDERS::Order.OpenTime = (datetime)::HistoryDealGetInteger(Ticket, DEAL_TIME);

    MT4ORDERS::Order.StopLoss = 0;
    MT4ORDERS::Order.TakeProfit = 0;

    MT4ORDERS::Order.ClosePrice = ::HistoryDealGetDouble(Ticket, DEAL_PRICE);
    MT4ORDERS::Order.CloseTime = (datetime)::HistoryDealGetInteger(Ticket, DEAL_TIME);
    ;

    MT4ORDERS::Order.Expiration = 0;

    MT4ORDERS::Order.MagicNumber = (int)::HistoryDealGetInteger(Ticket, DEAL_MAGIC);

    MT4ORDERS::Order.Profit = ::HistoryDealGetDouble(Ticket, DEAL_PROFIT);

    MT4ORDERS::Order.Commission = ::HistoryDealGetDouble(Ticket, DEAL_COMMISSION);
    MT4ORDERS::Order.Swap = ::HistoryDealGetDouble(Ticket, DEAL_SWAP);

    const ulong OpenTicket = MT4ORDERS::GetPositionDealIn(::HistoryDealGetInteger(Ticket, DEAL_POSITION_ID));

    if (OpenTicket > 0) {
      MT4ORDERS::Order.OpenPrice = ::HistoryDealGetDouble(OpenTicket, DEAL_PRICE);
      MT4ORDERS::Order.OpenTime = (datetime)::HistoryDealGetInteger(OpenTicket, DEAL_TIME);

      const double OpenLots = ::HistoryDealGetDouble(OpenTicket, DEAL_VOLUME);

      if (OpenLots > 0)
        MT4ORDERS::Order.Commission +=
            ::HistoryDealGetDouble(OpenTicket, DEAL_COMMISSION) * MT4ORDERS::Order.Lots / OpenLots;

      if (MT4ORDERS::Order.MagicNumber == 0)
        MT4ORDERS::Order.MagicNumber = (int)::HistoryDealGetInteger(OpenTicket, DEAL_MAGIC);

      if (MT4ORDERS::Order.Comment == "") MT4ORDERS::Order.Comment = ::HistoryDealGetString(OpenTicket, DEAL_COMMENT);
    }

    return;
  }

  static bool Waiting(const bool FlagInit = false) {
    static ulong StartTime = 0;

    if (FlagInit) StartTime = ::GetMicrosecondCount();

    const bool Res = (::GetMicrosecondCount() - StartTime < MT4ORDERS::OrderSend_MaxPause);

    if (Res) ::Sleep(0);

    return (Res);
  }

  static bool EqualPrices(const double Price1, const double Price2, const int digits) {
    return (::NormalizeDouble(Price1 - Price2, digits) == 0);
  }

#define WHILE(A) while (!(Res = (A)) && MT4ORDERS::Waiting())

  static bool OrderSend(const MqlTradeRequest &Request, MqlTradeResult &Result) {
    bool Res = ::OrderSend(Request, Result);

    if (Res && !MT4ORDERS::IsTester && (Result.retcode < TRADE_RETCODE_ERROR) && (MT4ORDERS::OrderSend_MaxPause > 0)) {
      Res = (Result.retcode == TRADE_RETCODE_DONE);
      MT4ORDERS::Waiting(true);

      if (Request.action == TRADE_ACTION_DEAL) {
        WHILE(::HistoryOrderSelect(Result.order));

        Res = Res && (((ENUM_ORDER_STATE)::HistoryOrderGetInteger(Result.order, ORDER_STATE) == ORDER_STATE_FILLED) ||
                      ((ENUM_ORDER_STATE)::HistoryOrderGetInteger(Result.order, ORDER_STATE) == ORDER_STATE_PARTIAL));

        if (Res) WHILE(::HistoryDealSelect(Result.deal));
      } else if (Request.action == TRADE_ACTION_PENDING) {
        if (Res)
          WHILE(::OrderSelect(Result.order));
        else {
          WHILE(::HistoryOrderSelect(Result.order));

          Res = false;
        }
      } else if (Request.action == TRADE_ACTION_SLTP) {
        if (Res) {
          bool EqualSL = false;
          bool EqualTP = false;

          const int digits = (int)::SymbolInfoInteger(Request.symbol, SYMBOL_DIGITS);

          if ((Request.position == 0) ? ::PositionSelect(Request.symbol) : ::PositionSelectByTicket(Request.position)) {
            EqualSL = MT4ORDERS::EqualPrices(::PositionGetDouble(POSITION_SL), Request.sl, digits);
            EqualTP = MT4ORDERS::EqualPrices(::PositionGetDouble(POSITION_TP), Request.tp, digits);
          }

          WHILE((EqualSL && EqualTP))
          if ((Request.position == 0) ? ::PositionSelect(Request.symbol) : ::PositionSelectByTicket(Request.position)) {
            EqualSL = MT4ORDERS::EqualPrices(::PositionGetDouble(POSITION_SL), Request.sl, digits);
            EqualTP = MT4ORDERS::EqualPrices(::PositionGetDouble(POSITION_TP), Request.tp, digits);
          }
        }
      } else if (Request.action == TRADE_ACTION_MODIFY) {
        if (Res) {
          bool EqualSL = false;
          bool EqualTP = false;

          const int digits = (int)::SymbolInfoInteger(Request.symbol, SYMBOL_DIGITS);

          if (::OrderSelect(Result.order)) {
            EqualSL = MT4ORDERS::EqualPrices(::OrderGetDouble(ORDER_SL), Request.sl, digits);
            EqualTP = MT4ORDERS::EqualPrices(::OrderGetDouble(ORDER_TP), Request.tp, digits);
          }

          WHILE((EqualSL && EqualTP))
          if (::OrderSelect(Result.order)) {
            EqualSL = MT4ORDERS::EqualPrices(::OrderGetDouble(ORDER_SL), Request.sl, digits);
            EqualTP = MT4ORDERS::EqualPrices(::OrderGetDouble(ORDER_TP), Request.tp, digits);
          }
        }
      } else if (Request.action == TRADE_ACTION_REMOVE)
        if (Res) WHILE(::HistoryOrderSelect(Result.order));
    }

    return (Res);
  }

#undef WHILE

  static bool NewOrderSend(const MqlTradeRequest &Request) {
    MqlTradeResult Result;

    return (MT4ORDERS::OrderSend(Request, Result) ? Result.retcode < TRADE_RETCODE_ERROR : false);
  }

  static bool ModifyPosition(const ulong Ticket, MqlTradeRequest &Request) {
    const bool Res = ::PositionSelectByTicket(Ticket);

    if (Res) {
      Request.action = TRADE_ACTION_SLTP;

      Request.position = Ticket;
      Request.symbol = ::PositionGetString(POSITION_SYMBOL);
    }

    return (Res);
  }

  static ENUM_ORDER_TYPE_FILLING GetFilling(const string Symb, const uint Type = ORDER_FILLING_FOK) {
    const ENUM_SYMBOL_TRADE_EXECUTION ExeMode =
        (ENUM_SYMBOL_TRADE_EXECUTION)::SymbolInfoInteger(Symb, SYMBOL_TRADE_EXEMODE);
    const int FillingMode = (int)::SymbolInfoInteger(Symb, SYMBOL_FILLING_MODE);

    return ((FillingMode == 0 || (Type >= ORDER_FILLING_RETURN) || ((FillingMode & (Type + 1)) != Type + 1))
                ? (((ExeMode == SYMBOL_TRADE_EXECUTION_EXCHANGE) || (ExeMode == SYMBOL_TRADE_EXECUTION_INSTANT))
                       ? ORDER_FILLING_RETURN
                       : ((FillingMode == SYMBOL_FILLING_IOC) ? ORDER_FILLING_IOC : ORDER_FILLING_FOK))
                : (ENUM_ORDER_TYPE_FILLING)Type);
  }

  static bool ModifyOrder(const ulong _ticket, const double _price, const datetime _expiration,
                          MqlTradeRequest &Request) {
    const bool _res = ::OrderSelect(_ticket);

    if (_res) {
      Request.action = TRADE_ACTION_MODIFY;
      Request.order = _ticket;

      Request.price = _price;

      Request.symbol = ::OrderGetString(ORDER_SYMBOL);

      Request.type_filling = MT4ORDERS::GetFilling(Request.symbol);

      if (_expiration > 0) {
        Request.type_time = ORDER_TIME_SPECIFIED;
        Request.expiration = _expiration;
      }
    }

    return (_res);
  }

 public:
  static bool SelectByPosHistory(const int Index) {
    const int Ticket = (int)MT4ORDERS::History[Index];
    const bool Res =
        (Ticket > 0) ? ::HistoryDealSelect(Ticket) : ((Ticket < 0) ? ::HistoryOrderSelect(-Ticket) : false);

    if (Res) {
      if (Ticket > 0)
        MT4ORDERS::GetHistoryPositionData(Ticket);
      else
        MT4ORDERS::GetHistoryOrderData(-Ticket);
    }

    return (Res);
  }

  // position has higher priority
  static bool SelectByPos(const int Index) {
    const int Total = ::PositionsTotal();
    const bool Flag = (Index < Total);

    const bool Res =
        (Flag) ? ::PositionSelectByTicket(::PositionGetTicket(Index)) : ::OrderSelect(::OrderGetTicket(Index - Total));

    if (Res) {
      if (Flag)
        MT4ORDERS::GetPositionData();
      else
        MT4ORDERS::GetOrderData();
    }

    return (Res);
  }

  static bool SelectByHistoryTicket(const int Ticket) {
    bool Res = ::HistoryDealSelect(Ticket) ? MT4HISTORY::IsMT4Deal(Ticket) : false;

    if (Res)
      MT4ORDERS::GetHistoryPositionData(Ticket);
    else {
      Res = ::HistoryOrderSelect(Ticket) ? MT4HISTORY::IsMT4Order(Ticket) : false;

      if (Res) MT4ORDERS::GetHistoryOrderData(Ticket);
    }

    return (Res);
  }

  static bool SelectByExistingTicket(const int Ticket) {
    bool Res = true;

    if (::PositionSelectByTicket(Ticket))
      MT4ORDERS::GetPositionData();
    else if (::OrderSelect(Ticket))
      MT4ORDERS::GetOrderData();
    else
      Res = false;

    return (Res);
  }

  // One Ticket priority:
  // MODE_TRADES:  exist position > exist order > deal > canceled order
  // MODE_HISTORY: deal > canceled order > exist position > exist order
  static bool SelectByTicket(const int Ticket, const int Pool = MODE_TRADES) {
    return ((Pool == MODE_TRADES)
                ? (MT4ORDERS::SelectByExistingTicket(Ticket) ? true : MT4ORDERS::SelectByHistoryTicket(Ticket))
                : (MT4ORDERS::SelectByHistoryTicket(Ticket) ? true : MT4ORDERS::SelectByExistingTicket(Ticket)));
  }

 public:
  static uint OrderSend_MaxPause;

  static bool MT4OrderSelect(const int Index, const int Select, const int Pool = MODE_TRADES) {
    return ((Select == SELECT_BY_POS)
                ? ((Pool == MODE_TRADES) ? MT4ORDERS::SelectByPos(Index) : MT4ORDERS::SelectByPosHistory(Index))
                : MT4ORDERS::SelectByTicket(Index, Pool));
  }

  // MT5 OrderSelect
  static bool MT4OrderSelect(const ulong Ticket) { return (::OrderSelect(Ticket)); }

  static int MT4OrdersTotal(void) { return (::OrdersTotal() + ::PositionsTotal()); }

  // MT5 OrdersTotal
  static int MT4OrdersTotal(const bool MT5) { return (::OrdersTotal()); }

  static int MT4OrdersHistoryTotal(void) { return (MT4ORDERS::History.GetAmount()); }

  static int MT4OrderSend(const string Symb, const int Type, const double dVolume, const double _price,
                          const int SlipPage, const double SL, const double TP, const string comment = NULL,
                          const int magic = 0, const datetime dExpiration = 0, color arrow_color = clrNONE) {
    MqlTradeRequest Request = {0};

    Request.action = (((Type == OP_BUY) || (Type == OP_SELL)) ? TRADE_ACTION_DEAL : TRADE_ACTION_PENDING);
    Request.magic = magic;

    Request.symbol = ((Symb == NULL) ? ::Symbol() : Symb);
    Request.volume = dVolume;
    Request.price = _price;

    Request.tp = TP;
    Request.sl = SL;
    Request.deviation = SlipPage;
    Request.type = (ENUM_ORDER_TYPE)Type;

    Request.type_filling = MT4ORDERS::GetFilling(Request.symbol, (uint)Request.deviation);

    if (dExpiration > 0) {
      Request.type_time = ORDER_TIME_SPECIFIED;
      Request.expiration = dExpiration;
    }

    Request.comment = comment;

    MqlTradeResult Result;

    return (MT4ORDERS::OrderSend(Request, Result)
                ? ((Request.action == TRADE_ACTION_DEAL)
                       ? (::HistoryDealSelect(Result.deal) ? (int)::HistoryDealGetInteger(Result.deal, DEAL_POSITION_ID)
                                                           : -1)
                       : (int)Result.order)
                : -1);
  }

  static bool MT4OrderModify(const ulong Ticket, const double _price, const double SL, const double TP,
                             const datetime Expiration, const color Arrow_Color = clrNONE) {
    MqlTradeRequest Request = {0};

    // considered case if order and position has the same ticket
    bool Res =
        ((Ticket != MT4ORDERS::Order.Ticket) || (MT4ORDERS::Order.Ticket <= OP_SELL))
            ? (MT4ORDERS::ModifyPosition(Ticket, Request) ? true
                                                          : MT4ORDERS::ModifyOrder(Ticket, _price, Expiration, Request))
            : (MT4ORDERS::ModifyOrder(Ticket, _price, Expiration, Request)
                   ? true
                   : MT4ORDERS::ModifyPosition(Ticket, Request));

    if (Res) {
      Request.tp = TP;
      Request.sl = SL;

      Res = MT4ORDERS::NewOrderSend(Request);
    }

    return (Res);
  }

  static bool MT4OrderClose(const ulong Ticket, const double dLots, const double _price, const int SlipPage,
                            const color Arrow_Color = clrNONE) {
    bool Res = ::PositionSelectByTicket(Ticket);

    if (Res) {
      MqlTradeRequest Request = {0};

      Request.action = TRADE_ACTION_DEAL;
      Request.position = Ticket;

      Request.symbol = ::PositionGetString(POSITION_SYMBOL);

      Request.volume = dLots;
      Request.price = _price;

      Request.deviation = SlipPage;

      Request.type = (ENUM_ORDER_TYPE)(1 - ::PositionGetInteger(POSITION_TYPE));

      Request.type_filling = MT4ORDERS::GetFilling(Request.symbol, (uint)Request.deviation);

      Res = MT4ORDERS::NewOrderSend(Request);
    }

    return (Res);
  }

  static bool MT4OrderCloseBy(const ulong Ticket, const int Opposite, const color Arrow_color) {
    bool Res = ::PositionSelectByTicket(Ticket);

    if (Res) {
      string _symbol = ::PositionGetString(POSITION_SYMBOL);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE);

      if (!PositionSelectByTicket(Opposite)) return (false);

      string symbol_by = ::PositionGetString(POSITION_SYMBOL);
      ENUM_POSITION_TYPE type_by = (ENUM_POSITION_TYPE)::PositionGetInteger(POSITION_TYPE);

      if (type == type_by) return (false);
      if (_symbol != symbol_by) return (false);

      MqlTradeRequest Request = {0};

      Request.action = TRADE_ACTION_CLOSE_BY;
      Request.position = Ticket;
      Request.position_by = Opposite;

      Res = MT4ORDERS::NewOrderSend(Request);
    }
    return (Res);
  }

  static bool MT4OrderDelete(const ulong Ticket, const color Arrow_Color = clrNONE) {
    bool Res = ::OrderSelect(Ticket);

    if (Res) {
      MqlTradeRequest Request = {0};

      Request.action = TRADE_ACTION_REMOVE;
      Request.order = Ticket;

      Res = MT4ORDERS::NewOrderSend(Request);
    }

    return (Res);
  }
};

static MT4_ORDER MT4ORDERS::Order = {0};

static MT4HISTORY MT4ORDERS::History;

static const bool MT4ORDERS::IsTester = (::MQLInfoInteger(MQL_TESTER) || ::MQLInfoInteger(MQL_OPTIMIZATION) ||
                                         ::MQLInfoInteger(MQL_VISUAL_MODE) || ::MQLInfoInteger(MQL_FRAME_MODE));

static uint MT4ORDERS::OrderSend_MaxPause = 1000000;  // Maximum time synchronization in microseconds.

bool OrderClose(const ulong Ticket, const double dLots, const double _price, const int SlipPage,
                const color Arrow_Color = clrNONE) {
  return (MT4ORDERS::MT4OrderClose(Ticket, dLots, _price, SlipPage, Arrow_Color));
}

bool OrderModify(const ulong Ticket, const double _price, const double SL, const double TP, const datetime Expiration,
                 const color Arrow_Color = clrNONE) {
  return (MT4ORDERS::MT4OrderModify(Ticket, _price, SL, TP, Expiration, Arrow_Color));
}

bool OrderDelete(const ulong Ticket, const color Arrow_Color = clrNONE) {
  return (MT4ORDERS::MT4OrderDelete(Ticket, Arrow_Color));
}

bool OrderCloseBy(const ulong Ticket, const int Opposite, const color Arrow_color) {
  return (MT4ORDERS::MT4OrderCloseBy(Ticket, Opposite, Arrow_color));
}

#endif  // __MT4ORDERS__
#endif  // __MQL5__

/**
 * MQL4 wrapper to work in MQL5.
 */
class MQL4 {
 public:
  /**
   * Converts MQL4 time periods.
   *
   * As in MQL5 chart period constants changed, and some new time periods (M2, M3, M4, M6, M10, M12, H2, H3, H6, H8,
   * H12) were added.
   *
   * Note: In MQL5 the numerical values of chart timeframe constants (from H1)
   * are not equal to the number of minutes of a bar.
   * E.g. In MQL5, the value of constant PERIOD_H1 is 16385, but in MQL4 PERIOD_H1=60.
   *
   * @see: https://www.mql5.com/en/articles/81
   */
  static ENUM_TIMEFRAMES TFMigrate(int _tf) {
    switch (_tf) {
      case 0:
        return (PERIOD_CURRENT);
      case 1:
        return (PERIOD_M1);
      case 2:
        return (PERIOD_M2);
      case 3:
        return (PERIOD_M3);
      case 4:
        return (PERIOD_M4);
      case 5:
        return (PERIOD_M5);
      case 6:
        return (PERIOD_M6);
      case 10:
        return (PERIOD_M10);
      case 12:
        return (PERIOD_M12);
      case 15:
        return (PERIOD_M15);
      case 30:
        return (PERIOD_M30);
      case 60:
        return (PERIOD_H1);
      case 240:
        return (PERIOD_H4);
      case 1440:
        return (PERIOD_D1);
      case 10080:
        return (PERIOD_W1);
      case 43200:
        return (PERIOD_MN1);
      case 16385:
        return (PERIOD_H1);
      case 16386:
        return (PERIOD_H2);
      case 16387:
        return (PERIOD_H3);
      case 16388:
        return (PERIOD_H4);
      case 16390:
        return (PERIOD_H6);
      case 16392:
        return (PERIOD_H8);
      case 16396:
        return (PERIOD_H12);
      case 16408:
        return (PERIOD_D1);
      case 32769:
        return (PERIOD_W1);
      case 49153:
        return (PERIOD_MN1);
      default:
        return (PERIOD_CURRENT);
    }
  }

  ENUM_MA_METHOD MethodMigrate(int method) {
    switch (method) {
      case 0:
        return (MODE_SMA);
      case 1:
        return (MODE_EMA);
      case 2:
        return (MODE_SMMA);
      case 3:
        return (MODE_LWMA);
      default:
        return (MODE_SMA);
    }
  }

  ENUM_APPLIED_PRICE PriceMigrate(int price) {
    switch (price) {
      case 1:
        return (PRICE_CLOSE);
      case 2:
        return (PRICE_OPEN);
      case 3:
        return (PRICE_HIGH);
      case 4:
        return (PRICE_LOW);
      case 5:
        return (PRICE_MEDIAN);
      case 6:
        return (PRICE_TYPICAL);
      case 7:
        return (PRICE_WEIGHTED);
      default:
        return (PRICE_CLOSE);
    }
  }

  ENUM_STO_PRICE StoFieldMigrate(int field) {
    switch (field) {
      case 0:
        return (STO_LOWHIGH);
      case 1:
        return (STO_CLOSECLOSE);
      default:
        return (STO_LOWHIGH);
    }
  }
};
#endif  // MQL4_MQH

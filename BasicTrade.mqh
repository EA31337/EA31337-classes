//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                            Copyright 2016, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+
#property strict

//---
#define CUR    0
#define PREV   1
#define FAR    2
//---
#define ERR_ORDER_SELECT            ERR_USER_ERROR_FIRST + 102
#define ERR_INVALID_ORDER_TYPE      ERR_USER_ERROR_FIRST + 103
#define ERR_INVALID_SYMBOL_NAME     ERR_USER_ERROR_FIRST + 104
#define ERR_INVALID_EXPIRATION_TIME ERR_USER_ERROR_FIRST + 105
//---
#define TRADE_PAUSE_SHORT 500
#define TRADE_PAUSE_LONG  5000
#define OPEN_METHODS      8

#ifdef __MQL4__
//+------------------------------------------------------------------+
//|   ENUM_APPLIED_VOLUME                                            |
//+------------------------------------------------------------------+
enum ENUM_APPLIED_VOLUME
  {
   VOLUME_TICK,
   VOLUME_REAL
  };
#endif

//+------------------------------------------------------------------+
#ifdef __MQL4__
#define TFS 9
const ENUM_TIMEFRAMES tf[TFS]=
  {
   PERIOD_M1,PERIOD_M5,PERIOD_M15,
   PERIOD_M30,PERIOD_H1,PERIOD_H4,
   PERIOD_D1,PERIOD_W1,PERIOD_MN1
  };
#endif

//+------------------------------------------------------------------+
#ifdef __MQL5__

#include <Trade\Trade.mqh>

#define TFS 21
const ENUM_TIMEFRAMES tf[TFS]=
  {
   PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,
   PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,
   PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,
   PERIOD_D1,PERIOD_W1,PERIOD_MN1
  };
#endif
//+------------------------------------------------------------------+
//|   TPositionCount                                                 |
//+------------------------------------------------------------------+
struct TPositionCount
  {
   int               buy_count;
   int               sell_count;
  };
//+------------------------------------------------------------------+
//|   TDealTime                                                      |
//+------------------------------------------------------------------+
struct TDealTime
  {
   datetime          buy_time;
   datetime          sell_time;
  };
//+------------------------------------------------------------------+
//|   ENUN_OPEN_METHOD                                               |
//+------------------------------------------------------------------+
enum ENUM_OPEN_METHOD
  {
   OPEN_METHOD_ONE=-1,// One Of Methods
   OPEN_METHOD_SUM=0,// Sum Of Methods
   OPEN_METHOD1=1,   // Method #1 (1)
   OPEN_METHOD2=2,   // Method #2 (2)
   OPEN_METHOD3=4,   // Method #3 (4)
   OPEN_METHOD4=8,   // Method #4 (8)
   OPEN_METHOD5=16,  // Method #5 (16)
   OPEN_METHOD6=32,  // Method #6 (32)
   OPEN_METHOD7=64,  // Method #7 (64)
   OPEN_METHOD8=128  // Method #8 (128)
  };
//+------------------------------------------------------------------+
//|   GetOpenMethod                                                  |
//+------------------------------------------------------------------+
int GetOpenMethod(const int open_method,const int one_of_methods,const int sum_of_methods)
  {
   int result=open_method;

   if(open_method==OPEN_METHOD_ONE)
      result=-one_of_methods;

   if(open_method==OPEN_METHOD_SUM)
      result=sum_of_methods;

   return(result);
  }
//+------------------------------------------------------------------+
//|   ENUM_TRADE_DIRECTION                                           |
//+------------------------------------------------------------------+
enum ENUM_TRADE_DIRECTION
  {
   TRADE_NONE=-1, //None
   TRADE_BUY=0,   //Buy
   TRADE_SELL=1,  //Sell
   TRADE_BOTH=2   //Both
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_RUN_MODE
  {
   RUN_OPTIMIZATION,
   RUN_VISUAL,
   RUN_TESTER,
   RUN_LIVE
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_RUN_MODE GetRunMode(void)
  {
   if(MQLInfoInteger(MQL_OPTIMIZATION))
      return(RUN_OPTIMIZATION);
   if(MQLInfoInteger(MQL_VISUAL_MODE))
      return(RUN_VISUAL);
   if(MQLInfoInteger(MQL_TESTER))
      return(RUN_TESTER);
   return(RUN_LIVE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string BoolToString(const bool _value)
  {
   if(_value)
      return("yes");
   return("no");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeframeToString(const ENUM_TIMEFRAMES _tf)
  {
   return(StringSubstr(EnumToString(_tf),7));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OpenMethodToString(const ENUM_OPEN_METHOD _open_method,
                          const int one_of_methods,
                          const int sum_of_methods)
  {
   string result="";
   switch(_open_method)
     {
      case OPEN_METHOD_ONE: result="One Of Methods ("+IntegerToString(one_of_methods)+")"; break;
      case OPEN_METHOD_SUM: result="Sum Of Methods ("+IntegerToString(sum_of_methods)+")"; break;
      default: result=StringSubstr(EnumToString(_open_method),5); break;
     }
   return(result);
  }

#ifdef __MQL5__
//+------------------------------------------------------------------+
//|   GetTypeFilling                                                 |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING GetTypeFilling(const string _symbol)
  {
   ENUM_ORDER_TYPE_FILLING result=ORDER_FILLING_RETURN;
   uint filling=(uint)SymbolInfoInteger(_symbol,SYMBOL_FILLING_MODE);
   if((filling&SYMBOL_FILLING_IOC)!=0)
      result=ORDER_FILLING_IOC;
   if((filling&SYMBOL_FILLING_FOK)!=0)
      result=ORDER_FILLING_FOK;
   return(result);
  }
#endif  
//+------------------------------------------------------------------+
//|   CBasicTrade                                                    |
//+------------------------------------------------------------------+
class CBasicTrade
  {
private:
   int               m_last_error;

protected:
   //+------------------------------------------------------------------+
   double NormalizeVolume(const double _volume)
     {
      double lot_min=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
      double lot_max=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
      double lot_step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
      //---
      double lot_value=_volume;
      //--- нормировка значения лота
      if(lot_value<=lot_min)lot_value=lot_min;           // проверка на минимальный лот
      else if(lot_value>=lot_max)lot_value=lot_max;      // проверка на максимальный лот
      else lot_value=round(lot_value/lot_step)*lot_step; // округление до ближайшего меньшего
      //---
      return(NormalizeDouble(lot_value,2));
     }

   //+------------------------------------------------------------------+
   int   TimeframeToIndex(ENUM_TIMEFRAMES _tf)
     {
      if(_tf==0 || _tf==PERIOD_CURRENT)
         _tf=(ENUM_TIMEFRAMES)_Period;
      int total=ArraySize(tf);
      for(int i=0;i<total;i++)
        {
         if(tf[i]==_tf)
            return(i);
        }
      return(0);
     }

public:

   //+------------------------------------------------------------------+
   void  CBasicTrade(void)
     {
      m_last_error=0;
     }

   //+------------------------------------------------------------------+
   bool  Trade(string   _symbol,          // symbol
               ENUM_TRADE_DIRECTION _type,// operation
               double   _volume,          // volume
               int      _stop_loss,       // stop loss, pips
               int      _take_profit,     // take profit, pips
               string   _comment=NULL,    // comment
               int      _magic=0,         // magic number
               )
     {
      ResetLastError();
      m_last_error=0;

      //--- check symbol name
      double _point=SymbolInfoDouble(_symbol,SYMBOL_POINT);
      if(_point==0.0)
        {
         m_last_error=ERR_INVALID_SYMBOL_NAME;
         return(false);
        }

      //--- order type
      if(!(_type==TRADE_BUY || _type==TRADE_SELL))
        {
         m_last_error=ERR_INVALID_ORDER_TYPE;
         return(false);
        }

      //--- get digits
      int _digits=(int)SymbolInfoInteger(_symbol,SYMBOL_DIGITS);

      //--- get coef point
      int _coef_point=1;
      if(_digits==3 || _digits==5)
         _coef_point=10;

#ifdef __MQL4__

      int attempts=5;
      while(attempts>0)
        {
         ResetLastError();

         if(IsTradeContextBusy())
           {
            Sleep(TRADE_PAUSE_SHORT);
            attempts--;
            continue;
           }

         RefreshRates();

         //--- check the free margin
         if(AccountFreeMarginCheck(_symbol,_type,_volume)<=0 || _LastError==ERR_NOT_ENOUGH_MONEY)
           {
            m_last_error=ERR_NOT_ENOUGH_MONEY;
            return(false);
           }

         //---
         double price=0.0;
         if(_type==OP_BUY)
            price=NormalizeDouble(SymbolInfoDouble(_symbol,SYMBOL_ASK),_digits);
         if(_type==OP_SELL)
            price=NormalizeDouble(SymbolInfoDouble(_symbol,SYMBOL_BID),_digits);

         //---
         int slippage=(int)SymbolInfoInteger(_symbol,SYMBOL_SPREAD);

         //---
         double volume=NormalizeVolume(_volume);

         //---         
         int ticket=OrderSend(_symbol,_type,volume,price,slippage,0,0,_comment,_magic,0,clrNONE);
         if(ticket>0)
           {
            if(_stop_loss>0 || _take_profit>0)
              {

               if(OrderSelect(ticket,SELECT_BY_TICKET))
                 {

                  //---
                  double order_open_price=NormalizeDouble(OrderOpenPrice(),_digits);
                  double order_stop_loss=NormalizeDouble(OrderStopLoss(),_digits);
                  double order_take_profit=NormalizeDouble(OrderTakeProfit(),_digits);

                  double sl=0.0;
                  double tp=0.0;

                  //---
                  attempts=5;
                  while(attempts>0)
                    {
                     ResetLastError();
                     RefreshRates();
                     //---
                     double _bid = SymbolInfoDouble(_symbol, SYMBOL_BID);
                     double _ask = SymbolInfoDouble(_symbol, SYMBOL_ASK);

                     if(IsTradeContextBusy())
                       {
                        attempts--;
                        Sleep(TRADE_PAUSE_SHORT);
                        continue;
                       }

                     //---
                     int stop_level=(int)SymbolInfoInteger(_symbol,SYMBOL_TRADE_STOPS_LEVEL);
                     int spread=(int)SymbolInfoInteger(_symbol,SYMBOL_SPREAD);
                     stop_level=fmax(stop_level,spread);

                     //---
                     if(OrderType()==OP_BUY)
                       {
                        if(_stop_loss==-1.0) sl=order_stop_loss;
                        else if(_stop_loss==0.0) sl=0.0;
                        else sl=NormalizeDouble(fmin(order_open_price-_stop_loss*_coef_point*_point,_bid-stop_level*_point),_digits);

                        if(_take_profit==-1.0) tp=order_take_profit;
                        else if(_take_profit==0.0) tp=0.0;
                        else tp=NormalizeDouble(fmax(order_open_price+_take_profit*_coef_point*_point,_bid+stop_level*_point),_digits);
                       }

                     if(OrderType()==OP_SELL)
                       {
                        if(_stop_loss==-1.0) sl=order_stop_loss;
                        else if(_stop_loss==0.0) sl=0.0;
                        else sl=NormalizeDouble(fmax(order_open_price+_stop_loss*_coef_point*_point,_ask+stop_level*_point),_digits);

                        if(_take_profit==-1.0) tp=order_take_profit;
                        else if(_take_profit==0.0) tp=0.0;
                        else tp=NormalizeDouble(fmin(order_open_price-_take_profit*_coef_point*_point,_ask-stop_level*_point),_digits);
                       }

                     if(sl==order_stop_loss && tp==order_take_profit)
                        return(true);

                     //---
                     ResetLastError();
                     if(OrderModify(ticket,order_open_price,sl,tp,0,clrNONE))
                       {
                        return(true);
                       }
                     else
                       {
                        //ENUM_ERROR_LEVEL level=PrintError(_LastError);
                        //if(level==LEVEL_ERROR)
                          {
                           Sleep(TRADE_PAUSE_LONG);
                           return(false);
                          }
                       }

                     //---
                     Sleep(TRADE_PAUSE_SHORT);
                     attempts--;
                    }// end while

                 }

               Sleep(TRADE_PAUSE_SHORT);
               return(true); //position opened
              }
            else
              {
               //ENUM_ERROR_LEVEL level=PrintError(_LastError);
               //if(level==LEVEL_ERROR)
                 {
                  Sleep(TRADE_PAUSE_LONG);
                  break;
                 }
              }// end else

            Sleep(TRADE_PAUSE_SHORT);
            attempts--;
           }
        }
#endif

      //---
#ifdef __MQL5__

      ENUM_ORDER_TYPE order_type=-1;
      double price=0.0;
      double sl=0.0;
      double tp=0.0;
      double _ask=SymbolInfoDouble(_symbol,SYMBOL_ASK);
      double _bid=SymbolInfoDouble(_symbol,SYMBOL_BID);
      int stop_level=(int)SymbolInfoInteger(_symbol,SYMBOL_TRADE_STOPS_LEVEL);
      if(_type==TRADE_BUY)
        {
         order_type=ORDER_TYPE_BUY;
         price=_ask;

         if(_stop_loss>0)
            sl=NormalizeDouble(fmin(price-_stop_loss*_coef_point*_point,_bid-stop_level*_point),_digits);

         if(_take_profit>0)
            tp=NormalizeDouble(fmax(price+_take_profit*_coef_point*_point,_bid+stop_level*_point),_digits);

        }
      if(_type==TRADE_SELL)
        {
         order_type=ORDER_TYPE_SELL;
         price=_bid;

         if(_stop_loss>0)
            sl=NormalizeDouble(fmax(price+_stop_loss*_coef_point*_point,_ask+stop_level*_point),_digits);

         if(_take_profit>0)
            tp=NormalizeDouble(fmin(price-_take_profit*_coef_point*_point,_ask-stop_level*_point),_digits);
        }

      double volume=NormalizeVolume(_volume);

      CTrade trade;
      trade.SetDeviationInPoints(SymbolInfoInteger(_symbol,SYMBOL_SPREAD));
      trade.SetExpertMagicNumber(_magic);

      //---
      trade.SetTypeFilling(GetTypeFilling(_symbol));
      bool result=trade.PositionOpen(_symbol,order_type,volume,price,sl,tp,_comment);
      if(!result)
         m_last_error=(int)trade.ResultRetcode();
#endif   

      return(true);
     }

   //+------------------------------------------------------------------+
   int GetLastError()
     {
      return(m_last_error);
     }
  };
//+------------------------------------------------------------------+
bool PositonTotal(TPositionCount &count,const string _symbol=NULL,const int _magic=0)
  {

   ResetLastError();

   count.buy_count=0;
   count.sell_count=0;

#ifdef __MQL4__
   int total= OrdersTotal();
   for(int i=0;i<total;i++)
     {
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
#endif

#ifdef __MQL5__
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

   return(true);
  }
//+------------------------------------------------------------------+     
bool DealLastTime(TDealTime &last_time,const string _symbol,const int _magic)
  {
   last_time.buy_time=0;
   last_time.sell_time=0;
//---   
#ifdef __MQL4__   
   int orders_total=OrdersHistoryTotal();
   for(int i=orders_total-1; i>=0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         return(false);

      if(_symbol!=NULL && OrderSymbol()!=_symbol)
         continue;
      if(_magic!=-1 && OrderMagicNumber()!=_magic)
         continue;
      //---
      if(OrderType()==OP_BUY && 
         last_time.buy_time==0)
         last_time.buy_time=OrderOpenTime();
      //---
      if(OrderType()==OP_SELL && 
         last_time.sell_time==0)
         last_time.sell_time=OrderOpenTime();
      //---
      break;
     }
#endif     


#ifdef __MQL5__
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Time(const string _symbol,const ENUM_TIMEFRAMES _tf,const int _index)
  {
#ifdef __MQL4__
   return(iTime(_symbol,_tf,_index));
#endif

#ifdef __MQL5__
   datetime ArTime[1]={0};
   CopyTime(_Symbol,_tf,0,1,ArTime);
   return(ArTime[0]);
#endif
  }

#ifdef __MQL4__
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_POSITION_TYPE
  {
   POSITION_TYPE_BUY,
   POSITION_TYPE_SELL,
  };
#endif
//+------------------------------------------------------------------+
//|   PositionCloseAll                                               |
//+------------------------------------------------------------------+
bool PositionCloseAll(const string              _symbol=NULL,
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
               Sleep(TRADE_PAUSE_SHORT);
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

         if(!res_one)// если одну не закрыли то возвращаем TRUE
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
//+------------------------------------------------------------------+

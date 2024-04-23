//+------------------------------------------------------------------+
//|                                                    test_enum.mq4 |
//|                                                      Cedric Gava |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Cedric Gava"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <EA31337-classes/Test.mqh>
#include <EA31337-classes/Trade/TradeSignal.struct.h>


// all the following macro return true if the main signal is activated AND the filter is not activated AND the time filter is not activated
#define TRADE_SIGNAL_IS_CLOSE_BUY(x)  ((x & TRADE_SIGNAL_FLAG_CLOSE_BUY_MAIN) && !(x & (TRADE_SIGNAL_FLAG_CLOSE_BUY_FILTER | TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER)))
#define TRADE_SIGNAL_IS_CLOSE_SELL(x) ((x & TRADE_SIGNAL_FLAG_CLOSE_SELL_MAIN) && !(x & (TRADE_SIGNAL_FLAG_CLOSE_SELL_FILTER | TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER)))
#define TRADE_SIGNAL_IS_OPEN_BUY(x)  ((x & TRADE_SIGNAL_FLAG_OPEN_BUY_MAIN) && !(x & (TRADE_SIGNAL_FLAG_OPEN_BUY_FILTER | TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER)))
#define TRADE_SIGNAL_IS_OPEN_SELL(x) ((x & TRADE_SIGNAL_FLAG_OPEN_SELL_MAIN) && !(x & (TRADE_SIGNAL_FLAG_OPEN_SELL_FILTER | TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER)))

int testEnum(){
  uint s;
   
  s = TRADE_SIGNAL_FLAG_CLOSE_BUY_MAIN |                                  0 | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==true ,"Fail!");
  s = TRADE_SIGNAL_FLAG_CLOSE_BUY_MAIN | TRADE_SIGNAL_FLAG_CLOSE_BUY_FILTER | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!");
  s = TRADE_SIGNAL_FLAG_CLOSE_BUY_MAIN | 0                                  | TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!");
  s = TRADE_SIGNAL_FLAG_CLOSE_BUY_MAIN | TRADE_SIGNAL_FLAG_CLOSE_BUY_FILTER | TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!");
  s = 0                                |                                  0 | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!");
  s = 0                                | TRADE_SIGNAL_FLAG_CLOSE_BUY_FILTER | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!");
  s = 0                                | 0                                  | TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!");
  s = 0                                | TRADE_SIGNAL_FLAG_CLOSE_BUY_FILTER | TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!"); 
   
  s = TRADE_SIGNAL_FLAG_CLOSE_SELL_MAIN|                                  0 | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==true ,"Fail!");
  s = TRADE_SIGNAL_FLAG_CLOSE_SELL_MAIN| TRADE_SIGNAL_FLAG_CLOSE_SELL_FILTER| 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");
  s = TRADE_SIGNAL_FLAG_CLOSE_SELL_MAIN| 0                                  | TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");
  s = TRADE_SIGNAL_FLAG_CLOSE_SELL_MAIN| TRADE_SIGNAL_FLAG_CLOSE_SELL_FILTER| TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");
  s = 0                                |                                  0 | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");
  s = 0                                | TRADE_SIGNAL_FLAG_CLOSE_SELL_FILTER| 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");
  s = 0                                | 0                                  | TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");
  s = 0                                | TRADE_SIGNAL_FLAG_CLOSE_SELL_FILTER| TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");


  s = TRADE_SIGNAL_FLAG_OPEN_BUY_MAIN  |                                  0 | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==true ,"Fail!");
  s = TRADE_SIGNAL_FLAG_OPEN_BUY_MAIN  | TRADE_SIGNAL_FLAG_OPEN_BUY_FILTER  | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");
  s = TRADE_SIGNAL_FLAG_OPEN_BUY_MAIN  | 0                                  | TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");
  s = TRADE_SIGNAL_FLAG_OPEN_BUY_MAIN  | TRADE_SIGNAL_FLAG_OPEN_BUY_FILTER  | TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");
  s = 0                                |                                  0 | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");
  s = 0                                | TRADE_SIGNAL_FLAG_OPEN_BUY_FILTER  | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");
  s = 0                                | 0                                  | TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");
  s = 0                                | TRADE_SIGNAL_FLAG_OPEN_BUY_FILTER  | TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");

  s = TRADE_SIGNAL_FLAG_OPEN_SELL_MAIN |                                  0 | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==true ,"Fail!");
  s = TRADE_SIGNAL_FLAG_OPEN_SELL_MAIN | TRADE_SIGNAL_FLAG_OPEN_SELL_FILTER | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  s = TRADE_SIGNAL_FLAG_OPEN_SELL_MAIN | 0                                  | TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  s = TRADE_SIGNAL_FLAG_OPEN_SELL_MAIN | TRADE_SIGNAL_FLAG_OPEN_SELL_FILTER | TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  s = 0                                |                                  0 | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  s = 0                                | TRADE_SIGNAL_FLAG_OPEN_SELL_FILTER | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  s = 0                                | 0                                  | TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  s = 0                                | TRADE_SIGNAL_FLAG_OPEN_SELL_FILTER | TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  return INIT_SUCCEEDED;
} 

void OnStart(){
    if (testEnum()==INIT_SUCCEEDED){
        Print("Test passed!");
    } else {
        Print("Test failed!");
    }
}

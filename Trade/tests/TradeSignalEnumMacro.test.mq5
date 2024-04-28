//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

// Includes.
#include "../../Test.mqh"
#include "../TradeSignal.struct.h"

int testEnum(){
  uint s;

  s = SIGNAL_CLOSE_BUY_MAIN            |                       0 | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==true ,"Fail!");
  s = SIGNAL_CLOSE_BUY_MAIN            | SIGNAL_CLOSE_BUY_FILTER | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!");
  s = SIGNAL_CLOSE_BUY_MAIN            | 0                                  | SIGNAL_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!");
  s = SIGNAL_CLOSE_BUY_MAIN            | SIGNAL_CLOSE_BUY_FILTER            | SIGNAL_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!");
  s = 0                                |                       0 | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!");
  s = 0                                | SIGNAL_CLOSE_BUY_FILTER | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!");
  s = 0                                | 0                                  | SIGNAL_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!");
  s = 0                                | SIGNAL_CLOSE_BUY_FILTER            | SIGNAL_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_BUY(s)==false,"Fail!");

  s = SIGNAL_CLOSE_SELL_MAIN           |                       0 | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==true ,"Fail!");
  s = SIGNAL_CLOSE_SELL_MAIN           | SIGNAL_CLOSE_SELL_FILTER| 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");
  s = SIGNAL_CLOSE_SELL_MAIN           | 0                                  | SIGNAL_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");
  s = SIGNAL_CLOSE_SELL_MAIN           | SIGNAL_CLOSE_SELL_FILTER           | SIGNAL_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");
  s = 0                                |                       0 | 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");
  s = 0                                | SIGNAL_CLOSE_SELL_FILTER| 0                                   ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");
  s = 0                                | 0                                  | SIGNAL_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");
  s = 0                                | SIGNAL_CLOSE_SELL_FILTER           | SIGNAL_CLOSE_TIME_FILTER ; assertTrueOrFail(TRADE_SIGNAL_IS_CLOSE_SELL(s)==false,"Fail!");


  s = SIGNAL_OPEN_BUY_MAIN             |                                  0 | 0                        ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==true ,"Fail!");
  s = SIGNAL_OPEN_BUY_MAIN             | SIGNAL_OPEN_BUY_FILTER             | 0                        ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");
  s = SIGNAL_OPEN_BUY_MAIN             | 0                                  | SIGNAL_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");
  s = SIGNAL_OPEN_BUY_MAIN             | SIGNAL_OPEN_BUY_FILTER             | SIGNAL_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");
  s = 0                                |                                  0 | 0                        ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");
  s = 0                                | SIGNAL_OPEN_BUY_FILTER             | 0                        ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");
  s = 0                                | 0                                  | SIGNAL_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");
  s = 0                                | SIGNAL_OPEN_BUY_FILTER             | SIGNAL_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_BUY(s)==false,"Fail!");

  s = SIGNAL_OPEN_SELL_MAIN            |                                  0 | 0                        ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==true ,"Fail!");
  s = SIGNAL_OPEN_SELL_MAIN            | SIGNAL_OPEN_SELL_FILTER            | 0                        ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  s = SIGNAL_OPEN_SELL_MAIN            | 0                                  | SIGNAL_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  s = SIGNAL_OPEN_SELL_MAIN            | SIGNAL_OPEN_SELL_FILTER            | SIGNAL_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  s = 0                                |                                  0 | 0                        ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  s = 0                                | SIGNAL_OPEN_SELL_FILTER            | 0                        ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  s = 0                                | 0                                  | SIGNAL_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  s = 0                                | SIGNAL_OPEN_SELL_FILTER            | SIGNAL_OPEN_TIME_FILTER  ; assertTrueOrFail(TRADE_SIGNAL_IS_OPEN_SELL(s)==false,"Fail!");
  return INIT_SUCCEEDED;
}

/**
 * Implements OnInit().
 */
int OnInit() {
    return testEnum();
}

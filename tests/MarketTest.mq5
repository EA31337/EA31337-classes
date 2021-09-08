//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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

/**
 * @file
 * Test functionality of Market class.
 */

// Includes.
#include "../Chart.define.h"
#include "../Market.mqh"
#include "../Test.mqh"

/**
 * Implements OnInit().
 */
int OnInit() {
  Market *market = new Market();
  Market::RefreshRates();
  // Test MarketInfo().
#ifdef __MQL5__
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_LOW) == SymbolInfoDouble(_Symbol, SYMBOL_LASTLOW),
                   "Invalid market value for MODE_LOW!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_HIGH) == SymbolInfoDouble(_Symbol, SYMBOL_LASTHIGH),
                   "Invalid market value for MODE_HIGH!");
#endif
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_TIME) == market.GetQuoteTime(),
                   "Invalid market value for MODE_TIME!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_BID) == market.GetBid(), "Invalid market value for MODE_BID!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_ASK) == market.GetAsk(), "Invalid market value for MODE_ASK!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_POINT) == market.GetPointSize(),
                   "Invalid market value for MODE_POINT!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_DIGITS) == market.GetDigits(),
                   "Invalid market value for MODE_DIGITS!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_SPREAD) == market.GetSpreadInPts(),
                   "Invalid market value for MODE_SPREAD!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_STOPLEVEL) == market.GetTradeStopsLevel(),
                   "Invalid market value for MODE_STOPLEVEL!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_LOTSIZE) == market.GetTradeContractSize(),
                   "Invalid market value for MODE_LOTSIZE!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_TICKVALUE) == market.GetTickValue(),
                   "Invalid market value for MODE_TICKVALUE!");
  assertTrueOrFail((float)Market::MarketInfo(_Symbol, MODE_TICKSIZE) == (float)market.GetTickSize(),
                   "Invalid market value for MODE_TICKSIZE!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_SWAPLONG) == market.GetSwapLong(),
                   "Invalid market value for MODE_SWAPLONG!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_SWAPSHORT) == market.GetSwapShort(),
                   "Invalid market value for MODE_SWAPSHORT!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_LOTSTEP) == market.GetVolumeStep(),
                   "Invalid market value for MODE_LOTSTEP!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_MINLOT) == market.GetVolumeMin(),
                   "Invalid market value for MODE_MINLOT!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_MAXLOT) == market.GetVolumeMax(),
                   "Invalid market value for MODE_MAXLOT!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_SWAPTYPE) == market.GetSwapMode(),
                   "Invalid market value for MODE_SWAPTYPE!");
  assertTrueOrFail(
      Market::MarketInfo(_Symbol, MODE_PROFITCALCMODE) == SymbolInfoInteger(_Symbol, SYMBOL_TRADE_CALC_MODE),
      "Invalid market value for SYMBOL_TRADE_CALC_MODE!");
  // @todo: MODE_STARTING
  // @todo: MODE_EXPIRATION
  // @fixme
  // assertTrueOrFail((bool)Market::MarketInfo(_Symbol, MODE_TRADEALLOWED) == Terminal::IsTradeAllowed(),
  //"Invalid market value for MODE_TRADEALLOWED!");
  // MODE_MARGINCALCMODE
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_MARGININIT) == market.GetMarginInit(),
                   "Invalid market value for MODE_MARGININIT!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_MARGINMAINTENANCE) == market.GetMarginMaintenance(),
                   "Invalid market value for MODE_MARGINMAINTENANCE!");
  // @todo: MODE_MARGINHEDGED
  // @todo: MODE_MARGINREQUIRED
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_FREEZELEVEL) == market.GetFreezeLevel(),
                   "Invalid market value for MODE_FREEZELEVEL!");
  // Test MarketInfo() for MQL4.
#ifdef __MQL4__
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_LOW) == MarketInfo(_Symbol, MODE_LOW),
                   "Invalid market value for MODE_LOW!");  // @fixme
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_HIGH) == MarketInfo(_Symbol, MODE_HIGH),
                   "Invalid market value for MODE_HIGH!");  // @fixme
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_TIME) == MarketInfo(_Symbol, MODE_TIME),
                   "Invalid market value for MODE_TIME!");  // @fixme
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_BID) == MarketInfo(_Symbol, MODE_BID),
                   "Invalid market value for MODE_BID!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_ASK) == MarketInfo(_Symbol, MODE_ASK),
                   "Invalid market value for MODE_ASK!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_POINT) == MarketInfo(_Symbol, MODE_POINT),
                   "Invalid market value for MODE_POINT!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_DIGITS) == MarketInfo(_Symbol, MODE_DIGITS),
                   "Invalid market value for MODE_DIGITS!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_SPREAD) == MarketInfo(_Symbol, MODE_SPREAD),
                   "Invalid market value for MODE_SPREAD!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_STOPLEVEL) == MarketInfo(_Symbol, MODE_STOPLEVEL),
                   "Invalid market value for MODE_STOPLEVEL!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_LOTSIZE) == MarketInfo(_Symbol, MODE_LOTSIZE),
                   "Invalid market value for MODE_LOTSIZE!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_TICKVALUE) == MarketInfo(_Symbol, MODE_TICKVALUE),
                   "Invalid market value for MODE_TICKVALUE!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_TICKSIZE) == MarketInfo(_Symbol, MODE_TICKSIZE),
                   "Invalid market value for MODE_TICKSIZE!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_SWAPLONG) == MarketInfo(_Symbol, MODE_SWAPLONG),
                   "Invalid market value for MODE_SWAPLONG!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_SWAPSHORT) == MarketInfo(_Symbol, MODE_SWAPSHORT),
                   "Invalid market value for MODE_SWAPSHORT!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_LOTSTEP) == MarketInfo(_Symbol, MODE_LOTSTEP),
                   "Invalid market value for MODE_LOTSTEP!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_MINLOT) == MarketInfo(_Symbol, MODE_MINLOT),
                   "Invalid market value for MODE_MINLOT!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_MAXLOT) == MarketInfo(_Symbol, MODE_MAXLOT),
                   "Invalid market value for MODE_MAXLOT!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_SWAPTYPE) == MarketInfo(_Symbol, MODE_SWAPTYPE),
                   "Invalid market value for MODE_SWAPTYPE!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_PROFITCALCMODE) == MarketInfo(_Symbol, MODE_PROFITCALCMODE),
                   "Invalid market value for SYMBOL_TRADE_CALC_MODE!");
  // @todo: MODE_STARTING
  // @todo: MODE_EXPIRATION
  // @fixme
  // assertTrueOrFail((bool)Market::MarketInfo(_Symbol, MODE_TRADEALLOWED), "Invalid market value for
  // MODE_TRADEALLOWED!"); MODE_MARGINCALCMODE
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_MARGININIT) == MarketInfo(_Symbol, MODE_MARGININIT),
                   "Invalid market value for MODE_MARGININIT!");
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_MARGINMAINTENANCE) == MarketInfo(_Symbol, MODE_MARGINMAINTENANCE),
                   "Invalid market value for MODE_MARGINMAINTENANCE!");
  // @todo: MODE_MARGINHEDGED
  // @todo: MODE_MARGINREQUIRED
  assertTrueOrFail(Market::MarketInfo(_Symbol, MODE_FREEZELEVEL) == MarketInfo(_Symbol, MODE_FREEZELEVEL),
                   "Invalid market value for MODE_FREEZELEVEL!");
#endif
  // Test delta and last price.
  assertTrueOrFail(market.GetDeltaValue() == Market::GetDeltaValue(_Symbol), "Invalid GetDeltaValue()!");
  assertTrueOrFail(market.GetLastPriceChangeInPips() == 0, "Invalid LastPriceChangeInPips()!");
  // Test normalization methods.
  // @todo: NormalizePrice()
  // @todo: NormalizeLots()
  // @todo: NormalizeSLTP()
  // Test state checking methods.
  assertTrueOrFail(Market::SymbolExists(_Symbol), "Invalid value for SymbolExists()!");
  // assertFalseOrFail(Market::SymbolExists("XXXYYY"), "Invalid value for SymbolExists()!"); // @fixme
  // Test other methods.
  // @todo: TradeOpAllowed()
  // Test printer methods.
  Print("MARKET: ", market.ToString());
  Print("CSV (header): ", market.ToCSV(true));
  Print("CSV (data): ", market.ToCSV());
  delete market;

  return (INIT_SUCCEEDED);
}

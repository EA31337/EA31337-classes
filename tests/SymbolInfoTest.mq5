//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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
 * Test functionality of SymbolInfo class.
 */

// Includes.
#include "../SymbolInfo.mqh"
#include "../Test.mqh"

/**
 * Implements OnInit().
 */
int OnInit() {
  SymbolInfo *si = new SymbolInfo();
  // Symbol test.
  assertTrueOrFail(si.GetSymbol() == _Symbol, "Invalid class symbol!");
  assertTrueOrFail(si.GetCurrentSymbol() == _Symbol, "Invalid current chart symbol!");
  // Tick test.
  // MqlTick stick = SymbolInfo::GetTick(); // @fixme: error 258: code generation error
  MqlTick dtick = si.GetTick();
  MqlTick ltick = si.GetLastTick();
  assertTrueOrFail(dtick.ask > 0 && dtick.ask == ltick.ask, "Invalid: Current Ask price");
  assertTrueOrFail(dtick.bid > 0 && dtick.bid == ltick.bid, "Invalid: Current Bid price");
  assertTrueOrFail(dtick.last == ltick.last, "Invalid: Price of the last deal (Last)");
  assertTrueOrFail(dtick.time > 0 && dtick.time == ltick.time, "Invalid: Time of the last prices update");
  assertTrueOrFail(dtick.volume == ltick.volume, "Invalid: Volume for the current Last price");
#ifdef __MQL5__
  // @see: https://www.mql5.com/en/docs/constants/structures/mqltick
  assertTrueOrFail(dtick.flags == ltick.flags, "Invalid: Tick flags");
  assertTrueOrFail(dtick.time_msc = ltick.time_msc, "Invalid: Time of a price last update in milliseconds");
  assertTrueOrFail(dtick.volume_real == ltick.volume_real,
                   "Invalid: Volume for the current Last price with greater accuracy");
#endif
  assertTrueOrFail(si.GetLastAsk() == ltick.ask, "Invalid: GetLastAsk()!");
  assertTrueOrFail(si.GetLastBid() == ltick.bid, "Invalid: GetLastBid()!");
  assertTrueOrFail(si.GetLastVolume() == ltick.volume, "Invalid: GetLastVolume()!");
  // Test prices.
  assertTrueOrFail(si.GetAsk() == SymbolInfo::GetAsk(_Symbol), "Invalid: GetAsk()!");
  assertTrueOrFail(si.GetBid() == SymbolInfo::GetBid(_Symbol), "Invalid: GetBid()!");
  assertTrueOrFail(si.GetVolume() == SymbolInfo::GetVolume(_Symbol), "Invalid: GetVolume()!");
  assertTrueOrFail(si.GetSessionVolume() == SymbolInfo::GetSessionVolume(_Symbol), "Invalid: GetSessionVolume()!");
  // Test Ask/Bid open prices.
  assertTrueOrFail(si.GetQuoteTime() > 0 && si.GetQuoteTime() == SymbolInfo::GetQuoteTime(_Symbol),
                   "Invalid: GetQuoteTime()!");
  assertTrueOrFail(si.GetCloseOffer(ORDER_TYPE_BUY) == dtick.bid &&
                       si.GetCloseOffer(ORDER_TYPE_BUY) == SymbolInfo::GetCloseOffer(_Symbol, ORDER_TYPE_BUY),
                   "Invalid: GetCloseOffer()!");
  assertTrueOrFail(si.GetCloseOffer(ORDER_TYPE_SELL) == dtick.ask &&
                       si.GetCloseOffer(ORDER_TYPE_SELL) == SymbolInfo::GetCloseOffer(_Symbol, ORDER_TYPE_SELL),
                   "Invalid: GetCloseOffer()!");
  assertTrueOrFail(si.GetOpenOffer(ORDER_TYPE_BUY) == dtick.ask &&
                       si.GetOpenOffer(ORDER_TYPE_BUY) == SymbolInfo::GetOpenOffer(_Symbol, ORDER_TYPE_BUY),
                   "Invalid: GetOpenOffer()!");
  assertTrueOrFail(si.GetOpenOffer(ORDER_TYPE_SELL) == dtick.bid &&
                       si.GetOpenOffer(ORDER_TYPE_SELL) == SymbolInfo::GetOpenOffer(_Symbol, ORDER_TYPE_SELL),
                   "Invalid: GetOpenOffer()!");
  // Test point, pip and tick sizes.
  assertTrueOrFail(si.GetPipSize() == SymbolInfo::GetPipSize(_Symbol), "Invalid: GetPipSize()!");
  assertTrueOrFail(si.GetPointSize() == SymbolInfo::GetPointSize(_Symbol), "Invalid: GetPointSize()!");
  assertTrueOrFail(si.GetTickSize() == SymbolInfo::GetTickSize(_Symbol), "Invalid: GetTickSize()!");
  assertTrueOrFail(si.GetTickValue() == SymbolInfo::GetTickValue(_Symbol), "Invalid: GetTickValue()!");
  assertTrueOrFail(si.GetTickValueLoss() == SymbolInfo::GetTickValueLoss(_Symbol), "Invalid: GetTickValueLoss()!");
  assertTrueOrFail(si.GetTickValueProfit() == SymbolInfo::GetTickValueProfit(_Symbol),
                   "Invalid: GetTickValueProfit()!");
  assertTrueOrFail(si.GetTradeTickSize() == SymbolInfo::GetTradeTickSize(_Symbol), "Invalid: GetTradeTickSize()!");
  // Test digits, spreads and trade stops.
  assertTrueOrFail(si.GetDigits() == SymbolInfo::GetDigits(_Symbol), "Invalid: GetDigits()!");
  assertTrueOrFail(si.GetRealSpread() == SymbolInfo::GetRealSpread(_Symbol), "Invalid: GetRealSpread()!");
  assertTrueOrFail(si.GetSpread() == SymbolInfo::GetSpread(_Symbol), "Invalid: GetSpread()!");
  assertTrueOrFail(si.GetTradeContractSize() == SymbolInfo::GetTradeContractSize(_Symbol),
                   "Invalid: GetTradeContractSize()!");
  assertTrueOrFail(si.GetTradeStopsLevel() == SymbolInfo::GetTradeStopsLevel(_Symbol),
                   "Invalid: GetTradeStopsLevel()!");
  // Test volumes.
  assertTrueOrFail(si.GetVolumeMax() == SymbolInfo::GetVolumeMax(_Symbol), "Invalid: GetVolumeMax()!");
  assertTrueOrFail(si.GetVolumeMin() == SymbolInfo::GetVolumeMin(_Symbol), "Invalid: GetVolumeMin()!");
  assertTrueOrFail(si.GetVolumeStep() == SymbolInfo::GetVolumeStep(_Symbol), "Invalid: GetVolumeStep()!");
  // Test freeze level.
  assertTrueOrFail(si.GetFreezeLevel() == SymbolInfo::GetFreezeLevel(_Symbol), "Invalid: GetFreezeLevel()!");
  // Test swap and margin values.
  assertTrueOrFail(si.GetSwapLong() == SymbolInfo::GetSwapLong(_Symbol), "Invalid: GetSwapLong()!");
  assertTrueOrFail(si.GetSwapShort() == SymbolInfo::GetSwapShort(_Symbol), "Invalid: GetSwapShort()!");
  assertTrueOrFail(si.GetMarginInit() == SymbolInfo::GetMarginInit(_Symbol), "Invalid: GetMarginInit()!");
  assertTrueOrFail(si.GetMarginMaintenance() == SymbolInfo::GetMarginMaintenance(_Symbol),
                   "Invalid: GetMarginMaintenance()!");
  // Test saving ticks.
  si.SaveTick(dtick);
  si.SaveTick(ltick);
  si.ResetTicks();
  // Test GetEntry().
  SymbolInfoEntry _entry = si.GetEntry();
  assertTrueOrFail(_entry.bid == dtick.bid, __FUNCTION_LINE__);
  assertTrueOrFail(_entry.ask == dtick.ask, __FUNCTION_LINE__);
  assertTrueOrFail(_entry.last == dtick.last, __FUNCTION_LINE__);
  assertTrueOrFail(_entry.spread == SymbolInfo::GetSpread(_Symbol), __FUNCTION_LINE__);
  assertTrueOrFail(_entry.volume == SymbolInfo::GetVolume(_Symbol), __FUNCTION_LINE__);
  // Print.
  Print("MARKET: ", si.ToString());
  Print("CSV (Header): ", si.ToCSV(true));
  Print("CSV (Data): ", si.ToCSV());
  delete si;

  return (INIT_SUCCEEDED);
}

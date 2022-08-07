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

// Prevents processing this includes file for the second time.
#ifndef SYMBOLINFO_MQH
#define SYMBOLINFO_MQH

// Includes symbol defines, enums and structs.
#include "SymbolInfo.define.h"
#include "SymbolInfo.enum.h"
#include "SymbolInfo.enum.symbols.h"
#include "SymbolInfo.extern.h"
#include "SymbolInfo.struct.h"
#include "SymbolInfo.struct.static.h"

// Forward declaration.
class Log;
class SymbolInfo;

// Includes.
#include "Log.mqh"
#include "Serializer.mqh"
#include "SerializerNode.enum.h"

/**
 * Class to provide symbol information.
 */
class SymbolInfo : public Object {
 protected:
  // Variables.
  string symbol;  // Current symbol pair.
  Log logger;
  MqlTick last_tick;           // Stores the latest prices of the symbol.
  ARRAY(MqlTick, tick_data);   // Stores saved ticks.
  SymbolInfoEntry s_entry;     // Symbol entry.
  SymbolInfoProp sprops;       // Symbol properties.
  double pip_size;             // Value of pip size.
  unsigned int symbol_digits;  // Count of digits after decimal point in the symbol price.
  // unsigned int pts_per_pip;          // Number of points per pip.
  double volume_precision;

 public:
  /**
   * Class constructor given a symbol string.
   */
  SymbolInfo(string _symbol = NULL) : symbol(_symbol), pip_size(GetPipSize()), symbol_digits(GetDigits()) {
    Select();
    last_tick = GetTick();
    // @todo: Test symbol with SymbolExists(_symbol)
    sprops.pip_digits = SymbolInfoStatic::GetPipDigits(_symbol);
    sprops.pip_value = SymbolInfoStatic::GetPipValue(_symbol);
    sprops.pts_per_pip = SymbolInfoStatic::GetPointsPerPip(_symbol);
    sprops.vol_digits = SymbolInfoStatic::GetVolumeDigits(_symbol);
    if (StringLen(symbol) == 0) {
      symbol = _Symbol;
    }
  }

  /**
   * Class constructor with symbol properties.
   */
  SymbolInfo(const SymbolInfoProp &_sip) : sprops(_sip) {}

  /**
   * Class copy constructor.
   */
  SymbolInfo(const SymbolInfo &_si) : s_entry(_si.s_entry), sprops(_si.sprops) {}

  ~SymbolInfo() {}

  /**
   * Selects current symbol in the Market Watch window.
   *
   * @docs
   * - https://docs.mql4.com/marketinformation/symbolselect
   * - https://www.mql5.com/en/docs/MarketInformation/SymbolSelect
   */
  bool Select() { return (bool)SymbolInfoInteger(symbol, SYMBOL_SELECT); }

  /* Getters */

  /**
   * Get current symbol pair used by the class.
   */
  string GetSymbol() { return symbol; }

  /**
   * Updates and gets the latest tick prices.
   *
   * @docs MQL4 https://docs.mql4.com/constants/structures/mqltick
   * @docs MQL5 https://www.mql5.com/en/docs/constants/structures/mqltick
   */
  MqlTick GetTick() {
    if (!SymbolInfoTick(symbol, last_tick)) {
      GetLogger().Error("Cannot return current prices!", __FUNCTION__);
    }
    return last_tick;
  }

  /**
   * Gets the last tick prices (without updating).
   */
  MqlTick GetLastTick() { return last_tick; }

  /**
   * The latest known seller's price (ask price) for the current symbol.
   * The RefreshRates() function must be used to update.
   *
   * @see http://docs.mql4.com/predefined/ask
   */
  double Ask() {
    return GetTick().ask;

    // @todo?
    // Overriding Ask variable to become a function call.
    // #ifdef __MQL5__ #define Ask Market::Ask() #endif // @fixme
  }

  /**
   * Updates and gets the latest ask price (best buy offer).
   */
  double GetAsk() { return SymbolInfoStatic::GetAsk(symbol); }

  /**
   * Gets the last ask price (without updating).
   */
  double GetLastAsk() { return last_tick.ask; }

  /**
   * The latest known buyer's price (offer price, bid price) of the current symbol.
   * The RefreshRates() function must be used to update.
   *
   * @see http://docs.mql4.com/predefined/bid
   */
  double Bid() {
    return GetTick().bid;

    // @todo?
    // Overriding Bid variable to become a function call.
    // #ifdef __MQL5__ #define Bid Market::Bid() #endif // @fixme
  }

  /**
   * Updates and gets the latest bid price (best sell offer).
   */
  double GetBid() { return SymbolInfoStatic::GetBid(symbol); }

  /**
   * Gets the last bid price (without updating).
   */
  double GetLastBid() { return last_tick.bid; }

  /**
   * Get the last volume for the current last price.
   *
   * @see: https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
   */
  unsigned long GetVolume() { return SymbolInfoStatic::GetTick(symbol).volume; }

  /**
   * Gets the last volume for the current price (without updating).
   */
  unsigned long GetLastVolume() { return last_tick.volume; }

  /**
   * Get summary volume of current session deals.
   *
   * @see: https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
   */
  double GetSessionVolume() { return SymbolInfoStatic::GetSessionVolume(symbol); }

  /**
   * Time of the last quote
   *
   * @docs
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#enum_symbol_info_double
   */
  datetime GetQuoteTime() { return SymbolInfoStatic::GetQuoteTime(symbol); }

  /**
   * Get current open price depending on the operation type.
   *
   * @param:
   *   op_type int Order operation type of the order.
   * @return
   *   Current open price.
   */
  double GetOpenOffer(ENUM_ORDER_TYPE _cmd) { return SymbolInfoStatic::GetOpenOffer(symbol, _cmd); }

  /**
   * Get current close price depending on the operation type.
   *
   * @param:
   *   op_type int Order operation type of the order.
   * @return
   * Current close price.
   */
  double GetCloseOffer(ENUM_ORDER_TYPE _cmd) { return SymbolInfoStatic::GetCloseOffer(symbol, _cmd); }

  /**
   * Get pip precision.
   */
  unsigned int GetPipDigits() { return sprops.pip_digits; }

  /**
   * Get pip value.
   */
  double GetPipValue() { return sprops.pip_value; }

  /**
   * Get number of points per pip.
   *
   */
  unsigned int GetPointsPerPip() { return sprops.pts_per_pip; }

  /**
   * Get the point size in the quote currency.
   *
   * The smallest digit of price quote.
   * A change of 1 in the least significant digit of the price.
   * You may also use Point predefined variable for the current symbol.
   */
  double GetPointSize() { return SymbolInfoStatic::GetPointSize(symbol); }

  /**
   * Return a pip size.
   *
   * In most cases, a pip is equal to 1/100 (.01%) of the quote currency.
   */
  double GetPipSize() { return SymbolInfoStatic::GetPipSize(symbol); }

  /**
   * Get current spread in points.
   *
   * @param
   *   symbol string (optional)
   *   Currency pair symbol.
   *
   * @return
   *   Return symbol trade spread level in points.
   */
  unsigned int GetSpreadInPts() { return GetSpread(); }

  /**
   * Get current spread in float.
   */
  double GetSpreadInPips() { return (GetAsk() - GetBid()) * pow(10, GetPipDigits()); }

  /**
   * Get current spread in percent.
   */
  double GetSpreadInPct() { return SymbolInfoStatic::GetSpreadInPct(symbol); }

  /**
   * Get a tick size in the price value.
   *
   * It is the smallest movement in the price quoted by the broker,
   * which could be several points.
   * In currencies it is equivalent to point size, in metals they are not.
   */
  float GetTickSize() { return (float)SymbolInfoStatic::GetTickSize(symbol); }

  /**
   * Get a tick size in points.
   *
   * It is a minimal price change in points.
   * In currencies it is equivalent to point size, in metals they are not.
   */
  double GetTradeTickSize() { return SymbolInfoStatic::GetTradeTickSize(symbol); }

  /**
   * Get a tick value in the deposit currency.
   *
   * @return
   * Returns the number of base currency units for one pip of movement.
   */
  double GetTickValue() { return SymbolInfoStatic::GetTickValue(symbol); }

  /**
   * Get a calculated tick price for a profitable position.
   *
   * @return
   * Returns the number of base currency units for one pip of movement.
   */
  double GetTickValueProfit() { return SymbolInfoStatic::GetTickValueProfit(symbol); }

  /**
   * Get a calculated tick price for a losing position.
   *
   * @return
   * Returns the number of base currency units for one pip of movement.
   */
  double GetTickValueLoss() { return SymbolInfoStatic::GetTickValueLoss(symbol); }

  /**
   * Get count of digits after decimal point for the symbol price.
   *
   * For the current symbol, it is stored in the predefined variable Digits.
   *
   */
  unsigned int GetDigits() { return SymbolInfoStatic::GetDigits(symbol); }

  /**
   * Get current spread in points.
   *
   * @param
   *   symbol string (optional)
   *   Currency pair symbol.
   *
   * @return
   *   Return symbol trade spread level in points.
   */
  unsigned int GetSpread() { return SymbolInfoStatic::GetSpread(symbol); }

  /**
   * Get real spread based on the ask and bid price (in points).
   */
  unsigned int GetRealSpread() { return SymbolInfoStatic::GetRealSpread(symbol); }

  /**
   * Minimal indention in points from the current close price to place Stop orders.
   *
   * This is due that at placing of a pending order, the open price cannot be too close to the market.
   * The minimal distance of the pending price from the current market one in points can be obtained
   * using the MarketInfo() function with the MODE_STOPLEVEL parameter.
   * Related error messages:
   *   Error 130 (ERR_INVALID_STOPS) happens In case of false open price of a pending order.
   *   Error 145 (ERR_TRADE_MODIFY_DENIED) happens when modification of order was too close to market.
   *
   * @param
   *   symbol string (optional)
   *   Currency pair symbol.
   *
   * @return
   *   Returns the minimal permissible distance value in points for StopLoss/TakeProfit.
   *   A zero value means either absence of any restrictions on the minimal distance.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  long GetTradeStopsLevel() { return SymbolInfoStatic::SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL); }

  /**
   * Get a contract lot size in the base currency.
   */
  double GetTradeContractSize() {
    return SymbolInfoStatic::SymbolInfoDouble(
        symbol,
        SYMBOL_TRADE_CONTRACT_SIZE);  // Same as: MarketInfo(symbol, MODE_LOTSIZE);
  }

  /**
   * Get a volume precision.
   */
  unsigned int GetVolumeDigits() { return sprops.vol_digits; }

  /**
   * Minimum permitted amount of a lot/volume for a deal.
   */
  double GetVolumeMin() { return SymbolInfoStatic::GetVolumeMin(symbol); }

  /**
   * Maximum permitted amount of a lot/volume for a deal.
   */
  double GetVolumeMax() { return SymbolInfoStatic::GetVolumeMax(symbol); }

  /**
   * Get a lot/volume step for a deal.
   *
   * Minimal volume change step for deal execution
   */
  double GetVolumeStep() { return SymbolInfoStatic::GetVolumeStep(symbol); }

  /**
   * Order freeze level in points.
   *
   * Freeze level is a value that determines the price band,
   * within which the order is considered as 'frozen' (prohibited to change).
   *
   * If the execution price lies within the range defined by the freeze level,
   * the order cannot be modified, cancelled or closed.
   * The possibility of deleting a pending order is regulated by the FreezeLevel.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  int GetFreezeLevel() { return SymbolInfoStatic::GetFreezeLevel(symbol); }

  /**
   * Gets flags of allowed order filling modes.
   *
   *  The flags can be combined by the operation of the logical OR (e.g. SYMBOL_FILLING_FOK|SYMBOL_FILLING_IOC).
   *
   * @docs
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#symbol_filling_mode
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   */
  ENUM_ORDER_TYPE_FILLING GetFillingMode() { return SymbolInfoStatic::GetFillingMode(symbol); }

  /**
   * Buy order swap value
   *
   * @docs
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
   */
  double GetSwapLong() { return SymbolInfoStatic::GetSwapLong(symbol); }

  /**
   * Sell order swap value
   *
   * @docs
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
   */
  double GetSwapShort() { return SymbolInfoStatic::GetSwapShort(symbol); }

  /**
   * Swap calculation model.
   *
   * @docs
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
   */
  ENUM_SYMBOL_SWAP_MODE GetSwapMode() { return SymbolInfoStatic::GetSwapMode(symbol); }

  /**
   * Returns initial margin (a security deposit) requirements for opening an order.
   *
   * @docs
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#enum_symbol_info_double
   */
  double GetMarginInit(ENUM_ORDER_TYPE _cmd = ORDER_TYPE_BUY) { return SymbolInfoStatic::GetMarginInit(symbol, _cmd); }

  /**
   * Return the maintenance margin to maintain open orders.
   *
   * @docs
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#enum_symbol_info_double
   */
  double GetMarginMaintenance(ENUM_ORDER_TYPE _cmd = ORDER_TYPE_BUY) {
    return SymbolInfoStatic::GetMarginMaintenance(symbol, _cmd);
  }

  /**
   * Gets symbol entry.
   */
  SymbolInfoEntry GetEntry(MqlTick &_tick) {
    SymbolInfoEntry _entry(_tick, symbol);
    return _entry;
  }
  SymbolInfoEntry GetEntry() {
    MqlTick _tick = GetTick();
    return GetEntry(_tick);
  }
  SymbolInfoEntry GetEntryLast() {
    MqlTick _tick = GetLastTick();
    return GetEntry(_tick);
  }

  /* Tick storage */

  /**
   * Appends a new tick to an array.
   */
  bool SaveTick(MqlTick &_tick) {
    static int _index = 0;
    if (_index++ >= ArraySize(tick_data) - 1) {
      if (ArrayResize(tick_data, _index + 100, 1000) < 0) {
        GetLogger().Error(StringFormat("Cannot resize array (size: %d)!", _index), __FUNCTION__);
        return false;
      }
    }
    tick_data[_index] = GetTick();
    return true;
  }

  /**
   * Empties the tick array.
   */
  bool ResetTicks() { return ArrayResize(tick_data, 0, 100) != -1; }

  /* Setters */

  /**
   * Overrides the last tick.
   */
  void SetTick(MqlTick &_tick) { last_tick = _tick; }

  /* Printer methods */

  /**
   * Returns symbol information in string format.
   */
  string ToString() override {
    return StringFormat(
        string("Symbol: %s, Last Ask/Bid: %g/%g, Last Price/Session Volume: %d/%g, Point size: %g, Pip size: %g, ") +
            "Tick size: %g (%g pts), Tick value: %g (%g/%g), " + "Digits: %d, Spread: %d pts, Trade stops level: %d, " +
            "Trade contract size: %g, Min lot: %g, Max lot: %g, Lot step: %g, " +
            "Freeze level: %d, Swap (long/short/mode): %g/%g/%d, Margin initial (maintenance): %g (%g)",
        GetSymbol(), GetLastAsk(), GetLastBid(), GetLastVolume(), GetSessionVolume(), GetPointSize(), GetPipSize(),
        GetTickSize(), GetTradeTickSize(), GetTickValue(), GetTickValueProfit(), GetTickValueLoss(), GetDigits(),
        GetSpread(), GetTradeStopsLevel(), GetTradeContractSize(), GetVolumeMin(), GetVolumeMax(), GetVolumeStep(),
        GetFreezeLevel(), GetSwapLong(), GetSwapShort(), GetSwapMode(), GetMarginInit(), GetMarginMaintenance());
  }

  /**
   * Returns symbol information in CSV format.
   */
  const string ToCSV(bool _header = false) {
    return !_header
               ? StringFormat(string("%s,%g,%g,%d,%g,%g,%g,") + "%g,%g,%g,%g,%g," + "%d,%d,%d," + "%g,%g,%g,%g," +
                                  "%d,%g,%g,%d,%g,%g",
                              GetSymbol(), GetLastAsk(), GetLastBid(), GetLastVolume(), GetSessionVolume(),
                              GetPointSize(), GetPipSize(), GetTickSize(), GetTradeTickSize(), GetTickValue(),
                              GetTickValueProfit(), GetTickValueLoss(), GetDigits(), GetSpread(), GetTradeStopsLevel(),
                              GetTradeContractSize(), GetVolumeMin(), GetVolumeMax(), GetVolumeStep(), GetFreezeLevel(),
                              GetSwapLong(), GetSwapShort(), GetSwapMode(), GetMarginInit(), GetMarginMaintenance())
               : string("Symbol,Last Ask,Last Bid,Last Volume,Session Volume,Point Size,Pip Size,") +
                     "Tick Size,Tick Size (pts),Tick Value,Tick Value Profit,Tick Value Loss," +
                     "Digits,Spread (pts),Trade Stops," + "Trade Contract Size,Min Lot,Max Lot,Lot Step," +
                     "Freeze level, Swap Long, Swap Short, Swap Mode, Margin Init";
  }

  /* Serializers */

  /**
   * Returns serialized representation of the object instance.
   */
  const SerializerNodeType Serialize(Serializer &_s) {
    _s.Pass(THIS_REF, "symbol", symbol);
    _s.PassStruct(THIS_REF, "symbol-entry", s_entry);
    return SerializerNodeObject;
  }

  /* Class handlers */

  /**
   * Returns Log handler.
   */
  Log *GetLogger() { return GetPointer(logger); }
};
#endif  // SYMBOLINFO_MQH

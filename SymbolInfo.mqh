//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2018, 31337 Investments Ltd |
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

// Prevents processing this includes file for the second time.
#ifndef SYMBOLINFO_MQH
#define SYMBOLINFO_MQH

// Forward declaration.
class SymbolInfo;
class Terminal;

// Includes.
#include "Terminal.mqh"

#ifdef __MQL4__
// Methods of swap calculation at position transfer.
// @see: https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#enum_symbol_swap_mode
enum ENUM_SYMBOL_SWAP_MODE {
  // Swaps disabled (no swaps).
  SYMBOL_SWAP_MODE_DISABLED = -1,
  // Swaps are charged in points.
  SYMBOL_SWAP_MODE_POINTS = 0,
  // Swaps are charged in money in base currency of the symbol.
  SYMBOL_SWAP_MODE_CURRENCY_SYMBOL = 1,
  // Swaps are charged as the specified annual interest from the instrument price at calculation of swap (standard bank year is 360 days).
  SYMBOL_SWAP_MODE_INTEREST_CURRENT = 2,
  // Swaps are charged in money in margin currency of the symbol.
  SYMBOL_SWAP_MODE_CURRENCY_MARGIN = 3,
  // Swaps are charged in money, in client deposit currency.
  SYMBOL_SWAP_MODE_CURRENCY_DEPOSIT,
  // Swaps are charged as the specified annual interest from the open price of position (standard bank year is 360 days).
  SYMBOL_SWAP_MODE_INTEREST_OPEN,
  // Swaps are charged by reopening positions. At the end of a trading day the position is closed. Next day it is reopened by the close price +/- specified number of points (parameters SYMBOL_SWAP_LONG and SYMBOL_SWAP_SHORT).
  SYMBOL_SWAP_MODE_REOPEN_CURRENT,
  // Swaps are charged by reopening positions. At the end of a trading day the position is closed. Next day it is reopened by the current Bid price +/- specified number of points (parameters SYMBOL_SWAP_LONG and SYMBOL_SWAP_SHORT).
  SYMBOL_SWAP_MODE_REOPEN_BID
};
#endif

/**
 * Class to provide symbol information.
 */
class SymbolInfo : public Terminal {

  protected:

    // Variables.
    string symbol;             // Current symbol pair.
    MqlTick last_tick;         // Stores the latest prices of the symbol.
    MqlTick tick_data[];       // Stores saved ticks.
    double pip_size;           // Value of pip size.
    uint symbol_digits;        // Count of digits after decimal point in the symbol price.
    //uint pts_per_pip;          // Number of points per pip.
    double volume_precision;

  public:

    /**
     * Implements class constructor with a parameter.
     */
    SymbolInfo(string _symbol = NULL, Log *_log = NULL) :
      symbol(_symbol == NULL ? _Symbol : _symbol),
      pip_size(GetPipSize()),
      symbol_digits(GetDigits()),
      Terminal(_log)
      {
        this.last_tick = GetTick();
      }

    ~SymbolInfo() {
    }

    /* Getters */

    /**
     * Get the current symbol pair from the current chart.
     */
    static string GetCurrentSymbol() {
      return _Symbol;
    }

    /**
     * Get current symbol pair used by the class.
     */
    string GetSymbol() {
      return this.symbol;
    }

    /**
     * Updates and gets the latest tick prices.
     *
     * @docs MQL4 https://docs.mql4.com/constants/structures/mqltick
     * @docs MQL5 https://www.mql5.com/en/docs/constants/structures/mqltick
     */
    static MqlTick GetTick(string _symbol) {
      MqlTick _last_tick;
      if (!SymbolInfoTick(_symbol, _last_tick)) {
        PrintFormat("Error: %s(): %s", __FUNCTION__, "Cannot return current prices!");
      }
      return _last_tick;
    }
    MqlTick GetTick() {
      if (!SymbolInfoTick(this.symbol, this.last_tick)) {
        Logger().Error("Cannot return current prices!", __FUNCTION__);
      }
      return this.last_tick;
    }

    /**
     * Gets the last tick prices (without updating).
     */
    MqlTick GetLastTick() {
      return this.last_tick;
    }

    /**
     * The latest known seller's price (ask price) for the current symbol.
     * The RefreshRates() function must be used to update.
     *
     * @see http://docs.mql4.com/predefined/ask
     */
    double Ask() {
      return this.GetTick().ask;

      // @todo?
      // Overriding Ask variable to become a function call.
      // #ifdef __MQL5__ #define Ask Market::Ask() #endif // @fixme 
    }

    /**
     * Updates and gets the latest ask price (best buy offer).
     */
    static double GetAsk(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_ASK);
    }
    double GetAsk() {
      return this.GetAsk(symbol);
    }

    /**
     * Gets the last ask price (without updating).
     */
    double GetLastAsk() {
      return this.last_tick.ask;
    }

    /**
     * The latest known buyer's price (offer price, bid price) of the current symbol.
     * The RefreshRates() function must be used to update.
     *
     * @see http://docs.mql4.com/predefined/bid
     */
    double Bid() {
      return this.GetTick().bid;

      // @todo?
      // Overriding Bid variable to become a function call.
      // #ifdef __MQL5__ #define Bid Market::Bid() #endif // @fixme
    }

    /**
     * Updates and gets the latest bid price (best sell offer).
     */
    static double GetBid(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_BID);
    }
    double GetBid() {
      return this.GetBid(symbol);
    }

    /**
     * Gets the last bid price (without updating).
     */
    double GetLastBid() {
      return this.last_tick.bid;
    }

    /**
     * Get the last volume for the current last price.
     *
     * @see: https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
     */
    static ulong GetVolume(string _symbol) {
      return GetTick(_symbol).volume;
    }
    ulong GetVolume() {
      return this.GetTick(this.symbol).volume;
    }

    /**
     * Gets the last volume for the current price (without updating).
     */
    ulong GetLastVolume() {
      return this.last_tick.volume;
    }

    /**
     * Get summary volume of current session deals.
     *
     * @see: https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
     */
    static double GetSessionVolume(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_SESSION_VOLUME);
    }
    double GetSessionVolume() {
      return this.GetSessionVolume(this.symbol);
    }

    /**
     * Time of the last quote
     *
     * @docs
     * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
     * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#enum_symbol_info_double
     */
    static datetime GetQuoteTime(string _symbol) {
      return (datetime) SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_TIME);
    }
    datetime GetQuoteTime() {
      return GetQuoteTime(this.symbol);
    }

    /**
     * Get current open price depending on the operation type.
     *
     * @param:
     *   op_type int Order operation type of the order.
     * @return
     *   Current open price.
     */
    static double GetOpenOffer(string _symbol, ENUM_ORDER_TYPE _cmd = NULL) {
      if (_cmd == NULL) _cmd = (ENUM_ORDER_TYPE) OrderGetInteger(ORDER_TYPE); // Same as: OrderType();
      // Use the right open price at opening of a market order. For example:
      // When selling, only the latest Bid prices can be used.
      // When buying, only the latest Ask prices can be used.
      return _cmd == ORDER_TYPE_BUY ? GetAsk(_symbol) : GetBid(_symbol);
    }
    double GetOpenOffer(ENUM_ORDER_TYPE _cmd) {
      return GetOpenOffer(symbol, _cmd);
    }

    /**
     * Get current close price depending on the operation type.
     *
     * @param:
     *   op_type int Order operation type of the order.
     * @return
     * Current close price.
     */
    static double GetCloseOffer(string _symbol, ENUM_ORDER_TYPE _cmd = NULL) {
      if (_cmd == NULL) _cmd = (ENUM_ORDER_TYPE) OrderGetInteger(ORDER_TYPE); // Same as: OrderType();
      return _cmd == ORDER_TYPE_BUY ? GetBid(_symbol) : GetAsk(_symbol);
    }
    double GetCloseOffer(ENUM_ORDER_TYPE _cmd = NULL) {
      return GetCloseOffer(symbol, _cmd);
    }

    /**
     * Get the point size in the quote currency.
     *
     * The smallest digit of price quote.
     * A change of 1 in the least significant digit of the price.
     * You may also use Point predefined variable for the current symbol.
     */
    double GetPointSize() {
      return SymbolInfo::SymbolInfoDouble(symbol, SYMBOL_POINT); // Same as: MarketInfo(symbol, MODE_POINT);
    }
    static double GetPointSize(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_POINT); // Same as: MarketInfo(symbol, MODE_POINT);
    }

    /**
     * Return a pip size.
     *
     * In most cases, a pip is equal to 1/100 (.01%) of the quote currency.
     */
    static double GetPipSize(string _symbol) {
      // @todo: This code may fail at Gold and Silver (https://www.mql5.com/en/forum/135345#515262).
      return GetDigits(_symbol) % 2 == 0 ? GetPointSize(_symbol) : GetPointSize(_symbol) * 10;
    }
    double GetPipSize() {
      return GetPipSize(symbol);
    }

    /**
     * Get a tick size in the price value.
     *
     * It is the smallest movement in the price quoted by the broker,
     * which could be several points.
     * In currencies it is equivalent to point size, in metals they are not.
     */
    static double GetTickSize(string _symbol) {
      // Note: In currencies a tick is always a point, but not for other markets.
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_SIZE);
    }
    double GetTickSize() {
      return GetTickSize(symbol);
    }

    /**
     * Get a tick size in points.
     *
     * It is a minimal price change in points.
     * In currencies it is equivalent to point size, in metals they are not.
     */
    static double GetTradeTickSize(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_SIZE);
    }
    double GetTradeTickSize() {
      return GetTradeTickSize(symbol);
    }

    /**
     * Get a tick value in the deposit currency.
     *
     * @return
     * Returns the number of base currency units for one pip of movement.
     */
    static double GetTickValue(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_VALUE); // Same as: MarketInfo(symbol, MODE_TICKVALUE);
    }
    double GetTickValue() {
      return GetTickValue(symbol);
    }

    /**
     * Get a calculated tick price for a profitable position.
     *
     * @return
     * Returns the number of base currency units for one pip of movement.
     */
    static double GetTickValueProfit(string _symbol) {
      // Not supported in MQL4.
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT); // Same as: MarketInfo(symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT);
    }
    double GetTickValueProfit() {
      return GetTickValueProfit(symbol);
    }

    /**
     * Get a calculated tick price for a losing position.
     *
     * @return
     * Returns the number of base currency units for one pip of movement.
     */
    static double GetTickValueLoss(string _symbol) {
      // Not supported in MQL4.
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_VALUE_LOSS); // Same as: MarketInfo(symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
    }
    double GetTickValueLoss() {
      return GetTickValueLoss(symbol);
    }

    /**
     * Get count of digits after decimal point for the symbol price.
     *
     * For the current symbol, it is stored in the predefined variable Digits.
     *
     */
    static uint GetDigits(string _symbol) {
      return (uint) SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_DIGITS); // Same as: MarketInfo(symbol, MODE_DIGITS);
    }
    uint GetDigits() {
      return GetDigits(symbol);
    }

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
    static uint GetSpread(string _symbol) {
      return (uint) SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_SPREAD);
    }
    uint GetSpread() {
      return GetSpread(symbol);
    }

    /**
     * Get real spread based on the ask and bid price (in points).
     */
    static uint GetRealSpread(string _symbol) {
      return (uint) round((GetAsk(_symbol) - GetBid(_symbol)) * pow(10, GetDigits(_symbol)));
    }
    uint GetRealSpread() {
      return GetRealSpread(symbol);
    }

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
    long GetTradeStopsLevel() {
      return SymbolInfo::SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
    }
    static long GetTradeStopsLevel(string _symbol) {
      return SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_TRADE_STOPS_LEVEL);
    }

    /**
     * Get a contract lot size in the base currency.
     */
    double GetTradeContractSize() {
      return SymbolInfo::SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE); // Same as: MarketInfo(symbol, MODE_LOTSIZE);
    }
    static double GetTradeContractSize(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE); // Same as: MarketInfo(symbol, MODE_LOTSIZE);
    }

    /**
     * Minimum permitted amount of a lot/volume for a deal.
     */
    static double GetVolumeMin(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); // Same as: MarketInfo(symbol, MODE_MINLOT);
    }
    double GetVolumeMin() {
      return GetVolumeMin(symbol);
    }

    /**
     * Maximum permitted amount of a lot/volume for a deal.
     */
    static double GetVolumeMax(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX); // Same as: MarketInfo(symbol, MODE_MAXLOT);
    }
    double GetVolumeMax() {
      return GetVolumeMax(symbol);
    }

    /**
     * Get a lot/volume step for a deal.
     *
     * Minimal volume change step for deal execution
     */
    static double GetVolumeStep(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP); // Same as: MarketInfo(symbol, MODE_LOTSTEP);
    }
    double GetVolumeStep() {
      return GetVolumeStep(symbol);
    }

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
    static uint GetFreezeLevel(string _symbol) {
      return (uint) SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_TRADE_FREEZE_LEVEL); // Same as: MarketInfo(symbol, MODE_FREEZELEVEL);
    }
    uint GetFreezeLevel() {
      return GetFreezeLevel(symbol);
    }

    /**
     * Get allowed order filling modes.
     *
     *
     * @docs
     * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#symbol_filling_mode
     * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
     */
    static ENUM_ORDER_TYPE_FILLING GetFillingMode(string _symbol) {
      // Note: Not supported for MQL4.
      return (ENUM_ORDER_TYPE_FILLING) SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_FILLING_MODE);
    }
    ENUM_ORDER_TYPE_FILLING GetFillingMode() {
      return GetFillingMode(symbol);
    }

    /**
     * Buy order swap value
     *
     * @docs
     * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
     * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
     */
    static double GetSwapLong(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_SWAP_LONG);
    }
    double GetSwapLong() {
      return GetSwapLong(symbol);
    }

    /**
     * Sell order swap value
     *
     * @docs
     * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
     * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
     */
    static double GetSwapShort(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_SWAP_SHORT);
    }
    double GetSwapShort() {
      return GetSwapShort(symbol);
    }

    /**
     * Swap calculation model.
     *
     * @docs
     * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
     * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
     */
    static ENUM_SYMBOL_SWAP_MODE GetSwapMode(string _symbol) {
      return (ENUM_SYMBOL_SWAP_MODE) SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_SWAP_MODE);
    }
    ENUM_SYMBOL_SWAP_MODE GetSwapMode() {
      return GetSwapMode(symbol);
    }

    /**
     * Initial margin (a security deposit) requirements for 1 lot.
     *
     * Initial margin means the amount in the margin currency required for opening a position with the volume of one lot.
     * It is used for checking a client's assets when he or she enters the market.
     *
     * @docs
     * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
     * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#enum_symbol_info_double
     */
    static double GetMarginInit(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_MARGIN_INITIAL); // Same as: MarketInfo(symbol, MODE_MARGININIT);
    }
    double GetMarginInit() {
      return GetMarginInit(symbol);
    }

    /**
     * Margin to maintain open orders calculated for 1 lot
     *
     * If it is set, it sets the margin amount in the margin currency of the symbol, charged from one lot.
     * It is used for checking a client's assets when his/her account state changes.
     * If the maintenance margin is equal to 0, the initial margin is used.
     *
     * @docs
     * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
     * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#enum_symbol_info_double
     */
    static double GetMarginMaintenance(string _symbol) {
      return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_MARGIN_MAINTENANCE); // Same as: MarketInfo(symbol, SYMBOL_MARGIN_MAINTENANCE);
    }
    double GetMarginMaintenance() {
      return GetMarginMaintenance(symbol);
    }

    /* Tick storage */

    /**
     * Appends a new tick to an array.
     */
    bool SaveTick(MqlTick &_tick) {
      static int _index = 0;
      if (_index++ >= ArraySize(this.tick_data) - 1) {
        if (ArrayResize(this.tick_data, _index + 100, 1000) < 0) {
          logger.Error(StringFormat("Cannot resize array (size: %d)!", _index), __FUNCTION__);
          return false;
        }
      }
      this.tick_data[_index] = this.GetTick();
      return true;
    }

    /**
     * Empties the tick array.
     */
    bool ResetTicks() {
      return ArrayResize(this.tick_data, 0, 100) != -1;
    }

    /* Setters */

    /**
     * Overrides the last tick.
     */
    void SetTick(MqlTick &_tick) {
      this.last_tick = _tick;
    }

    /**
     * Returns the value of a corresponding property of the symbol.
     *
     * @param string name
     *   Symbol name.
     * @param ENUM_SYMBOL_INFO_DOUBLE prop_id
     *   Identifier of a property.
     *
     * @return double
     *   Returns the value of the property.
     *   In case of error, information can be obtained using GetLastError() function.
     *
     * @docs
     * - https://docs.mql4.com/marketinformation/symbolinfodouble
     * - https://www.mql5.com/en/docs/marketinformation/symbolinfodouble
     *
     */
    static double SymbolInfoDouble(string name, ENUM_SYMBOL_INFO_DOUBLE prop_id) {
#ifdef __MQLBUILD__
      return ::SymbolInfoDouble(name, prop_id);
#else
    printf("@fixme: %s\n", "Symbol::SymbolInfoDouble()");
    return 0;
#endif
    }

    /**
     * Returns the value of a corresponding property of the symbol.
     *
     * @param string name
     *   Symbol name.
     * @param ENUM_SYMBOL_INFO_INTEGER prop_id
     *   Identifier of a property.
     *
     * @return long
     *   Returns the value of the property.
     *   In case of error, information can be obtained using GetLastError() function.
     *
     * @docs
     * - https://docs.mql4.com/marketinformation/symbolinfointeger
     * - https://www.mql5.com/en/docs/marketinformation/symbolinfointeger
     *
     */
    static long SymbolInfoInteger(string name, ENUM_SYMBOL_INFO_INTEGER prop_id) {
#ifdef __MQLBUILD__
      return ::SymbolInfoInteger(name, prop_id);
#else
    printf("@fixme: %s\n", "SymbolInfo::SymbolInfoInteger()");
    return 0;
#endif
    }

    /**
     * Returns the value of a corresponding property of the symbol.
     *
     * @param string name
     *   Symbol name.
     * @param ENUM_SYMBOL_INFO_STRING prop_id
     *   Identifier of a property.
     *
     * @return string
     *   Returns the value of the property.
     *   In case of error, information can be obtained using GetLastError() function.
     *
     * @docs
     * - https://docs.mql4.com/marketinformation/symbolinfostring
     * - https://www.mql5.com/en/docs/marketinformation/symbolinfostring
     *
     */
    static string SymbolInfoString(string name, ENUM_SYMBOL_INFO_STRING prop_id) {
#ifdef __MQLBUILD__
      return ::SymbolInfoString(name, prop_id);
#else
    printf("@fixme: %s\n", "SymbolInfo::SymbolInfoString()");
    return 0;
#endif
    }

    /* Printer methods */

    /**
     * Returns symbol information in string format.
     */
    string ToString() {
      return StringFormat(
       "Symbol: %s, Last Ask/Bid: %g/%g, Last Price/Session Volume: %d/%g, Point size: %g, Pip size: %g, " +
       "Tick size: %g (%g pts), Tick value: %g (%g/%g), " +
       "Digits: %d, Spread: %d pts, Trade stops level: %d, " +
       "Trade contract size: %g, Min lot: %g, Max lot: %g, Lot step: %g, " +
       "Freeze level: %d, Swap (long/short/mode): %g/%g/%d, Margin initial (maintenance): %g (%g)",
       GetSymbol(), GetLastAsk(), GetLastBid(), GetLastVolume(), GetSessionVolume(), GetPointSize(), GetPipSize(),
       GetTickSize(), GetTradeTickSize(), GetTickValue(), GetTickValueProfit(), GetTickValueLoss(),
       GetDigits(), GetSpread(), GetTradeStopsLevel(),
       GetTradeContractSize(), GetVolumeMin(), GetVolumeMax(), GetVolumeStep(),
       GetFreezeLevel(), GetSwapLong(), GetSwapShort(), GetSwapMode(), GetMarginInit(), GetMarginMaintenance()
      );
    }

    /**
     * Returns symbol information in CSV format.
     */
    string ToCSV(bool _header = false) {
      return
        !_header ? StringFormat(
          "%s,%g,%g,%d,%g,%g,%g," +
          "%g,%g,%g,%g,%g," +
          "%d,%d,%d," +
          "%g,%g,%g,%g," +
          "%d,%g,%g,%d,%g,%g",
          GetSymbol(), GetLastAsk(), GetLastBid(), GetLastVolume(), GetSessionVolume(), GetPointSize(), GetPipSize(),
          GetTickSize(), GetTradeTickSize(), GetTickValue(), GetTickValueProfit(), GetTickValueLoss(),
          GetDigits(), GetSpread(), GetTradeStopsLevel(),
          GetTradeContractSize(), GetVolumeMin(), GetVolumeMax(), GetVolumeStep(),
          GetFreezeLevel(), GetSwapLong(), GetSwapShort(), GetSwapMode(), GetMarginInit(), GetMarginMaintenance()
          )
        :
          "Symbol,Last Ask,Last Bid,Last Volume,Session Volume,Point Size,Pip Size," +
          "Tick Size,Tick Size (pts),Tick Value,Tick Value Profit,Tick Value Loss," +
          "Digits,Spread (pts),Trade Stops," +
          "Trade Contract Size,Min Lot,Max Lot,Lot Step," +
          "Freeze level, Swap Long, Swap Short, Swap Mode, Margin Init";
    }

};
#endif // SYMBOLINFO_MQH

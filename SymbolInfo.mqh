//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
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

// Properties.
#property strict

// Forward declaration.
class SymbolInfo;
class Terminal;

// Includes.
#include "Terminal.mqh"

/**
 * Class to provide symbol information.
 */
class SymbolInfo : public Terminal {

  protected:

    // Variables.
    string symbol;             // Current symbol pair.
    double last_ask, last_bid; // Last Ask/Bid prices.
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
      //pts_per_pip(GetPointsPerPip()),
      last_ask(GetAsk()),
      last_bid(GetBid()),
      Terminal(_log)
      {
      }

    ~SymbolInfo() {
    }

    /* Getters */

    /**
     * Get current symbol pair used by the class.
     */
    string GetSymbol() {
      return symbol;
    }

    /**
     * Get the symbol pair from the current chart.
     */
    string GetChartSymbol() {
      return _Symbol;
    }

    /**
     * Get ask price (best buy offer).
     */
    static double GetAsk(string _symbol) {
      return SymbolInfoDouble(_symbol, SYMBOL_ASK);
    }
    double GetAsk() {
      return last_ask = GetAsk(symbol);
    }

    /**
     * Get last ask price (best buy offer).
     */
    double GetLastAsk() {
      return last_ask;
    }

    /**
     * Get bid price (best sell offer).
     */
    static double GetBid(string _symbol) {
      return SymbolInfoDouble(_symbol, SYMBOL_BID);
    }
    double GetBid() {
      return last_bid = GetBid(symbol);
    }

    /**
     * Get last bid price (best sell offer).
     */
    double GetLastBid() {
      return last_bid;
    }
    /**
     * Get summary volume of current session deals.
     *
     * @see: https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
     */
    static double GetSessionVolume(string _symbol) {
      return SymbolInfoDouble(_symbol, SYMBOL_SESSION_VOLUME);
    }
    double GetSessionVolume() {
      return GetSessionVolume(symbol);
    }


    /**
     * The latest known seller's price (ask price) for the current symbol.
     * The RefreshRates() function must be used to update.
     *
     * @see http://docs.mql4.com/predefined/ask
     */
    double Ask() {
      MqlTick last_tick;
      SymbolInfoTick(symbol,last_tick);
      return last_tick.ask;

      // Overriding Ask variable to become a function call.
      // #ifdef __MQL5__ #define Ask Market::Ask() #endif // @fixme 
    }

    /**
     * The latest known buyer's price (offer price, bid price) of the current symbol.
     * The RefreshRates() function must be used to update.
     *
     * @see http://docs.mql4.com/predefined/bid
     */
    double Bid() {
      MqlTick last_tick;
      SymbolInfoTick(symbol, last_tick);
      return last_tick.bid;

      // Overriding Bid variable to become a function call.
      // #ifdef __MQL5__ #define Bid Market::Bid() #endif // @fixme

    }

    /**
     * Get the point size in the quote currency.
     *
     * The smallest digit of price quote.
     * A change of 1 in the least significant digit of the price.
     * You may also use Point predefined variable for the current symbol.
     */
    double GetPointSize() {
      return SymbolInfoDouble(symbol, SYMBOL_POINT); // Same as: MarketInfo(symbol, MODE_POINT);
    }
    static double GetPointSize(string _symbol) {
      return SymbolInfoDouble(_symbol, SYMBOL_POINT); // Same as: MarketInfo(symbol, MODE_POINT);
    }

    /**
     * Return a pip size.
     *
     * In most cases, a pip is equal to 1/100 (.01%) of the quote currency.
     */
    double GetPipSize() {
      // @todo: This code may fail at Gold and Silver (https://www.mql5.com/en/forum/135345#515262).
      return GetDigits() % 2 == 0 ? GetPointSize() : GetPointSize() * 10;
    }

    /**
     * Get a tick size in the price value.
     *
     * It is the smallest movement in the price quoted by the broker,
     * which could be several points.
     * In currencies it is equivalent to point size, in metals they are not.
     */
    double GetTickSize() {
      // Note: In currencies a tick is always a point, but not for other markets.
      return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    }
    static double GetTickSize(string _symbol) {
      return SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_SIZE);
    }

    /**
     * Get a tick size in points.
     *
     * It is a minimal price change in points.
     * In currencies it is equivalent to point size, in metals they are not.
     */
    double GetTradeTickSize() {
      return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
    }

    /**
     * Get a tick value in the deposit currency.
     *
     * @return
     * Returns the number of base currency units for one pip of movement.
     */
    static double GetTickValue(string _symbol) {
      return SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_VALUE); // Same as: MarketInfo(symbol, MODE_TICKVALUE);
    }
    double GetTickValue() {
      double _value = GetTickValue(symbol);
      _value = _value > 0 ? _value : GetTickValueProfit(symbol);
      return _value > 0 ? _value : 1;
    }

    /**
     * Get a calculated tick price for a profitable position.
     *
     * @return
     * Returns the number of base currency units for one pip of movement.
     */
    static double GetTickValueProfit(string _symbol) {
      // Not supported in MQL4.
      return SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT); // Same as: MarketInfo(symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT);
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
      return SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_VALUE_LOSS); // Same as: MarketInfo(symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
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
      return (uint) SymbolInfoInteger(_symbol, SYMBOL_DIGITS); // Same as: MarketInfo(symbol, MODE_DIGITS);
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
      return (uint) SymbolInfoInteger(_symbol, SYMBOL_SPREAD);
    }
    uint GetSpread() {
      return GetSpread(symbol);
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
      return SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
    }
    static long GetTradeStopsLevel(string _symbol) {
      return SymbolInfoInteger(_symbol, SYMBOL_TRADE_STOPS_LEVEL);
    }

    /**
     * Get a lot/volume step.
     */
    double GetLotStepInPts() {
      // @todo: Correct bit shifting.
      return SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP); // Same as: MarketInfo(symbol, MODE_LOTSTEP);
    }
    static double GetLotStepInPts(string _symbol) {
      // @todo: Correct bit shifting.
      return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP); // Same as: MarketInfo(symbol, MODE_LOTSTEP);
    }

    /**
     * Get a contract lot size in the base currency.
     */
    double GetTradeContractSize() {
      return SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE); // Same as: MarketInfo(symbol, MODE_LOTSIZE);
    }
    static double GetTradeContractSize(string _symbol) {
      return SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE); // Same as: MarketInfo(symbol, MODE_LOTSIZE);
    }

    /**
     * Minimum permitted amount of a lot/volume.
     */
    static double GetMinLot(string _symbol) {
      return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); // Same as: MarketInfo(symbol, MODE_MINLOT);
    }
    double GetMinLot() {
      return GetMinLot(symbol);
    }

    /**
     * Maximum permitted amount of a lot/volume.
     */
    double GetMaxLot() {
      return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX); // Same as: MarketInfo(symbol, MODE_MAXLOT);
    }
    static double GetMaxLot(string _symbol) {
      return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX); // Same as: MarketInfo(symbol, MODE_MAXLOT);
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
    uint GetFreezeLevel() {
      return (uint) SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL); // Same as: MarketInfo(symbol, MODE_FREEZELEVEL);
    }
    static uint GetFreezeLevel(string _symbol) {
      return (uint) SymbolInfoInteger(_symbol, SYMBOL_TRADE_FREEZE_LEVEL); // Same as: MarketInfo(symbol, MODE_FREEZELEVEL);
    }

    /**
     * Initial margin requirements for 1 lot.
     */
    double GetMarginInit() {
      return SymbolInfoDouble(symbol, SYMBOL_MARGIN_INITIAL); // Same as: MarketInfo(symbol, MODE_MARGININIT);
    }

    /**
     * Returns symbol information.
     */
   string ToString() {
     return StringFormat(
       "Symbol: %s, Ask/Bid: %g/%g, Session Volume: %g, Point size: %g, Pip size: %g, " +
       "Tick size: %g (%g pts), Tick value: %g (%g/%g), " +
       "Digits: %d, Spread: %d pts, Trade stops level: %d, " +
       "Lot step: %g pts, Trade contract size: %g, Min lot: %g, Max lot: %g, Freeze level: %d, Margin init: %g",
       GetSymbol(), GetAsk(), GetBid(), GetSessionVolume(), GetPointSize(), GetPipSize(),
       GetTickSize(), GetTradeTickSize(), GetTickValue(), GetTickValueProfit(), GetTickValueLoss(),
       GetDigits(), GetSpread(), GetTradeStopsLevel(),
       GetLotStepInPts(), GetTradeContractSize(), GetMinLot(), GetMaxLot(), GetFreezeLevel(), GetMarginInit()
     );
   }

};

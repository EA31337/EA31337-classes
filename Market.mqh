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

// Properties.
#property strict

/*
 * Class to provide market information.
 */
class Market {
public:

    double pip_size; // Value of pip size.
    int pip_digits;  // Number of digits for a pip.
    int pts_per_pip; // Number of points per pip.
    double volume_precision;

    /**
     * Implements class constructor with a parameter.
     */
    Market(string symbol) {
      pip_size = GetPipSize();
      pip_digits = GetPipDigits();
      pts_per_pip = GetPointsPerPip();
    }

    /**
     * Get ask price.
     */
    static double GetAsk(string symbol = NULL) {
      return symbol ? MarketInfo(symbol, MODE_ASK) : Ask;
    }

    /**
     * Get bid price.
     */
    static double GetBid(string symbol = NULL) {
      return symbol ? MarketInfo(symbol, MODE_BID) : Bid;
    }

    /**
     * Get point size in the quote currency.
     *
     * Use Point predefined variable for the current symbol.
     */
    static double GetPoint(string symbol = NULL) {
      return symbol ? MarketInfo(symbol, MODE_POINT) : Point;
    }

    /**
     * Return pip size.
     */
    static double GetPipSize(string symbol = NULL) {
      int digits = (int) MarketInfo(symbol, MODE_DIGITS);
      switch (digits) {
        case 0:
        case 1:
          return 1.0;
        case 2:
        case 3:
          return 0.01;
        case 4:
        case 5:
        default:
          return 0.0001;
      }
    }

    /**
     * Get count of digits after decimal point in the symbol price.
     *
     * @param
     *   symbol string
     *   Currency pair symbol.
     *
     */
    static int GetDigits(string symbol) {
      return (int) MarketInfo(symbol, MODE_DIGITS);
    }

    /**
     * Get count of digits after decimal point in the symbol price.
     */
    static int GetDigits() {
      return Digits;
    }

    /**
     * Get pip precision.
     */
    static int GetPipDigits(string symbol = NULL) {
      return (GetDigits(symbol) < 4 ? 2 : 4);
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
    static long GetSpreadInPts(string symbol = NULL) {
      return SymbolInfoInteger(symbol, SYMBOL_SPREAD);
    }

    /**
     * Get current spread in float.
     */
    static double GetSpreadInPips() {
      return pow(10 * GetPipDigits(), Ask - Bid);
    }

    /**
     * Get current spread in percent.
     */
    static double GetSpreadInPct() {
      return 100.0 * (Ask - Bid) / Ask;
    }

    /**
     * Get number of points per pip.
     *
     * To be used to replace Point for trade parameters calculations.
     * See: http://forum.mql4.com/30672
     */
    static int GetPointsPerPip() {
      return (int) pow(10, GetDigits() - GetPipDigits());
    }

    /**
     * Get market stop level in points.
     *
     * Minimum distance limitation.
     * A zero value means either absence of any restrictions on the minimal distance.
     *
     * @see: https://book.mql4.com/appendix/limits
     */
    static long GetStopLevel(string symbol = NULL) {
      return (long)MarketInfo(symbol, MODE_STOPLEVEL);
    }

    /**
     * Minimal indention in points from the current close price to place Stop orders.
     *
     * @param
     *   symbol string (optional)
     *   Currency pair symbol.
     *
     * @return
     *   Return symbol trade stops level in points.
     */
    static long GetTradeStopsLevel(string symbol = NULL) {
      return SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
    }

    /**
     * Get a market gap in points.
     *
     * Minimal permissible distance value in points for StopLoss/TakeProfit.
     *
     * This is due that at placing of a pending order, the open price cannot be too close to the market.
     * The minimal distance of the pending price from the current market one in points can be obtained
     * using the MarketInfo() function with the MODE_STOPLEVEL parameter.
     * Related error messages:
     *   Error 130 (ERR_INVALID_STOPS) happens In case of false open price of a pending order.
     *   Error 145 (ERR_TRADE_MODIFY_DENIED) happens when modification of order was too close to market.
     *
     * @see: https://book.mql4.com/appendix/limits
     */
    static long GetMarketDistanceInPts(string symbol = NULL) {
      return fmax(GetTradeStopsLevel(symbol), GetFreezeLevel(symbol));
    }

    /**
     * Get a market gap in pips.
     *
     * Minimal permissible distance value in pips for StopLoss/TakeProfit.
     *
     * @see: https://book.mql4.com/appendix/limits
     */
    static double GetMarketDistanceInPips(string symbol = NULL) {
      return GetMarketDistanceInPts() / GetPointsPerPip();
    }

    /**
     * Get a market gap in value.
     *
     * Minimal permissible distance value in price value for StopLoss/TakeProfit.
     *
     * @see: https://book.mql4.com/appendix/limits
     */
    static double GetMarketDistanceInValue(string symbol = NULL) {
      // @todo
      // return 10 >> GetPipDigits();
      // return GetMarketDistanceInPts() * GetPipSize();
      return False;
    }

    /**
     * Validate whether trade operation is permitted.
     *
     * @param int cmd
     *   Trade command.
     * @param int sl
     *   Stop loss price value.
     * @param int tp
     *   Take profit price value.
     * @return
     *   Returns True when trade operation is allowed.
     *
     * @see: https://book.mql4.com/appendix/limits
     */
    static double TradeOpAllowed(int cmd, double sl, double tp) {
      double ask = GetAsk();
      double bid = GetBid();
      double openprice = GetOpenPrice();
      double closeprice = GetClosePrice();
      double distance = GetMarketDistanceInPips();
      switch (cmd) {
        case OP_BUY:
          // Requirements for Minimum Distance Limitation:
          // - Bid-SL >= StopLevel && TP-Bid >= StopLevel
          // - Bid-SL > FreezeLevel && TP-Bid > FreezeLevel
          /*
            result = bid - sl >= distance && tp - bid >= distance;
            PrintFormat("1. Buy: (%g - %g) = %g >= %g; %s", Bid, sl, (bid - sl), distance, result ? "TRUE" : "FALSE");
            PrintFormat("2. Buy: (%g - %g) = %g >= %g; %s", tp, Bid, (tp - Bid), distance, result ? "TRUE" : "FALSE");
          */
          return sl > 0 && tp > 0 &&
            bid - sl >= distance &&
            tp - bid >= distance;
        case OP_SELL:
          // Requirements for Minimum Distance Limitation:
          // - SL-Ask >= StopLevel && Ask-TP >= StopLevel
          // - SL-Ask > FreezeLevel && Ask-TP > FreezeLevel
          /*
            result = sl - ask > distance && ask - tp > distance;
            PrintFormat("1. Sell: (%g - %g) = %g >= %g; %s",
                sl, Ask, (sl - Ask), distance, result ? "TRUE" : "FALSE");
            PrintFormat("2. Sell: (%g - %g) = %g >= %g; %s",
                Ask, tp, (ask - tp), distance, result ? "TRUE" : "FALSE");
          */
          return sl > 0 && tp > 0 &&
            sl - ask > distance &&
            ask - tp > distance;
        case OP_BUYLIMIT:
          // Requirements when performing trade operations:
          // - Ask-OpenPrice >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
          // - Open Price of a Pending Order is Below the current Ask price.
          // - Ask price reaches open price.
          return
            ask - openprice >= distance &&
            openprice - sl >= distance &&
            tp - openprice >= distance;
        case OP_SELLLIMIT:
          // Requirements when performing trade operations:
          // - OpenPrice-Bid >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
          // - Open Price of a Pending Order is Above the current Bid price.
          // - Bid price reaches open price.
          return
            openprice - bid >= distance &&
            sl - openprice >= distance &&
            openprice - tp >= distance;
        case OP_BUYSTOP:
          // Requirements when performing trade operations:
          // - OpenPrice-Ask >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
          // - Open Price of a Pending Order is Above the current Ask price.
          // - Ask price reaches open price.
          return
            openprice - ask >= distance &&
            openprice - sl >= distance &&
            tp - openprice >= distance;
        case OP_SELLSTOP:
          // Requirements when performing trade operations:
          // - Bid-OpenPrice >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
          // - Open Price of a Pending Order is Below the current Bid price.
          // - Bid price reaches open price.
          return
            bid - openprice >= distance &&
            sl - openprice >= distance &&
            openprice - tp >= distance;
        default:
          return (True);
      }
    }

    /**
     * Validate whether trade operation is permitted.
     *
     * @param int cmd
     *   Trade command.
     * @param int price
     *   Take profit or stop loss price value.
     * @return
     *   Returns True when trade operation is allowed.
     *
     * @see: https://book.mql4.com/appendix/limits
     */
    static double TradeOpAllowed(int cmd, double price) {
      double ask = GetAsk();
      double bid = GetBid();
      double openprice = GetOpenPrice();
      double closeprice = GetClosePrice();
      double distance = GetMarketDistanceInPips() + GetPipSize();
      bool result = (bool) (fabs(bid - price) > GetMarketDistanceInPips() + GetPipSize() && fabs(GetAsk() - price) > GetMarketDistanceInPips() + GetPipSize());
      switch (cmd) {
        case OP_BUY:
        case OP_SELL:
          /*
            PrintFormat("1: fabs(%g - %g) = %g > %g; %s",
                bid, price, fabs(bid - price), distance, result ? "TRUE" : "FALSE");
            PrintFormat("2: fabs(%g - %g) = %g > %g; %s",
                ask, price, fabs(ask - price), distance, result ? "TRUE" : "FALSE");
          */
          return price > 0 &&
            fabs(bid - price) > distance &&
            fabs(ask - price) > distance;
        case OP_BUYLIMIT:
          // Ask-OpenPrice >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
        case OP_SELLLIMIT:
          // OpenPrice-Bid >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
        case OP_BUYSTOP:
          // OpenPrice-Ask >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
        case OP_SELLSTOP:
          // Bid-OpenPrice >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
          return price > 0 &&
            fabs(bid - price) > distance &&
            fabs(ask - price) > distance;
        default:
          return (True);
      }
    }

    /**
     * Get a lot step.
     */
    static double GetLotStep(string symbol = NULL) {
      // @todo: Correct bit shifting.
      return fmax(MarketInfo(symbol, MODE_LOTSTEP), 10 >> GetPipDigits());
    }

    /**
     * Get a lot size in the base currency.
     */
    static double GetLotSize(string symbol = NULL) {
      return MarketInfo(symbol, MODE_LOTSIZE);
    }

    /**
     * Minimum permitted amount of a lot.
     */
    static double GetMinLot(string symbol = NULL) {
      return MarketInfo(symbol, MODE_MINLOT);
    }

    /**
     * Maximum permitted amount of a lot.
     */
    static double GetMaxLot(string symbol = NULL) {
      return MarketInfo(symbol, MODE_MAXLOT);
    }

    /**
     * Get a volume precision.
     */
    static int GetVolumeDigits(string symbol = NULL) {
      return (int)
        -log10(
            fmin(
              GetLotStep(symbol),
              GetMinLot(symbol)
            )
        );
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
    static int GetFreezeLevel(string symbol = NULL) {
      return (int)MarketInfo(symbol, MODE_FREEZELEVEL);
    }

    /**
     * Initial margin requirements for 1 lot.
     */
    static double GetMarginInit(string symbol = NULL) {
      return MarketInfo(symbol, MODE_MARGININIT);
    }

    /**
     * Free margin required to open 1 lot for buying.
     */
    static double GetMarginRequired(string symbol = NULL) {
      return MarketInfo(symbol, MODE_MARGINREQUIRED);
    }

    /**
     * Get current open price depending on the operation type.
     *
     * @param:
     *   op_type int Order operation type of the order.
     * @return
     *   Current open price.
     */
    static double GetOpenPrice(int op_type = EMPTY_VALUE) {
      if (op_type == EMPTY_VALUE) op_type = OrderType();
      return op_type == OP_BUY ? Ask : Bid;
    }

    /**
     * Get current close price depending on the operation type.
     *
     * @param:
     *   op_type int Order operation type of the order.
     * @return
     * Current close price.
     */
    static double GetClosePrice(int op_type = EMPTY_VALUE) {
      if (op_type == EMPTY_VALUE) op_type = OrderType();
      return op_type == OP_BUY ? Bid : Ask;
    }

    /**
     * Get value in account currency of a point of symbol.
     *
     * @see
     * - https://forum.mql4.com/33975
     * - https://forum.mql4.com/43064#515262
     * - https://forum.mql4.com/41259/page3#512466
     */
    double DeltaValuePerLot(string symbol = NULL) {
      // Return tick value in the deposit currency divided by tick size in points.
      return MarketInfo(symbol, MODE_TICKVALUE) / MarketInfo(symbol, MODE_TICKSIZE);
    }

    /**
     * Refresh data in pre-defined variables and series arrays.
     */
    static void RefreshRates() {
      ::RefreshRates();
    }

    /**
     * Check whether we're trading within market peak hours.
     */
    bool IsPeakHour() {
        int hour;
        #ifdef __MQL5__
        MqlDateTime dt;
        TimeCurrent(dt);
        hour = dt.hour;
        #else
        hour = Hour();
        #endif
        return hour >= 8 && hour <= 16;
    }

};

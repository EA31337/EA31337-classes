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
    static int GetAsk(string symbol = NULL) {
      return symbol ? MarketInfo(symbol, MODE_ASK) : Ask;
    }

    /**
     * Get bid price.
     */
    static int GetBid(string symbol = NULL) {
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
     */
    static int GetDigits(string symbol = NULL) {
      return symbol ? MarketInfo(symbol, MODE_DIGITS) : Digits;
    }

    /**
     * Get pip precision.
     */
    static int GetPipDigits(string symbol = NULL) {
      return (GetDigits(symbol) < 4 ? 2 : 4);
    }

    /**
     * Get current spread in points.
     */
    static long GetSpreadInPts(string symbol = NULL) {
      return SymbolInfoInteger(symbol, SYMBOL_SPREAD);
    }

    /**
     * Get current spread in float.
     */
    static double GetSpreadInPips() {
      return Ask - Bid;
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
      return (int)pow(10, GetDigits() - GetPipDigits());
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
     */
    static long GetTradeStopsLevel(string symbol = NULL) {
      return SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
    }

    /**
     * Get market gap in points.
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
    static long GetDistanceInPts(string symbol = NULL) {
      return fmax(GetTradeStopsLevel(symbol), GetFreezeLevel(symbol));
    }

    /**
     * Get market gap in pips.
     *
     * Minimal permissible distance value in pips for StopLoss/TakeProfit.
     *
     * @see: https://book.mql4.com/appendix/limits
     */
    static double GetDistanceInPips(string symbol = NULL) {
      return fmax(GetTradeStopsLevel(symbol), GetFreezeLevel(symbol)) * GetPoint();
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
      switch (cmd) {
        case OP_BUY:
          return GetBid() > tp && GetAsk() < sl
            && GetBid() - sl > GetDistanceInPips() + GetPipSize()
            && tp - GetBid() > GetDistanceInPips() + GetPipSize();
        case OP_SELL:
          return GetBid() < tp && GetAsk() > sl
            && sl - GetAsk() > GetDistanceInPips() + GetPipSize()
            && GetAsk() - tp > GetDistanceInPips() + GetPipSize();
        case OP_BUYLIMIT:
          // Ask-OpenPrice ≥ StopLevel / OpenPrice-SL ≥ StopLevel && TP-OpenPrice ≥ StopLevel
        case OP_SELLLIMIT:
          // OpenPrice-Bid ≥ StopLevel / SL-OpenPrice ≥ StopLevel && OpenPrice-TP ≥ StopLevel
        case OP_BUYSTOP:
          // OpenPrice-Ask ≥ StopLevel / OpenPrice-SL ≥ StopLevel && TP-OpenPrice ≥ StopLevel
        case OP_SELLSTOP:
          // Bid-OpenPrice ≥ StopLevel / SL-OpenPrice ≥ StopLevel && OpenPrice-TP ≥ StopLevel
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
      switch (cmd) {
        case OP_BUY:
        case OP_SELL:
          return
            fabs(GetBid() - price) > GetDistanceInPips() + GetPipSize() &&
            fabs(GetAsk() - price) > GetDistanceInPips() + GetPipSize();
        case OP_BUYLIMIT:
          // Ask-OpenPrice ≥ StopLevel / OpenPrice-SL ≥ StopLevel && TP-OpenPrice ≥ StopLevel
        case OP_SELLLIMIT:
          // OpenPrice-Bid ≥ StopLevel / SL-OpenPrice ≥ StopLevel && OpenPrice-TP ≥ StopLevel
        case OP_BUYSTOP:
          // OpenPrice-Ask ≥ StopLevel / OpenPrice-SL ≥ StopLevel && TP-OpenPrice ≥ StopLevel
        case OP_SELLSTOP:
          // Bid-OpenPrice ≥ StopLevel / SL-OpenPrice ≥ StopLevel && OpenPrice-TP ≥ StopLevel
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

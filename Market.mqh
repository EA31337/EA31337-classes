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

/**
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
      return symbol != NULL ? MarketInfo(symbol, MODE_ASK) : Ask;
    }

    /**
     * Get bid price.
     */
    static double GetBid(string symbol = NULL) {
      return symbol != NULL ? MarketInfo(symbol, MODE_BID) : Bid;
    }

    /**
     * Get point size in the quote currency.
     *
     * Use Point predefined variable for the current symbol.
     */
    static double GetPoint(string symbol = NULL) {
      return symbol != NULL ? MarketInfo(symbol, MODE_POINT) : Point;
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
     * Get a tick size.
     */
    double GetTickSize(string symbol = NULL) {
      // Note: In currencies a tick is always a point, but not for other markets.
      return MarketInfo(symbol, MODE_TICKSIZE);
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
    static double GetSpreadInPips(string symbol = NULL) {
      return (Ask - Bid) * pow(10, GetPipDigits(symbol));
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
    static int GetPointsPerPip(string symbol = NULL) {
      return (int) pow(10, GetDigits() - GetPipDigits(symbol));
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
      // @fixme
      return (double) (GetMarketDistanceInPts(symbol) / GetPointsPerPip(symbol));
    }

    /**
     * Get a market gap in value.
     *
     * Minimal permissible distance value in value for StopLoss/TakeProfit.
     *
     * @see: https://book.mql4.com/appendix/limits
     */
    static double GetMarketDistanceInValue(string symbol = NULL) {
      return GetMarketDistanceInPts(symbol) * _Point;
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
     * @param string symbol
     *   Currency symbol.
     * @return
     *   Returns True when trade operation is allowed.
     *
     * @see: https://book.mql4.com/appendix/limits
     * @see: https://www.mql5.com/en/articles/2555#invalid_SL_TP_for_position
     */
    static double TradeOpAllowed(int cmd, double sl, double tp, string symbol = NULL) {
      double ask = GetAsk();
      double bid = GetBid();
      double openprice = GetOpenPrice();
      double closeprice = GetClosePrice();
      // The minimum distance of SYMBOL_TRADE_STOPS_LEVEL taken into account.
      double distance = GetMarketDistanceInValue(symbol);
      // bool result;
      switch (cmd) {
        case OP_BUY:
          // Buying is done at the Ask price.
          // Requirements for Minimum Distance Limitation:
          // - Bid - StopLoss >= StopLevel  && TakeProfit - Bid >= StopLevel
          // - Bid - StopLoss > FreezeLevel && TakeProfit - Bid > FreezeLevel
          /*
          result = sl > 0 && tp > 0 && bid - sl >= distance && tp - bid >= distance;
          PrintFormat("1. Buy: (%g - %g) = %g >= %g; %s", Bid, sl, (bid - sl), distance, result ? "TRUE" : "FALSE");
          PrintFormat("2. Buy: (%g - %g) = %g >= %g; %s", tp, Bid, (tp - Bid), distance, result ? "TRUE" : "FALSE");
          */
          // The TakeProfit and StopLoss levels must be at the distance of at least SYMBOL_TRADE_STOPS_LEVEL points from the Bid price.
          return sl > 0 && tp > 0 &&
            bid - sl >= distance &&
            tp - bid >= distance;
        case OP_SELL:
          // Selling is done at the Bid price.
          // Requirements for Minimum Distance Limitation:
          // - StopLoss - Ask >= StopLevel  && Ask - TakeProfit >= StopLevel
          // - StopLoss - Ask > FreezeLevel && Ask - TakeProfit > FreezeLevel
          /*
          result = sl > 0 && tp > 0 && sl - ask > distance && ask - tp > distance;
          PrintFormat("1. Sell: (%g - %g) = %g >= %g; %s",
            sl, Ask, (sl - Ask), distance, result ? "TRUE" : "FALSE");
          PrintFormat("2. Sell: (%g - %g) = %g >= %g; %s",
            Ask, tp, (ask - tp), distance, result ? "TRUE" : "FALSE");
          */
          // The TakeProfit and StopLoss levels must be at the distance of at least SYMBOL_TRADE_STOPS_LEVEL points from the Ask price.
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
      double distance = GetMarketDistanceInPips() + GetPipSize();
      // bool result;
      switch (cmd) {
        case OP_BUYSTOP:
          // OpenPrice-Ask >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
        case OP_BUYLIMIT:
          // Ask-OpenPrice >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
        case OP_BUY:
          // Bid-OpenPrice >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
        case OP_SELLLIMIT:
          // OpenPrice-Bid >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
        case OP_SELLSTOP:
          // Bid-OpenPrice >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
        case OP_SELL:
          /*
          result = price > 0 && ask - price > distance && price - ask > distance;
          PrintFormat("%s: 1: %g - %g = %g > %g; %s",
              __FUNCTION__, bid, price, bid - price, distance, result ? "TRUE" : "FALSE");
          PrintFormat("%s: 2: %g - %g = %g > %g; %s",
              __FUNCTION__, ask, price, ask - price, distance, result ? "TRUE" : "FALSE");
           */
          // return price > 0 && fabs(bid - price) > distance && fabs(ask - price) > distance;
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
    static double GetLotStepInPips(string symbol = NULL) {
      // @todo: Correct bit shifting.
      return fmax(MarketInfo(symbol, MODE_LOTSTEP), 10 >> GetPipDigits());
    }

    /**
     * Get a lot step.
     */
    static double GetLotStepInPts(string symbol = NULL) {
      // @todo: Correct bit shifting.
      return MarketInfo(symbol, MODE_LOTSTEP);
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
              GetLotStepInPts(symbol),
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
      return (int) MarketInfo(symbol, MODE_FREEZELEVEL);
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
     * Get peak price at given number of bars.
     *
     * In case of error, check it via GetLastError().
     */
    static double GetPeakPrice(int timeframe, int mode, int bars, int index = 0, string symbol = NULL) {
      int ibar = -1;
      double peak_price = Open[0];
      switch (mode) {
        case MODE_HIGH:
          ibar = iHighest(symbol, timeframe, MODE_HIGH, bars, index);
          return ibar >= 0 ? iHigh(symbol, timeframe, ibar) : False;
        case MODE_LOW:
          ibar =  iLowest(symbol, timeframe, MODE_LOW,  bars, index);
          return ibar >= 0 ? iLow(symbol, timeframe, ibar) : False;
        default:
          return False;
      }
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
   * Normalize price value.
   *
   * Make sure that the price is a multiple of ticksize.
   */
  double NormalizePrice(double p, string symbol = NULL) {
    // See: http://forum.mql4.com/47988
    // http://forum.mql4.com/43064#515262 zzuegg reports for non-currency DE30:
    // - MarketInfo(chart.symbol,MODE_TICKSIZE) returns 0.5
    // - MarketInfo(chart.symbol,MODE_DIGITS) return 1
    // - Point = 0.1
    // Rare fix when a change in tick size leads to a change in tick value.
    return round(p / Point) * GetTickSize();
  }

  /**
   * Normalize lot size.
   */
  static double NormalizeLots(double lots, bool ceiling = False, string symbol = NULL) {
    // Related: http://forum.mql4.com/47988
    double precision = GetLotStepInPts() > 0.0 ? 1 / GetLotStepInPts() : 1 / GetMinLot(symbol);
    double lot_size = ceiling ? MathCeil(lots * precision) / precision : MathFloor(lots * precision) / precision;
    lot_size = fmin(fmax(lot_size, GetMinLot(symbol)), GetMaxLot(symbol));
    return NormalizeDouble(lot_size, GetVolumeDigits());
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

  /**
   * Calculates the current market trend.
   *
   * @param
   *   method (int)
   *    Bitwise trend method to use.
   *   tf (ENUM_TIMEFRAMES)
   *     Frequency based on the given timeframe. Use NULL for the current.
   *   symbol (string)
   *     Symbol pair to check against it.
   *   simple (bool)
   *     If True, use simple trend calculation.
   *
   * @return
   *   Returns positive value for bullish, negative for bearish, zero for neutral market trend.
   *
   * @todo: Improve number of increases for bull/bear variables.
   */
  static double GetTrend(int method, ENUM_TIMEFRAMES tf = NULL, string symbol = NULL, bool simple = False) {
    static datetime _last_trend_check = 0;
    static double _last_trend = 0;
    if (_last_trend_check == iTime(symbol, tf, 0)) {
      return _last_trend;
    }
    double bull = 0, bear = 0;
    int _counter = 0;

    if (simple) {
      if ((method &   1) != 0)  {
        if (iOpen(NULL, PERIOD_MN1, 0) > iClose(NULL, PERIOD_MN1, 1)) bull++;
        if (iOpen(NULL, PERIOD_MN1, 0) < iClose(NULL, PERIOD_MN1, 1)) bear++;
      }
      if ((method &   2) != 0)  {
        if (iOpen(NULL, PERIOD_W1, 0) > iClose(NULL, PERIOD_W1, 1)) bull++;
        if (iOpen(NULL, PERIOD_W1, 0) < iClose(NULL, PERIOD_W1, 1)) bear++;
      }
      if ((method &   4) != 0)  {
        if (iOpen(NULL, PERIOD_D1, 0) > iClose(NULL, PERIOD_D1, 1)) bull++;
        if (iOpen(NULL, PERIOD_D1, 0) < iClose(NULL, PERIOD_D1, 1)) bear++;
      }
      if ((method &   8) != 0)  {
        if (iOpen(NULL, PERIOD_H4, 0) > iClose(NULL, PERIOD_H4, 1)) bull++;
        if (iOpen(NULL, PERIOD_H4, 0) < iClose(NULL, PERIOD_H4, 1)) bear++;
      }
      if ((method &   16) != 0)  {
        if (iOpen(NULL, PERIOD_H1, 0) > iClose(NULL, PERIOD_H1, 1)) bull++;
        if (iOpen(NULL, PERIOD_H1, 0) < iClose(NULL, PERIOD_H1, 1)) bear++;
      }
      if ((method &   32) != 0)  {
        if (iOpen(NULL, PERIOD_M30, 0) > iClose(NULL, PERIOD_M30, 1)) bull++;
        if (iOpen(NULL, PERIOD_M30, 0) < iClose(NULL, PERIOD_M30, 1)) bear++;
      }
      if ((method &   64) != 0)  {
        if (iOpen(NULL, PERIOD_M15, 0) > iClose(NULL, PERIOD_M15, 1)) bull++;
        if (iOpen(NULL, PERIOD_M15, 0) < iClose(NULL, PERIOD_M15, 1)) bear++;
      }
      if ((method &  128) != 0)  {
        if (iOpen(NULL, PERIOD_M5, 0) > iClose(NULL, PERIOD_M5, 1)) bull++;
        if (iOpen(NULL, PERIOD_M5, 0) < iClose(NULL, PERIOD_M5, 1)) bear++;
      }
      //if (iOpen(NULL, PERIOD_H12, 0) > iClose(NULL, PERIOD_H12, 1)) bull++;
      //if (iOpen(NULL, PERIOD_H12, 0) < iClose(NULL, PERIOD_H12, 1)) bear++;
      //if (iOpen(NULL, PERIOD_H8, 0) > iClose(NULL, PERIOD_H8, 1)) bull++;
      //if (iOpen(NULL, PERIOD_H8, 0) < iClose(NULL, PERIOD_H8, 1)) bear++;
      //if (iOpen(NULL, PERIOD_H6, 0) > iClose(NULL, PERIOD_H6, 1)) bull++;
      //if (iOpen(NULL, PERIOD_H6, 0) < iClose(NULL, PERIOD_H6, 1)) bear++;
      //if (iOpen(NULL, PERIOD_H2, 0) > iClose(NULL, PERIOD_H2, 1)) bull++;
      //if (iOpen(NULL, PERIOD_H2, 0) < iClose(NULL, PERIOD_H2, 1)) bear++;
    } else {
      if ((method &   1) != 0)  {
        for (_counter = 0; _counter < 3; _counter++) {
          if (iOpen(NULL, PERIOD_MN1, _counter) > iClose(NULL, PERIOD_MN1, _counter + 1)) bull += 30;
          else if (iOpen(NULL, PERIOD_MN1, _counter) < iClose(NULL, PERIOD_MN1, _counter + 1)) bear += 30;
        }
      }
      if ((method &   2) != 0)  {
        for (_counter = 0; _counter < 8; _counter++) {
          if (iOpen(NULL, PERIOD_W1, _counter) > iClose(NULL, PERIOD_W1, _counter + 1)) bull += 7;
          else if (iOpen(NULL, PERIOD_W1, _counter) < iClose(NULL, PERIOD_W1, _counter + 1)) bear += 7;
        }
      }
      if ((method &   4) != 0)  {
        for (_counter = 0; _counter < 7; _counter++) {
          if (iOpen(NULL, PERIOD_D1, _counter) > iClose(NULL, PERIOD_D1, _counter + 1)) bull += 1440/1440;
          else if (iOpen(NULL, PERIOD_D1, _counter) < iClose(NULL, PERIOD_D1, _counter + 1)) bear += 1440/1440;
        }
      }
      if ((method &   8) != 0)  {
        for (_counter = 0; _counter < 24; _counter++) {
          if (iOpen(NULL, PERIOD_H4, _counter) > iClose(NULL, PERIOD_H4, _counter + 1)) bull += 240/1440;
          else if (iOpen(NULL, PERIOD_H4, _counter) < iClose(NULL, PERIOD_H4, _counter + 1)) bear += 240/1440;
        }
      }
      if ((method &   16) != 0)  {
        for (_counter = 0; _counter < 24; _counter++) {
          if (iOpen(NULL, PERIOD_H1, _counter) > iClose(NULL, PERIOD_H1, _counter + 1)) bull += 60/1440;
          else if (iOpen(NULL, PERIOD_H1, _counter) < iClose(NULL, PERIOD_H1, _counter + 1)) bear += 60/1440;
        }
      }
      if ((method &   32) != 0)  {
        for (_counter = 0; _counter < 48; _counter++) {
          if (iOpen(NULL, PERIOD_M30, _counter) > iClose(NULL, PERIOD_M30, _counter + 1)) bull += 30/1440;
          else if (iOpen(NULL, PERIOD_M30, _counter) < iClose(NULL, PERIOD_M30, _counter + 1)) bear += 30/1440;
        }
      }
      if ((method &   64) != 0)  {
        for (_counter = 0; _counter < 96; _counter++) {
          if (iOpen(NULL, PERIOD_M15, _counter) > iClose(NULL, PERIOD_M15, _counter + 1)) bull += 15/1440;
          else if (iOpen(NULL, PERIOD_M15, _counter) < iClose(NULL, PERIOD_M15, _counter + 1)) bear += 15/1440;
        }
      }
      if ((method &  128) != 0)  {
        for (_counter = 0; _counter < 288; _counter++) {
          if (iOpen(NULL, PERIOD_M5, _counter) > iClose(NULL, PERIOD_M5, _counter + 1)) bull += 5/1440;
          else if (iOpen(NULL, PERIOD_M5, _counter) < iClose(NULL, PERIOD_M5, _counter + 1)) bear += 5/1440;
        }
      }
    }
    _last_trend = (bull - bear);
    _last_trend_check = iTime(symbol, tf, 0);
    #ifdef __trace__ PrintFormat("%s: %g", __FUNCTION__, _last_trend); #endif
    return _last_trend;
  }

  /**
   * Get the current market trend.
   *
   * @param
   *   method (int)
   *    Bitwise trend method to use.
   *   tf (ENUM_TIMEFRAMES)
   *     Frequency based on the given timeframe. Use NULL for the current.
   *   symbol (string)
   *     Symbol pair to check against it.
   *   simple (bool)
   *     If True, use simple trend calculation.
   *
   * @return
   *   Returns OP_BUY operation for bullish, OP_SELL for bearish, EMPTY (-1) for neutral market trend.
   */
  static int GetTrendOp(int method, ENUM_TIMEFRAMES tf = NULL, string symbol = NULL, bool simple = False) {
    double _curr_trend = GetTrend(method, tf, symbol, simple);
    return _curr_trend == 0 ? EMPTY : (_curr_trend > 0 ? OP_BUY : OP_SELL);
  }

};
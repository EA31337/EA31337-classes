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
class Trade;

// Includes.
#include "Account.mqh"
#include "Chart.mqh"
#include "Convert.mqh"
// #include "Market.mqh"

/**
 * Trade class
 */
class Trade {

  protected:

    // Structs.
    struct TradeParams {
      uint             slippage;   // Value of the maximum price slippage in points.
      Account         *account;    // Pointer to Account class.
      Chart           *chart;      // Pointer to Chart class.
      void Init(TradeParams &p) { slippage = p.slippage; account = p.account; chart = p.chart; }
    };

    // Other variables.
    TradeParams trade_params;

  public:

    /**
     * Class constructor.
     */
    void Trade(TradeParams &_params) {
      trade_params = _params;
      trade_params.account = (trade_params.account == NULL ? new Account : trade_params.account);
      trade_params.chart = (trade_params.chart == NULL ? new Chart : trade_params.chart);
    }

    /**
     * Class deconstructor.
     */
    void ~Trade() {
      delete trade_params.account;
      delete trade_params.chart;
    }

  /**
   * Calculates the margin required for the specified order type.
   *
   * Note: It not taking into account current pending orders and open positions.
   *
   * @see: https://www.mql5.com/en/docs/trading/ordercalcmargin
   */
  bool OrderCalcMargin(
     ENUM_ORDER_TYPE       _action,           // type of order
     string                _symbol,           // symbol name
     double                _volume,           // volume
     double                _price,            // open price
     double&               _margin            // variable for obtaining the margin value
     ) {
     #ifdef __MQL4__
     // @todo: Not implemented yet.
     return NULL;
     #else // __MQL5__
     return OrderCalcMargin(_action, _symbol, _volume, _price, _margin);
     #endif
   }

  /* Lot size methods */

  /**
   * Calculate the maximal lot size for the given stop loss value and risk margin.
   *
   * @param double sl
   *   Stop loss to calculate the lot size for.
   * @param double risk_margin
   *   Maximum account margin to risk (in %).
   * @param string symbol
   *   Symbol pair.
   *
   * @return
   *   Returns maximum safe lot size value.
   *
   * @see: https://www.mql5.com/en/code/8568
   */
  double GetMaxLotSize(ENUM_ORDER_TYPE cmd, double sl, double risk_margin = 1.0) {
    double risk_amount = AccountInfo().GetRealBalance() / 100 * risk_margin;
    double _ticks = fabs(sl - MarketInfo().GetOpenOffer(cmd)) / MarketInfo().GetTickSize();
    double lot_size1 = risk_amount / (sl * (_ticks / 100.0));
    lot_size1 *= ChartInfo().GetMinLot();
    // double lot_size2 = 1 / (MarketInfo().GetTickValue() * sl / risk_margin);
    // PrintFormat("SL=%g: 1 = %g, 2 = %g", sl, lot_size1, lot_size2);
    return ChartInfo().NormalizeLots(lot_size1);
  }

  /**
   * Validate TP/SL value for the order.
   */
  bool ValidSLTP(double value, ENUM_ORDER_TYPE _cmd, int direction = -1, bool existing = false) {
    // Calculate minimum market gap.
    double price = MarketInfo().GetOpenOffer(_cmd);
    double distance = MarketInfo().GetTradeDistanceInPips();
    bool valid = (
            (_cmd == OP_BUY  && direction < 0 && Convert::GetValueDiffInPips(price, value) > distance)
         || (_cmd == OP_BUY  && direction > 0 && Convert::GetValueDiffInPips(value, price) > distance)
         || (_cmd == OP_SELL && direction < 0 && Convert::GetValueDiffInPips(value, price) > distance)
         || (_cmd == OP_SELL && direction > 0 && Convert::GetValueDiffInPips(price, value) > distance)
         );
    valid &= (value >= 0); // Also must be zero (for unlimited) or above.
    #ifdef __debug__
    if (!valid) PrintFormat("%s: Value is not valid: %g (price=%g, distance=%g)!", __FUNCTION__, value, price, distance);
    #endif
    return valid;
  }

 /**
  * Optimize lot size for open based on the consecutive wins and losses.
  *
  * @param
  *   lots (double)
  *     Base lot size.
  *   win_factor (double)
  *     Lot size increase factor (in %) multiplied by consecutive wins.
  *   loss_factor (double)
  *     Lot size increase factor (in %) multiplied by consecutive losses.
  *   ols_orders (double)
  *     Maximum number of recent orders to check for consecutive wins/losses.
  *   symbol (string)
  *     Optional symbol name if different than current.
  */
  double OptimizeLotSize(double lots, double win_factor = 1.0, double loss_factor = 1.0, int ols_orders = 100, string _symbol = NULL) {

    double lotsize = lots;
    int    wins = 0,  losses = 0; // Number of consequent losing orders.
    int    twins = 0, tlosses = 0; // Total number of consequent losing orders.
    if (win_factor == 0 && loss_factor == 0) {
      return lotsize;
    }
    // Calculate number of wins and losses orders without a break.
    #ifdef __MQL5__
    CDealInfo deal;
    HistorySelect(0, TimeCurrent()); // Select history for access.
    #endif
    int _orders = HistoryTotal();
    for (int i = _orders - 1; i >= fmax(0, _orders - ols_orders); i--) {
     #ifdef __MQL5__
     deal.Ticket(HistoryDealGetTicket(i));
     if (deal.Ticket() == 0) {
       Print(__FUNCTION__, ": Error in history!");
       break;
     }
     if (deal.Symbol() != MarketInfo().GetSymbol()) continue;
     double profit = deal.Profit();
     #else
     if (Order::OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == false) {
       Print(__FUNCTION__, ": Error in history!");
       break;
     }
     if (Order::OrderSymbol() != Symbol() || Order::OrderType() > ORDER_TYPE_SELL) continue;
     double profit = Order::OrderProfit();
     #endif
     if (profit > 0.0) {
       losses = 0;
       wins++;
     } else {
       wins = 0;
       losses++;
     }
     twins = fmax(wins, twins);
     tlosses = fmax(losses, tlosses);
    }
    lotsize = twins   > 1 ? NormalizeDouble(lotsize + (lotsize / 100 * win_factor * twins), 2) : lotsize;
    lotsize = tlosses > 1 ? NormalizeDouble(lotsize + (lotsize / 100 * loss_factor * tlosses), 2) : lotsize;
    // Normalize and check limits.
    double minvol = SymbolInfoDouble(MarketInfo().GetSymbol(), SYMBOL_VOLUME_MIN);
    lotsize = lotsize < minvol ? minvol : lotsize;
    double maxvol = SymbolInfoDouble(MarketInfo().GetSymbol(), SYMBOL_VOLUME_MAX);
    lotsize = lotsize > maxvol ? maxvol : lotsize;
    double stepvol = SymbolInfoDouble(MarketInfo().GetSymbol(), SYMBOL_VOLUME_STEP);
    lotsize = stepvol * NormalizeDouble(lotsize / stepvol, 0);
    return (lotsize);
  }

  /**
   * Calculate size of the lot based on the free margin.
   */
  double CalcLotSize(double risk_margin = 1, double risk_ratio = 1.0) {
    return AccountInfo().AccountAvailMargin() / ChartInfo().GetMarginRequired() * risk_margin / 100 * risk_ratio;
  }

  /* Orders methods */

  /**
   * Calculate available lot size given the risk margin.
   */
  uint CalcMaxLotSize(double risk_margin = 1.0) {
    double _avail_margin = AccountInfo().AccountAvailMargin();
    double _opened_lots = Trades().GetOpenLots();
    // @todo
    return 0;
  }

  /**
   * Calculate number of allowed orders to open.
   */
  uint CalcMaxOrders(double volume_size, double _risk_ratio = 1.0, uint prev_max_orders = 0, uint hard_limit = 0, bool smooth = true) {
    double _avail_margin = fmin(AccountInfo().GetMarginFree(), AccountInfo().GetBalance() + AccountInfo().GetCredit());
    double _margin_required = ChartInfo().GetMarginRequired();
    double _avail_orders = _avail_margin / _margin_required / volume_size;
    uint new_max_orders = (int) (_avail_orders * _risk_ratio);
    if (hard_limit > 0) new_max_orders = fmin(hard_limit, new_max_orders);
    if (smooth && new_max_orders > prev_max_orders) {
      // Increase the limit smoothly.
      return (prev_max_orders + new_max_orders) / 2;
    } else {
      return new_max_orders;
    }
  }

    /* TP/SL methods */

    /**
     * Returns maximal order stop loss value given the risk margin (in %).
     *
     * @param int cmd
     *   Trade command (e.g. OP_BUY/OP_SELL).
     * @param double lot_size
     *   Lot size to take into account.
     * @param double risk_margin
     *   Maximum account margin to risk (in %).
     * @return
     *   Returns maximum stop loss price value for the given symbol.
     */
    double GetMaxStopLoss(ENUM_ORDER_TYPE _cmd, double _lot_size, double _risk_margin = 1.0) {
      return MarketInfo().GetOpenOffer(_cmd)
        + ChartInfo().GetTradeDistanceInValue()
        + Convert::MoneyToValue(AccountInfo().GetRealBalance() / 100 * _risk_margin, _lot_size)
        * -Order::OrderDirection(_cmd);
    }

    /**
     * Returns value of take profit for the new order.
     */
    static double CalcOrderTakeProfit(ENUM_ORDER_TYPE _cmd, double _tp, string _symbol) {
      return _tp > 0 ? Market::GetOpenOffer(_symbol, _cmd) + _tp * Market::GetPipSize(_symbol) * Order::OrderDirection(_cmd) : 0;
    }
    double CalcOrderTakeProfit(ENUM_ORDER_TYPE _cmd, double _tp) {
      return _tp > 0 ? MarketInfo().GetOpenOffer(_cmd) + _tp * MarketInfo().GetPipSize() * Order::OrderDirection(_cmd) : 0;
    }

    /**
     * Returns value of stop loss for the new order.
     */
    static double CalcOrderStopLoss(ENUM_ORDER_TYPE _cmd, double _sl, string _symbol) {
      return _sl > 0 ? Market::GetOpenOffer(_symbol, _cmd) - _sl * Market::GetPipSize(_symbol) * Order::OrderDirection(_cmd) : 0;
    }
    double CalcOrderStopLoss(ENUM_ORDER_TYPE _cmd, double _sl) {
      return _sl > 0 ? MarketInfo().GetOpenOffer(_cmd) - _sl * MarketInfo().GetPipSize() * Order::OrderDirection(_cmd) : 0;
    }

  /* Trend methods */

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
   *     If true, use simple trend calculation.
   *
   * @return
   *   Returns positive value for bullish, negative for bearish, zero for neutral market trend.
   *
   * @todo: Improve number of increases for bull/bear variables.
   */
  double GetTrend(int method, ENUM_TIMEFRAMES _tf = NULL, bool simple = false) {
    static datetime _last_trend_check = 0;
    static double _last_trend = 0;
    string symbol = MarketInfo().GetSymbol();
    if (_last_trend_check == ChartInfo().GetBarTime(_tf)) {
      return _last_trend;
    }
    double bull = 0, bear = 0;
    int _counter = 0;

    if (simple && method != 0) {
      if ((method &   1) != 0)  {
        if (ChartInfo().GetOpen(PERIOD_MN1, 0) > ChartInfo().GetClose(PERIOD_MN1, 1)) bull++;
        if (ChartInfo().GetOpen(PERIOD_MN1, 0) < ChartInfo().GetClose(PERIOD_MN1, 1)) bear++;
      }
      if ((method &   2) != 0)  {
        if (ChartInfo().GetOpen(PERIOD_W1, 0) > ChartInfo().GetClose(PERIOD_W1, 1)) bull++;
        if (ChartInfo().GetOpen(PERIOD_W1, 0) < ChartInfo().GetClose(PERIOD_W1, 1)) bear++;
      }
      if ((method &   4) != 0)  {
        if (ChartInfo().GetOpen(PERIOD_D1, 0) > ChartInfo().GetClose(PERIOD_D1, 1)) bull++;
        if (ChartInfo().GetOpen(PERIOD_D1, 0) < ChartInfo().GetClose(PERIOD_D1, 1)) bear++;
      }
      if ((method &   8) != 0)  {
        if (ChartInfo().GetOpen(PERIOD_H4, 0) > ChartInfo().GetClose(PERIOD_H4, 1)) bull++;
        if (ChartInfo().GetOpen(PERIOD_H4, 0) < ChartInfo().GetClose(PERIOD_H4, 1)) bear++;
      }
      if ((method &   16) != 0)  {
        if (ChartInfo().GetOpen(PERIOD_H1, 0) > ChartInfo().GetClose(PERIOD_H1, 1)) bull++;
        if (ChartInfo().GetOpen(PERIOD_H1, 0) < ChartInfo().GetClose(PERIOD_H1, 1)) bear++;
      }
      if ((method &   32) != 0)  {
        if (ChartInfo().GetOpen(PERIOD_M30, 0) > ChartInfo().GetClose(PERIOD_M30, 1)) bull++;
        if (ChartInfo().GetOpen(PERIOD_M30, 0) < ChartInfo().GetClose(PERIOD_M30, 1)) bear++;
      }
      if ((method &   64) != 0)  {
        if (ChartInfo().GetOpen(PERIOD_M15, 0) > ChartInfo().GetClose(PERIOD_M15, 1)) bull++;
        if (ChartInfo().GetOpen(PERIOD_M15, 0) < ChartInfo().GetClose(PERIOD_M15, 1)) bear++;
      }
      if ((method &  128) != 0)  {
        if (ChartInfo().GetOpen(PERIOD_M5, 0) > ChartInfo().GetClose(PERIOD_M5, 1)) bull++;
        if (ChartInfo().GetOpen(PERIOD_M5, 0) < ChartInfo().GetClose(PERIOD_M5, 1)) bear++;
      }
      //if (ChartInfo().GetOpen(PERIOD_H12, 0) > ChartInfo().GetClose(PERIOD_H12, 1)) bull++;
      //if (ChartInfo().GetOpen(PERIOD_H12, 0) < ChartInfo().GetClose(PERIOD_H12, 1)) bear++;
      //if (ChartInfo().GetOpen(PERIOD_H8, 0) > ChartInfo().GetClose(PERIOD_H8, 1)) bull++;
      //if (ChartInfo().GetOpen(PERIOD_H8, 0) < ChartInfo().GetClose(PERIOD_H8, 1)) bear++;
      //if (ChartInfo().GetOpen(PERIOD_H6, 0) > ChartInfo().GetClose(PERIOD_H6, 1)) bull++;
      //if (ChartInfo().GetOpen(PERIOD_H6, 0) < ChartInfo().GetClose(PERIOD_H6, 1)) bear++;
      //if (ChartInfo().GetOpen(PERIOD_H2, 0) > ChartInfo().GetClose(PERIOD_H2, 1)) bull++;
      //if (ChartInfo().GetOpen(PERIOD_H2, 0) < ChartInfo().GetClose(PERIOD_H2, 1)) bear++;
    } else if (method != 0) {
      if ((method %   1) == 0)  {
        for (_counter = 0; _counter < 3; _counter++) {
          if (ChartInfo().GetOpen(PERIOD_MN1, _counter) > ChartInfo().GetClose(PERIOD_MN1, _counter + 1)) bull += 30;
          else if (ChartInfo().GetOpen(PERIOD_MN1, _counter) < ChartInfo().GetClose(PERIOD_MN1, _counter + 1)) bear += 30;
        }
      }
      if ((method %   2) == 0)  {
        for (_counter = 0; _counter < 8; _counter++) {
          if (ChartInfo().GetOpen(PERIOD_W1, _counter) > ChartInfo().GetClose(PERIOD_W1, _counter + 1)) bull += 7;
          else if (ChartInfo().GetOpen(PERIOD_W1, _counter) < ChartInfo().GetClose(PERIOD_W1, _counter + 1)) bear += 7;
        }
      }
      if ((method %   4) == 0)  {
        for (_counter = 0; _counter < 7; _counter++) {
          if (ChartInfo().GetOpen(PERIOD_D1, _counter) > ChartInfo().GetClose(PERIOD_D1, _counter + 1)) bull += 1440/1440;
          else if (ChartInfo().GetOpen(PERIOD_D1, _counter) < ChartInfo().GetClose(PERIOD_D1, _counter + 1)) bear += 1440/1440;
        }
      }
      if ((method %   8) == 0)  {
        for (_counter = 0; _counter < 24; _counter++) {
          if (ChartInfo().GetOpen(PERIOD_H4, _counter) > ChartInfo().GetClose(PERIOD_H4, _counter + 1)) bull += 240/1440;
          else if (ChartInfo().GetOpen(PERIOD_H4, _counter) < ChartInfo().GetClose(PERIOD_H4, _counter + 1)) bear += 240/1440;
        }
      }
      if ((method %   16) == 0)  {
        for (_counter = 0; _counter < 24; _counter++) {
          if (ChartInfo().GetOpen(PERIOD_H1, _counter) > ChartInfo().GetClose(PERIOD_H1, _counter + 1)) bull += 60/1440;
          else if (ChartInfo().GetOpen(PERIOD_H1, _counter) < ChartInfo().GetClose(PERIOD_H1, _counter + 1)) bear += 60/1440;
        }
      }
      if ((method %   32) == 0)  {
        for (_counter = 0; _counter < 48; _counter++) {
          if (ChartInfo().GetOpen(PERIOD_M30, _counter) > ChartInfo().GetClose(PERIOD_M30, _counter + 1)) bull += 30/1440;
          else if (ChartInfo().GetOpen(PERIOD_M30, _counter) < ChartInfo().GetClose(PERIOD_M30, _counter + 1)) bear += 30/1440;
        }
      }
      if ((method %   64) == 0)  {
        for (_counter = 0; _counter < 96; _counter++) {
          if (ChartInfo().GetOpen(PERIOD_M15, _counter) > ChartInfo().GetClose(PERIOD_M15, _counter + 1)) bull += 15/1440;
          else if (ChartInfo().GetOpen(PERIOD_M15, _counter) < ChartInfo().GetClose(PERIOD_M15, _counter + 1)) bear += 15/1440;
        }
      }
      if ((method %  128) == 0)  {
        for (_counter = 0; _counter < 288; _counter++) {
          if (ChartInfo().GetOpen(PERIOD_M5, _counter) > ChartInfo().GetClose(PERIOD_M5, _counter + 1)) bull += 5/1440;
          else if (ChartInfo().GetOpen(PERIOD_M5, _counter) < ChartInfo().GetClose(PERIOD_M5, _counter + 1)) bear += 5/1440;
        }
      }
    }
    _last_trend = (bull - bear);
    _last_trend_check = ChartInfo().GetBarTime(_tf, 0);
    Logger().Debug(StringFormat("%s: %g", __FUNCTION__, _last_trend));
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
   *     If true, use simple trend calculation.
   *
   * @return
   *   Returns Buy operation for bullish, Sell for bearish, otherwise NULL for neutral market trend.
   */
  ENUM_ORDER_TYPE GetTrendOp(int method, ENUM_TIMEFRAMES _tf = NULL, bool simple = false) {
    double _curr_trend = GetTrend(method, _tf, simple);
    return _curr_trend == 0 ? (ENUM_ORDER_TYPE) (ORDER_TYPE_BUY + ORDER_TYPE_SELL) : (_curr_trend > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
  }

  /* Class access methods */

  /**
   * Returns access to Account class.
   */
  Account *AccountInfo() {
    return trade_params.account;
  }

  /**
   * Returns access to Orders class.
   */
  Orders *Trades() {
    return trade_params.account.Trades();
  }

  /**
   * Return access to Market class.
   */
  Market *MarketInfo() {
    return (Market *) GetPointer(trade_params.chart);
  }

  /**
   * Returns access to the current chart.
   */
  Chart *ChartInfo() {
    return (Chart *) GetPointer(trade_params.chart);
  }

  /**
   * Returns access to Log class.
   */
  Log *Logger() {
    return trade_params.chart.Log();
  }

};

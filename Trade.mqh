//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                            Copyright 2016, 31337 Investments Ltd |
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
class Account;
class Chart;
class Log;
class Market;
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
    return MarketInfo().GetOpenPrice(_cmd)
      + ChartInfo().GetTradeDistanceInValue()
      + Convert::MoneyToValue(AccountInfo().GetRealBalance() / 100 * _risk_margin, _lot_size)
      * -Order::OrderDirection(_cmd);
  }

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
    double lot_size1 = risk_amount / (sl * (ChartInfo().GetTickValue() / 100.0));
    lot_size1 *= ChartInfo().GetMinLot();
    /* // @todo: To test.
    double lot_size2 = 1 / (Market::GetTickValue(symbol) * sl / risk_amount);
    double ticks = fabs(sl - Market::GetOpenPrice(cmd)) / Market::GetTickSize(symbol);
    double lot_size3 = risk_amount / (ticks * Market::GetTickValue(symbol));
    */
    return ChartInfo().NormalizeLots(lot_size1);
  }

  /**
   * Validate TP/SL value for the order.
   */
  bool ValidSLTP(double value, int cmd, int direction = -1, bool existing = false) {
    // Calculate minimum market gap.
    double price = MarketInfo().GetOpenPrice();
    double distance = MarketInfo().GetTradeDistanceInPips();
    bool valid = (
            (cmd == OP_BUY  && direction < 0 && Convert::GetValueDiffInPips(price, value) > distance)
         || (cmd == OP_BUY  && direction > 0 && Convert::GetValueDiffInPips(value, price) > distance)
         || (cmd == OP_SELL && direction < 0 && Convert::GetValueDiffInPips(value, price) > distance)
         || (cmd == OP_SELL && direction > 0 && Convert::GetValueDiffInPips(price, value) > distance)
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

  /**
   * Calculate size of the lot based on the free margin.
   */
  double CalcLotSize(double risk_margin = 1, double risk_ratio = 1.0) {
    return AccountInfo().AccountAvailMargin() / ChartInfo().GetMarginRequired() * risk_margin / 100 * risk_ratio;
  }

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

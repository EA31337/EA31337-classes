//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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
#include "Object.mqh"

/**
 * Trade class
 */
#ifndef TRADE_MQH
#define TRADE_MQH
class Trade {

    // Structs.
    struct TradeParams {
      uint             slippage;   // Value of the maximum price slippage in points.
      Account          *account;   // Pointer to Account class.
      Chart            *chart;     // Pointer to Chart class.
      Log              *logger;    // Pointer to Log class.
      //Market          *market;     // Pointer to Market class.
      //void Init(TradeParams &p) { slippage = p.slippage; account = p.account; chart = p.chart; }
      // Constructor.
      TradeParams() :
        account(new Account),
        chart(new Chart),
        logger(new Log)
      {
      }
      // Deconstructor.
      ~TradeParams() {
        DeleteObjects();
      }
      // Struct methods.
      void DeleteObjects() {
        delete account;
        delete chart;
        delete logger;
      }
    } trade_params;

  public:

  /**
   * Class constructor.
   */
  void Trade() {
  }
  void Trade(ENUM_TIMEFRAMES _tf, string _symbol = NULL) {
  }
  void Trade(TradeParams &_params) {
    trade_params.DeleteObjects();
    trade_params = _params;
  }

  /**
   * Class deconstructor.
   */
  void ~Trade() {
    trade_params.DeleteObjects();
  }

  /**
   * Calculates the margin required for the specified order type.
   *
   * Note: It not taking into account current pending orders and open positions.
   *
   * @return
   *  The function returns true in case of success; otherwise it returns false.
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
     // @fixme: Not implemented yet.
     return false;
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
  double GetMaxLotSize(double _sl, double risk_margin = 1.0, ENUM_ORDER_TYPE _cmd = NULL) {
    _cmd = _cmd == NULL ? Order::OrderType() : _cmd;
    double risk_amount = this.Account().GetRealBalance() / 100 * risk_margin;
    double _ticks = fabs(_sl - this.Market().GetOpenOffer(_cmd)) / this.Market().GetTickSize();
    double lot_size1 = fmin(_sl, _ticks) > 0 ? risk_amount / (_sl * (_ticks / 100.0)) : 1;
    lot_size1 *= this.Market().GetVolumeMin();
    // double lot_size2 = 1 / (this.Market().GetTickValue() * sl / risk_margin);
    // PrintFormat("SL=%g: 1 = %g, 2 = %g", sl, lot_size1, lot_size2);
    return this.Chart().NormalizeLots(lot_size1);
  }
  double GetMaxLotSize(uint _pips, double risk_margin = 1.0, ENUM_ORDER_TYPE _cmd = NULL) {
    return GetMaxLotSize(CalcOrderSLTP(_pips, _cmd, ORDER_SL));
  }

  /**
   * Validate TP/SL value for the order.
   */
  bool ValidSLTP(double value, ENUM_ORDER_TYPE _cmd, int direction = -1, bool existing = false) {
    // Calculate minimum market gap.
    double price = this.Market().GetOpenOffer(_cmd);
    double distance = this.Market().GetTradeDistanceInPips();
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
    /* @fixme: Rewrite without using CDealInfo.
    CDealInfo deal;
    HistorySelect(0, TimeCurrent()); // Select history for access.
    */
    #endif
    int _orders = HistoryTotal();
    for (int i = _orders - 1; i >= fmax(0, _orders - ols_orders); i--) {
      #ifdef __MQL5__
      /* @fixme: Rewrite without using CDealInfo.
      deal.Ticket(HistoryDealGetTicket(i));
      if (deal.Ticket() == 0) {
        Print(__FUNCTION__, ": Error in history!");
        break;
      }
      if (deal.Symbol() != this.Market().GetSymbol()) continue;
      double profit = deal.Profit();
      */
      double profit = 0;
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
    lotsize = twins   > 1 ? lotsize + (lotsize / 100 * win_factor * twins): lotsize;
    lotsize = tlosses > 1 ? lotsize + (lotsize / 100 * loss_factor * tlosses) : lotsize;
    return this.Market().NormalizeLots(lotsize);
  }

  /**
   * Calculate size of the lot based on the free margin or balance.
   */
  double CalcLotSize(
    double _risk_margin = 1,  // Risk margin in %.
    double _risk_ratio = 1.0, // Risk ratio factor.
    uint   _method = 0        // Method of calculation (0-3).
    ) {

    double _lot_size = this.Market().GetVolumeMin();
    double _avail_amount = _method % 2 == 0 ? this.Account().GetMarginAvail() : this.Account().GetRealBalance();
    if (_method == 0 || _method == 1) {
      _lot_size = this.Market().NormalizeLots(
        _avail_amount / fmax(0.00001, this.Chart().GetMarginRequired() * _risk_ratio) / 100 * _risk_ratio
      );
    } else {
      double _risk_amount = _avail_amount / 100 * _risk_margin;
      double _risk_value = Convert::MoneyToValue(_risk_amount, this.Market().GetVolumeMin(), this.Market().GetSymbol());
      double _tick_value = this.Market().GetTickSize();
      _lot_size = this.Market().NormalizeLots(_risk_value * _tick_value * _risk_ratio);
    }
    return _lot_size;
  }

  /* Orders methods */

  /**
   * Calculate available lot size given the risk margin.
   */
  uint CalcMaxLotSize(double risk_margin = 1.0) {
    double _avail_margin = this.Account().AccountAvailMargin();
    double _opened_lots = Trades().GetOpenLots();
    // @todo
    return 0;
  }

  /**
   * Calculate number of allowed orders to open.
   */
  uint CalcMaxOrders(double volume_size, double _risk_ratio = 1.0, uint prev_max_orders = 0, uint hard_limit = 0, bool smooth = true) {
    double _avail_margin = fmin(this.Account().GetMarginFree(), this.Account().GetBalance() + this.Account().GetCredit());
    double _margin_required = this.Market().GetMarginRequired();
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
    double GetMaxSLTP(double _risk_margin = 1.0, ENUM_ORDER_TYPE _cmd = NULL, double _lot_size = 0, ENUM_ORDER_PROPERTY_DOUBLE _mode = ORDER_SL) {
      double _price = _cmd == NULL ? Order::OrderOpenPrice() : this.Market().GetOpenOffer(_cmd);
      // For the new orders, use the available margin for calculation, otherwise use the account balance.
      double _margin = Convert::MoneyToValue((_cmd == NULL ? this.Account().GetMarginAvail() : this.Account().GetRealBalance()) / 100 * _risk_margin, _lot_size, this.Market().GetSymbol());
      _cmd = _cmd == NULL ? Order::OrderType() : _cmd;
      _lot_size = _lot_size <= 0 ? fmax(Order::OrderLots(), this.Market().GetVolumeMin()) : _lot_size;
      return _price
        + this.Chart().GetTradeDistanceInValue()
        // + Convert::MoneyToValue(AccountInfo().GetRealBalance() / 100 * _risk_margin, _lot_size)
        // + Convert::MoneyToValue(AccountInfo().GetMarginAvail() / 100 * _risk_margin, _lot_size)
        + _margin
        * Order::OrderDirection(_cmd, _mode);
    }
    double GetMaxSL(double _risk_margin = 1.0, ENUM_ORDER_TYPE _cmd = NULL, double _lot_size = 0) {
      return GetMaxSLTP(_risk_margin, _cmd, _lot_size, ORDER_SL);
    }
    double GetMaxTP(double _risk_margin = 1.0, ENUM_ORDER_TYPE _cmd = NULL, double _lot_size = 0) {
      return GetMaxSLTP(_risk_margin, _cmd, _lot_size, ORDER_TP);
    }

    /**
     * Returns value of stop loss for the new order given the pips value.
     */
    double CalcOrderSLTP(
      double _value,                    // Value in pips.
      ENUM_ORDER_TYPE _cmd,             // Order type (e.g. buy or sell).
      ENUM_ORDER_PROPERTY_DOUBLE _mode  // Type of value (stop loss or take profit).
    ) {
      double _price = _cmd == NULL ? Order::OrderOpenPrice() : this.Market().GetOpenOffer(_cmd);
      _cmd = _cmd == NULL ? Order::OrderType() : _cmd;
      // PrintFormat("#%d: %s/%s: %g (%g/%g) + %g * %g * %g = %g", Order::OrderTicket(), EnumToString(_cmd), EnumToString(_mode), _price, Bid, Ask, _value, this.Market().GetPipSize(), Order::OrderDirection(_cmd, _mode), this.Market().GetOpenOffer(_cmd) + _value * this.Market().GetPipSize() * Order::OrderDirection(_cmd, _mode));
      return _value > 0 ? _price + _value * this.Market().GetPipSize() * Order::OrderDirection(_cmd, _mode) : 0;
    }
    double CalcOrderSL(double _value, ENUM_ORDER_TYPE _cmd = NULL) {
      return CalcOrderSLTP(_value, _cmd, ORDER_SL);
    }
    double CalcOrderTP(double _value, ENUM_ORDER_TYPE _cmd = NULL) {
      return CalcOrderSLTP(_value, _cmd, ORDER_TP);
    }

    /**
     * Returns safer SL/TP based on the two SL or TP input values.
     */
    double GetSaferSLTP(double _value1, double _value2, ENUM_ORDER_TYPE _cmd, ENUM_ORDER_PROPERTY_DOUBLE _mode) {
      if (_value1 <= 0 || _value2 <= 0) {
        return this.Market().NormalizeSLTP(fmax(_value1, _value2), _cmd, _mode);
      }
      switch (_cmd) {
        case ORDER_TYPE_BUY_LIMIT:
        case ORDER_TYPE_BUY:
          switch (_mode) {
            case ORDER_SL: return this.Market().NormalizeSLTP(_value1 > _value2 ? _value1 : _value2, _cmd, _mode);
            case ORDER_TP: return this.Market().NormalizeSLTP(_value1 < _value2 ? _value1 : _value2, _cmd, _mode);
            default: Logger().Error(StringFormat("Invalid mode: %s!", EnumToString(_mode), __FUNCTION__));
          }
          break;
        case ORDER_TYPE_SELL_LIMIT:
        case ORDER_TYPE_SELL:
          switch (_mode) {
            case ORDER_SL: return this.Market().NormalizeSLTP(_value1 < _value2 ? _value1 : _value2, _cmd, _mode);
            case ORDER_TP: return this.Market().NormalizeSLTP(_value1 > _value2 ? _value1 : _value2, _cmd, _mode);
            default: Logger().Error(StringFormat("Invalid mode: %s!", EnumToString(_mode), __FUNCTION__));
          }
          break;
        default: Logger().Error(StringFormat("Invalid order type: %s!", EnumToString(_cmd), __FUNCTION__));
      }
      return EMPTY_VALUE;
    }
    double GetSaferSLTP(double _value1, double _value2, double _value3, ENUM_ORDER_TYPE _cmd, ENUM_ORDER_PROPERTY_DOUBLE _mode) {
      return GetSaferSLTP(GetSaferSLTP(_value1, _value2, _cmd, _mode), _value3, _cmd, _mode);
    }
    double GetSaferSL(double _value1, double _value2, ENUM_ORDER_TYPE _cmd) {
      return GetSaferSLTP(_value1, _value2, _cmd, ORDER_SL);
    }
    double GetSaferSL(double _value1, double _value2, double _value3, ENUM_ORDER_TYPE _cmd) {
      return GetSaferSLTP(GetSaferSLTP(_value1, _value2, _cmd, ORDER_SL), _value3, _cmd, ORDER_SL);
    }
    double GetSaferTP(double _value1, double _value2, ENUM_ORDER_TYPE _cmd) {
      return GetSaferSLTP(_value1, _value2, _cmd, ORDER_TP);
    }
    double GetSaferTP(double _value1, double _value2, double _value3, ENUM_ORDER_TYPE _cmd) {
      return GetSaferSLTP(GetSaferSLTP(_value1, _value2, _cmd, ORDER_TP), _value3, _cmd, ORDER_TP);
    }

    /**
     * Calculates the best SL/TP value for the order given the limits.
     */
    double CalcBestSLTP(
      double _value,                      // Suggested value.
      double _max_pips,                   // Maximal amount of pips.
      double _max_order_risk,             // Maximal risk in balance percentage.
      ENUM_ORDER_PROPERTY_DOUBLE _mode,   // Type of value (stop loss or take profit).
      ENUM_ORDER_TYPE _cmd = NULL,        // Order type (e.g. buy or sell).
      double _lot_size = 0                // Lot size of the order.
    ) {
      double _max_value1 = _max_pips > 0 ? CalcOrderSLTP(_max_pips, _cmd, _mode) : 0;
      double _max_value2 = _max_order_risk > 0 ? GetMaxSLTP(_max_order_risk, _cmd, _lot_size, _mode) : 0;
      double _res = this.Market().NormalizePrice(GetSaferSLTP(_value, _max_value1, _max_value2, _cmd, _mode));
      // PrintFormat("%s/%s: Value: %g", EnumToString(_cmd), EnumToString(_mode), _value);
      // PrintFormat("%s/%s: Max value 1: %g", EnumToString(_cmd), EnumToString(_mode), _max_value1);
      // PrintFormat("%s/%s: Max value 2: %g", EnumToString(_cmd), EnumToString(_mode), _max_value2);
      // PrintFormat("%s/%s: Result: %g", EnumToString(_cmd), EnumToString(_mode), _res);
      return _res;
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
    string symbol = this.Market().GetSymbol();
    if (_last_trend_check == this.Chart().GetBarTime(_tf)) {
      return _last_trend;
    }
    double bull = 0, bear = 0;
    int _counter = 0;

    if (simple && method != 0) {
      if ((method &   1) != 0)  {
        if (this.Chart().GetOpen(PERIOD_MN1, 0) > this.Chart().GetClose(PERIOD_MN1, 1)) bull++;
        if (this.Chart().GetOpen(PERIOD_MN1, 0) < this.Chart().GetClose(PERIOD_MN1, 1)) bear++;
      }
      if ((method &   2) != 0)  {
        if (this.Chart().GetOpen(PERIOD_W1, 0) > this.Chart().GetClose(PERIOD_W1, 1)) bull++;
        if (this.Chart().GetOpen(PERIOD_W1, 0) < this.Chart().GetClose(PERIOD_W1, 1)) bear++;
      }
      if ((method &   4) != 0)  {
        if (this.Chart().GetOpen(PERIOD_D1, 0) > this.Chart().GetClose(PERIOD_D1, 1)) bull++;
        if (this.Chart().GetOpen(PERIOD_D1, 0) < this.Chart().GetClose(PERIOD_D1, 1)) bear++;
      }
      if ((method &   8) != 0)  {
        if (this.Chart().GetOpen(PERIOD_H4, 0) > this.Chart().GetClose(PERIOD_H4, 1)) bull++;
        if (this.Chart().GetOpen(PERIOD_H4, 0) < this.Chart().GetClose(PERIOD_H4, 1)) bear++;
      }
      if ((method &   16) != 0)  {
        if (this.Chart().GetOpen(PERIOD_H1, 0) > this.Chart().GetClose(PERIOD_H1, 1)) bull++;
        if (this.Chart().GetOpen(PERIOD_H1, 0) < this.Chart().GetClose(PERIOD_H1, 1)) bear++;
      }
      if ((method &   32) != 0)  {
        if (this.Chart().GetOpen(PERIOD_M30, 0) > this.Chart().GetClose(PERIOD_M30, 1)) bull++;
        if (this.Chart().GetOpen(PERIOD_M30, 0) < this.Chart().GetClose(PERIOD_M30, 1)) bear++;
      }
      if ((method &   64) != 0)  {
        if (this.Chart().GetOpen(PERIOD_M15, 0) > this.Chart().GetClose(PERIOD_M15, 1)) bull++;
        if (this.Chart().GetOpen(PERIOD_M15, 0) < this.Chart().GetClose(PERIOD_M15, 1)) bear++;
      }
      if ((method &  128) != 0)  {
        if (this.Chart().GetOpen(PERIOD_M5, 0) > this.Chart().GetClose(PERIOD_M5, 1)) bull++;
        if (this.Chart().GetOpen(PERIOD_M5, 0) < this.Chart().GetClose(PERIOD_M5, 1)) bear++;
      }
      //if (this.Chart().GetOpen(PERIOD_H12, 0) > this.Chart().GetClose(PERIOD_H12, 1)) bull++;
      //if (this.Chart().GetOpen(PERIOD_H12, 0) < this.Chart().GetClose(PERIOD_H12, 1)) bear++;
      //if (this.Chart().GetOpen(PERIOD_H8, 0) > this.Chart().GetClose(PERIOD_H8, 1)) bull++;
      //if (this.Chart().GetOpen(PERIOD_H8, 0) < this.Chart().GetClose(PERIOD_H8, 1)) bear++;
      //if (this.Chart().GetOpen(PERIOD_H6, 0) > this.Chart().GetClose(PERIOD_H6, 1)) bull++;
      //if (this.Chart().GetOpen(PERIOD_H6, 0) < this.Chart().GetClose(PERIOD_H6, 1)) bear++;
      //if (this.Chart().GetOpen(PERIOD_H2, 0) > this.Chart().GetClose(PERIOD_H2, 1)) bull++;
      //if (this.Chart().GetOpen(PERIOD_H2, 0) < this.Chart().GetClose(PERIOD_H2, 1)) bear++;
    } else if (method != 0) {
      if ((method %   1) == 0)  {
        for (_counter = 0; _counter < 3; _counter++) {
          if (this.Chart().GetOpen(PERIOD_MN1, _counter) > this.Chart().GetClose(PERIOD_MN1, _counter + 1)) bull += 30;
          else if (this.Chart().GetOpen(PERIOD_MN1, _counter) < this.Chart().GetClose(PERIOD_MN1, _counter + 1)) bear += 30;
        }
      }
      if ((method %   2) == 0)  {
        for (_counter = 0; _counter < 8; _counter++) {
          if (this.Chart().GetOpen(PERIOD_W1, _counter) > this.Chart().GetClose(PERIOD_W1, _counter + 1)) bull += 7;
          else if (this.Chart().GetOpen(PERIOD_W1, _counter) < this.Chart().GetClose(PERIOD_W1, _counter + 1)) bear += 7;
        }
      }
      if ((method %   4) == 0)  {
        for (_counter = 0; _counter < 7; _counter++) {
          if (this.Chart().GetOpen(PERIOD_D1, _counter) > this.Chart().GetClose(PERIOD_D1, _counter + 1)) bull += 1440/1440;
          else if (this.Chart().GetOpen(PERIOD_D1, _counter) < this.Chart().GetClose(PERIOD_D1, _counter + 1)) bear += 1440/1440;
        }
      }
      if ((method %   8) == 0)  {
        for (_counter = 0; _counter < 24; _counter++) {
          if (this.Chart().GetOpen(PERIOD_H4, _counter) > this.Chart().GetClose(PERIOD_H4, _counter + 1)) bull += 240/1440;
          else if (this.Chart().GetOpen(PERIOD_H4, _counter) < this.Chart().GetClose(PERIOD_H4, _counter + 1)) bear += 240/1440;
        }
      }
      if ((method %   16) == 0)  {
        for (_counter = 0; _counter < 24; _counter++) {
          if (this.Chart().GetOpen(PERIOD_H1, _counter) > this.Chart().GetClose(PERIOD_H1, _counter + 1)) bull += 60/1440;
          else if (this.Chart().GetOpen(PERIOD_H1, _counter) < this.Chart().GetClose(PERIOD_H1, _counter + 1)) bear += 60/1440;
        }
      }
      if ((method %   32) == 0)  {
        for (_counter = 0; _counter < 48; _counter++) {
          if (this.Chart().GetOpen(PERIOD_M30, _counter) > this.Chart().GetClose(PERIOD_M30, _counter + 1)) bull += 30/1440;
          else if (this.Chart().GetOpen(PERIOD_M30, _counter) < this.Chart().GetClose(PERIOD_M30, _counter + 1)) bear += 30/1440;
        }
      }
      if ((method %   64) == 0)  {
        for (_counter = 0; _counter < 96; _counter++) {
          if (this.Chart().GetOpen(PERIOD_M15, _counter) > this.Chart().GetClose(PERIOD_M15, _counter + 1)) bull += 15/1440;
          else if (this.Chart().GetOpen(PERIOD_M15, _counter) < this.Chart().GetClose(PERIOD_M15, _counter + 1)) bear += 15/1440;
        }
      }
      if ((method %  128) == 0)  {
        for (_counter = 0; _counter < 288; _counter++) {
          if (this.Chart().GetOpen(PERIOD_M5, _counter) > this.Chart().GetClose(PERIOD_M5, _counter + 1)) bull += 5/1440;
          else if (this.Chart().GetOpen(PERIOD_M5, _counter) < this.Chart().GetClose(PERIOD_M5, _counter + 1)) bear += 5/1440;
        }
      }
    }
    _last_trend = (bull - bear);
    _last_trend_check = this.Chart().GetBarTime(_tf, 0);
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

  /* State checkers */

  /**
   * Checks if trading is allowed for the current terminal, account and running program.
   */
  bool IsTradeAllowed() {
    return this.Terminal().CheckPermissionToTrade() && this.Account().IsExpertEnabled() && this.Account().IsTradeAllowed();
  }

  /* Class handlers */

  /**
   * Returns access to Account class.
   */
  Account *Account() {
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
  Market *Market() {
    return (Market *) GetPointer(trade_params.chart);
  }

  /**
   * Returns access to the current chart.
   */
  Chart *Chart() {
    return (Chart *) GetPointer(trade_params.chart);
  }

  /**
   * Returns access to the current terminal.
   */
  Terminal *Terminal() {
    return (Terminal *) GetPointer(trade_params.chart);
  }

  /**
   * Returns access to Log class.
   */
  Log *Logger() {
    return trade_params.logger;
  }

};
#endif

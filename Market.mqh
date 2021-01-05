//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
#ifndef MARKET_MQH
#define MARKET_MQH

// Forward declaration.
class Market;
class SymbolInfo;

// Includes.
#include "Condition.enum.h"
#include "Math.h"
#include "Order.mqh"
#include "SymbolInfo.mqh"

// Structs.
// Market info.
struct MarketData {
  double pip_value;          // Pip value.
  unsigned int pip_digits;   // Pip digits (precision).
  unsigned int pts_per_pip;  // Points per pip.
  unsigned int vol_digits;   // Volume digits.
};

#ifndef __MQL4__
// Defines macros (for MQL4 backward compatibility).
double MarketInfo(string _symbol, int _type) { return Market::MarketInfo(_symbol, _type); }
#endif

/**
 * Class to provide market information.
 */
class Market : public SymbolInfo {
 protected:
  // Struct variables.
  MarketData minfo;

 public:
  /**
   * Implements class constructor with a parameter.
   */
  Market(string _symbol = NULL, Log *_log = NULL) : SymbolInfo(_symbol, Object::IsValid(_log) ? _log : new Log) {
    // @todo: Test symbol with SymbolExists(_symbol)
    minfo.pip_digits = GetPipDigits(_symbol);
    minfo.pip_value = GetPipValue(_symbol);
    minfo.pts_per_pip = GetPointsPerPip(_symbol);
    minfo.vol_digits = GetVolumeDigits(_symbol);
  }

  /**
   * Class deconstructor.
   */
  ~Market() {}

  /* Getters */

  /**
   * Get pip precision.
   */
  static unsigned int GetPipDigits(string _symbol) { return GetDigits(_symbol) < 4 ? 2 : 4; }
  unsigned int GetPipDigits() { return minfo.pip_digits; }

  /**
   * Get pip value.
   */
  static double GetPipValue(string _symbol) {
    unsigned int _pdigits = GetPipDigits(_symbol);
    return 10 >> _pdigits;
  }
  double GetPipValue() { return minfo.pip_value; }

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
  static unsigned int GetSpreadInPts(string _symbol) { return GetSpread(_symbol); }
  unsigned int GetSpreadInPts() { return GetSpread(); }

  /**
   * Get current spread in float.
   */
  double GetSpreadInPips() { return (GetAsk() - GetBid()) * pow(10, GetPipDigits()); }

  /**
   * Get current spread in percent.
   */
  static double GetSpreadInPct(string _symbol) { return 100.0 * (GetAsk(_symbol) - GetBid(_symbol)) / GetAsk(_symbol); }
  double GetSpreadInPct() { return GetSpreadInPct(symbol); }

  /**
   * Get number of points per pip.
   *
   * To be used to replace Point for trade parameters calculations.
   * See: http://forum.mql4.com/30672
   */
  static unsigned int GetPointsPerPip(string _symbol) {
    return (unsigned int)pow(10, GetDigits(_symbol) - GetPipDigits(_symbol));
  }
  unsigned int GetPointsPerPip() { return minfo.pts_per_pip; }

  /**
   * Get a market distance in points.
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
  static long GetTradeDistanceInPts(string _symbol) {
    return fmax(GetTradeStopsLevel(_symbol), GetFreezeLevel(_symbol));
  }
  long GetTradeDistanceInPts() { return GetTradeDistanceInPts(symbol); }

  /**
   * Get a market distance in pips.
   *
   * Minimal permissible distance value in pips for StopLoss/TakeProfit.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  static double GetTradeDistanceInPips(string _symbol) {
    unsigned int _pts_per_pip = GetPointsPerPip(_symbol);
    return (double)(_pts_per_pip > 0 ? (GetTradeDistanceInPts(_symbol) / _pts_per_pip) : 0);
  }
  double GetTradeDistanceInPips() { return GetTradeDistanceInPips(symbol); }

  /**
   * Get a market gap in value.
   *
   * Minimal permissible distance value in value for StopLoss/TakeProfit.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  static double GetTradeDistanceInValue(string _symbol) {
    return GetTradeDistanceInPts(_symbol) * GetPointSize(_symbol);
  }
  double GetTradeDistanceInValue() { return GetTradeDistanceInValue(symbol); }

  /**
   * Get a volume precision.
   */
  static unsigned int GetVolumeDigits(string _symbol) {
    return (unsigned int)-log10(fmin(GetVolumeStep(_symbol), GetVolumeMin(_symbol)));
  }
  unsigned int GetVolumeDigits() { return minfo.vol_digits; }

  /* Functional methods */

  /**
   * Refresh data in pre-defined variables and series arrays.
   *
   * @see http://docs.mql4.com/series/refreshrates
   */
  static bool RefreshRates() {
// In MQL5 returns true for backward compatibility.
#ifdef __MQL4__
    return ::RefreshRates();
#else
    return true;
#endif
  }

  /**
   * Returns market data about securities.
   *
   * @docs
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   */
  static double MarketInfo(string _symbol, int _type) {
    switch (_type) {
      case MODE_LOW:
        // Low day price.
        return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_LASTLOW);
      case MODE_HIGH:
        // High day price.
        return SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_LASTHIGH);
      case MODE_TIME:
        // Time of the last quote.
        return (double)GetQuoteTime(_symbol);
      case MODE_BID:
        // Last incoming bid price.
        return GetBid(_symbol);
      case MODE_ASK:
        // Last incoming ask price.
        return GetAsk(_symbol);
      case MODE_POINT:
        // Point size in the quote currency.
        return GetPointSize(_symbol);
      case MODE_DIGITS:
        // Symbol digits after decimal point.
        return GetDigits(_symbol);
      case MODE_SPREAD:
        // Spread value in points.
        return GetSpreadInPts(_symbol);
      case MODE_STOPLEVEL:
        // Stop level in points.
        return (double)GetTradeStopsLevel(_symbol);
      case MODE_LOTSIZE:
        // Lot size in the base currency.
        return GetTradeContractSize(_symbol);
      case MODE_TICKVALUE:
        // Tick value in the deposit currency.
        return GetTickValue(_symbol);
      case MODE_TICKSIZE:
        // Tick size in points.
        return GetTickSize(_symbol);
      case MODE_SWAPLONG:
        // Swap of the buy order.
        return GetSwapLong(_symbol);
      case MODE_SWAPSHORT:
        // Swap of the sell order.
        return GetSwapShort(_symbol);
      case MODE_LOTSTEP:
        // Step for changing lots.
        return GetVolumeStep(_symbol);
      case MODE_MINLOT:
        // Minimum permitted amount of a lot.
        return GetVolumeMin(_symbol);
      case MODE_MAXLOT:
        // Maximum permitted amount of a lot.
        return GetVolumeMax(_symbol);
      case MODE_SWAPTYPE:
        // Swap calculation method.
        return (double)GetSwapMode(_symbol);
      case MODE_PROFITCALCMODE:
        // Profit calculation mode.
        return (double)SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_TRADE_CALC_MODE);
      case MODE_STARTING:
        // @todo: Market starting date.
        return (0);
      case MODE_EXPIRATION:
        // @todo: Market expiration date.
        return (0);
      case MODE_TRADEALLOWED:
        // Trade is allowed for the symbol.
        return Terminal::IsTradeAllowed();
      case MODE_MARGINCALCMODE:
        // @todo: Margin calculation mode.
        return (0);
      case MODE_MARGININIT:
        // Initial margin requirements for 1 lot.
        return GetMarginInit(_symbol);
      case MODE_MARGINMAINTENANCE:
        // Margin to maintain open orders calculated for 1 lot.
        return GetMarginMaintenance(_symbol);
      case MODE_MARGINHEDGED:
        // @todo: Hedged margin calculated for 1 lot.
        return (0);
      case MODE_MARGINREQUIRED:
        // @todo: Free margin required to open 1 lot for buying.
        return (0);
      case MODE_FREEZELEVEL:
        // Order freeze level in points.
        return GetFreezeLevel(_symbol);
    }
    return (-1);
  }
  double MarketInfo(int _type) { return MarketInfo(symbol, _type); }

  /**
   * Get delta value per lot in account currency of a point of symbol.
   *
   * @see
   * - https://forum.mql4.com/33975
   * - https://forum.mql4.com/43064#515262
   * - https://forum.mql4.com/41259/page3#512466
   * - https://www.mql5.com/en/forum/127584
   * - https://www.mql5.com/en/forum/135345
   * - https://www.mql5.com/en/forum/133792/page3#512466
   */
  static double GetDeltaValue(string _symbol) {
    // Return tick value in the deposit currency divided by tick size in points.
    return GetTickValue(_symbol) / GetTickSize(_symbol);
  }
  double GetDeltaValue() { return GetDeltaValue(symbol); }

  /**
   * Returns the last price change in pips.
   */
  double GetLastPriceChangeInPips() {
    return fmax(fabs(GetLastAsk() - GetAsk()), fabs(GetLastBid() - GetBid())) * pow(10, GetPipDigits());
  }

  /* END: Getters */

  /* Normalization methods */

  /**
   * Normalize price value.
   *
   * Make sure that the price is a multiple of ticksize.
   */
  static double NormalizePrice(string _symbol, double p) {
    // See: http://forum.mql4.com/47988
    // http://forum.mql4.com/43064#515262 zzuegg reports for non-currency DE30:
    // - MarketInfo(chart.symbol,MODE_TICKSIZE) returns 0.5
    // - MarketInfo(chart.symbol,MODE_DIGITS) return 1
    // - Point = 0.1
    // Rare fix when a change in tick size leads to a change in tick value.
    return round(p / GetPointSize(_symbol)) * GetTickSize(_symbol);
  }
  double NormalizePrice(double p) { return NormalizePrice(symbol, p); }

  /**
   * Normalize lot size.
   */
  double NormalizeLots(double _lots, bool _ceil = false) {
    double _lot_size = _lots;
    double _vol_step = GetVolumeStep() > 0.0 ? GetVolumeStep() : GetVolumeMin();
    if (_vol_step > 0) {
      // Related: http://forum.mql4.com/47988
      double _precision = 1 / _vol_step;
      // Edge case when step is higher than minimum.
      _lot_size = _ceil ? ceil(_lots * _precision) / _precision : floor(_lots * _precision) / _precision;
      double _min_lot = fmax(GetVolumeMin(), GetVolumeStep());
      _lot_size = fmin(fmax(_lot_size, _min_lot), GetVolumeMax());
    }
    return _lot_size;
  }

  /**
   * Normalize SL/TP values.
   */
  double NormalizeSLTP(double _value, ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode) {
    switch (_cmd) {
      // Buying is done at the Ask price.
      // The TakeProfit and StopLoss levels must be at the distance
      // of at least SYMBOL_TRADE_STOPS_LEVEL points from the Bid price.
      case ORDER_TYPE_BUY:
        switch (_mode) {
          // Bid - StopLoss >= SYMBOL_TRADE_STOPS_LEVEL (minimum trade distance)
          case ORDER_TYPE_SL:
            return fmin(_value, GetBid() - GetTradeDistanceInValue());
          // TakeProfit - Bid >= SYMBOL_TRADE_STOPS_LEVEL (minimum trade distance)
          case ORDER_TYPE_TP:
            return fmax(_value, GetBid() + GetTradeDistanceInValue());
          default:
            Logger().Error(StringFormat("Invalid mode: %s!", EnumToString(_mode), __FUNCTION__));
        }
        break;
      // Selling is done at the Bid price.
      // The TakeProfit and StopLoss levels must be at the distance
      // of at least SYMBOL_TRADE_STOPS_LEVEL points from the Ask price.
      case ORDER_TYPE_SELL:
        switch (_mode) {
          // StopLoss - Ask >= SYMBOL_TRADE_STOPS_LEVEL (minimum trade distance)
          case ORDER_TYPE_SL:
            return fmax(_value, GetAsk() + GetTradeDistanceInValue());
          // Ask - TakeProfit >= SYMBOL_TRADE_STOPS_LEVEL (minimum trade distance)
          case ORDER_TYPE_TP:
            return fmin(_value, GetAsk() - GetTradeDistanceInValue());
          default:
            Logger().Error(StringFormat("Invalid mode: %s!", EnumToString(_mode), __FUNCTION__));
        }
        break;
      default:
        Logger().Error(StringFormat("Invalid order type: %s!", EnumToString(_cmd), __FUNCTION__));
    }
    return NULL;
  }
  double NormalizeSL(double _value, ENUM_ORDER_TYPE _cmd) {
    return NormalizePrice(NormalizeSLTP(_value, _cmd, ORDER_TYPE_SL));
  }
  double NormalizeTP(double _value, ENUM_ORDER_TYPE _cmd) {
    return NormalizePrice(NormalizeSLTP(_value, _cmd, ORDER_TYPE_TP));
  }

  /* Market state checking */

  /**
   * Check whether given symbol exists.
   */
  static bool SymbolExists(string _symbol = NULL) {
    ResetLastError();
    GetAsk(_symbol);
    return GetLastError() != ERR_MARKET_UNKNOWN_SYMBOL;
  }

  /* Printer methods */

  /**
   * Returns Market data in textual representation.
   */
  string ToString() {
    return StringFormat("Pip digits/value: %d/%g, Spread: %d pts (%g pips; %.4f%%), Pts/pip: %d, " +
                            "Trade distance: %g (%d pts; %.1f pips), Volume digits: %d, " +
                            "Delta: %g, Last change: %g pips",
                        GetPipDigits(), GetPipValue(), GetSpreadInPts(), GetSpreadInPips(), GetSpreadInPct(),
                        GetPointsPerPip(), GetTradeDistanceInValue(), GetTradeDistanceInPts(), GetTradeDistanceInPips(),
                        GetVolumeDigits(), GetDeltaValue(), GetLastPriceChangeInPips());
  }

  /**
   * Returns Market data in CSV format.
   */
  string ToCSV(bool _header = false) {
    return !_header ? StringFormat("%d,%g,%d,%g,%.4f,%d," + "%g,%d,%.1f,%d," + "%g,%g", GetPipDigits(), GetPipValue(),
                                   GetSpreadInPts(), GetSpreadInPips(), GetSpreadInPct(), GetPointsPerPip(),
                                   GetTradeDistanceInValue(), GetTradeDistanceInPts(), GetTradeDistanceInPips(),
                                   GetVolumeDigits(), GetDeltaValue(), GetLastPriceChangeInPips())
                    : "Pip Digits,Pip Value,Spread,Pts/pip," +
                          "Trade Distance (value),Trade Distance (points),Trade Distance (pips), Volume digits," +
                          "Delta,Last change (pips)";
  }

  /* Other methods */

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
   *   Returns true when trade operation is allowed.
   *
   * @see: https://book.mql4.com/appendix/limits
   * @see: https://www.mql5.com/en/articles/2555#invalid_SL_TP_for_position
   */
  double TradeOpAllowed(ENUM_ORDER_TYPE _cmd, double sl, double tp) {
    double ask = GetAsk();
    double bid = GetBid();
    double openprice = GetOpenOffer(_cmd);
    double closeprice = GetCloseOffer(_cmd);
    // The minimum distance of SYMBOL_TRADE_STOPS_LEVEL taken into account.
    double distance = GetTradeDistanceInValue();
    // bool result;
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Buying is done at the Ask price.
        // Requirements for Minimum Distance Limitation:
        // - Bid - StopLoss >= StopLevel  && TakeProfit - Bid >= StopLevel
        // - Bid - StopLoss > FreezeLevel && TakeProfit - Bid > FreezeLevel
        /*
        result = sl > 0 && tp > 0 && bid - sl >= distance && tp - bid >= distance;
        PrintFormat("1. Buy: (%g - %g) = %g >= %g; %s", Bid, sl, (bid - sl), distance, result ? "true" : "false");
        PrintFormat("2. Buy: (%g - %g) = %g >= %g; %s", tp, Bid, (tp - Bid), distance, result ? "true" : "false");
        */
        // The TakeProfit and StopLoss levels must be at the distance of at least SYMBOL_TRADE_STOPS_LEVEL points from
        // the Bid price.
        return sl > 0 && tp > 0 && bid - sl >= distance && tp - bid >= distance;
      case ORDER_TYPE_SELL:
        // Selling is done at the Bid price.
        // Requirements for Minimum Distance Limitation:
        // - StopLoss - Ask >= StopLevel  && Ask - TakeProfit >= StopLevel
        // - StopLoss - Ask > FreezeLevel && Ask - TakeProfit > FreezeLevel
        /*
        result = sl > 0 && tp > 0 && sl - ask > distance && ask - tp > distance;
        PrintFormat("1. Sell: (%g - %g) = %g >= %g; %s",
          sl, Ask, (sl - Ask), distance, result ? "true" : "false");
        PrintFormat("2. Sell: (%g - %g) = %g >= %g; %s",
          Ask, tp, (ask - tp), distance, result ? "true" : "false");
        */
        // The TakeProfit and StopLoss levels must be at the distance of at least SYMBOL_TRADE_STOPS_LEVEL points from
        // the Ask price.
        return sl > 0 && tp > 0 && sl - ask > distance && ask - tp > distance;
      case ORDER_TYPE_BUY_LIMIT:
        // Requirements when performing trade operations:
        // - Ask-OpenPrice >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
        // - Open Price of a Pending Order is Below the current Ask price.
        // - Ask price reaches open price.
        return ask - openprice >= distance && openprice - sl >= distance && tp - openprice >= distance;
      case ORDER_TYPE_SELL_LIMIT:
        // Requirements when performing trade operations:
        // - OpenPrice-Bid >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
        // - Open Price of a Pending Order is Above the current Bid price.
        // - Bid price reaches open price.
        return openprice - bid >= distance && sl - openprice >= distance && openprice - tp >= distance;
      case ORDER_TYPE_BUY_STOP:
        // Requirements when performing trade operations:
        // - OpenPrice-Ask >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
        // - Open Price of a Pending Order is Above the current Ask price.
        // - Ask price reaches open price.
        return openprice - ask >= distance && openprice - sl >= distance && tp - openprice >= distance;
      case ORDER_TYPE_SELL_STOP:
        // Requirements when performing trade operations:
        // - Bid-OpenPrice >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
        // - Open Price of a Pending Order is Below the current Bid price.
        // - Bid price reaches open price.
        return bid - openprice >= distance && sl - openprice >= distance && openprice - tp >= distance;
      default:
        return (true);
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
   *   Returns true when trade operation is allowed.
   *
   * @see: https://book.mql4.com/appendix/limits
   */
  double TradeOpAllowed(ENUM_ORDER_TYPE _cmd, double price) {
    double distance = GetTradeDistanceInValue();
    // bool result;
    switch (_cmd) {
      case ORDER_TYPE_BUY_STOP:
        // OpenPrice-Ask >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
      case ORDER_TYPE_BUY_LIMIT:
        // Ask-OpenPrice >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
      case ORDER_TYPE_BUY:
        // Bid-OpenPrice >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
      case ORDER_TYPE_SELL_LIMIT:
        // OpenPrice-Bid >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
      case ORDER_TYPE_SELL_STOP:
        // Bid-OpenPrice >= StopLevel && SL-OpenPrice >= StopLevel && OpenPrice-TP >= StopLevel
      case ORDER_TYPE_SELL:
        // SL-Ask >= StopLevel && Ask-TP >= StopLevel
        // OpenPrice-Ask >= StopLevel && OpenPrice-SL >= StopLevel && TP-OpenPrice >= StopLevel
        // PrintFormat("%g > %g", fmin(fabs(GetBid() - price), fabs(GetAsk() - price)), distance);
        return price > 0 && fmin(fabs(GetBid() - price), fabs(GetAsk() - price)) > distance;
      default:
        return (true);
    }
  }

  /* Conditions */

  /**
   * Checks for market condition.
   *
   * @param ENUM_MARKET_CONDITION _cond
   *   Market condition.
   * @param MqlParam[] _args
   *   Condition arguments.
   * @return
   *   Returns true when the condition is met.
   */
  bool CheckCondition(ENUM_MARKET_CONDITION _cond, IndiParamEntry &_args[]) {
    switch (_cond) {
      case MARKET_COND_IN_PEAK_HOURS:
        return DateTime::Hour() >= 8 && DateTime::Hour() <= 16;
      case MARKET_COND_SPREAD_LE_10:
        return GetSpreadInPts() <= 10;
      case MARKET_COND_SPREAD_GT_10:
        return GetSpreadInPts() > 10;
      case MARKET_COND_SPREAD_GT_20:
        return GetSpreadInPts() > 20;
      default:
        Logger().Error(StringFormat("Invalid market condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }
  bool CheckCondition(ENUM_MARKET_CONDITION _cond) {
    IndiParamEntry _args[] = {};
    return Market::CheckCondition(_cond, _args);
  }
};
#endif  // MARKET_MQH

//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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
#include "Serializer.mqh"
#include "SymbolInfo.mqh"

// Structs.
// Market info.
struct MarketData {
  int empty;
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s) {
    return SerializerNodeObject;
  }
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
  }

  /**
   * Class deconstructor.
   */
  ~Market() {}

  /* Getters */

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
#ifdef __MQL4__
    return ::MarketInfo(_symbol, _type);
#else
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
#endif
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
    double _result = round(p / GetPointSize(_symbol)) * GetTickSize(_symbol);
    _result = NormalizeDouble(_result, GetDigits(_symbol));
    return _result;
  }
  double NormalizePrice(double p) { return NormalizePrice(symbol, p); }

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
                            "Volume digits: %d, " +
                            "Delta: %g, Last change: %g pips",
                        GetPipDigits(), GetPipValue(), GetSpreadInPts(), GetSpreadInPips(), GetSpreadInPct(),
                        GetPointsPerPip(),
                        GetVolumeDigits(), GetDeltaValue(), GetLastPriceChangeInPips());
  }

  /**
   * Returns Market data in CSV format.
   */
  string ToCSV(bool _header = false) {
    return !_header ? StringFormat("%d,%g,%d,%g,%.4f,%d," + "%g,%d,%.1f,%d," + "%g,%g", GetPipDigits(), GetPipValue(),
                                   GetSpreadInPts(), GetSpreadInPips(), GetSpreadInPct(), GetPointsPerPip(),
                                   GetVolumeDigits(), GetDeltaValue(), GetLastPriceChangeInPips())
                    : "Pip Digits,Pip Value,Spread,Pts/pip," +
                          "Volume digits," +
                          "Delta,Last change (pips)";
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
  bool CheckCondition(ENUM_MARKET_CONDITION _cond, MqlParam &_args[]) {
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
    MqlParam _args[] = {};
    return Market::CheckCondition(_cond, _args);
  }

  /* Serializers */

  /**
   * Returns serialized representation of the object instance.
   */
  SerializerNodeType Serialize(Serializer &_s) {
    _s.PassStruct(this, "market-data", minfo);
    // _s.PassStruct(this, "symbol-info", (SymbolInfo *)this);
    return SerializerNodeObject;
  }

};
#endif  // MARKET_MQH

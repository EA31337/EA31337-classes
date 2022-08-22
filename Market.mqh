//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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

// Includes.
#include "Market.struct.h"
#include "Math.h"
#include "Serializer/Serializer.h"
#include "SymbolInfo.mqh"
#include "SymbolInfo.struct.static.h"
#include "Task/TaskCondition.enum.h"

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
  Market(string _symbol = NULL, Log *_log = NULL) : SymbolInfo(_symbol) {}

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
        return SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_LASTLOW);
      case MODE_HIGH:
        // High day price.
        return SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_LASTHIGH);
      case MODE_TIME:
        // Time of the last quote.
        return (double)SymbolInfoStatic::GetQuoteTime(_symbol);
      case MODE_BID:
        // Last incoming bid price.
        return SymbolInfoStatic::GetBid(_symbol);
      case MODE_ASK:
        // Last incoming ask price.
        return SymbolInfoStatic::GetAsk(_symbol);
      case MODE_POINT:
        // Point size in the quote currency.
        return SymbolInfoStatic::GetPointSize(_symbol);
      case MODE_DIGITS:
        // Symbol digits after decimal point.
        return SymbolInfoStatic::GetDigits(_symbol);
      case MODE_SPREAD:
        // Spread value in points.
        return SymbolInfoStatic::GetSpreadInPts(_symbol);
      case MODE_STOPLEVEL:
        // Stop level in points.
        return (double)SymbolInfoStatic::GetTradeStopsLevel(_symbol);
      case MODE_LOTSIZE:
        // Lot size in the base currency.
        return SymbolInfoStatic::GetTradeContractSize(_symbol);
      case MODE_TICKVALUE:
        // Tick value in the deposit currency.
        return SymbolInfoStatic::GetTickValue(_symbol);
      case MODE_TICKSIZE:
        // Tick size in points.
        return SymbolInfoStatic::GetTickSize(_symbol);
      case MODE_SWAPLONG:
        // Swap of the buy order.
        return SymbolInfoStatic::GetSwapLong(_symbol);
      case MODE_SWAPSHORT:
        // Swap of the sell order.
        return SymbolInfoStatic::GetSwapShort(_symbol);
      case MODE_LOTSTEP:
        // Step for changing lots.
        return SymbolInfoStatic::GetVolumeStep(_symbol);
      case MODE_MINLOT:
        // Minimum permitted amount of a lot.
        return SymbolInfoStatic::GetVolumeMin(_symbol);
      case MODE_MAXLOT:
        // Maximum permitted amount of a lot.
        return SymbolInfoStatic::GetVolumeMax(_symbol);
      case MODE_SWAPTYPE:
        // Swap calculation method.
        return (double)SymbolInfoStatic::GetSwapMode(_symbol);
      case MODE_PROFITCALCMODE:
        // Profit calculation mode.
        return (double)SymbolInfoStatic::SymbolInfoInteger(_symbol, SYMBOL_TRADE_CALC_MODE);
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
        return SymbolInfoStatic::GetMarginInit(_symbol);
      case MODE_MARGINMAINTENANCE:
        // Margin to maintain open orders calculated for 1 lot.
        return SymbolInfoStatic::GetMarginMaintenance(_symbol);
      case MODE_MARGINHEDGED:
        // @todo: Hedged margin calculated for 1 lot.
        return (0);
      case MODE_MARGINREQUIRED:
        // @todo: Free margin required to open 1 lot for buying.
        return (0);
      case MODE_FREEZELEVEL:
        // Order freeze level in points.
        return SymbolInfoStatic::GetFreezeLevel(_symbol);
    }
#endif
    return (-1);
  }
  double MarketInfo(int _type) { return MarketInfo(symbol, _type); }

  /**
   * Get delta value per lot in account currency of a point of symbol.
   *
   * @see
   * - https://www.mql5.com/en/forum/127584
   * - https://www.mql5.com/en/forum/133792/page3#512466
   * - https://www.mql5.com/en/forum/135345#515262
   */
  static double GetDeltaValue(string _symbol) {
    // Return tick value in the deposit currency divided by tick size in points.
    return SymbolInfoStatic::GetTickValue(_symbol) / SymbolInfoStatic::GetTickSize(_symbol);
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
    // See:
    // - https://www.mql5.com/en/forum/135345 (for non-currency DE30)
    // - https://www.mql5.com/en/forum/139338
    // - MarketInfo(chart.symbol,MODE_TICKSIZE) returns 0.5
    // - MarketInfo(chart.symbol,MODE_DIGITS) return 1
    // - Point = 0.1
    // Rare fix when a change in tick size leads to a change in tick value.
    double _result = round(p / SymbolInfoStatic::GetPointSize(_symbol)) * SymbolInfoStatic::GetTickSize(_symbol);
    _result = NormalizeDouble(_result, SymbolInfoStatic::GetDigits(_symbol));
    return _result;
  }
  double NormalizePrice(double p) { return NormalizePrice(symbol, p); }

  /* Market state checking */

  /**
   * Check whether given symbol exists.
   */
  static bool SymbolExists(string _symbol = NULL) {
    ResetLastError();
    SymbolInfoStatic::GetAsk(_symbol);
    return GetLastError() != ERR_MARKET_UNKNOWN_SYMBOL;
  }

  /* Printer methods */

  /**
   * Returns Market data in textual representation.
   */
  string ToString() override {
    return StringFormat(string("Pip digits/value: %d/%g, Spread: %d pts (%g pips; %.4f%%), Pts/pip: %d, ") +
                            "Volume digits: %d, " + "Delta: %g, Last change: %g pips",
                        GetPipDigits(), GetPipValue(), GetSpreadInPts(), GetSpreadInPips(), GetSpreadInPct(),
                        GetPointsPerPip(), GetVolumeDigits(), GetDeltaValue(), GetLastPriceChangeInPips());
  }

  /**
   * Returns Market data in CSV format.
   */
  string ToCSV(bool _header = false) {
    return !_header ? StringFormat(string("%d,%g,%d,%g,%.4f,%d,") + "%g,%d,%.1f,%d," + "%g,%g", GetPipDigits(),
                                   GetPipValue(), GetSpreadInPts(), GetSpreadInPips(), GetSpreadInPct(),
                                   GetPointsPerPip(), GetVolumeDigits(), GetDeltaValue(), GetLastPriceChangeInPips())
                    : string("Pip Digits,Pip Value,Spread,Pts/pip,") + "Volume digits," + "Delta,Last change (pips)";
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
  bool CheckCondition(ENUM_MARKET_CONDITION _cond, ARRAY_REF(DataParamEntry, _args)) {
    switch (_cond) {
      case MARKET_COND_IN_PEAK_HOURS:
        return DateTimeStatic::Hour() >= 8 && DateTimeStatic::Hour() <= 16;
      case MARKET_COND_SPREAD_LE_10:
        return GetSpreadInPts() <= 10;
      case MARKET_COND_SPREAD_GT_10:
        return GetSpreadInPts() > 10;
      case MARKET_COND_SPREAD_GT_20:
        return GetSpreadInPts() > 20;
      default:
        GetLogger().Error(StringFormat("Invalid market condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }
  bool CheckCondition(ENUM_MARKET_CONDITION _cond) {
    ARRAY(DataParamEntry, _args);
    return Market::CheckCondition(_cond, _args);
  }

  /* Serializers */

  /**
   * Returns serialized representation of the object instance.
   */
  SerializerNodeType Serialize(Serializer &_s) {
    _s.PassStruct(THIS_REF, "market-data", minfo);
    // _s.PassStruct(THIS_REF, "symbol-info", (SymbolInfo *)this);
    return SerializerNodeObject;
  }
};

#ifndef __MQL4__
// Defines macros (for MQL4 backward compatibility).
double MarketInfo(string _symbol, int _type) { return Market::MarketInfo(_symbol, _type); }
#endif

#endif  // MARKET_MQH

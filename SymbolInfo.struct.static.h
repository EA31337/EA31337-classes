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
#ifndef __MQL__
#pragma once
#endif

#include "MQL5.mqh"
#include "Order.enum.h"
#include "Std.h"
#include "Tick/Tick.struct.h"

/**
 * Struct to provide symbol information.
 */
struct SymbolInfoStatic {
 public:
  /**
   * Get the current symbol pair from the current chart.
   */
  static string GetCurrentSymbol() { return _Symbol; }

  /**
   * Updates and gets the latest tick prices.
   *
   * @docs MQL4 https://docs.mql4.com/constants/structures/mqltick
   * @docs MQL5 https://www.mql5.com/en/docs/constants/structures/mqltick
   */
  static MqlTick GetTick(string _symbol) {
    MqlTick _last_tick;
    if (!::SymbolInfoTick(_symbol, _last_tick)) {
      PrintFormat("Error: %s(): %s", __FUNCTION__, "Cannot return current prices!");
    }
    return _last_tick;
  }

  /**
   * Updates and gets the latest ask price (best buy offer).
   */
  static double GetAsk(string _symbol) { return SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_ASK); }

  /**
   * Updates and gets the latest bid price (best sell offer).
   */
  static double GetBid(string _symbol) { return SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_BID); }

  /**
   * Get the last volume for the current last price.
   *
   * @see: https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
   */
  static unsigned long GetVolume(string _symbol) { return GetTick(_symbol).volume; }

  /**
   * Get summary volume of current session deals.
   *
   * @see: https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
   */
  static double GetSessionVolume(string _symbol) {
    return SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_SESSION_VOLUME);
  }

  /**
   * Time of the last quote
   *
   * @docs
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#enum_symbol_info_double
   */
  static datetime GetQuoteTime(string _symbol) {
    return (datetime)SymbolInfoStatic::SymbolInfoInteger(_symbol, SYMBOL_TIME);
  }

  /**
   * Get current open price depending on the operation type.
   *
   * @param:
   *   op_type int Order operation type of the order.
   * @return
   *   Current open price.
   */
  static double GetOpenOffer(string _symbol, ENUM_ORDER_TYPE _cmd) {
    // Use the right open price at opening of a market order. For example:
    // - When selling, only the latest Bid prices can be used.
    // - When buying, only the latest Ask prices can be used.
    return _cmd == ORDER_TYPE_BUY ? GetAsk(_symbol) : GetBid(_symbol);
  }

  /**
   * Get current close price depending on the operation type.
   *
   * @param:
   *   op_type int Order operation type of the order.
   * @return
   * Current close price.
   */
  static double GetCloseOffer(string _symbol, ENUM_ORDER_TYPE _cmd) {
    return _cmd == ORDER_TYPE_BUY ? GetBid(_symbol) : GetAsk(_symbol);
  }

  /**
   * Get pip precision.
   */
  static unsigned int GetPipDigits(string _symbol) { return GetDigits(_symbol) < 4 ? 2 : 4; }

  /**
   * Get pip value.
   */
  static double GetPipValue(string _symbol) {
    unsigned int _pdigits = GetPipDigits(_symbol);
    return 10 >> _pdigits;
  }

  /**
   * Get number of points per pip.
   *
   */
  static unsigned int GetPointsPerPip(string _symbol) {
    // To be used to replace Point for trade parameters calculations.
    // See: https://www.mql5.com/en/forum/124692
    return (unsigned int)pow((unsigned int)10,
                             SymbolInfoStatic::GetDigits(_symbol) - SymbolInfoStatic::GetPipDigits(_symbol));
  }

  /**
   * Get the point size in the quote currency.
   *
   * The smallest digit of price quote.
   * A change of 1 in the least significant digit of the price.
   * You may also use Point predefined variable for the current symbol.
   */
  static double GetPointSize(string _symbol) {
    // Same as: MarketInfo(symbol, MODE_POINT);
    return SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_POINT);
  }

  /**
   * Return a pip size.
   *
   * In most cases, a pip is equal to 1/100 (.01%) of the quote currency.
   */
  static double GetPipSize(string _symbol) {
    // @todo: This code may fail at Gold and Silver (https://www.mql5.com/en/forum/135345#515262).
    return GetPointSize(_symbol) * (GetDigits(_symbol) % 2 == 0 ? 1 : 10);
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
  static unsigned int GetSpreadInPts(string _symbol) { return GetSpread(_symbol); }

  /**
   * Get current spread in percent.
   */
  static double GetSpreadInPct(string _symbol) { return 100.0 * (GetAsk(_symbol) - GetBid(_symbol)) / GetAsk(_symbol); }

  /**
   * Get a tick size in the price value.
   *
   * It is the smallest movement in the price quoted by the broker,
   * which could be several points.
   * In currencies it is equivalent to point size, in metals they are not.
   */
  static float GetTickSize(string _symbol) {
    // Note: In currencies a tick is always a point, but not for other markets.
    return (float)SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_SIZE);
  }

  /**
   * Get a tick size in points.
   *
   * It is a minimal price change in points.
   * In currencies it is equivalent to point size, in metals they are not.
   */
  static double GetTradeTickSize(string _symbol) {
    return SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_SIZE);
  }

  /**
   * Get a tick value in the deposit currency.
   *
   * @return
   * Returns the number of base currency units for one pip of movement.
   */
  static double GetTickValue(string _symbol) {
    return SymbolInfoStatic::SymbolInfoDouble(_symbol,
                                              SYMBOL_TRADE_TICK_VALUE);  // Same as: MarketInfo(symbol, MODE_TICKVALUE);
  }

  /**
   * Get a calculated tick price for a profitable position.
   *
   * @return
   * Returns the number of base currency units for one pip of movement.
   */
  static double GetTickValueProfit(string _symbol) {
    // Not supported in MQL4.
    return SymbolInfoStatic::SymbolInfoDouble(
        _symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT);  // Same as: MarketInfo(symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT);
  }

  /**
   * Get a calculated tick price for a losing position.
   *
   * @return
   * Returns the number of base currency units for one pip of movement.
   */
  static double GetTickValueLoss(string _symbol) {
    // Not supported in MQL4.
    return SymbolInfoStatic::SymbolInfoDouble(
        _symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);  // Same as: MarketInfo(symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
  }

  /**
   * Get count of digits after decimal point for the symbol price.
   *
   * For the current symbol, it is stored in the predefined variable Digits.
   *
   */
  static unsigned int GetDigits(string _symbol) {
    return (unsigned int)SymbolInfoStatic::SymbolInfoInteger(
        _symbol,
        SYMBOL_DIGITS);  // Same as: MarketInfo(symbol, MODE_DIGITS);
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
  static unsigned int GetSpread(string _symbol) {
    return (unsigned int)SymbolInfoStatic::SymbolInfoInteger(_symbol, SYMBOL_SPREAD);
  }

  /**
   * Get real spread based on the ask and bid price (in points).
   */
  static unsigned int GetRealSpread(double _bid, double _ask, unsigned int _digits) {
    return (unsigned int)round((_ask - _bid) * pow((unsigned int)10, _digits));
  }
  static unsigned int GetRealSpread(string _symbol) {
    return GetRealSpread(SymbolInfoStatic::GetBid(_symbol), SymbolInfoStatic::GetAsk(_symbol),
                         SymbolInfoStatic::GetDigits(_symbol));
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
  static long GetTradeStopsLevel(string _symbol) {
    return SymbolInfoStatic::SymbolInfoInteger(_symbol, SYMBOL_TRADE_STOPS_LEVEL);
  }

  /**
   * Get a contract lot size in the base currency.
   */
  static double GetTradeContractSize(string _symbol) {
    return SymbolInfoStatic::SymbolInfoDouble(
        _symbol,
        SYMBOL_TRADE_CONTRACT_SIZE);  // Same as: MarketInfo(symbol, MODE_LOTSIZE);
  }

  /**
   * Get a volume precision.
   */
  static unsigned int GetVolumeDigits(string _symbol) {
    return (unsigned int)-log10(fmin(GetVolumeStep(_symbol), GetVolumeMin(_symbol)));
  }

  /**
   * Minimum permitted amount of a lot/volume for a deal.
   */
  static double GetVolumeMin(string _symbol) {
    return SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN);  // Same as: MarketInfo(symbol, MODE_MINLOT);
  }

  /**
   * Maximum permitted amount of a lot/volume for a deal.
   */
  static double GetVolumeMax(string _symbol) {
    return SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);  // Same as: MarketInfo(symbol, MODE_MAXLOT);
  }

  /**
   * Get a lot/volume step for a deal.
   *
   * Minimal volume change step for deal execution
   */
  static double GetVolumeStep(string _symbol) {
    return SymbolInfoStatic::SymbolInfoDouble(_symbol,
                                              SYMBOL_VOLUME_STEP);  // Same as: MarketInfo(symbol, MODE_LOTSTEP);
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
  static int GetFreezeLevel(string _symbol) {
    return (int)SymbolInfoStatic::SymbolInfoInteger(
        _symbol, SYMBOL_TRADE_FREEZE_LEVEL);  // Same as: MarketInfo(symbol, MODE_FREEZELEVEL);
  }

  /**
   * Gets flags of allowed order filling modes.
   *
   *  The flags can be combined by the operation of the logical OR (e.g. SYMBOL_FILLING_FOK|SYMBOL_FILLING_IOC).
   *
   * @docs
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#symbol_filling_mode
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   */
  static ENUM_ORDER_TYPE_FILLING GetFillingMode(string _symbol) {
    // Note: Not supported for MQL4.
    return (ENUM_ORDER_TYPE_FILLING)SymbolInfoStatic::SymbolInfoInteger(_symbol, SYMBOL_FILLING_MODE);
  }

  /**
   * Buy order swap value
   *
   * @docs
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
   */
  static double GetSwapLong(string _symbol) { return SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_SWAP_LONG); }

  /**
   * Sell order swap value
   *
   * @docs
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
   */
  static double GetSwapShort(string _symbol) { return SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_SWAP_SHORT); }

  /**
   * Swap calculation model.
   *
   * @docs
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
   */
  static ENUM_SYMBOL_SWAP_MODE GetSwapMode(string _symbol) {
    return (ENUM_SYMBOL_SWAP_MODE)SymbolInfoStatic::SymbolInfoInteger(_symbol, SYMBOL_SWAP_MODE);
  }

  /**
   * Returns initial margin (a security deposit) requirements for opening an order.
   *
   * @docs
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#enum_symbol_info_double
   */
  static double GetMarginInit(string _symbol, ENUM_ORDER_TYPE _cmd = ORDER_TYPE_BUY) {
#ifdef __MQL4__
    // The amount in the margin currency required for opening an order with the volume of one lot.
    // It is used for checking a client's assets when entering the market.
    // Same as: MarketInfo(symbol, MODE_MARGININIT);
    return SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_MARGIN_INITIAL);
#else  // __MQL5__
       // In MQL5, SymbolInfoDouble() is used for stock markets, not Forex (https://www.mql5.com/en/forum/7418).
       // So we've to use OrderCalcMargin() which calculates the margin required for the specified order type.
    double _margin_init, _margin_main;
    const bool _result = SymbolInfoMarginRate(_symbol, _cmd, _margin_init, _margin_main);
    return _result ? _margin_init : 0;
#endif
  }

  /**
   * Return the maintenance margin to maintain open orders.
   *
   * @docs
   * - https://docs.mql4.com/constants/environment_state/marketinfoconstants
   * - https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#enum_symbol_info_double
   */
  static double GetMarginMaintenance(string _symbol, ENUM_ORDER_TYPE _cmd = ORDER_TYPE_BUY) {
#ifdef __MQL4__
    // The margin amount in the margin currency of the symbol, charged from one lot.
    // It is used for checking a client's assets when his/her account state changes.
    // If the maintenance margin is equal to 0, the initial margin should be used.
    // Same as: MarketInfo(symbol, SYMBOL_MARGIN_MAINTENANCE);
    return SymbolInfoStatic::SymbolInfoDouble(_symbol, SYMBOL_MARGIN_MAINTENANCE);
#else  // __MQL5__
       // In MQL5, SymbolInfoDouble() is used for stock markets, not Forex (https://www.mql5.com/en/forum/7418).
       // So we've to use OrderCalcMargin() which calculates the margin required for the specified order type.
    double _margin_init, _margin_main;
    const bool _result = SymbolInfoMarginRate(_symbol, _cmd, _margin_init, _margin_main);
    return _result ? _margin_main : 0;
#endif
  }

  /**
   * Returns the value of a corresponding property of the symbol.
   *
   * @param string name
   *   Symbol name.
   * @param ENUM_SYMBOL_INFO_DOUBLE prop_id
   *   Identifier of a property.
   *
   * @return double
   *   Returns the value of the property.
   *   In case of error, information can be obtained using GetLastError() function.
   *
   * @docs
   * - https://docs.mql4.com/marketinformation/symbolinfodouble
   * - https://www.mql5.com/en/docs/marketinformation/symbolinfodouble
   *
   */
  static double SymbolInfoDouble(string name, ENUM_SYMBOL_INFO_DOUBLE prop_id) {
#ifdef __MQLBUILD__
    return ::SymbolInfoDouble(name, prop_id);
#else
    printf("@fixme: %s\n", "Symbol::SymbolInfoDouble()");
    return 0;
#endif
  }

  /**
   * Returns the value of a corresponding property of the symbol.
   *
   * @param string name
   *   Symbol name.
   * @param ENUM_SYMBOL_INFO_INTEGER prop_id
   *   Identifier of a property.
   *
   * @return long
   *   Returns the value of the property.
   *   In case of error, information can be obtained using GetLastError() function.
   *
   * @docs
   * - https://docs.mql4.com/marketinformation/symbolinfointeger
   * - https://www.mql5.com/en/docs/marketinformation/symbolinfointeger
   *
   */
  static long SymbolInfoInteger(string name, ENUM_SYMBOL_INFO_INTEGER prop_id) {
    return ::SymbolInfoInteger(name, prop_id);
  }

  /**
   * Returns the value of a corresponding property of the symbol.
   *
   * @param string name
   *   Symbol name.
   * @param ENUM_SYMBOL_INFO_STRING prop_id
   *   Identifier of a property.
   *
   * @return string
   *   Returns the value of the property.
   *   In case of error, information can be obtained using GetLastError() function.
   *
   * @docs
   * - https://docs.mql4.com/marketinformation/symbolinfostring
   * - https://www.mql5.com/en/docs/marketinformation/symbolinfostring
   *
   */
  static string SymbolInfoString(string name, ENUM_SYMBOL_INFO_STRING prop_id) {
#ifdef __MQLBUILD__
    return ::SymbolInfoString(name, prop_id);
#else
    printf("@fixme: %s\n", "SymbolInfoStatic::SymbolInfoString()");
    return 0;
#endif
  }
};

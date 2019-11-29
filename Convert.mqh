//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Prevents processing this includes file for the second time.
#ifndef CONVERT_MQH
#define CONVERT_MQH

// Includes.
#include "Math.mqh"
#include "SymbolInfo.mqh"

// Defines.
#ifdef __MQL5__
  #ifndef DoubleToStr
  // Returns text string with the specified numerical value converted into a specified precision format.
  #define DoubleToStr(value, digits) DoubleToString(value, digits)
  #endif
#endif

/**
 * Class to provide conversion methods.
 */
class Convert {

public:

  /*
   * Returns order type as buy or sell.
   *
   * @param
   *   op_type int Order operation type of the order.
   *
   * @return
   *   Returns OP_BUY for buy related orders,
   *   OP_SELL for sell related orders,
   *   otherwise EMPTY (-1).
   */
  static ENUM_ORDER_TYPE OrderTypeBuyOrSell(ENUM_ORDER_TYPE _cmd) {
    switch (_cmd) {
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_LIMIT:
      case ORDER_TYPE_SELL_STOP:
        return ORDER_TYPE_SELL;
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_BUY_STOP:
        return ORDER_TYPE_BUY;
      default:
        return NULL;
    }
  }

  /**
   * Return command operation based on the value.
   *
   * @param
   *   value int
   *     Value to convert.
   *
   * @return
   *   Returns OP_BUY when value is positive, OP_SELL when negative, otherwise -1.
   */
  static ENUM_ORDER_TYPE ValueToOp(int value) {
    return value == 0 ? (ENUM_ORDER_TYPE) EMPTY : (value > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
  }

  /**
   * Return command operation based on the value.
   */
  static ENUM_ORDER_TYPE ValueToOp(double value) {
    return value == 0 ? (ENUM_ORDER_TYPE) EMPTY : (value > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
  }

  /**
   * Points per pip given digits after decimal point of a symbol price.
   */
  static uint PointsPerPip(uint digits) {
    return (uint) pow(10, digits - (digits < 4 ? 2 : 4));
  }

  /**
   * Returns number of points per pip.
   */
  static uint PointsPerPip(string _symbol = NULL) {
    return PointsPerPip((uint) SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_DIGITS));
  }

  /**
   * Convert pips into price value.
   *
   */
  static double PipsToValue(double pips, int digits) {
    switch (digits) {
      case 0:
      case 1:
        return pips * 1.0;
      case 2:
      case 3:
        return pips * 0.01;
      case 4:
      case 5:
      default:
        return pips * 0.0001;
    }
  }

  /**
   * Convert pips into price value.
   */
  static double PipsToValue(double pips, string _symbol = NULL) {
    return PipsToValue(pips, (uint) SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_DIGITS));
  }

  /**
   * Convert value into pips given price value and digits.
   */
  static double ValueToPips(double value, uint digits) {
    return value * pow(10, digits < 4 ? 2 : 4);
  }

  /**
   * Convert value into pips.
   */
  static double ValueToPips(double value, string _symbol = NULL) {
    return ValueToPips(value, (uint) SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_DIGITS));
  }

  /**
   * Convert pips into points.
   */
  static uint PipsToPoints(double pips, int digits) {
    return (uint) pips * PointsPerPip(digits);
  }

  /**
   * Convert pips into points.
   */
  static uint PipsToPoints(double pips, string _symbol = NULL) {
    return PipsToPoints(pips, (uint) SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_DIGITS));
  }

  /**
   * Convert points into pips.
   */
  static double PointsToPips(long pts, int digits) {
    return (double) (pts / PointsPerPip(digits));
  }

  /**
   * Convert points into pips.
   */
  static double PointsToPips(long pts, string _symbol = NULL) {
    return PointsToPips(pts, (uint) SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_DIGITS));
  }

  /**
   * Convert points into price value.
   *
   */
  static double PointsToValue(long pts, int mode, string _symbol = NULL) {
    switch (mode) {
      case 0: // Forex.
        // In currencies a tick is a point.
        return pts * SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_SIZE);
      case 1: // CFD.
        // In metals a Tick is still the smallest change, but is larger than a point.
        // If price can change from 123.25 to 123.50,
        // you have a TickSize of 0.25 and a point of 0.01. Pip has no meaning.
        // @todo
        return pts * SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_SIZE);
      case 2: // Futures.
        // @todo
        return pts * SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_SIZE);
      case 3: // CFD for indices.
        // @todo
        return pts * SymbolInfo::SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_SIZE);
    }
    return false;
  }

  /**
   * Convert points into price value.
   */
  static double PointsToValue(long pts, int mode, int digits) {
    switch (mode) {
      case 0: // Forex.
        return PipsToValue((double) pts / PointsPerPip(digits), digits);
      case 1: // CFD.
        // In metals a Tick is still the smallest change, but is larger than a point.
        // @todo
        return PipsToValue((double) pts / PointsPerPip(digits), digits);
      case 2: // Futures.
        // @todo
        return PipsToValue((double) pts / PointsPerPip(digits), digits);
      case 3: // CFD for indices.
        // @todo
        return PipsToValue((double) pts / PointsPerPip(digits), digits);
    }
    return false;
  }

  /**
   * Convert points into price value.
   */
  static double PointsToValue(long pts, string _symbol = NULL) {
    return PointsToValue(pts, (int) SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_TRADE_CALC_MODE));
  }

  /**
   * Convert price value into money value in base currency.
   *
   * @return
   *   Returns amount in a base currency based on the given the value.
   */
  static double ValueToMoney(double value, string _symbol = NULL) {
    double _tick_value = SymbolInfo::GetTickValue(_symbol) > 0 ? SymbolInfo::GetTickValue(_symbol) : 1;
    return value * _tick_value / SymbolInfo::GetPointSize(_symbol);
  }

  /**
   * Convert money to value.
   *
   * @return
   *   Returns value in points equivalent to the amount in a base currency.
   */
  static double MoneyToValue(double money, double lot_size, string _symbol = NULL) {
    double _tick_value = SymbolInfo::GetTickValue(_symbol) > 0 ? SymbolInfo::GetTickValue(_symbol) : 1;
    return money > 0 && lot_size > 0 ? money / _tick_value * SymbolInfo::GetPointSize(_symbol) / lot_size : 0;
  }

  /**
   * Get the difference between two price values (in pips).
   */
  static double GetValueDiffInPips(double price1, double price2, bool abs = false, int digits = NULL, string _symbol = NULL) {
    digits = digits ? digits : (int) SymbolInfo::SymbolInfoInteger(_symbol, SYMBOL_DIGITS);
    return ValueToPips(abs ? fabs(price1 - price2) : (price1 - price2), digits);
  }

  /**
   * Add currency sign to the plain value.
   */
  static string ValueWithCurrency(double value, int digits = 2, string currency = "USD") {
    unsigned char sign; bool prefix = true;
    currency = currency == "" ? AccountInfoString(ACCOUNT_CURRENCY) : currency;
    if (currency == "USD") sign = (unsigned char) '$';
    else if (currency == "GBP") sign = (unsigned char) 0xA3; // ANSI code.
    else if (currency == "EUR") sign = (unsigned char) 0x80; // ANSI code.
    else { sign = NULL; prefix = false; }
    return prefix
      ? CharToString(sign) + DoubleToStr(value, digits)
      : DoubleToStr(value, digits) + CharToString(sign);
  }

  /**
   * Convert integer to hex.
   */
  static string IntToHex(long long_number) {
    string result;
    int integer_number = (int) long_number;
    for (int i = 0; i < 4; i++){
       int byte = (integer_number >> (i*8)) & 0xff;
       result += StringFormat("%02x", byte);
    }
    return result;
  }

  /**
   * Convert character into integer.
   */
  static int CharToInt(int &a[]) {
    return ((a[0]) | (a[1] << 8) | (a[2] << 16) | (a[3] << 24));
  }

  /**
   * Assume: len % 4 == 0.
   */
  static int String4ToIntArray(int &output[], string in) {
    int len;
    int i, j;
    len = StringLen(in);
    if (len % 4 != 0) len = len - len % 4;
    int size = ArraySize(output);
    if (size < len / 4) {
      ArrayResize(output, len/4);
    }
    for (i = 0, j = 0; j < len; i++, j += 4) {
      output[i] = (StringGetCharacter(in, j)) | ((StringGetCharacter(in, j + 1)) << 8) 
        | ((StringGetCharacter(in, j+2)) << 16) | ((StringGetCharacter(in, j + 3)) << 24);
    }
    return (len / 4);
  }

};
#endif // CONVERT_MQH

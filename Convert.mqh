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

// Define type of periods.
// @see: https://docs.mql4.com/constants/chartconstants/enum_timeframes
enum ENUM_TIMEFRAMES_INDEX {
  M1  =  0, // 1 minute
  M2  =  1, // 2 minutea (non-standard)
  M3  =  2, // 3 minutes (non-standard)
  M4  =  3, // 4 minutes (non-standard)
  M5  =  4, // 5 minutes
  M6  =  5, // 6 minutes (non-standard)
  M10 =  6, // 10 minutes (non-standard)
  M12 =  7, // 12 minutes (non-standard)
  M15 =  8, // 15 minutes
  M20 =  9, // 20 minutes (non-standard)
  M30 = 10, // 30 minutes
  H1  = 11, // 1 hour
  H2  = 12, // 2 hours (non-standard)
  H3  = 13, // 3 hours (non-standard)
  H4  = 14, // 4 hours
  H6  = 15, // 6 hours (non-standard)
  H8  = 16, // 8 hours (non-standard)
  H12 = 17, // 12 hours (non-standard)
  D1  = 18, // Daily
  W1  = 19, // Weekly
  MN1 = 20, // Monthly
  // This item should be the last one.
  // Used to calculate the number of enum items.
  FINAL_ENUM_TIMEFRAMES_INDEX_ENTRY = 21
};

/**
 * Class to provide conversion methods.
 */
class Convert {
public:

  /**
   * Convert period to proper chart timeframe value.
   */
  static ENUM_TIMEFRAMES IndexToTf(int index) {
    switch (index) {
      case M1:  return PERIOD_M1;  // For 1 minute.
      case M2:  return PERIOD_M2;  // For 2 minutes (non-standard).
      case M3:  return PERIOD_M3;  // For 3 minutes (non-standard).
      case M4:  return PERIOD_M4;  // For 4 minutes (non-standard).
      case M5:  return PERIOD_M5;  // For 5 minutes.
      case M6:  return PERIOD_M6;  // For 6 minutes (non-standard).
      case M10: return PERIOD_M10; // For 10 minutes (non-standard).
      case M12: return PERIOD_M12; // For 12 minutes (non-standard).
      case M15: return PERIOD_M15; // For 15 minutes.
      case M20: return PERIOD_M20; // For 20 minutes (non-standard).
      case M30: return PERIOD_M30; // For 30 minutes.
      case H1:  return PERIOD_H1;  // For 1 hour.
      case H2:  return PERIOD_H2;  // For 2 hours (non-standard).
      case H3:  return PERIOD_H3;  // For 3 hours (non-standard).
      case H4:  return PERIOD_H4;  // For 4 hours.
      case H6:  return PERIOD_H6;  // For 6 hours (non-standard).
      case H8:  return PERIOD_H8;  // For 8 hours (non-standard).
      case H12: return PERIOD_H12; // For 12 hours (non-standard).
      case D1:  return PERIOD_D1;  // Daily.
      case W1:  return PERIOD_W1;  // Weekly.
      case MN1: return PERIOD_MN1; // Monthly.
      default:  return NULL;
    }
  }

  /**
   * Convert timeframe constant to period value.
   */
  static int TfToIndex(ENUM_TIMEFRAMES tf) {
    switch (tf) {
      case PERIOD_M1:  return M1;
      case PERIOD_M2:  return M2;
      case PERIOD_M3:  return M3;
      case PERIOD_M4:  return M4;
      case PERIOD_M5:  return M5;
      case PERIOD_M6:  return M6;
      case PERIOD_M10: return M10;
      case PERIOD_M12: return M12;
      case PERIOD_M15: return M15;
      case PERIOD_M20: return M20;
      case PERIOD_M30: return M30;
      case PERIOD_H1:  return H1;
      case PERIOD_H2:  return H2;
      case PERIOD_H3:  return H3;
      case PERIOD_H4:  return H4;
      case PERIOD_H6:  return H6;
      case PERIOD_H8:  return H8;
      case PERIOD_H12: return H12;
      case PERIOD_D1:  return D1;
      case PERIOD_W1:  return W1;
      case PERIOD_MN1: return MN1;
      default:         return NULL;
    }
  }

  /**
   * Convert timeframe constant to period value.
   */
  static string TfToString(ENUM_TIMEFRAMES tf) {
    switch (tf) {
      case PERIOD_M1:  return "M1";
      case PERIOD_M2:  return "M2";
      case PERIOD_M3:  return "M3";
      case PERIOD_M4:  return "M4";
      case PERIOD_M5:  return "M5";
      case PERIOD_M6:  return "M6";
      case PERIOD_M10: return "M10";
      case PERIOD_M15: return "M15";
      case PERIOD_M20: return "M20";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H2:  return "H2";
      case PERIOD_H3:  return "H3";
      case PERIOD_H4:  return "H4";
      case PERIOD_H6:  return "H6";
      case PERIOD_H8:  return "H8";
      case PERIOD_H12: return "H12";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
      default:         return NULL;
    }
  }

  /**
   * Returns OrderType as a text.
   *
   * @param
   *   op_type int Order operation type of the order.
   *   lc bool If True, return order operation in lower case.
   *
   * @return
   *   Return text representation of the order.
   */
  static string OrderTypeToString(int op_type, bool lc = False) {
    switch (op_type) {
      case OP_BUY:          return !lc ? "Buy" : "buy";
      case OP_SELL:         return !lc ? "Sell" : "sell";
      case OP_BUYLIMIT:     return !lc ? "Buy Limit" : "buy limit";
      case OP_BUYSTOP:      return !lc ? "Buy Stop" : "buy stop";
      case OP_SELLLIMIT:    return !lc ? "Sell Limit" : "sell limit";
      case OP_SELLSTOP:     return !lc ? "Sell Stop" : "sell stop";
      default:              return !lc ? "Unknown" : "unknown";
    }
  }

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
  static int OpToBuyOrSell(int op_type) {
    switch (op_type) {
      case OP_SELL:
      case OP_SELLLIMIT:
      case OP_SELLSTOP:
        return OP_SELL;
      case OP_BUY:
      case OP_BUYLIMIT:
      case OP_BUYSTOP:
        return OP_BUY;
      default:
        return EMPTY;
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
   *   Returns OP_BUY when value is positive, OP_SELL when negative, otherwise EMPTY (-1).
   */
  static int ValueToOp(int value) {
    return value == 0 ? EMPTY : (value > 0 ? OP_BUY : OP_SELL);
  }

  /**
   * Return command operation based on the value.
   */
  static int ValueToOp(double value) {
    return value == 0 ? EMPTY : (value > 0 ? OP_BUY : OP_SELL);
  }

  /**
   * Return opposite trade of command operation.
   *
   * @param
   *   cmd int Trade command operation.
   */
  static int NegateOrderType(int cmd) {
    if (cmd == OP_BUY) return OP_SELL;
    if (cmd == OP_SELL) return OP_BUY;
    return EMPTY;
  }

  /**
   * Points per pip given digits after decimal point of a symbol price.
   */
  static int PointsPerPip(int digits) {
    return (int) pow(10, digits - (digits < 4 ? 2 : 4));
  }

  /**
   * Points per pip given a symbol name.
   */
  static int PointsPerPip(string symbol = NULL) {
    return PointsPerPip((int) MarketInfo(symbol, MODE_DIGITS));
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
  static double PipsToValue(double pips, string symbol = NULL) {
    return PipsToValue(pips, (int) MarketInfo(symbol, MODE_DIGITS));
  }

  /**
   * Convert value into pips given price value and digits.
   */
  static double ValueToPips(double value, int digits) {
    return value * pow(10, digits < 4 ? 2 : 4);
  }

  /**
   * Convert value into pips.
   */
  static double ValueToPips(double value, string symbol = NULL) {
    return ValueToPips(value, (int) MarketInfo(symbol, MODE_DIGITS));
  }

  /**
   * Convert pips into points.
   */
  static int PipsToPoints(double pips, int digits) {
    return (int) pips * PointsPerPip(digits);
  }

  /**
   * Convert pips into points.
   */
  static int PipsToPoints(double pips, string symbol = NULL) {
    return PipsToPoints(pips, (int) MarketInfo(symbol, MODE_DIGITS));
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
  static double PointsToPips(long pts, string symbol = NULL) {
    return PointsToPips(pts, (int) MarketInfo(symbol, MODE_DIGITS));
  }

  /**
   * Convert points into price value.
   *
   */
  static double PointsToValue(long pts, int mode, string symbol = NULL) {
    switch(mode) {
      case 0: // Forex.
        // In currencies a tick is a point.
        return pts * SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      case 1: // CFD.
        // In metals a Tick is still the smallest change but is larger than a point.
        // If price can change from 123.25 to 123.50,
        // you have a TickSize of 0.25 and a point of 0.01. Pip has no meaning.
        // @todo
        break;
      case 2: // Futures.
        // @todo
        break;
      case 3: // CFD for indices.
        // @todo
        break;
    }
    return False;
  }

  /**
   * Convert points into price value.
   */
  static double PointsToValue(long pts, int mode, int digits) {
    switch(mode) {
      case 0: // Forex.
        return PipsToValue((double) pts / PointsPerPip(digits), digits);
      case 1: // CFD.
        // In metals a Tick is still the smallest change but is larger than a point.
        // @todo
        break;
      case 2: // Futures.
        // @todo
        break;
      case 3: // CFD for indices.
        // @todo
        break;
    }
    return False;
  }

  /**
   * Convert points into price value.
   */
  static double PointsToValue(long pts, string symbol = NULL) {
    return PointsToValue(pts, (int) SymbolInfoInteger(symbol, SYMBOL_TRADE_CALC_MODE));
  }

  /**
   * Convert value to money.
   *
   * @return
   *   Returns amount in a base currency based on the given the value.
   */
  static double ValueToMoney(double value, string symbol = NULL) {
    return value * MarketInfo(symbol, MODE_TICKVALUE) / MarketInfo(symbol, MODE_POINT);
  }

  /**
   * Convert money to value.
   *
   * @return
   *   Returns value in points equivalent to the amount in a base currency.
   */
  static double MoneyToValue(double money, double lot_size, string symbol = NULL) {
    return money > 0 && lot_size > 0 ? money / MarketInfo(symbol, MODE_TICKVALUE) * MarketInfo(symbol, MODE_POINT) / lot_size : 0;
  }

  /**
   * Get the difference between two price values (in pips).
   */
  static double GetValueDiffInPips(double price1, double price2, bool abs = False, int digits = NULL, string symbol = NULL) {
    digits = digits ? digits : (int) MarketInfo(symbol, MODE_DIGITS);
    return ValueToPips(abs ? fabs(price1 - price2) : (price1 - price2), digits);
  }

  /**
   * Add currency sign to the plain value.
   */
  static string ValueWithCurrency(double value, int digits = 2, string currency = "USD") {
    uchar sign; bool prefix = TRUE;
    currency = currency == "" ? AccountCurrency() : currency;
    if (currency == "USD") sign = (uchar) '$';
    else if (currency == "GBP") sign = (uchar) 0xA3; // ANSI code.
    else if (currency == "EUR") sign = (uchar) 0x80; // ANSI code.
    else { sign = NULL; prefix = FALSE; }
    return prefix
      ? StringConcatenate(CharToString(sign), DoubleToStr(value, digits))
      : StringConcatenate(DoubleToStr(value, digits), CharToString(sign));
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

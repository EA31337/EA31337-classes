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
enum ENUM_PERIOD_TYPE {
  M1  = 0, // 1 minute
  M5  = 1, // 5 minutes
  M15 = 2, // 15 minutes
  M30 = 3, // 30 minutes
  H1  = 4, // 1 hour
  H4  = 5, // 4 hours
  D1  = 6, // Daily
  W1  = 7, // Weekly
  MN1 = 8, // Monthly
  FINAL_PERIOD_TYPE_ENTRY = 9 // Should be the last one. Used to calculate the number of enum items.
};

/**
 * Class to provide conversion methods.
 */
class Convert {
public:

  /**
   * Convert period to proper chart timeframe value.
   */
  static int IndexToTf(int index) {
    switch (index) {
      case M1:  return PERIOD_M1;  // For 1 minute.
      case M5:  return PERIOD_M5;  // For 5 minutes.
      case M15: return PERIOD_M15; // For 15 minutes.
      case M30: return PERIOD_M30; // For 30 minutes.
      case H1:  return PERIOD_H1;  // For 1 hour.
      case H4:  return PERIOD_H4;  // For 4 hours.
      case D1:  return PERIOD_D1;  // Daily.
      case W1:  return PERIOD_W1;  // Weekly.
      case MN1: return PERIOD_MN1; // Monthly.
      default:
        return NULL;
    }
  }

  /**
   * Convert timeframe constant to period value.
   */
  static int TfToIndex(ENUM_TIMEFRAMES tf) {
    switch (tf) {
      case PERIOD_M1:  return M1;
      case PERIOD_M5:  return M5;
      case PERIOD_M15: return M15;
      case PERIOD_M30: return M30;
      case PERIOD_H1:  return H1;
      case PERIOD_H4:  return H4;
      case PERIOD_D1:  return D1;
      case PERIOD_W1:  return W1;
      case PERIOD_MN1: return MN1;
      default:
        return NULL;
    }
  }

  /**
   * Returns OrderType as a text.
   *
   * @param
   *   op_type int Order operation type of the order.
   *
   * @return
   *   Return text representation of the order.
   */
  static string OrderTypeToString(int op_type) {
    switch (op_type) {
      case OP_BUY:          return("Buy");
      case OP_SELL:         return("Sell");
      case OP_BUYLIMIT:     return("BuyLimit");
      case OP_BUYSTOP:      return("BuyStop");
      case OP_SELLLIMIT:    return("SellLimit");
      case OP_SELLSTOP:     return("SellStop");
      default:              return("UnknownOrderType");
    }
  }

  /*
   * Returns OrderType as a value.
   *
   * @param
   *   op_type int Order operation type of the order.
   *
   * @return
   *   Return 1 for buy, -1 for sell orders.
   */
  static int OrderTypeToValue(int op_type) {
    switch (op_type) {
      case OP_SELL:
      case OP_SELLLIMIT:
      case OP_SELLSTOP:
        return -1;
        break;
      case OP_BUY:
      case OP_BUYLIMIT:
      case OP_BUYSTOP:
        return 1;
        break;
      default:
        return FALSE;
    }
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
    currency = currency ? currency : AccountCurrency();
    if (currency == "USD") sign = '$';
    else if (currency == "GBP") sign = '£';
    else if (currency == "EUR") sign = (uchar) '€';
    else { sign = NULL; prefix = FALSE; }
    return prefix
      ? StringConcatenate(CharToString(sign), DoubleToStr(value, digits))
      : StringConcatenate(DoubleToStr(value, digits), CharToString(sign));
  }

};

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
  FINAL_ENUM_TIMEFRAMES_INDEX = 21
};

// Enums.
// Define type of periods.
// @see: https://docs.mql4.com/constants/chartconstants/enum_timeframes
#ifdef __MQL4__
#define TFS 9
const ENUM_TIMEFRAMES arr_tf[TFS] = {
  PERIOD_M1, PERIOD_M5, PERIOD_M15,
  PERIOD_M30, PERIOD_H1, PERIOD_H4,
  PERIOD_D1, PERIOD_W1, PERIOD_MN1
};
#else // __MQL5__
#define TFS 21
const ENUM_TIMEFRAMES arr_tf[TFS] = {
  PERIOD_M1, PERIOD_M2, PERIOD_M3, PERIOD_M4, PERIOD_M5, PERIOD_M6,
  PERIOD_M10, PERIOD_M12, PERIOD_M15, PERIOD_M20, PERIOD_M30,
  PERIOD_H1, PERIOD_H2, PERIOD_H3, PERIOD_H4, PERIOD_H6, PERIOD_H8, PERIOD_H12,
  PERIOD_D1, PERIOD_W1, PERIOD_MN1
};
#endif

/**
 * Class to provide methods to deal with timeframes.
 */
class Timeframe {
protected:
  // Variables.
  string symbol;
  ENUM_TIMEFRAMES tf;

public:

  /**
   * Class constructor.
   */
  void Timeframe(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, string _symbol = NULL) :
    tf(_tf == 0 ? PERIOD_CURRENT : _tf),
    symbol(_symbol == NULL ? _Symbol : _symbol)
  {
  }

  /**
   * Convert period to proper chart timeframe value.
   *
   */
  static ENUM_TIMEFRAMES IndexToTf(int index) {
    // @todo: Convert it into a loop and using tf constant, see: TfToIndex().
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
   * Convert timeframe constant to index value.
   */
  /*
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
  */

  /**
   * Convert timeframe constant to index value.
   */
  static uint TfToIndex(ENUM_TIMEFRAMES _tf) {
    _tf = (_tf == 0 || _tf == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES) _Period : _tf;
    for (int i = 0; i < ArraySize(arr_tf); i++) {
      if (arr_tf[i] == _tf) {
        return (i);
      }
    }
    return (0);
  }

  /**
   * Returns text representation of the timeframe constant.
   */
  static string TfToString(const ENUM_TIMEFRAMES _tf) {
    return StringSubstr(EnumToString(_tf), 7);
  }

  /**
   * Returns text representation of the timeframe index.
   */
  static string IndexToString(uint tfi) {
    return TfToString(IndexToTf(tfi));
  }

  /**
   * Validate whether given timeframe is valid.
   */
  static bool ValidTf(ENUM_TIMEFRAMES _tf, string symbol = NULL) {
    double _ima = iMA(symbol, _tf, 13, 8, MODE_SMMA, PRICE_MEDIAN, 0);
    #ifdef __trace__ PrintFormat("%s: Tf: %d, MA: %g", __FUNCTION__, _tf, _ima); #endif
    return (iMA(symbol, _tf, 13, 8, MODE_SMMA, PRICE_MEDIAN, 0) > 0);
  }

  /**
   * Validate whether given timeframe index is valid.
   */
  static bool ValidTfIndex(uint _tf, string symbol = NULL) {
    return ValidTf(IndexToTf(_tf), symbol);
  }

  /**
   * Convert MQL4 time periods
   *
   * Note: In MQL5 the numerical values of chart timeframe constants (from H1)
   * are not equal to the number of minutes of a bar.
   * E.g. In MQL5, the value of constant PERIOD_H1 is 16385, but in MQL4 PERIOD_H1=60.
   *
   * @see: https://www.mql5.com/en/articles/81
   */
  static ENUM_TIMEFRAMES TFMigrate(int _mins) {
    switch (_mins) {
       case 0: return(PERIOD_CURRENT);
       case 1: return(PERIOD_M1);
       case 2: return(PERIOD_M2);
       case 3: return(PERIOD_M3);
       case 4: return(PERIOD_M4);
       case 5: return(PERIOD_M5);
       case 6: return(PERIOD_M6);
       case 10: return(PERIOD_M10);
       case 12: return(PERIOD_M12);
       case 15: return(PERIOD_M15);
       case 30: return(PERIOD_M30);
       case 60: return(PERIOD_H1);
       case 240: return(PERIOD_H4);
       case 1440: return(PERIOD_D1);
       case 10080: return(PERIOD_W1);
       case 43200: return(PERIOD_MN1);
       case 16385: return(PERIOD_H1);
       case 16386: return(PERIOD_H2);
       case 16387: return(PERIOD_H3);
       case 16388: return(PERIOD_H4);
       case 16390: return(PERIOD_H6);
       case 16392: return(PERIOD_H8);
       case 16396: return(PERIOD_H12);
       case 16408: return(PERIOD_D1);
       case 32769: return(PERIOD_W1);
       case 49153: return(PERIOD_MN1);
       default: return(PERIOD_CURRENT);
    }
  }

};

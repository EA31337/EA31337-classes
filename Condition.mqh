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

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Provides integration with market conditions.
 */

// Prevents processing this includes file for the second time.
#ifndef CONDITION_MQH
#define CONDITION_MQH

// Includes.
#include "Account.mqh"
#include "Chart.mqh"
#include "DateTime.mqh"
#include "DictStruct.mqh"
#include "Market.mqh"
#include "Object.mqh"
#include "Order.mqh"
#include "Trade.mqh"

// Define an assert macros.
#define METHOD(method, no) ((method & (1<<no)) == 1<<no)

// Define market event conditions.
#ifndef MARKET_EVENT_ENUM
  #define MARKET_EVENT_ENUM
  enum ENUM_MARKET_EVENT {
    C_EVENT_NONE          =  0, // None
    C_AC_BUY_SELL         =  1, // AC on buy/sell
    C_AD_BUY_SELL         =  2, // AD on buy/sell
    C_ADX_BUY_SELL        =  3, // ADX on buy/sell
    C_ALLIGATOR_BUY_SELL  =  4, // Alligator on buy/sell
    C_ATR_BUY_SELL        =  5, // ATR on buy/sell
    C_AWESOME_BUY_SELL    =  6, // Awesome on buy/sell
    C_BANDS_BUY_SELL      =  7, // Bands on buy/sell
    C_BEARSPOWER_BUY_SELL =  8, // BearsPower on buy/sell
    C_BULLSPOWER_BUY_SELL = 40, // BullsPower on buy/sell
    C_BWMFI_BUY_SELL      = 10, // BWMFI on buy/sell
    C_CCI_BUY_SELL        = 11, // CCI on buy/sell
    C_DEMARKER_BUY_SELL   = 12, // DeMarker on buy/sell
    C_ENVELOPES_BUY_SELL  = 13, // Envelopes on buy/sell
    C_FORCE_BUY_SELL      = 14, // Force on buy/sell
    C_FRACTALS_BUY_SELL   = 15, // Fractals on buy/sell
    C_GATOR_BUY_SELL      = 16, // Gator on buy/sell
    C_ICHIMOKU_BUY_SELL   = 17, // Ichimoku on buy/sell
    C_MA_BUY_SELL         = 18, // MA on buy/sell
    C_MACD_BUY_SELL       = 19, // MACD on buy/sell
    C_MFI_BUY_SELL        = 20, // MFI on buy/sell
    C_MOMENTUM_BUY_SELL   = 21, // Momentum on buy/sell
    C_OBV_BUY_SELL        = 22, // OBV on buy/sell
    C_OSMA_BUY_SELL       = 23, // OSMA on buy/sell
    C_RSI_BUY_SELL        = 24, // RSI on buy/sell
    C_RVI_BUY_SELL        = 25, // RVI on buy/sell
    C_SAR_BUY_SELL        = 26, // SAR on buy/sell
    C_STDDEV_BUY_SELL     = 27, // StdDev on buy/sell
    C_STOCHASTIC_BUY_SELL = 28, // Stochastic on buy/sell
    C_WPR_BUY_SELL        = 29, // WPR on buy/sell
    C_ZIGZAG_BUY_SELL     = 30, // ZigZag on buy/sell
    C_MA_FAST_SLOW_OPP    = 31, // MA Fast&Slow opposite
    C_MA_FAST_MED_OPP     = 32, // MA Fast&Med opposite
    C_MA_MED_SLOW_OPP     = 33, // MA Med&Slow opposite
  #ifdef __advanced__
    C_CUSTOM1_BUY_SELL    = 34, // Custom 1 on buy/sell
    C_CUSTOM2_BUY_SELL    = 35, // Custom 2 on buy/sell
    C_CUSTOM3_BUY_SELL    = 36, // Custom 3 on buy/sell
    C_CUSTOM4_MARKET_COND = 37, // Custom 4 market condition
    C_CUSTOM5_MARKET_COND = 38, // Custom 5 market condition
    C_CUSTOM6_MARKET_COND = 39, // Custom 6 market condition
  #endif
  };
#endif

// Defines condition statements (operators).
enum ENUM_CONDITION_STATEMENT {
  COND_OR  = 1, // Use OR statement.
  COND_AND = 2, // Use AND statement.
  COND_SEQ = 3, // Use sequential checks.
  FINAL_ENUM_COND_STATEMENT
};

// Defines condition types.
enum ENUM_CONDITION_TYPE {
  COND_TYPE_ACCOUNT,   // Account condition.
  COND_TYPE_CHART,     // Chart condition.
  COND_TYPE_DATETIME,  // Datetime condition.
  COND_TYPE_INDICATOR, // Indicator condition.
  COND_TYPE_MARKET,    // Market condition.
  COND_TYPE_ORDER,     // Order condition.
  COND_TYPE_TRADE,     // Trade condition.
  FINAL_CONDITION_TYPE_ENTRY
};

// Structs.
struct ConditionArgs {
  DictStruct<short, MqlParam> *args;              // Arguments.
};
struct ConditionEntry {
  bool                        active;             // State of the condition.
  datetime                    last_check;         // Time of latest check.
  datetime                    last_success;       // Time of previous check.
  long                        cond_id;            // Condition ID.
  void                        *obj;               // Reference to generic condition's object.
  ENUM_CONDITION_STATEMENT    next_statement;     // Statement type of the next condition.
  ENUM_CONDITION_TYPE         type;               // Condition type.
  ENUM_TIMEFRAMES             frequency;          // How often to check.
  ConditionArgs               args;               // Condition arguments.
  // Constructor.
  void ConditionEntry() : type(FINAL_CONDITION_TYPE_ENTRY), cond_id(WRONG_VALUE) { Init(); }
  void ConditionEntry(long _cond_id, ENUM_CONDITION_TYPE _type) : type(_type), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_ACCOUNT_CONDITION _cond_id) : type(COND_TYPE_ACCOUNT), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_CHART_CONDITION _cond_id) : type(COND_TYPE_CHART), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_DATETIME_CONDITION _cond_id) : type(COND_TYPE_DATETIME), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_MARKET_CONDITION _cond_id) : type(COND_TYPE_MARKET), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_ORDER_CONDITION _cond_id) : type(COND_TYPE_ORDER), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_TRADE_CONDITION _cond_id) : type(COND_TYPE_TRADE), cond_id(_cond_id) { Init(); }
  // Deconstructor.
  void ~ConditionEntry() { Object::Delete(obj); }
  // Operator overloading methods.
  //void operator= (const Entry&) {}
  // Other methods.
  void Init() {
    active = true;
    last_check = last_success = 0;
    next_statement = COND_AND;
  }
  void SetArgs(const ConditionArgs &_args) {
    args = _args;
  }
  void SetObject(void *_obj) {
    Object::Delete(obj);
    obj = _obj;
  }
};

/**
 * Condition class.
 */
class Condition {
 public:
  // Enums.
  /*
  // Define market conditions.
  enum ENUM_MARKET_CONDITION_NEW {
    MARKET_COND_PERIOD_PEAK   = 01, // Peak price per period
    MARKET_COND_PRICE_DROP    = 02, // Sudden price drop
    MARKET_COND_NEW_PERIOD    = 03, // New period started
    MARKET_COND_AT_HOUR       = 04, // Market at specific hour
    // COND_MRT_MA1_FS_ORDERS_OPP  = 11, // MA1 Fast&Slow orders-based opposite
    // COND_MRT_MA5_FS_ORDERS_OPP  = 12, // MA5 Fast&Slow orders-based opposite
    // COND_MRT_MA15_FS_ORDERS_OPP = 13, // MA15 Fast&Slow orders-based opposite
    // COND_MRT_MA30_FS_ORDERS_OPP = 14, // MA30 Fast&Slow orders-based opposite
    // COND_MRT_MA1_FS_TREND_OPP   = 15, // MA1 Fast&Slow trend-based opposite
    // COND_MRT_MA5_FS_TREND_OPP   = 16, // MA5 Fast&Slow trend-based opposite
    // COND_MRT_MA15_FS_TREND_OPP  = 17, // MA15 Fast&Slow trend-based opposite
    // COND_MRT_MA30_FS_TREND_OPP  = 18, // MA30 Fast&Slow trend-based opposite
    MARKET_COND_NONE          = 11, // None (inactive)
  };
  */

 protected:
  // Class variables.
  Log *logger;

 public:

  // Class variables.
  DictStruct<short, ConditionEntry> *cond;

  /* Special methods */

  /**
   * Class constructor.
   */
  Condition() {
    Init();
  }
  Condition(ConditionEntry &_entry) {
    Init();
    cond.Push(_entry);
  }
  Condition(long _cond_id, ENUM_CONDITION_TYPE _type) {
    Init();
    ConditionEntry _entry(_cond_id, _type);
    cond.Push(_entry);
  }
  template <typename T>
  Condition(T _cond_id) {
    Init();
    ConditionEntry _entry(_cond_id);
    cond.Push(_entry);
  }
  template <typename T>
  Condition(T _cond_id, const ConditionArgs &_args) {
    Init();
    ConditionEntry _entry(_cond_id);
    _entry.SetArgs(_args);
    cond.Push(_entry);
  }

  /**
   * Class copy constructor.
   */
  Condition(Condition &_cond) {
    Init();
    cond = _cond.GetCondition();
  }

  /**
   * Class deconstructor.
   */
  ~Condition() {
    //Object::Delete(trade);
  }

  /**
   * Initialize class variables.
   */
  void Init() {
    cond = new DictStruct<short, ConditionEntry>();
  }

  /* Main methods */

  /**
   * Test condition.
   */
  bool Test() {
    bool _result = false;
    for (DictStructIterator<short, ConditionEntry> iter = cond.Begin(); iter.IsValid(); ++iter) {
      ConditionEntry _cond = iter.Value();
      switch (_cond.type) {
        case COND_TYPE_ACCOUNT:   // Account condition.
          break;
        case COND_TYPE_CHART:     // Chart condition.
          break;
        case COND_TYPE_DATETIME:  // Datetime condition.
          break;
        case COND_TYPE_INDICATOR: // Indicator condition.
          break;
        case COND_TYPE_MARKET:    // Market condition.
          break;
        case COND_TYPE_ORDER:     // Order condition.
          break;
        case COND_TYPE_TRADE:     // Trade condition.
          break;
      //_cond.cond_id
      }
    }
    return _result;
  }

  /* Other methods */

  /**
   * Check conditions.
   */
  /*
  bool CheckCondition(ENUM_COND_STATEMENT _operator = COND_AND) {
    bool _result = (_operator != COND_OR);
    for (int i = 0; i < ArraySize(conditions); i++) {
      bool _cond = CheckAccountCondition(i) && CheckMarketCondition(i);
      conditions[i].last_success = (_cond ? TimeCurrent() : conditions[i].last_success);
      conditions[i].last_check = TimeCurrent();
      switch (_operator) {
        case COND_OR:
          _result |= _cond;
          break;
        case COND_SEQ:
          if (conditions[i].last_success > 0) {
            _result &= _cond;
          } else {
            break;
          }
        case COND_AND:
        default:
          _result &= _cond;
          break;
      }
    }
    return _result;
  }
  */

  /**
   * Text representation of condition.
   */
  /*
  string ToString(bool _short = true, string dlm = ";") {
    string _out = "";
    for (int i = 0; i < ArraySize(conditions); i++) {
      //_out += conditions[i].account_cond != COND_ACC_NONE ? "Acc: " + EnumToString(conditions[i].account_cond) + dlm: "";
      _out += conditions[i].market_cond != MARKET_COND_NONE ? "Mkt: " + EnumToString(conditions[i].market_cond) + dlm : "";
      _out += conditions[i].period != NULL ? EnumToString(conditions[i].period) + dlm : "";
      _out += conditions[i].indicator != INDI_NONE ? "I: " + EnumToString(conditions[i].indicator) + dlm : "";
      //_out += conditions[i].strategy != S_NONE ? "S: " + EnumToString(conditions[i].strategy) + dlm : "";
    }
    StringReplace(_out, "_LT", _short ? "<" : " lower than");
    StringReplace(_out, "_GT", _short ? ">" : " greater than");
    StringReplace(_out, "_DBAL", _short ? " d.bal." : " daily balance");
    StringReplace(_out, "_WBAL", _short ? " w.bal." : " weekly balance");
    StringReplace(_out, "_MBAL", _short ? " m.bal." : " monthly balance");
    StringReplace(_out, "_BAL", " bal.");
    StringReplace(_out, "_CDAY", _short ? "curr. day" : " current day");
    StringReplace(_out, "_PDAY", _short ? "prev. day" : " previous day");
    StringToLower(_out);
    return _out;
  }
  */

  /* Getters */

  /**
   * Returns conditions.
   */
  DictStruct<short, ConditionEntry> *GetCondition() {
    return cond;
  }

  /* Setters */

};
#endif // CONDITION_MQH

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
 * Provides integration with conditions.
 */

// Prevents processing this includes file for the second time.
#ifndef CONDITION_MQH
#define CONDITION_MQH

// Forward class declaration.
class Condition;

// Includes.
#include "Account.mqh"
#include "Chart.mqh"
#include "DateTime.mqh"
#include "DictStruct.mqh"
#include "Indicator.mqh"
#include "Market.mqh"
#include "Math.mqh"
#include "Object.mqh"
#include "Order.mqh"
#include "Trade.mqh"

// Define market event conditions.
#ifndef MARKET_EVENT_ENUM
#define MARKET_EVENT_ENUM
enum ENUM_MARKET_EVENT {
  C_EVENT_NONE = 0,            // None
  C_AC_BUY_SELL = 1,           // AC on buy/sell
  C_AD_BUY_SELL = 2,           // AD on buy/sell
  C_ADX_BUY_SELL = 3,          // ADX on buy/sell
  C_ALLIGATOR_BUY_SELL = 4,    // Alligator on buy/sell
  C_ATR_BUY_SELL = 5,          // ATR on buy/sell
  C_AWESOME_BUY_SELL = 6,      // Awesome on buy/sell
  C_BANDS_BUY_SELL = 7,        // Bands on buy/sell
  C_BEARSPOWER_BUY_SELL = 8,   // BearsPower on buy/sell
  C_BULLSPOWER_BUY_SELL = 40,  // BullsPower on buy/sell
  C_BWMFI_BUY_SELL = 10,       // BWMFI on buy/sell
  C_CCI_BUY_SELL = 11,         // CCI on buy/sell
  C_DEMARKER_BUY_SELL = 12,    // DeMarker on buy/sell
  C_ENVELOPES_BUY_SELL = 13,   // Envelopes on buy/sell
  C_FORCE_BUY_SELL = 14,       // Force on buy/sell
  C_FRACTALS_BUY_SELL = 15,    // Fractals on buy/sell
  C_GATOR_BUY_SELL = 16,       // Gator on buy/sell
  C_ICHIMOKU_BUY_SELL = 17,    // Ichimoku on buy/sell
  C_MA_BUY_SELL = 18,          // MA on buy/sell
  C_MACD_BUY_SELL = 19,        // MACD on buy/sell
  C_MFI_BUY_SELL = 20,         // MFI on buy/sell
  C_MOMENTUM_BUY_SELL = 21,    // Momentum on buy/sell
  C_OBV_BUY_SELL = 22,         // OBV on buy/sell
  C_OSMA_BUY_SELL = 23,        // OSMA on buy/sell
  C_RSI_BUY_SELL = 24,         // RSI on buy/sell
  C_RVI_BUY_SELL = 25,         // RVI on buy/sell
  C_SAR_BUY_SELL = 26,         // SAR on buy/sell
  C_STDDEV_BUY_SELL = 27,      // StdDev on buy/sell
  C_STOCHASTIC_BUY_SELL = 28,  // Stochastic on buy/sell
  C_WPR_BUY_SELL = 29,         // WPR on buy/sell
  C_ZIGZAG_BUY_SELL = 30,      // ZigZag on buy/sell
  C_MA_FAST_SLOW_OPP = 31,     // MA Fast&Slow opposite
  C_MA_FAST_MED_OPP = 32,      // MA Fast&Med opposite
  C_MA_MED_SLOW_OPP = 33,      // MA Med&Slow opposite
#ifdef __advanced__
  C_CUSTOM1_BUY_SELL = 34,     // Custom 1 on buy/sell
  C_CUSTOM2_BUY_SELL = 35,     // Custom 2 on buy/sell
  C_CUSTOM3_BUY_SELL = 36,     // Custom 3 on buy/sell
  C_CUSTOM4_MARKET_COND = 37,  // Custom 4 market condition
  C_CUSTOM5_MARKET_COND = 38,  // Custom 5 market condition
  C_CUSTOM6_MARKET_COND = 39,  // Custom 6 market condition
#endif
};
#endif

// Defines condition entry flags.
enum ENUM_CONDITION_ENTRY_FLAGS {
  COND_ENTRY_FLAG_NONE = 0,
  COND_ENTRY_FLAG_IS_ACTIVE = 1,
  COND_ENTRY_FLAG_IS_EXPIRED = 2,
  COND_ENTRY_FLAG_IS_INVALID = 4,
  COND_ENTRY_FLAG_IS_READY = 8
};

// Defines condition statements (operators).
enum ENUM_CONDITION_STATEMENT {
  COND_AND = 1,  // Use AND statement.
  COND_OR,       // Use OR statement.
  COND_SEQ,      // Use sequential checks.
  FINAL_ENUM_COND_STATEMENT
};

// Defines condition types.
enum ENUM_CONDITION_TYPE {
  COND_TYPE_ACCOUNT = 1,  // Account condition.
  COND_TYPE_ACTION,       // Action condition.
  COND_TYPE_CHART,        // Chart condition.
  COND_TYPE_DATETIME,     // Datetime condition.
  COND_TYPE_INDICATOR,    // Indicator condition.
  COND_TYPE_MARKET,       // Market condition.
  COND_TYPE_MATH,         // Math condition.
  COND_TYPE_ORDER,        // Order condition.
  COND_TYPE_TRADE,        // Trade condition.
  FINAL_CONDITION_TYPE_ENTRY
};

// Structs.
struct ConditionEntry {
  unsigned char flags;                      // Condition flags.
  datetime last_check;                      // Time of the latest check.
  datetime last_success;                    // Time of the last success.
  long cond_id;                             // Condition ID.
  short tries;                              // Number of successful tries left.
  void *obj;                                // Reference to associated object.
  ENUM_CONDITION_STATEMENT next_statement;  // Statement type of the next condition.
  ENUM_CONDITION_TYPE type;                 // Condition type.
  ENUM_TIMEFRAMES frequency;                // How often to check.
  MqlParam args[];                          // Condition arguments.
  // Constructor.
  void ConditionEntry() : type(FINAL_CONDITION_TYPE_ENTRY), cond_id(WRONG_VALUE) { Init(); }
  void ConditionEntry(long _cond_id, ENUM_CONDITION_TYPE _type) : type(_type), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_ACCOUNT_CONDITION _cond_id) : type(COND_TYPE_ACCOUNT), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_CHART_CONDITION _cond_id) : type(COND_TYPE_CHART), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_DATETIME_CONDITION _cond_id) : type(COND_TYPE_DATETIME), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_INDICATOR_CONDITION _cond_id) : type(COND_TYPE_INDICATOR), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_MARKET_CONDITION _cond_id) : type(COND_TYPE_MARKET), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_ORDER_CONDITION _cond_id) : type(COND_TYPE_ORDER), cond_id(_cond_id) { Init(); }
  void ConditionEntry(ENUM_TRADE_CONDITION _cond_id) : type(COND_TYPE_TRADE), cond_id(_cond_id) { Init(); }
  // Deconstructor.
  void ~ConditionEntry() {
    // Object::Delete(obj);
  }
  // Flag methods.
  bool HasFlag(unsigned char _flag) { return bool(flags & _flag); }
  void AddFlags(unsigned char _flags) { flags |= _flags; }
  void RemoveFlags(unsigned char _flags) { flags &= ~_flags; }
  void SetFlag(ENUM_CONDITION_ENTRY_FLAGS _flag, bool _value) {
    if (_value)
      AddFlags(_flag);
    else
      RemoveFlags(_flag);
  }
  void SetFlags(unsigned char _flags) { flags = _flags; }
  // State methods.
  bool IsActive() { return HasFlag(COND_ENTRY_FLAG_IS_ACTIVE); }
  bool IsExpired() { return HasFlag(COND_ENTRY_FLAG_IS_EXPIRED); }
  bool IsReady() { return HasFlag(COND_ENTRY_FLAG_IS_READY); }
  bool IsValid() { return !HasFlag(COND_ENTRY_FLAG_IS_INVALID); }
  // Setter methods.
  void AddArg(MqlParam &_arg) {
    // @todo: Add another value to args[].
  }
  void Init() {
    flags = COND_ENTRY_FLAG_NONE;
    AddFlags(COND_ENTRY_FLAG_IS_ACTIVE);
    last_check = last_success = 0;
    next_statement = COND_AND;
    tries = 1;
  }
  void SetArgs(MqlParam &_args[]) {
    // @todo: for().
  }
  void SetObject(void *_obj) {
    Object::Delete(obj);
    obj = _obj;
  }
  void SetTries(short _count) { tries = _count; }
};

/**
 * Condition class.
 */
class Condition {
 public:
 protected:
  // Class variables.
  Log *logger;

 public:
  // Class variables.
  DictStruct<short, ConditionEntry> *conds;

  /* Special methods */

  /**
   * Class constructor.
   */
  Condition() { Init(); }
  Condition(ConditionEntry &_entry) {
    Init();
    conds.Push(_entry);
  }
  Condition(long _cond_id, ENUM_CONDITION_TYPE _type) {
    Init();
    ConditionEntry _entry(_cond_id, _type);
    conds.Push(_entry);
  }
  template <typename T>
  Condition(T _cond_id, void *_obj = NULL) {
    Init();
    ConditionEntry _entry(_cond_id);
    if (_obj != NULL) {
      _entry.SetObject(_obj);
    }
    conds.Push(_entry);
  }
  template <typename T>
  Condition(T _cond_id, MqlParam &_args[], void *_obj = NULL) {
    Init();
    ConditionEntry _entry(_cond_id);
    _entry.SetArgs(_args);
    if (_obj != NULL) {
      _entry.SetObject(_obj);
    }
    conds.Push(_entry);
  }

  /**
   * Class copy constructor.
   */
  Condition(Condition &_cond) {
    Init();
    conds = _cond.GetConditions();
  }

  /**
   * Class deconstructor.
   */
  ~Condition() { delete conds; }

  /**
   * Initialize class variables.
   */
  void Init() { conds = new DictStruct<short, ConditionEntry>(); }

  /* Main methods */

  /**
   * Test conditions.
   */
  bool Test() {
    bool _result = false, _prev_result = true;
    for (DictStructIterator<short, ConditionEntry> iter = conds.Begin(); iter.IsValid(); ++iter) {
      bool _curr_result = false;
      ConditionEntry _entry = iter.Value();
      if (!_entry.IsValid()) {
        // Ignore invalid entries.
        continue;
      }
      if (_entry.IsActive()) {
        switch (_entry.next_statement) {
          case COND_AND:
            _curr_result = _prev_result && Test(_entry);
            break;
          case COND_OR:
            _curr_result = _prev_result || Test(_entry);
            break;
          case COND_SEQ:
            _curr_result = Test(_entry);
            if (!_curr_result) {
              // Do not check further conditions when the current condition is false.
              return false;
            }
        }
        _result = _prev_result = _curr_result;
      }
    }
    return _result;
  }

  /**
   * Test specific condition.
   */
  bool Test(ConditionEntry &_entry) {
    bool _result = false;
    switch (_entry.type) {
      case COND_TYPE_ACCOUNT:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Account *)_entry.obj).Condition((ENUM_ACCOUNT_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
      case COND_TYPE_CHART:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Chart *)_entry.obj).Condition((ENUM_CHART_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
      case COND_TYPE_DATETIME:
        if (Object::IsValid(_entry.obj)) {
          _result = ((DateTime *)_entry.obj).Condition((ENUM_DATETIME_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = DateTime::Condition((ENUM_DATETIME_CONDITION)_entry.cond_id, _entry.args);
        }
        break;
      case COND_TYPE_INDICATOR:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Indicator *)_entry.obj).Condition((ENUM_INDICATOR_CONDITION)_entry.cond_id, _entry.args);
        } else {
          // Static method not supported.
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
      case COND_TYPE_MARKET:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Market *)_entry.obj).Condition((ENUM_MARKET_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
      case COND_TYPE_MATH:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Math *)_entry.obj).Condition((ENUM_MATH_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
      case COND_TYPE_ORDER:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Order *)_entry.obj).Condition((ENUM_ORDER_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
      case COND_TYPE_TRADE:
        if (Object::IsValid(_entry.obj)) {
          _result = ((Trade *)_entry.obj).Condition((ENUM_TRADE_CONDITION)_entry.cond_id, _entry.args);
        } else {
          _result = false;
          _entry.AddFlags(COND_ENTRY_FLAG_IS_INVALID);
        }
        break;
    }
    if (_result) {
      _entry.last_success = TimeCurrent();
      _entry.tries--;
    }
    _entry.last_check = TimeCurrent();
    return _result;
  }

  /* Other methods */

  /* Getters */

  /**
   * Returns conditions.
   */
  DictStruct<short, ConditionEntry> *GetConditions() { return conds; }

  /* Setters */
};
#endif  // CONDITION_MQH
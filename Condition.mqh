//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2019, 31337 Investments Ltd |
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

// Properties.
#property strict

// Includes.
#include "Trade.mqh"
#include "Indicator.mqh"
//#include "Strategies.mqh"

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

// Define market conditions.
enum ENUM_MARKET_CONDITION {
  C_MARKET_NONE        = 00, // None (false).
  C_MARKET_TRUE        = 01, // Always true
  C_MA1_FS_ORDERS_OPP  = 02, // MA1 Fast&Slow orders-based opposite
  C_MA5_FS_ORDERS_OPP  = 03, // MA5 Fast&Slow orders-based opposite
  C_MA15_FS_ORDERS_OPP = 04, // MA15 Fast&Slow orders-based opposite
  C_MA30_FS_ORDERS_OPP = 05, // MA30 Fast&Slow orders-based opposite
  C_MA1_FS_TREND_OPP   = 06, // MA1 Fast&Slow trend-based opposite
  C_MA5_FS_TREND_OPP   = 07, // MA5 Fast&Slow trend-based opposite
  C_MA15_FS_TREND_OPP  = 08, // MA15 Fast&Slow trend-based opposite
  C_MA30_FS_TREND_OPP  = 09, // MA30 Fast&Slow trend-based opposite
  C_DAILY_PEAK         = 10, // Daily peak price
  C_WEEKLY_PEAK        = 11, // Weekly peak price
  C_MONTHLY_PEAK       = 12, // Monthly peak price
  C_MARKET_BIG_DROP    = 13, // Sudden price drop
  C_MARKET_VBIG_DROP   = 14, // Very big price drop
  C_MARKET_AT_HOUR     = 15, // At specific hour
  C_NEW_HOUR           = 16, // New hour
  C_NEW_DAY            = 17, // New day
  C_NEW_WEEK           = 18, // New week
  C_NEW_MONTH          = 19, // New month
};

/**
 * Condition class.
 */
class Condition {
public:
  // Enums.
  // Define account conditions.
  enum ENUM_ACCOUNT_CONDITION {
    COND_ACC_EQUITY_LOSS      = 01, // Equity in loss
    COND_ACC_EQUITY_PROFIT    = 02, // Equity in profit
    COND_ACC_BALANCE_LOSS     = 03, // Balance in loss
    COND_ACC_BALANCE_PROFIT   = 04, // Balance in profit
    COND_ACC_MARGIN_USED      = 05, // Margin used
    COND_ACC_DBAL_LT_WEEKLY   = 06, // Daily balance lower than weekly
    COND_ACC_DBAL_GT_WEEKLY   = 07, // Daily balance greater than weekly
    COND_ACC_WBAL_LT_MONTHLY  = 08, // Weekly balance lower than monthly
    COND_ACC_WBAL_GT_MONTHLY  = 09, // Weekly balance greater than monthly
    COND_ACC_IN_TREND         = 10, // Open orders in trend
    COND_ACC_IN_NON_TREND     = 11, // Open orders are against trend
    COND_ACC_CDAY_IN_PROFIT   = 12, // Current day in profit
    COND_ACC_CDAY_IN_LOSS     = 13, // Current day in loss
    COND_ACC_PDAY_IN_PROFIT   = 14, // Previous day in profit
    COND_ACC_PDAY_IN_LOSS     = 15, // Previous day in loss
    COND_ACC_MAX_ORDERS       = 16, // Max orders reached
    COND_ACC_NONE             = 17, // None (inactive)
  };

  // Note: Trend-based closures are using TrendMethodAction.

  // Define market conditions.
  enum ENUM_MARKET_CONDITION_NEW {
    COND_MARKET_PERIOD_PEAK   = 01, // Peak price per period
    COND_MARKET_PRICE_DROP    = 02, // Sudden price drop
    COND_MARKET_NEW_PERIOD    = 03, // New period started
    COND_MARKET_AT_HOUR       = 04, // Market at specific hour
    // COND_MRT_MA1_FS_ORDERS_OPP  = 11, // MA1 Fast&Slow orders-based opposite
    // COND_MRT_MA5_FS_ORDERS_OPP  = 12, // MA5 Fast&Slow orders-based opposite
    // COND_MRT_MA15_FS_ORDERS_OPP = 13, // MA15 Fast&Slow orders-based opposite
    // COND_MRT_MA30_FS_ORDERS_OPP = 14, // MA30 Fast&Slow orders-based opposite
    // COND_MRT_MA1_FS_TREND_OPP   = 15, // MA1 Fast&Slow trend-based opposite
    // COND_MRT_MA5_FS_TREND_OPP   = 16, // MA5 Fast&Slow trend-based opposite
    // COND_MRT_MA15_FS_TREND_OPP  = 17, // MA15 Fast&Slow trend-based opposite
    // COND_MRT_MA30_FS_TREND_OPP  = 18, // MA30 Fast&Slow trend-based opposite
    COND_MARKET_NONE          = 11, // None (inactive)
  };

  // Define condition operators.
  enum ENUM_COND_STATEMENT {
    COND_OR  = 01, // Use OR statement.
    COND_AND = 02, // Use AND statement.
    COND_SEQ = 03, // Use sequential checks.
    FINAL_ENUM_COND_STATEMENT
  };
  // Structs.
  struct ConditionEntry {
    bool                    enabled;            // State of the condition (enabled or disabled).
    datetime                last_check;         // Time of latest check.
    datetime                last_success;       // Time of previous check.
    ENUM_TIMEFRAMES         frequency;          // How often to check.
    ENUM_ACCOUNT_CONDITION  account_cond;       // Account condition.
    ENUM_MARKET_CONDITION_NEW market_cond;      // Market condition.
    ENUM_TIMEFRAMES         period;             // Associated period.
    ENUM_INDICATOR_TYPE     indicator;          // Associated indicator.
    //ENUM_STRATEGY           strategy;           // Associated strategy.
    double                  args[5];            // Extra arguments.
  };

protected:
  // Class variables.
  ConditionEntry conditions[];
  Trade *trade;
  Log *logger;
  //Market *market;
  //Chart *tf;

public:

  void Condition(ConditionEntry &_condition, Trade *_trade)
  : trade(_trade != NULL ? _trade : new Trade),
    logger(_trade.Logger())
  {
    AddCondition(_condition);
  }

  /**
   * Class deconstructor.
   */
  void ~Condition() {
    Object::Delete(trade);
  }

  /**
   * Adds new condition.
   */
  bool AddCondition(ConditionEntry &_condition, double _arg1 = NULL, double _arg2 = NULL) {
    uint _size = ArraySize(conditions);
    if (!ArrayResize(conditions, _size + 1, 10)) {
      logger.Error(StringFormat("Cannot resize array (size=%d).", _size), __FUNCTION__);
      return false;
    }
    conditions[_size] = _condition; // @fixme: Structure have objects.
    conditions[_size].last_check = 0;
    conditions[_size].last_success = 0;
    conditions[_size].args[0] = _arg1;
    conditions[_size].args[1] = _arg2;
    return true;
  }

  /**
   * Adds new argument to the selected condition.
   */
  /*
  bool AddArgument(ConditionEntry &_condition, double _value) {
    uint _size = ArraySize(_condition.args);
    if (!ArrayResize(_condition.args, ++_size, 10)) {
      logger.Error(StringFormat("Cannot resize array (size=%d).", _size), __FUNCTION__);
      return false;
    }
    _condition.args[_size] = _value;
    return true;
  }
  */

  /**
   * Check conditions.
   */
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

  /**
   * Check for current account condition.
   */
  bool CheckAccountCondition(uint _index = 0) {
    switch (conditions[_index].account_cond) {
      case COND_ACC_EQUITY_LOSS:    // Equity in loss
        return trade.Account().GetEquity() < trade.Account().GetRealBalance() / 100 * (100 - GetArg(_index, 0, 10));
      case COND_ACC_EQUITY_PROFIT:  // Equity in profit
        return trade.Account().GetEquity() > trade.Account().GetRealBalance() / 100 * (100 + GetArg(_index, 0, 10));
      case COND_ACC_BALANCE_LOSS:   // Balance in loss
        return trade.Account().GetProfit() < trade.Account().GetProfit() / 100 * (100 - GetArg(_index, 0, 10));
      case COND_ACC_BALANCE_PROFIT: // Balance in profit
        return trade.Account().GetProfit() > trade.Account().GetProfit() / 100 * (100 + GetArg(_index, 0, 10));
      case COND_ACC_MARGIN_USED:    // Margin used
        // Note that in some accounts, Stop Out will occur in your account
        // when equity reaches 70% of your used margin resulting in immediate closing of all positions.
        return trade.Account().GetMarginUsed() >= trade.Account().GetEquity() / 100 *  GetArg(_index, 0, 80);
      case COND_ACC_DBAL_LT_WEEKLY:  // Daily balance lower than weekly.
        return
          trade.Account().GetStatValue(ACC_BALANCE, ACC_DAILY,  (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX)))) <
          trade.Account().GetStatValue(ACC_BALANCE, ACC_WEEKLY, (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX))));
      case COND_ACC_DBAL_GT_WEEKLY:  // Daily balance greater than weekly.
        return
          trade.Account().GetStatValue(ACC_BALANCE, ACC_DAILY,  (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX)))) >
          trade.Account().GetStatValue(ACC_BALANCE, ACC_WEEKLY, (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX))));
      case COND_ACC_WBAL_LT_MONTHLY: // Weekly balance lower than monthly.
        return
          trade.Account().GetStatValue(ACC_BALANCE, ACC_WEEKLY,  (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX)))) <
          trade.Account().GetStatValue(ACC_BALANCE, ACC_MONTHLY, (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, 1))));
      case COND_ACC_WBAL_GT_MONTHLY: // Weekly balance greater than monthly.
        return
          trade.Account().GetStatValue(ACC_BALANCE, ACC_WEEKLY,  (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX)))) >
          trade.Account().GetStatValue(ACC_BALANCE, ACC_MONTHLY, (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_MAX))));
      case COND_ACC_IN_TREND:       // Open orders in trend
        return trade.Account().Trades().GetOrderTypeByOrders() == trade.GetTrendOp((int) GetArg(_index, 0, 113), trade.Chart().GetTf());
      case COND_ACC_IN_NON_TREND:   // Open orders are against trend
        return trade.Account().Trades().GetOrderTypeByOrders() != trade.GetTrendOp((int) GetArg(_index, 0, 113), trade.Chart().GetTf());
      case COND_ACC_CDAY_IN_PROFIT: // Current day in profit
        return trade.Account().GetStatValue(ACC_PROFIT, ACC_DAILY, (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_AVG)))) > 0;
      case COND_ACC_CDAY_IN_LOSS:   // Current day in loss
        return trade.Account().GetStatValue(ACC_PROFIT, ACC_DAILY, (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_AVG)))) < 0;
      case COND_ACC_PDAY_IN_PROFIT: // Previous day in profit
        return trade.Account().GetStatValue(ACC_PROFIT, ACC_DAILY, (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_AVG))), ACC_VALUE_PREV) > 0;
      case COND_ACC_PDAY_IN_LOSS:   // Previous day in loss
        return trade.Account().GetStatValue(ACC_PROFIT, ACC_DAILY, (ENUM_ACC_STAT_TYPE) fmin(0, fmax(FINAL_ENUM_ACC_STAT_TYPE - 1, GetArg(_index, 0, ACC_VALUE_AVG))), ACC_VALUE_PREV) < 0;
      case COND_ACC_MAX_ORDERS:     // Max orders reached
        // @todo
        return false;
      case COND_ACC_NONE:           // None (inactive)
      default:
        break;
    }
    return false;
  }

  /**
   * Check for current market condition.
   */
  bool CheckMarketCondition(uint _index = 0) {
    switch (conditions[_index].market_cond) {
      case COND_MARKET_PERIOD_PEAK: // Peak price per period
        // If argument is not present, use the daily period by default.
        return trade.Chart().IsPeak(GetPeriod(_index, PERIOD_D1));
      case COND_MARKET_PRICE_DROP:  // Sudden price drop
        // If argument is not present, use 50 pips by default.
        return Convert::ValueToPips(trade.Chart().GetHigh(GetPeriod(_index, PERIOD_CURRENT)) - trade.Chart().GetLow(GetPeriod(_index, PERIOD_CURRENT))) > GetArg(_index, 0, 50);
      case COND_MARKET_NEW_PERIOD:  // New period started
        // If argument is not present, use the current period by default.
        return
          conditions[_index].last_check < trade.Chart().GetBarTime(GetPeriod(_index, PERIOD_CURRENT))
          && TimeCurrent() >= trade.Chart().GetBarTime(GetPeriod(_index, PERIOD_CURRENT));
      case COND_MARKET_AT_HOUR:     // Market at specific hour
        // If argument is not present, use midnight by default.
        return DateTime::Hour() == GetArg(_index, 0, 0);
      // COND_MRT_MA1_FS_ORDERS_OPP  = 11, // MA1 Fast&Slow orders-based opposite
      // COND_MRT_MA5_FS_ORDERS_OPP  = 12, // MA5 Fast&Slow orders-based opposite
      // COND_MRT_MA15_FS_ORDERS_OPP = 13, // MA15 Fast&Slow orders-based opposite
      // COND_MRT_MA30_FS_ORDERS_OPP = 14, // MA30 Fast&Slow orders-based opposite
      // COND_MRT_MA1_FS_TREND_OPP   = 15, // MA1 Fast&Slow trend-based opposite
      // COND_MRT_MA5_FS_TREND_OPP   = 16, // MA5 Fast&Slow trend-based opposite
      // COND_MRT_MA15_FS_TREND_OPP  = 17, // MA15 Fast&Slow trend-based opposite
      // COND_MRT_MA30_FS_TREND_OPP  = 18, // MA30 Fast&Slow trend-based opposite
      default:
        break;
    }
    return false;
  }

  /**
   * Text representation of condition.
   */
  string ToString(bool _short = true, string dlm = ";") {
    string _out = "";
    for (int i = 0; i < ArraySize(conditions); i++) {
      _out += conditions[i].account_cond != COND_ACC_NONE ? "Acc: " + EnumToString(conditions[i].account_cond) + dlm: "";
      _out += conditions[i].market_cond != COND_MARKET_NONE ? "Mkt: " + EnumToString(conditions[i].market_cond) + dlm : "";
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

  /* Class getters */

  /**
   * Get argument of the condition.
   */
  double GetArg(uint _index = 0, uint _arg_no = 0, double _default = 0) {
    // If argument value is zero, then provide the default value (if any).
    return conditions[_index].args[_arg_no] != 0 ? conditions[_index].args[_arg_no] : _default;
  }

  /**
   * Get period of the condition.
   */
  ENUM_TIMEFRAMES GetPeriod(uint _index = 0, ENUM_TIMEFRAMES _default = 0) {
    return conditions[_index].period > 0 ? conditions[_index].period : _default;
  }

};

//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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

/**
 * @file
 * Includes Deal's enums.
 */

#ifndef __MQL__
enum ENUM_DEAL_TYPE {
  DEAL_TYPE_BUY,
  DEAL_TYPE_SELL,
  DEAL_TYPE_BALANCE,
  DEAL_TYPE_CREDIT,
  DEAL_TYPE_CHARGE,
  DEAL_TYPE_CORRECTION,
  DEAL_TYPE_BONUS,
  DEAL_TYPE_COMMISSION,
  DEAL_TYPE_COMMISSION_DAILY,
  DEAL_TYPE_COMMISSION_MONTHLY,
  DEAL_TYPE_COMMISSION_AGENT_DAILY,
  DEAL_TYPE_COMMISSION_AGENT_MONTHLY,
  DEAL_TYPE_INTEREST,
  DEAL_TYPE_BUY_CANCELED,
  DEAL_TYPE_SELL_CANCELED,
  DEAL_DIVIDEND,
  DEAL_DIVIDEND_FRANKED,
  DEAL_TAX
};

enum ENUM_DEAL_ENTRY { DEAL_ENTRY_IN, DEAL_ENTRY_OUT, DEAL_ENTRY_INOUT, DEAL_ENTRY_OUT_BY };

enum ENUM_DEAL_REASON {
  DEAL_REASON_CLIENT,
  DEAL_REASON_MOBILE,
  DEAL_REASON_WEB,
  DEAL_REASON_EXPERT,
  DEAL_REASON_SL,
  DEAL_REASON_TP,
  DEAL_REASON_SO,
  DEAL_REASON_ROLLOVER,
  DEAL_REASON_VMARGIN,
  DEAL_REASON_SPLIT
};

enum ENUM_DEAL_PROPERTY_DOUBLE { DEAL_VOLUME, DEAL_PRICE, DEAL_COMMISSION, DEAL_SWAP, DEAL_PROFIT, DEAL_FEE };

enum ENUM_DEAL_PROPERTY_INTEGER {
  DEAL_TICKET,
  DEAL_ORDER,
  DEAL_TIME,
  DEAL_TIME_MSC,
  DEAL_TYPE,
  DEAL_ENTRY,
  DEAL_MAGIC,
  DEAL_REASON,
  DEAL_POSITION_ID
};

enum ENUM_DEAL_PROPERTY_STRING { DEAL_SYMBOL, DEAL_COMMENT, DEAL_EXTERNAL_ID };
#endif

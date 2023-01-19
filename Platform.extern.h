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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once

// Includes.
#include "Deal.enum.h"
#include "Order.define.h"

// Forward declarations.
class MqlTradeRequest;
class MqlTradeResult;
class MqlTradeCheckResult;

template <typename... Args>
double iCustom(string symbol, int timeframe, string name, Args... args) {
  Alert(__FUNCSIG__, " it not implemented!");
  return 0;
}

/**
 * Returns number of candles for a given symbol and time-frame.
 */
extern int Bars(CONST_REF_TO(string) _symbol, ENUM_TIMEFRAMES _tf);

/**
 * Returns the number of calculated data for the specified indicator.
 */
extern int BarsCalculated(int indicator_handle);

/**
 * Gets data of a specified buffer of a certain indicator in the necessary quantity.
 */
extern int CopyBuffer(int indicator_handle, int buffer_num, int start_pos, int count, ARRAY_REF(double, buffer));

extern int CopyOpen(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count,
                    ARRAY_REF(double, close_array));
extern int CopyHigh(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count,
                    ARRAY_REF(double, close_array));
extern int CopyLow(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count,
                   ARRAY_REF(double, close_array));
extern int CopyClose(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count,
                     ARRAY_REF(double, close_array));

extern unsigned long PositionGetTicket(int _index);

extern long PositionGetInteger(ENUM_POSITION_PROPERTY_INTEGER property_id);

extern double PositionGetDouble(ENUM_POSITION_PROPERTY_DOUBLE property_id);

extern string PositionGetString(ENUM_POSITION_PROPERTY_STRING property_id);

extern int HistoryDealsTotal();

extern unsigned long HistoryDealGetTicket(int index);

extern long HistoryDealGetInteger(unsigned long ticket_number, ENUM_DEAL_PROPERTY_INTEGER property_id);

extern double HistoryDealGetDouble(unsigned long ticket_number, ENUM_DEAL_PROPERTY_DOUBLE property_id);

extern string HistoryDealGetString(unsigned long ticket_number, ENUM_DEAL_PROPERTY_STRING property_id);

extern bool OrderSelect(int index);

extern bool PositionSelectByTicket(int index);

extern bool HistoryOrderSelect(int index);

extern bool OrderSend(const MqlTradeRequest& request, MqlTradeResult& result);

extern bool OrderCheck(const MqlTradeRequest& request, MqlTradeCheckResult& result);

extern unsigned long OrderGetTicket(int index);

extern unsigned long HistoryOrderGetTicket(int index);

extern bool HistorySelectByPosition(long position_id);

extern bool HistoryDealSelect(unsigned long ticket);

extern long OrderGetInteger(ENUM_ORDER_PROPERTY_INTEGER property_id);

extern long HistoryOrderGetInteger(unsigned long ticket_number, ENUM_ORDER_PROPERTY_INTEGER property_id);

extern double OrderGetDouble(ENUM_ORDER_PROPERTY_DOUBLE property_id);

extern double HistoryOrderGetDouble(unsigned long ticket_number, ENUM_ORDER_PROPERTY_DOUBLE property_id);

string OrderGetString(ENUM_ORDER_PROPERTY_STRING property_id);

string HistoryOrderGetString(unsigned long ticket_number, ENUM_ORDER_PROPERTY_STRING property_id);

extern int PositionsTotal();

extern bool HistorySelect(datetime from_date, datetime to_date);

extern int HistoryOrdersTotal();

extern int OrdersTotal();

extern int CopyTickVolume(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count,
                          ARRAY_REF(long, arr));

extern int CopyRealVolume(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count,
                          ARRAY_REF(long, arr));

extern int ChartID();

extern bool OrderCalcMargin(ENUM_ORDER_TYPE _action, string _symbol, double _volume, double _price, double& _margin);

double AccountInfoDouble(ENUM_ACCOUNT_INFO_DOUBLE property_id);

long AccountInfoInteger(ENUM_ACCOUNT_INFO_INTEGER property_id);

string AccountInfoInteger(ENUM_ACCOUNT_INFO_STRING property_id);

#endif

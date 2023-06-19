//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
#include "../Exchange/Account/Account.enum.h"
#include "../Storage/Data.define.h"
#include "../Storage/DateTime.h"
#include "../Storage/Object.extern.h"
#include "Deal.enum.h"
#include "Order.define.h"
#include "Order.enum.h"
#include "Terminal.enum.h"

// Forward declarations.
struct MqlTradeRequest;
struct MqlTradeResult;
struct MqlTradeCheckResult;

template <typename... Args>
double iCustom(string symbol, int timeframe, string name, Args... args) {
  Alert(__FUNCSIG__, " it not implemented!");
  return 0;
}

/**
 * Displays a message in a separate window.
 * @docs: https://www.mql5.com/en/docs/common/alert
 */
extern void Alert(char* argument);
extern void Alert(string argument);

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

extern unsigned int64 PositionGetTicket(int _index);

extern int64 PositionGetInteger(ENUM_POSITION_PROPERTY_INTEGER property_id);

extern double PositionGetDouble(ENUM_POSITION_PROPERTY_DOUBLE property_id);

extern string PositionGetString(ENUM_POSITION_PROPERTY_STRING property_id);

extern int HistoryDealsTotal();

extern unsigned int64 HistoryDealGetTicket(int index);

extern int64 HistoryDealGetInteger(unsigned int64 ticket_number, ENUM_DEAL_PROPERTY_INTEGER property_id);

extern double HistoryDealGetDouble(unsigned int64 ticket_number, ENUM_DEAL_PROPERTY_DOUBLE property_id);

extern string HistoryDealGetString(unsigned int64 ticket_number, ENUM_DEAL_PROPERTY_STRING property_id);

extern bool OrderSelect(int index);

extern bool PositionSelectByTicket(int index);

extern bool HistoryOrderSelect(int index);

extern bool OrderSend(const MqlTradeRequest& request, MqlTradeResult& result);

extern bool OrderCheck(const MqlTradeRequest& request, MqlTradeCheckResult& result);

extern unsigned int64 OrderGetTicket(int index);

extern unsigned int64 HistoryOrderGetTicket(int index);

extern bool HistorySelectByPosition(int64 position_id);

extern bool HistoryDealSelect(unsigned int64 ticket);

extern int64 OrderGetInteger(ENUM_ORDER_PROPERTY_INTEGER property_id);

extern int64 HistoryOrderGetInteger(unsigned int64 ticket_number, ENUM_ORDER_PROPERTY_INTEGER property_id);

extern double OrderGetDouble(ENUM_ORDER_PROPERTY_DOUBLE property_id);

extern double HistoryOrderGetDouble(unsigned int64 ticket_number, ENUM_ORDER_PROPERTY_DOUBLE property_id);

string OrderGetString(ENUM_ORDER_PROPERTY_STRING property_id);

string HistoryOrderGetString(unsigned int64 ticket_number, ENUM_ORDER_PROPERTY_STRING property_id);

extern int PositionsTotal();

extern bool HistorySelect(datetime from_date, datetime to_date);

extern int HistoryOrdersTotal();

extern int OrdersTotal();

extern int CopyTickVolume(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count,
                          ARRAY_REF(int64, arr));

extern int CopyRealVolume(string symbol_name, ENUM_TIMEFRAMES timeframe, int start_pos, int count,
                          ARRAY_REF(int64, arr));

extern int ChartID();

extern bool OrderCalcMargin(ENUM_ORDER_TYPE _action, string _symbol, double _volume, double _price, double& _margin);

extern double AccountInfoDouble(ENUM_ACCOUNT_INFO_DOUBLE property_id);

extern int64 AccountInfoInteger(ENUM_ACCOUNT_INFO_INTEGER property_id);

extern string AccountInfoInteger(ENUM_ACCOUNT_INFO_STRING property_id);

extern string Symbol();

extern string ObjectName(int64 _chart_id, int _pos, int _sub_window = -1, int _type = -1);

extern int ObjectsTotal(int64 chart_id, int type = EMPTY, int window = -1);

extern bool PlotIndexSetString(int plot_index, int prop_id, string prop_value);

extern bool PlotIndexSetInteger(int plot_index, int prop_id, int prop_value);

extern bool ObjectSetInteger(int64 chart_id, string name, ENUM_OBJECT_PROPERTY_INTEGER prop_id, int64 prop_value);

extern bool ObjectSetInteger(int64 chart_id, string name, ENUM_OBJECT_PROPERTY_INTEGER prop_id, int prop_modifier,
                             int64 prop_value);

extern bool ObjectSetDouble(int64 chart_id, string name, ENUM_OBJECT_PROPERTY_DOUBLE prop_id, double prop_value);

extern bool ObjectSetDouble(int64 chart_id, string name, ENUM_OBJECT_PROPERTY_DOUBLE prop_id, int prop_modifier,
                            double prop_value);

extern bool ObjectCreate(int64 _cid, string _name, ENUM_OBJECT _otype, int _swindow, datetime _t1, double _p1);
extern bool ObjectCreate(int64 _cid, string _name, ENUM_OBJECT _otype, int _swindow, datetime _t1, double _p1,
                         datetime _t2, double _p2);

extern bool ObjectMove(int64 chart_id, string name, int point_index, datetime time, double price);

extern bool ObjectDelete(int64 chart_id, string name);

extern int ObjectFind(int64 chart_id, string name);

int GetLastError() { return _LastError; }

void ResetLastError() { _LastError = 0; }

#endif

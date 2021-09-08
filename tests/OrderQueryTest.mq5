//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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

/**
 * @file
 * Test functionality of OrderQuery class.
 */

// Includes.
#include "../OrderQuery.h"
#include "../Test.mqh"

bool Test01() {
  bool _result = true;
  DictStruct<long, Ref<Order>> orders;
  for (int i = 0; i < 10; i++) {
    OrderData _odata;
    _odata.Set<float>(ORDER_PROP_PROFIT, (float)i);
    Ref<Order> _order = new Order(_odata);
    orders.Push(_order);
  }
  OrderQuery _query(orders);
  Ref<Order> _order_profit_best =
      _query.FindPeakViaProp<ENUM_ORDER_PROPERTY_CUSTOM, float>(ORDER_PROP_PROFIT, STRUCT_ENUM(OrderQuery, ORDER_QUERY_OP_GT));
  Ref<Order> _order_profit_worst =
      _query.FindPeakViaProp<ENUM_ORDER_PROPERTY_CUSTOM, float>(ORDER_PROP_PROFIT, STRUCT_ENUM(OrderQuery, ORDER_QUERY_OP_LT));
  assertTrueOrReturnFalse(_order_profit_best.Ptr().Get<float>(ORDER_PROP_PROFIT) == 9,
                          "Best order by profit not correct!");
  assertTrueOrReturnFalse(_order_profit_worst.Ptr().Get<float>(ORDER_PROP_PROFIT) == 0,
                          "Worse order by profit not correct!");
  //_order_profit_best.ToString(); // @todo
  //_order_profit_worst.ToString(); // @todo
  return _result;
}

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  _result &= Test01();
  assertTrueOrFail(GetLastError() == ERR_NO_ERROR, StringFormat("Error: %d!", GetLastError()));
  return _result ? INIT_SUCCEEDED : INIT_FAILED;
}

/**
 * Implements Tick event handler.
 */
void OnTick() {}

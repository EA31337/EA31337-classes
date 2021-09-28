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
  // Initialize orders.
  DictStruct<long, Ref<Order>> orders;
  // Populate orders.
  for (int i = -10; i <= 10; i++) {
    OrderData _odata;
    _odata.Set<float>(ORDER_PROP_PROFIT, (float)i);
    _odata.Set(ORDER_TYPE, i % 2 == 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
    Ref<Order> _order = new Order(_odata);
    orders.Push(_order);
  }
  // Initialize OrderQuery instances.
  OrderQuery _oquery(orders);
  Ref<OrderQuery> _oquery_ref = OrderQuery::GetInstance(orders);

  // Find an order with the most profit.
  Ref<Order> _order_profit_best = _oquery.FindByPropViaOp<ENUM_ORDER_PROPERTY_CUSTOM, float>(
      ORDER_PROP_PROFIT, STRUCT_ENUM(OrderQuery, ORDER_QUERY_OP_GT));
  assertTrueOrReturnFalse(_order_profit_best.Ptr().Get<float>(ORDER_PROP_PROFIT) == 10,
                          "Best order by profit not correct!");

  // Find an order with the worst profit.
  Ref<Order> _order_profit_worst = _oquery.FindByPropViaOp<ENUM_ORDER_PROPERTY_CUSTOM, float>(
      ORDER_PROP_PROFIT, STRUCT_ENUM(OrderQuery, ORDER_QUERY_OP_LT));
  assertTrueOrReturnFalse(_order_profit_worst.Ptr().Get<float>(ORDER_PROP_PROFIT) == -10,
                          "Worse order by profit not correct!");

  // Find an order with the most profit using another instance.
  Ref<Order> _order_profit_best2 = _oquery_ref.Ptr().FindByPropViaOp<ENUM_ORDER_PROPERTY_CUSTOM, float>(
      ORDER_PROP_PROFIT, STRUCT_ENUM(OrderQuery, ORDER_QUERY_OP_GT));
  assertTrueOrReturnFalse(_order_profit_best.Ptr() == _order_profit_best2.Ptr(), "Best orders not the same!");

  // Find profit with profit 1.
  Ref<Order> _order_profit_1 = _oquery.FindByValueViaOp<ENUM_ORDER_PROPERTY_CUSTOM, float>(
      ORDER_PROP_PROFIT, 1, STRUCT_ENUM(OrderQuery, ORDER_QUERY_OP_EQ));
  assertTrueOrReturnFalse(_order_profit_1.Ptr().Get<float>(ORDER_PROP_PROFIT) == 1, "Order with profit 1 not found!");

  // Find order with profit greater than 2.
  Ref<Order> _order_profit_gt_2 = _oquery.FindByValueViaOp<ENUM_ORDER_PROPERTY_CUSTOM, float>(
      ORDER_PROP_PROFIT, 2, STRUCT_ENUM(OrderQuery, ORDER_QUERY_OP_GT));
  assertTrueOrReturnFalse(_order_profit_gt_2.Ptr().Get<float>(ORDER_PROP_PROFIT) > 2,
                          "Order with profit greater than 2 not found!");

  // Calculate profit sums (all, buys and sells).
  float _order_profit_all = _oquery.CalcSumByProp<ENUM_ORDER_PROPERTY_CUSTOM, float>(ORDER_PROP_PROFIT);
  assertTrueOrReturnFalse(_order_profit_all == 0, "All profit should be 0!");
  float _order_profit_buy =
      _oquery.CalcSumByPropWithCond<ENUM_ORDER_PROPERTY_CUSTOM, ENUM_ORDER_PROPERTY_INTEGER, ENUM_ORDER_TYPE, float>(
          ORDER_PROP_PROFIT, ORDER_TYPE, ORDER_TYPE_BUY);
  float _order_profit_sell =
      _oquery.CalcSumByPropWithCond<ENUM_ORDER_PROPERTY_CUSTOM, ENUM_ORDER_PROPERTY_INTEGER, ENUM_ORDER_TYPE, float>(
          ORDER_PROP_PROFIT, ORDER_TYPE, ORDER_TYPE_SELL);
  assertTrueOrReturnFalse(_order_profit_buy == _order_profit_sell, "Profit of buys should equal profit of sells!");

  // Find order type with the highest profit.
  ENUM_ORDER_TYPE _order_types[] = {ORDER_TYPE_BUY, ORDER_TYPE_SELL};
  ENUM_ORDER_TYPE _order_type_highest_profit =
      _oquery.FindPropBySum<ENUM_ORDER_TYPE, ENUM_ORDER_PROPERTY_CUSTOM, ENUM_ORDER_PROPERTY_INTEGER, float>(
          _order_types, ORDER_PROP_PROFIT, ORDER_TYPE);
  assertTrueOrReturnFalse(_order_type_highest_profit == 0.0f, "Highest profitable order type incorrect!");

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
  assertTrueOrFail(_LastError == ERR_NO_ERROR, StringFormat("Error: %d!", _LastError));
  return _result ? INIT_SUCCEEDED : INIT_FAILED;
}

/**
 * Implements Tick event handler.
 */
void OnTick() {}

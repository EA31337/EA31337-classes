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

/**
 * @file
 * Implements class for querying list of orders.
 */

// Includes.
#include "DictStruct.mqh"
#include "Order.mqh"
#include "Refs.mqh"
#include "Std.h"

class OrderQuery {
 protected:
  DictStruct<long, Ref<Order>> *orders;

 public:
  // Enumeration of comparison operators.
  enum ORDER_QUERY_OP {
    ORDER_QUERY_OP_NA = 0,  // (None)
    ORDER_QUERY_OP_EQ,      // Values are equal
    ORDER_QUERY_OP_GE,      // Value is greater or equal
    ORDER_QUERY_OP_GT,      // Value is greater
    ORDER_QUERY_OP_LE,      // Value is lesser or equal
    ORDER_QUERY_OP_LT,      // Value is lesser
    FINAL_ORDER_QUERY_OP,
  };

  OrderQuery() {}
  OrderQuery(DictStruct<long, Ref<Order>> &_orders) : orders(GetPointer(_orders)) {}

  /**
   * Find order by comparing property's value given the comparison operator.
   *
   * @return
   *   Returns structure with reference to Order instance which has been found.
   *   On error, returns Ref<Order> pointing to NULL.
   */
  template <typename E, typename T>
  Ref<Order> FindByPropViaOp(E _prop, STRUCT_ENUM(OrderQuery, ORDER_QUERY_OP) _op) {
    Ref<Order> _order_ref_found;
    if (orders.Size() == 0) {
      return _order_ref_found;
    }
    _order_ref_found = orders.Begin().Value();
    for (DictStructIterator<long, Ref<Order>> iter = orders.Begin(); iter.IsValid(); ++iter) {
      Ref<Order> _order_ref = iter.Value();
      if (Compare(_order_ref.Ptr().Get<T>(_prop), _op, _order_ref_found.Ptr().Get<T>(_prop))) {
        _order_ref_found = _order_ref;
      }
    }
    return _order_ref_found;
  }

  /**
   * Find first order by given value using a comparison operator.
   *
   * @return
   *   Returns structure with reference to Order instance which has been found.
   *   On error, returns Ref<Order> pointing to NULL.
   */
  template <typename E, typename T>
  Ref<Order> FindByValueViaOp(E _prop, T _value, STRUCT_ENUM(OrderQuery, ORDER_QUERY_OP) _op) {
    Ref<Order> _order_ref_found;
    if (orders.Size() == 0) {
      return _order_ref_found;
    }
    for (DictStructIterator<long, Ref<Order>> iter = orders.Begin(); iter.IsValid(); ++iter) {
      Ref<Order> _order_ref = iter.Value();
      if (Compare(_order_ref.Ptr().Get<T>(_prop), _op, _value)) {
        _order_ref_found = _order_ref;
        break;
      }
    }
    return _order_ref_found;
  }

  /**
   * Perform a comparison operation on two values.
   *
   * @return
   *   Returns true on successful comparison, otherwise false.
   */
  template <typename T>
  bool Compare(T _v1, ORDER_QUERY_OP _op, T _v2) {
    switch (_op) {
      case ORDER_QUERY_OP_NA:
        return false;
      case ORDER_QUERY_OP_EQ:
        return _v1 == _v2;
      case ORDER_QUERY_OP_GE:
        return _v1 >= _v2;
      case ORDER_QUERY_OP_GT:
        return _v1 > _v2;
      case ORDER_QUERY_OP_LE:
        return _v1 <= _v2;
      case ORDER_QUERY_OP_LT:
        return _v1 < _v2;
      default:
        break;
    }
    return false;
  }

  /**
   * Returns reference to new instance of OrderQuery class.
   *
   * @return
   *   Returns a pointer to the new instance.
   */
  static OrderQuery *GetInstance(DictStruct<long, Ref<Order>> &_orders) { return new OrderQuery(_orders); }
};

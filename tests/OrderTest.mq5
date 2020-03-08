//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
 * Test functionality of Order class.
 */

// Includes.
#include "../Chart.mqh"
#include "../Order.mqh"
#include "../Test.mqh"

// Global defines.
#define MAX_ORDERS 10

// Global variables.
int bar_processed;
Chart *chart;
Order *orders[MAX_ORDERS];
Order *orders_copy[MAX_ORDERS];
Order *orders_dummy[MAX_ORDERS];

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  chart = new Chart(PERIOD_M1);
  bar_processed = 0;
  _result &= GetLastError() == ERR_NO_ERROR;
  return _result ? INIT_SUCCEEDED : INIT_FAILED;
}

/**
 * Implements Tick event handler.
 */
void OnTick() {
  if (chart.IsNewBar()) {
    bool order_result;
    if (bar_processed < MAX_ORDERS) {
      int order_no = bar_processed + 1;
      order_result = OpenOrder(bar_processed, order_no);
      assertTrueOrExit(order_result, StringFormat("Order not opened (last error: %d)!", GetLastError()));
    }
    else if (bar_processed - MAX_ORDERS < MAX_ORDERS) {
      int order_index = bar_processed - MAX_ORDERS;
      order_result = CloseOrder(order_index);
      assertTrueOrExit(order_result, StringFormat("Order not closed (last error: %d)!", GetLastError()));
    }
    bar_processed++;
  }
}

/**
 * Open an order.
 */
bool OpenOrder(int _index, int _order_no) {
  // New request.
  MqlTradeRequest _request = {0};
  MqlTradeResult _result = {0};
  _request.action = TRADE_ACTION_DEAL;
  _request.comment = StringFormat("Order: %d", _order_no);
  _request.deviation = 50;
  _request.magic = _order_no;
  _request.type = bar_processed % 2 == 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
  _request.price = chart.GetOpenOffer(_request.type);
  _request.symbol = chart.GetSymbol();
  _request.type_filling = Order::GetOrderFilling(_request.symbol);
  _request.volume = chart.GetVolumeMin();
  // New order.
  orders[_index] = new Order(_request);
  _result = orders[_index].GetResult();
  assertTrueOrReturn(_result.retcode == TRADE_RETCODE_DONE, "Request not completed!", false);
  // Make a copy.
  orders_copy[_index] = new Order(orders[_index]);
  // Make a dummy order.
  OrderParams oparams_dummy(true);
  _request.comment = StringFormat("Order dummy: %d", _order_no);
  orders_dummy[_index] = new Order(_request, oparams_dummy);
  return GetLastError() == ERR_NO_ERROR;
}

/**
 * Close an order.
 */
bool CloseOrder(int _index) {
  Order order = orders[_index];
  if (order.IsOpen()) {
    string order_comment = StringFormat("Closing order: %d", order.GetTicket());
    order.OrderClose(order_comment);
  }
  return GetLastError() == ERR_NO_ERROR;
}

/**
 * Implements Deinit event handler.
 */
void OnDeinit(const int reason) {
  delete chart;
  for (int i = 0; i < fmin(bar_processed, MAX_ORDERS); i++) {
    delete orders[i];
    delete orders_copy[i];
    delete orders_dummy[i];
  }
}

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
 * Includes Trade's structs.
 */

struct TradeParams {
  float lot_size;     // Default lot size.
  float risk_margin;  // Maximum account margin to risk (in %).
  // Classes.
  Account *account;       // Pointer to Account class.
  Chart *chart;           // Pointer to Chart class.
  Ref<Log> logger;        // Reference to Log object.
  unsigned int slippage;  // Value of the maximum price slippage in points.
  // Market          *market;     // Pointer to Market class.
  // void Init(TradeParams &p) { slippage = p.slippage; account = p.account; chart = p.chart; }
  // Constructors.
  TradeParams() {}
  TradeParams(Account *_account, Chart *_chart, Log *_log, float _lot_size = 0, float _risk_margin = 1.0,
              unsigned int _slippage = 50)
      : account(_account),
        chart(_chart),
        logger(_log),
        lot_size(_lot_size),
        risk_margin(_risk_margin),
        slippage(_slippage) {}
  // Deconstructor.
  ~TradeParams() {}
  // Setters.
  void SetLotSize(float _lot_size) { lot_size = _lot_size; }
  // Struct methods.
  void DeleteObjects() {
    Object::Delete(account);
    Object::Delete(chart);
  }
};

//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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

// Includes.
#include "DateTime.mqh"
#include "Trade.enum.h"

/* Structure for trade parameters. */
struct TradeParams {
  float lot_size;     // Default lot size.
  float risk_margin;  // Maximum account margin to risk (in %).
  // Classes.
  Account *account;       // Pointer to Account class.
  Chart *chart;           // Pointer to Chart class.
  Ref<Log> logger;        // Reference to Log object.
  Ref<Terminal> terminal; // Reference to Terminal object.
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
        slippage(_slippage) {
    terminal = new Terminal();
  }
  // Deconstructor.
  ~TradeParams() {}
  // Getters.
  float GetRiskMargin() { return risk_margin; }
  // Setters.
  void SetLotSize(float _lot_size) { lot_size = _lot_size; }
  void SetRiskMargin(float _value) { risk_margin = _value; }
  // Struct methods.
  void DeleteObjects() {
    Object::Delete(account);
    Object::Delete(chart);
  }
  // Serializers.
  void SerializeStub(int _n1 = 1, int _n2 = 1, int _n3 = 1, int _n4 = 1, int _n5 = 1) {}
  SerializerNodeType Serialize(Serializer& _s) {
    _s.Pass(this, "lot_size", lot_size);
    _s.Pass(this, "risk_margin", risk_margin);
    _s.Pass(this, "slippage", slippage);
    return SerializerNodeObject;
  }
};

/* Structure for trade statistics. */
struct TradeStats {
  DateTime dt;
  unsigned int orders[FINAL_ENUM_TRADE_STAT_TYPE][FINAL_ENUM_TRADE_STAT_PERIOD];
  // Struct constructors.
  TradeStats() {
    ResetStats();
  }
  // Check statistics for new periods
  void Check() {
  }
  /* Getters */
  // Get value for the given type and period.
  unsigned int Get(ENUM_TRADE_STAT_TYPE _type, ENUM_TRADE_STAT_PERIOD _period, bool _reset = true) {
    if (_reset && _period < TRADE_STAT_ALL) {
      unsigned short _periods_started = dt.GetStartedPeriods();
      if (_periods_started >= DATETIME_HOUR) {
        ResetStats(_periods_started);
      }
    }
    return orders[_type][_period];
  }
  /* Setters */
  // Add value for the given type and period.
  void Add(ENUM_TRADE_STAT_TYPE _type, int _value = 1) {
    for (int p = 0; p < FINAL_ENUM_TRADE_STAT_PERIOD; p++) {
      orders[_type][p] += _value;
    }
  }
  /* Reset stats for the given periods. */
  void ResetStats(unsigned short _periods) {
    if ((_periods & DATETIME_HOUR) != 0) {
      ResetStats(TRADE_STAT_PER_HOUR);
    }
    if ((_periods & DATETIME_DAY) != 0) {
      // New day started.
      ResetStats(TRADE_STAT_PER_DAY);
    }
    if ((_periods & DATETIME_WEEK) != 0) {
      ResetStats(TRADE_STAT_PER_WEEK);
    }
    if ((_periods & DATETIME_MONTH) != 0) {
      ResetStats(TRADE_STAT_PER_MONTH);
    }
    if ((_periods & DATETIME_YEAR) != 0) {
      ResetStats(TRADE_STAT_PER_YEAR);
    }
  }
  /* Reset stats for the given type and period. */
  void ResetStats(ENUM_TRADE_STAT_TYPE _type, ENUM_TRADE_STAT_PERIOD _period) {
     orders[_type][_period] = 0;
  }
  /* Reset stats for the given period. */
  void ResetStats(ENUM_TRADE_STAT_PERIOD _period) {
    for (int t = 0; t < FINAL_ENUM_TRADE_STAT_TYPE; t++) {
      orders[t][_period] = 0;
    }
  }
  /* Reset stats for the given type. */
  void ResetStats(ENUM_TRADE_STAT_TYPE _type) {
    for (int p = 0; p < FINAL_ENUM_TRADE_STAT_PERIOD; p++) {
      orders[_type][p] = 0;
    }
  }
  /* Reset all stats. */
  void ResetStats() {
    for (int t = 0; t < FINAL_ENUM_TRADE_STAT_TYPE; t++) {
      for (int p = 0; p < FINAL_ENUM_TRADE_STAT_PERIOD; p++) {
        orders[t][p] = 0;
      }
    }
  }
};

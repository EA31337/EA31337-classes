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
 * Implements Expert Advisor class for writing custom trading robots.
 */

// Prevents processing this includes file for the second time.
#ifndef EA_MQH
#define EA_MQH

// Includes.
#include "Chart.mqh"
#include "Market.mqh"
#include "Strategy.mqh"
#include "SummaryReport.mqh"
#include "Terminal.mqh"

// Defines EA config parameters.
struct EAParams {
  string name;              // Name of EA.
  string symbol;            // Symbol to trade on.
  ENUM_LOG_LEVEL log_level; // Log verbosity level.
  EAParams() : name("EA"), log_level(V_INFO) {}
};

// Defines EA state variables.
struct EAState {
  // EA state.
  bool is_connected;    // Indicates connectedness to a trade server.
  bool is_allowed_libs; // Indicates the permission to use external libraries.
  bool is_allowed_trading; // Indicates the permission to trade on the chart.
};

class EA {

protected:
  // Class variables.
  Account *account;
  Chart *chart;
  Collection *strats;
  Log *logger;
  Market *market;
  SummaryReport *report;
  Terminal *terminal;
  Trade *trade[FINAL_ENUM_TIMEFRAMES_INDEX];
  // Dict<ENUM_TIMEFRAMES, Trade> _trade;

  // Data variables.
  string name;
  Dict<string, double> *ddata;
  Dict<string, int> *idata;
  EAParams eparams;
  EAState estate;

public:
  /**
   * Class constructor.
   */
  EA(EAParams &_params)
      : account(new Account), chart(new Chart(PERIOD_CURRENT, _params.symbol)),
        logger(new Log(_params.log_level)),
        market(new Market(_params.symbol, logger)), report(new SummaryReport),
        terminal(new Terminal) {}

  /**
   * Class deconstructor.
   */
  ~EA() {
    Object::Delete(account);
    Object::Delete(chart);
    Object::Delete(market);
    Object::Delete(report);
    Object::Delete(strats);
    Object::Delete(terminal);
    for (int tfi = 0; tfi < FINAL_ENUM_TIMEFRAMES_INDEX; tfi++) {
      Object::Delete(trade[tfi]);
    }
  }
};
#endif // EA_MQH
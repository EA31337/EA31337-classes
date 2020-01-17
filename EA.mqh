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
struct EA_Params {
  string name;               // Name of EA.
  string symbol;             // Symbol to trade on.
  unsigned long magic_no;    // Magic number.
  ENUM_LOG_LEVEL log_level;  // Log verbosity level.
  int chart_info_freq;       // Updates info on chart (in secs, 0 - off).
  bool report_to_file;       // Report to file.
  EA_Params(string _name = "EA", ENUM_LOG_LEVEL _ll = V_INFO, unsigned long _magic = 0)
      : name(_name), log_level(_ll), magic_no(_magic > 0 ? _magic : rand()), chart_info_freq(0) {}
  void SetChartInfoFreq(bool _secs) { chart_info_freq = _secs; }
  void SetFileReport(bool _bool) { report_to_file = _bool; }
  void SetName(string _name) { name = _name; }
};

// Defines EA state variables.
struct EA_State {
  // EA state.
  bool is_connected;        // Indicates connectedness to a trade server.
  bool is_allowed_libs;     // Indicates the permission to use external libraries.
  bool is_allowed_trading;  // Indicates the permission to trade on the chart.
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
  EA_Params eparams;
  EA_State estate;

 public:
  /**
   * Class constructor.
   */
  EA(EA_Params &_params)
      : account(new Account),
        chart(new Chart(PERIOD_CURRENT, _params.symbol)),
        logger(new Log(_params.log_level)),
        market(new Market(_params.symbol, logger)),
        report(new SummaryReport),
        strats(new Collection),
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

  /* Processing methods */

  /**
   * Process strategy signals.
   *
   * Call this method for every new bar.
   */
  bool Process() {
    bool _result = true;
    int _sid;
    Strategy *_strat;
    market.SetTick(SymbolInfo::GetTick(_Symbol));
    for (_sid = 0; _sid < strats.GetSize(); _sid++) {
      _strat = ((Strategy *)strats.GetByIndex(_sid));
      if (_strat.IsEnabled() && !_strat.IsSuspended() && _strat.Chart().IsNewBar()) {
        _strat.ProcessSignals();
        _strat.ProcessOrders();
        _result &= _strat.GetProcessResult().last_error > ERR_NO_ERROR;
      }
    }
    return _result;
  }

  /* Strategy methods */

  /**
   * Adds strategy to multiple timeframes.
   *
   * @param
   * _tfs - timeframes to add strategy (using bitwise operation).
   *
   * @return
   * Returns true if all strategies has been initialized correctly, otherwise
   * false.
   */
  template <typename SClass>
  bool StrategyAdd(int _tfs) {
    bool _result = true;
    if ((_tfs & M1B) == M1B) _result = strats.Add(SClass::Init(PERIOD_M1)) != NULL;
    if ((_tfs & M5B) == M5B) _result = strats.Add(SClass::Init(PERIOD_M5)) != NULL;
    if ((_tfs & M15B) == M15B) _result = strats.Add(SClass::Init(PERIOD_M15)) != NULL;
    if ((_tfs & M30B) == M30B) _result = strats.Add(SClass::Init(PERIOD_M30)) != NULL;
    if ((_tfs & H1B) == H1B) _result = strats.Add(SClass::Init(PERIOD_H1)) != NULL;
    if ((_tfs & H4B) == H4B) _result = strats.Add(SClass::Init(PERIOD_H4)) != NULL;
    if ((_tfs & D1B) == D1B) _result = strats.Add(SClass::Init(PERIOD_D1)) != NULL;
    if ((_tfs & W1B) == W1B) _result = strats.Add(SClass::Init(PERIOD_W1)) != NULL;
    if ((_tfs & MN1B) == MN1B) _result = strats.Add(SClass::Init(PERIOD_MN1)) != NULL;
    return _result;
  }

  /* Update methods */

  /**
   * Updates info on chart.
   */
  bool UpdateInfoOnChart() {
    bool _result = false;
    if (eparams.chart_info_freq > 0) {
      static datetime _last_update = 0;
      if (_last_update + eparams.chart_info_freq < TimeCurrent()) {
        _last_update = TimeCurrent();
        // @todo
        _result = true;
      }
    }
    return _result;
  }

  /* Other methods */

  /* Getters */

  /**
   * Gets EA's name.
   */
  string GetName() { return name; }

  /* State getters */

  /**
   * Checks if trading is allowed.
   */
  bool IsTradeAllowed() { return estate.is_allowed_trading; }

  /**
   * Checks if using libraries is allowed.
   */
  bool IsLibsAllowed() { return estate.is_allowed_libs; }

  /* Struct getters */

  /**
   * Gets EA params.
   */
  EA_Params GetEAParams() { return eparams; }

  /**
   * Gets EA state.
   */
  EA_State GetEAState() { return estate; }

  /* Class getters */

  /**
   * Gets pointer to account details.
   */
  Account *Account() { return account; }

  /**
   * Gets pointer to chart details.
   */
  Market *Chart() { return chart; }

  /**
   * Gets pointer to log instance.
   */
  Log *Log() { return logger; }

  /**
   * Gets pointer to market details.
   */
  Market *Market() { return market; }

  /**
   * Gets pointer to strategies collection.
   */
  Collection *Strategies() { return strats; }

  /**
   * Gets pointer to terminal instance.
   */
  Terminal *Terminal() { return terminal; }

  /* Setters */

};
#endif  // EA_MQH
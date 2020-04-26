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
#include "Task.mqh"
#include "Terminal.mqh"

// Enums.
// EA actions.
enum ENUM_EA_ACTION {
  EA_ACTION_DISABLE = 0, // Disables EA.
  EA_ACTION_ENABLE,      // Enables EA.
  EA_ACTION_TASKS_CLEAN, // Clean tasks.
  FINAL_EA_ACTION_ENTRY
};

// EA conditions.
enum ENUM_EA_CONDITION {
  EA_COND_IS_ACTIVE = 1,  // When EA is active (can trade).
  EA_COND_IS_ENABLED = 2,  // When EA is enabled.
  FINAL_EA_CONDITION_ENTRY
};

// Defines EA state flags.
enum ENUM_EA_STATE_FLAGS {
  EA_STATE_FLAG_NONE = 0,
  EA_STATE_FLAG_ACTIVE = 1,         // Indicates that EA is active (can trade).
  EA_STATE_FLAG_CONNECTED = 2,      // Indicates connectedness to a trade server.
  EA_STATE_FLAG_ENABLED = 4,        // Indicates that EA is enabled.
  EA_STATE_FLAG_LIBS_ALLOWED = 8,   // Indicates connectedness to a trade server.
  EA_STATE_FLAG_TRADE_ALLOWED = 16  // Indicates the permission to trade on the chart.
};

// Defines EA config parameters.
struct EAParams {
  string name;               // Name of EA.
  string symbol;             // Symbol to trade on.
  unsigned long magic_no;    // Magic number.
  ENUM_LOG_LEVEL log_level;  // Log verbosity level.
  int chart_info_freq;       // Updates info on chart (in secs, 0 - off).
  bool report_to_file;       // Report to file.
  EAParams(string _name = "EA", ENUM_LOG_LEVEL _ll = V_INFO, unsigned long _magic = 0)
      : name(_name), log_level(_ll), magic_no(_magic > 0 ? _magic : rand()), chart_info_freq(0) {}
  void SetChartInfoFreq(bool _secs) { chart_info_freq = _secs; }
  void SetFileReport(bool _bool) { report_to_file = _bool; }
  void SetName(string _name) { name = _name; }
};

// Defines struct to store results for EA processing.
struct EAProcessResult {
  unsigned int last_error;      // Last error code.
  unsigned int stg_errored;     // Number of errored strategies.
  unsigned int stg_processed;   // Number of processed strategies.
  unsigned int stg_suspended;   // Number of suspended strategies.
  unsigned int tasks_processed; // Number of tasks processed.
  EAProcessResult() { Reset(); }
  void Reset() {
    stg_errored = stg_processed = stg_suspended = 0;
    ResetError();
  }
  void ResetError() {
    ResetLastError();
    last_error = ERR_NO_ERROR;
  }
  string ToString() { return StringFormat("%d", last_error); }
};

// Defines EA state variables.
struct EAState {
  unsigned char flags;   // Action flags.
  bool is_allowed_libs;  // Indicates the permission to use external libraries.
  // Constructor.
  EAState() { AddFlags(EA_STATE_FLAG_ACTIVE | EA_STATE_FLAG_ENABLED); }
  // Struct methods.
  // Flag methods.
  bool CheckFlag(unsigned char _flag) { return bool(flags & _flag); }
  void AddFlags(unsigned char _flags) { flags |= _flags; }
  void RemoveFlags(unsigned char _flags) { flags &= ~_flags; }
  void SetFlag(ENUM_EA_STATE_FLAGS _flag, bool _value) {
    if (_value) {
      AddFlags(_flag);
    } else {
      RemoveFlags(_flag);
    }
  }
  void SetFlags(unsigned char _flags) { flags = _flags; }
  // State methods.
  bool IsActive() { return CheckFlag(EA_STATE_FLAG_ACTIVE); }
  bool IsConnected() { return CheckFlag(EA_STATE_FLAG_CONNECTED); }
  bool IsEnabled() { return CheckFlag(EA_STATE_FLAG_ENABLED); }
  bool IsLibsAllowed() { return !CheckFlag(EA_STATE_FLAG_LIBS_ALLOWED); }
  bool IsTradeAllowed() { return !CheckFlag(EA_STATE_FLAG_TRADE_ALLOWED); }
  // Setters.
  void Enable(bool _state = true) { SetFlag(EA_STATE_FLAG_ENABLED, _state); }
};

class EA {
 protected:
  // Class variables.
  Account *account;
  Chart *chart;
  Collection *strats;
  DictObject<short, Task> *tasks;
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
  EAProcessResult eresults;
  EAState estate;

 public:
  /**
   * Class constructor.
   */
  EA(EAParams &_params)
      : account(new Account),
        chart(new Chart(PERIOD_CURRENT, _params.symbol)),
        logger(new Log(_params.log_level)),
        market(new Market(_params.symbol, logger)),
        report(new SummaryReport),
        strats(new Collection),
        tasks(new DictObject<short, Task>),
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
  EAProcessResult Process() {
    Strategy *_strat;
    eresults.Reset();
    market.SetTick(SymbolInfo::GetTick(_Symbol));
    for (int _sid = 0; _sid < strats.GetSize(); _sid++) {
      _strat = ((Strategy *)strats.GetByIndex(_sid));
      if (_strat.IsEnabled()) {
        if (_strat.Chart().IsNewBar()) {
          if (!_strat.IsSuspended()) {
            eresults.ResetError();
            _strat.Process();
            eresults.last_error = fmax(eresults.last_error, _strat.GetProcessResult().last_error);
            eresults.stg_errored += (int)_strat.GetProcessResult().last_error > ERR_NO_ERROR;
            eresults.stg_processed++;
            if (eresults.last_error > ERR_NO_ERROR) {
              _strat.Logger().Flush();
            }
          } else {
            eresults.stg_suspended++;
          }
        }
      }
    }
    eresults.tasks_processed = ProcessTasks();
    return eresults;
  }

  /**
   * Process tasks.
   */
  unsigned int ProcessTasks() {
    unsigned int _counter = 0;
    for (DictStructIterator<short, Task> iter = tasks.Begin(); iter.IsValid(); ++iter) {
      Task _entry = iter.Value();
      if (_entry.Process()) {
        _counter++;
      }
    }
    return _counter;
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
    if ((_tfs & M1B) == M1B) _result = strats.Add(((SClass*)NULL).Init(PERIOD_M1)) != NULL;
    if ((_tfs & M5B) == M5B) _result = strats.Add(((SClass*)NULL).Init(PERIOD_M5)) != NULL;
    if ((_tfs & M15B) == M15B) _result = strats.Add(((SClass*)NULL).Init(PERIOD_M15)) != NULL;
    if ((_tfs & M30B) == M30B) _result = strats.Add(((SClass*)NULL).Init(PERIOD_M30)) != NULL;
    if ((_tfs & H1B) == H1B) _result = strats.Add(((SClass*)NULL).Init(PERIOD_H1)) != NULL;
    if ((_tfs & H4B) == H4B) _result = strats.Add(((SClass*)NULL).Init(PERIOD_H4)) != NULL;
    if ((_tfs & D1B) == D1B) _result = strats.Add(((SClass*)NULL).Init(PERIOD_D1)) != NULL;
    if ((_tfs & W1B) == W1B) _result = strats.Add(((SClass*)NULL).Init(PERIOD_W1)) != NULL;
    if ((_tfs & MN1B) == MN1B) _result = strats.Add(((SClass*)NULL).Init(PERIOD_MN1)) != NULL;
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

  /* Conditions and actions */

  /**
   * Checks for EA condition.
   *
   * @param ENUM_EA_CONDITION _cond
   *   EA condition.
   * @return
   *   Returns true when the condition is met.
   */
  bool Condition(ENUM_EA_CONDITION _cond, MqlParam &_args[]) {
    switch (_cond) {
      case EA_COND_IS_ACTIVE:
        return estate.IsActive();
      case EA_COND_IS_ENABLED:
        return estate.IsEnabled();
      default:
        logger.Error(StringFormat("Invalid EA condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }
  bool Condition(ENUM_EA_CONDITION _cond) {
    MqlParam _args[] = {};
    return EA::Condition(_cond, _args);
  }

  /**
   * Execute EA action.
   *
   * @param ENUM_EA_ACTION _action
   *   EA action to execute.
   * @return
   *   Returns true when the action has been executed successfully.
   */
  bool ExecuteAction(ENUM_EA_ACTION _action, MqlParam &_args[]) {
    bool _result = true;
    switch (_action) {
      case EA_ACTION_DISABLE:
        estate.Enable(false);
        return true;
      case EA_ACTION_ENABLE:
        estate.Enable();
        return true;
      case EA_ACTION_TASKS_CLEAN:
        Object::Delete(tasks);
        tasks = new DictObject<short, Task>();
        return tasks.Size() == 0;
      default:
        logger.Error(StringFormat("Invalid EA action: %s!", EnumToString(_action), __FUNCTION_LINE__));
        return false;
    }
    return _result;
  }
  bool ExecuteAction(ENUM_EA_ACTION _action) {
    MqlParam _args[] = {};
    return EA::ExecuteAction(_action, _args);
  }

  /* Getters */

  /**
   * Gets EA's name.
   */
  string GetName() { return name; }

  /* State getters */

  /**
   * Checks if trading is allowed.
   */
  bool IsTradeAllowed() { return estate.IsTradeAllowed(); }

  /**
   * Checks if using libraries is allowed.
   */
  bool IsLibsAllowed() { return estate.IsLibsAllowed(); }

  /* Struct getters */

  /**
   * Gets EA params.
   */
  EAParams GetEAParams() { return eparams; }

  /**
   * Gets EA state.
   */
  EAState GetEAState() { return estate; }

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

  /* Other methods */

};
#endif  // EA_MQH
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

// Forward class declaration.
class Condition;

// Enums.
// Defines EA state flags.
enum ENUM_EA_STATE_FLAGS {
  EA_STATE_FLAG_NONE = 0 << 0,            // None flags.
  EA_STATE_FLAG_ACTIVE = 1 << 0,          // Is active (can trade).
  EA_STATE_FLAG_CONNECTED = 1 << 1,       // Indicates connectedness to a trade server.
  EA_STATE_FLAG_ENABLED = 1 << 2,         // Is enabled.
  EA_STATE_FLAG_LIBS_ALLOWED = 1 << 3,    // Indicates the permission to use external libraries (such as DLL).
  EA_STATE_FLAG_OPTIMIZATION = 1 << 4,    // Indicates EA runs in optimization mode.
  EA_STATE_FLAG_TESTING = 1 << 5,         // Indicates EA runs in testing mode.
  EA_STATE_FLAG_TESTING_VISUAL = 1 << 6,  // Indicates EA runs in visual testing mode.
  EA_STATE_FLAG_TRADE_ALLOWED = 1 << 7,   // Indicates the permission to trade on the chart.
};

// Includes.
#include "ActionEnums.mqh"
#include "Chart.mqh"
#include "Market.mqh"
#include "Strategy.mqh"
#include "SummaryReport.mqh"
#include "Task.mqh"
#include "Terminal.mqh"
//#include "Trade.mqh"

// Defines EA config parameters.
struct EAParams {
  string author;             // EA's author.
  string desc;               // EA's description.
  string name;               // EA's name.
  string symbol;             // Symbol to trade on.
  string ver;                // EA's version.
  unsigned long magic_no;    // Magic number.
  ENUM_LOG_LEVEL log_level;  // Log verbosity level.
  int chart_info_freq;       // Updates info on chart (in secs, 0 - off).
  bool report_to_file;       // Report to file.
  // Struct special methods.
  EAParams(string _name = __FILE__, ENUM_LOG_LEVEL _ll = V_INFO, unsigned long _magic = 0)
      : author("unknown"),
        name(_name),
        desc("..."),
        symbol(_Symbol),
        ver("v1.00"),
        log_level(_ll),
        magic_no(_magic > 0 ? _magic : rand()),
        chart_info_freq(0) {}
  // Getters.
  string GetAuthor() { return author; }
  string GetName() { return name; }
  string GetSymbol() { return symbol; }
  string GetDesc() { return desc; }
  string GetVersion() { return ver; }
  unsigned long GetMagicNo() { return magic_no; }
  ENUM_LOG_LEVEL GetLogLevel() { return log_level; }
  // Setters.
  void SetAuthor(string _author) { author = _author; }
  void SetChartInfoFreq(bool _secs) { chart_info_freq = _secs; }
  void SetDesc(string _desc) { desc = _desc; }
  void SetFileReport(bool _bool) { report_to_file = _bool; }
  void SetLogLevel(ENUM_LOG_LEVEL _level) { log_level = _level; }
  void SetName(string _name) { name = _name; }
  void SetVersion(string _ver) { ver = _ver; }
  // Printers.
  string ToString(string _dlm = ",") { return StringFormat("%s v%s by %s (%s)", name, ver, author, desc); }
};

// Defines struct to store results for EA processing.
struct EAProcessResult {
  unsigned int last_error;       // Last error code.
  unsigned int stg_errored;      // Number of errored strategies.
  unsigned int stg_processed;    // Number of processed strategies.
  unsigned int stg_suspended;    // Number of suspended strategies.
  unsigned int tasks_processed;  // Number of tasks processed.
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
  unsigned char flags;  // Action flags.
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
  bool IsOptimizationMode() { return !CheckFlag(EA_STATE_FLAG_OPTIMIZATION); }
  bool IsTestingMode() { return !CheckFlag(EA_STATE_FLAG_TESTING); }
  bool IsTestingVisualMode() { return !CheckFlag(EA_STATE_FLAG_TESTING_VISUAL); }
  bool IsTradeAllowed() { return !CheckFlag(EA_STATE_FLAG_TRADE_ALLOWED); }
  // Setters.
  void Enable(bool _state = true) { SetFlag(EA_STATE_FLAG_ENABLED, _state); }
};

class Strategy;

class EA {
 protected:
  // Class variables.
  Account *account;
  DictObject<ENUM_TIMEFRAMES, Dict<long, Strategy *>> *strats;
  DictObject<ENUM_TIMEFRAMES, Trade> *trade;
  DictObject<short, Task> *tasks;
  Market *market;
  Ref<Log> logger;
  SummaryReport *report;
  Terminal *terminal;

  // Data variables.
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
        logger(new Log(_params.log_level)),
        market(new Market(_params.symbol, logger.Ptr())),
        report(new SummaryReport),
        strats(new DictObject<ENUM_TIMEFRAMES, Dict<long, Strategy *>>),
        tasks(new DictObject<short, Task>),
        terminal(new Terminal) {
    eparams = _params;
    UpdateStateFlags();
  }

  /**
   * Class deconstructor.
   */
  ~EA() {
    Object::Delete(account);
    Object::Delete(market);
    Object::Delete(report);
    Object::Delete(tasks);
    Object::Delete(terminal);
    Object::Delete(trade);

    for (DictObjectIterator<ENUM_TIMEFRAMES, Dict<long, Strategy *>> iter1 = strats.Begin(); iter1.IsValid(); ++iter1) {
      for (DictIterator<long, Strategy *> iter2 = iter1.Value().Begin(); iter2.IsValid(); ++iter2) {
        Object::Delete(iter2.Value());
      }
    }
    Object::Delete(strats);
  }

  Log *Logger() { return logger.Ptr(); }

  /* Processing methods */

  /**
   * Process strategy signals on tick event.
   *
   * Call this method for every tick bar.
   *
   * @return
   *   Returns number of strategies which processed the tick.
   */
  virtual EAProcessResult ProcessTick(const ENUM_TIMEFRAMES _tf, const MqlTick &_tick) {
    for (DictIterator<long, Strategy *> iter = strats[_tf].Begin(); iter.IsValid(); ++iter) {
      Strategy *_strat = iter.Value();
      if (_strat.IsEnabled()) {
        if (_strat.TickFilter(_tick)) {
          if (!_strat.IsSuspended()) {
            StgProcessResult _strat_result = _strat.Process();
            eresults.last_error = fmax(eresults.last_error, _strat_result.last_error);
            eresults.stg_errored += (int)_strat_result.last_error > ERR_NO_ERROR;
            eresults.stg_processed++;
          } else {
            eresults.stg_suspended++;
          }
        }
      }
    }
    return eresults;
  }
  virtual EAProcessResult ProcessTick() {
    if (estate.IsActive() && estate.IsEnabled()) {
      eresults.Reset();
      market.SetTick(SymbolInfo::GetTick(_Symbol));
      for (DictObjectIterator<ENUM_TIMEFRAMES, Dict<long, Strategy *>> iter_tf = strats.Begin(); iter_tf.IsValid();
           ++iter_tf) {
        ProcessTick(iter_tf.Key(), market.GetLastTick());
      }
      if (eresults.last_error > ERR_NO_ERROR) {
        logger.Ptr().Flush();
      }
    }
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
   * Adds strategy to specific timeframe.
   *
   * @param
   * _tf - timeframe to add the strategy.
   *
   * @return
   * Returns true if the strategy has been initialized correctly,
   * otherwise false.
   */
  template <typename SClass>
  bool StrategyAdd(ENUM_TIMEFRAMES _tf, long _sid = -1) {
    Strategy *_strat = ((SClass *)NULL).Init(_tf);
    Dict<long, Strategy *> _strat_dict;
    if (_sid > 0) {
      _strat_dict.Set(_sid, _strat);
    } else {
      _strat_dict.Push(_strat);
    }
    return strats.Set(_tf, _strat_dict);
  }

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
  bool StrategyAdd(unsigned int _tfs, long _sid = -1) {
    bool _result = true;
    if ((_tfs & M1B) == M1B) _result = StrategyAdd<SClass>(PERIOD_M1, _sid);
    if ((_tfs & M5B) == M5B) _result = StrategyAdd<SClass>(PERIOD_M5, _sid);
    if ((_tfs & M15B) == M15B) _result = StrategyAdd<SClass>(PERIOD_M15, _sid);
    if ((_tfs & M30B) == M30B) _result = StrategyAdd<SClass>(PERIOD_M30, _sid);
    if ((_tfs & H1B) == H1B) _result = StrategyAdd<SClass>(PERIOD_H1, _sid);
    if ((_tfs & H4B) == H4B) _result = StrategyAdd<SClass>(PERIOD_H4, _sid);
    if ((_tfs & D1B) == D1B) _result = StrategyAdd<SClass>(PERIOD_D1, _sid);
    if ((_tfs & W1B) == W1B) _result = StrategyAdd<SClass>(PERIOD_W1, _sid);
    if ((_tfs & MN1B) == MN1B) _result = StrategyAdd<SClass>(PERIOD_MN1, _sid);
    return _result;
  }

  /* Update methods */

  /**
   * Update EA state flags.
   */
  void UpdateStateFlags() {
    estate.SetFlag(EA_STATE_FLAG_CONNECTED, terminal.IsConnected());
    estate.SetFlag(EA_STATE_FLAG_LIBS_ALLOWED, terminal.IsLibrariesAllowed());
    estate.SetFlag(EA_STATE_FLAG_OPTIMIZATION, terminal.IsOptimization());
    estate.SetFlag(EA_STATE_FLAG_TESTING, terminal.IsTesting());
    estate.SetFlag(EA_STATE_FLAG_TESTING_VISUAL, terminal.IsVisualMode());
    estate.SetFlag(EA_STATE_FLAG_TRADE_ALLOWED, terminal.IsTradeAllowed());
  }

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
        Logger().Error(StringFormat("Invalid EA condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
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
        Logger().Error(StringFormat("Invalid EA action: %s!", EnumToString(_action), __FUNCTION_LINE__));
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
  EAParams GetParams() const { return eparams; }

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
  EAParams GetParams() { return eparams; }

  /**
   * Gets EA state.
   */
  EAState GetState() { return estate; }

  /* Class getters */

  /**
   * Gets pointer to account details.
   */
  Account *Account() { return account; }

  /**
   * Gets pointer to log instance.
   */
  Log *Log() { return logger.Ptr(); }

  /**
   * Gets pointer to market details.
   */
  Market *Market() { return market; }

  /**
   * Gets pointer to strategies.
   */
  DictObject<ENUM_TIMEFRAMES, Dict<long, Strategy *>> *Strategies() const { return strats; }

  /**
   * Gets pointer to symbol details.
   */
  SymbolInfo *SymbolInfo() { return (SymbolInfo *)market; }

  /**
   * Gets pointer to terminal instance.
   */
  Terminal *Terminal() { return terminal; }

  /**
   * Gets pointer to terminal instance.
   */
  Trade *Trade(ENUM_TIMEFRAMES _tf) { return trade[_tf]; }

  /* Setters */

  /* ... */

  /* Printer methods */

  /**
   * Returns EA data in textual representation.
   */
  string ToString(string _dlm = "; ") {
    string _output = "";
    _output += eparams.ToString() + _dlm;
    //_output += StringFormat("Strategies: %d", strats.Size());
    return _output;
  }

  /* Other methods */
};
#endif  // EA_MQH

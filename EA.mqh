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
 * Implements Expert Advisor class for writing custom trading robots.
 */

// Prevents processing this includes file for the second time.
#ifndef EA_MQH
#define EA_MQH

// Includes.
#include "Action.enum.h"
#include "Chart.mqh"
#include "Condition.enum.h"
#include "Dict.mqh"
#include "DictObject.mqh"
#include "EA.enum.h"
#include "EA.struct.h"
#include "Indicator.struct.h"
#include "Market.mqh"
#include "Refs.struct.h"
#include "SerializerConverter.mqh"
#include "SerializerCsv.mqh"
#include "SerializerJson.mqh"
#include "Strategy.mqh"
#include "SummaryReport.mqh"
#include "Task.mqh"
#include "Terminal.mqh"
#include "Trade.mqh"

class EA {
 protected:
  // Class variables.
  Account *account;
  DictObject<ENUM_TIMEFRAMES, DictStruct<long, Ref<Strategy>>> strats;
  DictStruct<short, TaskEntry> tasks;
  Market *market;
  Ref<Log> logger;
  SummaryReport *report;
  Terminal *terminal;

  // Data variables.
  BufferStruct<ChartEntry> data_chart;
  BufferStruct<SymbolInfoEntry> data_symbol;
  Dict<string, double> ddata;  // Custom user data.
  Dict<string, int> idata;     // Custom user data.
  DictObject<ENUM_TIMEFRAMES, BufferStruct<IndicatorDataEntry>> data_indi;
  DictObject<ENUM_TIMEFRAMES, BufferStruct<StgEntry>> data_stg;
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
        terminal(new Terminal) {
    eparams = _params;
    estate.SetFlag(EA_STATE_FLAG_ON_INIT, true);
    UpdateStateFlags();
    // Add and process tasks.
    AddTask(eparams.task_entry);
    ProcessTasks();
    estate.SetFlag(EA_STATE_FLAG_ON_INIT, false);
  }

  /**
   * Class deconstructor.
   */
  ~EA() {
    // Process tasks on quit.
    estate.SetFlag(EA_STATE_FLAG_ON_QUIT, true);
    ProcessTasks();
    // Deinitialize classes.
    Object::Delete(account);
    Object::Delete(market);
    Object::Delete(report);
    Object::Delete(terminal);
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
    for (DictStructIterator<long, Ref<Strategy>> iter = strats[_tf].Begin(); iter.IsValid(); ++iter) {
      Strategy *_strat = iter.Value().Ptr();
      if (_strat.IsEnabled()) {
        if (estate.new_periods != DATETIME_NONE) {
          // Process when new periods started.
          _strat.OnPeriod(estate.new_periods);
          eresults.stg_processed_periods++;
        }
        if (_strat.TickFilter(_tick)) {
          if (!_strat.IsSuspended()) {
            if (_strat.Trade().IsTradeAllowed()) {
              StgProcessResult _strat_result = _strat.Process(estate.new_periods);
              eresults.last_error = fmax(eresults.last_error, _strat_result.last_error);
              eresults.stg_errored += (int)_strat_result.last_error > ERR_NO_ERROR;
              eresults.stg_processed++;
            }
          } else {
            eresults.stg_suspended++;
          }
        }
      }
    }
    return eresults;
  }
  virtual EAProcessResult ProcessTick() {
    if (estate.IsEnabled()) {
      eresults.Reset();
      if (estate.IsActive()) {
        market.SetTick(SymbolInfo::GetTick(_Symbol));
        ProcessPeriods();
        for (DictObjectIterator<ENUM_TIMEFRAMES, DictStruct<long, Ref<Strategy>>> iter_tf = strats.Begin();
             iter_tf.IsValid(); ++iter_tf) {
          ENUM_TIMEFRAMES _tf = iter_tf.Key();
          ProcessTick(_tf, market.GetLastTick());
        }
        if (eresults.last_error > ERR_NO_ERROR) {
          logger.Ptr().Flush();
        }
      }
      estate.last_updated.Update();
      if (estate.new_periods > 0) {
        // Process data and tasks on new periods.
        ProcessData();
        ProcessTasks();
      }
    }
    return eresults;
  }

  /**
   * Process data to store.
   */
  void ProcessData() {
    long _timestamp = estate.last_updated.GetEntry().GetTimestamp();
    if ((eparams.data_store & EA_DATA_STORE_CHART) != 0) {
      ChartEntry _entry = Chart().GetEntry();
      data_chart.Add(_entry, _entry.GetOHLC().time);
    }
    if ((eparams.data_store & EA_DATA_STORE_INDICATOR) != 0) {
      for (DictObjectIterator<ENUM_TIMEFRAMES, DictStruct<long, Ref<Strategy>>> iter_tf = strats.Begin();
           iter_tf.IsValid(); ++iter_tf) {
        ENUM_TIMEFRAMES _itf = iter_tf.Key();
        for (DictStructIterator<long, Ref<Strategy>> iter = strats[_itf].Begin(); iter.IsValid(); ++iter) {
          Strategy *_strati = iter.Value().Ptr();
          Indicator *_indi = _strati.GetParams().GetIndicator();
          if (_indi != NULL) {
            IndicatorDataEntry _ientry = _indi.GetEntry();
            if (!data_indi.KeyExists(_itf)) {
              // Create new timeframe buffer if does not exist.
              data_indi.Set(_itf, new BufferStruct<IndicatorDataEntry>);
            }
            // Save entry into data_indi.
            data_indi[_itf].Add(_ientry);
          }
        }
      }
    }
    if ((eparams.data_store & EA_DATA_STORE_STRATEGY) != 0) {
      for (DictObjectIterator<ENUM_TIMEFRAMES, DictStruct<long, Ref<Strategy>>> iter_tf = strats.Begin();
           iter_tf.IsValid(); ++iter_tf) {
        ENUM_TIMEFRAMES _stf = iter_tf.Key();
        for (DictStructIterator<long, Ref<Strategy>> iter = strats[_stf].Begin(); iter.IsValid(); ++iter) {
          Strategy *_strat = iter.Value().Ptr();
          StgEntry _sentry = _strat.GetEntry();
          if (!data_stg.KeyExists(_stf)) {
            // Create new timeframe buffer if does not exist.
            data_stg.Set(_stf, new BufferStruct<StgEntry>);
          }
          // Save data into data_stg.
          data_stg[_stf].Add(_sentry);
        }
      }
    }
    if ((eparams.data_store & EA_DATA_STORE_SYMBOL) != 0) {
      data_symbol.Add(SymbolInfo().GetEntryLast(), _timestamp);
    }
    if ((eparams.data_store & EA_DATA_STORE_TRADE) != 0) {
      // @todo
    }
  }

  /**
   * Checks for new starting periods.
   */
  unsigned short ProcessPeriods() {
    estate.new_periods = estate.last_updated.GetStartedPeriods();
    OnPeriod();
    return estate.new_periods;
  }

  /**
   * Export data.
   */
  void DataExport(unsigned short _methods = EA_DATA_EXPORT_NONE) {
    long _timestamp = estate.last_updated.GetEntry().GetTimestamp();
    if ((eparams.data_store & EA_DATA_STORE_CHART) != 0) {
      string _key_chart = "Chart";
      if ((_methods & EA_DATA_EXPORT_CSV) != 0) {
        SerializerConverter _stub_chart =
            Serializer::MakeStubObject<BufferStruct<ChartEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN);
        SerializerConverter::FromObject(data_chart, SERIALIZER_FLAG_SKIP_HIDDEN)
            .ToFile<SerializerCsv>(_key_chart + ".csv", SERIALIZER_FLAG_SKIP_HIDDEN, &_stub_chart);
      }
      if ((_methods & EA_DATA_EXPORT_DB) != 0) {
        // @todo: Use Database class.
      }
      if ((_methods & EA_DATA_EXPORT_JSON) != 0) {
        SerializerConverter _stub_chart =
            Serializer::MakeStubObject<BufferStruct<ChartEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN);
        SerializerConverter::FromObject(data_chart, SERIALIZER_FLAG_SKIP_HIDDEN)
            .ToFile<SerializerJson>(_key_chart + ".json", SERIALIZER_FLAG_SKIP_HIDDEN, &_stub_chart);
      }
    }
    if ((eparams.data_store & EA_DATA_STORE_INDICATOR) != 0) {
      for (DictObjectIterator<ENUM_TIMEFRAMES, DictStruct<long, Ref<Strategy>>> iter_tf = strats.Begin();
           iter_tf.IsValid(); ++iter_tf) {
        ENUM_TIMEFRAMES _itf = iter_tf.Key();
        for (DictStructIterator<long, Ref<Strategy>> iter = strats[_itf].Begin(); iter.IsValid(); ++iter) {
          if (data_indi.KeyExists(_itf)) {
            string _key_indi = StringFormat("Indicator-%d", _itf);
            BufferStruct<IndicatorDataEntry> _indi_buff = data_indi.GetByKey(_itf);
            if ((_methods & EA_DATA_EXPORT_CSV) != 0) {
              SerializerConverter _stub_indi =
                  Serializer::MakeStubObject<BufferStruct<IndicatorDataEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN);
              SerializerConverter::FromObject(_indi_buff, SERIALIZER_FLAG_SKIP_HIDDEN)
                  .ToFile<SerializerCsv>(_key_indi + ".csv", SERIALIZER_FLAG_SKIP_HIDDEN, &_stub_indi);
            }
            if ((_methods & EA_DATA_EXPORT_DB) != 0) {
              // @todo: Use Database class.
            }
            if ((_methods & EA_DATA_EXPORT_JSON) != 0) {
              SerializerConverter _stub_indi =
                  Serializer::MakeStubObject<BufferStruct<IndicatorDataEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN);
              SerializerConverter::FromObject(_indi_buff, SERIALIZER_FLAG_SKIP_HIDDEN)
                  .ToFile<SerializerJson>(_key_indi + ".json", SERIALIZER_FLAG_SKIP_HIDDEN, &_stub_indi);
            }
          }
        }
      }
    }
    if ((eparams.data_store & EA_DATA_STORE_STRATEGY) != 0) {
      for (DictObjectIterator<ENUM_TIMEFRAMES, DictStruct<long, Ref<Strategy>>> iter_tf = strats.Begin();
           iter_tf.IsValid(); ++iter_tf) {
        ENUM_TIMEFRAMES _stf = iter_tf.Key();
        for (DictStructIterator<long, Ref<Strategy>> iter = strats[_stf].Begin(); iter.IsValid(); ++iter) {
          if (data_stg.KeyExists(_stf)) {
            string _key_stg = StringFormat("Strategy-%d", _stf);
            BufferStruct<StgEntry> _stg_buff = data_stg.GetByKey(_stf);
            if ((_methods & EA_DATA_EXPORT_CSV) != 0) {
              SerializerConverter _stub_stg =
                  Serializer::MakeStubObject<BufferStruct<StgEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN);
              SerializerConverter::FromObject(_stg_buff, SERIALIZER_FLAG_SKIP_HIDDEN)
                  .ToFile<SerializerCsv>(_key_stg + ".csv", SERIALIZER_FLAG_SKIP_HIDDEN, &_stub_stg);
            }
            if ((_methods & EA_DATA_EXPORT_DB) != 0) {
              // @todo: Use Database class.
            }
            if ((_methods & EA_DATA_EXPORT_JSON) != 0) {
              SerializerConverter _stub_stg =
                  Serializer::MakeStubObject<BufferStruct<StgEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN);
              SerializerConverter::FromObject(_stg_buff, SERIALIZER_FLAG_SKIP_HIDDEN)
                  .ToFile<SerializerJson>(_key_stg + ".json", SERIALIZER_FLAG_SKIP_HIDDEN, &_stub_stg);
            }
          }
        }
      }
    }
    if ((eparams.data_store & EA_DATA_STORE_SYMBOL) != 0) {
      string _key_sym = "Symbol";
      if ((_methods & EA_DATA_EXPORT_CSV) != 0) {
        SerializerConverter _stub_symbol =
            Serializer::MakeStubObject<BufferStruct<SymbolInfoEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN);
        SerializerConverter::FromObject(data_symbol, SERIALIZER_FLAG_SKIP_HIDDEN)
            .ToFile<SerializerCsv>(_key_sym + ".csv", SERIALIZER_FLAG_SKIP_HIDDEN, &_stub_symbol);
      }
      if ((_methods & EA_DATA_EXPORT_DB) != 0) {
        // @todo: Use Database class.
      }
      if ((_methods & EA_DATA_EXPORT_JSON) != 0) {
        SerializerConverter _stub_symbol =
            Serializer::MakeStubObject<BufferStruct<SymbolInfoEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN);
        SerializerConverter::FromObject(data_symbol, SERIALIZER_FLAG_SKIP_HIDDEN)
            .ToFile<SerializerJson>(_key_sym + ".json", SERIALIZER_FLAG_SKIP_HIDDEN, &_stub_symbol);
      }
    }
    if ((eparams.data_store & EA_DATA_STORE_TRADE) != 0) {
      string _key_trade = "Trade";
      if ((_methods & EA_DATA_EXPORT_CSV) != 0) {
        // @todo
        // SerializerConverter _stub_trade =
        // Serializer::MakeStubObject<BufferStruct<TradeEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN);
        // SerializerConverter::FromObject(data_trade, SERIALIZER_FLAG_SKIP_HIDDEN).ToFile<SerializerCsv>(_key + ".csv",
        // SERIALIZER_FLAG_SKIP_HIDDEN, &_stub_trade);
      }
      if ((_methods & EA_DATA_EXPORT_DB) != 0) {
        // @todo: Use Database class.
      }
      if ((_methods & EA_DATA_EXPORT_JSON) != 0) {
        // @todo
        // SerializerConverter _stub_trade =
        // Serializer::MakeStubObject<BufferStruct<TradeEntry>>(SERIALIZER_FLAG_SKIP_HIDDEN);
        // SerializerConverter::FromObject(data_trade, SERIALIZER_FLAG_SKIP_HIDDEN).ToFile<SerializerJson>(_key +
        // ".json", SERIALIZER_FLAG_SKIP_HIDDEN, &_stub_trade);
      }
    }
  }

  /* Tasks */

  /**
   * Add task.
   */
  void AddTask(TaskEntry &_entry) {
    if (_entry.IsValid()) {
      if (_entry.GetAction().GetType() == ACTION_TYPE_EA) {
        _entry.SetActionObject(GetPointer(this));
      }
      if (_entry.GetCondition().GetType() == COND_TYPE_EA) {
        _entry.SetConditionObject(GetPointer(this));
      }
      tasks.Push(_entry);
    }
  }

  /**
   * Process EA tasks.
   */
  unsigned int ProcessTasks() {
    unsigned int _counter = 0;
    for (DictStructIterator<short, TaskEntry> iter = tasks.Begin(); iter.IsValid(); ++iter) {
      bool _is_processed = false;
      TaskEntry _entry = iter.Value();
      _is_processed = Task::Process(_entry);
      _counter += (unsigned short)_is_processed;
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
    Ref<Strategy> _strat = ((SClass *)NULL).Init(_tf);
    DictStruct<long, Ref<Strategy>> _strat_dict;
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
    bool _result = false;
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
  bool CheckCondition(ENUM_EA_CONDITION _cond, MqlParam &_args[]) {
    switch (_cond) {
      case EA_COND_IS_ACTIVE:
        return estate.IsActive();
      case EA_COND_IS_ENABLED:
        return estate.IsEnabled();
      case EA_COND_IS_NOT_CONNECTED:
        estate.SetFlag(EA_STATE_FLAG_CONNECTED, terminal.IsConnected());
        return !estate.IsConnected();
      case EA_COND_ON_NEW_MINUTE:  // On new minute.
        return (estate.new_periods & DATETIME_MINUTE) != 0;
      case EA_COND_ON_NEW_HOUR:  // On new hour.
        return (estate.new_periods & DATETIME_HOUR) != 0;
      case EA_COND_ON_NEW_DAY:  // On new day.
        return (estate.new_periods & DATETIME_DAY) != 0;
      case EA_COND_ON_NEW_WEEK:  // On new week.
        return (estate.new_periods & DATETIME_WEEK) != 0;
      case EA_COND_ON_NEW_MONTH:  // On new month.
        return (estate.new_periods & DATETIME_MONTH) != 0;
      case EA_COND_ON_NEW_YEAR:  // On new year.
        return (estate.new_periods & DATETIME_YEAR) != 0;
      case EA_COND_ON_INIT:
        return estate.IsOnInit();
      case EA_COND_ON_QUIT:
        return estate.IsOnQuit();
      default:
        Logger().Error(StringFormat("Invalid EA condition: %s!", EnumToString(_cond), __FUNCTION_LINE__));
        return false;
    }
  }
  bool CheckCondition(ENUM_EA_CONDITION _cond) {
    MqlParam _args[] = {};
    return EA::CheckCondition(_cond, _args);
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
    double arg1d = EMPTY_VALUE;
    long arg1i = EMPTY;
    if (ArraySize(_args) > 0) {
      arg1d = _args[0].type == TYPE_DOUBLE ? _args[0].double_value : EMPTY_VALUE;
      arg1i = _args[0].type == TYPE_INT ? _args[0].integer_value : EMPTY;
    }
    switch (_action) {
      case EA_ACTION_DISABLE:
        estate.Enable(false);
        return true;
      case EA_ACTION_ENABLE:
        estate.Enable();
        return true;
      case EA_ACTION_EXPORT_DATA:
        DataExport((unsigned short)(arg1i != EMPTY ? arg1i : eparams.GetDataExport()));
        return true;
      case EA_ACTION_TASKS_CLEAN:
        // @todo
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
  DictObject<ENUM_TIMEFRAMES, DictStruct<long, Ref<Strategy>>> *Strategies() { return &strats; }

  /**
   * Gets pointer to symbol details.
   */
  SymbolInfo *SymbolInfo() { return (SymbolInfo *)market; }

  /**
   * Gets pointer to terminal instance.
   */
  Terminal *Terminal() { return terminal; }

  /* Setters */

  /* Virtual methods */

  /**
   * Event on new time periods.
   */
  virtual void OnPeriod() {
    if ((estate.new_periods & DATETIME_MINUTE) != 0) {
      // New minute started.
    }
    if ((estate.new_periods & DATETIME_HOUR) != 0) {
      // New hour started.
    }
    if ((estate.new_periods & DATETIME_DAY) != 0) {
      // New day started.
    }
    if ((estate.new_periods & DATETIME_WEEK) != 0) {
      // New week started.
    }
    if ((estate.new_periods & DATETIME_MONTH) != 0) {
      // New month started.
    }
    if ((estate.new_periods & DATETIME_YEAR) != 0) {
      // New year started.
    }
  }

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
};
#endif  // EA_MQH

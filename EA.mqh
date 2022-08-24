//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
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
#include "Chart.mqh"
#include "Data.struct.h"
#include "Dict.mqh"
#include "DictObject.mqh"
#include "EA.enum.h"
#include "EA.struct.h"
#include "Market.mqh"
#include "Platform.h"
#include "Refs.struct.h"
#include "Serializer/SerializerConverter.h"
#include "Serializer/SerializerCsv.h"
#include "Serializer/SerializerJson.h"
#include "Serializer/SerializerSqlite.h"
#include "Strategy.mqh"
#include "SummaryReport.mqh"
#include "Task/TaskManager.h"
#include "Task/Taskable.h"
#include "Terminal.mqh"
#include "Trade.mqh"
#include "Trade/TradeSignal.h"
#include "Trade/TradeSignalManager.h"

class EA : public Taskable<DataParamEntry> {
 protected:
  // Class variables.
  AccountMt *account;
  DictStruct<long, Ref<Strategy>> strats;
  Log logger;
  Terminal terminal;

  // Data variables.
  BufferStruct<ChartEntry> data_chart;
  BufferStruct<SymbolInfoEntry> data_symbol;
  Dict<string, double> ddata;  // Custom user data.
  Dict<string, int> idata;     // Custom user data.
  DictObject<string, Trade> trade;
  DictObject<ENUM_TIMEFRAMES, BufferStruct<IndicatorDataEntry>> data_indi;
  DictObject<ENUM_TIMEFRAMES, BufferStruct<StgEntry>> data_stg;
  EAParams eparams;
  EAProcessResult eresults;
  EAState estate;
  TaskManager tasks;
  TradeSignalManager tsm;

 protected:
  /* Protected methods */

  /**
   * Init code (called on constructor).
   */
  void Init() {
    // Ensuring Platform singleton is already initialized.
    Platform::Init();

    InitTask();
  }

  /**
   * Process initial task (called on constructor).
   */
  void InitTask() {
    // Add and process init task.
    TaskObject<EA, EA> _taskobj_init(eparams.GetStruct<TaskEntry>(STRUCT_ENUM(EAParams, EA_PARAM_STRUCT_TASK_ENTRY)),
                                     THIS_PTR, THIS_PTR);
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_ON_INIT), true);
    _taskobj_init.Process();
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_ON_INIT), false);
  }

 public:
  /**
   * Class constructor.
   */
  EA(EAParams &_params) : account(new AccountMt) {
    eparams = _params;
    UpdateStateFlags();
    // Add and process tasks.
    Init();
    // Initialize a trade instance for the current chart and symbol.
    Ref<IndicatorBase> _source = Platform::FetchDefaultCandleIndicator(_Symbol, PERIOD_CURRENT);
    TradeParams _tparams;
    Trade _trade(_tparams, _source.Ptr());
    trade.Set(_Symbol, _trade);
    logger.Link(_trade.GetLogger());
  }

  /**
   * Class deconstructor.
   */
  ~EA() {
    // Process tasks on quit.
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_ON_QUIT), true);
    ProcessTasks();
    // Deinitialize classes.
    Object::Delete(account);
  }

  /* Getters */

  /**
   * Gets EA state flag value.
   */
  bool Get(STRUCT_ENUM(EAState, ENUM_EA_STATE_FLAGS) _prop) { return estate.Get(_prop); }

  /**
   * Gets EA parameter value.
   */
  template <typename T>
  T Get(STRUCT_ENUM(EAParams, ENUM_EA_PARAM_PROP) _param) {
    return eparams.Get<T>(_param);
  }

  /**
   * Gets EA state property value.
   */
  template <typename T>
  T Get(STRUCT_ENUM(EAState, ENUM_EA_STATE_PROP) _prop) {
    return estate.Get<T>(_prop);
  }

  /**
   * Gets a Trade's state value.
   */
  template <typename T>
  T Get(ENUM_TRADE_STATE _state, string _symbol = NULL) {
    return trade.GetByKey(_symbol != NULL ? _symbol : _Symbol).Get<T>(_state);
  }

  /**
   * Gets a strategy's signal entry.
   *
   * @param Strategy _strat
   *   Reference to strategy to get the signal from.
   * @param bool _trade_allowed
   *   True if trade is allowed.
   * @param int _shift
   *   Bar shift.
   *
   * @return
   *   Returns TradeSignalEntry struct.
   */
  TradeSignalEntry GetStrategySignalEntry(Strategy *_strat, bool _trade_allowed = true, int _shift = 0) {
    // float _bf = 1.0;
    float _scl = _strat.Get<float>(STRAT_PARAM_SCL);
    float _sol = _strat.Get<float>(STRAT_PARAM_SOL);
    int _scfm = _strat.Get<int>(STRAT_PARAM_SCFM);
    int _scft = _strat.Get<int>(STRAT_PARAM_SCFT);
    int _scm = _strat.Get<int>(STRAT_PARAM_SCM);
    int _sob = _strat.Get<int>(STRAT_PARAM_SOB);
    int _sofm = _strat.Get<int>(STRAT_PARAM_SOFM);
    int _soft = _strat.Get<int>(STRAT_PARAM_SOFT);
    int _som = _strat.Get<int>(STRAT_PARAM_SOM);
    int _ss = _shift >= 0 ? _shift : _strat.Get<int>(STRAT_PARAM_SHIFT);
    unsigned int _signals = 0;
    // sparams.Get<float>(STRAT_PARAM_WEIGHT));
    if (_trade_allowed) {
      // Process boost factor and lot size.
      // sresult.SetBoostFactor(sparams.IsBoosted() ? SignalOpenBoost(ORDER_TYPE_BUY, _sob) : 1.0f);
      // sresult.SetLotSize(sparams.GetLotSizeWithFactor());
      // Process open signals when trade is allowed.
      _signals |= _strat.SignalOpen(ORDER_TYPE_BUY, _som, _sol, _ss) ? SIGNAL_OPEN_BUY_MAIN : 0;
      _signals |= !_strat.SignalOpenFilterMethod(ORDER_TYPE_BUY, _sofm) ? SIGNAL_OPEN_BUY_FILTER : 0;
      _signals |= _strat.SignalOpen(ORDER_TYPE_SELL, _som, _sol, _ss) ? SIGNAL_OPEN_SELL_MAIN : 0;
      _signals |= !_strat.SignalOpenFilterMethod(ORDER_TYPE_SELL, _sofm) ? SIGNAL_OPEN_SELL_FILTER : 0;
      _signals |= !_strat.SignalOpenFilterTime(_soft) ? SIGNAL_OPEN_TIME_FILTER : 0;
    }
    // Process close signals.
    _signals |= _strat.SignalClose(ORDER_TYPE_BUY, _scm, _scl, _ss) ? SIGNAL_CLOSE_BUY_MAIN : 0;
    _signals |= !_strat.SignalCloseFilter(ORDER_TYPE_BUY, _scfm) ? SIGNAL_CLOSE_BUY_FILTER : 0;
    _signals |= _strat.SignalClose(ORDER_TYPE_SELL, _scm, _scl, _ss) ? SIGNAL_CLOSE_SELL_MAIN : 0;
    _signals |= !_strat.SignalCloseFilter(ORDER_TYPE_SELL, _scfm) ? SIGNAL_CLOSE_SELL_FILTER : 0;
    _signals |= !_strat.SignalCloseFilterTime(_scft) ? SIGNAL_CLOSE_TIME_FILTER : 0;
    TradeSignalEntry _sentry(_signals, _strat.GetSource() PTR_DEREF GetTf(), _strat.Get<long>(STRAT_PARAM_ID));
    _sentry.Set(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_STRENGTH), _strat.SignalOpen(_sofm, _sol, _ss));
    _sentry.Set(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_TIME), ::TimeGMT());
    return _sentry;
  }

  /* Setters */

  /**
   * Sets an EA parameter value.
   */
  template <typename T>
  void Set(STRUCT_ENUM(EAParams, ENUM_EA_PARAM_PROP) _param, T _value) {
    eparams.Set<T>(_param, _value);
  }

  /**
   * Sets EA state flag value.
   */
  void Set(STRUCT_ENUM(EAState, ENUM_EA_STATE_FLAGS) _prop, bool _value) { estate.Set(_prop, _value); }

  /**
   * Sets an strategy parameter value for all strategies.
   */
  template <typename T>
  void Set(ENUM_STRATEGY_PARAM _param, T _value) {
    for (DictStructIterator<long, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
      Strategy *_strat = iter.Value().Ptr();
      _strat.Set<T>(_param, _value);
    }
  }

  /**
   * Sets a trade parameter value for all trade instances.
   */
  template <typename T>
  void Set(ENUM_TRADE_PARAM _param, T _value) {
    for (DictObjectIterator<string, Trade> iter = trade.Begin(); iter.IsValid(); ++iter) {
      Trade *_trade = iter.Value();
      _trade.Set<T>(_param, _value);
    }
  }

  /* Processing methods */

  /**
   * Process strategy signals.
   */
  bool ProcessSignals(const MqlTick &_tick, unsigned int _sig_filter = 0, bool _trade_allowed = true) {
    bool _result = true;
    int _last_error = ERR_NO_ERROR;
    ResetLastError();
    for (DictObjectIterator<int, TradeSignal> _iter = tsm.GetIterSignalsActive(); _iter.IsValid(); ++_iter) {
      bool _result_local = true;
      TradeSignal *_signal = _iter.Value();
      if (_signal.Get(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_PROCESSED))) {
        // Ignores already processed signals.
        continue;
      }
      Trade *_trade = trade.GetByKey(_Symbol);
      Strategy *_strat =
          strats.GetByKey(_signal.Get<long>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_MAGIC_ID))).Ptr();
      if (_trade.Get<bool>(TRADE_STATE_ORDERS_ACTIVE)) {
        float _sig_close = _signal.GetSignalClose();
        string _comment_close =
            _strat != NULL && _sig_close != 0.0f ? _strat.GetOrderCloseComment() : __FUNCTION_LINE__;
        // Check if we should close the orders.
        if (_sig_close >= 0.5f) {
          // Close signal for buy order.
          _trade.OrdersCloseViaProp2<ENUM_ORDER_PROPERTY_INTEGER, long>(
              ORDER_MAGIC, _signal.Get<long>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_MAGIC_ID)), ORDER_TYPE,
              ORDER_TYPE_BUY, MATH_COND_EQ, ORDER_REASON_CLOSED_BY_SIGNAL, _comment_close);
          // Buy orders closed.
          _strat.OnOrderClose(ORDER_TYPE_BUY);
        }
        if (_sig_close <= -0.5f) {
          // Close signal for sell order.
          _trade.OrdersCloseViaProp2<ENUM_ORDER_PROPERTY_INTEGER, long>(
              ORDER_MAGIC, _signal.Get<long>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_MAGIC_ID)), ORDER_TYPE,
              ORDER_TYPE_SELL, MATH_COND_EQ, ORDER_REASON_CLOSED_BY_SIGNAL, _comment_close);
          // Sell orders closed.
          _strat.OnOrderClose(ORDER_TYPE_SELL);
        }
      }
      _trade_allowed &= _trade.IsTradeAllowed();
      _trade_allowed &= !_strat.IsSuspended();
      if (_trade_allowed) {
        float _sig_open = _signal.GetSignalOpen();
        unsigned int _sig_f = eparams.Get<unsigned int>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_SIGNAL_FILTER));
        string _comment_open = _strat != NULL && _sig_open != 0.0f ? _strat.GetOrderOpenComment() : __FUNCTION_LINE__;
        // Open orders on signals.
        if (_sig_open >= 0.5f) {
          // Open signal for buy.
          // When H1 or H4 signal filter is enabled, do not open minute-based orders on opposite or neutral signals.
          if (_sig_f == 0) {  // @fixme: || GetSignalOpenFiltered(_signal, _sig_f) >= 0.5f) {
            _strat.Set(TRADE_PARAM_ORDER_COMMENT, _comment_open);
            // Buy order open.
            _result_local &= TradeRequest(ORDER_TYPE_BUY, _Symbol, _strat);
            if (_result_local && eparams.CheckSignalFilter(STRUCT_ENUM(EAParams, EA_PARAM_SIGNAL_FILTER_FIRST))) {
              _signal.Set(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_PROCESSED), true);
              break;
            }
          }
        }
        if (_sig_open <= -0.5f) {
          // Open signal for sell.
          // When H1 or H4 signal filter is enabled, do not open minute-based orders on opposite or neutral signals.
          if (_sig_f == 0) {  // @fixme: || GetSignalOpenFiltered(_signal, _sig_f) <= -0.5f) {
            _strat.Set(TRADE_PARAM_ORDER_COMMENT, _comment_open);
            // Sell order open.
            _result_local &= TradeRequest(ORDER_TYPE_SELL, _Symbol, _strat);
            if (_result_local && eparams.CheckSignalFilter(STRUCT_ENUM(EAParams, EA_PARAM_SIGNAL_FILTER_FIRST))) {
              _signal.Set(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_PROCESSED), true);
              break;
            }
          }
        }
        if (_result_local) {
          _signal.Set(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_PROCESSED), true);
        } else {
          _last_error = GetLastError();
          if (_last_error > 0) {
            logger.Warning(StringFormat("Error: %d", _last_error), __FUNCTION_LINE__, _strat.GetName());
            ResetLastError();
          }
          if (_trade.Get<bool>(TRADE_STATE_MONEY_NOT_ENOUGH)) {
            logger.Warning(StringFormat("Suspending strategy.", _last_error), __FUNCTION_LINE__, _strat.GetName());
            _strat.Suspended(true);
          }
        }
      }
      _result &= _result_local;
    }
    _last_error = GetLastError();
    if (_last_error > 0) {
      logger.Warning(StringFormat("Processing signals failed! Code: %d", _last_error), __FUNCTION_LINE__);
    }
    // Refresh signals after processing.
    tsm.Refresh();
    return _result && _last_error == 0;
  }

  /**
   * Process a trade request.
   *
   * @return
   *   Returns true on successful request.
   */
  virtual bool TradeRequest(ENUM_ORDER_TYPE _cmd, string _symbol = NULL, Strategy *_strat = NULL) {
    bool _result = false;
    Trade *_trade = trade.GetByKey(_symbol);
    // Prepare a request.
    MqlTradeRequest _request = _trade.GetTradeOpenRequest(_cmd);
    _request.comment = _strat.GetOrderOpenComment();
    _request.magic = _strat.Get<long>(STRAT_PARAM_ID);
    _request.price = SymbolInfoStatic::GetOpenOffer(_symbol, _cmd);
    _request.volume = fmax(_strat.Get<float>(STRAT_PARAM_LS), SymbolInfoStatic::GetVolumeMin(_symbol));

    // @fixit Uncomment
    // _request.volume = _trade.NormalizeLots(_request.volume);

    // Prepare an order parameters.
    OrderParams _oparams;
    _strat.OnOrderOpen(_oparams);
    // Send the request.
    _result = _trade.RequestSend(_request, _oparams);
    return _result;
  }

  /**
   * Process strategy signals on tick event.
   *
   * Note: Call this method for every market tick.
   *
   * @return
   *   Returns struct with the processed results.
   */
  virtual EAProcessResult ProcessTick() {
    if (estate.IsEnabled()) {
      MqlTick _tick = SymbolInfoStatic::GetTick(_Symbol);
      eresults.Reset();
      if (estate.IsActive()) {
        ProcessPeriods();
        // Process all enabled strategies and retrieve their signals.
        for (DictStructIterator<long, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
          bool _can_trade = true;
          Strategy *_strat = iter.Value().Ptr();
          Trade *_trade = trade.GetByKey(_Symbol);
          if (_strat.IsEnabled()) {
            if (estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) >= DATETIME_MINUTE) {
              // Process when new periods started.
              _strat.OnPeriod(estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)));
              _strat.ProcessTasks();
              _trade.OnPeriod(estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)));
              eresults.stg_processed_periods++;
            }
            if (_strat.TickFilter(_tick)) {
              _can_trade &= !_strat.IsSuspended();
              TradeSignalEntry _sentry = GetStrategySignalEntry(_strat, _can_trade, _strat.Get<int>(STRAT_PARAM_SHIFT));
              if (_sentry.Get<unsigned int>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_SIGNALS)) > 0) {
                TradeSignal _signal(_sentry);
                if (_signal.GetSignalClose() != _signal.GetSignalOpen()) {
                  tsm.SignalAdd(_signal);  //, _tick.time);
                }
                StgProcessResult _strat_result = _strat.GetProcessResult();
                eresults.last_error = fmax(eresults.last_error, _strat_result.last_error);
                eresults.stg_errored += (int)_strat_result.last_error > ERR_NO_ERROR;
                eresults.stg_processed++;
              }
            }
          }
        }
        if (tsm.GetSignalsActive().Size() > 0 && tsm.IsReady()) {
          // Process all strategies' signals and trigger trading orders.
          ProcessSignals(_tick, eparams.Get<unsigned int>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_SIGNAL_FILTER)));
        }
        if (eresults.last_error > ERR_NO_ERROR) {
          // On error, print logs.
          logger.Flush();
        }
        if (estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) >= DATETIME_MINUTE) {
          // Process data, tasks and trades on new periods.
          ProcessTrades();
        }
      }
      estate.last_updated.Update();
      if (estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) >= DATETIME_MINUTE) {
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
    if (eparams.CheckFlagDataStore(EA_DATA_STORE_CHART)) {
      ChartEntry _entry = Chart().GetEntry();
      data_chart.Add(_entry, _entry.bar.ohlc.time);
    }
    if (eparams.CheckFlagDataStore(EA_DATA_STORE_INDICATOR)) {
      for (DictStructIterator<long, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
        Strategy *_strati = iter.Value().Ptr();
        IndicatorData *_indi = _strati.GetIndicator();
        if (_indi != NULL) {
          ENUM_TIMEFRAMES _itf = _indi PTR_DEREF GetTf();
          IndicatorDataEntry _ientry = _indi.GetEntry();
          if (!data_indi.KeyExists(_itf)) {
            // Create new timeframe buffer if does not exist.
            BufferStruct<IndicatorDataEntry> *_ide = new BufferStruct<IndicatorDataEntry>;
            data_indi.Set(_itf, _ide);
          }
          // Save entry into data_indi.
          data_indi[_itf].Add(_ientry);
        }
      }
    }
    /*
    if (eparams.CheckFlagDataStore(EA_DATA_STORE_STRATEGY)) {
      for (DictStructIterator<long, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
        Strategy *_strat = iter.Value().Ptr();
        StgEntry _sentry = _strat.GetEntry();
        ENUM_TIMEFRAMES _stf = iter_tf.Key(); // @fixme
        if (!data_stg.KeyExists(_stf)) {
          // Create new timeframe buffer if does not exist.
          BufferStruct<StgEntry> *_se = new BufferStruct<StgEntry>;
          data_stg.Set(_stf, _se);
        }
        // Save data into data_stg.
        data_stg[_stf].Add(_sentry);
      }
    }
    */
    if (eparams.CheckFlagDataStore(EA_DATA_STORE_SYMBOL)) {
      data_symbol.Add(SymbolInfo().GetEntryLast(), _timestamp);
    }
    if (eparams.CheckFlagDataStore(EA_DATA_STORE_TRADE)) {
      // @todo
    }
  }

  /**
   * Checks for new starting periods.
   */
  unsigned int ProcessPeriods() {
    estate.Set<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS), estate.last_updated.GetStartedPeriods());
    OnPeriod();
    return estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS));
  }

  /**
   * Export data.
   */
  void DataExport(unsigned short _methods) {
    long _timestamp = estate.last_updated.GetEntry().GetTimestamp();
    int _serializer_flags = SERIALIZER_FLAG_SKIP_HIDDEN | SERIALIZER_FLAG_INCLUDE_DEFAULT |
                            SERIALIZER_FLAG_INCLUDE_DYNAMIC | SERIALIZER_FLAG_REUSE_STUB | SERIALIZER_FLAG_REUSE_OBJECT;

    if (eparams.CheckFlagDataStore(EA_DATA_STORE_CHART)) {
      string _key_chart = "Chart";
      _key_chart += StringFormat("-%d-%d", data_chart.GetMin(), data_chart.GetMax());

      SerializerConverter _stub = SerializerConverter::MakeStubObject<BufferStruct<ChartEntry>>(_serializer_flags);
      SerializerConverter _obj = SerializerConverter::FromObject(data_chart, _serializer_flags);

      if ((_methods & EA_DATA_EXPORT_CSV) != 0) {
        _obj.ToFile<SerializerCsv>(_key_chart + ".csv", _serializer_flags, &_stub);
      }
      if ((_methods & EA_DATA_EXPORT_DB) != 0) {
        SerializerSqlite::ConvertToFile(_obj, _key_chart + ".sqlite", "chart", _serializer_flags, &_stub);
      }
      if ((_methods & EA_DATA_EXPORT_JSON) != 0) {
        _obj.ToFile<SerializerJson>(_key_chart + ".json", _serializer_flags, &_stub);
      }

      // Required because of SERIALIZER_FLAG_REUSE_STUB flag.
      _stub.Clean();

      // Required because of SERIALIZER_FLAG_REUSE_OBJECT flag.
      _obj.Clean();
    }
    if (eparams.CheckFlagDataStore(EA_DATA_STORE_INDICATOR)) {
      SerializerConverter _stub =
          SerializerConverter::MakeStubObject<BufferStruct<IndicatorDataEntry>>(_serializer_flags);

      /*
      for (DictStructIterator<long, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
        ENUM_TIMEFRAMES _itf = iter_tf.Key(); // @fixme
        if (data_indi.KeyExists(_itf)) {
          BufferStruct<IndicatorDataEntry> _indi_buff = data_indi.GetByKey(_itf);

          SerializerConverter _obj = SerializerConverter::FromObject(_indi_buff, _serializer_flags);

          for (DictStructIterator<long, Ref<Strategy>> iter = strats[_itf].Begin(); iter.IsValid(); ++iter) {
            string _key_indi = "Indicator";
            _key_indi += StringFormat("-%d-%d-%d", _itf, _indi_buff.GetMin(), _indi_buff.GetMax());

            if ((_methods & EA_DATA_EXPORT_CSV) != 0) {
              _obj.ToFile<SerializerCsv>(_key_indi + ".csv", _serializer_flags, &_stub);
            }
            if ((_methods & EA_DATA_EXPORT_DB) != 0) {
              SerializerSqlite::ConvertToFile(_obj, _key_indi + ".sqlite", "indicator", _serializer_flags, &_stub);
            }
            if ((_methods & EA_DATA_EXPORT_JSON) != 0) {
              _obj.ToFile<SerializerJson>(_key_indi + ".json", _serializer_flags, &_stub);
            }
          }  // for

          // Required because of SERIALIZER_FLAG_REUSE_OBJECT flag.
          _obj.Clean();
        }  // if
      }
      */

      // Required because of SERIALIZER_FLAG_REUSE_STUB flag.
      _stub.Clean();
    }
    if (eparams.CheckFlagDataStore(EA_DATA_STORE_STRATEGY)) {
      SerializerConverter _stub = SerializerConverter::MakeStubObject<BufferStruct<StgEntry>>(_serializer_flags);

      /* @fixme
      for (DictStructIterator<long, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
        ENUM_TIMEFRAMES _stf = iter_tf.Key(); // @fixme
        if (data_stg.KeyExists(_stf)) {
          string _key_stg = StringFormat("Strategy-%d", _stf);
          BufferStruct<StgEntry> _stg_buff = data_stg.GetByKey(_stf);
          SerializerConverter _obj = SerializerConverter::FromObject(_stg_buff, _serializer_flags);

          _key_stg += StringFormat("-%d-%d-%d", _stf, _stg_buff.GetMin(), _stg_buff.GetMax());
          if ((_methods & EA_DATA_EXPORT_CSV) != 0) {
            _obj.ToFile<SerializerCsv>(_key_stg + ".csv", _serializer_flags, &_stub);
          }
          if ((_methods & EA_DATA_EXPORT_DB) != 0) {
            SerializerSqlite::ConvertToFile(_obj, _key_stg + ".sqlite", "strategy", _serializer_flags, &_stub);
          }
          if ((_methods & EA_DATA_EXPORT_JSON) != 0) {
            _obj.ToFile<SerializerJson>(_key_stg + ".json", _serializer_flags, &_stub);
          }

          // Required because of SERIALIZER_FLAG_REUSE_OBJECT flag.
          _obj.Clean();
        }
      }
      */
      // Required because of SERIALIZER_FLAG_REUSE_STUB flag.
      _stub.Clean();
    }
    if (eparams.CheckFlagDataStore(EA_DATA_STORE_SYMBOL)) {
      SerializerConverter _stub = SerializerConverter::MakeStubObject<BufferStruct<SymbolInfoEntry>>(_serializer_flags);
      SerializerConverter _obj = SerializerConverter::FromObject(data_symbol, _serializer_flags);

      string _key_sym = "Symbol";
      _key_sym += StringFormat("-%d-%d", data_symbol.GetMin(), data_symbol.GetMax());
      if ((_methods & EA_DATA_EXPORT_CSV) != 0) {
        _obj.ToFile<SerializerCsv>(_key_sym + ".csv", _serializer_flags, &_stub);
      }
      if ((_methods & EA_DATA_EXPORT_DB) != 0) {
        SerializerSqlite::ConvertToFile(_obj, _key_sym + ".sqlite", "symbol", _serializer_flags, &_stub);
      }
      if ((_methods & EA_DATA_EXPORT_JSON) != 0) {
        _obj.ToFile<SerializerJson>(_key_sym + ".json", _serializer_flags, &_stub);
      }

      // Required because of SERIALIZER_FLAG_REUSE_STUB flag.
      _stub.Clean();

      // Required because of SERIALIZER_FLAG_REUSE_OBJECT flag.
      _obj.Clean();
    }
    if (eparams.CheckFlagDataStore(EA_DATA_STORE_TRADE)) {
      string _key_trade = "Trade";
      // _key_sym += StringFormat("-%d-%d", data_trade.GetMin(), data_trade.GetMax());
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

  /**
   * Export data using default methods.
   */
  void DataExport() { DataExport(eparams.Get<unsigned short>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_DATA_EXPORT))); }

  /* Signal methods */

  /**
   * Returns signal open value after filtering.
   *
   * @return
   *   Returns 1 when buy signal exists, -1 for sell, otherwise 0 for neutral signal.
   */
  /* @fixme: Convert into TradeSignal format.
  float GetSignalOpenFiltered(StrategySignal &_signal, unsigned int _sf) {
    float _result = _signal.GetSignalOpen();
    ENUM_TIMEFRAMES _sig_tf = _signal.Get<ENUM_TIMEFRAMES>(STRUCT_ENUM(StrategySignal, STRATEGY_SIGNAL_PROP_TF));
    if (ChartTf::TfToHours(_sig_tf) < 1 && bool(_sf & STRUCT_ENUM(EAParams, EA_PARAM_SIGNAL_FILTER_OPEN_M_IF_H))) {
      _result = 0;
      long _tfts[4];
      _tfts[0] = ChartStatic::iTime(_Symbol, PERIOD_H1);
      _tfts[1] = ChartStatic::iTime(_Symbol, PERIOD_H4);
      _tfts[2] = ChartStatic::iTime(_Symbol, PERIOD_H1, 1);
      _tfts[3] = ChartStatic::iTime(_Symbol, PERIOD_H4, 1);
      for (int i = 0; i < ArraySize(_tfts); i++) {
        DictStruct<short, StrategySignal> _ds = strat_signals.GetByKey(_tfts[i]);
        for (DictStructIterator<short, StrategySignal> _dsi = _ds.Begin(); _dsi.IsValid(); ++_dsi) {
          StrategySignal _dsss = _dsi.Value();
          ENUM_TIMEFRAMES _dsss_tf = _dsss.Get<ENUM_TIMEFRAMES>(STRUCT_ENUM(StrategySignal, STRATEGY_SIGNAL_PROP_TF));
          if (ChartTf::TfToHours(_dsss_tf) >= 1) {
            _result = _dsss.GetSignalOpen();
            if (_result != 0) {
              return _result;
            }
          }
        }
      }
    }
    return _result;
  }
  */

  /* Strategy methods */

  /**
   * Adds strategy to specific timeframe.
   *
   * @param
   *   _tf - timeframe to add the strategy.
   *   _magic_no - unique order identified
   *
   * @return
   *   Returns true if the strategy has been initialized correctly, otherwise false.
   */
  template <typename SClass>
  bool StrategyAdd(ENUM_TIMEFRAMES _tf, long _magic_no = 0, int _type = 0) {
    bool _result = true;
    _magic_no = _magic_no > 0 ? _magic_no : rand();
    Ref<Strategy> _strat = ((SClass *)NULL).Init(_tf);
    _strat.Ptr().Set<long>(STRAT_PARAM_ID, _magic_no);
    _strat.Ptr().Set<ENUM_TIMEFRAMES>(STRAT_PARAM_TF, _tf);
    _strat.Ptr().Set<int>(STRAT_PARAM_TYPE, _type);
    _strat.Ptr().OnInit();
    if (!strats.KeyExists(_magic_no)) {
      _result &= strats.Set(_magic_no, _strat);
    } else {
      logger.Error("Strategy adding conflict!", __FUNCTION_LINE__);
      DebugBreak();
    }
    OnStrategyAdd(_strat.Ptr());
    return _result;
  }

  /**
   * Adds strategy to multiple timeframes.
   *
   * @param
   *   _tfs - timeframes to add strategy (using bitwise operation).
   *   _sid - strategy ID
   *   _init_magic - initial order identified
   *
   * Note:
   *   Final magic number is going to be increased by timeframe index value.
   *
   * @see: ENUM_TIMEFRAMES_INDEX
   *
   * @return
   *   Returns true if all strategies has been initialized correctly, otherwise false.
   */
  template <typename SClass>
  bool StrategyAdd(unsigned int _tfs, long _init_magic = 0, int _type = 0) {
    bool _result = true;
    for (int _tfi = 0; _tfi < sizeof(int) * 8; ++_tfi) {
      if ((_tfs & (1 << _tfi)) != 0) {
        _result &= StrategyAdd<SClass>(ChartTf::IndexToTf((ENUM_TIMEFRAMES_INDEX)_tfi), _init_magic + _tfi, _type);
      }
    }
    return _result;
  }

  /**
   * Loads existing trades for the given strategy.
   */
  bool StrategyLoadTrades(Strategy *_strat) {
    Trade *_trade = trade.GetByKey(_Symbol);
    return _trade.OrdersLoadByMagic(_strat.Get<long>(STRAT_PARAM_ID));
  }

  /* Trade methods */

  /**
   * Process open trades.
   *
   * @return
   *   Returns true on success, otherwise false.
   */
  bool ProcessTrades() {
    bool _result = true;
    ResetLastError();
    for (DictObjectIterator<string, Trade> titer = trade.Begin(); titer.IsValid(); ++titer) {
      Trade *_trade = titer.Value();
      if (_trade.Get<bool>(TRADE_STATE_ORDERS_ACTIVE)) {
        for (DictStructIterator<long, Ref<Order>> oiter = _trade.GetOrdersActive().Begin(); oiter.IsValid(); ++oiter) {
          bool _sl_valid = false, _tp_valid = false;
          double _sl_new = 0, _tp_new = 0;
          Order *_order = oiter.Value().Ptr();
          if (!_order.ShouldUpdate()) {
            continue;
          }
          _order.ProcessConditions();
          if (_order.IsClosed()) {
            _trade.OrderMoveToHistory(_order);
            continue;
          }
          ENUM_ORDER_TYPE _otype = _order.Get<ENUM_ORDER_TYPE>(ORDER_TYPE);
          Strategy *_strat = strats.GetByKey(_order.Get<unsigned long>(ORDER_MAGIC)).Ptr();
          Strategy *_strat_sl = _strat.GetStratSl();
          Strategy *_strat_tp = _strat.GetStratTp();
          if (_strat_sl != NULL || _strat_tp != NULL) {
            float _olots = _order.Get<float>(ORDER_VOLUME_CURRENT);
            float _trisk = _trade.Get<float>(TRADE_PARAM_RISK_MARGIN);
            if (_strat_sl != NULL) {
              float _psl = _strat_sl.Get<float>(STRAT_PARAM_PSL);
              float _sl_max = _trade.GetMaxSLTP(_otype, _olots, ORDER_TYPE_SL, _trisk);
              int _psm = _strat_sl.Get<int>(STRAT_PARAM_PSM);
              _sl_new = _strat_sl.PriceStop(_otype, ORDER_TYPE_SL, _psm, _psl);
              _sl_new = _trade.GetSaferSLTP(_sl_new, _sl_max, _otype, ORDER_TYPE_SL);
              _sl_new = _trade.NormalizeSL(_sl_new, _otype);
              _sl_valid = _trade.IsValidOrderSL(_sl_new, _otype, _order.Get<double>(ORDER_SL), _psm > 0);
              _sl_new = _sl_valid ? _sl_new : _order.Get<double>(ORDER_SL);
            }
            if (_strat_tp != NULL) {
              float _ppl = _strat_tp.Get<float>(STRAT_PARAM_PPL);
              float _tp_max = _trade.GetMaxSLTP(_otype, _olots, ORDER_TYPE_TP, _trisk);
              int _ppm = _strat_tp.Get<int>(STRAT_PARAM_PPM);
              _tp_new = _strat_tp.PriceStop(_otype, ORDER_TYPE_TP, _ppm, _ppl);
              _tp_new = _trade.GetSaferSLTP(_tp_new, _tp_max, _otype, ORDER_TYPE_TP);
              _tp_new = _trade.NormalizeTP(_tp_new, _otype);
              _tp_valid = _trade.IsValidOrderTP(_tp_new, _otype, _order.Get<double>(ORDER_TP), _ppm > 0);
              _tp_new = _tp_valid ? _tp_new : _order.Get<double>(ORDER_TP);
            }
          }
          if (_sl_valid || _tp_valid) {
            _result &= _order.OrderModify(_sl_new, _tp_new);
            if (_result) {
              _order.Set(ORDER_PROP_TIME_LAST_UPDATE, TimeCurrent());
            }
          }
        }
      }
    }
    return _result && _LastError == ERR_NO_ERROR;
  }

  /* Update methods */

  /**
   * Update EA state flags.
   */
  void UpdateStateFlags() {
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_CONNECTED), GetTerminal().IsConnected());
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_LIBS_ALLOWED), GetTerminal().IsLibrariesAllowed());
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_OPTIMIZATION), GetTerminal().IsOptimization());
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_TESTING), GetTerminal().IsTesting());
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_TRADE_ALLOWED), GetTerminal().IsTradeAllowed());
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_VISUAL_MODE), GetTerminal().IsVisualMode());
  }

  /**
   * Updates info on chart.
   */
  bool UpdateInfoOnChart() {
    bool _result = false;
    if (eparams.Get<int>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_CHART_INFO_FREQ)) > 0) {
      static datetime _last_update = 0;
      if (_last_update + eparams.Get<int>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_CHART_INFO_FREQ)) < TimeCurrent()) {
        _last_update = TimeCurrent();
        // @todo
        _result = true;
      }
    }
    return _result;
  }

  /**
   * Updates strategy lot size.
   */
  bool UpdateLotSize() {
    bool _result = false;
    if (eparams.CheckFlag(EA_PARAM_FLAG_LOTSIZE_AUTO)) {
      // Auto calculate lot size for all strategies.
      Trade *_trade = trade.GetByKey(_Symbol);
      _result &= _trade.Run(TRADE_ACTION_CALC_LOT_SIZE);
      Set(STRAT_PARAM_LS, _trade.Get<float>(TRADE_PARAM_LOT_SIZE));
    }
    return _result;
  }

  /* Tasks methods */

  /**
   * Add task.
   */
  bool AddTask(TaskEntry &_tentry) {
    bool _is_valid = _tentry.IsValid();
    if (_is_valid) {
      TaskObject<EA, EA> _taskobj(_tentry, THIS_PTR, THIS_PTR);
      tasks.Add(&_taskobj);
    }
    return _is_valid;
  }

  /**
   * Process tasks.
   */
  void ProcessTasks() { tasks.Process(); }

  /* Tasks */

  /**
   * Checks a condition.
   */
  virtual bool Check(const TaskConditionEntry &_entry) {
    bool _result = false;
    switch (_entry.GetId()) {
      case EA_COND_IS_ACTIVE:
        return estate.IsActive();
      case EA_COND_IS_ENABLED:
        return estate.IsEnabled();
      case EA_COND_IS_NOT_CONNECTED:
        estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_CONNECTED), GetTerminal().IsConnected());
        return !estate.IsConnected();
      case EA_COND_ON_NEW_MINUTE:  // On new minute.
        return (estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) & DATETIME_MINUTE) != 0;
      case EA_COND_ON_NEW_HOUR:  // On new hour.
        return (estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) & DATETIME_HOUR) != 0;
      case EA_COND_ON_NEW_DAY:  // On new day.
        return (estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) & DATETIME_DAY) != 0;
      case EA_COND_ON_NEW_WEEK:  // On new week.
        return (estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) & DATETIME_WEEK) != 0;
      case EA_COND_ON_NEW_MONTH:  // On new month.
        return (estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) & DATETIME_MONTH) != 0;
      case EA_COND_ON_NEW_YEAR:  // On new year.
        return (estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) & DATETIME_YEAR) != 0;
      case EA_COND_ON_INIT:
        return estate.IsOnInit();
      case EA_COND_ON_QUIT:
        return estate.IsOnQuit();
      default:
        GetLogger().Error(StringFormat("Invalid EA condition: %d!", _entry.GetId(), __FUNCTION_LINE__));
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _result;
  }

  /**
   * Gets a copy of structure.
   */
  virtual DataParamEntry Get(const TaskGetterEntry &_entry) {
    DataParamEntry _result;
    switch (_entry.GetId()) {
      default:
        break;
    }
    return _result;
  }

  /**
   * Runs an action.
   */
  virtual bool Run(const TaskActionEntry &_entry) {
    bool _result = false;
    switch (_entry.GetId()) {
      case EA_ACTION_DISABLE:
        estate.Enable(false);
        return true;
      case EA_ACTION_ENABLE:
        estate.Enable();
        return true;
      case EA_ACTION_EXPORT_DATA:
        DataExport();
        return true;
      case EA_ACTION_STRATS_EXE_ACTION: {
        // Args:
        // 1st (i:0) - Strategy's enum action to execute.
        // 2nd (i:1) - Strategy's argument to pass.
        TaskActionEntry _entry_strat = _entry;
        _entry_strat.ArgRemove(0);
        for (DictStructIterator<long, Ref<Strategy>> iter_strat = strats.Begin(); iter_strat.IsValid(); ++iter_strat) {
          Strategy *_strat = iter_strat.Value().Ptr();

          _result &= _strat.Run(_entry_strat);
        }
        return _result;
      }
      case EA_ACTION_TASKS_CLEAN:
        // @todo
        // return tasks.Size() == 0;
        SetUserError(ERR_INVALID_PARAMETER);
        return false;
      default:
        GetLogger().Error(StringFormat("Invalid EA action: %d!", _entry.GetId(), __FUNCTION_LINE__));
        SetUserError(ERR_INVALID_PARAMETER);
    }
    return _result;
  }

  /**
   * Sets an entry value.
   */
  virtual bool Set(const TaskSetterEntry &_entry, const DataParamEntry &_entry_value) {
    bool _result = false;
    switch (_entry.GetId()) {
      // _entry_value.GetValue()
      default:
        break;
    }
    return _result;
  }

  /* Getters */

  /**
   * Gets strategy based on the property value.
   *
   * @return
   *   Returns first found strategy instance on success.
   *   Otherwise, it returns NULL.
   */
  template <typename T>
  Strategy *GetStrategyViaProp(ENUM_STRATEGY_PARAM _prop, T _value, ENUM_MATH_CONDITION _op = MATH_COND_EQ) {
    for (DictStructIterator<long, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
      Strategy *_strat = iter.Value().Ptr();
      if (Math::Compare(_strat.Get<T>(_prop), _value, _op)) {
        return _strat;
      }
    }
    return NULL;
  }

  /**
   * Gets strategy based on the two property values.
   *
   * @return
   *   Returns first found strategy instance on success.
   *   Otherwise, it returns NULL.
   */
  template <typename T1, typename T2>
  Strategy *GetStrategyViaProp2(ENUM_STRATEGY_PARAM _prop1, T1 _value1, ENUM_STRATEGY_PARAM _prop2, T2 _value2,
                                ENUM_MATH_CONDITION _op = MATH_COND_EQ) {
    for (DictStructIterator<long, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
      Strategy *_strat = iter.Value().Ptr();
      if (Math::Compare(_strat.Get<T1>(_prop1), _value1, _op) && Math::Compare(_strat.Get<T2>(_prop2), _value2, _op)) {
        return _strat;
      }
    }
    return NULL;
  }

  /**
   * Returns pointer to Market object.
   */
  Terminal *GetTerminal() { return GetPointer(terminal); }

  /**
   * Gets EA's name.
   */
  EAParams GetParams() const { return eparams; }

  /**
   * Gets DictStruct reference to strategies.
   */
  DictStruct<long, Ref<Strategy>> *GetStrategies() { return GetPointer(strats); }

  /**
   * Gets EA state.
   */
  EAState GetState() { return estate; }

  /* Class getters */

  /**
   * Gets pointer to account details.
   */
  AccountMt *Account() { return account; }

  /**
   * Gets pointer to log instance.
   */
  Log *GetLogger() { return GetPointer(logger); }

  /**
   * Gets reference to strategies.
   */
  DictStruct<long, Ref<Strategy>> *Strategies() { return &strats; }

  /* Setters */

  /* Virtual methods */

  /**
   * Executed when new time is started (like each minute).
   */
  virtual void OnPeriod() {
    if ((estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) & DATETIME_MINUTE) != 0) {
      // New minute started.
#ifndef __optimize__
      if (Terminal::IsRealtime()) {
        logger.Flush();
      }
#endif
    }
    if ((estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) & DATETIME_HOUR) != 0) {
      // New hour started.
      tsm.Refresh();
    }
    if ((estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) & DATETIME_DAY) != 0) {
      // New day started.
      UpdateLotSize();
#ifndef __optimize__
      logger.Flush();
#endif
    }
    if ((estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) & DATETIME_WEEK) != 0) {
      // New week started.
    }
    if ((estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) & DATETIME_MONTH) != 0) {
      // New month started.
    }
    if ((estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) & DATETIME_YEAR) != 0) {
      // New year started.
    }
  }

  /**
   * Executed on strategy being added.
   *
   * @param _strat Strategy instance.
   * @see StrategyAdd()
   *
   */
  virtual void OnStrategyAdd(Strategy *_strat) {
    // Sets margin risk.
    float _margin_risk = eparams.Get<float>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_RISK_MARGIN_MAX));
    _strat.Set<float>(TRADE_PARAM_RISK_MARGIN, _margin_risk);
    // Link a logger instance.
    logger.Link(_strat.GetLogger());
    // Load existing strategy trades.
    StrategyLoadTrades(_strat);
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

  /* Serializers */

  /**
   * Returns serialized representation of the object instance.
   */
  SerializerNodeType Serialize(Serializer &_s) {
    _s.Pass(THIS_REF, "account", account, SERIALIZER_FIELD_FLAG_DYNAMIC);

    for (DictStructIterator<long, Ref<Strategy>> _iter = GetStrategies().Begin(); _iter.IsValid(); ++_iter) {
      Strategy *_strat = _iter.Value().Ptr();
      // @fixme: GH-422
      // _s.PassWriteOnly(this, "strat:" + _strat.GetName(), _strat);
      string _sname = _strat.GetName();  // + "@" + Chart::TfToString(_strat.GetTf()); // @todo
      string _sparams = _strat.GetParams().ToString();
      string _sresults = _strat.GetProcessResult().ToString();
      _s.Pass(THIS_REF, "strat:params:" + _sname, _sparams);
      _s.Pass(THIS_REF, "strat:results:" + _sname, _sresults);
    }
    _s.PassObject(THIS_REF, "trade", trade);
    _s.PassObject(THIS_REF, "tsm", tsm);
    return SerializerNodeObject;
  }
};
#endif  // EA_MQH

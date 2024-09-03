//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Platform/Chart/Chart.struct.static.h"
#include "EA.enum.h"
#include "EA.struct.h"
#include "Market.mqh"
#include "Platform/Chart/Chart.h"
#include "Platform/Platform.h"
#include "Platform/Terminal.h"
#include "Refs.struct.h"
#include "Serializer/SerializerConverter.h"
#include "Serializer/SerializerCsv.h"
#include "Serializer/SerializerJson.h"
#include "Serializer/SerializerSqlite.h"
#include "Storage/Data.struct.h"
#include "Storage/Dict/Dict.h"
#include "Storage/Dict/DictObject.h"
#include "Strategy.mqh"
#include "SummaryReport.mqh"
#include "Task/Task.h"
#include "Task/TaskAction.enum.h"
#include "Task/TaskCondition.enum.h"
#include "Task/TaskManager.h"
#include "Task/Taskable.h"
#include "Trade.mqh"
#include "Trade/TradeSignal.h"
#include "Trade/TradeSignalManager.h"

class EA : public Taskable<DataParamEntry> {
 protected:
  // Class variables.
  AccountMt *account;
  DictStruct<int64, Ref<Strategy>> strats;
  Log logger;
  Terminal terminal;

  // Data variables.
  BufferStruct<ChartEntry> data_chart;
  BufferStruct<SymbolInfoEntry> data_symbol;
  Dict<string, double> ddata;  // Custom user data.
  Dict<string, int> idata;     // Custom user data.
  DictStruct<string, Ref<Trade>> trade;
  DictObject<int, BufferStruct<IndicatorDataEntry>> data_indi;
  DictObject<int, BufferStruct<StgEntry>> data_stg;
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
    Ref<IndicatorData> _source = Platform::FetchDefaultCandleIndicator(Platform::GetSymbol(), Platform::GetPeriod());
    TradeParams _tparams(0, 1.0f, 0, (ENUM_LOG_LEVEL)eparams.Get<int>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_LOG_LEVEL)));
    Ref<Trade> _trade = new Trade(_tparams, _source.Ptr());
    trade.Set(_Symbol, _trade);
    logger.Link(_trade REF_DEREF GetLogger());
    logger.SetLevel((ENUM_LOG_LEVEL)eparams.Get<int>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_LOG_LEVEL)));
    //_trade.GetLogger().SetLevel((ENUM_LOG_LEVEL)eparams.Get<int>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_LOG_LEVEL)));
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
    float _scl = _strat PTR_DEREF Get<float>(STRAT_PARAM_SCL);
    float _sol = _strat PTR_DEREF Get<float>(STRAT_PARAM_SOL);
    int _scfm = _strat PTR_DEREF Get<int>(STRAT_PARAM_SCFM);
    int _scft = _strat PTR_DEREF Get<int>(STRAT_PARAM_SCFT);
    int _scm = _strat PTR_DEREF Get<int>(STRAT_PARAM_SCM);
    int _sob = _strat PTR_DEREF Get<int>(STRAT_PARAM_SOB);
    int _sofm = _strat PTR_DEREF Get<int>(STRAT_PARAM_SOFM);
    int _soft = _strat PTR_DEREF Get<int>(STRAT_PARAM_SOFT);
    int _som = _strat PTR_DEREF Get<int>(STRAT_PARAM_SOM);
    int _ss = _shift >= 0 ? _shift : _strat PTR_DEREF Get<int>(STRAT_PARAM_SHIFT);
    unsigned int _signals = 0;
    // sparams.Get<float>(STRAT_PARAM_WEIGHT));
    if (_trade_allowed) {
      // Process boost factor and lot size.
      // sresult.SetBoostFactor(sparams.IsBoosted() ? SignalOpenBoost(ORDER_TYPE_BUY, _sob) : 1.0f);
      // sresult.SetLotSize(sparams.GetLotSizeWithFactor());
      // Process open signals when trade is allowed.
      _signals |= _strat PTR_DEREF SignalOpen(ORDER_TYPE_BUY, _som, _sol, _ss) ? SIGNAL_OPEN_BUY_MAIN : 0;
      _signals |= !_strat PTR_DEREF SignalOpenFilterMethod(ORDER_TYPE_BUY, _sofm) ? SIGNAL_OPEN_BUY_FILTER : 0;
      _signals |= _strat PTR_DEREF SignalOpen(ORDER_TYPE_SELL, _som, _sol, _ss) ? SIGNAL_OPEN_SELL_MAIN : 0;
      _signals |= !_strat PTR_DEREF SignalOpenFilterMethod(ORDER_TYPE_SELL, _sofm) ? SIGNAL_OPEN_SELL_FILTER : 0;
      _signals |= !_strat PTR_DEREF SignalOpenFilterTime(_soft) ? SIGNAL_OPEN_TIME_FILTER : 0;
    }
    // Process close signals.
    _signals |= _strat PTR_DEREF SignalClose(ORDER_TYPE_BUY, _scm, _scl, _ss) ? SIGNAL_CLOSE_BUY_MAIN : 0;
    _signals |= !_strat PTR_DEREF SignalCloseFilter(ORDER_TYPE_BUY, _scfm) ? SIGNAL_CLOSE_BUY_FILTER : 0;
    _signals |= _strat PTR_DEREF SignalClose(ORDER_TYPE_SELL, _scm, _scl, _ss) ? SIGNAL_CLOSE_SELL_MAIN : 0;
    _signals |= !_strat PTR_DEREF SignalCloseFilter(ORDER_TYPE_SELL, _scfm) ? SIGNAL_CLOSE_SELL_FILTER : 0;
    _signals |= !_strat PTR_DEREF SignalCloseFilterTime(_scft) ? SIGNAL_CLOSE_TIME_FILTER : 0;
    TradeSignalEntry _sentry(_signals, _strat PTR_DEREF GetSource() PTR_DEREF GetTf(),
                             _strat PTR_DEREF Get<int64>(STRAT_PARAM_ID));
    _sentry.Set(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_STRENGTH),
                _strat PTR_DEREF SignalOpen(_sofm, _sol, _ss));
    _sentry.Set(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_TIME), ::TimeGMT());
    return _sentry;
  }

  /**
   * Gets EA's trade instance.
   */
  Trade *GetTrade(string _symbol) { return trade.GetByKey(_symbol); }

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
    for (DictStructIterator<int64, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
      Strategy *_strat = iter.Value().Ptr();
      _strat PTR_DEREF Set<T>(_param, _value);
    }
  }

  /**
   * Sets a trade parameter value for all trade instances.
   */
  template <typename T>
  void Set(ENUM_TRADE_PARAM _param, T _value) {
    for (DictObjectIterator<string, Ref<Trade>> iter = trade.Begin(); iter.IsValid(); ++iter) {
      Trade *_trade = iter.Value();
      _trade PTR_DEREF Set<T>(_param, _value);
    }
    for (DictStructIterator<int64, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
      Strategy *_strat = iter.Value().Ptr();
      _strat PTR_DEREF Set<T>(_param, _value);
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
      if (_signal PTR_DEREF Get(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_PROCESSED))) {
        // Ignores already processed signals.
        continue;
      }
      Trade *_trade = trade.GetByKey(_Symbol).Ptr();
      Strategy *_strat =
          strats.GetByKey(_signal PTR_DEREF Get<int64>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_MAGIC_ID))).Ptr();
      _trade_allowed &= _trade.IsTradeAllowed();
      if (_trade PTR_DEREF Get<bool>(TRADE_STATE_ORDERS_ACTIVE)) {
        float _sig_close = _signal PTR_DEREF GetSignalClose();
        string _comment_close =
            _strat != NULL && _sig_close != 0.0f ? _strat PTR_DEREF GetOrderCloseComment() : __FUNCTION_LINE__;
        // Check if we should close the orders.
        // _trade_allowed &= _strat PTR_DEREF GetTrade().IsTradeAllowed(_sig_close != 0.0f);
        if (_sig_close != 0.0f && _trade_allowed) {
          if (_sig_close >= 0.5f) {
            // Close signal for buy order.
            _trade PTR_DEREF OrdersCloseViaProp2<ENUM_ORDER_PROPERTY_INTEGER, int64>(
                ORDER_MAGIC, _signal PTR_DEREF Get<int64>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_MAGIC_ID)), ORDER_TYPE,
                ORDER_TYPE_BUY, MATH_COND_EQ, ORDER_REASON_CLOSED_BY_SIGNAL, _comment_close);
            // Buy orders closed.
            _strat PTR_DEREF OnOrderClose(ORDER_TYPE_BUY);
          }
          if (_sig_close <= -0.5f) {
            // Close signal for sell order.
            _trade PTR_DEREF OrdersCloseViaProp2<ENUM_ORDER_PROPERTY_INTEGER, int64>(
                ORDER_MAGIC, _signal PTR_DEREF Get<int64>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_MAGIC_ID)), ORDER_TYPE,
                ORDER_TYPE_SELL, MATH_COND_EQ, ORDER_REASON_CLOSED_BY_SIGNAL, _comment_close);
            // Sell orders closed.
            _strat PTR_DEREF OnOrderClose(ORDER_TYPE_SELL);
          }
        }
      }
      _trade_allowed &= !_strat PTR_DEREF IsSuspended();
      if (_trade_allowed) {
        float _sig_open = _signal PTR_DEREF GetSignalOpen();
        unsigned int _sig_f = eparams.Get<unsigned int>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_SIGNAL_FILTER));
        string _comment_open = _strat != NULL && _sig_open != 0.0f ? _strat PTR_DEREF GetOrderOpenComment() : __FUNCTION_LINE__;
        // Open orders on signals.
        // _trade_allowed &= _strat PTR_DEREF GetTrade() PTR_DEREF IsTradeAllowed(_sig_open != 0.0f);
        if (_sig_open != 0.0f && _trade_allowed) {
          if (_sig_open >= 0.5f) {
            // Open signal for buy.
            // When H1 or H4 signal filter is enabled, do not open minute-based orders on opposite or neutral signals.
            if (GetSignalOpenFiltered(_signal, _sig_f) >= 0.5f) {
              _strat PTR_DEREF Set(TRADE_PARAM_ORDER_COMMENT, _comment_open);
              // Buy order open.
              _result_local &= TradeRequest(ORDER_TYPE_BUY, _Symbol, _strat);
              if (_result_local && eparams.CheckSignalFilter(STRUCT_ENUM(EAParams, EA_PARAM_SIGNAL_FILTER_FIRST))) {
                _signal PTR_DEREF Set(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_PROCESSED), true);
                break;
              }
            } else {
              // Signal filtered.
            }
          }
          if (_sig_open <= -0.5f) {
            // Open signal for sell.
            // When H1 or H4 signal filter is enabled, do not open minute-based orders on opposite or neutral signals.
            if (GetSignalOpenFiltered(_signal, _sig_f) <= -0.5f) {
              _strat PTR_DEREF Set(TRADE_PARAM_ORDER_COMMENT, _comment_open);
              // Sell order open.
              _result_local &= TradeRequest(ORDER_TYPE_SELL, _Symbol, _strat);
              if (_result_local && eparams.CheckSignalFilter(STRUCT_ENUM(EAParams, EA_PARAM_SIGNAL_FILTER_FIRST))) {
                _signal PTR_DEREF Set(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_PROCESSED), true);
                break;
              }
            } else {
              // Signal filtered.
            }
          }
        }
        if (_result_local) {
          _signal PTR_DEREF Set(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_PROCESSED), true);
        } else {
          _last_error = GetLastError();
          if (_last_error > 0) {
            logger.Warning(StringFormat("Error: %d", _last_error), __FUNCTION_LINE__, _strat PTR_DEREF GetName());
#ifdef __debug_ea__
            Print(__FUNCTION_LINE__ + "(): " + SerializerConverter::FromObject(_signal).ToString<SerializerJson>());
#endif
            ResetLastError();
          }
          if (_trade PTR_DEREF Get<bool>(TRADE_STATE_MONEY_NOT_ENOUGH)) {
            logger.Warning(StringFormat("Suspending strategy.", _last_error), __FUNCTION_LINE__,
                           _strat PTR_DEREF GetName());
            _strat PTR_DEREF Suspended(true);
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
    Trade *_trade = trade.GetByKey(_symbol).Ptr();
    // Prepare a request.
    MqlTradeRequest _request = _trade PTR_DEREF GetTradeOpenRequest(_cmd);
    _request.comment = _strat PTR_DEREF GetOrderOpenComment();
    _request.magic = _strat PTR_DEREF Get<int64>(STRAT_PARAM_ID);
    _request.price = SymbolInfoStatic::GetOpenOffer(_symbol, _cmd);
    _request.volume = fmax(_strat PTR_DEREF Get<float>(STRAT_PARAM_LS), SymbolInfoStatic::GetVolumeMin(_symbol));

    // @fixit Uncomment
    // _request.volume = _trade PTR_DEREF NormalizeLots(_request.volume);

    // Check strategy's trade states.
    switch (_request.action) {
      case TRADE_ACTION_DEAL:
        if (!_trade.IsTradeRecommended()) {
          if (logger.GetLevel() > V_INFO) {
            logger.Debug(
                StringFormat("Trade not opened due to EA trading states (%d).", _trade.GetStates().GetStates()),
                __FUNCTION_LINE__);
          }
          return _result;
        }
        break;
    }
    // Prepare an order parameters.
    OrderParams _oparams;
    _strat PTR_DEREF OnOrderOpen(_oparams);
    // Send the request.
    _result = _trade PTR_DEREF RequestSend(_request, _oparams);
    if (!_result) {  //  && _strade.IsTradeRecommended(
      logger.Debug(
          StringFormat("Error while sending a trade request! Entry: %s",
                       SerializerConverter::FromObject(MqlTradeRequestProxy(_request)).ToString<SerializerJson>()),
          __FUNCTION_LINE__, StringFormat("Code: %d, Msg: %s", _LastError, Terminal::GetErrorText(_LastError)));
      if (_trade.IsTradeRecommended()) {
        logger.Debug(
            StringFormat("Error while sending a trade request! Entry: %s",
                         SerializerConverter::FromObject(MqlTradeRequestProxy(_request)).ToString<SerializerJson>()),
            __FUNCTION_LINE__, StringFormat("Code: %d, Msg: %s", _LastError, Terminal::GetErrorText(_LastError)));
      }
#ifdef __debug_ea__
      Print(__FUNCTION_LINE__ +
            "(): " + SerializerConverter::FromObject(MqlTradeRequestProxy(_request)).ToString<SerializerJson>());
#endif
    }
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
        for (DictStructIterator<int64, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
          bool _can_trade = true;
          Strategy *_strat = iter.Value().Ptr();
          Trade *_trade = trade.GetByKey(_Symbol).Ptr();
          if (_strat PTR_DEREF IsEnabled()) {
            if (estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)) >= DATETIME_MINUTE) {
              // Process when new periods started.
              _strat PTR_DEREF OnPeriod(estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)));
              _strat PTR_DEREF ProcessTasks();
              _trade PTR_DEREF OnPeriod(estate.Get<unsigned int>(STRUCT_ENUM(EAState, EA_STATE_PROP_NEW_PERIODS)));
              eresults.stg_processed_periods++;
            }
            if (_strat PTR_DEREF TickFilter(_tick)) {
              _can_trade &= !_trade PTR_DEREF HasState(TRADE_STATE_MODE_DISABLED);
              _can_trade &= !_strat PTR_DEREF IsSuspended();
              TradeSignalEntry _sentry = GetStrategySignalEntry(_strat, _can_trade, _strat PTR_DEREF Get<int>(STRAT_PARAM_SHIFT));
              if (_sentry.Get<unsigned int>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_SIGNALS)) > 0) {
                TradeSignal _signal(_sentry);
                if (_signal.GetSignalClose() != _signal.GetSignalOpen()) {
                  tsm.SignalAdd(_signal);  //, _tick.time);
                }
                StgProcessResult _strat_result = _strat PTR_DEREF GetProcessResult();
                eresults.last_error = fmax(eresults.last_error, _strat_result.last_error);
                eresults.stg_errored += (int)_strat_result.last_error > ERR_NO_ERROR;
                eresults.stg_processed++;
              }
            }
          }
        }
        if (tsm.GetSignalsActive() PTR_DEREF Size() > 0 && tsm.IsReady()) {
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
    int64 _timestamp = estate.last_updated.GetEntry().GetTimestamp();
    if (eparams.CheckFlagDataStore(EA_DATA_STORE_CHART)) {
      ChartEntry _entry = Chart().GetEntry();
      data_chart.Add(_entry, _entry.bar.ohlc.time);
    }
    /* @fixme
    if (eparams.CheckFlagDataStore(EA_DATA_STORE_INDICATOR)) {
      for (DictStructIterator<int64, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
        Strategy *_strati = iter.Value().Ptr();
        IndicatorData *_indi = _strati PTR_DEREF GetIndicator();
        if (_indi != NULL) {
          ENUM_TIMEFRAMES _itf = _indi PTR_DEREF GetTf();
          IndicatorDataEntry _ientry = _indi PTR_DEREF GetEntry();
          if (!data_indi.KeyExists(_itf)) {
            // Create new timeframe buffer if does not exist.
            BufferStruct<IndicatorDataEntry> *_ide = new BufferStruct<IndicatorDataEntry>;
            data_indi.Set(_itf, PTR_TO_REF(_ide));
          }
          // Save entry into data_indi.
          data_indi[_itf] PTR_DEREF Add(_ientry);
        }
      }
    }
    */
    /*
    if (eparams.CheckFlagDataStore(EA_DATA_STORE_STRATEGY)) {
      for (DictStructIterator<int64, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
        Strategy *_strat = iter.Value().Ptr();
        StgEntry _sentry = _strat PTR_DEREF GetEntry();
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
    int64 _timestamp = estate.last_updated.GetEntry().GetTimestamp();
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

      /* @todo
      for (DictStructIterator<int64, Ref<Strategy>> _iter = GetStrategies() PTR_DEREF Begin(); _iter.IsValid(); ++_iter)
      { int _sid = (int)_iter.Key(); Strategy *_strat = _iter.Value().Ptr();
        // ENUM_TIMEFRAMES _itf = iter_tf.Key(); // @fixme
        if (data_indi.KeyExists(_itf)) {
          BufferStruct<IndicatorDataEntry> _indi_buff = data_indi.GetByKey(_itf);

          SerializerConverter _obj = SerializerConverter::FromObject(_indi_buff, _serializer_flags);

          for (DictStructIterator<int64, Ref<Strategy>> iter = strats[_itf].Begin(); iter.IsValid(); ++iter) {
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

      for (DictStructIterator<int64, Ref<Strategy>> _iter = GetStrategies() PTR_DEREF Begin(); _iter.IsValid();
           ++_iter) {
        int _sid = (int)_iter.Key();
        Strategy *_strat = _iter.Value().Ptr();
        if (data_stg.KeyExists(_sid)) {
          string _key_stg = StringFormat("Strategy-%d", _sid);
          BufferStruct<StgEntry> _stg_buff = data_stg.GetByKey(_sid);
          SerializerConverter _obj = SerializerConverter::FromObject(_stg_buff, _serializer_flags);

          _key_stg += StringFormat("-%d-%d-%d", _sid, _stg_buff.GetMin(), _stg_buff.GetMax());
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
      // _key_sym += StringFormat("-%d-%d", data_trade PTR_DEREF GetMin(), data_trade PTR_DEREF GetMax());
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
   *   Returns positive for buy signal, negative for sell, otherwise 0 for neutral signal.
   */
  float GetSignalOpenFiltered(TradeSignal &_signal, unsigned int _sf) {
    bool _res_sig = false;
    float _sig_open = _signal.GetSignalOpen();
    ENUM_TIMEFRAMES _sig_tf = _signal.Get<ENUM_TIMEFRAMES>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_TF));
    if (ChartTf::TfToHours(_sig_tf) < 1 && bool(_sf & STRUCT_ENUM(EAParams, EA_PARAM_SIGNAL_FILTER_OPEN_M_IF_H))) {
      for (DictStructIterator<int64, Ref<Strategy>> _iter = GetStrategies().Begin(); _iter.IsValid(); ++_iter) {
        Strategy *_strat = _iter.Value().Ptr();
        ENUM_TIMEFRAMES _stf = _strat PTR_DEREF Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF);
        if (ChartTf::TfToHours(_stf) >= 1) {
          TradeSignal *_hsignal0 =
              tsm.GetSignalByCid(_strat PTR_DEREF Get<int>(STRAT_PARAM_ID), (int)_stf, (int)ChartStatic::iTime(_Symbol, _stf));
          TradeSignal *_hsignal1 =
              tsm.GetSignalByCid(_strat PTR_DEREF Get<int>(STRAT_PARAM_ID), (int)_stf, (int)ChartStatic::iTime(_Symbol, _stf, 1));
          TradeSignal *_hsignal2 =
              tsm.GetSignalByCid(_strat PTR_DEREF Get<int>(STRAT_PARAM_ID), (int)_stf, (int)ChartStatic::iTime(_Symbol, _stf, 2));
          // Increase signal if confirmed by hourly signal.
          if (_hsignal0 != NULL && _hsignal0.Get<int64>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_TIME)) > 0) {
            _sig_open += ((_sig_open > 0) == (_hsignal0.GetSignalOpen() > 0)) ? 1.0f : -1.0f;
            _sig_open -= ((_sig_open < 0) == (_hsignal0.GetSignalOpen() < 0)) ? 1.0f : -1.0f;
          } else if (_hsignal1 != NULL &&
                     _hsignal1.Get<int64>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_TIME)) > 0) {
            _sig_open += ((_sig_open > 0) == (_hsignal1.GetSignalOpen() > 0)) ? 0.5f : -0.5f;
            _sig_open -= ((_sig_open < 0) == (_hsignal1.GetSignalOpen() < 0)) ? 0.5f : -0.5f;
          } else if (_hsignal2 != NULL &&
                     _hsignal2.Get<int64>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_TIME)) > 0) {
            _sig_open += ((_sig_open > 0) == (_hsignal2.GetSignalOpen() > 0)) ? 0.2f : -0.2f;
            _sig_open -= ((_sig_open < 0) == (_hsignal2.GetSignalOpen() < 0)) ? 0.2f : -0.2f;
          } else {
            // Decrease signal by 0.1 if no hourly signal is found.
            _sig_open -= 0.1f;
          }
        }
      }
    }
    return _sig_open;
  }

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
  bool StrategyAdd(ENUM_TIMEFRAMES _tf, int64 _magic_no = 0, int _type = 0) {
    bool _result = true;
    _magic_no = _magic_no > 0 ? _magic_no : rand();
    Ref<Strategy> _strat = ((SClass *)NULL).Init(_tf, THIS_PTR);
    _strat PTR_DEREF Ptr().Set<int64>(STRAT_PARAM_ID, _magic_no);
    _strat PTR_DEREF Ptr().Set<int64>(TRADE_PARAM_MAGIC_NO, _magic_no);
    _strat PTR_DEREF Ptr().Set<int>(STRAT_PARAM_LOG_LEVEL,
                          (ENUM_LOG_LEVEL)eparams.Get<int>(STRUCT_ENUM(EAParams, EA_PARAM_PROP_LOG_LEVEL)));
    _strat PTR_DEREF Ptr().Set<ENUM_TIMEFRAMES>(STRAT_PARAM_TF, _tf);
    _strat PTR_DEREF Ptr().Set<int>(STRAT_PARAM_TYPE, _type);
    _strat PTR_DEREF Ptr().OnInit();
    if (!strats.KeyExists(_magic_no)) {
      _result &= strats.Set(_magic_no, _strat);
    } else {
      logger.Error("Strategy adding conflict!", __FUNCTION_LINE__);
      DebugBreak();
    }
    OnStrategyAdd(_strat PTR_DEREF Ptr());
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
  bool StrategyAdd(unsigned int _tfs, int64 _init_magic = 0, int _type = 0) {
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
    bool _result = true;
    Trade *_trade = trade.GetByKey(_Symbol).Ptr();
    // Load active trades.
    _result &= _trade.OrdersLoadByMagic(_strat PTR_DEREF Get<int64>(STRAT_PARAM_ID));
    // Load strategy-specific order parameters (e.g. conditions).
    // This is a temporary workaround for GH-705.
    // @todo: To move to Strategy class.
    Ref<Order> _order;
    for (DictStructIterator<int64, Ref<Order>> iter = _trade.GetOrdersActive().Begin(); iter.IsValid(); ++iter) {
      _order = iter.Value();
      if (_order.IsSet() && _order.Ptr().IsOpen()) {
        _strat PTR_DEREF OnOrderLoad(_order.Ptr());
      }
    }
    return _result;
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
    for (DictStructIterator<string, Ref<Trade>> titer = trade.Begin(); titer.IsValid(); ++titer) {
      Trade *_trade = titer.Value().Ptr();
      if (_trade.Get<bool>(TRADE_STATE_ORDERS_ACTIVE) && !_trade.Get<bool>(TRADE_STATE_MARKET_CLOSED)) {
        for (DictStructIterator<int64, Ref<Order>> oiter = _trade.GetOrdersActive().Begin(); oiter.IsValid(); ++oiter) {
          bool _sl_valid = false, _tp_valid = false;
          double _sl_new = 0, _tp_new = 0;
          Order *_order = oiter.Value().Ptr();
          if (!_order PTR_DEREF ShouldUpdate()) {
            continue;
          }
          _order PTR_DEREF ProcessConditions();
          if (_order PTR_DEREF IsClosed()) {
            _trade PTR_DEREF OrderMoveToHistory(_order);
            continue;
          }
          ENUM_ORDER_TYPE _otype = _order PTR_DEREF Get<ENUM_ORDER_TYPE>(ORDER_TYPE);
          Strategy *_strat = strats.GetByKey(_order PTR_DEREF Get<uint64>(ORDER_MAGIC)).Ptr();
          Strategy *_strat_sl = _strat PTR_DEREF GetStratSl();
          Strategy *_strat_tp = _strat PTR_DEREF GetStratTp();
          if (_strat_sl != NULL || _strat_tp != NULL) {
            float _olots = _order PTR_DEREF Get<float>(ORDER_VOLUME_CURRENT);
            float _trisk = _trade PTR_DEREF Get<float>(TRADE_PARAM_RISK_MARGIN);
            if (_strat_sl != NULL) {
              float _psl = _strat_sl PTR_DEREF Get<float>(STRAT_PARAM_PSL);
              float _sl_max = _trade PTR_DEREF GetMaxSLTP(_otype, _olots, ORDER_TYPE_SL, _trisk);
              int _psm = _strat_sl PTR_DEREF Get<int>(STRAT_PARAM_PSM);
              _sl_new = _strat_sl PTR_DEREF PriceStop(_otype, ORDER_TYPE_SL, _psm, _psl);
              _sl_new = _trade PTR_DEREF GetSaferSLTP(_sl_new, _sl_max, _otype, ORDER_TYPE_SL);
              _sl_new = _trade PTR_DEREF NormalizeSL(_sl_new, _otype);
              _sl_valid =
                  _trade PTR_DEREF IsValidOrderSL(_sl_new, _otype, _order PTR_DEREF Get<double>(ORDER_SL), _psm > 0);
              _sl_new = _sl_valid ? _sl_new : _order PTR_DEREF Get<double>(ORDER_SL);
            }
            if (_strat_tp != NULL) {
              float _ppl = _strat_tp PTR_DEREF Get<float>(STRAT_PARAM_PPL);
              float _tp_max = _trade PTR_DEREF GetMaxSLTP(_otype, _olots, ORDER_TYPE_TP, _trisk);
              int _ppm = _strat_tp PTR_DEREF Get<int>(STRAT_PARAM_PPM);
              _tp_new = _strat_tp PTR_DEREF PriceStop(_otype, ORDER_TYPE_TP, _ppm, _ppl);
              _tp_new = _trade PTR_DEREF GetSaferSLTP(_tp_new, _tp_max, _otype, ORDER_TYPE_TP);
              _tp_new = _trade PTR_DEREF NormalizeTP(_tp_new, _otype);
              _tp_valid =
                  _trade PTR_DEREF IsValidOrderTP(_tp_new, _otype, _order PTR_DEREF Get<double>(ORDER_TP), _ppm > 0);
              _tp_new = _tp_valid ? _tp_new : _order PTR_DEREF Get<double>(ORDER_TP);
            }
          }
          if (_sl_valid || _tp_valid) {
            _result &= _order PTR_DEREF OrderModify(_sl_new, _tp_new);
            if (_result) {
              _order PTR_DEREF Set(ORDER_PROP_TIME_LAST_UPDATE, TimeCurrent());
            } else {
              _trade.UpdateStates(true);
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
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_CONNECTED), GetTerminal() PTR_DEREF IsConnected());
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_LIBS_ALLOWED), GetTerminal() PTR_DEREF IsLibrariesAllowed());
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_OPTIMIZATION), GetTerminal() PTR_DEREF IsOptimization());
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_TESTING), GetTerminal() PTR_DEREF IsTesting());
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_TRADE_ALLOWED), GetTerminal() PTR_DEREF IsTradeAllowed());
    estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_VISUAL_MODE), GetTerminal() PTR_DEREF IsVisualMode());
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
      Trade *_trade = trade.GetByKey(_Symbol).Ptr();
      _result &= _trade PTR_DEREF Run(TRADE_ACTION_CALC_LOT_SIZE);
      Set(STRAT_PARAM_LS, _trade PTR_DEREF Get<float>(TRADE_PARAM_LOT_SIZE));
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
      tasks.Add(new TaskObject<EA, EA>(_tentry, THIS_PTR, THIS_PTR));
    }
    return _is_valid;
  }

  /**
   * Add task object.
   */
  template <typename TA, typename TC>
  bool AddTaskObject(TaskObject<TA, TC> *_tobj) {
    return EA::tasks.Add<TA, TC>(_tobj);
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
        estate.Set(STRUCT_ENUM(EAState, EA_STATE_FLAG_CONNECTED), GetTerminal() PTR_DEREF IsConnected());
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
        GetLogger() PTR_DEREF Error(StringFormat("Invalid EA condition: %d!", _entry.GetId(), __FUNCTION_LINE__));
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
        break;
      case EA_ACTION_ENABLE:
        estate.Enable();
        break;
      case EA_ACTION_EXPORT_DATA:
        DataExport();
        break;
      case EA_ACTION_STRATS_EXE_ACTION: {
        // Args:
        // 1st (i:0) - Strategy's enum action to execute.
        // 2nd (i:1) - Strategy's argument to pass.
        TaskActionEntry _entry_strat = _entry;
        _entry_strat PTR_DEREF ArgRemove(0);
        for (DictStructIterator<int64, Ref<Strategy>> iter_strat = strats.Begin(); iter_strat PTR_DEREF IsValid(); ++iter_strat) {
          Strategy *_strat = iter_strat PTR_DEREF Value().Ptr();

          _result &= _strat PTR_DEREF Run(_entry_strat);
        }
        break;
      }
      case EA_ACTION_TASKS_CLEAN:
        tasks.GetTasks().Clear();
        return tasks.GetTasks().Size() == 0;
      default:
        GetLogger() PTR_DEREF Error(StringFormat("Invalid EA action: %d!", _entry.GetId(), __FUNCTION_LINE__));
        SetUserError(ERR_INVALID_PARAMETER);
        _result = false;
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
    for (DictStructIterator<int64, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
      Strategy *_strat = iter.Value().Ptr();
      if (Math::Compare(_strat PTR_DEREF Get<T>(_prop), _value, _op)) {
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
    for (DictStructIterator<int64, Ref<Strategy>> iter = strats.Begin(); iter.IsValid(); ++iter) {
      Strategy *_strat = iter.Value().Ptr();
      if (Math::Compare(_strat PTR_DEREF Get<T1>(_prop1), _value1, _op) &&
          Math::Compare(_strat PTR_DEREF Get<T2>(_prop2), _value2, _op)) {
        return _strat;
      }
    }
    return NULL;
  }

  /**
   * Returns pointer to Market object.
   */
  Terminal *GetTerminal() { return GET_PTR(terminal); }

  /**
   * Gets EA's name.
   */
  EAParams GetParams() const { return eparams; }

  /**
   * Gets DictStruct reference to strategies.
   */
  DictStruct<int64, Ref<Strategy>> *GetStrategies() { return GET_PTR(strats); }

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
  Log *GetLogger() { return GET_PTR(logger); }

  /**
   * Gets reference to strategies.
   */
  DictStruct<int64, Ref<Strategy>> *Strategies() { return &strats; }

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
    _strat PTR_DEREF Set<float>(TRADE_PARAM_RISK_MARGIN, _margin_risk);
    // Link a logger instance.
    logger.Link(_strat PTR_DEREF GetLogger());
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
    _s.PassObject(THIS_REF, "account", PTR_TO_REF(account), SERIALIZER_FIELD_FLAG_DYNAMIC);

    for (DictStructIterator<int64, Ref<Strategy>> _iter = GetStrategies() PTR_DEREF Begin(); _iter.IsValid(); ++_iter) {
      Strategy *_strat = _iter.Value().Ptr();
      // @fixme: GH-422
      // _s.PassWriteOnly(this, "strat:" + _strat PTR_DEREF GetName(), _strat);
      string _sname = _strat PTR_DEREF GetName();  // + "@" + Chart::TfToString(_strat PTR_DEREF GetTf()); // @todo
      string _sparams = _strat PTR_DEREF GetParams().ToString();
      string _sresults = _strat PTR_DEREF GetProcessResult().ToString();
      _s.Pass(THIS_REF, "strat:params:" + _sname, _sparams);
      _s.Pass(THIS_REF, "strat:results:" + _sname, _sresults);
    }
    _s.PassObject(THIS_REF, "trade", trade);
    _s.PassObject(THIS_REF, "tsm", tsm);
    return SerializerNodeObject;
  }
};

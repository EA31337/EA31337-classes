//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
 * Implements TradeSignalManager class.
 */

// Includes.
#include "../DictObject.mqh"
#include "TradeSignal.h"
#include "TradeSignalManager.struct.h"

/**
 * Class to store and manage a trading signal.
 */
class TradeSignalManager : Dynamic {
 protected:
  DictObject<int, TradeSignal> signals_active;
  DictObject<int, TradeSignal> signals_expired;
  DictObject<int, TradeSignal> signals_processed;
  TradeSignalManagerParams params;

  /**
   * Init code (called on constructor).
   */
  void Init() {
    signals_active.AddFlags(DICT_FLAG_FILL_HOLES_UNSORTED);
    signals_active.SetOverflowListener(SignalOverflowCallback, 10);
    signals_expired.AddFlags(DICT_FLAG_FILL_HOLES_UNSORTED);
    signals_expired.SetOverflowListener(SignalOverflowCallback, 10);
    signals_processed.AddFlags(DICT_FLAG_FILL_HOLES_UNSORTED);
    signals_processed.SetOverflowListener(SignalOverflowCallback, 10);
  }

 public:
  /**
   * Default class constructor.
   */
  TradeSignalManager() { Init(); }

  /**
   * Class constructor with parameters.
   */
  TradeSignalManager(TradeSignalManagerParams &_params) : params(_params) { Init(); }

  /* Getters */

  /**
   * Gets a property value.
   */
  template <typename T>
  T Get(STRUCT_ENUM(TradeSignalManagerParams, ENUM_TSM_PARAMS_PROP) _prop) {
    return params.Get<T>(_prop);
  }

  /**
   * Gets a signal struct based on cache ID value.
   *
   * @param
   *   _cid Cache ID.
   */
  TradeSignal *GetSignalByCid(int _cid) {
    unsigned int _pos = 0;
    if (signals_active.KeyExists(_cid, _pos)) {
      return signals_active.GetByPos(_pos);
    } else if (signals_processed.KeyExists(_cid, _pos)) {
      return signals_processed.GetByPos(_pos);
    }
    return NULL;
  }

  /**
   * Checks if signal exists based on provided values.
   *
   * @param
   *   _magic_no Magic Number.
   *   _tf Timeframe value.
   *   _timestamp Timestamp.
   */
  TradeSignal *GetSignalByCid(int _magic_no, int _tf, int _timestamp) {
    return GetSignalByCid(_magic_no + _tf + _timestamp);
  }

  /**
   * Gets a cache ID based on the signal.
   */
  int GetCid(TradeSignal &_signal) {
    return _signal.Get<int>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_MAGIC_ID)) +
           _signal.Get<int>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_TF)) +
           _signal.Get<int>(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_PROP_TIME));
  }

  /**
   * Gets an iterator instance.
   *
   */
  DictObjectIterator<int, TradeSignal> GetIterSignalsActive() {
    DictObjectIterator<int, TradeSignal> _iter = signals_active.Begin();
    return _iter;
  }

  /**
   * Gets pointer to active signals.
   *
   */
  DictObject<int, TradeSignal> *GetSignalsActive() { return &signals_active; }

  /**
   * Gets pointer to expired signals.
   *
   */
  DictObject<int, TradeSignal> *GetSignalsExpired() { return &signals_expired; }

  /**
   * Gets pointer to processed signals.
   *
   */
  DictObject<int, TradeSignal> *GetSignalsProcessed() { return &signals_processed; }

  /* Setters */

  /**
   * Sets a property value.
   */
  template <typename T>
  void Set(STRUCT_ENUM(TradeSignalManagerParams, ENUM_TSM_PARAMS_PROP) _prop, T _value) {
    params.Set<T>(_prop, _value);
  }

  /* Signal methods */

  /**
   * Adds new signal.
   *
   */
  void SignalAdd(TradeSignal &_signal) { signals_active.Set(GetCid(_signal), _signal); }

  /**
   * Refresh signals.
   *
   * Move already processed signals or expired to different list.
   *
   */
  void Refresh() {
    for (DictObjectIterator<int, TradeSignal> iter = GetIterSignalsActive(); iter.IsValid(); ++iter) {
      TradeSignal *_signal = iter.Value();
      if (_signal PTR_DEREF Get(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_PROCESSED))) {
        signals_active.Unset(iter);
        signals_processed.Set(GetCid(PTR_TO_REF(_signal)), PTR_TO_REF(_signal));
        continue;
      }
      if (_signal PTR_DEREF Get(STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_EXPIRED))) {
        signals_active.Unset(iter);
        signals_expired.Set(GetCid(PTR_TO_REF(_signal)), PTR_TO_REF(_signal));
        continue;
      }
    }
    Set<long>(TSM_PROP_LAST_CHECK, ::TimeGMT());
  }

  /* State methods */

  /**
   * Checks if signal manager is ready for signal processing based on the frequency param.
   *
   * @param
   *   _update Update last check timestamp when true.
   */
  bool IsReady(bool _update = true) {
    bool _res = Get<long>(TSM_PROP_LAST_CHECK) <= ::TimeGMT() - Get<short>(TSM_PROP_FREQ);
    if (_res) {
      Set<long>(TSM_PROP_LAST_CHECK, ::TimeGMT());
    }
    return _res;
  }

  /* Callback methods */

  /**
   * Function should return true if resize can be made, or false to overwrite current slot.
   */
  static bool SignalOverflowCallback(ENUM_DICT_OVERFLOW_REASON _reason, int _size, int _num_conflicts) {
    static int cache_limit = 1000;
    switch (_reason) {
      case DICT_OVERFLOW_REASON_FULL:
        // We allow resize if dictionary size is less than 86400 slots.
        return _size < cache_limit;
      case DICT_OVERFLOW_REASON_TOO_MANY_CONFLICTS:
      default:
        // When there is too many conflicts, we just reject doing resize, so first conflicting slot will be reused.
        break;
    }
    return false;
  }

  /* Serializers */

  SERIALIZER_EMPTY_STUB;

  /**
   * Serializes this class.
   *
   * @return
   *   Returns a JSON serialized instance.
   */
  SerializerNodeType Serialize(Serializer &_s) {
    _s.PassObject(THIS_REF, "signals_active", signals_active);
    return SerializerNodeObject;
  }

  /**
   * Converts this class into a string.
   *
   * @return
   *   Returns a JSON serialized signal.
   */
  string ToString() {
    // SerializerConverter _stub = SerializerConverter::MakeStubObject<TradeSignalManager>(SERIALIZER_FLAG_SKIP_HIDDEN);
    return SerializerConverter::FromObject(THIS_REF, SERIALIZER_FLAG_INCLUDE_ALL | SERIALIZER_FLAG_SKIP_HIDDEN)
        .ToString<SerializerJson>(SERIALIZER_JSON_NO_WHITESPACES);
  }
};

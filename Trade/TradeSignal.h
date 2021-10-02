//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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

// Includes.
#include "TradeSignal.struct.h"

/**
 * @file
 * Implements TradeSignal class.
 */

/**
 * Class to store and manage a trading signal.
 */
class TradeSignal {
 protected:
  TradeSignalEntry signal;

 public:
  /**
   * Class constructor.
   */
  TradeSignal() {}
  TradeSignal(const TradeSignalEntry &_entry) : signal(_entry) {}
  TradeSignal(const TradeSignal &_signal) : signal(_signal.GetSignal()) {}

  /* Getters */

  /**
   * Gets a signal flag state.
   */
  bool Get(STRUCT_ENUM(TradeSignalEntry, ENUM_TRADE_SIGNAL_FLAG) _flag) { return signal.Get(_flag); }

  /**
   * Gets a signal property.
   */
  template <typename TV>
  TV Get(STRUCT_ENUM(TradeSignalEntry, ENUM_TRADE_SIGNAL_PROP) _prop) {
    return signal.Get<TV>(_prop);
  }

  /**
   * Gets a signal entry.
   */
  TradeSignalEntry GetSignal() const { return signal; }

  /* Setters */

  /**
   * Sets a signal flag state.
   */
  void Set(STRUCT_ENUM(TradeSignalEntry, ENUM_TRADE_SIGNAL_FLAG) _prop, bool _value) { signal.Set(_prop, _value); }

  /**
   * Sets a signal property.
   */
  template <typename TV>
  void Set(STRUCT_ENUM(TradeSignalEntry, ENUM_TRADE_SIGNAL_PROP) _prop, TV _value) {
    signal.Set<TV>(_prop, _value);
  }

  /* Signal methods */

  /**
   * Check for signal to close a trade.
   */
  bool ShouldClose(ENUM_ORDER_TYPE _cmd) {
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        return signal.CheckSignalsEqual(SIGNAL_CLOSE_BUY_SIGNAL, SIGNAL_CLOSE_BUY_MAIN);
      case ORDER_TYPE_SELL:
        return signal.CheckSignalsEqual(SIGNAL_CLOSE_SELL_SIGNAL, SIGNAL_CLOSE_SELL_MAIN);
      default:
        break;
    }
    return false;
  }

  /**
   * Check for signal to open a trade.
   */
  bool ShouldOpen(ENUM_ORDER_TYPE _cmd) {
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        return signal.CheckSignalsEqual(SIGNAL_OPEN_BUY_SIGNAL, SIGNAL_OPEN_BUY_MAIN);
      case ORDER_TYPE_SELL:
        return signal.CheckSignalsEqual(SIGNAL_OPEN_SELL_SIGNAL, SIGNAL_OPEN_SELL_MAIN);
      default:
        break;
    }
    return false;
  }

  /**
   * Gets signal's strength to close.
   *
   * @return
   *   Returns strength of signal to close between -1 and 1.
   *   Returns 0 on a neutral signal or when signals are in conflict.
   */
  float GetSignalClose() { return float(int(ShouldClose(ORDER_TYPE_BUY)) - int(ShouldClose(ORDER_TYPE_SELL))); }

  /**
   * Gets signal's close direction.
   *
   * @return
   *   Returns +1 for upwards, -1 for downwards, or 0 for a neutral direction.
   */
  char GetSignalCloseDirection() {
    if (signal.CheckSignals(SIGNAL_CLOSE_UPWARDS)) {
      return 1;
    } else if (signal.CheckSignals(SIGNAL_CLOSE_DOWNWARDS)) {
      return -1;
    }
    return 0;
  }

  /**
   * Gets signal's strength to open.
   *
   * @return
   *   Returns strength of signal to close between -1 and 1.
   *   Returns 0 on a neutral signal or when signals are in conflict.
   */
  float GetSignalOpen() { return float(int(ShouldOpen(ORDER_TYPE_BUY)) - int(ShouldOpen(ORDER_TYPE_SELL))); }

  /**
   * Gets signal's open direction.
   *
   * @return
   *   Returns +1 for upwards, -1 for downwards, or 0 for a neutral direction.
   */
  char GetSignalOpenDirection() {
    if (signal.CheckSignals(SIGNAL_OPEN_UPWARDS)) {
      return 1;
    } else if (signal.CheckSignals(SIGNAL_OPEN_DOWNWARDS)) {
      return -1;
    }
    return 0;
  }

  /* Serializers */

  /**
   * Serializes this class.
   *
   * @return
   *   Returns a JSON serialized instance.
   */
  SerializerNodeType Serialize(Serializer &_s) {
    _s.PassStruct(THIS_REF, "signal", signal);
    return SerializerNodeObject;
  }

  /**
   * Converts this class into a string.
   *
   * @return
   *   Returns a JSON serialized signal.
   */
  string ToString() { return signal.ToString(); }
};

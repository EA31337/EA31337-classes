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

/**
 * @file
 * Includes TradeSignal's structs.
 */

// Includes.
#include "../Chart.enum.h"
#include "../Serializer/SerializerConverter.h"
#include "../Serializer/SerializerJson.h"

// Defines.
#define SIGNAL_CLOSE_BUY_FILTER STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_CLOSE_BUY_FILTER)
#define SIGNAL_CLOSE_BUY_MAIN STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_CLOSE_BUY_MAIN)
#define SIGNAL_CLOSE_BUY_SIGNAL STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_CLOSE_BUY_SIGNAL)
#define SIGNAL_CLOSE_DOWNWARDS STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_CLOSE_DOWNWARDS)
#define SIGNAL_CLOSE_SELL_FILTER STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_CLOSE_SELL_FILTER)
#define SIGNAL_CLOSE_SELL_MAIN STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_CLOSE_SELL_MAIN)
#define SIGNAL_CLOSE_SELL_SIGNAL STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_CLOSE_SELL_SIGNAL)
#define SIGNAL_CLOSE_TIME_FILTER STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER)
#define SIGNAL_CLOSE_UPWARDS STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_CLOSE_UPWARDS)
#define SIGNAL_OPEN_BUY_FILTER STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_OPEN_BUY_FILTER)
#define SIGNAL_OPEN_BUY_MAIN STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_OPEN_BUY_MAIN)
#define SIGNAL_OPEN_BUY_SIGNAL STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_OPEN_BUY_SIGNAL)
#define SIGNAL_OPEN_DOWNWARDS STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_OPEN_DOWNWARDS)
#define SIGNAL_OPEN_SELL_FILTER STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_OPEN_SELL_FILTER)
#define SIGNAL_OPEN_SELL_MAIN STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_OPEN_SELL_MAIN)
#define SIGNAL_OPEN_SELL_SIGNAL STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_OPEN_SELL_SIGNAL)
#define SIGNAL_OPEN_TIME_FILTER STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER)
#define SIGNAL_OPEN_UPWARDS STRUCT_ENUM(TradeSignalEntry, TRADE_SIGNAL_FLAG_OPEN_UPWARDS)

// Structure for a trade signal.
struct TradeSignalEntry {
 protected:
  long magic_id;         // Magic identifier.
  unsigned int signals;  // Store signals (@see: ENUM_TRADE_SIGNAL_FLAG).
  float strength;        // Signal strength.
  ENUM_TIMEFRAMES tf;    // Timeframe.
  long timestamp;        // Creation timestamp
  float weight;          // Signal weight.

 public:
  /* Struct's enumerations */

  // Enumeration for strategy bitwise signal flags.
  enum ENUM_TRADE_SIGNAL_FLAG {
    TRADE_SIGNAL_FLAG_NONE = 0 << 0,
    TRADE_SIGNAL_FLAG_CLOSE_BUY_FILTER = 1 << 0,   // Filter for close buy
    TRADE_SIGNAL_FLAG_CLOSE_BUY_MAIN = 1 << 1,     // Main signal for close buy
    TRADE_SIGNAL_FLAG_CLOSE_SELL_FILTER = 1 << 2,  // Filter for close sell
    TRADE_SIGNAL_FLAG_CLOSE_SELL_MAIN = 1 << 3,    // Main signal for close sell
    TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER = 1 << 4,  // Time filter to close
    TRADE_SIGNAL_FLAG_EXPIRED = 1 << 5,            // Signal expired
    TRADE_SIGNAL_FLAG_OPEN_BUY_FILTER = 1 << 6,    // Filter for close buy
    TRADE_SIGNAL_FLAG_OPEN_BUY_MAIN = 1 << 7,      // Main signal for close buy
    TRADE_SIGNAL_FLAG_OPEN_SELL_FILTER = 1 << 8,   // Filter for close sell
    TRADE_SIGNAL_FLAG_OPEN_SELL_MAIN = 1 << 9,     // Main signal for close sell
    TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER = 1 << 10,  // Time filter to open
    TRADE_SIGNAL_FLAG_PROCESSED = 1 << 11,         // Signal proceed
    // Pre-defined signal conditions.
    TRADE_SIGNAL_FLAG_CLOSE_BUY_SIGNAL =
        TRADE_SIGNAL_FLAG_CLOSE_BUY_MAIN ^ (TRADE_SIGNAL_FLAG_CLOSE_BUY_FILTER | TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER),
    TRADE_SIGNAL_FLAG_CLOSE_SELL_SIGNAL =
        TRADE_SIGNAL_FLAG_CLOSE_SELL_MAIN ^ (TRADE_SIGNAL_FLAG_CLOSE_SELL_FILTER | TRADE_SIGNAL_FLAG_CLOSE_TIME_FILTER),
    TRADE_SIGNAL_FLAG_OPEN_BUY_SIGNAL =
        TRADE_SIGNAL_FLAG_OPEN_BUY_MAIN ^ (TRADE_SIGNAL_FLAG_OPEN_BUY_FILTER | TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER),
    TRADE_SIGNAL_FLAG_OPEN_SELL_SIGNAL =
        TRADE_SIGNAL_FLAG_OPEN_SELL_MAIN ^ (TRADE_SIGNAL_FLAG_OPEN_SELL_FILTER | TRADE_SIGNAL_FLAG_OPEN_TIME_FILTER),
    // Pre-defined signal directions.
    TRADE_SIGNAL_FLAG_CLOSE_DOWNWARDS = TRADE_SIGNAL_FLAG_CLOSE_SELL_MAIN & ~TRADE_SIGNAL_FLAG_CLOSE_BUY_MAIN,
    TRADE_SIGNAL_FLAG_CLOSE_UPWARDS = TRADE_SIGNAL_FLAG_CLOSE_BUY_MAIN & ~TRADE_SIGNAL_FLAG_CLOSE_SELL_MAIN,
    TRADE_SIGNAL_FLAG_OPEN_DOWNWARDS = TRADE_SIGNAL_FLAG_OPEN_SELL_MAIN & ~TRADE_SIGNAL_FLAG_OPEN_BUY_MAIN,
    TRADE_SIGNAL_FLAG_OPEN_UPWARDS = TRADE_SIGNAL_FLAG_OPEN_BUY_MAIN & ~TRADE_SIGNAL_FLAG_OPEN_SELL_MAIN,
  };

  // Enumeration for strategy signal properties.
  enum ENUM_TRADE_SIGNAL_PROP {
    TRADE_SIGNAL_PROP_MAGIC_ID,
    TRADE_SIGNAL_PROP_SIGNALS,
    TRADE_SIGNAL_PROP_STRENGTH,
    TRADE_SIGNAL_PROP_TF,
    TRADE_SIGNAL_PROP_TIME,
    TRADE_SIGNAL_PROP_WEIGHT,
  };

  // Enumeration for strategy signal types.
  enum ENUM_TRADE_SIGNAL_OP {
    TRADE_SIGNAL_OP_SELL = -1,    // Signal to sell.
    TRADE_SIGNAL_OP_NEUTRAL = 0,  // Neutral signal.
    TRADE_SIGNAL_OP_BUY = 1,      // Signal to buy.
  };

  /* Constructor */
  TradeSignalEntry(unsigned int _signals = 0, ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, long _magic_id = 0,
                   float _strength = 0.0f, float _weight = 0.0f, long _time = 0)
      : magic_id(_magic_id), signals(_signals), strength(_strength), tf(_tf), timestamp(_time), weight(_weight) {}
  TradeSignalEntry(const TradeSignalEntry &_entry) { THIS_REF = _entry; }
  /* Getters */
  template <typename T>
  T Get(STRUCT_ENUM(TradeSignalEntry, ENUM_TRADE_SIGNAL_PROP) _prop) {
    switch (_prop) {
      case TRADE_SIGNAL_PROP_MAGIC_ID:
        return (T)magic_id;
      case TRADE_SIGNAL_PROP_SIGNALS:
        return (T)signals;
      case TRADE_SIGNAL_PROP_STRENGTH:
        return (T)strength;
      case TRADE_SIGNAL_PROP_TF:
        return (T)tf;
      case TRADE_SIGNAL_PROP_TIME:
        return (T)timestamp;
      case TRADE_SIGNAL_PROP_WEIGHT:
        return (T)weight;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return (T)NULL;
  }
  bool Get(STRUCT_ENUM(TradeSignalEntry, ENUM_TRADE_SIGNAL_FLAG) _prop) { return CheckSignals(_prop); }
  /* Setters */
  template <typename T>
  void Set(STRUCT_ENUM(TradeSignalEntry, ENUM_TRADE_SIGNAL_PROP) _prop, T _value) {
    switch (_prop) {
      case TRADE_SIGNAL_PROP_MAGIC_ID:
        magic_id = (long)_value;
        return;
      case TRADE_SIGNAL_PROP_SIGNALS:
        signals = (unsigned int)_value;
        return;
      case TRADE_SIGNAL_PROP_STRENGTH:
        strength = (float)_value;
        return;
      case TRADE_SIGNAL_PROP_TF:
        tf = (ENUM_TIMEFRAMES)_value;
        return;
      case TRADE_SIGNAL_PROP_TIME:
        timestamp = (long)_value;
        return;
      case TRADE_SIGNAL_PROP_WEIGHT:
        weight = (float)_value;
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
  }
  void Set(STRUCT_ENUM(TradeSignalEntry, ENUM_TRADE_SIGNAL_FLAG) _prop, bool _value) { SetSignal(_prop, _value); }
  /* Signal methods for bitwise operations */
  bool CheckSignals(unsigned int _flags) { return (signals & _flags) != 0; }
  bool CheckSignalsEqual(unsigned int _flags, unsigned int _value) { return (signals & _flags) == _value; }
  bool CheckSignalsExact(unsigned int _flags) { return (signals & _flags) == _flags; }
  unsigned int GetSignals() { return signals; }
  /* Setters */
  void AddSignals(unsigned int _flags) { signals |= _flags; }
  void RemoveSignals(unsigned int _flags) { signals &= ~_flags; }
  void SetSignal(ENUM_TRADE_SIGNAL_FLAG _flag, bool _value = true) {
    if (_value) {
      AddSignals(_flag);
    } else {
      RemoveSignals(_flag);
    }
  }
  void SetSignals(unsigned int _flags) { signals = _flags; }
  // Serializers.
  SERIALIZER_EMPTY_STUB;
  SerializerNodeType Serialize(Serializer &_s) {
    _s.PassEnum(THIS_REF, "tf", tf);
    _s.Pass(THIS_REF, "timestamp", timestamp, SERIALIZER_FIELD_FLAG_DYNAMIC | SERIALIZER_FIELD_FLAG_FEATURE);
    _s.Pass(THIS_REF, "strength", strength, SERIALIZER_FIELD_FLAG_DYNAMIC);
    _s.Pass(THIS_REF, "weight", weight, SERIALIZER_FIELD_FLAG_DYNAMIC);
    int _size = sizeof(int) * 8;
    for (int i = 0; i < _size; i++) {
      int _value = CheckSignals(1 << i) ? 1 : 0;
      _s.Pass(THIS_REF, IntegerToString(i + 1), _value, SERIALIZER_FIELD_FLAG_DYNAMIC | SERIALIZER_FIELD_FLAG_FEATURE);
    }
    return SerializerNodeObject;
  }
  string ToString() {
    // SerializerConverter _stub = SerializerConverter::MakeStubObject<TradeSignalEntry>(SERIALIZER_FLAG_SKIP_HIDDEN);
    return SerializerConverter::FromObject(THIS_REF, SERIALIZER_FLAG_INCLUDE_ALL | SERIALIZER_FLAG_SKIP_HIDDEN)
        .ToString<SerializerJson>(SERIALIZER_JSON_NO_WHITESPACES);
  }
};

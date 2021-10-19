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
 * Implements TradeSignalManager's structures.
 */

// Defines.
#define TSM_PROP_FREQ STRUCT_ENUM(TradeSignalManagerParams, TSM_PARAMS_PROP_FREQ)

/**
 * Structure to manage TradeSignalManager parameters.
 */
struct TradeSignalManagerParams {
 protected:
  short freq;  // Signal process refresh frequency (in sec).

 public:
  /* Struct's enumerations */

  // Enumeration for strategy bitwise signal flags.
  enum ENUM_TSM_PARAMS_PROP {
    TSM_PARAMS_PROP_FREQ = 0,
  };

  /**
   * Struct constructor.
   */
  TradeSignalManagerParams(short _freq = 10) : freq(_freq) {}

  /**
   * Struct copy constructor.
   */
  TradeSignalManagerParams(TradeSignalManagerParams &_params) { THIS_REF = _params; }

  /* Getters */

  template <typename T>
  T Get(STRUCT_ENUM(TradeSignalManagerParams, ENUM_TSM_PARAMS_PROP) _prop) {
    switch (_prop) {
      case TSM_PARAMS_PROP_FREQ:
        return (T)freq;
    }
    SetUserError(ERR_INVALID_PARAMETER);
    return (T)WRONG_VALUE;
  }

  /* Setters */

  template <typename T>
  void Set(STRUCT_ENUM(TradeSignalManagerParams, ENUM_TSM_PARAMS_PROP) _prop, T _value) {
    switch (_prop) {
      case TSM_PARAMS_PROP_FREQ:
        freq = (short)_value;
        return;
    }
    SetUserError(ERR_INVALID_PARAMETER);
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
    _s.Pass(THIS_REF, "freq", freq);
    return SerializerNodeObject;
  }

  /**
   * Converts this class into a string.
   *
   * @return
   *   Returns a JSON serialized signal.
   */
  string ToString() {
    return SerializerConverter::FromObject(THIS_REF, SERIALIZER_FLAG_SKIP_HIDDEN)
        .ToString<SerializerJson>(SERIALIZER_JSON_NO_WHITESPACES);
  }
};

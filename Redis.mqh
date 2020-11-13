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
 * Implements class for storing/retrieving Redis database data.
 */
#include "Object.mqh"
#include "SerializerJson.mqh"
#include "Socket.mqh"

enum ENUM_REDIS_VALUE_SET { REDIS_VALUE_SET_ALWAYS, REDIS_VALUE_SET_IF_NOT_EXIST, REDIS_VALUE_SET_IF_ALREADY_EXIST };

/**
 * Redis class.
 */
class Redis : public Object {
 protected:
  Socket socket;

 public:
  /**
   * Constructor.
   */
  Redis(const string address, const int port = 6379) { socket.Connect(address, port); }

  bool Ping() { return Command("PING") == "PONG"; }

  /**
   * Set string-based variable.
   */
  bool SetString(string _key, string _value, unsigned int _expiration_ms = 0,
                 ENUM_REDIS_VALUE_SET _set_type = REDIS_VALUE_SET_ALWAYS) {
    string _command = "SET " + Serializer::ValueToString(_key, true) + " " + Serializer::ValueToString(_value, true);

    if (_expiration_ms != 0) {
      _command += " PX " + IntegerToString(_expiration_ms);
    }

    switch (_set_type) {
      case REDIS_VALUE_SET_ALWAYS:
        break;
      case REDIS_VALUE_SET_IF_NOT_EXIST:
        _command += " NX";
        break;
      case REDIS_VALUE_SET_IF_ALREADY_EXIST:
        _command += " XX";
        break;
    }

    return Command(_command) == "OK";
  }

  /**
   * Returns string-based variable, default value or NULL.
   */
  string GetString(const string _key, string _default = NULL) {
    string result = Command("GET " + Serializer::ValueToString(_key, true));

    if (result == NULL) return _default;

    return result;
  }

  /**
   * Increments integer-based value by given amount.
   */
  bool Increment(const string _key, const int _value = 1) {
    if (_value > 0) {
      return Command("INCRBY " + Serializer::ValueToString(_key, true) + " " + IntegerToString(_value)) != NULL;
    } else if (_value < 0) {
      return Command("DECRBY " + Serializer::ValueToString(_key, true) + " " + IntegerToString(-_value)) != NULL;
    }

    // _value was 0. Nothing to do.
    return true;
  }

  /**
   * Increments float-based value by given amount.
   */
  bool Increment(const string _key, const float _value = 1.0f) {
    if (_value > 0.0f) {
      return Command("INCRBYFLOAT " + Serializer::ValueToString(_key, true) + " " + DoubleToString(_value)) != NULL;
    } else if (_value < 0.0f) {
      return Command("DECRBYFLOAT " + Serializer::ValueToString(_key, true) + " " + DoubleToString(_value)) != NULL;
    }

    // _value was 0. Nothing to do.
    return true;
  }

  /**
   * Decrements integer-based value by given amount.
   */
  bool Decrement(const string _key, const int _value = 1) { return Increment(_key, -_value); }

  /**
   * Decrements float-based value by given amount.
   */
  bool Decrement(const string _key, const float _value = 1.0f) { return Increment(_key, -_value); }

  /**
   * Deletes variable by given key.
   */
  bool Delete(const string _key) { return Command("DEL " + Serializer::ValueToString(_key, true)) != NULL; }

  /**
   * Subscribes to string-based values on the given channels (separated by space).
   *
   * After subscribe, please use TryReadString() in the loop to retrieve values.
   */
  bool Subscribe(const string _channel_list) { return Command("SUBSCRIBE " + _channel_list) != NULL; }

  /**
   * Unsubscribes from the given channels (separated by space).
   */
  bool Unsubscribe(const string _channel_list) { return Command("UNSUBSCRIBE " + _channel_list) != NULL; }

  /**
   * Publishes string-based value on the given channel (channel must be previously subscribed).
   */
  bool Publish(const string _channel, const string _value) {
    return Command("PUBLISH " + _channel + " " + Serializer::ValueToString(_value, true)) != NULL;
  }

  /**
   * Executes Redis command on the given socket.
   */
  string Command(const string _command) {
    socket.EnsureConnected();
    socket.Send(_command + "\n");
    string _response = socket.ReadString();
    string _header = StringSubstr(_response, 0, StringFind(_response, "\r\n"));

    if (StringSubstr(_header, 0, 1) == "+") {
      // A tiny response.
      _response = StringSubstr(_header, 1);
    } else {
      if (_header == "$-1" || StringSubstr(_header, 0, 1) == "-") {
        // No response or error happened.
        return NULL;
      }

      _response = StringSubstr(_response, StringFind(_response, "\r\n") + 2);
      _response = StringSubstr(_response, 0, StringLen(_response) - 2);
    }

    return _response;
  }
};

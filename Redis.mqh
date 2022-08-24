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
 * Implements class for storing/retrieving Redis database data.
 */
#include "Dict.mqh"
#include "Object.mqh"
#include "Redis.struct.h"
#include "Serializer/Serializer.h"
#include "Serializer/SerializerConversions.h"
#include "Serializer/SerializerJson.h"
#include "Socket.mqh"

enum ENUM_REDIS_VALUE_SET { REDIS_VALUE_SET_ALWAYS, REDIS_VALUE_SET_IF_NOT_EXIST, REDIS_VALUE_SET_IF_ALREADY_EXIST };

typedef void (*RedisCallback)(string);

/**
 * Redis queue for simulation.
 */
class RedisQueue {
 protected:
  // Messages queue for simulation purposes.
  string _queue[];

  // Current message index to be processed. Set to 0 if all messages have been popped out.
  int _queue_index;

 public:
  /**
   * Constructor.
   */
  RedisQueue() { _queue_index = 0; }

  /**
   * Enqueues a single messange on the queue.
   */
  void Enqueue(RedisMessage& message) { Enqueue(message.ToString()); }

  /**
   * Enqueues a single messange on the queue.
   */
  void Enqueue(string message) {
    ArrayResize(_queue, ArraySize(_queue) + 1, 10);
    _queue[ArraySize(_queue) - 1] = message;
  }

  /**
   * Checks whether there are any awaiting message to be processed.
   */
  bool HasData() { return ArraySize(_queue) > 0; }

  /**
   * Clears message queue.
   */
  void Clear() { ArrayResize(_queue, 0); }

  /**
   * Pops out the oldest added message and clears the queue if all messages are popped out.
   */
  RedisMessage PopFirst() {
    string result = _queue[_queue_index++];

    if (_queue_index >= ArraySize(_queue)) {
      // Popped last item.
      ArrayResize(_queue, 0);
      _queue_index = 0;
#ifdef __debug__
      Print("Redis Queue Cleared!");
#endif
    }

    RedisMessage msg;
    msg.FromString(result);
    return msg;
  }
};

/**
 * Redis class.
 */
class Redis : public Object {
 protected:
  Socket _socket;

  // List of messages sent by server back to client.
  RedisQueue _messages;

  // List of client channels subscriptions.
  Dict<string, bool> _subscriptions;

  // Whether Redis is simualting being both, the client & the server.
  bool _simulate;

 public:
  /**
   * Constructor.
   */
  Redis(const string address = "127.0.0.1", const int port = 6379, bool simulate = false) {
    _simulate = simulate;
    if (!simulate) {
      Connect(address, port);
    }
  }

  /**
   * Constructor.
   */
  Redis(bool simulate) {
    _simulate = simulate;
    if (!simulate) {
      Connect("127.0.0.1", 6379);
    }
  }

  /**
   * Connects to Redis socket.
   */
  bool Connect(const string address = "127.0.0.1", const int port = 6379) { return _socket.Connect(address, port); }

  /**
   * Returns list of messages sent by server back to client.
   */
  RedisQueue* Messages() { return &_messages; }

  /**
   * Parses server's command such as SUBSCRIBE, UNSUBSCRIBE.
   */
  string ParseCommand(string command) {
    StringTrimLeft(command);
    StringTrimRight(command);

    string command_name = StringSubstr(command, 0, StringFind(command, " "));
    string command_args = StringSubstr(command, StringLen(command_name) + 1);

    if (command_name == "SUBSCRIBE") {
      string subscriptions[];
      StringSplit(command_args, ' ', subscriptions);
      for (int i = 0; i < ArraySize(subscriptions); ++i) {
        _subscriptions.Set(subscriptions[i], true);
      }
      return "OK";
    }

    return "UNKNOWN COMMAND!";
  }

  /**
   * Checks whether we are simulating Redis client/server.
   */
  bool Simulated() { return _simulate; }

  /**
   * Checks whether Redis channel has been subscribed. Only works in simulation mode.
   */
  bool Subscribed(string channel) { return _subscriptions.KeyExists(channel); }

  /**
   * Ping and returns whether pong was received back.
   */
  bool Ping() { return Command("PING") == "PONG"; }

  /**
   * Set string-based variable.
   */
  bool SetString(string _key, string _value, unsigned int _expiration_ms = 0,
                 ENUM_REDIS_VALUE_SET _set_type = REDIS_VALUE_SET_ALWAYS) {
    string _command = "SET " + SerializerConversions::ValueToString(_key, true) + " " +
                      SerializerConversions::ValueToString(_value, true);

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
    string result = Command("GET " + SerializerConversions::ValueToString(_key, true));

    if (result == NULL) return _default;

    return result;
  }

  /**
   * Increments integer-based value by given amount.
   */
  bool Increment(const string _key, const int _value = 1) {
    if (_value > 0) {
      return Command("INCRBY " + SerializerConversions::ValueToString(_key, true) + " " + IntegerToString(_value)) !=
             NULL;
    } else if (_value < 0) {
      return Command("DECRBY " + SerializerConversions::ValueToString(_key, true) + " " + IntegerToString(-_value)) !=
             NULL;
    }

    // _value was 0. Nothing to do.
    return true;
  }

  /**
   * Increments float-based value by given amount.
   */
  bool Increment(const string _key, const float _value = 1.0f) {
    if (_value > 0.0f) {
      return Command("INCRBYFLOAT " + SerializerConversions::ValueToString(_key, true) + " " +
                     DoubleToString(_value)) != NULL;
    } else if (_value < 0.0f) {
      return Command("DECRBYFLOAT " + SerializerConversions::ValueToString(_key, true) + " " +
                     DoubleToString(_value)) != NULL;
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
  bool Delete(const string _key) { return Command("DEL " + SerializerConversions::ValueToString(_key, true)) != NULL; }

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
    return Command("PUBLISH " + _channel + " " + SerializerConversions::ValueToString(_value, true)) != NULL;
  }

  /**
   * Checks whether there is any data waiting on the Redis socket to be read.
   */
  bool HasData() { return _messages.HasData() || _socket.HasData(); }

  /**
   * Executes Redis command on the given socket.
   */
  string Command(const string _command) {
    if (_simulate) {
      return ParseCommand(_command);
    }

    _socket.EnsureConnected();
    _socket.Send(_command + "\n");
    string _response = _socket.ReadString();
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

  /**
   * Reads a single string from subscribed channels.
   */
  RedisMessage ReadMessage() {
    if (_messages.HasData()) {
      // Retrieving message from queue.
      return _messages.PopFirst();
    }

    RedisMessage msg;

    if (_socket.HasData()) {
      msg.FromString(_socket.ReadString());
      return msg;
    }

    // Empty message.
    return msg;
  }
};

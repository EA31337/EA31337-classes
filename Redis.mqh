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
#include "Dict.mqh"
#include "Object.mqh"
#include "Serializer.mqh"
#include "SerializerJson.mqh"
#include "Socket.mqh"

enum ENUM_REDIS_VALUE_SET { REDIS_VALUE_SET_ALWAYS, REDIS_VALUE_SET_IF_NOT_EXIST, REDIS_VALUE_SET_IF_ALREADY_EXIST };

typedef void (*RedisCallback)(string);

/**
 * Redis message with command name and arguments.
 */

struct RedisMessage {
  // Original message text.
  string WholeMessage;

  // Originating channel.
  string Channel;

  // Channel's command.
  string Command;

  // Channel's message.
  string Message;

  // Items of array returned from Redis.
  string Items[];

  /**
   * Adds string value into Redis message array.
   */
  void Add(string value) { PushItem(value); }

  /**
   * Adds integer value into Redis message array.
   */
  void Add(int value) { PushItem(":" + IntegerToString(value)); }

 protected:
  void PushItem(string value) {
    ArrayResize(Items, ArraySize(Items) + 1);
    Items[ArraySize(Items) - 1] = value;
  }

 public:
  string ToString() {
    string result = "";

    if (ArraySize(Items) > 1) {
      result += "*" + IntegerToString(ArraySize(Items)) + "\r\n";
      for (int i = 0; i < ArraySize(Items); ++i) {
        result += "$" + IntegerToString(StringLen(Items[i])) + "\r\n";
        result += Items[i] + "\r\n";
      }
    } else if (ArraySize(Items) == 1) {
      result += Items[0] + "\r\n";
    } else {
      result = "Tried to convert empty Redis message into string!";
      Alert(result);
    }

    return result;
  }

  int SkipTillNewline(string& value, int start) {
    int i;
    unsigned short char1, char2;

    for (i = start; i < StringLen(value); ++i) {
#ifdef __MQL5__
      char1 = StringGetCharacter(value, i);
      char2 = StringGetCharacter(value, i + 1);
#else
      char1 = StringGetChar(value, i);
      char2 = StringGetChar(value, i + 1);
#endif

      if (char1 == '\r' && char2 == '\n') {
        break;
      }
    }

    return i - start;
  }

  void FromString(string message) {
    WholeMessage = message;
    int i;

    if (message[0] == '*') {
      // Array of items.

      // Skipping '*'.
      i = 1;

      // Taking number of array items.
      while (message[i] != '\r') {
        ++i;
      }

      int num_items = (int)StringToInteger(StringSubstr(message, 1, i - 1));

      // Skipping \r\n.
      i += 2;

      string rest = StringSubstr(message, i);

      for (int item = 0; item < num_items; ++item) {
        i = ParseItem(rest, i);
      }
    } else {
      // Single item.
      ParseItem(message);
    }

    if (ArraySize(Items) > 1) {
      if (Items[0] == "message") {
        Command = Items[0];
        Channel = Items[1];
        Message = Serializer::UnescapeString(Items[2]);
      }
    } else {
      Message = Items[0];
    }
  }

  int ParseItem(string& rest, int i = 0) {
    unsigned short c;

    c = StringGetCharacter(rest, i);

    if (c == '$') {
      // A blob.

      // Skipping '$'.
      ++i;

      int skip = SkipTillNewline(rest, i);
      int data_length = (int)StringToInteger(StringSubstr(rest, i, skip));

      // Skipping number and \r\n.
      i += skip + 2;

      string data = StringSubstr(rest, i, data_length);

      // Skipping data length and \r\n.
      i += data_length + 2;

      PushItem(data);
    } else if (c == ':') {
      // Number.

      // Skipping ':'.
      ++i;

      int skip = SkipTillNewline(rest, i);
      PushItem(StringSubstr(rest, i, skip));

      // Skipping number and \r\n.
      i += skip + 2;
    } else {
      // Single string.
      int data_length = SkipTillNewline(rest, i);
      PushItem(StringSubstr(rest, i, data_length));

      // Skipping data length and \r\n.
      i += data_length + 2;
    }

    return i;
  }
};

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
      Print("Redis Queue Cleared!");
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

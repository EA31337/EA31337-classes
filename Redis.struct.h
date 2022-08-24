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
 * Includes Redis's structs.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "Serializer/SerializerConversions.h"

// Forward declaration.
class Serializer;

/**
 * @file
 * Includes Redis's structs.
 */

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
        Message = SerializerConversions::UnescapeString(Items[2]);
      }
    } else {
      Message = Items[0];
    }
  }

  int ParseItem(string& rest, int i = 0) {
    int data_length = 0, skip = 0;
    unsigned short c;

    c = StringGetCharacter(rest, i);

    if (c == '$') {
      // A blob.

      // Skipping '$'.
      ++i;

      skip = SkipTillNewline(rest, i);
      data_length = (int)StringToInteger(StringSubstr(rest, i, skip));

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

      skip = SkipTillNewline(rest, i);
      PushItem(StringSubstr(rest, i, skip));

      // Skipping number and \r\n.
      i += skip + 2;
    } else {
      // Single string.
      data_length = SkipTillNewline(rest, i);
      PushItem(StringSubstr(rest, i, data_length));

      // Skipping data length and \r\n.
      i += data_length + 2;
    }

    return i;
  }
};

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

// Prevents processing this includes file for the second time.
#ifndef JSON_MQH
#define JSON_MQH

// Includes.
#include "DictBase.mqh"
#include "JsonNode.mqh"
#include "JsonSerializer.mqh"
#include "Object.mqh"

class Log;

class JSON {
 public:
  static string ValueToString(datetime value, bool includeQuotes = false) {
#ifdef __MQL5__
    return (includeQuotes ? "\"" : "") + TimeToString(value) + (includeQuotes ? "\"" : "");
#else
    return (includeQuotes ? "\"" : "") + TimeToStr(value) + (includeQuotes ? "\"" : "");
#endif
  }

  static string ValueToString(bool value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + (value ? "true" : "false") + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(int value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + IntegerToString(value) + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(long value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + IntegerToString(value) + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(string value, bool includeQuotes = false) {
    string output = includeQuotes ? "\"" : "";

    for (unsigned short i = 0; i < StringLen(value); ++i) {
#ifdef __MQL5__
      switch (StringGetCharacter(value, i))
#else
      switch (StringGetChar(value, i))
#endif
      {
        case '"':
          output += "\\\"";
          break;
        case '/':
          output += "\\/";
          break;
        case '\n':
          output += "\\n";
          break;
        case '\r':
          output += "\\r";
          break;
        case '\t':
          output += "\\t";
          break;
        case '\\':
          output += "\\\\";
          break;
        default:
#ifdef __MQL5__
          output += ShortToString(StringGetCharacter(value, i));
#else
          output += ShortToString(StringGetChar(value, i));
#endif
          break;
      }
    }

    return output + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(float value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + StringFormat("%.6f", value) + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(double value, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + StringFormat("%.8f", value) + (includeQuotes ? "\"" : "");
  }

  static string ValueToString(Object* _obj, bool includeQuotes = false) {
    return (includeQuotes ? "\"" : "") + ((Object*)_obj).ToString() + (includeQuotes ? "\"" : "");
  }
  template <typename T>
  static string ValueToString(T value, bool includeQuotes = false) {
    return StringFormat("%s%s%s", (includeQuotes ? "\"" : ""), value, (includeQuotes ? "\"" : ""));
  }

  template <typename X>
  static string Stringify(X& obj, bool trimWhitespace = true, int indentSize = 2) {
    JsonSerializer serializer(NULL, JsonSerialize);
    serializer.PassStruct(obj, "", obj);

    if (serializer.GetRoot()) {
      return serializer.GetRoot().ToString(trimWhitespace, indentSize);
    }

    // Error occured.
    return "{\"error\": \"Cannot stringify object!\"}";
  }

  template <typename X>
  static bool Parse(string data, X* obj, Log* logger = NULL) {
    return Parse(data, *obj, logger);
  }

  template <typename X>
  static bool Parse(string data, X& obj, Log* logger = NULL) {
    JsonNode* node = Parse(data);

    if (!node) {
      // Parsing failed.
      return false;
    }

    JsonSerializer serializer(node, JsonUnserialize);

    if (logger != NULL) serializer.Logger().Link(logger);

    // We don't use result. We parse data as it is.
    obj.Serialize(serializer);

    return true;
  }

  static JsonNode* Parse(string data) {
    JsonNodeType type;
    if (StringGetCharacter(data, 0) == '{')
      type = JsonNodeObject;
    else if (StringGetCharacter(data, 0) == '[')
      type = JsonNodeArray;
    else {
      return GracefulReturn("Failed to parse JSON. It must start with either \"{\" or \"[\".", 0, NULL, NULL);
    }

    JsonNode* root = NULL;
    JsonNode* current = NULL;
    JsonNode* node = NULL;

    string extracted;

    bool isOuterScope = true;
    bool expectingKey = false;
    bool expectingValue = false;
    bool expectingSemicolon = false;
    JsonParam* key = NULL;
    JsonParam* value = NULL;
    unsigned short ch, ch2;
    unsigned int k;

    for (unsigned int i = 0; i < (unsigned int)StringLen(data); ++i) {
      ch = StringGetCharacter(data, i);

      // ch2 will be an another non-whitespace character.
      k = i + 1;
      do {
        ch2 = StringGetCharacter(data, k++);
      } while (ch2 == ' ' || ch2 == '\t' || ch2 == '\n' || ch2 == '\r');

      if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') continue;

      if (ch == '"') {
        extracted = ExtractString(data, i + 1);

        if (extracted == NULL) {
          return GracefulReturn("Unexpected end of file when parsing string", i, root, key);
        }
        if (expectingKey) {
          key = JsonParam::FromString(extracted);

          expectingKey = false;
          expectingSemicolon = true;
        } else if (expectingValue) {
          current.AddChild(
              new JsonNode(current.GetType() == JsonNodeObject ? JsonNodeObjectProperty : JsonNodeArrayItem, current,
                           key, JsonParam::FromString(extracted)));

          expectingValue = false;
        } else {
          return GracefulReturn("Unexpected '\"' symbol", i, root, key);
        }

        // Skipping double quotes.
        i += StringLen(extracted) + 1;
      } else if (expectingSemicolon) {
        if (ch != ':') {
          return GracefulReturn("Expected semicolon", i, root, key);
        }
        expectingSemicolon = false;
        expectingValue = true;
      } else if (ch == '{') {
        if (expectingKey) {
          return GracefulReturn("Cannot use object as a key", i, root, key);
        }

        node = new JsonNode(JsonNodeObject, current, key);

        if (!root) root = node;

        if (expectingValue) current.AddChild(node);

        current = node;

        isOuterScope = false;
        expectingValue = false;
        expectingKey = ch2 != '}';
        key = NULL;
      } else if (ch == '}') {
        if (expectingKey || expectingValue || current.GetType() != JsonNodeObject) {
          return GracefulReturn("Unexpected end of object", i, root, key);
        }

        current = current.GetParent();
        expectingValue = false;
      } else if (ch == '[') {
        if (expectingKey) {
          return GracefulReturn("Cannot use array as a key", i, root, key);
        }

        node = new JsonNode(JsonNodeArray, current, key);

        if (!root) root = node;

        if (expectingValue) current.AddChild(node);

        current = node;
        expectingValue = ch2 != ']';
        isOuterScope = false;
        key = NULL;
      } else if (ch == ']') {
        if (expectingKey || expectingValue || current.GetType() != JsonNodeArray) {
          return GracefulReturn("Unexpected end of array", i, root, key);
        }

        current = current.GetParent();
        expectingValue = false;
      } else if (ch >= '0' && ch <= '9') {
        if (!expectingValue) {
          return GracefulReturn("Unexpected numeric value", i, root, key);
        }

        if (!ExtractNumber(data, i, extracted)) {
          return GracefulReturn("Cannot parse numeric value", i, root, key);
        }

        value = StringFind(extracted, ".") != -1 ? JsonParam::FromValue(StringToDouble(extracted))
                                                 : JsonParam::FromValue(StringToInteger(extracted));
        current.AddChild(new JsonNode(current.GetType() == JsonNodeObject ? JsonNodeObjectProperty : JsonNodeArrayItem,
                                      current, key, value));
        expectingValue = false;

        // Skipping value.
        i += StringLen(extracted) - 1;

        // We don't want to delete it twice.
        key = NULL;
      } else if (ch == ',') {
        if (expectingKey || expectingValue || expectingSemicolon) {
          return GracefulReturn("Unexpected comma", i, root, key);
        }

        if (current.GetType() == JsonNodeObject)
          expectingKey = true;
        else
          expectingValue = true;
      }
    }

    if (key) delete key;

    return root;
  }

  static JsonNode* GracefulReturn(string error, unsigned int index, JsonNode* root, JsonParam* key) {
    Print(error + " at index ", index);

    if (root != NULL) delete root;

    if (key != NULL) delete key;

    return NULL;
  }

  static bool ExtractNumber(string& data, unsigned int index, string& number) {
    string str;

    for (unsigned int i = index; i < (unsigned int)StringLen(data); ++i) {
#ifdef __MQL5__
      unsigned short ch = StringGetCharacter(data, i);
#else
      unsigned short ch = StringGetChar(data, i);
#endif

      if (ch >= '0' && ch <= '9') {
        str += ShortToString(ch);
      } else if (ch == '.') {
        if (i == index) {
          return false;
        }
        str += ShortToString(ch);
      } else {
        // End of the number.
        number = str;
        return true;
      }
    }

    return true;
  }

  static string ExtractString(string& data, unsigned int index) {
    for (unsigned int i = index; i < (unsigned int)StringLen(data); ++i) {
      unsigned short ch = StringGetCharacter(data, i);

      if (ch == '"') {
        return StringSubstr(data, index, i - index);
      }
    }

    return NULL;
  }
};

#endif

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

// Prevents processing this includes file for the second time.
#ifndef SERIALIZER_JSON_MQH
#define SERIALIZER_JSON_MQH

// Includes.
#include "DictBase.mqh"
#include "Object.mqh"
#include "Serializer.mqh"
#include "SerializerNode.mqh"

class Log;

enum ENUM_SERIALIZER_JSON_FLAGS {
  SERIALIZER_JSON_NO_WHITESPACES = 1,
  SERIALIZER_JSON_INDENT_2_SPACES = 2,
  SERIALIZER_JSON_INDENT_4_SPACES = 4
};

class SerializerJson {
 public:
  /**
   * Serializes node and its children into string in generic format (JSON at now).
   */
  static string Stringify(SerializerNode* _node, unsigned int stringify_flags = 0, void* stringify_aux_arg = NULL,
                          unsigned int indent = 0) {
    string repr;
    string ident;

    bool trimWhitespaces = bool(stringify_flags & SERIALIZER_JSON_NO_WHITESPACES);

    int indentSize;

    if (bool(stringify_flags & SERIALIZER_JSON_INDENT_2_SPACES))
      indentSize = 2;
    else if (bool(stringify_flags & SERIALIZER_JSON_INDENT_4_SPACES))
      indentSize = 4;
    else
      indentSize = 2;

    if (!trimWhitespaces)
      for (unsigned int i = 0; i < indent * indentSize; ++i) ident += " ";

    repr += ident;

    if (PTR_ATTRIB(_node, GetKeyParam()) != NULL && PTR_ATTRIB(PTR_ATTRIB(_node, GetKeyParam()), AsString(false, false)) != "")
      repr += PTR_ATTRIB(PTR_ATTRIB(_node, GetKeyParam()), AsString(false, true)) + ":" + (trimWhitespaces ? "" : " ");

    if (PTR_ATTRIB(_node, GetValueParam()) != NULL) repr += PTR_ATTRIB(PTR_ATTRIB(_node, GetValueParam()), AsString(false, true));

    switch (PTR_ATTRIB(_node, GetType())) {
      case SerializerNodeObject:
        repr += string("{") + (trimWhitespaces ? "" : "\n");
        break;
      case SerializerNodeArray:
        repr += string("[") + (trimWhitespaces ? "" : "\n");
        break;
    }

    if (PTR_ATTRIB(_node, HasChildren())) {
      for (unsigned int j = 0; j < PTR_ATTRIB(_node, NumChildren()); ++j) {
        repr += PTR_ATTRIB(PTR_ATTRIB(_node, GetChild(j)), ToString(trimWhitespaces, indentSize, indent + 1));
      }
    }

    switch (PTR_ATTRIB(_node, GetType())) {
      case SerializerNodeObject:
        repr += ident + "}";
        break;
      case SerializerNodeArray:
        repr += ident + "]";
        break;
    }

    if (!PTR_ATTRIB(_node, IsLast())) repr += ",";

    // Appending newline only when inside the root node.
    if (indent != 0) repr += (trimWhitespaces ? "" : "\n");

    return repr;
  }

  template <typename X>
  static bool Parse(string data, X* obj, Log* logger = NULL) {
    return Parse(data, *obj, logger);
  }

  template <typename X>
  static bool Parse(string data, X& obj, Log* logger = NULL) {
    SerializerNode* node = Parse(data);

    if (!node) {
      // Parsing failed.
      return false;
    }

    Serializer serializer(node, JsonUnserialize);

    if (logger != NULL) serializer.Logger().Link(logger);

    // We don't use result. We parse data as it is.
    obj.Serialize(serializer);

    return true;
  }

  static SerializerNode* Parse(string data, unsigned int converter_flags = 0) {
    SerializerNodeType type;
    if (StringGetCharacter(data, 0) == '{')
      type = SerializerNodeObject;
    else if (StringGetCharacter(data, 0) == '[')
      type = SerializerNodeArray;
    else {
      return GracefulReturn("Failed to parse JSON. It must start with either \"{\" or \"[\".", 0, NULL, NULL);
    }

    SerializerNode* root = NULL;
    SerializerNode* current = NULL;
    SerializerNode* node = NULL;

    string extracted;

    bool isOuterScope = true;
    bool expectingKey = false;
    bool expectingValue = false;
    bool expectingSemicolon = false;
    SerializerNodeParam* key = NULL;
    SerializerNodeParam* value = NULL;
    unsigned short ch, ch2;
    unsigned int k;

    for (unsigned int i = 0; i < (unsigned int)StringLen(data); ++i) {
      ch = StringGetCharacter(data, i);

      // ch2 will be an another non-whitespace character.
      k = i + 1;
      do {
        ch2 = StringGetCharacter(data, k++);
        if (GetLastError() == 5041) {
          ResetLastError();
          ch2 = 0;
          break;
        }
      } while (ch2 == ' ' || ch2 == '\t' || ch2 == '\n' || ch2 == '\r');

      if (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') continue;

      if (ch == '"') {
        extracted = ExtractString(data, i + 1);

        if (extracted == "") {
          return GracefulReturn("Unexpected end of file when parsing string", i, root, key);
        }
        if (expectingKey) {
          key = SerializerNodeParam::FromString(extracted);
          expectingKey = false;
          expectingSemicolon = true;
        } else if (expectingValue) {
          PTR_ATTRIB(current, AddChild(new SerializerNode(
              PTR_ATTRIB(current, GetType()) == SerializerNodeObject ? SerializerNodeObjectProperty : SerializerNodeArrayItem,
              current, key, SerializerNodeParam::FromString(extracted))));

#ifdef __debug__
          Print("SerializerJson: Value \"" + extracted + "\" for key " +
                (key != NULL ? ("\"" + key.ToString() + "\"") : "<none>"));
#endif

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

#ifdef __debug__
        Print("SerializerJson: Entering object for key " + (key != NULL ? ("\"" + key.ToString() + "\"") : "<none>"));
#endif

        node = new SerializerNode(SerializerNodeObject, current, key);

        if (!root) root = node;

        if (expectingValue) PTR_ATTRIB(current, AddChild(node));

        current = node;

        isOuterScope = false;
        expectingValue = false;
        expectingKey = ch2 != '}';
        key = NULL;
      } else if (ch == '}') {
        if (expectingKey || expectingValue || PTR_ATTRIB(current, GetType()) != SerializerNodeObject) {
          return GracefulReturn("Unexpected end of object", i, root, key);
        }

#ifdef __debug__
        Print("SerializerJson: Leaving object for key " + (current != NULL && current.GetKeyParam() != NULL
                                                               ? ("\"" + current.GetKeyParam().ToString() + "\"")
                                                               : "<none>"));
#endif

        current = PTR_ATTRIB(current, GetParent());
        expectingValue = false;
      } else if (ch == '[') {
#ifdef __debug__
        Print("SerializerJson: Entering list for key " + (key != NULL ? ("\"" + key.ToString() + "\"") : "<none>"));
#endif

        if (expectingKey) {
          return GracefulReturn("Cannot use array as a key", i, root, key);
        }

        node = new SerializerNode(SerializerNodeArray, current, key);

        if (!root) root = node;

        if (expectingValue) PTR_ATTRIB(current, AddChild(node));

        current = node;
        expectingValue = ch2 != ']';
        isOuterScope = false;
        key = NULL;
      } else if (ch == ']') {
#ifdef __debug__
        Print("SerializerJson: Leaving list for key " + (key != NULL ? ("\"" + key.ToString() + "\"") : "<none>"));
#endif

        if (expectingKey || expectingValue || PTR_ATTRIB(current, GetType()) != SerializerNodeArray) {
          return GracefulReturn("Unexpected end of array", i, root, key);
        }

        current = PTR_ATTRIB(current, GetParent());
        expectingValue = false;
      } else if (ch >= '0' && ch <= '9') {
        if (!expectingValue) {
          return GracefulReturn("Unexpected numeric value", i, root, key);
        }

        if (!ExtractNumber(data, i, extracted)) {
          return GracefulReturn("Cannot parse numeric value", i, root, key);
        }

        value = StringFind(extracted, ".") != -1 ? SerializerNodeParam::FromValue(StringToDouble(extracted))
                                                 : SerializerNodeParam::FromValue(StringToInteger(extracted));
#ifdef __debug__
        Print("SerializerJson: Value " + value.AsString() + " for key " +
              (key != NULL ? ("\"" + key.ToString() + "\"") : "<none>"));
#endif

        PTR_ATTRIB(current, AddChild(new SerializerNode(
            PTR_ATTRIB(current, GetType()) == SerializerNodeObject ? SerializerNodeObjectProperty : SerializerNodeArrayItem, current,
            key, value)));
        expectingValue = false;

        // Skipping value.
        i += StringLen(extracted) - 1;

        // We don't want to delete it twice.
        key = NULL;
      } else if (ch == 't' || ch == 'f') {
        // Assuming true/false.

        value = SerializerNodeParam::FromValue(ch == 't' ? true : false);

#ifdef __debug__
        Print("SerializerJson: Value " + (value.ToBool() ? "true" : "false") + " for key " +
              (key != NULL ? ("\"" + key.ToString() + "\"") : "<none>"));
#endif

        // Skipping value.
        i += ch == 't' ? 3 : 4;

        PTR_ATTRIB(current, AddChild(new SerializerNode(
            PTR_ATTRIB(current, GetType()) == SerializerNodeObject ? SerializerNodeObjectProperty : SerializerNodeArrayItem, current,
            key, value)));
        expectingValue = false;

        // We don't want to delete it twice.
        key = NULL;
      } else if (ch == ',') {
        if (expectingKey || expectingValue || expectingSemicolon) {
          return GracefulReturn("Unexpected comma", i, root, key);
        }

        if (PTR_ATTRIB(current, GetType()) == SerializerNodeObject)
          expectingKey = true;
        else
          expectingValue = true;
      }
    }

    if (key) delete key;

    return root;
  }

  static SerializerNode* GracefulReturn(string error, unsigned int index, SerializerNode* root,
                                        SerializerNodeParam* key) {
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

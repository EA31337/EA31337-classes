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
#ifndef JSON_NODE_MQH
#define JSON_NODE_MQH

// Includes.
#include "DictBase.mqh"
#include "JsonNode.enum.h"
#include "JsonParam.mqh"

class JsonNode {
 protected:
  JsonNodeType _type;

  JsonNode* _parent;
  JsonParam* _key;
  JsonParam* _value;
  JsonNode* _children[];
  unsigned int _numChildren;
  unsigned int _currentChildIndex;

 public:
  /**
   * Constructor.
   */
  JsonNode(JsonNodeType type, JsonNode* parent = NULL, JsonParam* key = NULL, JsonParam* value = NULL)
      : _type(type), _parent(parent), _key(key), _value(value), _numChildren(0), _currentChildIndex(0) {}

  /**
   * Destructor.
   */
  ~JsonNode() {
    if (_key) delete _key;

    if (_value) delete _value;

    for (unsigned int i = 0; i < _numChildren; ++i) delete _children[i];
  }

  /**
   * Checks whether node has specified key.
   */
  bool HasKey() { return _key != NULL && _key._string != ""; }

  /**
   * Returns key specified for a node or empty string (not a NULL).
   */
  string Key() { return _key != NULL ? _key.AsString(false, false) : ""; }

  /**
   * Returns pointer to JsonParam holding the key or NULL.
   */
  JsonParam* GetKeyParam() { return _key; }

  /**
   * Returns pointer to JsonParam holding the value or NULL.
   */
  JsonParam* GetValueParam() { return _value; }

  /**
   * Returns parent node or NULL.
   */
  JsonNode* GetParent() { return _parent; }

  /**
   * Returns next child node (increments index each time the method is called).
   */
  JsonNode* GetNextChild() {
    if (_currentChildIndex >= _numChildren) return NULL;

    return _children[_currentChildIndex++];
  }

  /**
   * Returns type of the node (object, array, object property, array item).
   */
  JsonNodeType GetType() { return _type; }

  /**
   * Sets type of the node. Should be used only internally.
   */
  void SetType(JsonNodeType type) { _type = type; }

  /**
   * Adds child to this node.
   */
  void AddChild(JsonNode* child) {
    if (_numChildren == ArraySize(_children)) ArrayResize(_children, _numChildren + 10);

    _children[_numChildren++] = child;
  }

  /**
   * Checks whether node has children.
   */
  bool HasChildren() { return _numChildren > 0; }

  /**
   * Returns number of child nodes.
   */
  unsigned int NumChildren() { return _numChildren; }

  /**
   * Returns pointer to the child node at given index or NULL.
   */
  JsonNode* GetChild(unsigned int index) { return index >= _numChildren ? NULL : _children[index]; }

  /**
   * Checks whether this node is last in its parent.
   */
  bool IsLast() {
    if (!_parent) return true;

    for (unsigned int i = 0; i < _parent.NumChildren(); ++i) {
      if (_parent.GetChild(i) == &this && i != _parent.NumChildren() - 1) return false;
    }

    return true;
  }

  /**
   * Serializes node and its children into JSON string.
   */
  string ToString(bool trimWhitespaces = false, unsigned int indentSize = 2, unsigned int indent = 0) {
    string repr;
    string ident;

    if (!trimWhitespaces)
      for (unsigned int i = 0; i < indent * indentSize; ++i) ident += " ";

    repr += ident;

    if (GetKeyParam() != NULL && GetKeyParam().AsString(false, false) != "")
      repr += GetKeyParam().AsString(false, true) + ":" + (trimWhitespaces ? "" : " ");

    if (GetValueParam() != NULL) repr += GetValueParam().AsString(false, true);

    switch (GetType()) {
      case JsonNodeObject:
        repr += "{" + (trimWhitespaces ? "" : "\n");
        break;
      case JsonNodeArray:
        repr += "[" + (trimWhitespaces ? "" : "\n");
        break;
    }

    if (HasChildren()) {
      for (unsigned int j = 0; j < NumChildren(); ++j) {
        repr += GetChild(j).ToString(trimWhitespaces, indentSize, indent + 1);
      }
    }

    switch (GetType()) {
      case JsonNodeObject:
        repr += ident + "}";
        break;
      case JsonNodeArray:
        repr += ident + "]";
        break;
    }

    if (!IsLast()) repr += ",";

    // Appending newline only when inside the root node.
    if (indent != 0) repr += (trimWhitespaces ? "" : "\n");

    return repr;
  }
};

#endif

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
#ifndef JSON_NODE_MQH
#define JSON_NODE_MQH

// Includes.
#include "SerializerNode.enum.h"
#include "SerializerNodeParam.mqh"

class SerializerNode {
 protected:
  SerializerNodeType _type;

  SerializerNode* _parent;
  SerializerNodeParam* _key;
  SerializerNodeParam* _value;
  ARRAY(SerializerNode*, _children);
  unsigned int _numChildren;
  unsigned int _currentChildIndex;
  unsigned int _flags;
  int _index;

 public:
  /**
   * Constructor.
   */
  SerializerNode(SerializerNodeType type, SerializerNode* parent = NULL, SerializerNodeParam* key = NULL,
                 SerializerNodeParam* value = NULL, unsigned int flags = 0)
      : _type(type), _parent(parent), _key(key), _value(value), _numChildren(0), _currentChildIndex(0), _flags(flags) {}

  /**
   * Destructor.
   */
  ~SerializerNode() {
    if (_key) delete _key;

    if (_value) delete _value;

    for (unsigned int i = 0; i < _numChildren; ++i) delete _children[i];
  }

  void SetKey(string name) {
    if (_key != NULL) {
      delete _key;
    }

    _key = name != "" ? SerializerNodeParam::FromString(name) : NULL;
  }

  /**
   * Sets node flags.
   */
  void SetFlags(unsigned int flags) { _flags = flags; }

  /**
   * Returns node flags.
   */
  unsigned int GetFlags() { return _flags; }

  /**
   * Checks whether node has specified key.
   */
  bool HasKey() { return _key != NULL && PTR_ATTRIB(_key, _string) != ""; }

  /**
   * Checks whether node is an array.
   */
  bool IsArray() { return _type == SerializerNodeArray; }

  /**
   * Checks whether node is an objec with properties.
   */
  bool IsObject() { return _type == SerializerNodeObject; }

  /**
   * Checks whether node is a container.
   */
  bool IsContainer() { return _type == SerializerNodeArray || _type == SerializerNodeObject; }

  /**
   * Checks whether node is a container for values.
   */
  bool IsValuesContainer() {
    return (_type == SerializerNodeArray || _type == SerializerNodeObject) && _numChildren > 0 &&
           !PTR_ATTRIB(_children[0], IsContainer());
  }

  /**
   * Returns index of the current node in the parent.
   */
  int Index() { return _index; }

  /**
   * Returns key specified for a node or empty string (not a NULL).
   */
  string Key() { return _key != NULL ? PTR_ATTRIB(_key, AsString(false, false)) : ""; }

  /**
   * Returns tree size in bytes.
   */
  int BinarySize() {
    int _result = 0;

    if (!IsContainer()) {
      switch (PTR_ATTRIB(_value, GetType())) {
        case SerializerNodeParamBool:
          _result += 1;
          break;
        case SerializerNodeParamDouble:
          _result += 8;
          break;
        case SerializerNodeParamLong:
          _result += 4;
          break;
        case SerializerNodeParamString:
          _result += StringLen(PTR_ATTRIB(_value, _string)) + 1;
          break;
        default:
          Print("Error: Wrong value type ", EnumToString(GetType()), "!");
          DebugBreak();
      }
    }

    for (unsigned int i = 0; i < _numChildren; ++i) _result += PTR_ATTRIB(_children[i], BinarySize());

    return _result;
  }

  /**
   * Overrides floating-point precision for this node and all the children.
   */
  void OverrideFloatingPointPrecision(int _fp_precision) {
    SerializerNodeParam* _value_param = GetValueParam();

    if (_value_param != NULL) {
      PTR_ATTRIB(_value_param, SetFloatingPointPrecision(_fp_precision));
    }

    for (unsigned int i = 0; i < _numChildren; ++i) {
      PTR_ATTRIB(_children[i], OverrideFloatingPointPrecision(_fp_precision));
    }
  }

  /**
   * Returns total number of children and their children inside this node.
   */
  unsigned int TotalNumChildren() {
    if (!IsContainer()) return 1;

    unsigned int _result = 0;

    for (unsigned int i = 0; i < _numChildren; ++i) _result += PTR_ATTRIB(_children[i], TotalNumChildren());

    return _result;
  }

  /**
   * Returns maximum number of children in the last "dimension".
   */
  unsigned int MaximumNumChildrenInDeepEnd() {
    unsigned int _result = 0, i;

    if (GetParent() == NULL) {
      for (i = 0; i < _numChildren; ++i) {
        if (IsObject())
          _result += PTR_ATTRIB(_children[i], MaximumNumChildrenInDeepEnd());
        else
          _result = MathMax(_result, PTR_ATTRIB(_children[i], MaximumNumChildrenInDeepEnd()));
      }

      return _result;
    }

    if (IsObject() || IsArray()) {
      for (i = 0; i < _numChildren; ++i) {
        _result += PTR_ATTRIB(_children[i], MaximumNumChildrenInDeepEnd());
      }
      return _result;
    }

    return 1;
  }

  /**
   * Returns maximum number of containers before the last "dimension".
   */
  unsigned int MaximumNumContainersInDeepEnd() {
    unsigned int _result = 1, _sum = 0;

    if (GetType() == SerializerNodeArrayItem || GetType() == SerializerNodeObjectProperty) {
      return 1;
    }

    for (unsigned int i = 0; i < _numChildren; ++i) {
      if (PTR_ATTRIB(_children[i], GetType()) == SerializerNodeArray ||
          PTR_ATTRIB(_children[i], GetType()) == SerializerNodeObject) {
        _sum += PTR_ATTRIB(_children[i], MaximumNumContainersInDeepEnd());
      }
    }

    return _result * _sum;
  }

  /**
   * Returns pointer to SerializerNodeParam holding the key or NULL.
   */
  SerializerNodeParam* GetKeyParam() { return _key; }

  /**
   * Returns pointer to SerializerNodeParam holding the value or NULL.
   */
  SerializerNodeParam* GetValueParam() { return _value; }

  /**
   * Returns parent node or NULL.
   */
  SerializerNode* GetParent() { return _parent; }

  /**
   * Returns next child node (increments index each time the method is called).
   */
  SerializerNode* GetNextChild() {
    if (_currentChildIndex >= _numChildren) return _children[_numChildren - 1];

    return _children[_currentChildIndex++];
  }

  /**
   * Returns type of the node (object, array, object property, array item).
   */
  SerializerNodeType GetType() { return _type; }

  /**
   * Sets type of the node. Should be used only internally.
   */
  void SetType(SerializerNodeType type) { _type = type; }

  /**
   * Adds child to this node.
   */
  void AddChild(SerializerNode* child) {
    if (_numChildren == ArraySize(_children)) ArrayResize(_children, _numChildren + 10);

    PTR_ATTRIB(child, _index) = (int)_numChildren;
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
  SerializerNode* GetChild(unsigned int index) { return index >= _numChildren ? NULL : _children[index]; }

  /**
   * Removes child with given index.
   */
  void RemoveChild(unsigned int index) {
    delete _children[index];

    for (unsigned int i = ArraySize(_children) - 2; i >= index; --i) {
      _children[i] = _children[i + 1];
    }
  }

  /**
   * Checks whether this node is last in its parent.
   */
  bool IsLast() {
    if (!_parent) return true;

    for (unsigned int i = 0; i < PTR_ATTRIB(_parent, NumChildren()); ++i) {
      if (PTR_ATTRIB(_parent, GetChild(i)) == THIS_PTR && i != PTR_ATTRIB(_parent, NumChildren() - 1)) return false;
    }

    return true;
  }

  /**
   * Serializes node and its children into string in generic format (JSON at now).
   */
  string ToString(bool trimWhitespaces = false, unsigned int indentSize = 2, unsigned int indent = 0) {
    string repr;
    string ident;

    if (!trimWhitespaces)
      for (unsigned int i = 0; i < indent * indentSize; ++i) ident += " ";

    repr += ident;

    if (GetKeyParam() != NULL && PTR_ATTRIB(GetKeyParam(), AsString(false, false)) != "")
      repr += PTR_ATTRIB(GetKeyParam(), AsString(false, true)) + ":" + (trimWhitespaces ? "" : " ");

    if (GetValueParam() != NULL) repr += PTR_ATTRIB(GetValueParam(), AsString(false, true));

    switch (GetType()) {
      case SerializerNodeObject:
        repr += string("{") + (trimWhitespaces ? "" : "\n");
        break;
      case SerializerNodeArray:
        repr += string("[") + (trimWhitespaces ? "" : "\n");
        break;
    }

    if (HasChildren()) {
      for (unsigned int j = 0; j < NumChildren(); ++j) {
        repr += PTR_ATTRIB(GetChild(j), ToString(trimWhitespaces, indentSize, indent + 1));
      }
    }

    switch (GetType()) {
      case SerializerNodeObject:
        repr += ident + "}";
        break;
      case SerializerNodeArray:
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

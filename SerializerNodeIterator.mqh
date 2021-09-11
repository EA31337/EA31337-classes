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
#ifndef JSON_ITERATOR_MQH
#define JSON_ITERATOR_MQH

#include "SerializerNode.mqh"

class SerializerNode;
class Serializer;

class SerializerNodeIterator {
 protected:
  unsigned int _index;
  SerializerNode* _collection;

 public:
  /**
   * Constructor.
   */
  SerializerNodeIterator(SerializerNode* collection = NULL) {
    _index = 0;
    _collection = collection;
  }

  /**
   * Constructor.
   */
  SerializerNodeIterator(const SerializerNodeIterator& r) {
    _index = r._index;
    _collection = r._collection;
  }

  /**
   * Returns current node or NULL.
   */
  SerializerNode* Node() { return !IsValid() ? NULL : PTR_ATTRIB(_collection, GetChild(_index));
  }

  /**
   * Returns current node index.
   */
  unsigned int Index() { return _index; }

  /**
   * Iterator incrementation operator.
   */
  void operator++(void) { ++_index; }

  /**
   * Checks whether iterator is still valid.
   */
  bool IsValid() { return _index < PTR_ATTRIB(_collection, NumChildren());
  }

  /**
   * Returns current's child key or empty string.
   */
  const string Key() { return !IsValid() ? "" : PTR_ATTRIB(PTR_ATTRIB(_collection, GetChild(_index)), Key());
  }

  /**
   * Checks whether current child has key.
   */
  bool HasKey() { return !IsValid() ? false : PTR_ATTRIB(PTR_ATTRIB(_collection, GetChild(_index)), HasKey());
  }

  /**
   * Checks whether current child is a container.
   */
  bool IsContainer() { return !IsValid() ? false : PTR_ATTRIB(PTR_ATTRIB(_collection, GetChild(_index)), IsContainer());
  }
};

template <typename X>
class SerializerIterator : public SerializerNodeIterator {
 protected:
  Serializer* _serializer;

 public:
  /**
   * Constructor.
   */
  SerializerIterator(Serializer* serializer = NULL, SerializerNode* collection = NULL)
      : SerializerNodeIterator(collection) {
    _serializer = serializer;
  }

  /**
   * Constructor.
   */
  SerializerIterator(const SerializerIterator& r) : SerializerNodeIterator(r) { _serializer = r._serializer; }

  /**
   * Returns next value or value by given key.
   */
  template <>
  X Value(string key = "") {
    X value;
    _serializer.Pass(_serializer, key, value);
    return value;
  }

  /**
   * Returns next object or object by given key.
   */
  template <>
  X Object(string key = "") {
    return Struct(key);
  }

  /**
   * Returns next structure or structure by given key.
   */
  template <>
  X Struct(string key = "") {
    X value;
    _serializer.PassStruct(_serializer, key, value);
    return value;
  }

  SerializerNodeType ParentNodeType() { return _collection.GetType(); }
};

#endif

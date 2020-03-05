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
#ifndef JSON_ITERATOR_MQH
#define JSON_ITERATOR_MQH

class JsonNode;
class JsonSerializer;

template<typename X>
class JsonIterator {
protected:

  unsigned int _index;
  JsonNode* _collection;
  JsonSerializer* _serializer;
  
public:
  
  /**
   * Constructor.
   */
  JsonIterator(JsonSerializer* serializer = NULL, JsonNode* collection = NULL) {
    _index = 0;
    _collection = collection;
    _serializer = serializer;
  }

  /**
   * Constructor.
   */
  JsonIterator(const JsonIterator& r) {
    _index = r._index;
    _collection = r._collection;
    _serializer = r._serializer;
  }

  /**
   * Iterator incrementation operator.
   */
  void operator++(void) {
    ++_index;
  }
  
  /**
   * Checks whether iterator is still valid.
   */
  bool IsValid() {
    return _index < _collection.NumChildren();
  }
  
  /**
   * Returns current's child key or empty string.
   */
  const string Key() {
    return !IsValid() ? "" : _collection.GetChild(_index).Key();
  }

  /**
   * Checks whether current child has key.
   */
  bool HasKey() {
    return !IsValid() ? false : _collection.GetChild(_index).HasKey();
  }

  /**
   * Returns next value or value by given key.
   */
  template<>
  X Value(string key = "") {
    X value;
    _serializer.Pass(_serializer, key, value);
    return value;
  }

  /**
   * Returns next object or object by given key.
   */
  template<>
  X Object(string key = "") {
    return Struct(key);
  }

  /**
   * Returns next structure or structure by given key.
   */
  template<>
  X Struct(string key = "") {
    X value;  
    _serializer.PassStruct(_serializer, key, value);
    return value;
  }
  
  JsonNodeType ParentNodeType() {
    return _collection.GetType();
  }
};

#endif
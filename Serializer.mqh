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
#ifndef SERIALIZER_MQH
#define SERIALIZER_MQH

// Includes.
#include "Convert.mqh"
#include "Serializer.define.h"
#include "Serializer.enum.h"
#include "SerializerNode.mqh"
#include "SerializerNodeIterator.mqh"
#include "SerializerNodeParam.mqh"
#include "Terminal.define.h"

#define SERIALIZER_DEFAULT_FP_PRECISION 8

// Forward declarations.
template <typename X>
class SerializerIterator;

class Serializer {
 protected:
  SerializerNode* _node;
  SerializerNode* _root;
  SerializerMode _mode;
  bool _root_node_ownership;
  bool _skip_hidden;
  string _single_value_name;

  unsigned int _flags;

  // Floating-point precision.
  int fp_precision;

 public:
  /**
   * Constructor.
   */
  Serializer(SerializerNode* node, SerializerMode mode, int flags = 0) : _node(node), _mode(mode), _flags(flags) {
    _root = node;
    _root_node_ownership = true;
    fp_precision = SERIALIZER_DEFAULT_FP_PRECISION;
    if (_flags == 0) {
      // Preventing flags misuse.
      _flags = SERIALIZER_FLAG_INCLUDE_ALL;
    }
  }

  /**
   * Destructor.
   */
  ~Serializer() {
    if (_root_node_ownership && _root != NULL) delete _root;
  }

  template <typename X>
  SerializerIterator<X> Begin() {
    SerializerIterator<X> iter(THIS_PTR, _node);
    return iter;
  }

  void FreeRootNodeOwnership() { _root_node_ownership = false; }

  /**
   * Enters object or array for a given key or just iterates over objects/array during unserializing.
   */
  bool Enter(SerializerEnterMode mode = SerializerEnterObject, string key = "") {
    if (IsWriting()) {
#ifdef __MQL__
      SerializerNodeParam* nameParam = (key != "" && key != "") ? SerializerNodeParam::FromString(key) : NULL;
#else
      SerializerNodeParam* nameParam = (key != "") ? SerializerNodeParam::FromString(key) : NULL;
#endif

      // When writing, we need to make parent->child structure. It is not
      // required when reading, because structure is full done by parsing the
      // string.
      _node = new SerializerNode(mode == SerializerEnterObject ? SerializerNodeObject : SerializerNodeArray, _node,
                                 nameParam);

      if (PTR_ATTRIB(_node, GetParent()) != NULL) PTR_ATTRIB(PTR_ATTRIB(_node, GetParent()), AddChild(_node));

      if (_root == NULL) _root = _node;
    } else {
      if (_node == NULL) {
        _node = _root;
        return true;
      }

      SerializerNode* child;

      if (key != "") {
        // We need to enter object that matches given key.
        for (unsigned int i = 0; i < PTR_ATTRIB(_node, NumChildren()); ++i) {
          child = PTR_ATTRIB(_node, GetChild(i));
          if (PTR_ATTRIB(PTR_ATTRIB(child, GetKeyParam()), AsString(false, false)) == key) {
            _node = child;
            return true;
          }
        }
        // We didn't enter into child node.
        return false;
      } else if (key == "") {
        _node = PTR_ATTRIB(_node, GetNextChild());
      }
    }
    return true;
  }

  /**
   * Leaves current object/array. Used in custom Serialize() method.
   */
  void Leave() { _node = PTR_ATTRIB(_node, GetParent()); }

  /**
   * Checks whether we are in serialization process. Used in custom Serialize() method.
   */
  bool IsWriting() { return _mode == Serialize || bool(_flags & SERIALIZER_FLAG_SIMULATE_SERIALIZE); }

  /**
   * Checks whether we are in unserialization process. Used in custom Serialize() method.
   */
  bool IsReading() { return !IsWriting(); }

  /**
   * Checks whether current node is inside array. Used in custom Serialize() method.
   */
  bool IsArray() {
    return _mode == Unserialize && _node != NULL && PTR_ATTRIB(_node, GetType()) == SerializerNodeArray;
  }

  /**
   * Returns number of array items inside current array.
   */
  unsigned int NumArrayItems() { return _node != NULL ? PTR_ATTRIB(_node, NumChildren()) : 0; }

  /**
   * Checks whether current node is an object. Used in custom Serialize() method.
   */
  bool IsObject() {
    return _mode == Unserialize && _node != NULL && PTR_ATTRIB(_node, GetType()) == SerializerNodeObject;
  }

  /**
   * Returns number of child nodes.
   */
  unsigned int NumChildren() { return _node ? PTR_ATTRIB(_node, NumChildren()) : 0; }

  /**
   * Returns root node or NULL. Could be used after unserialization.
   */
  SerializerNode* GetRoot() { return _root; }

  /**
   * Returns child node for a given index or NULL.
   */
  SerializerNode* GetChild(unsigned int index) { return _node ? PTR_ATTRIB(_node, GetChild(index)) : NULL; }

  /**
   * Returns floating-point precision.
   */
  int GetFloatingPointPrecision() { return fp_precision; }

  /**
   * Sets floating-point precision.
   */
  void SetPrecision(int _fp_precision) { fp_precision = _fp_precision; }

  /**
   * Serializes or unserializes object.
   */
  template <typename T, typename V>
  void PassObject(T& self, string name, V& value, unsigned int flags = SERIALIZER_FIELD_FLAG_DEFAULT) {
    PassStruct(self, name, value, flags);
  }

  /**
   * Serializes or unserializes object that acts as a value.
   */
  template <typename T, typename V>
  void PassValueObject(T& self, string name, V& value, unsigned int flags = SERIALIZER_FIELD_FLAG_DEFAULT) {
    if (_mode == Serialize) {
      value.Serialize(this);
      fp_precision = SERIALIZER_DEFAULT_FP_PRECISION;

      SerializerNode* obj = _node PTR_DEREF GetChild(PTR_ATTRIB(_node, NumChildren()) - 1);

      obj PTR_DEREF SetKey(name);
    } else {
      _single_value_name = name;
      value.Serialize(this);
    }
  }

  bool IsFieldVisible(int serializer_flags, int field_flags) {
    // Is field visible? Such field cannot be exluded in anyway.
    if ((field_flags & SERIALIZER_FIELD_FLAG_VISIBLE) == SERIALIZER_FIELD_FLAG_VISIBLE) {
      return true;
    }

    if ((field_flags & SERIALIZER_FIELD_FLAG_HIDDEN) == SERIALIZER_FIELD_FLAG_HIDDEN) {
      if ((serializer_flags & SERIALIZER_FLAG_SKIP_HIDDEN) != SERIALIZER_FLAG_SKIP_HIDDEN) {
        // Field is hidden, but serializer has no SERIALIZER_FLAG_SKIP_HIDDEN flag set, so field will be serialized.
        return true;
      }
    }

    // Is field hidden?
    if ((serializer_flags & SERIALIZER_FLAG_SKIP_HIDDEN) == SERIALIZER_FLAG_SKIP_HIDDEN) {
      if ((field_flags & SERIALIZER_FIELD_FLAG_HIDDEN) == SERIALIZER_FIELD_FLAG_HIDDEN) {
        return false;
      }
    }

    // Is field default?
    if ((serializer_flags & SERIALIZER_FLAG_EXCLUDE_DEFAULT) == SERIALIZER_FLAG_EXCLUDE_DEFAULT) {
      if ((field_flags & SERIALIZER_FIELD_FLAG_DEFAULT) == SERIALIZER_FIELD_FLAG_DEFAULT) {
        if ((serializer_flags & SERIALIZER_FLAG_INCLUDE_DEFAULT) == SERIALIZER_FLAG_INCLUDE_DEFAULT) {
          // Field was excluded by e.g., dynamic or feature type, but included explicitly by flag.
          return true;
        } else {
          // Field was excluded by e.g., dynamic or feature type, but not included again explicitly by flag.
          return false;
        }
      }
    }

    // Is field dynamic?
    if ((serializer_flags & SERIALIZER_FLAG_INCLUDE_DYNAMIC) == SERIALIZER_FLAG_INCLUDE_DYNAMIC) {
      if ((field_flags & SERIALIZER_FIELD_FLAG_DYNAMIC) == SERIALIZER_FIELD_FLAG_DYNAMIC) {
        return true;
      }
    }

    // Is field a feature?
    if ((serializer_flags & SERIALIZER_FLAG_INCLUDE_FEATURE) == SERIALIZER_FLAG_INCLUDE_FEATURE) {
      if ((field_flags & SERIALIZER_FIELD_FLAG_FEATURE) == SERIALIZER_FIELD_FLAG_FEATURE) {
        return true;
      }
    }

    return false;
  }

  /**
   * Serializes or unserializes structure.
   */
  template <typename T, typename V>
  void PassStruct(T& self, string name, V& value, unsigned int flags = SERIALIZER_FIELD_FLAG_DEFAULT) {
    if (_mode == Serialize) {
      if (!IsFieldVisible(_flags, flags)) return;
    }

    // Entering object or array. value's Serialize() method should check if it's array by s.IsArray().
    // Note that binary serializer shouldn't rely on the property names and just skip entering/leaving at all.
    // Entering a root node does nothing, because we would end up going to first child node, which we don't want to do.

    if (_mode == Serialize || (_mode == Unserialize && name != "")) {
      Enter(SerializerEnterObject, name);
    }

    SerializerNodeType newType = value.Serialize(THIS_REF);
    fp_precision = SERIALIZER_DEFAULT_FP_PRECISION;

    // value's Serialize() method returns which type of node it should be treated as.
    if (newType != SerializerNodeUnknown) PTR_ATTRIB(_node, SetType(newType));

    // Goes to the sibling node. In other words, it goes to the parent's next node.
    if (_mode == Serialize || (_mode == Unserialize && name != "")) {
      Leave();
    }
  }

  void Next() {
    if (PTR_ATTRIB(_node, GetParent()) == NULL) {
      return;
    }

    _node = PTR_ATTRIB(PTR_ATTRIB(_node, GetParent()), GetNextChild());
  }

  /**
   * Serializes or unserializes enum value (stores it as integer).
   */
  template <typename T, typename V>
  void PassEnum(T& self, string name, V& value, unsigned int flags = SERIALIZER_FIELD_FLAG_DEFAULT) {
    int enumValue;
    if (_mode == Serialize) {
      if (!IsFieldVisible(_flags, flags)) {
        return;
      }

      enumValue = (int)value;
      Pass(self, name, enumValue, flags);
    } else {
      Pass(self, name, enumValue, flags);
      value = (V)enumValue;
    }
  }

  template <typename T, typename VT>
  void PassArray(T& self, string name, ARRAY_REF(VT, array), unsigned int flags = SERIALIZER_FIELD_FLAG_DEFAULT) {
    int num_items;

    if (_mode == Serialize) {
      if (!IsFieldVisible(_flags, flags)) {
        // Skipping prematurely instead of creating object by new.
        return;
      }
    }

    if (_mode == Serialize) {
      if (Enter(SerializerEnterArray, name)) {
        num_items = ArraySize(array);
        for (int i = 0; i < num_items; ++i) {
          PassStruct(THIS_REF, "", array[i]);
        }
        Leave();
      }
    } else {
      if (Enter(SerializerEnterArray, name)) {
        SerializerNode* parent = _node;

        num_items = (int)NumArrayItems();
        ArrayResize(array, num_items);

        for (SerializerIterator<VT> si = Begin<VT>(); si.IsValid(); ++si) {
          if (si.HasKey()) {
            // Should not happen.
          } else {
            _node = parent PTR_DEREF GetChild(si.Index());
            array[si.Index()] = Struct<VT>(si.Key());
          }
        }

        Leave();
      }
    }
  }

  /**
   * Serializes or unserializes pointer to object.
   */
  template <typename T, typename V>
  void Pass(T& self, string name, V*& value, unsigned int flags = SERIALIZER_FIELD_FLAG_DEFAULT) {
    if (_mode == Serialize) {
      if (!IsFieldVisible(_flags, flags)) {
        return;
      }

      PassObject(self, name, value, flags);
    } else {
      V* newborn = new V();

      PassObject(self, name, newborn, flags);

      value = newborn;
    }
  }

  /**
   * Serializes or unserializes simple value.
   */
  template <typename T, typename V>
  SerializerNode* Pass(T& self, string name, V& value, unsigned int flags = SERIALIZER_FIELD_FLAG_DEFAULT) {
    SerializerNode* child = NULL;
    bool _skip_push = (_flags & SERIALIZER_FLAG_SKIP_PUSH) == SERIALIZER_FLAG_SKIP_PUSH;

    if (_mode == Serialize) {
      if (!IsFieldVisible(_flags, flags)) {
        return NULL;
      }

      SerializerNodeParam* key = name != "" ? SerializerNodeParam::FromString(name) : NULL;
      SerializerNodeParam* val = SerializerNodeParam::FromValue(value);

      if (val == NULL) {
        Print("Error: Value to SerializerNodeParam conversion failed!");
        DebugBreak();
      }

      PTR_ATTRIB(val, SetFloatingPointPrecision(GetFloatingPointPrecision()));
      child = new SerializerNode(SerializerNodeObjectProperty, _node, key, val, flags);

      if (!_skip_push) {
        PTR_ATTRIB(_node, AddChild(child));
      }

      return child;
    } else {
      if (name == "") {
        // Determining name from Serializer's SingleValueName().
        name = _single_value_name;
      }

      for (unsigned int i = 0; i < PTR_ATTRIB(_node, NumChildren()); ++i) {
        child = PTR_ATTRIB(_node, GetChild(i));
        if (PTR_ATTRIB(PTR_ATTRIB(child, GetKeyParam()), AsString(false, false)) == name) {
          SerializerNodeParamType paramType = PTR_ATTRIB(PTR_ATTRIB(child, GetValueParam()), GetType());
          switch (paramType) {
            case SerializerNodeParamBool:
              Convert::BoolToType(PTR_ATTRIB(PTR_ATTRIB(child, GetValueParam()), _integral)._bool, value);
              break;
            case SerializerNodeParamLong:
              Convert::LongToType(PTR_ATTRIB(PTR_ATTRIB(child, GetValueParam()), _integral)._long, value);
              break;
            case SerializerNodeParamDouble:
              Convert::DoubleToType(PTR_ATTRIB(PTR_ATTRIB(child, GetValueParam()), _integral)._double, value);
              break;
            case SerializerNodeParamString:
              // There shouldn't be a conversion to int!
              Convert::StringToType(PTR_ATTRIB(PTR_ATTRIB(child, GetValueParam()), _string), value);
              break;
            default:
              Print("Error: Wrong param type ", paramType, "!");
              SetUserError(ERR_INVALID_PARAMETER);
              DebugBreak();
          }

          return NULL;
        }
      }
    }

    return NULL;
  }

  /**
   * Returns next value or value by given key.
   */
  template <typename X>
  X Value(string key = "") {
    X value;
    Pass(THIS_REF, key, value);
    return value;
  }

  /**
   * Returns next structure or structure by given key.
   */
  template <typename X>
  X Struct(string key = "") {
    X value;
    PassStruct(THIS_REF, key, value);
    return value;
  }

  /**
   * Returns next object or object by given key.
   */
  template <typename X>
  X Object(string key = "") {
    return Struct<X>(key);
  }
};

#endif  // End: SERIALIZER_MQH

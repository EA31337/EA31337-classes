//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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
#ifndef COLLECTION_MQH
#define COLLECTION_MQH

// Includes.
#include "../Object.mqh"

/**
 * Class to deal with collection of objects.
 */
template <typename X>
class Collection {
 protected:
  // Variables.
  string name;
  int index;
  ARRAY(Ref<X>, data);

 public:
  /**
   * Class constructor.
   */
  Collection() {}
  Collection(string _name) : name(_name) {}
  Collection(void *_obj) { Add(_obj); }
  ~Collection() {}

  /* Setters */

  /**
   * Add the object into the collection.
   */
  X *Add(X *_object) {
    int _size = ArraySize(data);
    int _count = ArrayResize(data, _size + 1, 100);
    if (_count > 0) {
      data[_size] = _object;
    } else {
      PrintFormat("ERROR at %s(): Cannot resize array!", __FUNCTION__);
    }
    return _count > 0 ? _object : NULL;
  }

  /* Getters */

  /**
   * Returns pointer to the collection item.
   */
  X *Get(X *_object) {
    if (_object != NULL) {
      int i;
      for (i = 0; i < ArraySize(data); i++) {
        if (_object == data[i].Ptr()) {
          return data[i].Ptr();
        }
      }
      return Add(_object);
    }
    return NULL;
  }

  /**
   * Returns pointer to the first valid object.
   */
  void *GetFirstItem() {
    int i;
    for (i = 0; i < ArraySize(data); i++) {
      if (data[i].Ptr() != NULL) {
        index = i;
        return data[i].Ptr();
      }
    }
    return NULL;
  }

  /**
   * Returns pointer to the current object.
   */
  X *GetCurrentItem() { return data[index].Ptr() != NULL ? data[index].Ptr() : NULL; }

  /**
   * Returns ID of the current object.
   */
  int GetCurrentIndex() { return index; }

  /**
   * Returns pointer to the next valid object.
   */
  X *GetNextItem() {
    int i;
    for (i = ++index; i < ArraySize(data); i++) {
      if (data[i].Ptr() != NULL) {
        index = i;
        return data[i].Ptr();
      }
    }
    return NULL;
  }

  /**
   * Returns pointer to the last valid object.
   */
  X *GetLastItem() {
    int i;
    for (i = ArraySize(data) - 1; i >= 0; i--) {
      if (data[i].Ptr() != NULL) {
        return data[i].Ptr();
      }
    }
    return NULL;
  }

  /**
   * Returns object item by array index.
   */
  X *GetByIndex(int _index) { return data[_index].Ptr(); }

  /**
   * Returns object item by object id.
   */
  X *GetById(long _id) {
    int i;
    X *_object = GetSize() > 0 ? data[0].Ptr() : NULL;
    for (i = 0; i < ArraySize(data); i++) {
      if (data[i].Ptr().GetId() == _id) {
        _object = data[i].Ptr();
      }
    }
    return _object;
  }

  /**
   * Returns pointer to the collection item with the lowest weight.
   */
  X *GetLowest() {
    int i;
    X *_object = GetSize() > 0 ? data[0].Ptr() : NULL;
    for (i = 0; i < ArraySize(data); i++) {
      double _weight = data[i].Ptr().GetWeight();
      if (_weight < _object.GetWeight()) {
        _object = data[i].Ptr();
      }
    }
    return _object;
  }

  /**
   * Returns pointer to the collection item with the highest weight.
   */
  X *GetHighest() {
    int i;
    X *_object = GetSize() > 0 ? data[0].Ptr() : NULL;
    for (i = 0; i < ArraySize(data); i++) {
      double _weight = data[i].Ptr().GetWeight();
      if (_weight > _object.GetWeight()) {
        _object = data[i].Ptr();
      }
    }
    return _object;
  }

  /**
   * Returns name of the collection.
   */
  string GetName() { return name; }

  /**
   * Returns size of the collection.
   */
  int GetSize() { return ArraySize(data); }

  /* Printers */

  /**
   * Fetch object textual data by calling each ToString() method.
   */
  string ToString(double _min_weight = 0, string _dlm = ";") {
    int i;
    string _out = name + ": ";
    for (i = 0; i < ArraySize(data); i++) {
      if (data[i].Ptr() != NULL) {
        if (data[i].Ptr().GetWeight() >= _min_weight) {
          _out += data[i].Ptr().ToString() + _dlm;
        }
      }
    }
    return _out;
  }
};
#endif  // COLLECTION_MQH

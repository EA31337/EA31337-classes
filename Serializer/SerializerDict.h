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
#ifndef SERIALIZER_DICT_MQH
#define SERIALIZER_DICT_MQH

// Includes.
#include "SerializerNode.h"

enum ENUM_SERIALIZER_DICT_FLAGS {};

class SerializerDict {
 public:
  template <typename D, typename V>
  static void Extract(SerializerNode* _root, D& _dict, unsigned int extractor_flags = 0) {
    if (_root PTR_DEREF IsContainer()) {
      for (unsigned int _data_entry_idx = 0; _data_entry_idx < _root PTR_DEREF NumChildren(); ++_data_entry_idx) {
        Extract<D, V>(_root PTR_DEREF GetChild(_data_entry_idx), _dict, extractor_flags);
      }
    } else {
      SerializerNodeParam* _value_param = _root PTR_DEREF GetValueParam();

      V _aux = (V)NULL;

      _dict.Push(_value_param PTR_DEREF ConvertTo(_aux));
    }
  }
};

#endif

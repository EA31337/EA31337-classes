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
#ifndef SERIALIZER_CSV_MQH
#define SERIALIZER_CSV_MQH

// Includes.
#include "DictBase.mqh"
#include "SerializerConverter.mqh"
#include "SerializerNode.mqh"
#include "Serializer.mqh"
#include "Object.mqh"

class Log;

class SerializerCsv {
 public:
 
  static SerializerNode* Parse(string _text) {
    return NULL;
  }
 
  static string Stringify(SerializerNode* _root) {
    return "<csv data>";
  }

};

#endif

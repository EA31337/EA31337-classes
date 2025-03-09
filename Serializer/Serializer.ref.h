//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
#ifndef __MQL__
#pragma once
#endif

#include "../Refs.struct.h"

template <typename T>
#ifdef __MQL__
template <>
SerializerNodeType Ref::Serialize(Serializer& s) {
#else
SerializerNodeType Ref<T>::Serialize(Serializer& s) {
#endif
  if (s.IsWriting()) {
    if (Ptr() == nullptr) {
      // Missing object!
      Alert("Error: Ref<T> serialization is supported only for non-null references!");
      DebugBreak();
      return SerializerNodeObject;
    }
    return Ptr() PTR_DEREF Serialize(s);
  } else {
    // Reading.
    return Ptr() PTR_DEREF Serialize(s);
  }
}

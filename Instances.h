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

/**
 * @file
 * Collects information about class instances.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Prevents processing this includes file multiple times.
#ifndef INSTANCES_H
#define INSTANCES_H

#include "Storage/Dict/Dict.h"
#include "Util.h"

template <typename T>
class Instances {
 public:
  static T* instances[];
  Instances(T* _self) { Util::ArrayPush(instances, _self); }

  ~Instances() {
    // Util::ArrayRemove(instances, &this);
  }
};

template <typename T>
T* Instances<T>::instances[];

#endif  // INSTANCES_MQH

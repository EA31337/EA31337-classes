//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Includes TaskCondition's structures serialization methods.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "TaskCondition.struct.h"

SerializerNodeType TaskConditionEntry::Serialize(Serializer &s) {
  s.Pass(THIS_REF, "flags", flags);
  s.Pass(THIS_REF, "id", id);
  s.Pass(THIS_REF, "last_check", last_check);
  s.Pass(THIS_REF, "last_success", last_success);
  s.Pass(THIS_REF, "tries", tries);
  s.PassEnum(THIS_REF, "freq", freq);
  s.PassArray(THIS_REF, "args", args);
  return SerializerNodeObject;
}

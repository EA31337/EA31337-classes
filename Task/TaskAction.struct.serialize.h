//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
 * Includes TaskAction's structure serialization methods.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes.
#include "../Serializer/Serializer.h"
#include "TaskAction.struct.h"

SerializerNodeType TaskActionEntry::Serialize(Serializer &s) {
  s.Pass(THIS_REF, "flags", flags);
  s.Pass(THIS_REF, "id", id);
  s.Pass(THIS_REF, "time_last_run", time_last_run);
  s.Pass(THIS_REF, "tries", tries);
  s.PassEnum(THIS_REF, "freq", freq);
  s.PassArray(THIS_REF, "args", args);
  return SerializerNodeObject;
}

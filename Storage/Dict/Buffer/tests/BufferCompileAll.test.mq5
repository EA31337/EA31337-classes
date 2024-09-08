//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2024, EA31337 Ltd |
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
 * Test compilation of all Buffer class files.
 */

// Includes.
#include "../../../../Test.mqh"
#include "../Buffer.h"
#include "../BufferCandle.h"
#include "../BufferFXT.h"
#include "../BufferStruct.h"
#include "../BufferTick.h"

/**
 * Implements Init event handler.
 */
int OnInit() { return (_LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED); }

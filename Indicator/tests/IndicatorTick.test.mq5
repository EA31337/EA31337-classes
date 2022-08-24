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
 * Test functionality of IndicatorTick class.
 */

// Includes.
#include "../../Test.mqh"
#include "../IndicatorTick.h"
#include "classes/IndicatorTickDummy.h"

/**
 * Implements OnInit().
 */
int OnInit() {
  IndicatorTickDummy _indi_tick(_Symbol);
  long _time = 1;
  for (double _price = 0.1; _price <= 2.0; _price += 0.1) {
    MqlTick _tick;
    _tick.time = (datetime)_time++;
    _tick.ask = _price;
    _tick.bid = _price;
    _indi_tick.SetTick(_tick, _tick.time);
  }
  // Print(_indi_tick.ToString());
  return (INIT_SUCCEEDED);
}

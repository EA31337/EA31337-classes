//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
   This file is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of Strategies class.
 */

// Includes.
#include "../Strategies.mqh"

// Properties.
#property strict

/**
 * Implements OnInit().
 */
int OnInit() {
  TradeParams trade_params;
  trade_params.slippage = 50;
  trade_params.account = new Account();
  trade_params.chart = new Chart(PERIOD_CURRENT, _Symbol);

  StrategiesParams params;
  params.tf_filter = 0;
  params.magic_no_start = 31337;

  Strategies *strategies = new Strategies(params, trade_params);
  strategies.Logger().Info("Strategies loaded successfully!");
  return (INIT_SUCCEEDED);
}

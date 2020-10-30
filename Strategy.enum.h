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

/**
 * @file
 * Includes Strategy's enums.
 */

enum ENUM_OPEN_METHOD {
  OPEN_METHOD1 = 1,      // Method #1.
  OPEN_METHOD2 = 2,      // Method #2.
  OPEN_METHOD3 = 4,      // Method #3.
  OPEN_METHOD4 = 8,      // Method #4.
  OPEN_METHOD5 = 16,     // Method #5.
  OPEN_METHOD6 = 32,     // Method #6.
  OPEN_METHOD7 = 64,     // Method #7.
  OPEN_METHOD8 = 128,    // Method #8.
  OPEN_METHOD9 = 256,    // Method #9.
  OPEN_METHOD10 = 512,   // Method #10.
  OPEN_METHOD11 = 1024,  // Method #11.
  OPEN_METHOD12 = 2048   // Method #12.
};

enum ENUM_STRATEGY_STATS_PERIOD {
  EA_STATS_DAILY,
  EA_STATS_WEEKLY,
  EA_STATS_MONTHLY,
  EA_STATS_TOTAL,
  FINAL_ENUM_STRATEGY_STATS_PERIOD
};

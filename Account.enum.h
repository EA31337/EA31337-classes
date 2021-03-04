//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2021, 31337 Investments Ltd |
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
 * Includes Account's enums.
 */

/** 
  *Enums
  */
enum ENUM_ACC_STAT_VALUE {
  ACC_BALANCE = 0,
  ACC_CREDIT = 1,
  ACC_EQUITY = 2,
  ACC_PROFIT = 3,
  ACC_MARGIN_USED = 4,
  ACC_MARGIN_FREE = 5,
  FINAL_ENUM_ACC_STAT_VALUE = 6
};

/** 
  * enum 
  */
enum ENUM_ACC_STAT_PERIOD { ACC_DAILY = 0, ACC_WEEKLY = 1, ACC_MONTHLY = 2, FINAL_ENUM_ACC_STAT_PERIOD = 3 };

/** 
  * enum 
  */
enum ENUM_ACC_STAT_TYPE { ACC_VALUE_MIN = 0, ACC_VALUE_MAX = 1, ACC_VALUE_AVG = 2, FINAL_ENUM_ACC_STAT_TYPE = 3 };

/** 
  * enum 
  */
enum ENUM_ACC_STAT_INDEX { ACC_VALUE_CURR = 0, ACC_VALUE_PREV = 1, FINAL_ENUM_ACC_STAT_INDEX = 2 };

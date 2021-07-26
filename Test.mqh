//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
 * Provides base functionality for testing purposes.
 */

// Define an assert macros.
#define assertTrueOrFail(cond, msg)                                                         \
  if (!(cond)) {                                                                            \
    Alert(msg + " - Assert fail on " + #cond + " in " + __FILE__ + ":" + (string)__LINE__); \
    return (INIT_FAILED);                                                                   \
  }

#define assertEqualOrFail(current, expected, msg)                             \
  if ((current) != (expected)) {                                              \
    Alert(msg + " - Assert fail. Expected ", expected, ", but got ", current, \
          " in " + __FILE__ + ":" + (string)__LINE__);                        \
    return (INIT_FAILED);                                                     \
  }

#define assertFalseOrFail(cond, msg)                                                        \
  if ((cond)) {                                                                             \
    Alert(msg + " - Assert fail on " + #cond + " in " + __FILE__ + ":" + (string)__LINE__); \
    return (INIT_FAILED);                                                                   \
  }

#define assertTrueOrReturn(cond, msg, ret)                                                  \
  if (!(cond)) {                                                                            \
    Alert(msg + " - Assert fail on " + #cond + " in " + __FILE__ + ":" + (string)__LINE__); \
    return (ret);                                                                           \
  }

#define assertTrueOrReturnFalse(cond, msg)                                                  \
  if (!(cond)) {                                                                            \
    Alert(msg + " - Assert fail on " + #cond + " in " + __FILE__ + ":" + (string)__LINE__); \
    return (false);                                                                         \
  }

#define assertFalseOrReturn(cond, msg, ret)                                                 \
  if ((cond)) {                                                                             \
    Alert(msg + " - Assert fail on " + #cond + " in " + __FILE__ + ":" + (string)__LINE__); \
    return (ret);                                                                           \
  }

#define assertTrueOrExit(cond, msg)                                                         \
  if (!(cond)) {                                                                            \
    Alert(msg + " - Assert fail on " + #cond + " in " + __FILE__ + ":" + (string)__LINE__); \
    ExpertRemove();                                                                         \
  }

#define assertFalseOrExit(cond, msg)                                                        \
  if ((cond)) {                                                                             \
    Alert(msg + " - Assert fail on " + #cond + " in " + __FILE__ + ":" + (string)__LINE__); \
    ExpertRemove();                                                                         \
  }

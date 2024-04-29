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
 * Flags manipulation helper.
 */
template <typename T>
struct Flags {
  // Bit-based value.
  unsigned T value;

  /**
   * Constructor.
   */
  Flags(T _value = 0) : value(_value) {}

  /**
   * Adds given flag to the current value.
   */
  void AddFlag(T _flag) {
    if ((_flag & (_flag - 1)) != 0) {
      Print("WARNING: Please use Flags::AddFlags() when adding multiple flags!");
      DebugBreak();
    }

    value |= _flag;
  }

  /**
   * Adds multiple flags to the current value.
   */
  void AddFlags(T _flags) {
    if ((_flags & (_flags - 1)) == 0) {
      Print("WARNING: Please use Flags::AddFlag() when adding a single flag!");
      DebugBreak();
    }

    value |= _flags;
  }

  /**
   * Clears given flag or multiple flags from the current value.
   */
  void ClearFlags(T _flags) { value &= ~_flags; }

  /**
   * Checks whether current value has given flag. (Same as HasAllFlags()).
   */
  bool HasFlag(T _flag) {
    if ((_flag & (_flag - 1)) != 0) {
      Print("WARNING: Please use Flags::HasFlags() when checking for multiple flags!");
      DebugBreak();
    }

    return (value & _flag) == _flag;
  }

  /**
   * Checks whether current value has all given flags.
   */
  bool HasAllFlags(T _flags) {
    if ((_flags & (_flags - 1)) == 0) {
      Print("WARNING: Please use Flags::HasFlag() when checking for a single flag!");
      DebugBreak();
    }

    return (value & _flags) == _flags;
  }

  /**
   * Checks whether current value has any of the given flags.
   */
  bool HasAnyFlag(T _flags) {
    if ((_flags & (_flags - 1)) == 0) {
      Print("WARNING: Please use Flags::HasFlag() when checking for a single flag!");
      DebugBreak();
    }

    return (value & _flags) != 0;
  }

  /**
   * Clears current value.
   */
  void Clear() { value = 0; }
};

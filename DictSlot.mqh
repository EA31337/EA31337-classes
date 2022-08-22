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

// Prevents processing this includes file for the second time.
#ifndef DICT_SLOT_MQH
#define DICT_SLOT_MQH

enum DICT_SLOT_FLAGS { DICT_SLOT_INVALID = 1, DICT_SLOT_HAS_KEY = 2, DICT_SLOT_IS_USED = 4, DICT_SLOT_WAS_USED = 8 };

/**
 * Represents a single item in the hash table.
 */
template <typename K, typename V>
class DictSlot {
 public:
  unsigned char _flags;
  K key;    // Key used to store value.
  V value;  // Value stored.

  static const DictSlot Invalid;

  DictSlot(unsigned char flags = 0) : _flags(flags) {}

  bool IsValid() { return !bool(_flags & DICT_SLOT_INVALID); }

  bool HasKey() { return bool(_flags & DICT_SLOT_HAS_KEY); }

  bool IsUsed() { return bool(_flags & DICT_SLOT_IS_USED); }

  bool WasUsed() { return bool(_flags & DICT_SLOT_WAS_USED); }

  void SetFlags(unsigned char flags) { _flags = flags; }

  void AddFlags(unsigned char flags) { _flags |= flags; }

  void RemoveFlags(unsigned char flags) { _flags &= (unsigned char)~flags; }
};

#endif  // DICT_SLOT_MQH

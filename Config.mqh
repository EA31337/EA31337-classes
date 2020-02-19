//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
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
 * Implements class for storing, importing and exporting configuration.
 */

// Prevents processing this includes file for the second time.
#ifndef CONFIG_MQH
#define CONFIG_MQH

// Includes.
#include "Dict.mqh"
#include "File.mqh"

class ConfigEntry {
 public:
  MqlParam value;
};

class Config : public DictObject<string, ConfigEntry> {
 private:
 protected:
  File *file;

 public:
  /**
   * Class constructor.
   */
  Config(bool _use_file = false) {
    if (_use_file) {
      file = new File();
    }
  }

  /* File methods */

  /**
   * Loads config from the file.
   */
  bool LoadFromFile() { return false; }

  /**
   * Save config into the file.
   */
  bool SaveToFile() { return false; }

  /* Printers methods */

  /**
   * Returns config in plain format.
   */
  string ToJSON() { return "{}"; }

  /**
   * Returns config in plain format.
   */
  string ToString() { return ""; }
};
#endif  // CONFIG_MQH

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

// Includes.
#include "SymbolInfo.mqh"
#include "Terminal.mqh"

/**
 * Class to provide functions to work with the strategy tester.
 */
class Tester : public Terminal {

  public:

    /**
     * Check whether spread is valid.
     */
    static bool ValidSpread(string _symbol = NULL, bool verbose = true) {
      uint _symbol_spread = SymbolInfo::GetSpread(_symbol);
      uint _real_spread = SymbolInfo::GetRealSpread(_symbol);
      double _lot_step = SymbolInfo::GetVolumeStep(_symbol);
      uint _digits = SymbolInfo::GetDigits(_symbol);
      if (_real_spread == 0 || _symbol_spread != _real_spread) {
        if (verbose) {
          PrintFormat("Reported spread: %d pts", _symbol_spread);
          PrintFormat("Real spread    : %d pts", _real_spread);
          PrintFormat("Ask/Bid        : %g/%g", SymbolInfo::GetAsk(_symbol), SymbolInfo::GetBid(_symbol));
          PrintFormat("Symbol digits  : %g", SymbolInfo::GetDigits(_symbol));
          PrintFormat("Lot step       : %g", _lot_step);
          PrintFormat("Error: Spread is not valid, it's %d!", _real_spread);
        }
        return (false);
      }
      return (true);
    }

    /**
     * Check whether lot step is valid.
     */
    static bool ValidLotstep(string _symbol = NULL, bool verbose = true) {
      uint _symbol_spread = SymbolInfo::GetSpread(_symbol);
      uint _real_spread = SymbolInfo::GetRealSpread(_symbol);
      double _lot_step = SymbolInfo::GetVolumeStep(_symbol);
      uint _digits = SymbolInfo::GetDigits(_symbol);
      switch (_digits) {
        case 4:
          if (_lot_step != 0.1) {
            if (verbose) {
              PrintFormat("Symbol digits  : %g", _digits);
              PrintFormat("Lot step       : %g", _lot_step);
              PrintFormat("Error: Expected lot step for %d digits: 0.1, found: %g", _digits, _lot_step);
            }
            return (false);
          }
          break;
        case 5:
          if (_lot_step != 0.01) {
            if (verbose) {
              PrintFormat("Symbol digits  : %g", _digits);
              PrintFormat("Lot step       : %g", _lot_step);
              PrintFormat("Error: Expected lot step for %d digits: 0.01, found: %g", _digits, _lot_step);
            }
            return (false);
          }
          break;
      }
      return (true);
    }

};

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
 * Exchange class.
 */
#ifndef EXCHANGE_H
#define EXCHANGE_H

// Includes.
#include "../Account.mqh"
#include "../DictObject.mqh"
#include "../SymbolInfo.mqh"
#include "../Trade.mqh"
#include "Exchange.struct.h"

class Exchange {
 protected:
  DictObject<string, Account> accounts;
  DictObject<string, SymbolInfo> symbols;
  DictObject<string, Trade> trades;
  ExchangeParams eparams;

 public:
  /**
   * Class constructor without parameters.
   */
  Exchange(){};

  /**
   * Class constructor with parameters.
   */
  Exchange(ExchangeParams &_eparams) : eparams(_eparams){};

  /**
   * Class deconstructor.
   */
  ~Exchange() {}

};
#endif  // EXCHANGE_H

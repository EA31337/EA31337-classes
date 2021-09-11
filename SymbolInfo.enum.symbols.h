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
 * Includes SymbolInfo's symbol enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

/**
 * Enumeration for the Crypto symbols.
 */
enum ENUM_SYMBOL_LIST_CRYPTO {
  SYMBOL_CRYPTO_BTCEUR,  // BTCEUR
  SYMBOL_CRYPTO_BTCCNH,  // BTCCNH
  SYMBOL_CRYPTO_BTCCNY,  // BTCCNY
  SYMBOL_CRYPTO_BTCJPY,  // BTCJPY
  SYMBOL_CRYPTO_BTCRUB,  // BTCRUB
  SYMBOL_CRYPTO_DSHUSD,  // DSHUSD
  SYMBOL_CRYPTO_ETCUSD,  // ETCUSD
  SYMBOL_CRYPTO_ETCBTC,  // ETCBTC
  SYMBOL_CRYPTO_ETCETH,  // ETCETH
  SYMBOL_CRYPTO_ETHUSD,  // ETHUSD
  SYMBOL_CRYPTO_ETHBTC,  // ETHBTC
  SYMBOL_CRYPTO_ETHLTC,  // ETHLTC
  SYMBOL_CRYPTO_BTCUSD,  // BTCUSD
  SYMBOL_CRYPTO_ETHRUB,  // ETHRUB
  SYMBOL_CRYPTO_EMCUSD,  // EMCUSD
  SYMBOL_CRYPTO_LTCUSD,  // LTCUSD
  SYMBOL_CRYPTO_BTCBTC,  // BTCBTC
  SYMBOL_CRYPTO_LTCEUR,  // LTCEUR
  SYMBOL_CRYPTO_LTCCNH,  // LTCCNH
  SYMBOL_CRYPTO_LTCCNY,  // LTCCNY
  SYMBOL_CRYPTO_LTCJPY,  // LTCJPY
  SYMBOL_CRYPTO_LTCRUB,  // LTCRUB
  SYMBOL_CRYPTO_MBTUSD,  // MBTUSD
  SYMBOL_CRYPTO_XMRUSD,  // XMRUSD
  SYMBOL_CRYPTO_XRPUSD,  // XRPUSD
  SYMBOL_CRYPTO_ZECUSD,  // ZECUSD
  SYMBOL_CRYPTO_EOSUSD,  // EOSUSD
};

/**
 * Enumeration for the energy symbols.
 */
enum ENUM_SYMBOL_LIST_ENERGY {
  SYMBOL_ENERGY_XBRUSD,  // Brent Oil vs US Dollar (XBRUSD)
  SYMBOL_ENERGY_XNGUSD,  // Natural Gas vs US Dollar (XNGUSD)
  SYMBOL_ENERGY_XTIUSD,  // Crude Oil vs US Dollar (XTIUSD)
};

/**
 * Enumeration for the Forex symbols.
 */
enum ENUM_SYMBOL_LIST_FOREX {
  SYMBOL_FOREX_AUDCAD,  // AUDJPY
  SYMBOL_FOREX_AUDCHF,  // AUDNZD
  SYMBOL_FOREX_AUDJPY,  // AUDUSD
  SYMBOL_FOREX_AUDNZD,  // CADJPY
  SYMBOL_FOREX_AUDUSD,  // CHFJPY
  SYMBOL_FOREX_CADCHF,  // EURAUD
  SYMBOL_FOREX_CADJPY,  // EURCAD
  SYMBOL_FOREX_CHFJPY,  // EURCHF
  SYMBOL_FOREX_EURAUD,  // EURGBP
  SYMBOL_FOREX_EURCAD,  // EURJPY
  SYMBOL_FOREX_EURCHF,  // EURNOK
  SYMBOL_FOREX_EURGBP,  // EURSEK
  SYMBOL_FOREX_EURJPY,  // EURUSD
  SYMBOL_FOREX_EURNOK,  // GBPCHF
  SYMBOL_FOREX_EURNZD,  // GBPJPY
  SYMBOL_FOREX_EURSEK,  // GBPUSD
  SYMBOL_FOREX_EURUSD,  // NZDUSD
  SYMBOL_FOREX_GBPAUD,  // USDCAD
  SYMBOL_FOREX_GBPCAD,  // USDCHF
  SYMBOL_FOREX_GBPCHF,  // USDJPY
  SYMBOL_FOREX_GBPJPY,  // USDNOK
  SYMBOL_FOREX_GBPNZD,  // USDSEK
  SYMBOL_FOREX_GBPUSD,  // USDSGD
  SYMBOL_FOREX_NZDCAD,  // AUDCAD
  SYMBOL_FOREX_NZDCHF,  // AUDCHF
  SYMBOL_FOREX_NZDJPY,  // CADCHF
  SYMBOL_FOREX_NZDUSD,  // EURNZD
  SYMBOL_FOREX_USDCAD,  // GBPAUD
  SYMBOL_FOREX_USDCHF,  // GBPCAD
  SYMBOL_FOREX_USDJPY,  // GBPNZD
  SYMBOL_FOREX_USDNOK,  // NZDCAD
  SYMBOL_FOREX_USDSEK,  // NZDCHF
  SYMBOL_FOREX_USDSGD,  // NZDJPY
};

/**
 * Enumeration for the index symbols.
 */
enum ENUM_SYMBOL_LIST_INDEX {
  SYMBOL_INDEX_FCHI40,  // CAC 40 Index
  SYMBOL_INDEX_GDAXIm,  // DAX 30 Index
  SYMBOL_INDEX_HSI50,   // HSI 50 Index
  SYMBOL_INDEX_ND100m,  // NASDAX 100 Index
  SYMBOL_INDEX_AUS200,  // ASX 200 Index
  SYMBOL_INDEX_NI225,   // Nikkei 225 Index
  SYMBOL_INDEX_UK100,   // FTSE 100 Index
  SYMBOL_INDEX_SP500m,  // Standard & Poor's 500
  SYMBOL_INDEX_SPN35,   // IBEX 35 Index
  SYMBOL_INDEX_STOX50,  // EUR STOXX 50
};

/**
 * Enumeration for the precious metal symbols.
 */
enum ENUM_SYMBOL_LIST_METALS {
  SYMBOL_METAL_XAGEUR,  // Silver vs Euro (XAGEUR)
  SYMBOL_METAL_XAGUSD,  // Silver vs US Dollar (XAGUSD)
  SYMBOL_METAL_XAUAUD,  // Gold vs Australian Dollar (XAUAUD)
  SYMBOL_METAL_XAUEUR,  // Gold vs Euro (XAUEUR)
  SYMBOL_METAL_XAUUSD,  // Gold vs US Dollar (XAUUSD)
  SYMBOL_METAL_XPDUSD,  // Palladium vs US Dollar (XPDUSD)
  SYMBOL_METAL_XPTUSD,  // Platinum vs US Dollar (XPTUSD)
};

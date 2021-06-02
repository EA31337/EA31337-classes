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
 * Includes SymbolInfo's enums.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

#ifndef __MQL5__
// Methods of swap calculation at position transfer.
// @see: https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants#enum_symbol_swap_mode
enum ENUM_SYMBOL_SWAP_MODE {
  SYMBOL_SWAP_MODE_DISABLED = -1,         // Swaps disabled (no swaps).
  SYMBOL_SWAP_MODE_POINTS = 0,            // Swaps are charged in points.
  SYMBOL_SWAP_MODE_CURRENCY_SYMBOL = 1,   // Swaps are charged in money in base currency of the symbol.
  SYMBOL_SWAP_MODE_INTEREST_CURRENT = 2,  // Swaps are charged as the specified annual interest.
  SYMBOL_SWAP_MODE_CURRENCY_MARGIN = 3,   // Swaps are charged in money in margin currency of the symbol.
  SYMBOL_SWAP_MODE_CURRENCY_DEPOSIT,      // Swaps are charged in money, in client deposit currency.
  SYMBOL_SWAP_MODE_INTEREST_OPEN,         // Swaps are charged as the specified annual interest from the open price.
  SYMBOL_SWAP_MODE_REOPEN_CURRENT,        // Swaps are charged by reopening positions.
  SYMBOL_SWAP_MODE_REOPEN_BID             // Swaps are charged by reopening positions.
};
#endif

#ifndef __MQL__
/**
 * Enumeration for the current market double values.
 *
 * For function SymbolInfoDouble().
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
 */
enum ENUM_SYMBOL_INFO_DOUBLE {
  SYMBOL_BID,                      // Bid - best sell offer (double).
  SYMBOL_BIDHIGH,                  // Maximal Bid of the day (double).
  SYMBOL_BIDLOW,                   // Minimal Bid of the day (double).
  SYMBOL_ASK,                      // Ask - best buy offer (double).
  SYMBOL_ASKHIGH,                  // Maximal Ask of the day (double).
  SYMBOL_ASKLOW,                   // Minimal Ask of the day (double).
  SYMBOL_LAST,                     // Price of the last deal (double).
  SYMBOL_LASTHIGH,                 // Maximal Last of the day (double).
  SYMBOL_LASTLOW,                  // Minimal Last of the day (double).
  SYMBOL_VOLUME_REAL,              // Volume of the last deal (double).
  SYMBOL_VOLUMEHIGH_REAL,          // Maximum Volume of the day (double).
  SYMBOL_VOLUMELOW_REAL,           // Minimum Volume of the day (double).
  SYMBOL_OPTION_STRIKE,            // The strike price of an option (double).
  SYMBOL_POINT,                    // Symbol point value (double).
  SYMBOL_TRADE_TICK_VALUE,         // Value of SYMBOL_TRADE_TICK_VALUE_PROFIT (double).
  SYMBOL_TRADE_TICK_VALUE_PROFIT,  // Calculated tick price for a profitable position (double).
  SYMBOL_TRADE_TICK_VALUE_LOSS,    // Calculated tick price for a losing position (double).
  SYMBOL_TRADE_TICK_SIZE,          // Minimal price change (double).
  SYMBOL_TRADE_CONTRACT_SIZE,      // Trade contract size (double).
  SYMBOL_TRADE_ACCRUED_INTEREST,   // Accrued interest - accumulated coupon interest (double).
  SYMBOL_TRADE_FACE_VALUE,         // Face value - initial bond value set by the issuer (double).
  SYMBOL_TRADE_LIQUIDITY_RATE,     // Liquidity Rate is the share of the asset that can be used for the margin (double).
  SYMBOL_VOLUME_MIN,               // Minimal volume for a deal (double).
  SYMBOL_VOLUME_MAX,               // Maximal volume for a deal (double).
  SYMBOL_VOLUME_STEP,              // Minimal volume change step for deal execution (double).
  SYMBOL_VOLUME_LIMIT,      // Maximum allowed aggregate volume of an open position and pending orders in one direction.
  SYMBOL_SWAP_LONG,         // Long swap value (double).
  SYMBOL_SWAP_SHORT,        // Short swap value (double).
  SYMBOL_MARGIN_INITIAL,    // The amount in the margin currency required for opening a position.
  SYMBOL_SESSION_VOLUME,    // Summary volume of current session deals (double).
  SYMBOL_SESSION_TURNOVER,  // Summary turnover of the current session (double).
  SYMBOL_SESSION_INTEREST,  // Summary open interest (double).
  SYMBOL_SESSION_BUY_ORDERS_VOLUME,   // Current volume of Buy orders (double).
  SYMBOL_SESSION_SELL_ORDERS_VOLUME,  // Current volume of Sell orders (double).
  SYMBOL_SESSION_OPEN,                // Open price of the current session (double).
  SYMBOL_SESSION_CLOSE,               // Close price of the current session (double).
  SYMBOL_SESSION_AW,                  // Average weighted price of the current session (double).
  SYMBOL_SESSION_PRICE_SETTLEMENT,    // Settlement price of the current session (double).
  SYMBOL_SESSION_PRICE_LIMIT_MIN,     // Minimal price of the current session (double).
  SYMBOL_SESSION_PRICE_LIMIT_MAX,     // Maximal price of the current session (double).
  SYMBOL_MARGIN_HEDGED,               // Contract size or margin value per one lot of hedged positions.
  SYMBOL_PRICE_CHANGE,  // Change of the current price relative to the end of the previous trading day in % (double).
  SYMBOL_PRICE_VOLATILITY,   // Price volatility in % (double).
  SYMBOL_PRICE_THEORETICAL,  // Theoretical option price (double).
  SYMBOL_PRICE_DELTA,        // Option/warrant delta shows the value the option price changes by.
  SYMBOL_PRICE_THETA,        // Option/warrant theta shows the number of points the option price is to lose.
  SYMBOL_PRICE_GAMMA,        // Option/warrant gamma shows the change rate of delta.
  SYMBOL_PRICE_VEGA,         // Option/warrant vega shows the number of points the option price changes.
  SYMBOL_PRICE_RHO,          // Option/warrant rho reflects the sensitivity of the theoretical option price.
  SYMBOL_PRICE_OMEGA,        // Option/warrant omega (double).
  SYMBOL_PRICE_SENSITIVITY,  // Option/warrant sensitivity (double).
};

/**
 * Enumeration for the current market integer values.
 *
 * For function SymbolInfoInteger().
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
 */
enum ENUM_SYMBOL_INFO_INTEGER {
  SYMBOL_SECTOR,            // The sector of the economy to which the asset belongs (ENUM_SYMBOL_SECTOR).
  SYMBOL_INDUSTRY,          // The industry or the economy branch to which the symbol belongs (ENUM_SYMBOL_INDUSTRY).
  SYMBOL_CUSTOM,            // A custom symbol - the symbol has been created synthetically based on other symbols.
  SYMBOL_BACKGROUND_COLOR,  // The color of the background used for the symbol in Market Watch (color).
  SYMBOL_CHART_MODE,     // The price type used for generating symbols bars, i.e. Bid or Last (ENUM_SYMBOL_CHART_MODE).
  SYMBOL_EXIST,          // Symbol with this name exists (bool).
  SYMBOL_SELECT,         // Symbol is selected in Market Watch (bool).
  SYMBOL_VISIBLE,        // Symbol is visible in Market Watch (bool).
  SYMBOL_SESSION_DEALS,  // Number of deals in the current session (long).
  SYMBOL_SESSION_BUY_ORDERS,     // Number of Buy orders at the moment (long).
  SYMBOL_SESSION_SELL_ORDERS,    // Number of Sell orders at the moment (long).
  SYMBOL_VOLUME,                 // Volume of the last deal (long).
  SYMBOL_VOLUMEHIGH,             // Maximal day volume (long).
  SYMBOL_VOLUMELOW,              // Minimal day volume (long).
  SYMBOL_TIME,                   // Time of the last quote (datetime).
  SYMBOL_TIME_MSC,               // Time of the last quote in milliseconds since 1970.01.01 (long).
  SYMBOL_DIGITS,                 // Digits after a decimal point (int).
  SYMBOL_SPREAD_FLOAT,           // Indication of a floating spread (bool).
  SYMBOL_SPREAD,                 // Spread value in points (int).
  SYMBOL_TICKS_BOOKDEPTH,        // Maximal number of requests shown in Depth of Market.
  SYMBOL_TRADE_CALC_MODE,        // Contract price calculation mode (ENUM_SYMBOL_CALC_MODE).
  SYMBOL_TRADE_MODE,             // Order execution type (ENUM_SYMBOL_TRADE_MODE).
  SYMBOL_START_TIME,             // Date of the symbol trade beginning (usually used for futures) (datetime).
  SYMBOL_EXPIRATION_TIME,        // Date of the symbol trade end (usually used for futures) (datetime).
  SYMBOL_TRADE_STOPS_LEVEL,      // Minimal indention in points from the current close price to place Stop orders (int).
  SYMBOL_TRADE_FREEZE_LEVEL,     // Distance to freeze trade operations in points (int).
  SYMBOL_TRADE_EXEMODE,          // Deal execution mode (ENUM_SYMBOL_TRADE_EXECUTION).
  SYMBOL_SWAP_MODE,              // Swap calculation model (ENUM_SYMBOL_SWAP_MODE).
  SYMBOL_SWAP_ROLLOVER3DAYS,     // Day of week to charge 3 days swap rollover (ENUM_DAY_OF_WEEK).
  SYMBOL_MARGIN_HEDGED_USE_LEG,  // Calculating hedging margin using the larger leg (Buy or Sell) (bool).
  SYMBOL_EXPIRATION_MODE,        // Flags of allowed order expiration modes (int).
  SYMBOL_FILLING_MODE,           // Flags of allowed order filling modes (int).
  SYMBOL_ORDER_MODE,             // Flags of allowed order types (int).
  SYMBOL_ORDER_GTC_MODE,         // Expiration of Stop Loss and Take Profit orders.
  SYMBOL_OPTION_MODE,            // Option type (ENUM_SYMBOL_OPTION_MODE).
  SYMBOL_OPTION_RIGHT,           // Option right (Call/Put) (ENUM_SYMBOL_OPTION_RIGHT).
};

/**
 * Enumeration for the current market string values.
 *
 * For function SymbolInfoString().
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
 */
enum ENUM_SYMBOL_INFO_STRING {
  SYMBOL_BASIS,            // The underlying asset of a derivative (string).
  SYMBOL_CATEGORY,         // The name of the sector or category to which the financial symbol belongs (string).
  SYMBOL_COUNTRY,          // The country to which the financial symbol belongs (string).
  SYMBOL_SECTOR_NAME,      // The sector of the economy to which the financial symbol belongs (string).
  SYMBOL_INDUSTRY_NAME,    // The industry branch or the industry to which the financial symbol belongs (string).
  SYMBOL_CURRENCY_BASE,    // Basic currency of a symbol (string).
  SYMBOL_CURRENCY_PROFIT,  // Profit currency (string).
  SYMBOL_CURRENCY_MARGIN,  // Margin currency (string).
  SYMBOL_BANK,             // Feeder of the current quote (string).
  SYMBOL_DESCRIPTION,      // Symbol description (string).
  SYMBOL_EXCHANGE,         // The name of the exchange in which the financial symbol is traded (string).
  SYMBOL_FORMULA,          // The formula used for the custom symbol pricing (string).
  SYMBOL_ISIN,             // The name of a symbol in the ISIN system (International Securities Identification Number).
  SYMBOL_PAGE,             // The address of the web page containing symbol information.
  SYMBOL_PATH,             // Path in the symbol tree (string).
};

/**
 * Enumeration for the current market modes.
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
 */
enum ENUM_SYMBOL_CHART_MODE {
  SYMBOL_CHART_MODE_BID,   // Bars are based on Bid prices.
  SYMBOL_CHART_MODE_LAST,  // Bars are based on Last prices.
};

/**
 * Enumeration for the symbol order GTC mode.
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
 */
enum ENUM_SYMBOL_ORDER_GTC_MODE {
  SYMBOL_ORDERS_GTC,    // Pending orders and Stop Loss/Take Profit levels are valid for an unlimited period.
  SYMBOL_ORDERS_DAILY,  // Orders are valid during one trading day.
  SYMBOL_ORDERS_DAILY_EXCLUDING_STOPS,  // When a trade day changes, only pending orders are deleted.
};

/**
 * Enumeration for the margin calculation modes.
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
 */
enum ENUM_SYMBOL_CALC_MODE {
  SYMBOL_CALC_MODE_FOREX,              // Forex mode - calculation of profit and margin for Forex.
  SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE,  // Forex No Leverage mode.
  SYMBOL_CALC_MODE_FUTURES,            // Futures mode - calculation of margin and profit for futures.
  SYMBOL_CALC_MODE_CFD,                // CFD mode - calculation of margin and profit for CFD.
  SYMBOL_CALC_MODE_CFDINDEX,           // CFD index mode - calculation of margin and profit for CFD by indexes.
  SYMBOL_CALC_MODE_CFDLEVERAGE,   // CFD Leverage mode - calculation of margin and profit for CFD at leverage trading.
  SYMBOL_CALC_MODE_EXCH_STOCKS,   // Exchange mode - calculation of margin and profit for trading securities.
  SYMBOL_CALC_MODE_EXCH_FUTURES,  // Futures mode - calculation of margin and profit for trading futures contracts.
  SYMBOL_CALC_MODE_EXCH_FUTURES_FORTS,  // FORTS Futures mode.
  SYMBOL_CALC_MODE_EXCH_BONDS,          // Exchange Bonds mode.
  SYMBOL_CALC_MODE_EXCH_STOCKS_MOEX,    // Exchange MOEX Stocks mode.
  SYMBOL_CALC_MODE_EXCH_BONDS_MOEX,     // Exchange MOEX Bonds mode.
  SYMBOL_CALC_MODE_SERV_COLLATERAL,     // Collateral mode.
};

/**
 * Enumeration for the trading modes.
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
 */
enum ENUM_SYMBOL_TRADE_MODE {
  SYMBOL_TRADE_MODE_DISABLED,   // Trade is disabled for the symbol.
  SYMBOL_TRADE_MODE_LONGONLY,   // Allowed only long positions.
  SYMBOL_TRADE_MODE_SHORTONLY,  // Allowed only short positions.
  SYMBOL_TRADE_MODE_CLOSEONLY,  // Allowed only position close operations.
  SYMBOL_TRADE_MODE_FULL,       // No trade restrictions.
};

/**
 * Enumeration for the possible deal execution modes.
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
 */
enum ENUM_SYMBOL_TRADE_EXECUTION {
  SYMBOL_TRADE_EXECUTION_REQUEST,   // Execution by request.
  SYMBOL_TRADE_EXECUTION_INSTANT,   // Instant execution.
  SYMBOL_TRADE_EXECUTION_MARKET,    // Market execution.
  SYMBOL_TRADE_EXECUTION_EXCHANGE,  // Exchange execution.
};

/**
 * Enumeration for the option right modes.
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
 */
enum ENUM_SYMBOL_OPTION_RIGHT {
  SYMBOL_OPTION_RIGHT_CALL,  // A call option gives you the right to buy an asset at a specified price.
  SYMBOL_OPTION_RIGHT_PUT,   // A put option gives you the right to sell an asset at a specified price.
};

/**
 * Enumeration for the symbol option modes.
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
 */
enum ENUM_SYMBOL_OPTION_MODE {
  SYMBOL_OPTION_MODE_EUROPEAN,  // European option may only be exercised on a specified date.
  SYMBOL_OPTION_MODE_AMERICAN,  // American option may be exercised on any trading day or before expiry.
};

/**
 * Enumeration for the type of financial instruments.
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
 */
enum ENUM_SYMBOL_SECTOR {
  SECTOR_UNDEFINED,               // Undefined.
  SECTOR_BASIC_MATERIALS,         // Basic materials.
  SECTOR_COMMUNICATION_SERVICES,  // Communication services.
  SECTOR_CONSUMER_CYCLICAL,       // Consumer cyclical.
  SECTOR_CONSUMER_DEFENSIVE,      // Consumer defensive.
  SECTOR_CURRENCY,                // Currencies.
  SECTOR_CURRENCY_CRYPTO,         // Cryptocurrencies.
  SECTOR_ENERGY,                  // Energy.
  SECTOR_FINANCIAL,               // Finance.
  SECTOR_HEALTHCARE,              // Healthcare.
  SECTOR_INDUSTRIALS,             // Industrials.
  SECTOR_REAL_ESTATE,             // Real estate.
  SECTOR_TECHNOLOGY,              // Technology.
  SECTOR_UTILITIES,               // Utilities.
};

/**
 * Enumeration for each type of industry or economy branch.
 *
 * @docs
 * https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
 */
enum ENUM_SYMBOL_INDUSTRY {
  INDUSTRY_UNDEFINED,  // Undefined.
  // Basic materials.
  INDUSTRY_AGRICULTURAL_INPUTS,  // Agricultural inputs.
  INDUSTRY_ALUMINIUM,            // Aluminium.
  INDUSTRY_BUILDING_MATERIALS,   // Building materials.
  INDUSTRY_CHEMICALS,            // Chemicals.
  INDUSTRY_COKING_COAL,          // Coking coal.
  INDUSTRY_COPPER,               // Copper.
  INDUSTRY_GOLD,                 // Gold.
  INDUSTRY_LUMBER_WOOD,          // Lumber and wood production.
  INDUSTRY_INDUSTRIAL_METALS,    // Other industrial metals and mining.
  INDUSTRY_PRECIOUS_METALS,      // Other precious metals and mining.
  INDUSTRY_PAPER,                // Paper and paper products.
  INDUSTRY_SILVER,               // Silver.
  INDUSTRY_SPECIALTY_CHEMICALS,  // Specialty chemicals.
  INDUSTRY_STEEL,                // Steel.
  // Communication services.
  INDUSTRY_ADVERTISING,        // Advertising agencies.
  INDUSTRY_BROADCASTING,       // Broadcasting.
  INDUSTRY_GAMING_MULTIMEDIA,  // Electronic gaming and multimedia.
  INDUSTRY_ENTERTAINMENT,      // Entertainment.
  INDUSTRY_INTERNET_CONTENT,   // Internet content and information.
  INDUSTRY_PUBLISHING,         // Publishing.
  INDUSTRY_TELECOM,            // Telecom services.
  // Consumer cyclical.
  INDUSTRY_APPAREL_MANUFACTURING,  // Apparel manufacturing.
  INDUSTRY_APPAREL_RETAIL,         // Apparel retail.
  INDUSTRY_AUTO_MANUFACTURERS,     // Auto manufacturers.
  INDUSTRY_AUTO_PARTS,             // Auto parts.
  INDUSTRY_AUTO_DEALERSHIP,        // Auto and truck dealerships.
  INDUSTRY_DEPARTMENT_STORES,      // Department stores.
  INDUSTRY_FOOTWEAR_ACCESSORIES,   // Footwear and accessories.
  INDUSTRY_FURNISHINGS,            // Furnishing, fixtures and appliances.
  INDUSTRY_GAMBLING,               // Gambling.
  INDUSTRY_HOME_IMPROV_RETAIL,     // Home improvement retail.
  INDUSTRY_INTERNET_RETAIL,        // Internet retail.
  INDUSTRY_LEISURE,                // Leisure.
  INDUSTRY_LODGING,                // Lodging.
  INDUSTRY_LUXURY_GOODS,           // Luxury goods.
  INDUSTRY_PACKAGING_CONTAINERS,   // Packaging and containers.
  INDUSTRY_PERSONAL_SERVICES,      // Personal services.
  INDUSTRY_RECREATIONAL_VEHICLES,  // Recreational vehicles.
  INDUSTRY_RESIDENT_CONSTRUCTION,  // Residential construction.
  INDUSTRY_RESORTS_CASINOS,        // Resorts and casinos.
  INDUSTRY_RESTAURANTS,            // Restaurants.
  INDUSTRY_SPECIALTY_RETAIL,       // Specialty retail.
  INDUSTRY_TEXTILE_MANUFACTURING,  // Textile manufacturing.
  INDUSTRY_TRAVEL_SERVICES,        // Travel services.
  // Consumer defensive.
  INDUSTRY_BEVERAGES_BREWERS,   // Beverages - Brewers.
  INDUSTRY_BEVERAGES_NON_ALCO,  // Beverages - Non-alcoholic.
  INDUSTRY_BEVERAGES_WINERIES,  // Beverages - Wineries and distilleries.
  INDUSTRY_CONFECTIONERS,       // Confectioners.
  INDUSTRY_DISCOUNT_STORES,     // Discount stores.
  INDUSTRY_EDUCATION_TRAINIG,   // Education and training services.
  INDUSTRY_FARM_PRODUCTS,       // Farm products.
  INDUSTRY_FOOD_DISTRIBUTION,   // Food distribution.
  INDUSTRY_GROCERY_STORES,      // Grocery stores.
  INDUSTRY_HOUSEHOLD_PRODUCTS,  // Household and personal products.
  INDUSTRY_PACKAGED_FOODS,      // Packaged foods.
  INDUSTRY_TOBACCO,             // Tobacco.
  // Energy.
  INDUSTRY_OIL_GAS_DRILLING,    // Oil and gas drilling.
  INDUSTRY_OIL_GAS_EP,          // Oil and gas extraction and processing.
  INDUSTRY_OIL_GAS_EQUIPMENT,   // Oil and gas equipment and services.
  INDUSTRY_OIL_GAS_INTEGRATED,  // Oil and gas integrated.
  INDUSTRY_OIL_GAS_MIDSTREAM,   // Oil and gas midstream.
  INDUSTRY_OIL_GAS_REFINING,    // Oil and gas refining and marketing.
  INDUSTRY_THERMAL_COAL,        // Thermal coal.
  INDUSTRY_URANIUM,             // Uranium.
  // Finance.
  INDUSTRY_EXCHANGE_TRADED_FUND,     // Exchange traded fund.
  INDUSTRY_ASSETS_MANAGEMENT,        // Assets management.
  INDUSTRY_BANKS_DIVERSIFIED,        // Banks - Diversified.
  INDUSTRY_BANKS_REGIONAL,           // Banks - Regional.
  INDUSTRY_CAPITAL_MARKETS,          // Capital markets.
  INDUSTRY_CLOSE_END_FUND_DEBT,      // Closed-End fund - Debt.
  INDUSTRY_CLOSE_END_FUND_EQUITY,    // Closed-end fund - Equity.
  INDUSTRY_CLOSE_END_FUND_FOREIGN,   // Closed-end fund - Foreign.
  INDUSTRY_CREDIT_SERVICES,          // Credit services.
  INDUSTRY_FINANCIAL_CONGLOMERATE,   // Financial conglomerates.
  INDUSTRY_FINANCIAL_DATA_EXCHANGE,  // Financial data and stock exchange.
  INDUSTRY_INSURANCE_BROKERS,        // Insurance brokers.
  INDUSTRY_INSURANCE_DIVERSIFIED,    // Insurance - Diversified.
  INDUSTRY_INSURANCE_LIFE,           // Insurance - Life.
  INDUSTRY_INSURANCE_PROPERTY,       // Insurance - Property and casualty.
  INDUSTRY_INSURANCE_REINSURANCE,    // Insurance - Reinsurance.
  INDUSTRY_INSURANCE_SPECIALTY,      // Insurance - Specialty.
  INDUSTRY_MORTGAGE_FINANCE,         // Mortgage finance.
  INDUSTRY_SHELL_COMPANIES,          // Shell companies.
  // Healthcare.
  INDUSTRY_BIOTECHNOLOGY,             // Biotechnology.
  INDUSTRY_DIAGNOSTICS_RESEARCH,      // Diagnostics and research.
  INDUSTRY_DRUGS_MANUFACTURERS,       // Drugs manufacturers - general.
  INDUSTRY_DRUGS_MANUFACTURERS_SPEC,  // Drugs manufacturers - Specialty and generic.
  INDUSTRY_HEALTHCARE_PLANS,          // Healthcare plans.
  INDUSTRY_HEALTH_INFORMATION,        // Health information services.
  INDUSTRY_MEDICAL_FACILITIES,        // Medical care facilities.
  INDUSTRY_MEDICAL_DEVICES,           // Medical devices.
  INDUSTRY_MEDICAL_DISTRIBUTION,      // Medical distribution.
  INDUSTRY_MEDICAL_INSTRUMENTS,       // Medical instruments and supplies.
  INDUSTRY_PHARM_RETAILERS,           // Pharmaceutical retailers.
  // Industrials.
  INDUSTRY_AEROSPACE_DEFENSE,           // Aerospace and defense.
  INDUSTRY_AIRLINES,                    // Airlines.
  INDUSTRY_AIRPORTS_SERVICES,           // Airports and air services.
  INDUSTRY_BUILDING_PRODUCTS,           // Building products and equipment.
  INDUSTRY_BUSINESS_EQUIPMENT,          // Business equipment and supplies.
  INDUSTRY_CONGLOMERATES,               // Conglomerates.
  INDUSTRY_CONSULTING_SERVICES,         // Consulting services.
  INDUSTRY_ELECTRICAL_EQUIPMENT,        // Electrical equipment and parts.
  INDUSTRY_ENGINEERING_CONSTRUCTION,    // Engineering and construction.
  INDUSTRY_FARM_HEAVY_MACHINERY,        // Farm and heavy construction machinery.
  INDUSTRY_INDUSTRIAL_DISTRIBUTION,     // Industrial distribution.
  INDUSTRY_INFRASTRUCTURE_OPERATIONS,   // Infrastructure operations.
  INDUSTRY_FREIGHT_LOGISTICS,           // Integrated freight and logistics.
  INDUSTRY_MARINE_SHIPPING,             // Marine shipping.
  INDUSTRY_METAL_FABRICATION,           // Metal fabrication.
  INDUSTRY_POLLUTION_CONTROL,           // Pollution and treatment controls.
  INDUSTRY_RAILROADS,                   // Railroads.
  INDUSTRY_RENTAL_LEASING,              // Rental and leasing services.
  INDUSTRY_SECURITY_PROTECTION,         // Security and protection services.
  INDUSTRY_SPEALITY_BUSINESS_SERVICES,  // Specialty business services.
  INDUSTRY_SPEALITY_MACHINERY,          // Specialty industrial machinery.
  INDUSTRY_STUFFING_EMPLOYMENT,         // Stuffing and employment services.
  INDUSTRY_TOOLS_ACCESSORIES,           // Tools and accessories.
  INDUSTRY_TRUCKING,                    // Trucking.
  INDUSTRY_WASTE_MANAGEMENT,            // Waste management.
  // Real estate.
  INDUSTRY_REAL_ESTATE_DEVELOPMENT,  // Real estate - Development.
  INDUSTRY_REAL_ESTATE_DIVERSIFIED,  // Real estate - Diversified.
  INDUSTRY_REAL_ESTATE_SERVICES,     // Real estate services.
  INDUSTRY_REIT_DIVERSIFIED,         // REIT - Diversified.
  INDUSTRY_REIT_HEALTCARE,           // REIT - Healthcase facilities.
  INDUSTRY_REIT_HOTEL_MOTEL,         // REIT - Hotel and motel.
  INDUSTRY_REIT_INDUSTRIAL,          // REIT - Industrial.
  INDUSTRY_REIT_MORTAGE,             // REIT - Mortgage.
  INDUSTRY_REIT_OFFICE,              // REIT - Office.
  INDUSTRY_REIT_RESIDENTAL,          // REIT - Residential.
  INDUSTRY_REIT_RETAIL,              // REIT - Retail.
  INDUSTRY_REIT_SPECIALITY,          // REIT - Specialty.
  // Technology.
  INDUSTRY_COMMUNICATION_EQUIPMENT,  // Communication equipment.
  INDUSTRY_COMPUTER_HARDWARE,        // Computer hardware.
  INDUSTRY_CONSUMER_ELECTRONICS,     // Consumer electronics.
  INDUSTRY_ELECTRONIC_COMPONENTS,    // Electronic components.
  INDUSTRY_ELECTRONIC_DISTRIBUTION,  // Electronics and computer distribution.
  INDUSTRY_IT_SERVICES,              // Information technology services.
  INDUSTRY_SCIENTIFIC_INSTRUMENTS,   // Scientific and technical instruments.
  INDUSTRY_SEMICONDUCTOR_EQUIPMENT,  // Semiconductor equipment and materials.
  INDUSTRY_SEMICONDUCTORS,           // Semiconductors.
  INDUSTRY_SOFTWARE_APPLICATION,     // Software - Application.
  INDUSTRY_SOFTWARE_INFRASTRUCTURE,  // Software - Infrastructure.
  INDUSTRY_SOLAR,                    // Solar.
  // Utilities.
  INDUSTRY_UTILITIES_DIVERSIFIED,         // Utilities - Diversified.
  INDUSTRY_UTILITIES_POWERPRODUCERS,      // Utilities - Independent power producers.
  INDUSTRY_UTILITIES_RENEWABLE,           // Utilities - Renewable.
  INDUSTRY_UTILITIES_REGULATED_ELECTRIC,  // Utilities - Regulated electric.
  INDUSTRY_UTILITIES_REGULATED_GAS,       // Utilities - Regulated gas.
  INDUSTRY_UTILITIES_REGULATED_WATER,     // Utilities - Regulated water.
  INDUSTRY_UTILITIES_FIRST,               // Start of the utilities services types enumeration.
  INDUSTRY_UTILITIES_LAST,                // End of the utilities services types enumeration.
};
#endif

// Enum constants.
const ENUM_SYMBOL_INFO_INTEGER market_icache[] = {
    SYMBOL_DIGITS,          SYMBOL_EXPIRATION_MODE, SYMBOL_FILLING_MODE,
    SYMBOL_ORDER_MODE,      SYMBOL_SWAP_MODE,       SYMBOL_SWAP_ROLLOVER3DAYS,
    SYMBOL_TRADE_CALC_MODE, SYMBOL_TRADE_EXEMODE,   SYMBOL_TRADE_MODE};

// Enum constants.
const ENUM_SYMBOL_INFO_DOUBLE market_dcache[] = {SYMBOL_MARGIN_INITIAL,
                                                 SYMBOL_MARGIN_LIMIT,
                                                 SYMBOL_MARGIN_LONG,
                                                 SYMBOL_MARGIN_MAINTENANCE,
                                                 SYMBOL_MARGIN_SHORT,
                                                 SYMBOL_MARGIN_STOP,
                                                 SYMBOL_MARGIN_STOPLIMIT,
                                                 SYMBOL_POINT,
                                                 SYMBOL_SWAP_LONG,
                                                 SYMBOL_SWAP_SHORT,
                                                 SYMBOL_TRADE_CONTRACT_SIZE,
                                                 SYMBOL_TRADE_TICK_SIZE,
                                                 SYMBOL_TRADE_TICK_VALUE,
                                                 SYMBOL_TRADE_TICK_VALUE_LOSS,
                                                 SYMBOL_TRADE_TICK_VALUE_PROFIT,
                                                 SYMBOL_VOLUME_LIMIT,
                                                 SYMBOL_VOLUME_MAX,
                                                 SYMBOL_VOLUME_MIN,
                                                 SYMBOL_VOLUME_STEP};

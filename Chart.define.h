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
 * Terminal's defines.
 */

/* Defines */

// Define type of timeframe periods using bitwise values.
#define M1B (1 << M1)    // 1 minute
#define M2B (1 << M2)    // 2 minutes (non-standard)
#define M3B (1 << M3)    // 3 minutes (non-standard)
#define M4B (1 << M4)    // 4 minutes (non-standard)
#define M5B (1 << M5)    // 5 minutes
#define M6B (1 << M6)    // 6 minutes (non-standard)
#define M10B (1 << M10)  // 10 minutes (non-standard)
#define M12B (1 << M12)  // 12 minutes (non-standard)
#define M15B (1 << M15)  // 15 minutes
#define M20B (1 << M20)  // 20 minutes (non-standard)
#define M30B (1 << M30)  // 30 minutes
#define H1B (1 << H1)    // 1 hour
#define H2B (1 << H2)    // 2 hours (non-standard)
#define H3B (1 << H3)    // 3 hours (non-standard)
#define H4B (1 << H4)    // 4 hours
#define H6B (1 << H6)    // 6 hours (non-standard)
#define H8B (1 << H8)    // 8 hours (non-standard)
#define H12B (1 << H12)  // 12 hours (non-standard)
#define D1B (1 << D1)    // Daily
#define W1B (1 << W1)    // Weekly
#define MN1B (1 << MN1)  // Monthly

#ifndef __MQL4__
// Chart.
#define CHART_BAR 0
#define CHART_CANDLE 1
//---
#ifndef MODE_ASCEND
#define MODE_ASCEND 0
#endif
#ifndef MODE_DESCEND
#define MODE_DESCEND 1
#endif
//---
#define MODE_LOW 1
#define MODE_HIGH 2
// --
#define MODE_OPEN 0
#define MODE_CLOSE 3
#define MODE_VOLUME 4
#define MODE_REAL_VOLUME 5
// --
#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_TICK_SIZE 21
#define MODE_TICK_VALUE 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_SWAPTYPE 26
#define MODE_PROFITCALCMODE 27
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33
#endif

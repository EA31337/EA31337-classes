# EA31337-classes

EA31337 framework for writing trading robots for MetaTrader 4 and 5 platforms.

## Build status

| Type            | Status      |
| --------------: |:-----------:|
| Travis CI build | [![Build Status](https://api.travis-ci.org/EA31337/EA-Tester.svg?branch=master)](https://travis-ci.org/EA31337/EA-Tester) |
| AppVeyor build  | [![Build status](https://ci.appveyor.com/api/projects/status/543yj94k3m50gy0g/branch/master?svg=true)](https://ci.appveyor.com/project/kenorb/ea31337-classes/branch/master) |

### Class hierarchy

    .
    |-- Account (Orders)
    |-- Terminal (Log)
    |   |-- SymbolInfo
    |   |   |-- Market
    |   |   |   |-- Chart
    |   |   |   |   |-- Draw
    |   |   |   |   |-- Indicator
    |   |-- Tester
    |   |-- Session
    |   |   |-- Check
    |   |   |-- Registry
    |   |   |-- RegistryBinary
    |   |   |-- File
    |-- Trade (Account, Chart, Log)
    |-- Order (Market)
    |-- Strategy (String, Trade)
    |-- Indicators
    |-- Strategies
    |-- Rules (Condition, Action)
    |-- Array
    |-- DateTime
    |-- BasicTrade
    |-- Convert
    |-- Inet
    |-- MD5
    |-- MQL4
    |-- Mail
    |-- Math
    |-- Misc
    |-- Msg
    |-- Report
    |-- SVG
    |-- SetFile
    |-- Stats
    |-- SummaryReport
    |-- Task
    |-- Tests
    |-- Ticker
    |-- Timer (Object)

### `Timer` class

The purpose of`Timer` class is to measure time between starting and stopping points.

### Example 1

Single timer:

```
#include "Timer.mqh"

Timer *timer = new Timer("mytimer");
timer.Start();
// Some code to measure here.
timer.Stop();
Print("Time (ms): ", timer.GetSum());
timer.PrintSummary();
delete timer;
```

### Example 2

Multiple measurements:

```
#include "Timer.mqh"

Timer *timer = new Timer(__FUNCTION__);
  for (uint i = 0; i < 5; i++) {
    timer.Start();
    Sleep(10); // Some code to measure here.
    PrintFormat("Current time elapsed before stop (%d/5): %d", i + 1, timer.GetTime());
    timer.Stop();
    PrintFormat("Current time elapsed after stop (%d/5): %d", i + 1, timer.GetTime(i));
  }
timer.PrintSummary();
delete timer;
```

### Support

- For bugs/features, raise a [new issue at GitHub](https://github.com/EA31337/EA31337-classes/issues).
- Join our [Telegram group](https://t.me/EA31337) and [channel](https://t.me/EA31337_Announcements) for support.

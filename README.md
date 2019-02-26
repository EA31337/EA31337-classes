# EA31337-classes

[![Join the chat at Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/EA31337/EA31337)

Class files.

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
// Some code here.
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
timer.Start();
  for (uint i = 0; i < 5; i++) {
    timer.Start();
    Sleep(10); // Some code here.
    PrintFormat("Current time elapsed before stop (%d/5): %d", i + 1, timer.GetTime());
    timer.Stop();
    PrintFormat("Current time elapsed after stop (%d/5): %d", i + 1, timer.GetTime(i));
  }
timer.PrintSummary();
delete timer;
```

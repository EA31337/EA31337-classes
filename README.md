# About the project

EA31337 framework is designed for writing trading robots for MetaTrader 4 and 5 platforms. It can be also used to convert your MQL4 code into MQL5 with minimum code changes.

## Table of contents

<!-- TOC -->

- [About the project](#about-the-project)
  - [Table of contents](#table-of-contents)
  - [Build status](#build-status)
  - [Conversion](#conversion)
    - [MQL4 to MQL5 conversion](#mql4-to-mql5-conversion)
  - [Classes](#classes)
    - [`Collection` class](#collection-class)
    - [`Dict` class](#dict-class)
      - [Example 1 - Storing string-int data structures](#example-1---storing-string-int-data-structures)
    - [`Mail` class](#mail-class)
      - [Example 1 - Send e-mail on trade execution](#example-1---send-e-mail-on-trade-execution)
    - [`Indicator` class](#indicator-class)
      - [Example 1 - Storing values](#example-1---storing-values)
    - [`IndicatorData` class](#indicatordata-class)
    - [`Profiler` class](#profiler-class)
      - [Example 1 - Measure execution time of function multiple times](#example-1---measure-execution-time-of-function-multiple-times)
      - [Example 2 - Measure execution time of function multiple times](#example-2---measure-execution-time-of-function-multiple-times)
    - [`Timer` class](#timer-class)
      - [Example 1 - Single timer](#example-1---single-timer)
      - [Example 2 - Multiple timers](#example-2---multiple-timers)
      - [Support](#support)

<!-- /TOC -->

## Build status

| Type            | Status      |
| --------------: |:-----------:|
| Travis CI build | [![Build Status](https://api.travis-ci.org/EA31337/EA31337-classes.svg?branch=master)](https://travis-ci.org/EA31337/EA31337-classes) |
| AppVeyor build  | [![Build status](https://ci.appveyor.com/api/projects/status/543yj94k3m50gy0g/branch/master?svg=true)](https://ci.appveyor.com/project/kenorb/ea31337-classes/branch/master) |

## Conversion

### MQL4 to MQL5 conversion

This framework can be used to convert your MQL4 code to be compatible with both MQL4 and MQL5.

Here is the table of conversion (replace code on left with right):

| MQL4 (original)      | MQL4 & MQL5 (replace with) | Required include file |
|:---------------------|:---------------------------|:----------------------|
| `WindowRedraw()`     | `Chart::WindowRedraw()`    | `Chart.mqh`           |
| `Day()`              | `DateTime::Day()` | `DateTime.mqh` |
| `TimeDayOfWeek()`    | `DateTime::DayOfWeek()` | `DateTime.mqh` |
| `DayOfWeek()`        | `DateTime::DayOfWeek()` | `DateTime.mqh` |
| `DayOfYear()`        | `DateTime::DayOfYear()` | `DateTime.mqh` |
| `Hour()`             | `DateTime::Hour()` | `DateTime.mqh` |
| `Month()`            | `DateTime::Month()` | `DateTime.mqh` |
| `TimeDay()`          | `DateTime::TimeDay()` | `DateTime.mqh` |
| `TimeDayOfYear()`    | `DateTime::TimeDayOfYear()` | `DateTime.mqh` |
| `TimeToStr()`        | `DateTime::TimeToStr()` | `DateTime.mqh` |
| `Year()`             | `DateTime::Year()` | `DateTime.mqh` |
| `iAC()`              | `Indi_AC::iAC()` | `Indicators/Indi_AC.mqh` |
| `iAD()`              | `Indi_AD::iAD()` | `Indicators/Indi_AD.mqh` |
| `iADX()`             | `Indi_ADX::iADX()` | `Indicators/Indi_ADX.mqh` |
| `iAO()`              | `Indi_AO::iAO()` | `Indicators/Indi_AO.mqh` |
| `iATR()`             | `Indi_ATR::iATR()` | `Indicators/Indi_ATR.mqh` |
| `iBWMFI()`           | `Indi_BWMFI::iBWMFI()` | `Indicators/Indi_BWMFI.mqh` |
| `iBands()`           | `Indi_Bands::iBands()` | `Indicators/Indi_Bands.mqh` |
| `iBearsPower()`      | `Indi_BearsPower::iBearsPower()` | `Indicators/Indi_BearsPower.mqh` |
| `iBullsPower()`      | `Indi_BullsPower::iBullsPower()` | `Indicators/Indi_BullsPower.mqh` |
| `iCCI()`             | `Indi_CCI::iCCI()` | `Indicators/Indi_CCI.mqh` |
| `iDeMarker()`        | `Indi_DeMarker::iDeMarker()` | `Indicators/Indi_DeMarker.mqh` |
| `iEnvelopes()`       | `Indi_Envelopes::iEnvelopes()` | `Indicators/Indi_Envelopes.mqh` |
| `iForce()`           | `Indi_Force::iForce()` | `Indicators/Indi_Force.mqh` |
| `iFractals()`        | `Indi_Fractals::iFractals()` | `Indicators/Indi_Fractals.mqh` |
| `iGator()`           | `Indi_Gator::iGator()` | `Indicators/Indi_Gator.mqh` |
| `iIchimoku()`        | `Indi_Ichimoku::iIchimoku()` | `Indicators/Indi_Ichimoku.mqh` |
| `iMA()`              | `Indi_MA::iMA()` | `Indicators/Indi_MA.mqh` |
| `iMACD()`            | `Indi_MAcD::iMACD()` | `Indicators/Indi_MACD.mqh` |
| `iMFI()`             | `Indi_MFI::iMFI()` | `Indicators/Indi_MFI.mqh` |
| `iMomentum()`        | `Indi_Momentum::iMomentum()` | `Indicators/Indi_Momentum.mqh` |
| `iOBV()`             | `Indi_OBV::iOBV()` | `Indicators/Indi_OBV.mqh` |
| `iOsMA()`            | `Indi_OsMA::iOsMA()` | `Indicators/Indi_OsMA.mqh` |
| `iRSI()`             | `Indi_RSI::iRSI()` | `Indicators/Indi_RSI.mqh` |
| `iRVI()`             | `Indi_RVI::iRVI()` | `Indicators/Indi_RVI.mqh` |
| `iSAR()`             | `Indi_SAR::iSAR()` | `Indicators/Indi_SAR.mqh` |
| `iStdDev()`          | `Indi_StdDev::iStdDev()` | `Indicators/Indi_StdDev.mqh` |
| `iStochastic()`      | `Indi_Stochastic::iStochastic()` | `Indicators/Indi_Stochastic.mqh` |
| `iWPR()`             | `Indi_WPR::iWPR()` | `Indicators/Indi_WPR.mqh` |
| `RefreshRates()`     | `Market::RefreshRates()` | `Market.mqh` |
| `delete object`      | `Object::Delete(object)` | `Object.mqh` |
| `GetOrderProfit()`   | `Order::GetOrderProfit()` | `Order.mqh` |
| `OrderClose()`       | `Order::OrderClose()` | `Order.mqh` |
| `OrderCloseTime()`   | `Order::OrderCloseTime()` | `Order.mqh` |
| `OrderCommission()`  | `Order::OrderCommission()` | `Order.mqh` |
| `OrderLots()`        | `Order::OrderLots()` | `Order.mqh` |
| `OrderMagicNumber()` | `Order::OrderMagicNumber()` | `Order.mqh` |
| `OrderOpenPrice()`   | `Order::OrderOpenPrice()` | `Order.mqh` |
| `OrderOpenTime()`    | `Order::OrderOpenTime()` | `Order.mqh` |
| `OrderPrint()`       | `Order::OrderPrint()` | `Order.mqh` |
| `OrderSelect()`      | `Order::OrderSelect()` | `Order.mqh` |
| `OrderStopLoss()`    | `Order::OrderStopLoss()` | `Order.mqh` |
| `OrderSymbol()`      | `Order::OrderSymbol()` | `Order.mqh` |
| `OrderTicket()`      | `Order::OrderTicket()` | `Order.mqh` |
| `OrderType()`        | `Order::OrderType()` | `Order.mqh` |
| `OrdersTotal()`      | `Orders::OrdersTotal()` | `Order.mqh` |

Here are the special [predefined variables](https://docs.mql4.com/predefined) conversion:

| MQL4 (original)      | MQL4 & MQL5 (replace with) | Required include file |
|:---------------------|:-----------------------------|:-----------------|
| `Ask`                | `SymbolInfo::GetAsk()`       | `SymbolInfo.mqh` |
| `Bars`               | `Chart::iBars()`             | `Chart.mqh`      |
| `Bid`                | `SymbolInfo::GetBid()`       | `SymbolInfo.mqh` |
| `Close[]`            | `Chart::iClose()`            | `Chart.mqh`      |
| `Digits`             | `SymbolInfo::GetDigits()`    | `SymbolInfo.mqh` |
| `High[]`             | `Chart::iHigh()`             | `Chart.mqh`      |
| `Low[]`              | `Chart::iLow()`              | `Chart.mqh`      |
| `Open[]`             | `Chart::iOpen()`             | `Chart.mqh`      |
| `Point`              | `SymbolInfo::GetPointSize()` | `SymbolInfo.mqh` |
| `Time[]`             | `Chart::iTime()`             | `Chart.mqh`      |
| `Volume[]`           | `Chart::iVolume()`           | `Chart.mqh`      |

## Classes

### `Collection` class

This class is for storing various type of objects. Here is the example usage:

    // Define custom classes of Object type.
    class Stack : Object {
      public:
        virtual string GetName() = NULL;
    };
    class Foo : Stack {
      public:
        string GetName() { return "Foo"; };
        double Weight() { return 0; };
    };
    class Bar : Stack {
      public:
        string GetName() { return "Bar"; };
        double Weight() { return 1; };
    };
    class Baz : Stack {
      public:
        string GetName() { return "Baz"; };
        double Weight() { return 2; };
    };

    int OnInit() {
      // Define and add items.
      Collection *stack = new Collection();
      stack.Add(new Foo);
      stack.Add(new Bar);
      stack.Add(new Baz);
      // Print the lowest and the highest items.
      Print("Lowest: ", ((Stack *)stack.GetLowest()).GetName());
      Print("Highest: ", ((Stack *)stack.GetHighest()).GetName());
      // Print all the items.
      for (uint i = 0; i < stack.GetSize(); i++) {
        Print(i, ": ", ((Stack *)stack.GetByIndex(i)).GetName());
      }
      // Clean up.
      Object::Delete(stack);
      return (INIT_SUCCEEDED);
    }

### `Dict` class

Use this class to store the values in form of a collective attribute–value pairs, in similar way as [associative arrays](https://en.wikipedia.org/wiki/Associative_array) with a [hash table](https://en.wikipedia.org/wiki/Hash_table) work.

#### Example 1 - Storing string-int data structures

Example of storing key-value data with string as a key:

    Dict<string, int> data1;
    data1.Set("a", 1);
    data1.Set("b", 2);
    data1.Set("c", 3);
    data1.Unset("c");
    Print(data1.GetByKey("a"));

### `Mail` class

The purpose of `Mail` class is to provide common functionality for managing e-mails.

#### Example 1 - Send e-mail on trade execution

Example sending e-mail on trade execution:

    int OnInit() { // @see: https://www.mql5.com/en/docs/event_handlers/oninit
      Mail *mail = new Mail();
      mail.SetSubjectPrefix("Trading");
    }
    void OnTrade() { // @see: https://www.mql5.com/en/docs/event_handlers/ontrade
      if (!Terminal::IsRealtime()) {
        mail.SendMailExecuteOrder();
      }
    }
    int OnDeinit() { // @see: https://www.mql5.com/en/docs/event_handlers/ondeinit
      delete mail;
    }

### `Indicator` class

The purpose of `Indicator` class is to provide common functionality across all indicators such as storing and searching for values.

This class is used as a base class to handle technical indicator classes which can be found in [`Indicators/`](Indicators/) folder.

It can be used for storing and reading variables as shown below.

#### Example 1 - Storing values

Example usage for storing values:

    IndicatorParams iparams;
    Indicator *in = new Indicator(iparams);
    in.SetName("MyIndicator");
    MqlParam entry;
    entry.integer_value = 1;
    in.AddValue(entry);
    entry.integer_value = 2;
    in.AddValue(entry);
    Print(in.GetName(), "; ", in.ToString());
    delete in;

To change maximum buffer values to keep, initialize IndicatorParams with constructor, e.g.

    IndicatorParams iparams(10, INDI_NONE, TYPE_INT);

### `IndicatorData` class

The purpose of `IndicatorData` class is to store indicator data. It is basically alternative implementation of `Indicator` class.

For more details, please read: [Class to hold indicator values](https://github.com/EA31337/EA31337-classes/issues/23).

For implementation example, check [`tests/IndicatorDataTest.mq4`](tests/IndicatorDataTest.mq4).

### `Profiler` class

The purpose of `Profiler` class is to profile functions by measuring its time of execution. The minimum threshold can be set, so only slow execution can be reported.

#### Example 1 - Measure execution time of function multiple times

Example to measure execution time of function multiple times, then printing the summary of all calls which took 5ms or more.

    #include "Profiler.mqh"

    void MyFunction() {
      PROFILER_START
      Sleep(rand()%10);
      PROFILER_STOP
    }

    int OnInit() {
      for (uint i = 0; i < 10; i++) {
        MyFunction();
      }
      // Set minimum threshold of 5ms.
      PROFILER_SET_MIN(5)
      // Print summary of slow executions above 5ms.
      PROFILER_PRINT
      return (INIT_SUCCEEDED);
    }

    void OnDeinit(const int reason) {
      PROFILER_DEINIT
    }

#### Example 2 - Measure execution time of function multiple times

Example to measure execution time of function multiple times, then automatically printing all calls which took 5ms or more.

    #include "Profiler.mqh"

    void MyFunction() {
      PROFILER_START
      Sleep(rand()%10);
      // Automatically prints slow executions.
      PROFILER_STOP_PRINT
    }

    int OnInit() {
      // Set minimum threshold of 5ms.
      PROFILER_SET_MIN(5);
      for (uint i = 0; i < 10; i++) {
        MyFunction();
      }
      return (INIT_SUCCEEDED);
    }

    void OnDeinit(const int reason) {
      PROFILER_DEINIT
    }

### `Timer` class

The purpose of`Timer` class is to measure time between starting and stopping points.

#### Example 1 - Single timer

Single timer:

    #include "Timer.mqh"

    Timer *timer = new Timer("mytimer");
    timer.Start();
    // Some code to measure here.
    timer.Stop();
    Print("Time (ms): ", timer.GetSum());
    timer.PrintSummary();
    delete timer;

#### Example 2 - Multiple timers

Multiple measurements:

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

#### Support

- For bugs/features, raise a [new issue at GitHub](https://github.com/EA31337/EA31337-classes/issues).
- Join our [Telegram group](https://t.me/EA31337) and [channel](https://t.me/EA31337_Announcements) for support.

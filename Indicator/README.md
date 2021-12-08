# Indicator

Indicator classes are intended for implementation of technical indicators.

They can help with storing and accessing values and indicator parameters.

## `IndicatorBase`

An abstract class for all type of indicators (a base class).

## `Indicator`

An abstract class (subclass of `IndicatorBase`) to implement all type of indicators.

It implements structure for storing input parameters
and buffer for accessing cached values by a given timestamp.

## `IndicatorCandle`

An abstract class (subclass of `IndicatorBase`) to implement candle indicators.

It aims at managing prices by grouping them into OHLC chart candles.

## `IndicatorRenko`

(to be added)

An abstract class (subclass of `IndicatorCandle`) to implement Renko indicators.

It aims at managing prices by splitting them based solely on price movements.

It can accept `IndicatorTick` as a data source.

## `IndicatorTf`

An abstract class (subclass of `IndicatorCandle`)
to implement timeframe indicators.

It aims at storing prices by grouping them based on standardized time intervals
(e.g. M1, M2, M5).

An instance has information about timeframe.

Information about symbol can be accessed through the tick indicator.

It can accept `IndicatorTick` as a data source.

## `IndicatorTick`

An abstract class (subclass of `IndicatorBase`) to implement tick indicators.

It aims at managing bid and ask prices and can be used as data source.

An instance has information about symbol, but it doesn't have timeframe.

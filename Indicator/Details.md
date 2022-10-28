# Explanation of shift parameters in Indicator/IndicatorData classes for following methods:
- `GetEntryValue(int _mode, int _abs_shift)`
- `GetEntryAlter(IndicatorDataEntry &_entry, int _rel_shift)`
- `GetValue(int _mode = 0, int _rel_shift = 0)`
- `GetEntry(int _rel_shift = 0)`

## GetEntryValue(int _mode, int _abs_shift) - overridable method

Method must be overriden in any new indicator and MUST NOT apply shift from `iparams.shift`/`iparams.GetShift()`! Shift 0 must always point to the value for the current tick.

Returns indicators's value for a given mode and absolute shift (the shift is directly passed to built-in methods such as iATR(), OnCalculate methods such as `iVIDyAOnIndicator()` and also to `iCustom()`).

For `OnCalculate()` methods such as iVIDyAOnIndicator(), the shift is passed to `return _cache.GetTailValue<double>(_mode, _shift);` so we can return value calculated in the past (or just retrieve **DBL_MAX** in case the value was not yet calculated).
Note that `OnCalculate()` methods uses single/multiple price buffers, e.g., applied price or OHLCs from base indicator.

In scenario of `VIDyA[shift = 2] <- Candle <- TickMt` call hierarchy looks like:
```cpp
- VIDyA::GetEntry(_rel_shift = 1) // Then per each mode:
- entry.values[_mode] = Indicator::GetValue(_mode, _rel_shift = 1)
- VIDyA::GetEntryValue(_mode, _abs_shift = iparams.shift + 1)
- VIDyA::iVIDyAOnIndicator(..., _mode, _shift = 3) then: // Shift is absolute.
- VIDyA::iVIDyAOnArray(..., _mode, _shift = 3) then: // Shift is absolute.
  return _cache.GetTailValue<double>(_mode, _shift = 3); // Shift is absolute.
```
Last line means that we will retrieve **VIDyA** value shifted by 3 (2 from `iparams.shift` + 1 from `GetEntry()`). It is correct.

## GetEntryAlter(IndicatorDataEntry &_entry, int _rel_shift) - overridable method

Shift passed is relative to the shift from `IndicatorParams::shift` (read via `Indicator::iparams.shift`).

Method calls (seen in **MWMFI**, **CCI**, **Envelopes**, **Momentum**, **Pivot**):
```cpp
- GetValue<double>(_mode, _rel_shift) // GetValue<T>() takes relative shift.
```

## GetValue(int _mode = 0, int _rel_shift = 0) - non-overridable method

Shift passed is relative to the shift from `IndicatorParams::shift` (read via `Indicator::iparams.shift`).

Method calls:
```cpp
- GetEntryValue(_mode, _abs_shift = iparams.shift + _rel_shift)
```

## GetEntry(int _rel_shift = 0) - overridable method

Shift passed is relative to the shift from `IndicatorParams::shift` (read via `Indicator::iparams.shift`).

If you need to access entries from absolute shift, use `GetEntryByAbsShift(int _abs_shift)`.

Note that values accessed via index operator `storage[rel_shift]` e.g., inside `OnCalculate()` methods like `double _o = open[rel_shift = 4].Get()` will take relative shift and retrieve open price shifted by (in this scenario) `4 + iparams.shift` set in base indicator:
```cpp
- double _o = open[_rel_shift = 4]
- IndicatorBufferValueStorage::Fetch(_rel_shift = 4)
- IndicatorData::GetValue(_mode, _rel_shift = 4)
- Indicator::GetEntryValue(_mode, _abs_shift = iparams.shift + 4) // As GetEntryValue() takes absolute shift, we add shift from iparams.shift.
- Indicator::GetEntry(_rel_shift = _abs_shift - iparams.shift)... // Converting absolute shift into relative one for GetEntry().
- ...[_mode]; // IndicatorDataEntry.values[_mode].Get(...);
```
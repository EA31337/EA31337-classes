//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
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
 * Inline method bodies for PlatformTime that require complete IndicatorBase/IndicatorData types.
 *
 * This file must be included AFTER both IndicatorBase and IndicatorData class definitions are
 * available (i.e. from the end of IndicatorData.h). It must NOT be included from PlatformTime.h
 * itself, to avoid a circular include through Serializer.h -> Convert.basic.h -> DateTime.h.
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

// Includes the full indicator types (safe here because IndicatorData.h is already processed).
#include "../Indicator/IndicatorBase.h"
#include "../Indicator/IndicatorData.h"

// Static member definition (must appear in exactly one translation unit).
// Since IndicatorData.h is designed to be included from a single TU in WASM builds, this is safe here.
IndicatorBase* PlatformTime::current_tick_indicator = nullptr;

inline int64 PlatformTime::TimeCurrent() {
  if (current_tick_indicator == nullptr) {
    Print("Error: Current tick indicator is not set. TimeCurrent() will return 0 and is unusable. You should use IndicatorTest/Platform::Tick() method to run ticks.");
    DebugBreak();
    return 0;
  }

  Print("Retrieving current time from current tick indicator: ", current_tick_indicator PTR_DEREF GetFullName(), " with time ", current_tick_indicator PTR_DEREF GetTimeCurrent());

  return current_tick_indicator PTR_DEREF GetTimeCurrent();
}

inline int64 PlatformTime::CurrentTimestampMs() {
  if (current_tick_indicator == nullptr) {
    return 0;
  }
  return current_tick_indicator PTR_DEREF GetTimeCurrent() * 1000;
}

inline MqlDateTime PlatformTime::CurrentTime() {
  if (current_tick_indicator == nullptr) {
    Print("Warning: Current tick indicator is not set. Returning 0 as current time.");
    DebugBreak();
    return MqlDateTime{0, 0, 0, 0, 0, 0, 0, 0};
  }

  MqlDateTime dt;
  TimeToStruct(current_tick_indicator PTR_DEREF GetTimeCurrent(), dt);
  return dt;
}

inline void PlatformTime::SetCurrentIndicator(IndicatorData* _indi) {
  current_tick_indicator = _indi PTR_DEREF GetTick();
}

inline void PlatformTime::UpdateLastTickTimeMs(int64 tick_time_ms, IndicatorData* _source_indi) {
  if (current_tick_indicator != _source_indi) {
    Print("Warning: Currently ticking indicator is not the same as indicator calling PlatformTime::Update()! Returning without updating time.");
    DebugBreak();
    return;
  }
  current_tick_indicator PTR_DEREF UpdateLastTickTimeMs(tick_time_ms);
}

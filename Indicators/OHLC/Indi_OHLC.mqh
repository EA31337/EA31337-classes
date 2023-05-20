//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
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

// Includes.
#include "../../BufferStruct.mqh"
#include "../../Indicator/IndicatorTickOrCandleSource.h"
#include "../../Storage/Objects.h"

// Enums.
enum ENUM_INDI_OHLC_MODE {
  INDI_OHLC_CLOSE = 0,
  INDI_OHLC_OPEN,
  INDI_OHLC_HIGH,
  INDI_OHLC_LOW,
  FINAL_INDI_OHLC_MODE_ENTRY,
};

// Structs.
struct IndiOHLCParams : IndicatorParams {
  // Struct constructor.
  IndiOHLCParams(int _shift = 0) : IndicatorParams(INDI_OHLC) { SetShift(_shift); };
  IndiOHLCParams(IndiOHLCParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  };
};

/**
 * OHLC Indicator.
 */
class Indi_OHLC : public IndicatorTickOrCandleSource<IndiOHLCParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_OHLC(IndiOHLCParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : IndicatorTickOrCandleSource(_p,
                                    IndicatorDataParams::GetInstance(FINAL_INDI_OHLC_MODE_ENTRY, TYPE_DOUBLE, _idstype,
                                                                     IDATA_RANGE_PRICE, _indi_src_mode),
                                    _indi_src){};
  Indi_OHLC(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT, int _shift = 0)
      : IndicatorTickOrCandleSource(INDI_PRICE, _tf, _shift){};

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = 0) {
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    ENUM_APPLIED_PRICE _ap = PRICE_OPEN;
    switch (_mode) {
      case INDI_OHLC_CLOSE:
        _ap = PRICE_CLOSE;
        break;
      case INDI_OHLC_OPEN:
        _ap = PRICE_OPEN;
        break;
      case INDI_OHLC_HIGH:
        _ap = PRICE_HIGH;
        break;
      case INDI_OHLC_LOW:
        _ap = PRICE_LOW;
        break;
    }
    return ChartStatic::iPrice(_ap, GetSymbol(), GetTf(), _ishift);
  }

  /**
   * Returns already cached version of Indi_OHLC for a given parameters.
   */
  static Indi_OHLC *GetCached(string _symbol, ENUM_TIMEFRAMES _tf, int _shift) {
    String _cache_key;
    _cache_key.Add(_symbol);
    _cache_key.Add((int)_tf);
    _cache_key.Add(_shift);
    string _key = _cache_key.ToString();
    Indi_OHLC *_indi_ohlc;
    if (!Objects<Indi_OHLC>::TryGet(_key, _indi_ohlc)) {
      IndiOHLCParams _indi_ohlc_params(_shift);
      _indi_ohlc_params.SetTf(_tf);
      _indi_ohlc = Objects<Indi_OHLC>::Set(_key, new Indi_OHLC(_indi_ohlc_params));
      _indi_ohlc.SetSymbol(_symbol);
    }
    return _indi_ohlc;
  }
};

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

// Includes.
#include "../../BufferStruct.mqh"
#include "../../Indicator/Indicator.h"
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
  IndiOHLCParams(IndiOHLCParams &_params) { THIS_REF = _params; };
};

/**
 * OHLC Indicator.
 */
class Indi_OHLC : public Indicator<IndiOHLCParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_OHLC(IndiOHLCParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(_p,
                  IndicatorDataParams::GetInstance(FINAL_INDI_OHLC_MODE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE,
                                                   _indi_src_mode),
                  _indi_src){};
  Indi_OHLC(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_BUILTIN, IndicatorData *_indi_src = NULL,
            int _indi_src_mode = 0)
      : Indicator(IndiOHLCParams(),
                  IndicatorDataParams::GetInstance(FINAL_INDI_OHLC_MODE_ENTRY, TYPE_DOUBLE, _idstype, IDATA_RANGE_PRICE,
                                                   _indi_src_mode),
                  _indi_src){};
  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_CUSTOM; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_BUILTIN; }

  /**
   * Checks whether given data source satisfies our requirements.
   */
  bool OnCheckIfSuitableDataSource(IndicatorData *_ds) override {
    if (Indicator<IndiOHLCParams>::OnCheckIfSuitableDataSource(_ds)) {
      return true;
    }

    // OHLC are required from data source.
    return _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_OPEN) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_HIGH) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_LOW) &&
           _ds PTR_DEREF HasSpecificAppliedPriceValueStorage(PRICE_CLOSE);
  }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
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
    return GetDataSource() PTR_DEREF GetPrice(_ap, _shift);
  }
};

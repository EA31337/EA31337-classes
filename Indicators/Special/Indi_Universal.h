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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

// Includes.
#include "../../Indicator/Indicator.h"
#include "../Price/Indi_Price.h"

// Structs.
struct IndiUniversalParams : IndicatorParams {
  unsigned int mode_1;
  unsigned int shift_1;

  // Struct constructor.
  IndiUniversalParams(unsigned int _mode_1 = 0, unsigned int _shift_1 = 0, int _shift = 0)
      : IndicatorParams(INDI_SPECIAL_UNIVERSAL) {
    mode_1 = _mode_1;
    shift = _shift;
    shift_1 = _shift_1;
  };

  IndiUniversalParams(IndiUniversalParams &_params) { THIS_REF = _params; };
};

/**
 * Implements the Universal indicator.
 */
class Indi_Universal : public Indicator<IndiUniversalParams> {
 protected:
  /**
   * Initialize.
   */
  void Init() {
    if (!indi_src.IsSet()) {
      indi_src = new Indi_Price();
    }
  }

 public:
  /**
   * Class constructor.
   */
  Indi_Universal(IndiUniversalParams &_p, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_INDICATOR,
                 IndicatorData *_indi_src = NULL, int _indi_src_mode = 0)
      : Indicator(_p, IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {
    Init();
  };
  Indi_Universal(int _shift = 0, ENUM_IDATA_SOURCE_TYPE _idstype = IDATA_INDICATOR, IndicatorData *_indi_src = NULL,
                 int _indi_src_mode = 0)
      : Indicator(IndiUniversalParams(),
                  IndicatorDataParams::GetInstance(1, TYPE_DOUBLE, _idstype, IDATA_RANGE_MIXED, _indi_src_mode),
                  _indi_src) {
    Init();
  };

  /**
   * Returns possible data source types. It is a bit mask of ENUM_INDI_SUITABLE_DS_TYPE.
   */
  unsigned int GetSuitableDataSourceTypes() override { return INDI_SUITABLE_DS_TYPE_EXPECT_ANY; }

  /**
   * Returns possible data source modes. It is a bit mask of ENUM_IDATA_SOURCE_TYPE.
   */
  unsigned int GetPossibleDataModes() override { return IDATA_INDICATOR; }

  /**
   * Returns the indicator's value.
   */
  virtual IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _abs_shift = 0) {
    IndicatorDataEntryValue _value = EMPTY_VALUE;
    switch (Get<ENUM_IDATA_SOURCE_TYPE>(STRUCT_ENUM(IndicatorDataParams, IDATA_PARAM_IDSTYPE))) {
      case IDATA_INDICATOR:
        if (!indi_src.IsSet()) {
          logger REF_DEREF Error(
              "In order use custom indicator as a source, you need to select one using SetIndicatorData() method, "
              "which is a part of IndiUniversalParams structure.",
              "Indi_Universal");
          Alert(
              "Indi_Universal: In order use custom indicator as a source, you need to select one using "
              "SetIndicatorData() "
              "method, which is a part of IndiUniversalParams structure.");
          SetUserError(ERR_INVALID_PARAMETER);
          return _value;
        }
        _value = indi_src REF_DEREF GetEntryValue(_mode, _abs_shift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        break;
    }
    return _value;
  }

  /* Getters */

  /**
   * Whether we can and have to select mode when specifying data source.
   */
  virtual bool IsDataSourceModeSelectable() { return false; }
};

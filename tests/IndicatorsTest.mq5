//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2022, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of Indicator class.
 */

// Defines.
// #define __debug__  // Enables debug.
// #define __debug_verbose__

// Forward declaration.
struct DataParamEntry;

// Includes.
//#include "../ChartMt.h"
#include "../Dict.mqh"
#include "../DictObject.mqh"
#include "../Indicator/Indicator.h"
#include "../Indicator/tests/classes/IndicatorTfDummy.h"
#include "../Indicators/Bitwise/indicators.h"
#include "../Indicators/Tick/Indi_TickMt.mqh"
#include "../Indicators/indicators.h"
#include "../Platform.h"
#include "../SerializerConverter.mqh"
#include "../SerializerJson.mqh"
#include "../Std.h"
#include "../Test.mqh"

// Custom indicator identifiers.
enum ENUM_CUSTOM_INDICATORS { INDI_SPECIAL_MATH_CUSTOM = FINAL_INDICATOR_TYPE_ENTRY + 1 };

// Global variables.
DictStruct<int, Ref<IndicatorData>> indis;
DictStruct<int, Ref<IndicatorData>> whitelisted_indis;
DictStruct<int, Ref<IndicatorData>> tested;
double test_values[] = {1.245, 1.248, 1.254, 1.264, 1.268, 1.261, 1.256, 1.250, 1.242, 1.240, 1.235,
                        1.240, 1.234, 1.245, 1.265, 1.274, 1.285, 1.295, 1.300, 1.312, 1.315, 1.320,
                        1.325, 1.335, 1.342, 1.348, 1.352, 1.357, 1.359, 1.422, 1.430, 1.435};
Ref<Indi_Drawer> _indi_drawer;
Ref<IndicatorData> _indi_test;

/**
 * Implements Init event handler.
 */
int OnInit() {
  Platform::Init();
  bool _result = true;
  Print("We have ", Bars(NULL, 0), " bars to analyze");
  // Initialize indicators.
  _result &= InitIndicators();

  Print("Indicators to test: ", indis.Size());

  Print("Connecting candle and tick indicators to all indicators...");
  // Connecting all indicators to default candle indicator (which is connected to default tick indicator).
  for (DictStructIterator<int, Ref<IndicatorData>> iter = indis.Begin(); iter.IsValid(); ++iter) {
    Platform::AddWithDefaultBindings(iter.Value().Ptr(), _Symbol, PERIOD_CURRENT);
  }

  // Check for any errors.
  assertEqualOrFail(_LastError, ERR_NO_ERROR, StringFormat("Error: %d", GetLastError()));
  ResetLastError();
  // Print indicator values.

  _result &= PrintIndicators(__FUNCTION__);
  assertEqualOrFail(_LastError, ERR_NO_ERROR, StringFormat("Error: %d", GetLastError()));
  ResetLastError();

  return (_result && _LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements Tick event handler.
 */
void OnTick() {
  Platform::Tick();
  IndicatorData* _candles = Platform::FetchDefaultCandleIndicator(_Symbol, PERIOD_CURRENT);

  if (_candles PTR_DEREF IsNewBar()) {
    if (_candles PTR_DEREF GetBarIndex() > 200) {
      ExpertRemove();
  }

    if (indis.Size() == 0) {
      return;
    }

    for (DictStructIterator<int, Ref<IndicatorData>> iter = indis.Begin(); iter.IsValid(); ++iter) {
      if (whitelisted_indis.Size() == 0) {
        if (tested.Contains(iter.Value())) {
          // Indicator is already tested, skipping.
          continue;
        }
      } else {
        if (!whitelisted_indis.Contains(iter.Value())) {
          continue;
        }
      }

      IndicatorData* _indi = iter.Value().Ptr();
      IndicatorDataEntry _entry(_indi PTR_DEREF GetEntry());

      if (_indi PTR_DEREF Get<bool>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
        if (_entry.IsValid()) {
          PrintFormat("%s: bar %d: %s", _indi PTR_DEREF GetFullName(), _candles PTR_DEREF GetBars(),
                      _indi PTR_DEREF ToString());
          tested.Push(iter.Value());  // Mark as tested.
        }
      }
    }
  }
}

/**
 * Implements Deinit event handler.
 */
void OnDeinit(const int reason) {
  int num_not_tested = 0;
  for (DictStructIterator<int, Ref<IndicatorData>> iter = indis.Begin(); iter.IsValid(); ++iter) {
    if (!tested.Contains(iter.Value())) {
      PrintFormat("%s: Indicator not tested: %s", __FUNCTION__, iter.Value().Ptr().GetFullName());
      ++num_not_tested;
    }
  }

  PrintFormat("%s: Indicators not tested: %d", __FUNCTION__, num_not_tested);
  assertTrueOrExit(num_not_tested == 0, "Not all indicators has been tested!");
}

/**
 * Initialize indicators.
 */
bool InitIndicators() {
  /* Price/OHLC indicators */

  // Price indicator.
  Ref<IndicatorData> indi_price = new Indi_Price(PriceIndiParams());
  // indis.Push(indi_price); // @fixme: Make it work with the test?

  /* Standard indicators */

  // AC.
  indis.Push(new Indi_AC());

  // AD.
  indis.Push(new Indi_AD());

  // ADX.
  IndiADXParams adx_params(14);
  indis.Push(new Indi_ADX(adx_params));

  // Alligator.
  IndiAlligatorParams alli_params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  indis.Push(new Indi_Alligator(alli_params));

  // Awesome Oscillator (AO).
  indis.Push(new Indi_AO());

  // Accumulation Swing Index (ASI).
  IndiASIParams _asi_params;
  indis.Push(new Indi_ASI(_asi_params));

  // Average True Range (ATR).
  IndiATRParams atr_params(14);
  indis.Push(new Indi_ATR(atr_params));

  // Bollinger Bands - Built-in.
  IndiBandsParams bands_params(20, 2, 0, PRICE_OPEN);
  Ref<IndicatorData> indi_bands = new Indi_Bands(bands_params);
  indis.Push(indi_bands);
  // whitelisted_indis.Push(indi_bands);

  // Bollinger Bands - OnCalculate.
  Ref<IndicatorData> indi_bands_oncalculate = new Indi_Bands(bands_params, IDATA_ONCALCULATE);
  indis.Push(indi_bands_oncalculate);
  // whitelisted_indis.Push(indi_bands_oncalculate);

  // Bears Power.
  IndiBearsPowerParams bears_params(13, PRICE_CLOSE);
  indis.Push(new Indi_BearsPower(bears_params));

  // Bulls Power.
  IndiBullsPowerParams bulls_params(13, PRICE_CLOSE);
  indis.Push(new Indi_BullsPower(bulls_params));

  // Market Facilitation Index (BWMFI).
  IndiBWIndiMFIParams _bwmfi_params(1);
  indis.Push(new Indi_BWMFI(_bwmfi_params));

  // Commodity Channel Index (CCI).
  IndiCCIParams cci_params(14, PRICE_OPEN);
  indis.Push(new Indi_CCI(cci_params));

  // DeMarker.
  IndiDeMarkerParams dm_params(14);
  indis.Push(new Indi_DeMarker(dm_params));

  // Envelopes.
  IndiEnvelopesParams env_params(13, 0, MODE_SMA, PRICE_OPEN, 2);
  indis.Push(new Indi_Envelopes(env_params));

  // Force Index.
  IndiForceParams force_params(13, MODE_SMA, PRICE_CLOSE);
  indis.Push(new Indi_Force(force_params));

  // Fractals.
  indis.Push(new Indi_Fractals());

  // Fractal Adaptive Moving Average (FRAMA).
  IndiFrAIndiMAParams frama_params();
  indis.Push(new Indi_FrAMA(frama_params));

  // Gator Oscillator.
  IndiGatorParams gator_params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  indis.Push(new Indi_Gator(gator_params));

  // Heiken Ashi.
  IndiHeikenAshiParams _ha_params();
  indis.Push(new Indi_HeikenAshi(_ha_params));

  // Ichimoku Kinko Hyo.
  IndiIchimokuParams ichi_params(9, 26, 52);
  indis.Push(new Indi_Ichimoku(ichi_params));

  // Moving Average.
  IndiMAParams ma_params(13, 0, MODE_SMA, PRICE_OPEN);
  Ref<IndicatorData> indi_ma = new Indi_MA(ma_params);
  indis.Push(indi_ma);

  // DEMA.
  IndiDEMAParams dema_params(13, 2, PRICE_OPEN);
  Ref<IndicatorData> indi_dema = new Indi_DEMA(dema_params, INDI_DEMA_DEFAULT_IDSTYPE, indi_price.Ptr());
  // indis.Push(indi_dema); // @fixme

  // MACD.
  IndiMACDParams macd_params(12, 26, 9, PRICE_CLOSE);
  Ref<IndicatorData> macd = new Indi_MACD(macd_params);
  indis.Push(macd);

  // Money Flow Index (MFI).
  IndiMFIParams mfi_params(14);
  indis.Push(new Indi_MFI(mfi_params));

  // Momentum (MOM).
  IndiMomentumParams mom_params();
  indis.Push(new Indi_Momentum(mom_params));

  // On Balance Volume (OBV).
  indis.Push(new Indi_OBV());

  // OsMA.
  IndiOsMAParams osma_params(12, 26, 9, PRICE_CLOSE);
  indis.Push(new Indi_OsMA(osma_params));

  // Relative Strength Index (RSI).
  IndiRSIParams rsi_params(14, PRICE_OPEN);
  Ref<IndicatorData> indi_rsi = new Indi_RSI(rsi_params);
  indis.Push(indi_rsi.Ptr());

  // Bollinger Bands over RSI.
  IndiBandsParams indi_bands_over_rsi_params(20, 2, 0, PRICE_OPEN);
  Ref<IndicatorData> indi_bands_over_rsi = new Indi_Bands(indi_bands_over_rsi_params);
  // Using RSI's mode 0 as applied price.
  indi_bands_over_rsi REF_DEREF SetDataSourceAppliedPrice(INDI_VS_TYPE_INDEX_0);
  indi_bands_over_rsi REF_DEREF SetDataSource(indi_rsi.Ptr());
  indis.Push(indi_bands_over_rsi);

  // Standard Deviation (StdDev).
  IndiStdDevParams stddev_params(13, 10, MODE_SMA, PRICE_OPEN);
  Ref<IndicatorData> indi_stddev = new Indi_StdDev(stddev_params);
  indis.Push(indi_stddev);

  // Relative Strength Index (RSI) over Standard Deviation (StdDev).
  IndiRSIParams indi_rsi_over_stddev_params();
  Ref<IndicatorData> indi_rsi_over_stddev = new Indi_RSI(indi_rsi_over_stddev_params);
  indi_rsi_over_stddev.Ptr().SetDataSource(indi_stddev.Ptr());
  indis.Push(indi_rsi_over_stddev);

  // Relative Vigor Index (RVI).
  IndiRVIParams rvi_params(14);
  indis.Push(new Indi_RVI(rvi_params));

  // Parabolic SAR.
  IndiSARParams sar_params(0.02, 0.2);
  indis.Push(new Indi_SAR(sar_params));

  // Standard Deviation (StdDev).
  Ref<IndicatorData> indi_price_for_stdev = new Indi_Price(PriceIndiParams());
  IndiStdDevParams stddev_on_price_params();
  // stddev_on_price_params.SetDraw(clrBlue, 1); // @fixme
  Ref<Indi_StdDev> indi_stddev_on_price =
      new Indi_StdDev(stddev_on_price_params, IDATA_BUILTIN, indi_price_for_stdev.Ptr());
  indis.Push(indi_stddev_on_price.Ptr());

  // Stochastic Oscillator.
  IndiStochParams stoch_params(5, 3, 3, MODE_SMMA, STO_LOWHIGH);
  indis.Push(new Indi_Stochastic(stoch_params));

  // Williams' Percent Range (WPR).
  IndiWPRParams wpr_params(14);
  indis.Push(new Indi_WPR(wpr_params));

  // ZigZag.
  IndiZigZagParams zz_params(12, 5, 3);
  indis.Push(new Indi_ZigZag(zz_params));

  /* Special indicators */

  // Demo/Dummy Indicator.
  indis.Push(new Indi_Demo());

  // Bollinger Bands over Price indicator.
  PriceIndiParams price_params_4_bands();
  Ref<IndicatorData> indi_price_4_bands = new Indi_Price(price_params_4_bands);
  IndiBandsParams bands_on_price_params();
  // bands_on_price_params.SetDraw(clrCadetBlue); // @fixme
  Ref<Indi_Bands> indi_bands_on_price = new Indi_Bands(bands_on_price_params, IDATA_BUILTIN, indi_price_4_bands.Ptr());
  indis.Push(indi_bands_on_price.Ptr());

  // Standard Deviation (StdDev) over MA(SMA).
  // NOTE: If you set ma_shift parameter for MA, then StdDev will no longer
  // match built-in StdDev indicator (as it doesn't use ma_shift for averaging).
  IndiMAParams ma_sma_params_for_stddev();
  Ref<IndicatorData> indi_ma_sma_for_stddev = new Indi_MA(ma_sma_params_for_stddev);

  IndiStdDevParams stddev_params_on_ma_sma(13, 10);
  // stddev_params_on_ma_sma.SetDraw(true, 1); // @fixme

  Ref<Indi_StdDev> indi_stddev_on_ma_sma =
      new Indi_StdDev(stddev_params_on_ma_sma, IDATA_BUILTIN, indi_ma_sma_for_stddev.Ptr());
  indis.Push(indi_stddev_on_ma_sma.Ptr());

  // Standard Deviation (StdDev) in SMA mode over Price.
  PriceIndiParams price_params_for_stddev_sma();
  Ref<IndicatorData> indi_price_for_stddev_sma = new Indi_Price(price_params_for_stddev_sma);
  IndiStdDevParams stddev_sma_on_price_params();
  // stddev_sma_on_price_params.SetDraw(true, 1); // @fixme
  Ref<Indi_StdDev> indi_stddev_on_sma =
      new Indi_StdDev(stddev_sma_on_price_params, IDATA_BUILTIN, indi_price_for_stddev_sma.Ptr());
  indis.Push(indi_stddev_on_sma.Ptr());

  // Moving Average (MA) over Price indicator.
  PriceIndiParams price_params_4_ma();
  Ref<IndicatorData> indi_price_4_ma = new Indi_Price(price_params_4_ma);
  IndiMAParams ma_on_price_params(13, 0, MODE_SMA, PRICE_OPEN, 0);
  // ma_on_price_params.SetDraw(clrYellowGreen); // @fixme
  ma_on_price_params.SetIndicatorType(INDI_MA_ON_PRICE);
  Ref<Indi_MA> indi_ma_on_price = new Indi_MA(ma_on_price_params, IDATA_BUILTIN, indi_price_4_ma.Ptr());
  indis.Push(indi_ma_on_price.Ptr());

  // Commodity Channel Index (CCI) over Price indicator.
  PriceIndiParams price_params_4_cci();
  Ref<IndicatorData> indi_price_4_cci = new Indi_Price(price_params_4_cci);
  IndiCCIParams cci_on_price_params();
  // cci_on_price_params.SetDraw(clrYellowGreen, 1); // @fixme
  Ref<IndicatorData> indi_cci_on_price = new Indi_CCI(cci_on_price_params, IDATA_BUILTIN, indi_price_4_cci.Ptr());
  indis.Push(indi_cci_on_price.Ptr());

  // Envelopes over Price indicator.
  PriceIndiParams price_params_4_envelopes();
  Ref<IndicatorData> indi_price_4_envelopes = new Indi_Price(price_params_4_envelopes);
  IndiEnvelopesParams env_on_price_params();
  // env_on_price_params.SetDraw(clrBrown); // @fixme
  Ref<Indi_Envelopes> indi_envelopes_on_price =
      new Indi_Envelopes(env_on_price_params, IDATA_BUILTIN, indi_price_4_envelopes.Ptr());
  indis.Push(indi_envelopes_on_price.Ptr());

  // DEMA over Price indicator.
  PriceIndiParams price_params_4_dema();
  Ref<IndicatorData> indi_price_4_dema = new Indi_Price(price_params_4_dema);
  IndiDEMAParams dema_on_price_params(13, 2, PRICE_OPEN);
  // dema_on_price_params.SetDraw(clrRed); // @fixme
  Ref<Indi_DEMA> indi_dema_on_price =
      new Indi_DEMA(dema_on_price_params, INDI_DEMA_DEFAULT_IDSTYPE, indi_price_4_dema.Ptr());
  // indis.Push(indi_dema_on_price.Ptr()); // @fixme

  // Momentum over Price indicator.
  Ref<IndicatorData> indi_price_4_momentum = new Indi_Price();
  IndiMomentumParams mom_on_price_params();
  // mom_on_price_params.SetDraw(clrDarkCyan); // @fixme
  Ref<Indi_Momentum> indi_momentum_on_price =
      new Indi_Momentum(mom_on_price_params, IDATA_BUILTIN, indi_price_4_momentum.Ptr());
  indis.Push(indi_momentum_on_price.Ptr());

  // Relative Strength Index (RSI) over Price indicator.
  PriceIndiParams price_params_4_rsi();
  Ref<IndicatorData> indi_price_4_rsi = new Indi_Price(price_params_4_rsi);
  IndiRSIParams rsi_on_price_params();
  // rsi_on_price_params.SetDraw(clrBisque, 1); // @fixme
  Ref<Indi_RSI> indi_rsi_on_price = new Indi_RSI(rsi_on_price_params, IDATA_BUILTIN, indi_price_4_rsi.Ptr());
  indis.Push(indi_rsi_on_price.Ptr());

  // Drawer (socket-based) indicator over RSI over Price.
  IndiDrawerParams drawer_params(14, PRICE_OPEN);
  // drawer_params.SetDraw(clrBisque, 0); // @fixme
  Ref<Indi_Drawer> indi_drawer_on_rsi = new Indi_Drawer(drawer_params, IDATA_BUILTIN, indi_rsi_on_price.Ptr());
  indis.Push(indi_drawer_on_rsi.Ptr());

  // Applied Price over OHCL indicator.
  IndiAppliedPriceParams applied_price_params();
  // applied_price_params.SetDraw(clrAquamarine, 0); // @fixme
  IndiOHLCParams applied_price_ohlc_params(PRICE_TYPICAL);
  Ref<Indi_AppliedPrice> indi_applied_price_on_price =
      new Indi_AppliedPrice(applied_price_params, IDATA_INDICATOR, new Indi_OHLC(applied_price_ohlc_params));
  indis.Push(indi_applied_price_on_price.Ptr());

  // ADXW.
  IndiADXWParams adxw_params(14);
  indis.Push(new Indi_ADXW(adxw_params));

  // AMA.
  IndiAMAParams ama_params();
  // Will use Candle indicator by default.
  // However, in that case we need to specifiy applied price (excluding ASK and BID).
  Indi_AMA* _indi_ama = new Indi_AMA(ama_params, IDATA_INDICATOR);
  _indi_ama.SetAppliedPrice(PRICE_OPEN);
  indis.Push(_indi_ama);

  // Original AMA.
  IndiAMAParams ama_params_orig();
  ama_params_orig.SetName("Original AMA to compare");
  indis.Push(new Indi_AMA(ama_params_orig));

  // Chaikin Oscillator.
  IndiCHOParams cho_params();
  indis.Push(new Indi_CHO(cho_params));

  // Chaikin Volatility.
  IndiCHVParams chv_params();
  indis.Push(new Indi_CHV(chv_params));

  // Color Bars.
  IndiColorBarsParams color_bars_params();
  indis.Push(new Indi_ColorBars(color_bars_params));

  // Color Candles Daily.
  IndiColorCandlesDailyParams color_candles_daily_params();
  indis.Push(new Indi_ColorCandlesDaily(color_candles_daily_params));

  // Color Line.
  IndiColorLineParams color_line_params();
  indis.Push(new Indi_ColorLine(color_line_params));

  // Detrended Price Oscillator.
  IndiDetrendedPriceParams detrended_params();
  indis.Push(new Indi_DetrendedPrice(detrended_params));

  // Mass Index.
  IndiMassIndexParams mass_index_params();
  indis.Push(new Indi_MassIndex(mass_index_params));

  // OHLC.
  IndiOHLCParams ohlc_params();
  indis.Push(new Indi_OHLC(ohlc_params));

  // Price Channel.
  IndiPriceChannelParams price_channel_params();
  indis.Push(new Indi_PriceChannel(price_channel_params));

  // Price Volume Trend.
  IndiPriceVolumeTrendParams price_volume_trend_params();
  indis.Push(new Indi_PriceVolumeTrend(price_volume_trend_params));

  // Bill Williams' Zone Trade.
  IndiBWZTParams bwzt_params();
  indis.Push(new Indi_BWZT(bwzt_params));

  // Rate of Change.
  IndiRateOfChangeParams rate_of_change_params();
  indis.Push(new Indi_RateOfChange(rate_of_change_params));

  // Triple Exponential Moving Average.
  IndiTEMAParams tema_params();
  indis.Push(new Indi_TEMA(tema_params));

  // Triple Exponential Average.
  IndiTRIXParams trix_params();
  indis.Push(new Indi_TRIX(trix_params));

  // Ultimate Oscillator.
  IndiUltimateOscillatorParams ultimate_oscillator_params();
  indis.Push(new Indi_UltimateOscillator(ultimate_oscillator_params));

  // VIDYA.
  IndiVIDYAParams vidya_params();
  indis.Push(new Indi_VIDYA(vidya_params));

  // Volumes.
  IndiVolumesParams volumes_params();
  indis.Push(new Indi_Volumes(volumes_params));

  // Volume Rate of Change.
  IndiVROCParams vol_rate_of_change_params();
  indis.Push(new Indi_VROC(vol_rate_of_change_params));

  // Larry Williams' Accumulation/Distribution.
  IndiWilliamsADParams williams_ad_params();
  indis.Push(new Indi_WilliamsAD(williams_ad_params));

  // ZigZag Color.
  IndiZigZagColorParams zigzag_color_params();
  indis.Push(new Indi_ZigZagColor(zigzag_color_params));

  // Custom Moving Average.
  IndiCustomMovingAverageParams cma_params();
  indis.Push(new Indi_CustomMovingAverage(cma_params));

  // Math (specialized indicator).
  IndiMathParams math_params(MATH_OP_SUB, BAND_UPPER, BAND_LOWER, 0, 0);
  // math_params.SetDraw(clrBlue); // @fixme
  math_params.SetName("Bands(UP - LO)");
  Ref<Indi_Math> indi_math_1 = new Indi_Math(math_params, IDATA_INDICATOR, indi_bands.Ptr());
  indis.Push(indi_math_1.Ptr());

  // Math (specialized indicator) via custom math method.
  IndiMathParams math_custom_params(MathCustomOp, BAND_UPPER, BAND_LOWER, 0, 0);
  // math_custom_params.SetDraw(clrBeige); // @fixme
  math_custom_params.SetName("Bands(Custom math fn)");
  Ref<Indi_Math> indi_math_2 = new Indi_Math(math_custom_params, IDATA_INDICATOR, indi_bands.Ptr());
  indis.Push(indi_math_2.Ptr());

  // RS (Math-based) indicator.
  IndiRSParams rs_params();
  indis.Push(new Indi_RS(rs_params));

  // Pattern Detector.
  IndiPatternParams pattern_params();
  indis.Push(new Indi_Pattern(pattern_params));

  // Pivot.
  IndiPivotParams pivot_params();
  indis.Push(new Indi_Pivot(pivot_params));

  // Candle Pattern Detector.
  CandleParams candle_params();
  indis.Push(new Indi_Candle(candle_params));

  // Push white-listed indicators here.
  // whitelisted_indis.Push(_indi_test);

  return GetLastError() == ERR_NO_ERROR;
}

double MathCustomOp(double a, double b) { return 1.11 + (b - a) * 2.0; }

/**
 * Print indicators.
 */
bool PrintIndicators(string _prefix = "") {
  for (DictIterator<int, Ref<IndicatorData>> iter = indis.Begin(); iter.IsValid(); ++iter) {
    if (whitelisted_indis.Size() != 0 && !whitelisted_indis.Contains(iter.Value())) {
      continue;
    }

    IndicatorData* _indi = iter.Value().Ptr();

    if (_indi.GetModeCount() == 0) {
      // Indicator has no modes.
      PrintFormat("Skipping %s as it has no modes.", _indi.GetFullName());
      continue;
    }

    string _indi_name = _indi.GetFullName();
    IndicatorDataEntryValue _value = _indi.GetEntryValue();
    if (GetLastError() == ERR_INDICATOR_DATA_NOT_FOUND ||
        GetLastError() == ERR_USER_ERROR_FIRST + ERR_USER_INVALID_BUFF_NUM) {
      ResetLastError();
      continue;
    }
    if (_indi.Get<bool>(STRUCT_ENUM(IndicatorState, INDICATOR_STATE_PROP_IS_READY))) {
      PrintFormat("%s: %s: %s", _prefix, _indi.GetName(), _indi.ToString(0));
    }
  }
  return GetLastError() == ERR_NO_ERROR;
}

/**
 * Run all tests.
 */
bool RunTests() {
  bool _result = true;
  /*
    @fixme Commented out due to compiler bug.

    _result &= TestAC();
    _result &= TestAD();
    _result &= TestADX();
    _result &= TestAO();
    _result &= TestATR();
    _result &= TestAlligator();
    _result &= TestBWMFI();
    _result &= TestBands();
    // @todo
    // _result &= TestBandsOnPrice();
    _result &= TestBearsPower();
    _result &= TestBullsPower();
    _result &= TestCCI();
    // @todo
    // _result &= TestPrice();
    _result &= TestDeMarker();
    // @todo Demo must know tick index somehow.
    // _result &= TestDemo();
    _result &= TestEnvelopes();
    _result &= TestForce();
    _result &= TestFractals();
    _result &= TestGator();
    _result &= TestHeikenAshi();
    _result &= TestIchimoku();
    _result &= TestMA();
    // @todo
    // _result &= TestMAOnPrice();
    _result &= TestMACD();
    _result &= TestMFI();
    _result &= TestMomentum();
    _result &= TestOBV();
    _result &= TestOsMA();
    _result &= TestRSI();
    _result &= TestRVI();
    _result &= TestSAR();
    _result &= TestStdDev();
    _result &= TestStochastic();
    _result &= TestWPR();
    _result &= TestZigZag();
  */
  return _result;
}

/**
 * Test AC indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestAC() {
  // Get static value.
  double ac_value = Indi_AC::iAC();
  // Get dynamic values.
  IndiACParams params(PERIOD_CURRENT);
  Indi_AC *ac = new Indi_AC(params);
  IndicatorDataEntry _entry = ac.GetEntry();
  Print("AC: ", _entry.GetValue<double>());
  assertTrueOrReturn(ac.GetValue<double>() == ac_value, "AC value does not match!", false);
  assertTrueOrReturn(_entry.values[0] == ac_value, "AC entry value does not match!", false);
  assertTrueOrReturn(_entry.values[0] > 0, "AC value is zero or negative!", false);
  // Clean up.
  delete ac;
  return true;
}
*/

/**
 * Test AD indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestAD() {
  // Get static value.
  double ad_value = Indi_AD::iAD();
  // Get dynamic values.
  IndiADParams params(PERIOD_CURRENT);
  Indi_AD *ad = new Indi_AD(params);
  IndicatorDataEntry _entry = ad.GetEntry();
  Print("AD: ", _entry.GetValue<double>());
  assertTrueOrReturn(ad.GetValue<double>() == ad_value, "AD value does not match!", false);
  assertTrueOrReturn(_entry.values[0] == ad_value, "AD entry value does not match!", false);
  assertTrueOrReturn(_entry.values[0] > 0, "AD value is zero or negative!", false);
  // Clean up.
  delete ad;
  return true;
}
*/

/**
 * Test ADX indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestADX() {
  // Get static value.
  double adx_value = Indi_ADX::iADX(_Symbol, PERIOD_CURRENT, 14, PRICE_HIGH, LINE_MAIN_ADX);
  // Get dynamic values.
  IndiADXParams params(14);
  Indi_ADX *adx = new Indi_ADX(params);
  Print("ADX: ", adx.GetValue<double>());
  assertTrueOrReturn(adx.GetValue<double>() == adx_value, "ADX value does not match!", false);
  adx.SetPeriod(adx.GetPeriod() + 1);
  // Clean up.
  delete adx;
  return true;
}
*/

/**
 * Test AO indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestAO() {
  // Get static value.
  double ao_value = Indi_AO::iAO();
  // Get dynamic values.
  IndiAOParams params(PERIOD_CURRENT);
  Indi_AO *ao = new Indi_AO(params);
  Print("AO: ", ao.GetValue<double>());
  assertTrueOrReturn(ao.GetValue<double>() == ao_value, "AO value does not match!", false);
  // Clean up.
  delete ao;
  return true;
}
*/

/**
 * Test ATR indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestATR() {
  // Get static value.
  double atr_value = Indi_ATR::iATR(_Symbol, PERIOD_CURRENT, 14);
  // Get dynamic values.
  IndiATRParams params(14);
  Indi_ATR *atr = new Indi_ATR(params);
  Print("ATR: ", atr.GetValue<double>());
  assertTrueOrReturn(atr.GetValue<double>() == atr_value, "ATR value does not match!", false);
  atr.SetPeriod(atr.GetPeriod() + 1);
  // Clean up.
  delete atr;
  return true;
}
*/

/**
 * Test Alligator indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestAlligator() {
  // Get static value.
  double alligator_value =
      Indi_Alligator::iAlligator(_Symbol, PERIOD_CURRENT, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, LINE_JAW);
  // Get dynamic values.
  IndiAlligatorParams params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  Indi_Alligator *alligator = new Indi_Alligator(params);
  PrintFormat("Alligator: %g/%g/%g", alligator.GetValue<double>(LINE_JAW), alligator.GetValue<double>(LINE_TEETH),
              alligator.GetValue<double>(LINE_LIPS));
  assertTrueOrReturn(alligator.GetValue<double>(LINE_JAW) == alligator_value, "Alligator jaw value does not match!",
                     false);
  assertTrueOrReturn(alligator.GetValue<double>(LINE_JAW) != alligator.GetValue<double>(LINE_TEETH),
                     "Alligator jaw value should be different than teeth value!", false);
  assertTrueOrReturn(alligator.GetValue<double>(LINE_TEETH) != alligator.GetValue<double>(LINE_LIPS),
                     "Alligator teeth value should be different than lips value!", false);
  alligator.SetJawPeriod(alligator.GetJawPeriod() + 1);
  alligator.SetJawShift(alligator.GetJawShift() + 1);
  alligator.SetTeethPeriod(alligator.GetTeethPeriod() + 1);
  alligator.SetTeethShift(alligator.GetTeethShift() + 1);
  alligator.SetLipsPeriod(alligator.GetLipsPeriod() + 1);
  alligator.SetLipsShift(alligator.GetLipsShift() + 1);
  // Clean up.
  delete alligator;
  return true;
}
*/

/**
 * Test BWMFI indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestBWMFI() {
  // Get static value.
  double bwmfi_value = Indi_BWMFI::iBWMFI();
  // Get dynamic values.
  IndiBWIndiMFIParams params(PERIOD_CURRENT);
  Indi_BWMFI *bwmfi = new Indi_BWMFI(params);
  Print("BWMFI: ", bwmfi.GetValue<double>());
  assertTrueOrReturn(bwmfi.GetValue<double>() == bwmfi_value, "BWMFI value does not match!", false);
  // Clean up.
  delete bwmfi;
  return true;
}
*/

/**
 * Test bands indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestBands() {
  // Get static value.
  double bands_value = Indi_Bands::iBands(_Symbol, PERIOD_CURRENT, 20, 2, 0, PRICE_LOW);
  // Get dynamic values.
  IndiBandsParams params(20, 2, 0, PRICE_LOW);
  Indi_Bands *bands = new Indi_Bands(params);
  IndicatorDataEntry _entry = bands.GetEntry();
  Print("Bands: ", _entry.GetValue<double>());
  assertTrueOrReturn(_entry.values[BAND_BASE] == bands_value, "Bands value does not match!", false);
  assertTrueOrReturn(_entry.values[BAND_BASE] == bands.GetValue<double>(BAND_BASE),
                     "Bands BAND_BASE value does not match!", false);
  assertTrueOrReturn(_entry.values[BAND_LOWER] == bands.GetValue<double>(BAND_LOWER),
                     "Bands BAND_LOWER value does not match!", false);
  assertTrueOrReturn(_entry.values[BAND_UPPER] == bands.GetValue<double>(BAND_UPPER),
                     "Bands BAND_UPPER value does not match!", false);
  assertTrueOrReturn(_entry.values[BAND_LOWER].GetDbl() < _entry.values[BAND_UPPER].GetDbl(),
                     "Bands lower value should be less than upper value!", false);
  assertTrueOrReturn(_entry.values[BAND_UPPER].GetDbl() > _entry.values[BAND_BASE].GetDbl(),
                     "Bands upper value should be greater than base value!", false);
  bands.SetPeriod(bands.GetPeriod() + 1);
  bands.SetDeviation(bands.GetDeviation() + 0.1);
  // Clean up.
  delete bands;
  return true;
}
*/

/**
 * Test BearsPower indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestBearsPower() {
  // Get static value.
  double bp_value = Indi_BearsPower::iBearsPower(_Symbol, PERIOD_CURRENT, 13, PRICE_CLOSE);
  // Get dynamic values.
  IndiBearsPowerParams params(13, PRICE_CLOSE);
  Indi_BearsPower *bp = new Indi_BearsPower(params);
  Print("BearsPower: ", bp.GetValue<double>());
  assertTrueOrReturn(bp.GetValue<double>() == bp_value, "BearsPower value does not match!", false);
  bp.SetPeriod(bp.GetPeriod() + 1);
  bp.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete bp;
  return true;
}
*/

/**
 * Test BullsPower indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestBullsPower() {
  // Get static value.
  double bp_value = Indi_BullsPower::iBullsPower(_Symbol, PERIOD_CURRENT, 13, PRICE_CLOSE);
  // Get dynamic values.
  IndiBullsPowerParams params(13, PRICE_CLOSE);
  Indi_BullsPower *bp = new Indi_BullsPower(params);
  Print("BullsPower: ", bp.GetValue<double>());
  assertTrueOrReturn(bp.GetValue<double>() == bp_value, "BullsPower value does not match!", false);
  bp.SetPeriod(bp.GetPeriod() + 1);
  bp.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete bp;
  return true;
}
*/

/**
 * Test CCI indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestCCI() {
  // Get static value.
  double cci_value = Indi_CCI::iCCI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
  // Get dynamic values.
  IndiCCIParams params(14, PRICE_CLOSE);
  Indi_CCI *cci = new Indi_CCI(params);
  Print("CCI: ", cci.GetValue<double>());
  assertTrueOrReturn(cci.GetValue<double>() == cci_value, "CCI value does not match!", false);
  cci.SetPeriod(cci.GetPeriod() + 1);
  // Clean up.
  delete cci;

  double cci_on_array_1 = Indi_CCI::iCCIOnArray(test_values, 0, 13, 2);

  assertTrueOrReturn(cci_on_array_1 >= 233.5937 && cci_on_array_1 < 233.5938,
                     "Wrong result of iCCIOnArray. Expected ~233.5937!", false);

  double cci_on_array_2 = Indi_CCI::iCCIOnArray(test_values, 0, 13, 0);

  assertTrueOrReturn(cci_on_array_2 >= 155.7825 && cci_on_array_2 < 155.7826,
                     "Wrong result of iCCIOnArray. Expected ~155.7825, got " + DoubleToString(cci_on_array_2) + "!",
                     false);

  return true;
}
*/

/**
 * Test DeMarker indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestDeMarker() {
  // Get static value.
  double dm_value = Indi_DeMarker::iDeMarker(_Symbol, PERIOD_CURRENT, 14);
  // Get dynamic values.
  IndiDeMarkerParams params(14);
  Indi_DeMarker *dm = new Indi_DeMarker(params);
  Print("DeMarker: ", dm.GetValue<double>());
  assertTrueOrReturn(dm.GetValue<double>() == dm_value, "DeMarker value does not match!", false);
  dm.SetPeriod(dm.GetPeriod() + 1);
  // Clean up.
  delete dm;
  return true;
}
*/

/**
 * Test Demo indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestDemo() {
  // Get static value.
  double demo_value = Indi_Demo::iDemo();
  // Get dynamic values.
  IndiDemoParams params(PERIOD_CURRENT);
  Indi_Demo *demo = new Indi_Demo(params);
  IndicatorDataEntry _entry = demo.GetEntry();
  Print("Demo: ", _entry.GetValue<double>());
  assertTrueOrReturn(demo.GetValue<double>() == demo_value, "Demo value does not match!", false);
  assertTrueOrReturn(_entry.values[0] == demo_value, "Demo entry value does not match!", false);
  assertTrueOrReturn(_entry.values[0] <= 0, "Demo value is zero or negative!", false);
  // Clean up.
  delete demo;
  return true;
}
*/

/**
 * Test Envelopes indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestEnvelopes() {
  // Get static value.
  double env_value = Indi_Envelopes::iEnvelopes(_Symbol, PERIOD_CURRENT, 13, 0, MODE_SMA, PRICE_CLOSE, 2, LINE_UPPER);
  // Get dynamic values.
  IndiEnvelopesParams params(13, 0, MODE_SMA, PRICE_CLOSE, 2);
  Indi_Envelopes *env = new Indi_Envelopes(params);
  IndicatorDataEntry _entry = env.GetEntry();
  Print("Envelopes: ", _entry.GetValue<double>());
  assertTrueOrReturn(_entry.values[LINE_UPPER] == env_value, "Envelopes value does not match!", false);
  assertTrueOrReturn(_entry.values[LINE_LOWER] == env.GetValue<double>(LINE_LOWER),
                     "Envelopes LINE_LOWER value does not match!", false);
  assertTrueOrReturn(_entry.values[LINE_UPPER] == env.GetValue<double>(LINE_UPPER),
                     "Envelopes LINE_UPPER value does not match!", false);
  assertTrueOrReturn(_entry.values[LINE_LOWER].GetDbl() < _entry.values[LINE_UPPER].GetDbl(),
                     "Envelopes lower value should be less than upper value!", false);
  env.SetMAPeriod(env.GetMAPeriod() + 1);
  env.SetMAMethod(MODE_SMA);
  env.SetMAShift(env.GetMAShift() + 1);
  env.SetAppliedPrice(PRICE_MEDIAN);
  env.SetDeviation(env.GetDeviation() + 0.1);
  // Clean up.
  delete env;
  return true;
}
*/

/**
 * Test Force indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestForce() {
  // Get static value.
  double force_value = Indi_Force::iForce(_Symbol, PERIOD_CURRENT, 13, MODE_SMA, PRICE_CLOSE);
  // Get dynamic values.
  IndiForceParams params(13, MODE_SMA, PRICE_CLOSE);
  Indi_Force *force = new Indi_Force(params);
  Print("Force: ", force.GetValue<double>());
  assertTrueOrReturn(force.GetValue<double>() == force_value, "Force value does not match!", false);
  force.SetPeriod(force.GetPeriod() + 1);
  force.SetMAMethod(MODE_SMA);
  force.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete force;
  return true;
}
*/

/**
 * Test Fractals indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestFractals() {
  // Get static value.
  double fractals_value = Indi_Fractals::iFractals(_Symbol, PERIOD_CURRENT, LINE_UPPER);
  // Get dynamic values.
  IndiFractalsParams params(PERIOD_CURRENT);
  Indi_Fractals *fractals = new Indi_Fractals(params);
  Print("Fractals: ", fractals.GetValue<double>(LINE_UPPER));
  assertTrueOrReturn(fractals.GetValue<double>(LINE_UPPER) == fractals_value, "Fractals value does not match!", false);
  // Clean up.
  delete fractals;
  return true;
}
*/

/**
 * Test Gator indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestGator() {
  // Get static value.
  double gator_value =
      Indi_Gator::iGator(_Symbol, PERIOD_CURRENT, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, LINE_UPPER_HISTOGRAM);
  // Get dynamic values.
  IndiGatorParams params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  Indi_Gator *gator = new Indi_Gator(params);
  Print("Gator upper: ", gator.GetValue<double>(LINE_UPPER_HISTOGRAM));
  assertTrueOrReturn(gator.GetValue<double>(LINE_UPPER_HISTOGRAM) == gator_value, "Gator value does not match!", false);
  gator.SetJawPeriod(gator.GetJawPeriod() + 1);
  gator.SetJawShift(gator.GetJawShift() + 1);
  gator.SetTeethPeriod(gator.GetTeethPeriod() + 1);
  gator.SetTeethShift(gator.GetTeethShift() + 1);
  gator.SetLipsPeriod(gator.GetLipsPeriod() + 1);
  gator.SetLipsShift(gator.GetLipsShift() + 1);
  // Clean up.
  delete gator;
  return true;
}
*/

/**
 * Test HeikenAshi indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestHeikenAshi() {
  // Get static value.
  double ha_value = Indi_HeikenAshi::iHeikenAshi(_Symbol, PERIOD_CURRENT, HA_OPEN);
  // Get dynamic values.
  IndiHeikenAshiParams params(PERIOD_CURRENT);
  Indi_HeikenAshi *ha = new Indi_HeikenAshi(params);
  Print("HeikenAshi: ", ha.GetValue<double>(HA_OPEN));
  assertTrueOrReturn(ha.GetValue<double>(HA_OPEN) == ha_value, "HeikenAshi value does not match!", false);
  // Clean up.
  delete ha;
  return true;
}
*/

/**
 * Test Ichimoku indicator.
 */
/*
bool TestIchimoku() {
  // Get static value.
  double ichimoku_value = Indi_Ichimoku::iIchimoku(_Symbol, PERIOD_CURRENT, 9, 26, 52, LINE_TENKANSEN);
  // Get dynamic values.
  IndiIchimokuParams params(9, 26, 52);
  Indi_Ichimoku *ichimoku = new Indi_Ichimoku(params);
  Print("Ichimoku: ", ichimoku.GetValue<double>(LINE_TENKANSEN));
  assertTrueOrReturn(ichimoku.GetValue<double>(LINE_TENKANSEN) == ichimoku_value, "Ichimoku value does not match!",
                     false);
  ichimoku.SetTenkanSen(ichimoku.GetTenkanSen() + 1);
  ichimoku.SetKijunSen(ichimoku.GetKijunSen() + 1);
  ichimoku.SetSenkouSpanB(ichimoku.GetSenkouSpanB() + 1);
  // Clean up.
  delete ichimoku;
  return true;
}
*/

/**
 * Test MA indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestMA() {
  // Get static value.
  double ma_value = Indi_MA::iMA(_Symbol, PERIOD_CURRENT, 13, 10, MODE_SMA, PRICE_CLOSE);
  // Get dynamic values.
  IndiMAParams params(13, 10, MODE_SMA, PRICE_CLOSE);
  Indi_MA *_ma = new Indi_MA(params);
  Print("MA: ", _ma.GetValue<double>());
  assertTrueOrReturn(_ma.GetValue<double>() == ma_value, "MA value does not match!", false);
  _ma.SetPeriod(_ma.GetPeriod() + 1);
  _ma.SetMAShift(_ma.GetMAShift() + 1);
  _ma.SetMAMethod(MODE_SMA);
  _ma.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete _ma;
  return true;
}
*/

/**
 * Test MACD indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestMACD() {
  // Get static value.
  double macd_value = Indi_MACD::iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
  // Get dynamic values.
  IndiMACDParams params(12, 26, 9, PRICE_CLOSE);
  Indi_MACD *macd = new Indi_MACD(params);
  Print("MACD: ", macd.GetValue<double>(LINE_MAIN));
  assertTrueOrReturn(macd.GetValue<double>(LINE_MAIN) == macd_value, "MACD value does not match!", false);
  macd.SetEmaFastPeriod(macd.GetEmaFastPeriod() + 1);
  macd.SetEmaSlowPeriod(macd.GetEmaSlowPeriod() + 1);
  macd.SetSignalPeriod(macd.GetSignalPeriod() + 1);
  macd.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete macd;
  return true;
}
*/

/**
 * Test MFI indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestMFI() {
  // Get static value.
  double mfi_value = Indi_MFI::iMFI(_Symbol, PERIOD_CURRENT, 14);
  // Get dynamic values.
  IndiMFIParams params(14);
  Indi_MFI *mfi = new Indi_MFI(params);
  Print("MFI: ", mfi.GetValue<double>());
  assertTrueOrReturn(mfi.GetValue<double>() == mfi_value, "MFI value does not match!", false);
  mfi.SetPeriod(mfi.GetPeriod() + 1);
  mfi.SetAppliedVolume(VOLUME_REAL);
  // Clean up.
  delete mfi;
  return true;
}
*/

/**
 * Test Momentum indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestMomentum() {
  // Get static value.
  double mom_value = Indi_Momentum::iMomentum(_Symbol, PERIOD_CURRENT, 12, PRICE_CLOSE);
  // Get dynamic values.
  IndiMomentumParams params(12, PRICE_CLOSE);
  Indi_Momentum *mom = new Indi_Momentum(params);
  Print("Momentum: ", mom.GetValue<double>());
  assertTrueOrReturn(mom.GetValue<double>() == mom_value, "Momentum value does not match!", false);
  mom.SetPeriod(mom.GetPeriod() + 1);
  mom.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete mom;
  return true;
}
*/

/**
 * Test OBV indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestOBV() {
  // Get static value.
  double obv_value = Indi_OBV::iOBV(_Symbol, PERIOD_CURRENT);
  // Get dynamic values.
  IndiOBVParams params;
  Indi_OBV *obv = new Indi_OBV(params);
  Print("OBV: ", obv.GetValue<double>());
  assertTrueOrReturn(obv.GetValue<double>() == obv_value, "OBV value does not match!", false);
  obv.SetAppliedPrice(PRICE_MEDIAN);
  obv.SetAppliedVolume(VOLUME_REAL);
  // Clean up.
  delete obv;
  return true;
}
*/

/**
 * Test OsMA indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestOsMA() {
  // Get static value.
  double osma_value = Indi_OsMA::iOsMA(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
  // Get dynamic values.
  IndiOsMAParams params(12, 26, 9, PRICE_CLOSE);
  Indi_OsMA *osma = new Indi_OsMA(params);
  Print("OsMA: ", osma.GetValue<double>());
  assertTrueOrReturn(osma.GetValue<double>() == osma_value, "OsMA value does not match!", false);
  osma.SetEmaFastPeriod(osma.GetEmaFastPeriod() + 1);
  osma.SetEmaSlowPeriod(osma.GetEmaSlowPeriod() + 1);
  osma.SetSignalPeriod(osma.GetSignalPeriod() + 1);
  osma.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete osma;
  return true;
}
*/

/**
 * Test RSI indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestRSI() {
  // Get static value.
  double rsi_value = Indi_RSI::iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
  // Get dynamic values.
  IndiRSIParams params(14, PRICE_CLOSE);
  Indi_RSI *rsi = new Indi_RSI(params);
  Print("RSI: ", rsi.GetValue<double>());
  assertTrueOrReturn(rsi.GetValue<double>() == rsi_value, "RSI value does not match!", false);
  rsi.SetPeriod(rsi.GetPeriod() + 1);
  rsi.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete rsi;
  return true;
}
*/

/**
 * Test RVI indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestRVI() {
  // Get static value.
  double rvi_value = Indi_RVI::iRVI(_Symbol, PERIOD_CURRENT, 14, LINE_MAIN);
  // Get dynamic values.
  IndiRVIParams params(14);
  Indi_RVI *rvi = new Indi_RVI(params);
  Print("RVI: ", rvi.GetValue<double>(LINE_MAIN));
  assertTrueOrReturn(rvi.GetValue<double>(LINE_MAIN) == rvi_value, "RVI value does not match!", false);
  rvi.SetPeriod(rvi.GetPeriod() + 1);
  // Clean up.
  delete rvi;
  return true;
}
*/

/**
 * Test SAR indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestSAR() {
  // Get static value.
  double sar_value = Indi_SAR::iSAR();
  // Get dynamic values.
  IndiSARParams params(0.02, 0.2);
  Indi_SAR *sar = new Indi_SAR(params);
  Print("SAR: ", sar.GetValue<double>(0));
  assertTrueOrReturn(sar.GetValue<double>(0) == sar_value, "SAR value does not match!", false);
  sar.SetStep(sar.GetStep() * 2);
  sar.SetMax(sar.GetMax() * 2);
  // Clean up.
  delete sar;
  return true;
}
*/

/*
  @fixme Commented out due to compiler bug.

#ifdef __MQL4__
struct StdDevTestCase {
  int total, ma_period, ma_shift, ma_method, shift;
};
#endif
*/

/**
 * Test StdDev indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestStdDev() {
  // Get static value.
  double sd_value = Indi_StdDev::iStdDev(_Symbol, PERIOD_CURRENT, 13, 10, MODE_SMA, PRICE_CLOSE);
  // Get dynamic values.
  IndiStdDevParams params(13, 10, MODE_SMA, PRICE_CLOSE);
  Indi_StdDev *sd = new Indi_StdDev(params);
  Print("StdDev: ", sd.GetValue<double>());
  assertTrueOrReturn(sd.GetValue<double>() == sd_value, "StdDev value does not match!", false);
  sd.SetMAPeriod(sd.GetMAPeriod() + 1);
  sd.SetMAShift(sd.GetMAShift() + 1);
  sd.SetMAMethod(MODE_SMA);
  sd.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete sd;

#ifdef __MQL4__
  // Checking iStdDevOnArray consistency between custom method and the one built-in into MT4.
  StdDevTestCase test_cases[] = {
      {0, 5, 0, MODE_SMA, 0},   {0, 15, 0, MODE_SMA, 0}, {0, 15, 2, MODE_SMMA, 1},
      {0, 15, 5, MODE_SMMA, 3}, {0, 18, 3, MODE_SMA, 2},
  };

  double max_diff = 0.0001;

  for (int i = 0; i < ArraySize(test_cases); ++i) {
    double original_result = ::iStdDevOnArray(test_values, test_cases[i].total, test_cases[i].ma_period,
                                              test_cases[i].ma_shift, test_cases[i].ma_method, test_cases[i].shift);
    double custom_result =
        Indi_StdDev::iStdDevOnArray(test_values, test_cases[i].total, test_cases[i].ma_period, test_cases[i].ma_shift,
                                    test_cases[i].ma_method, test_cases[i].shift);

    assertTrueOrReturnFalse(original_result > custom_result - max_diff || original_result < custom_result + max_diff,
                            "Original result: " + DoubleToStr(original_result) +
                                " differs from custom result: " + DoubleToStr(custom_result) + "!");
  }
#endif
  return true;
}
*/

/**
 * Test Stochastic indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestStochastic() {
  // Get static value.
  double stoch_value =
      Indi_Stochastic::iStochastic(_Symbol, PERIOD_CURRENT, 5, 3, 3, MODE_SMMA, STO_LOWHIGH, LINE_MAIN);
  // Get dynamic values.
  IndiStochParams params(5, 3, 3, MODE_SMMA, STO_LOWHIGH);
  Indi_Stochastic *stoch = new Indi_Stochastic(params);
  Print("Stochastic: ", stoch.GetValue<double>());
  assertTrueOrReturn(stoch.GetValue<double>() == stoch_value, "Stochastic value does not match!", false);
  stoch.SetKPeriod(stoch.GetKPeriod() + 1);
  stoch.SetDPeriod(stoch.GetDPeriod() + 1);
  stoch.SetSlowing(stoch.GetSlowing() + 1);
  stoch.SetMAMethod(MODE_SMA);
  stoch.SetPriceField(STO_CLOSECLOSE);
  // Clean up.
  delete stoch;
  return true;
}
*/

/**
 * Test WPR indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestWPR() {
  // Get static value.
  double wpr_value = Indi_WPR::iWPR(_Symbol, PERIOD_CURRENT, 14, 0);
  // Get dynamic values.
  IndiWPRParams params(14);
  Indi_WPR *wpr = new Indi_WPR(params);
  Print("WPR: ", wpr.GetValue<double>());
  assertTrueOrReturn(wpr.GetValue<double>() == wpr_value, "WPR value does not match!", false);
  wpr.SetPeriod(wpr.GetPeriod() + 1);
  // Clean up.
  delete wpr;
  return true;
}
*/

/**
 * Test ZigZag indicator.
 */
/*
  @fixme Commented out due to compiler bug.

bool TestZigZag() {
  // Get static value.
  double zz_value = Indi_ZigZag::iZigZag(_Symbol, PERIOD_CURRENT, 12, 5, 3, ZIGZAG_BUFFER, 0);
  // Get dynamic values.
  IndiZigZagParams params(12, 5, 3);
  Indi_ZigZag *zz = new Indi_ZigZag(params);
  Print("ZigZag: ", zz.GetValue<double>(ZIGZAG_BUFFER));
  assertTrueOrReturn(zz.GetValue<double>(ZIGZAG_BUFFER) == zz_value, "ZigZag value does not match!", false);
  zz.SetDepth(zz.GetDepth() + 1);
  zz.SetDeviation(zz.GetDeviation() + 1);
  zz.SetBackstep(zz.GetBackstep() + 1);
  // Clean up.
  delete zz;
  return true;
}
*/

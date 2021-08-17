//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2021, EA31337 Ltd |
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
//#define __debug__  // Enables debug.

// Forward declaration.
struct DataParamEntry;

// Includes.
#include "../Dict.mqh"
#include "../DictObject.mqh"
#include "../Indicator.mqh"
#include "../Indicators/Bitwise/Indi_Candle.mqh"
#include "../Indicators/Indi_AC.mqh"
#include "../Indicators/Indi_AD.mqh"
#include "../Indicators/Indi_ADX.mqh"
#include "../Indicators/Indi_ADXW.mqh"
#include "../Indicators/Indi_AMA.mqh"
#include "../Indicators/Indi_AO.mqh"
#include "../Indicators/Indi_ATR.mqh"
#include "../Indicators/Indi_Alligator.mqh"
#include "../Indicators/Indi_AppliedPrice.mqh"
#include "../Indicators/Indi_BWMFI.mqh"
#include "../Indicators/Indi_BWZT.mqh"
#include "../Indicators/Indi_Bands.mqh"
#include "../Indicators/Indi_BearsPower.mqh"
#include "../Indicators/Indi_BullsPower.mqh"
#include "../Indicators/Indi_CCI.mqh"
#include "../Indicators/Indi_CHO.mqh"
#include "../Indicators/Indi_CHV.mqh"
#include "../Indicators/Indi_ColorBars.mqh"
#include "../Indicators/Indi_ColorCandlesDaily.mqh"
#include "../Indicators/Indi_ColorLine.mqh"
#include "../Indicators/Indi_CustomMovingAverage.mqh"
#include "../Indicators/Indi_DeMarker.mqh"
#include "../Indicators/Indi_Demo.mqh"
#include "../Indicators/Indi_DetrendedPrice.mqh"
#include "../Indicators/Indi_Drawer.mqh"
#include "../Indicators/Indi_Envelopes.mqh"
#include "../Indicators/Indi_Force.mqh"
#include "../Indicators/Indi_Fractals.mqh"
#include "../Indicators/Indi_Gator.mqh"
#include "../Indicators/Indi_HeikenAshi.mqh"
#include "../Indicators/Indi_Ichimoku.mqh"
#include "../Indicators/Indi_MA.mqh"
#include "../Indicators/Indi_MACD.mqh"
#include "../Indicators/Indi_MFI.mqh"
#include "../Indicators/Indi_MassIndex.mqh"
#include "../Indicators/Indi_Momentum.mqh"
#include "../Indicators/Indi_OBV.mqh"
#include "../Indicators/Indi_OsMA.mqh"
#include "../Indicators/Indi_Pattern.mqh"
#include "../Indicators/Indi_Price.mqh"
#include "../Indicators/Indi_PriceChannel.mqh"
#include "../Indicators/Indi_PriceVolumeTrend.mqh"
#include "../Indicators/Indi_RS.mqh"
#include "../Indicators/Indi_RSI.mqh"
#include "../Indicators/Indi_RVI.mqh"
#include "../Indicators/Indi_RateOfChange.mqh"
#include "../Indicators/Indi_SAR.mqh"
#include "../Indicators/Indi_StdDev.mqh"
#include "../Indicators/Indi_Stochastic.mqh"
#include "../Indicators/Indi_TEMA.mqh"
#include "../Indicators/Indi_TRIX.mqh"
#include "../Indicators/Indi_UltimateOscillator.mqh"
#include "../Indicators/Indi_VIDYA.mqh"
#include "../Indicators/Indi_VROC.mqh"
#include "../Indicators/Indi_Volumes.mqh"
#include "../Indicators/Indi_WPR.mqh"
#include "../Indicators/Indi_WilliamsAD.mqh"
#include "../Indicators/Indi_ZigZag.mqh"
#include "../Indicators/Indi_ZigZagColor.mqh"
#include "../Indicators/Special/Indi_Math.mqh"
#include "../Indicators/Special/Indi_Pivot.mqh"
#include "../SerializerConverter.mqh"
#include "../SerializerJson.mqh"
#include "../Test.mqh"

// Custom indicator identifiers.
enum ENUM_CUSTOM_INDICATORS { INDI_SPECIAL_MATH_CUSTOM = FINAL_INDICATOR_TYPE_ENTRY + 1 };

// Global variables.
Chart *chart;
Dict<long, Indicator *> indis;
Dict<long, bool> whitelisted_indis;
Dict<long, bool> tested;
int bar_processed;
double test_values[] = {1.245, 1.248, 1.254, 1.264, 1.268, 1.261, 1.256, 1.250, 1.242, 1.240, 1.235,
                        1.240, 1.234, 1.245, 1.265, 1.274, 1.285, 1.295, 1.300, 1.312, 1.315, 1.320,
                        1.325, 1.335, 1.342, 1.348, 1.352, 1.357, 1.359, 1.422, 1.430, 1.435};
Indi_Drawer *_indi_drawer;

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  // Initialize chart.
  chart = new Chart();
  // Initialize indicators.
  _result &= InitIndicators();
  Print("Indicators to test: ", indis.Size());
  // Check for any errors.
  assertTrueOrFail(GetLastError() == ERR_NO_ERROR, StringFormat("Error: %d", GetLastError()));
  // Print indicator values.
  _result &= PrintIndicators(__FUNCTION__);
  assertTrueOrFail(GetLastError() == ERR_NO_ERROR, StringFormat("Error: %d", GetLastError()));
  bar_processed = 0;

  return (_result && _LastError == ERR_NO_ERROR ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements Tick event handler.
 */
void OnTick() {
  chart.OnTick();

  if (chart.IsNewBar()) {
    Redis *redis = _indi_drawer.Redis();

    if (redis.Simulated() && redis.Subscribed("DRAWER")) {
      // redis.Messages().Enqueue("Tick number #" + IntegerToString(chart.GetTickIndex()));
    }

    bar_processed++;
    if (indis.Size() == 0) {
      return;
    }
    for (DictIterator<long, Indicator *> iter = indis.Begin(); iter.IsValid(); ++iter) {
      if (whitelisted_indis.Size() == 0) {
        if (tested.GetByKey(iter.Key())) {
          // Indicator is already tested, skipping.
          continue;
        }
      } else {
        if (!whitelisted_indis.KeyExists(iter.Key())) {
          continue;
        }
      }

      Indicator *_indi = iter.Value();
      _indi.OnTick();
      IndicatorDataEntry _entry = _indi.GetEntry();
      if (_indi.Get<bool>(IndicatorState::INDICATOR_STATE_PROP_IS_READY) && _entry.IsValid()) {
        PrintFormat("%s: bar %d: %s", _indi.GetFullName(), bar_processed, _indi.ToString());
        tested.Set(iter.Key(), true);  // Mark as tested.
      }
    }
  }
}

/**
 * Implements Deinit event handler.
 */
void OnDeinit(const int reason) {
  int num_not_tested = 0;
  for (DictIterator<long, bool> iter = tested.Begin(); iter.IsValid(); ++iter) {
    if (!iter.Value()) {
      PrintFormat("%s: Indicator not tested: %s", __FUNCTION__, indis[iter.Key()].GetName());
      ++num_not_tested;
    }
  }

  delete chart;

  for (DictIterator<long, Indicator *> iter = indis.Begin(); iter.IsValid(); ++iter) {
    delete iter.Value();
  }

  PrintFormat("%s: Indicators not tested: %d", __FUNCTION__, num_not_tested);
  assertTrueOrExit(num_not_tested == 0, "Not all indicators has been tested!");
}

/**
 * Initialize indicators.
 */
bool InitIndicators() {
  /* Standard indicators */

  // AC.
  indis.Push(new Indi_AC());

  // AD.
  indis.Push(new Indi_AD());

  // ADX.
  ADXParams adx_params(14, PRICE_HIGH);
  indis.Push(new Indi_ADX(adx_params));

  // Alligator.
  AlligatorParams alli_params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  indis.Push(new Indi_Alligator(alli_params));

  // Adaptive Moving Average (AMA).
  // Awesome Oscillator (AO).
  indis.Push(new Indi_AO());

  // Average True Range (ATR).
  ATRParams atr_params(14);
  indis.Push(new Indi_ATR(atr_params));

  // Bollinger Bands.
  BandsParams bands_params(20, 2, 0, PRICE_OPEN);
  Indicator *indi_bands = new Indi_Bands(bands_params);
  indis.Push(indi_bands);

  // Bollinger Bands over RSI.
  BandsParams bands_over_rsi_params(20, 2, 0, PRICE_OPEN);
  bands_over_rsi_params.SetDataSource(INDI_RSI);
  indis.Push(new Indi_Bands(bands_over_rsi_params));

  // Bears Power.
  BearsPowerParams bears_params(13, PRICE_CLOSE);
  indis.Push(new Indi_BearsPower(bears_params));

  // Bulls Power.
  BullsPowerParams bulls_params(13, PRICE_CLOSE);
  indis.Push(new Indi_BullsPower(bulls_params));

  // Market Facilitation Index (BWMFI).
  indis.Push(new Indi_BWMFI());

  // Commodity Channel Index (CCI).
  CCIParams cci_params(14, PRICE_OPEN);
  indis.Push(new Indi_CCI(cci_params));

  // DeMarker.
  DeMarkerParams dm_params(14);
  indis.Push(new Indi_DeMarker(dm_params));

  // Envelopes.
  EnvelopesParams env_params(13, 0, MODE_SMA, PRICE_OPEN, 2);
  indis.Push(new Indi_Envelopes(env_params));

  // Force Index.
  ForceParams force_params(13, MODE_SMA, PRICE_CLOSE);
  indis.Push(new Indi_Force(force_params));

  // Fractals.
  indis.Push(new Indi_Fractals());

  // Fractal Adaptive Moving Average (FRAMA).
  // @todo
  // indis.Push(new Indi_Frama(frama_params));

  // Gator Oscillator.
  GatorParams gator_params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  indis.Push(new Indi_Gator(gator_params));

  // Heiken Ashi.
  indis.Push(new Indi_HeikenAshi());

  // Ichimoku Kinko Hyo.
  IchimokuParams ichi_params(9, 26, 52);
  indis.Push(new Indi_Ichimoku(ichi_params));

  // Moving Average.
  MAParams ma_params(13, 10, MODE_SMA, PRICE_OPEN);
  Indicator *indi_ma = new Indi_MA(ma_params);
  indis.Push(indi_ma);

  // MACD.
  MACDParams macd_params(12, 26, 9, PRICE_CLOSE);
  Indicator *macd = new Indi_MACD(macd_params);
  indis.Push(macd);

  // Money Flow Index (MFI).
  MFIParams mfi_params(14);
  indis.Push(new Indi_MFI(mfi_params));

  // Momentum (MOM).
  MomentumParams mom_params();
  indis.Push(new Indi_Momentum(mom_params));

  // On Balance Volume (OBV).
  indis.Push(new Indi_OBV());

  // OsMA.
  OsMAParams osma_params(12, 26, 9, PRICE_CLOSE);
  indis.Push(new Indi_OsMA(osma_params));

  // Relative Strength Index (RSI).
  RSIParams rsi_params(14, PRICE_OPEN);
  indis.Push(new Indi_RSI(rsi_params));

  // Relative Strength Index (RSI).
  RSIParams rsi_over_blt_stddev_params();
  rsi_over_blt_stddev_params.SetDataSource(INDI_STDDEV);
  indis.Push(new Indi_RSI(rsi_over_blt_stddev_params));

  // Relative Vigor Index (RVI).
  RVIParams rvi_params(14);
  indis.Push(new Indi_RVI(rvi_params));

  // Parabolic SAR.
  SARParams sar_params(0.02, 0.2);
  indis.Push(new Indi_SAR(sar_params));

  // Standard Deviation (StdDev).
  StdDevParams stddev_params(13, 10, MODE_SMA, PRICE_OPEN);
  indis.Push(new Indi_StdDev(stddev_params));

  // Standard Deviation (StdDev).
  Indicator *indi_price_for_stdev = new Indi_Price(PriceIndiParams());

  StdDevParams stddev_on_price_params();
  stddev_on_price_params.SetDataSource(indi_price_for_stdev, true, PRICE_OPEN);
  stddev_on_price_params.SetDraw(clrBlue, 1);
  indis.Push(new Indi_StdDev(stddev_on_price_params));

  // Stochastic Oscillator.
  StochParams stoch_params(5, 3, 3, MODE_SMMA, STO_LOWHIGH);
  indis.Push(new Indi_Stochastic(stoch_params));

  // Triple Exponential Moving Average (TEMA).
  // @todo
  // indis.Push(new Indi_TEMA(tema_params));
  // Triple Exponential Moving Averages Oscillator (TRIX).
  // @todo
  // indis.Push(new Indi_TRIX(trix_params));
  // Variable Index Dynamic Average (VIDYA).
  // @todo
  // indis.Push(new Indi_VIDYA(vidya_params));
  // Volumes.
  // @todo
  // indis.Push(new Indi_Volumes(vol_params));

  // Williams' Percent Range (WPR).
  WPRParams wpr_params(14);
  indis.Push(new Indi_WPR(wpr_params));

  // ZigZag.
  ZigZagParams zz_params(12, 5, 3);
  indis.Push(new Indi_ZigZag(zz_params));

  /* Special indicators */

  // Demo/Dummy Indicator.
  indis.Push(new Indi_Demo());

  // Current Price.
  PriceIndiParams price_params();
  // price_params.SetDraw(clrAzure);
  Indicator *indi_price = new Indi_Price(price_params);
  indis.Push(indi_price);

  // Bollinger Bands over Price indicator.
  PriceIndiParams price_params_4_bands();
  Indicator *indi_price_4_bands = new Indi_Price(price_params_4_bands);
  BandsParams bands_on_price_params();
  bands_on_price_params.SetDraw(clrCadetBlue);
  bands_on_price_params.SetDataSource(indi_price_4_bands, true, INDI_PRICE_MODE_OPEN);
  indis.Push(new Indi_Bands(bands_on_price_params));

  // Standard Deviation (StdDev) over MA(SMA).
  // NOTE: If you set ma_shift parameter for MA, then StdDev will no longer
  // match built-in StdDev indicator (as it doesn't use ma_shift for averaging).
  MAParams ma_sma_params_for_stddev();
  Indicator *indi_ma_sma_for_stddev = new Indi_MA(ma_sma_params_for_stddev);

  StdDevParams stddev_params_on_ma_sma(13, 10);
  stddev_params_on_ma_sma.SetDraw(true, 1);
  stddev_params_on_ma_sma.SetDataSource(indi_ma_sma_for_stddev, true, 0);
  indis.Push(new Indi_StdDev(stddev_params_on_ma_sma));

  // Standard Deviation (StdDev) in SMA mode over Price.
  PriceIndiParams price_params_for_stddev_sma();
  Indicator *indi_price_for_stddev_sma = new Indi_Price(price_params_for_stddev_sma);

  StdDevParams stddev_sma_on_price_params();
  stddev_sma_on_price_params.SetDraw(true, 1);
  stddev_sma_on_price_params.SetDataSource(indi_price_for_stddev_sma, true, INDI_PRICE_MODE_OPEN);
  indis.Push(new Indi_StdDev(stddev_sma_on_price_params));

  // Moving Average (MA) over Price indicator.
  PriceIndiParams price_params_4_ma();
  Indicator *indi_price_4_ma = new Indi_Price(price_params_4_ma);
  MAParams ma_on_price_params();
  ma_on_price_params.SetDraw(clrYellowGreen);
  ma_on_price_params.SetDataSource(indi_price_4_ma, true, INDI_PRICE_MODE_OPEN);
  ma_on_price_params.SetIndicatorType(INDI_MA_ON_PRICE);
  Indicator *indi_ma_on_price = new Indi_MA(ma_on_price_params);
  indis.Push(indi_ma_on_price);

  // Commodity Channel Index (CCI) over Price indicator.
  PriceIndiParams price_params_4_cci();
  Indicator *indi_price_4_cci = new Indi_Price(price_params_4_cci);
  CCIParams cci_on_price_params();
  cci_on_price_params.SetDraw(clrYellowGreen, 1);
  cci_on_price_params.SetDataSource(indi_price_4_cci, true, INDI_PRICE_MODE_OPEN);
  Indicator *indi_cci_on_price = new Indi_CCI(cci_on_price_params);
  indis.Push(indi_cci_on_price);

  // Envelopes over Price indicator.
  PriceIndiParams price_params_4_envelopes();
  Indicator *indi_price_4_envelopes = new Indi_Price(price_params_4_envelopes);
  EnvelopesParams env_on_price_params();
  env_on_price_params.SetDataSource(indi_price_4_envelopes, true, INDI_PRICE_MODE_OPEN);
  env_on_price_params.SetDraw(clrBrown);
  indis.Push(new Indi_Envelopes(env_on_price_params));

  // Momentum over Price indicator.
  Indicator *indi_price_4_momentum = new Indi_Price();
  MomentumParams mom_on_price_params();
  mom_on_price_params.SetDataSource(indi_price_4_momentum);
  mom_on_price_params.SetDraw(clrDarkCyan);
  indis.Push(new Indi_Momentum(mom_on_price_params));

  // Relative Strength Index (RSI) over Price indicator.
  PriceIndiParams price_params_4_rsi();
  Indicator *indi_price_4_rsi = new Indi_Price(price_params_4_rsi);
  RSIParams rsi_on_price_params();
  rsi_on_price_params.SetDataSource(indi_price_4_rsi, true, INDI_PRICE_MODE_OPEN);
  rsi_on_price_params.SetDraw(clrBisque, 1);
  indis.Push(new Indi_RSI(rsi_on_price_params));

  // Drawer (socket-based) indicator.
  DrawerParams drawer_params(14, /*unused*/ PRICE_OPEN);
  // drawer_params.SetIndicatorData(indi_price_4_rsi);
  // drawer_params.SetIndicatorMode(INDI_PRICE_MODE_OPEN);
  drawer_params.SetDraw(clrBisque, 0);
  indis.Push(_indi_drawer = new Indi_Drawer(drawer_params));

  // "Applied Price over OHCL Indicator" indicator.
  AppliedPriceParams applied_price_params(PRICE_HIGH);
  applied_price_params.SetDraw(clrAquamarine, 0);
  PriceIndiParams applied_price_price_params;
  applied_price_params.SetDataSource(new Indi_Price(applied_price_price_params));
  indis.Push(new Indi_AppliedPrice(applied_price_params));

// ADXW.
#ifdef __MQL5__
  ADXWParams adxw_params(14);
  indis.Push(new Indi_ADXW(adxw_params));
#endif

// AMA.
#ifdef __MQL5__
  AMAParams ama_params();
  indis.Push(new Indi_AMA(ama_params));
#endif

// Chaikin Oscillator.
#ifdef __MQL5__
  CHOParams cho_params();
  indis.Push(new Indi_CHO(cho_params));
#endif

// Chaikin Volatility.
#ifdef __MQL5__
  CHVParams chv_params();
  indis.Push(new Indi_CHV(chv_params));
#endif

// Color Bars.
#ifdef __MQL5__
  ColorBarsParams color_bars_params();
  indis.Push(new Indi_ColorBars(color_bars_params));
#endif

// Color Candles Daily.
#ifdef __MQL5__
  ColorCandlesDailyParams color_candles_daily_params();
  indis.Push(new Indi_ColorCandlesDaily(color_candles_daily_params));
#endif

// Color Line.
#ifdef __MQL5__
  ColorLineParams color_line_params();
  indis.Push(new Indi_ColorLine(color_line_params));
#endif

// Detrended Price Oscillator.
#ifdef __MQL5__
  DetrendedPriceParams detrended_params();
  indis.Push(new Indi_DetrendedPrice(detrended_params));
#endif

// Mass Index.
#ifdef __MQL5__
  MassIndexParams mass_index_params();
  indis.Push(new Indi_MassIndex(mass_index_params));
#endif

// Price Channel.
#ifdef __MQL5__
  PriceChannelParams price_channel_params();
  indis.Push(new Indi_PriceChannel(price_channel_params));
#endif

// Price Volume Trend.
#ifdef __MQL5__
  PriceVolumeTrendParams price_volume_trend_params();
  indis.Push(new Indi_PriceVolumeTrend(price_volume_trend_params));
#endif

// Bill Williams' Zone Trade.
#ifdef __MQL5__
  BWZTParams bwzt_params();
  indis.Push(new Indi_BWZT(bwzt_params));
#endif

// Rate of Change.
#ifdef __MQL5__
  RateOfChangeParams rate_of_change_params();
  indis.Push(new Indi_RateOfChange(rate_of_change_params));
#endif

// Triple Exponential Moving Average.
#ifdef __MQL5__
  TEMAParams tema_params();
  indis.Push(new Indi_TEMA(tema_params));
#endif

// Triple Exponential Average.
#ifdef __MQL5__
  TRIXParams trix_params();
  indis.Push(new Indi_TRIX(trix_params));
#endif

// Ultimate Oscillator.
#ifdef __MQL5__
  UltimateOscillatorParams ultimate_oscillator_params();
  indis.Push(new Indi_UltimateOscillator(ultimate_oscillator_params));
#endif

// VIDYA.
#ifdef __MQL5__
  VIDYAParams vidya_params();
  indis.Push(new Indi_VIDYA(vidya_params));
#endif

// Volumes.
#ifdef __MQL5__
  VolumesParams volumes_params();
  indis.Push(new Indi_Volumes(volumes_params));
#endif

// Volume Rate of Change.
#ifdef __MQL5__
  VROCParams vol_rate_of_change_params();
  indis.Push(new Indi_VROC(vol_rate_of_change_params));
#endif

// Larry Williams' Accumulation/Distribution.
#ifdef __MQL5__
  WilliamsADParams williams_ad_params();
  indis.Push(new Indi_WilliamsAD(williams_ad_params));
#endif

// ZigZag Color.
#ifdef __MQL5__
  ZigZagColorParams zigzag_color_params();
  indis.Push(new Indi_ZigZagColor(zigzag_color_params));
#endif

// Custom Moving Average.
#ifdef __MQL5__
  CustomMovingAverageParams cma_params();
  indis.Push(new Indi_CustomMovingAverage(cma_params));
#endif

  // Math (specialized indicator).
  MathParams math_params(MATH_OP_SUB, BAND_UPPER, BAND_LOWER, 0, 0);
  math_params.SetDataSource(indi_bands, false, 0);
  math_params.SetDraw(clrBlue);
  math_params.SetName("Bands(UP - LO)");
  indis.Push(new Indi_Math(math_params));

  // Math (specialized indicator) via custom math method.
  MathParams math_custom_params(MathCustomOp, BAND_UPPER, BAND_LOWER, 0, 0);
  math_custom_params.SetDataSource(indi_bands, false, 0);
  math_custom_params.SetDraw(clrBeige);
  math_custom_params.SetName("Bands(Custom math fn)");
  indis.Push(new Indi_Math(math_custom_params));

  // RS (Math-based) indicator.
  RSParams rs_params();
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

  // Mark all as untested.
  for (DictIterator<long, Indicator *> iter = indis.Begin(); iter.IsValid(); ++iter) {
    tested.Set(iter.Key(), false);
  }

  // Paste white-listed indicators here.
  // whitelisted_indis.Set(INDI_RSI, true);

  return GetLastError() == ERR_NO_ERROR;
}

double MathCustomOp(double a, double b) { return 1.11 + (b - a) * 2.0; }

/**
 * Print indicators.
 */
bool PrintIndicators(string _prefix = "") {
  for (DictIterator<long, Indicator *> iter = indis.Begin(); iter.IsValid(); ++iter) {
    if (whitelisted_indis.Size() != 0 && !whitelisted_indis.KeyExists(iter.Key())) {
      continue;
    }

    Indicator *_indi = iter.Value();
    string _indi_name = _indi.GetName();
    MqlParam _value = _indi.GetEntryValue();
    if (GetLastError() == ERR_INDICATOR_DATA_NOT_FOUND ||
        GetLastError() == ERR_USER_ERROR_FIRST + ERR_USER_INVALID_BUFF_NUM) {
      ResetLastError();
      continue;
    }
    if (_indi.Get<int>(IndicatorState::INDICATOR_STATE_PROP_IS_READY)) {
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
  return _result;
}

/**
 * Test AC indicator.
 */
bool TestAC() {
  // Get static value.
  double ac_value = Indi_AC::iAC();
  // Get dynamic values.
  ACParams params(PERIOD_CURRENT);
  Indi_AC *ac = new Indi_AC(params);
  IndicatorDataEntry _entry = ac.GetEntry();
  Print("AC: ", _entry.GetValue<double>());
  assertTrueOrReturn(ac.GetValue() == ac_value, "AC value does not match!", false);
  assertTrueOrReturn(_entry.values[0] == ac_value, "AC entry value does not match!", false);
  assertTrueOrReturn(_entry.values[0] > 0, "AC value is zero or negative!", false);
  // Clean up.
  delete ac;
  return true;
}

/**
 * Test AD indicator.
 */
bool TestAD() {
  // Get static value.
  double ad_value = Indi_AD::iAD();
  // Get dynamic values.
  ADParams params(PERIOD_CURRENT);
  Indi_AD *ad = new Indi_AD(params);
  IndicatorDataEntry _entry = ad.GetEntry();
  Print("AD: ", _entry.GetValue<double>());
  assertTrueOrReturn(ad.GetValue() == ad_value, "AD value does not match!", false);
  assertTrueOrReturn(_entry.values[0] == ad_value, "AD entry value does not match!", false);
  assertTrueOrReturn(_entry.values[0] > 0, "AD value is zero or negative!", false);
  // Clean up.
  delete ad;
  return true;
}

/**
 * Test ADX indicator.
 */
bool TestADX() {
  // Get static value.
  double adx_value = Indi_ADX::iADX(_Symbol, PERIOD_CURRENT, 14, PRICE_HIGH, LINE_MAIN_ADX);
  // Get dynamic values.
  ADXParams params(14, PRICE_HIGH);
  Indi_ADX *adx = new Indi_ADX(params);
  Print("ADX: ", adx.GetValue());
  assertTrueOrReturn(adx.GetValue() == adx_value, "ADX value does not match!", false);
  adx.SetPeriod(adx.GetPeriod() + 1);
  // Clean up.
  delete adx;
  return true;
}

/**
 * Test AO indicator.
 */
bool TestAO() {
  // Get static value.
  double ao_value = Indi_AO::iAO();
  // Get dynamic values.
  AOParams params(PERIOD_CURRENT);
  Indi_AO *ao = new Indi_AO(params);
  Print("AO: ", ao.GetValue());
  assertTrueOrReturn(ao.GetValue() == ao_value, "AO value does not match!", false);
  // Clean up.
  delete ao;
  return true;
}

/**
 * Test ATR indicator.
 */
bool TestATR() {
  // Get static value.
  double atr_value = Indi_ATR::iATR(_Symbol, PERIOD_CURRENT, 14);
  // Get dynamic values.
  ATRParams params(14);
  Indi_ATR *atr = new Indi_ATR(params);
  Print("ATR: ", atr.GetValue());
  assertTrueOrReturn(atr.GetValue() == atr_value, "ATR value does not match!", false);
  atr.SetPeriod(atr.GetPeriod() + 1);
  // Clean up.
  delete atr;
  return true;
}

/**
 * Test Alligator indicator.
 */
bool TestAlligator() {
  // Get static value.
  double alligator_value =
      Indi_Alligator::iAlligator(_Symbol, PERIOD_CURRENT, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, LINE_JAW);
  // Get dynamic values.
  AlligatorParams params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  Indi_Alligator *alligator = new Indi_Alligator(params);
  PrintFormat("Alligator: %g/%g/%g", alligator.GetValue(LINE_JAW), alligator.GetValue(LINE_TEETH),
              alligator.GetValue(LINE_LIPS));
  assertTrueOrReturn(alligator.GetValue(LINE_JAW) == alligator_value, "Alligator jaw value does not match!", false);
  assertTrueOrReturn(alligator.GetValue(LINE_JAW) != alligator.GetValue(LINE_TEETH),
                     "Alligator jaw value should be different than teeth value!", false);
  assertTrueOrReturn(alligator.GetValue(LINE_TEETH) != alligator.GetValue(LINE_LIPS),
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

/**
 * Test BWMFI indicator.
 */
bool TestBWMFI() {
  // Get static value.
  double bwmfi_value = Indi_BWMFI::iBWMFI();
  // Get dynamic values.
  BWMFIParams params(PERIOD_CURRENT);
  Indi_BWMFI *bwmfi = new Indi_BWMFI(params);
  Print("BWMFI: ", bwmfi.GetValue());
  assertTrueOrReturn(bwmfi.GetValue() == bwmfi_value, "BWMFI value does not match!", false);
  // Clean up.
  delete bwmfi;
  return true;
}

/**
 * Test bands indicator.
 */
bool TestBands() {
  // Get static value.
  double bands_value = Indi_Bands::iBands(_Symbol, PERIOD_CURRENT, 20, 2, 0, PRICE_LOW);
  // Get dynamic values.
  BandsParams params(20, 2, 0, PRICE_LOW);
  Indi_Bands *bands = new Indi_Bands(params);
  IndicatorDataEntry _entry = bands.GetEntry();
  Print("Bands: ", _entry.GetValue<double>());
  assertTrueOrReturn(_entry.values[BAND_BASE] == bands_value, "Bands value does not match!", false);
  assertTrueOrReturn(_entry.values[BAND_BASE] == bands.GetValue(BAND_BASE), "Bands BAND_BASE value does not match!",
                     false);
  assertTrueOrReturn(_entry.values[BAND_LOWER] == bands.GetValue(BAND_LOWER), "Bands BAND_LOWER value does not match!",
                     false);
  assertTrueOrReturn(_entry.values[BAND_UPPER] == bands.GetValue(BAND_UPPER), "Bands BAND_UPPER value does not match!",
                     false);
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

/**
 * Test BearsPower indicator.
 */
bool TestBearsPower() {
  // Get static value.
  double bp_value = Indi_BearsPower::iBearsPower(_Symbol, PERIOD_CURRENT, 13, PRICE_CLOSE);
  // Get dynamic values.
  BearsPowerParams params(13, PRICE_CLOSE);
  Indi_BearsPower *bp = new Indi_BearsPower(params);
  Print("BearsPower: ", bp.GetValue());
  assertTrueOrReturn(bp.GetValue() == bp_value, "BearsPower value does not match!", false);
  bp.SetPeriod(bp.GetPeriod() + 1);
  bp.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete bp;
  return true;
}

/**
 * Test BullsPower indicator.
 */
bool TestBullsPower() {
  // Get static value.
  double bp_value = Indi_BullsPower::iBullsPower(_Symbol, PERIOD_CURRENT, 13, PRICE_CLOSE);
  // Get dynamic values.
  BullsPowerParams params(13, PRICE_CLOSE);
  Indi_BullsPower *bp = new Indi_BullsPower(params);
  Print("BullsPower: ", bp.GetValue());
  assertTrueOrReturn(bp.GetValue() == bp_value, "BullsPower value does not match!", false);
  bp.SetPeriod(bp.GetPeriod() + 1);
  bp.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete bp;
  return true;
}

/**
 * Test CCI indicator.
 */
bool TestCCI() {
  // Get static value.
  double cci_value = Indi_CCI::iCCI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
  // Get dynamic values.
  CCIParams params(14, PRICE_CLOSE);
  Indi_CCI *cci = new Indi_CCI(params);
  Print("CCI: ", cci.GetValue());
  assertTrueOrReturn(cci.GetValue() == cci_value, "CCI value does not match!", false);
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

/**
 * Test DeMarker indicator.
 */
bool TestDeMarker() {
  // Get static value.
  double dm_value = Indi_DeMarker::iDeMarker(_Symbol, PERIOD_CURRENT, 14);
  // Get dynamic values.
  DeMarkerParams params(14);
  Indi_DeMarker *dm = new Indi_DeMarker(params);
  Print("DeMarker: ", dm.GetValue());
  assertTrueOrReturn(dm.GetValue() == dm_value, "DeMarker value does not match!", false);
  dm.SetPeriod(dm.GetPeriod() + 1);
  // Clean up.
  delete dm;
  return true;
}

/**
 * Test Demo indicator.
 */
bool TestDemo() {
  // Get static value.
  double demo_value = Indi_Demo::iDemo();
  // Get dynamic values.
  DemoIndiParams params(PERIOD_CURRENT);
  Indi_Demo *demo = new Indi_Demo(params);
  IndicatorDataEntry _entry = demo.GetEntry();
  Print("Demo: ", _entry.GetValue<double>());
  assertTrueOrReturn(demo.GetValue() == demo_value, "Demo value does not match!", false);
  assertTrueOrReturn(_entry.values[0] == demo_value, "Demo entry value does not match!", false);
  assertTrueOrReturn(_entry.values[0] <= 0, "Demo value is zero or negative!", false);
  // Clean up.
  delete demo;
  return true;
}

/**
 * Test Envelopes indicator.
 */
bool TestEnvelopes() {
  // Get static value.
  double env_value = Indi_Envelopes::iEnvelopes(_Symbol, PERIOD_CURRENT, 13, 0, MODE_SMA, PRICE_CLOSE, 2, LINE_UPPER);
  // Get dynamic values.
  EnvelopesParams params(13, 0, MODE_SMA, PRICE_CLOSE, 2);
  Indi_Envelopes *env = new Indi_Envelopes(params);
  IndicatorDataEntry _entry = env.GetEntry();
  Print("Envelopes: ", _entry.GetValue<double>());
  assertTrueOrReturn(_entry.values[LINE_UPPER] == env_value, "Envelopes value does not match!", false);
  assertTrueOrReturn(_entry.values[LINE_LOWER] == env.GetValue(LINE_LOWER),
                     "Envelopes LINE_LOWER value does not match!", false);
  assertTrueOrReturn(_entry.values[LINE_UPPER] == env.GetValue(LINE_UPPER),
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

/**
 * Test Force indicator.
 */
bool TestForce() {
  // Get static value.
  double force_value = Indi_Force::iForce(_Symbol, PERIOD_CURRENT, 13, MODE_SMA, PRICE_CLOSE);
  // Get dynamic values.
  ForceParams params(13, MODE_SMA, PRICE_CLOSE);
  Indi_Force *force = new Indi_Force(params);
  Print("Force: ", force.GetValue());
  assertTrueOrReturn(force.GetValue() == force_value, "Force value does not match!", false);
  force.SetPeriod(force.GetPeriod() + 1);
  force.SetMAMethod(MODE_SMA);
  force.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete force;
  return true;
}

/**
 * Test Fractals indicator.
 */
bool TestFractals() {
  // Get static value.
  double fractals_value = Indi_Fractals::iFractals(_Symbol, PERIOD_CURRENT, LINE_UPPER);
  // Get dynamic values.
  FractalsParams params(PERIOD_CURRENT);
  Indi_Fractals *fractals = new Indi_Fractals(params);
  Print("Fractals: ", fractals.GetValue(LINE_UPPER));
  assertTrueOrReturn(fractals.GetValue(LINE_UPPER) == fractals_value, "Fractals value does not match!", false);
  // Clean up.
  delete fractals;
  return true;
}

/**
 * Test Gator indicator.
 */
bool TestGator() {
  // Get static value.
  double gator_value =
      Indi_Gator::iGator(_Symbol, PERIOD_CURRENT, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, LINE_UPPER_HISTOGRAM);
  // Get dynamic values.
  GatorParams params(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
  Indi_Gator *gator = new Indi_Gator(params);
  Print("Gator upper: ", gator.GetValue(LINE_UPPER_HISTOGRAM));
  assertTrueOrReturn(gator.GetValue(LINE_UPPER_HISTOGRAM) == gator_value, "Gator value does not match!", false);
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

/**
 * Test HeikenAshi indicator.
 */
bool TestHeikenAshi() {
  // Get static value.
  double ha_value = Indi_HeikenAshi::iHeikenAshi(_Symbol, PERIOD_CURRENT, HA_OPEN);
  // Get dynamic values.
  HeikenAshiParams params(PERIOD_CURRENT);
  Indi_HeikenAshi *ha = new Indi_HeikenAshi(params);
  Print("HeikenAshi: ", ha.GetValue(HA_OPEN));
  assertTrueOrReturn(ha.GetValue(HA_OPEN) == ha_value, "HeikenAshi value does not match!", false);
  // Clean up.
  delete ha;
  return true;
}

/**
 * Test Ichimoku indicator.
 */
bool TestIchimoku() {
  // Get static value.
  double ichimoku_value = Indi_Ichimoku::iIchimoku(_Symbol, PERIOD_CURRENT, 9, 26, 52, LINE_TENKANSEN);
  // Get dynamic values.
  IchimokuParams params(9, 26, 52);
  Indi_Ichimoku *ichimoku = new Indi_Ichimoku(params);
  Print("Ichimoku: ", ichimoku.GetValue(LINE_TENKANSEN));
  assertTrueOrReturn(ichimoku.GetValue(LINE_TENKANSEN) == ichimoku_value, "Ichimoku value does not match!", false);
  ichimoku.SetTenkanSen(ichimoku.GetTenkanSen() + 1);
  ichimoku.SetKijunSen(ichimoku.GetKijunSen() + 1);
  ichimoku.SetSenkouSpanB(ichimoku.GetSenkouSpanB() + 1);
  // Clean up.
  delete ichimoku;
  return true;
}

/**
 * Test MA indicator.
 */
bool TestMA() {
  // Get static value.
  double ma_value = Indi_MA::iMA(_Symbol, PERIOD_CURRENT, 13, 10, MODE_SMA, PRICE_CLOSE);
  // Get dynamic values.
  MAParams params(13, 10, MODE_SMA, PRICE_CLOSE);
  Indi_MA *_ma = new Indi_MA(params);
  Print("MA: ", _ma.GetValue());
  assertTrueOrReturn(_ma.GetValue() == ma_value, "MA value does not match!", false);
  _ma.SetPeriod(_ma.GetPeriod() + 1);
  _ma.SetMAShift(_ma.GetMAShift() + 1);
  _ma.SetMAMethod(MODE_SMA);
  _ma.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete _ma;
  return true;
}

/**
 * Test MACD indicator.
 */
bool TestMACD() {
  // Get static value.
  double macd_value = Indi_MACD::iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
  // Get dynamic values.
  MACDParams params(12, 26, 9, PRICE_CLOSE);
  Indi_MACD *macd = new Indi_MACD(params);
  Print("MACD: ", macd.GetValue(LINE_MAIN));
  assertTrueOrReturn(macd.GetValue(LINE_MAIN) == macd_value, "MACD value does not match!", false);
  macd.SetEmaFastPeriod(macd.GetEmaFastPeriod() + 1);
  macd.SetEmaSlowPeriod(macd.GetEmaSlowPeriod() + 1);
  macd.SetSignalPeriod(macd.GetSignalPeriod() + 1);
  macd.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete macd;
  return true;
}

/**
 * Test MFI indicator.
 */
bool TestMFI() {
  // Get static value.
  double mfi_value = Indi_MFI::iMFI(_Symbol, PERIOD_CURRENT, 14);
  // Get dynamic values.
  MFIParams params(14);
  Indi_MFI *mfi = new Indi_MFI(params);
  Print("MFI: ", mfi.GetValue());
  assertTrueOrReturn(mfi.GetValue() == mfi_value, "MFI value does not match!", false);
  mfi.SetPeriod(mfi.GetPeriod() + 1);
  mfi.SetAppliedVolume(VOLUME_REAL);
  // Clean up.
  delete mfi;
  return true;
}

/**
 * Test Momentum indicator.
 */
bool TestMomentum() {
  // Get static value.
  double mom_value = Indi_Momentum::iMomentum(_Symbol, PERIOD_CURRENT, 12, PRICE_CLOSE);
  // Get dynamic values.
  MomentumParams params(12, PRICE_CLOSE);
  Indi_Momentum *mom = new Indi_Momentum(params);
  Print("Momentum: ", mom.GetValue());
  assertTrueOrReturn(mom.GetValue() == mom_value, "Momentum value does not match!", false);
  mom.SetPeriod(mom.GetPeriod() + 1);
  mom.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete mom;
  return true;
}

/**
 * Test OBV indicator.
 */
bool TestOBV() {
  // Get static value.
  double obv_value = Indi_OBV::iOBV(_Symbol, PERIOD_CURRENT);
  // Get dynamic values.
  OBVParams params;
  Indi_OBV *obv = new Indi_OBV(params);
  Print("OBV: ", obv.GetValue());
  assertTrueOrReturn(obv.GetValue() == obv_value, "OBV value does not match!", false);
  obv.SetAppliedPrice(PRICE_MEDIAN);
  obv.SetAppliedVolume(VOLUME_REAL);
  // Clean up.
  delete obv;
  return true;
}

/**
 * Test OsMA indicator.
 */
bool TestOsMA() {
  // Get static value.
  double osma_value = Indi_OsMA::iOsMA(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
  // Get dynamic values.
  OsMAParams params(12, 26, 9, PRICE_CLOSE);
  Indi_OsMA *osma = new Indi_OsMA(params);
  Print("OsMA: ", osma.GetValue());
  assertTrueOrReturn(osma.GetValue() == osma_value, "OsMA value does not match!", false);
  osma.SetEmaFastPeriod(osma.GetEmaFastPeriod() + 1);
  osma.SetEmaSlowPeriod(osma.GetEmaSlowPeriod() + 1);
  osma.SetSignalPeriod(osma.GetSignalPeriod() + 1);
  osma.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete osma;
  return true;
}

/**
 * Test RSI indicator.
 */
bool TestRSI() {
  // Get static value.
  double rsi_value = Indi_RSI::iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
  // Get dynamic values.
  RSIParams params(14, PRICE_CLOSE);
  Indi_RSI *rsi = new Indi_RSI(params);
  Print("RSI: ", rsi.GetValue());
  assertTrueOrReturn(rsi.GetValue() == rsi_value, "RSI value does not match!", false);
  rsi.SetPeriod(rsi.GetPeriod() + 1);
  rsi.SetAppliedPrice(PRICE_MEDIAN);
  // Clean up.
  delete rsi;
  return true;
}

/**
 * Test RVI indicator.
 */
bool TestRVI() {
  // Get static value.
  double rvi_value = Indi_RVI::iRVI(_Symbol, PERIOD_CURRENT, 14, LINE_MAIN);
  // Get dynamic values.
  RVIParams params(14);
  Indi_RVI *rvi = new Indi_RVI(params);
  Print("RVI: ", rvi.GetValue(LINE_MAIN));
  assertTrueOrReturn(rvi.GetValue(LINE_MAIN) == rvi_value, "RVI value does not match!", false);
  rvi.SetPeriod(rvi.GetPeriod() + 1);
  // Clean up.
  delete rvi;
  return true;
}

/**
 * Test SAR indicator.
 */
bool TestSAR() {
  // Get static value.
  double sar_value = Indi_SAR::iSAR();
  // Get dynamic values.
  SARParams params(0.02, 0.2);
  Indi_SAR *sar = new Indi_SAR(params);
  Print("SAR: ", sar.GetValue(0));
  assertTrueOrReturn(sar.GetValue(0) == sar_value, "SAR value does not match!", false);
  sar.SetStep(sar.GetStep() * 2);
  sar.SetMax(sar.GetMax() * 2);
  // Clean up.
  delete sar;
  return true;
}

#ifdef __MQL4__
struct StdDevTestCase {
  int total, ma_period, ma_shift, ma_method, shift;
};
#endif

/**
 * Test StdDev indicator.
 */
bool TestStdDev() {
  // Get static value.
  double sd_value = Indi_StdDev::iStdDev(_Symbol, PERIOD_CURRENT, 13, 10, MODE_SMA, PRICE_CLOSE);
  // Get dynamic values.
  StdDevParams params(13, 10, MODE_SMA, PRICE_CLOSE);
  Indi_StdDev *sd = new Indi_StdDev(params);
  Print("StdDev: ", sd.GetValue());
  assertTrueOrReturn(sd.GetValue() == sd_value, "StdDev value does not match!", false);
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

/**
 * Test Stochastic indicator.
 */
bool TestStochastic() {
  // Get static value.
  double stoch_value =
      Indi_Stochastic::iStochastic(_Symbol, PERIOD_CURRENT, 5, 3, 3, MODE_SMMA, STO_LOWHIGH, LINE_MAIN);
  // Get dynamic values.
  StochParams params(5, 3, 3, MODE_SMMA, STO_LOWHIGH);
  Indi_Stochastic *stoch = new Indi_Stochastic(params);
  Print("Stochastic: ", stoch.GetValue());
  assertTrueOrReturn(stoch.GetValue() == stoch_value, "Stochastic value does not match!", false);
  stoch.SetKPeriod(stoch.GetKPeriod() + 1);
  stoch.SetDPeriod(stoch.GetDPeriod() + 1);
  stoch.SetSlowing(stoch.GetSlowing() + 1);
  stoch.SetMAMethod(MODE_SMA);
  stoch.SetPriceField(STO_CLOSECLOSE);
  // Clean up.
  delete stoch;
  return true;
}

/**
 * Test WPR indicator.
 */
bool TestWPR() {
  // Get static value.
  double wpr_value = Indi_WPR::iWPR(_Symbol, PERIOD_CURRENT, 14, 0);
  // Get dynamic values.
  WPRParams params(14);
  Indi_WPR *wpr = new Indi_WPR(params);
  Print("WPR: ", wpr.GetValue());
  assertTrueOrReturn(wpr.GetValue() == wpr_value, "WPR value does not match!", false);
  wpr.SetPeriod(wpr.GetPeriod() + 1);
  // Clean up.
  delete wpr;
  return true;
}

/**
 * Test ZigZag indicator.
 */
bool TestZigZag() {
  // Get static value.
  double zz_value = Indi_ZigZag::iZigZag(_Symbol, PERIOD_CURRENT, 12, 5, 3, ZIGZAG_BUFFER, 0);
  // Get dynamic values.
  ZigZagParams params(12, 5, 3);
  Indi_ZigZag *zz = new Indi_ZigZag(params);
  Print("ZigZag: ", zz.GetValue(ZIGZAG_BUFFER));
  assertTrueOrReturn(zz.GetValue(ZIGZAG_BUFFER) == zz_value, "ZigZag value does not match!", false);
  zz.SetDepth(zz.GetDepth() + 1);
  zz.SetDeviation(zz.GetDeviation() + 1);
  zz.SetBackstep(zz.GetBackstep() + 1);
  // Clean up.
  delete zz;
  return true;
}

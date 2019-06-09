# Indicators

This folder contains the classes implementing the following technical indicators.

## AC

Example usage:

    Indi_AC *ac = new Indi_AC();
    Print("AC: ", ac.GetValue());
    delete ac;

Example using a static call:

    double ac_value = Indi_AC::iAC();

## AD

Example usage:

    Indi_AD *ad = new Indi_AD();
    Print("AD: ", ad.GetValue());
    delete ad;

Example using a static call:

    double ad_value = Indi_AD::iAD();

## ADX

Example usage:

    ADX_Params params;
    params.period = 14;
    params.applied_price = PRICE_HIGH;
    Indi_ADX *adx = new Indi_ADX(params);
    Print("ADX: ", adx.GetValue(LINE_MAIN_ADX));
    delete adx;

Example using a static call:

    double adx_value = Indi_ADX::iADX(_Symbol, PERIOD_CURRENT, 14, PRICE_HIGH, );

## AO

Example usage:

    Indi_AO *ao = new Indi_AO();
    Print("AO: ", ao.GetValue());
    delete ao;

Example using a static call:

    double ao_value = Indi_AO::iAO();

## ATR

Example usage:

    ATR_Params params;
    params.period = 14;
    Indi_ATR *atr = new Indi_ATR(params);
    Print("ATR: ", atr.GetValue());
    delete atr;

Example using a static call:

    double atr_value = Indi_ATR::iATR(_Symbol, PERIOD_CURRENT, 14);

## Alligator

Example usage:

    Alligator_Params params;
    params.jaw_period = 13;
    params.jaw_shift = 8;
    params.teeth_period = 8;
    params.teeth_shift = 5;
    params.lips_period = 5;
    params.lips_shift = 3;
    params.ma_method = MODE_SMMA;
    params.applied_price = PRICE_MEDIAN;
    Indi_Alligator *alligator = new Indi_Alligator(params);
    Print("Alligator: ", alligator.GetValue(LINE_JAW));
    delete alligator;

Example using a static call:

    double alligator_value = Indi_Alligator::iAlligator(_Symbol, PERIOD_CURRENT, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, LINE_JAW);

## BWMFI

Example usage:

    Indi_BWMFI *bwmfi = new Indi_BWMFI();
    Print("BWMFI: ", bwmfi.GetValue());
    delete bwmfi;

Example using a static call:

    double bwmfi_value = Indi_BWMFI::iBWMFI();

## Bands

Example usage:

    Bands_Params params;
    params.period = 20;
    params.deviation = 2;
    params.bands_shift = 0;
    params.applied_price = PRICE_LOW;
    Indi_Bands *bands = new Indi_Bands(params);
    Print("Bands: ", bands.GetValue(BAND_BASE));
    delete bands;

Example using a static call:

    double bands_value = Indi_Bands::iBands(_Symbol, PERIOD_CURRENT, 20, 2, 0, PRICE_LOW, BAND_BASE);

## BearsPower

Example usage:

    BearsPower_Params params;
    params.period = 13;
    params.applied_price = PRICE_CLOSE;
    Indi_BearsPower *bp = new Indi_BearsPower(params);
    Print("BearsPower: ", bp.GetValue());
    delete bp;

Example changing params:

    bp.SetPeriod(bp.GetPeriod()+1);
    bp.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double bp_value = Indi_BearsPower::iBearsPower(_Symbol, PERIOD_CURRENT, params.period, params.applied_price);

## BullsPower

Example usage:

    BullsPower_Params params;
    params.period = 13;
    params.applied_price = PRICE_CLOSE;
    Indi_BullsPower *bp = new Indi_BullsPower(params);
    Print("BullsPower: ", bp.GetValue());
    delete bp;

Example changing params:

    bp.SetPeriod(bp.GetPeriod()+1);
    bp.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double bp_value = Indi_BullsPower::iBullsPower(_Symbol, PERIOD_CURRENT, params.period, params.applied_price);

## CCI

Example usage:

    CCI_Params params;
    params.period = 14;
    params.applied_price = PRICE_CLOSE;
    Indi_CCI *cci = new Indi_CCI(params);
    Print("CCI: ", cci.GetValue());
    delete cci;

Example changing params:

    cci.SetPeriod(cci.GetPeriod()+1);

Example using a static call:

    double cci_value = Indi_CCI::iCCI(_Symbol, PERIOD_CURRENT, params.period, params.applied_price);

## DeMarker

Example usage:

    DeMarker_Params params;
    params.period = 14;
    Indi_DeMarker *dm = new Indi_DeMarker(params);
    Print("DeMarker: ", dm.GetValue());
    delete dm;

Example using a static call:

    double dm_value = Indi_DeMarker::iDeMarker(_Symbol, PERIOD_CURRENT, params.period);

## Envelopes

Example usage:

    Envelopes_Params params;
    params.ma_period = 13;
    params.ma_method = MODE_SMA;
    params.ma_shift = 10;
    params.applied_price = PRICE_CLOSE;
    params.deviation = 2;
    Indi_Envelopes *env = new Indi_Envelopes(params);
    Print("Envelopes: ", env.GetValue(LINE_UPPER));
    delete env;

Example changing params:

    env.SetMAPeriod(env.GetMAPeriod()+1);
    env.SetMAMethod(MODE_SMA);
    env.SetMAShift(env.GetMAShift()+1);
    env.SetAppliedPrice(PRICE_MEDIAN);
    env.SetDeviation(env.GetDeviation()+0.1);

Example using a static call:

    double env_value = Indi_Envelopes::iEnvelopes( _Symbol, PERIOD_CURRENT, 13, MODE_SMA, 10, PRICE_CLOSE, 2, LINE_UPPER);

## Force

Example usage:

    Force_Params params;
    params.period = 13;
    params.ma_method = MODE_SMA;
    params.applied_price = PRICE_CLOSE;
    Indi_Force *force = new Indi_Force(params);
    Print("Force: ", force.GetValue());
    delete force;

Example changing params:

    force.SetPeriod(force.GetPeriod()+1);
    force.SetMAMethod(MODE_SMA);
    force.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double force_value = Indi_Force::iForce( _Symbol, PERIOD_CURRENT, 13, MODE_SMA, PRICE_CLOSE);

## Fractals

Example usage:

    Indi_Fractals *fractals = new Indi_Fractals();
    Print("Fractals: ", fractals.GetValue(LINE_UPPER));
    delete fractals;

Example using a static call:

    double fractals_value = Indi_Fractals::iFractals(_Symbol, PERIOD_CURRENT, LINE_UPPER);

## Gator

Example usage:

    Gator_Params params;
    params.jaw_period = 13;
    params.jaw_shift = 8;
    params.teeth_period = 8;
    params.teeth_shift = 5;
    params.lips_period = 5;
    params.lips_shift = 3;
    params.ma_method = MODE_SMMA;
    params.applied_price = PRICE_MEDIAN;
    Indi_Gator *gator = new Indi_Gator(params);
    Print("Gator: ", gator.GetValue(LINE_JAW));
    delete gator;

Example changing params:

    gator.SetJawPeriod(gator.GetJawPeriod()+1);
    gator.SetJawShift(gator.GetJawShift()+1);
    gator.SetTeethPeriod(gator.GetTeethPeriod()+1);
    gator.SetTeethShift(gator.GetTeethShift()+1);
    gator.SetLipsPeriod(gator.GetLipsPeriod()+1);
    gator.SetLipsShift(gator.GetLipsShift()+1);

Example using a static call:

    double gator_value = Indi_Gator::iGator( _Symbol, PERIOD_CURRENT, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, LINE_JAW);

## HeikenAshi

Example usage:

    Indi_HeikenAshi *ha = new Indi_HeikenAshi();
    Print("HeikenAshi: ", ha.GetValue(HA_OPEN));
    delete ha;

Example using a static call:

    double ha_value = Indi_HeikenAshi::iHeikenAshi(_Symbol, PERIOD_CURRENT, HA_OPEN);

## Ichimoku

Example usage:

    Ichimoku_Params params;
    params.tenkan_sen = 9;
    params.kijun_sen = 26;
    params.senkou_span_b = 52;
    Indi_Ichimoku *ichimoku = new Indi_Ichimoku(params);
    Print("Ichimoku: ", ichimoku.GetValue(LINE_TENKANSEN));
    delete ichimoku;

Example changing params:

    ichimoku.SetTenkanSen(ichimoku.GetTenkanSen()+1);
    ichimoku.SetKijunSen(ichimoku.GetKijunSen()+1);
    ichimoku.SetSenkouSpanB(ichimoku.GetSenkouSpanB()+1);

Example using a static call:

    double ichimoku_value = Indi_Ichimoku::iIchimoku( _Symbol, PERIOD_CURRENT, 9, 26, 52, LINE_TENKANSEN);

## MA

Example usage:

    MA_Params params;
    params.ma_period = 13;
    params.ma_shift = 10;
    params.ma_method = MODE_SMA;
    params.applied_price = PRICE_CLOSE;
    Indi_MA *ma = new Indi_MA(params);
    Print("MA: ", ma.GetValue());
    delete ma;

Example changing params:

    ma.SetPeriod(ma.GetPeriod()+1);
    ma.SetMAShift(ma.GetMAShift()+1);
    ma.SetMAMethod(MODE_SMA);
    ma.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double ma_value = Indi_MA::iMA( _Symbol, PERIOD_CURRENT, 13, 0, MODE_SMA, PRICE_CLOSE);

## MACD

Example usage:

    MACD_Params params;
    params.ema_fast_period = 12;
    params.ema_slow_period = 26;
    params.signal_period = 9;
    params.applied_price = PRICE_CLOSE;
    Indi_MACD *macd = new Indi_MACD(params);
    Print("MACD: ", macd.GetValue(LINE_MAIN));
    delete macd;

Example changing params:

    macd.SetEmaFastPeriod(macd.GetEmaFastPeriod()+1);
    macd.SetEmaSlowPeriod(macd.GetEmaSlowPeriod()+1);
    macd.SetSignalPeriod(macd.GetSignalPeriod()+1);
    macd.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double macd_value = Indi_MACD::iMACD( _Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE, LINE_MAIN);

## MFI

Example usage:

    MFI_Params params;
    params.ma_period = 14;
    params.applied_volume = VOLUME_TICK; // Used in MT5 only.
    Indi_MFI *mfi = new Indi_MFI(params);
    Print("MFI: ", mfi.GetValue());

Example changing params:

    mfi.SetPeriod(mfi.GetPeriod()+1);
    mfi.SetAppliedVolume(VOLUME_REAL);

Example using a static call:

    double mfi_value = Indi_MFI::iMFI(_Symbol, PERIOD_CURRENT, params.ma_period);

## Momentum

Example usage:

    Momentum_Params params;
    params.period = 12;
    params.applied_price = PRICE_CLOSE;
    Indi_Momentum *mom = new Indi_Momentum(params);
    Print("Momentum: ", mom.GetValue());
    delete mom;

Example changing params:

    mom.SetPeriod(mom.GetPeriod()+1);
    mom.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double mom_value = Indi_Momentum::iMomentum(_Symbol, PERIOD_CURRENT, 12, PRICE_CLOSE);

## OBV

Example usage:

    OBV_Params params;
    params.applied_price = PRICE_CLOSE; // Used in MT4.
    params.applied_volume = VOLUME_TICK; // Used in MT5.
    Indi_OBV *obv = new Indi_OBV(params);
    Print("OBV: ", obv.GetValue());
    delete obv;

Example changing params:

    obv.SetAppliedPrice(PRICE_MEDIAN);
    obv.SetAppliedVolume(VOLUME_REAL);

Example using a static call:

    double obv_value = Indi_OBV::iOBV(_Symbol, PERIOD_CURRENT, PRICE_CLOSE);

## OsMA

Example usage:

    OsMA_Params params;
    params.ema_fast_period = 12;
    params.ema_slow_period = 26;
    params.signal_period = 9;
    params.applied_price = PRICE_CLOSE;
    Indi_OsMA *osma = new Indi_OsMA(params);
    Print("OsMA: ", osma.GetValue());
    delete osma;

Example changing params:

    osma.SetEmaFastPeriod(osma.GetEmaFastPeriod()+1);
    osma.SetEmaSlowPeriod(osma.GetEmaSlowPeriod()+1);
    osma.SetSignalPeriod(osma.GetSignalPeriod()+1);
    osma.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double osma_value = Indi_OsMA::iOsMA( _Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);

## RSI

Example usage:

    RSI_Params params;
    params.period = 14;
    params.applied_price = PRICE_CLOSE;
    Indi_RSI *rsi = new Indi_RSI(params);
    Print("RSI: ", rsi.GetValue());
    delete rsi;

Example changing params:

    rsi.SetPeriod(rsi.GetPeriod()+1);
    rsi.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double rsi_value = Indi_RSI::iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);

## RVI

Example usage:

    RVI_Params params;
    params.period = 14;
    Indi_RVI *rvi = new Indi_RVI(params);
    Print("RVI: ", rvi.GetValue(LINE_MAIN));
    delete rvi;

Example changing params:

    rvi.SetPeriod(rvi.GetPeriod()+1);

Example using a static call:

    double rvi_value = Indi_RVI::iRVI(_Symbol, PERIOD_CURRENT, 14, LINE_MAIN);

## SAR

Example usage:

    SAR_Params params;
    params.step = 0.02;
    params.max  = 0.2;
    Indi_SAR *sar = new Indi_SAR(params);
    Print("SAR: ", sar.GetValue());
    delete sar;

Example changing params:

    sar.SetStep(sar.GetStep()*2);
    sar.SetMax(sar.GetMax()*2);

Example using a static call:

    double sar_value = Indi_SAR::iSAR();

## StdDev

Example usage:

    StdDev_Params params;
    params.ma_period = 13;
    params.ma_shift = 10;
    params.ma_method = MODE_SMA;
    params.applied_price = PRICE_CLOSE;
    Indi_StdDev *sd = new Indi_StdDev(params);
    Print("StdDev: ", sd.GetValue());
    delete sd;

Example changing params:

    sd.SetPeriod(sd.GetPeriod()+1);
    sd.SetMAShift(sd.GetMAShift()+1);
    sd.SetMAMethod(MODE_SMA);
    sd.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double sd_value = Indi_StdDev::iStdDev( _Symbol, PERIOD_CURRENT, 13, 10, MODE_SMA, PRICE_CLOSE);

## Stochastic

Example usage:

    Stoch_Params params;
    params.kperiod = 5;
    params.dperiod = 3;
    params.slowing = 3;
    params.ma_method = MODE_SMMA;
    params.price_field = STO_LOWHIGH;
    Indi_Stochastic *stoch = new Indi_Stochastic(params);
    Print("Stochastic: ", stoch.GetValue());
    delete stoch;

Example changing params:

    stoch.SetKPeriod(stoch.GetKPeriod()+1);
    stoch.SetDPeriod(stoch.GetDPeriod()+1);
    stoch.SetSlowing(stoch.GetSlowing()+1);
    stoch.SetMAMethod(MODE_SMA);
    stoch.SetPriceField(STO_CLOSECLOSE);

Example using a static call:

    double stoch_value = Indi_Stochastic::iStochastic(_Symbol, PERIOD_CURRENT, 5, 3, 3, MODE_SMMA, STO_LOWHIGH, LINE_MAIN);

## WPR

Example usage:

    WPR_Params params;
    params.period = 14;
    Indi_WPR *wpr = new Indi_WPR(params);
    Print("WPR: ", wpr.GetValue());
    delete wpr;

Example changing params:

    wpr.SetPeriod(wpr.GetPeriod()+1);

Example using a static call:

    double wpr_value = Indi_WPR::iWPR(_Symbol, PERIOD_CURRENT, 14, 0);

## ZigZag

Example usage:

    ZigZag_Params params;
    params.depth = 12;
    params.deviation = 5;
    params.backstep = 3;
    Indi_ZigZag *zz = new Indi_ZigZag(params);
    Print("ZigZag: ", zz.GetValue());
    delete zz;

Example changing params:

    zz.SetDepth(zz.GetDepth()+1);
    zz.SetDeviation(zz.GetDeviation()+1);
    zz.SetBackstep(zz.GetBackstep()+1);

Example using a static call:

    double zz_value = Indi_ZigZag::iZigZag(_Symbol, PERIOD_CURRENT, 12, 5, 3);
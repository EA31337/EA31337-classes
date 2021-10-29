# Indicators

This folder contains the classes implementing the following technical indicators.

## AC

Example usage:

    IndicatorParams iparams;
    Indi_AC *ac = new Indi_AC(iparams);
    Print("AC: ", ac.GetValue());
    delete ac;

Example using a static call:

    double ac_value = Indi_AC::iAC();

## AD

Example usage:

    IndicatorParams iparams;
    Indi_AD *ad = new Indi_AD(iparams);
    Print("AD: ", ad.GetValue());
    delete ad;

Example using a static call:

    double ad_value = Indi_AD::iAD();

## ADX

Example usage:

    IndicatorParams iparams;
    ADX_Params iparams(14, PRICE_HIGH);
    Indi_ADX *adx = new Indi_ADX(iparams, iparams);
    Print("ADX: ", adx.GetValue(LINE_MAIN_ADX));
    delete adx;

Example using a static call:

    double adx_value = Indi_ADX::iADX(_Symbol, PERIOD_CURRENT, 14, PRICE_HIGH, );

## AO

Example usage:

    IndicatorParams iparams;
    Indi_AO *ao = new Indi_AO();
    Print("AO: ", ao.GetValue());
    delete ao;

Example using a static call:

    double ao_value = Indi_AO::iAO();

## ATR

Example usage:

    IndicatorParams iparams;
    ATR_Params iparams(14);
    Indi_ATR *atr = new Indi_ATR(iparams, iparams);
    Print("ATR: ", atr.GetValue());
    delete atr;

Example using a static call:

    double atr_value = Indi_ATR::iATR(_Symbol, PERIOD_CURRENT, 14);

## Alligator

Example usage:

    IndicatorParams iparams;
    Alligator_Params iparams(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
    Indi_Alligator *alligator = new Indi_Alligator(iparams, iparams);
    Print("Alligator: ", alligator.GetValue(LINE_JAW));
    delete alligator;

Example using a static call:

    double alligator_value = Indi_Alligator::iAlligator(_Symbol, PERIOD_CURRENT,
                                                        13, 8, 8, 5, 5, 3,
                                                        MODE_SMMA, PRICE_MEDIAN, LINE_JAW);

## BWMFI

Example usage:

    IndicatorParams iparams;
    Indi_BWMFI *bwmfi = new Indi_BWMFI(iparams);
    Print("BWMFI: ", bwmfi.GetValue());
    delete bwmfi;

Example using a static call:

    double bwmfi_value = Indi_BWMFI::iBWMFI();

## Bands

Example usage:

    IndicatorParams iparams;
    Bands_Params iparams(20, 2, 0, PRICE_LOW);
    Indi_Bands *bands = new Indi_Bands(iparams, iparams);
    Print("Bands: ", bands.GetValue(BAND_BASE));
    delete bands;

Example using a static call:

    double bands_value = Indi_Bands::iBands(_Symbol, PERIOD_CURRENT, 20, 2, 0, PRICE_LOW, BAND_BASE);

## BearsPower

Example usage:

    IndicatorParams iparams;
    BearsPower_Params iparams(13, PRICE_CLOSE);
    Indi_BearsPower *bp = new Indi_BearsPower(iparams, iparams);
    Print("BearsPower: ", bp.GetValue());
    delete bp;

Example changing iparams:

    bp.SetPeriod(bp.GetPeriod()+1);
    bp.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double bp_value = Indi_BearsPower::iBearsPower(_Symbol, PERIOD_CURRENT, 13, PRICE_CLOSE);

## BullsPower

Example usage:

    IndicatorParams iparams;
    BullsPower_Params iparams(13, PRICE_CLOSE);
    Indi_BullsPower *bp = new Indi_BullsPower(iparams, iparams);
    Print("BullsPower: ", bp.GetValue());
    delete bp;

Example changing iparams:

    bp.SetPeriod(bp.GetPeriod()+1);
    bp.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double bp_value = Indi_BullsPower::iBullsPower(_Symbol, PERIOD_CURRENT, 13, PRICE_CLOSE);

## CCI

Example usage:

    IndicatorParams iparams;
    CCI_Params iparams(14, PRICE_CLOSE);
    Indi_CCI *cci = new Indi_CCI(iparams, iparams);
    Print("CCI: ", cci.GetValue());
    delete cci;

Example changing iparams:

    cci.SetPeriod(cci.GetPeriod()+1);

Example using a static call:

    double cci_value = Indi_CCI::iCCI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);

## DeMarker

Example usage:

    IndicatorParams iparams;
    DeMarker_Params iparams;
    iparams.period = 14;
    Indi_DeMarker *dm = new Indi_DeMarker(iparams, iparams);
    Print("DeMarker: ", dm.GetValue());
    delete dm;

Example using a static call:

    double dm_value = Indi_DeMarker::iDeMarker(_Symbol, PERIOD_CURRENT, iparams.period);

## Envelopes

Example usage:

    IndicatorParams iparams;
    Envelopes_Params iparams(13, 0, MODE_SMA, PRICE_CLOSE, 2);
    Indi_Envelopes *env = new Indi_Envelopes(iparams, iparams);
    Print("Envelopes: ", env.GetValue(LINE_UPPER));
    delete env;

Example changing iparams:

    env.SetMAPeriod(env.GetMAPeriod()+1);
    env.SetMAMethod(MODE_SMA);
    env.SetMAShift(env.GetMAShift()+1);
    env.SetAppliedPrice(PRICE_MEDIAN);
    env.SetDeviation(env.GetDeviation()+0.1);

Example using a static call:

    double env_value = Indi_Envelopes::iEnvelopes( _Symbol, PERIOD_CURRENT, 13, MODE_SMA, 10, PRICE_CLOSE, 2, LINE_UPPER);

## Force

Example usage:

    IndicatorParams iparams;
    Force_Params iparams(13, MODE_SMA, PRICE_CLOSE);
    Indi_Force *force = new Indi_Force(iparams, iparams);
    Print("Force: ", force.GetValue());
    delete force;

Example changing iparams:

    force.SetPeriod(force.GetPeriod()+1);
    force.SetMAMethod(MODE_SMA);
    force.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double force_value = Indi_Force::iForce( _Symbol, PERIOD_CURRENT, 13, MODE_SMA, PRICE_CLOSE);

## Fractals

Example usage:

    IndicatorParams iparams;
    Indi_Fractals *fractals = new Indi_Fractals(iparams);
    Print("Fractals: ", fractals.GetValue(LINE_UPPER));
    delete fractals;

Example using a static call:

    double fractals_value = Indi_Fractals::iFractals(_Symbol, PERIOD_CURRENT, LINE_UPPER);

## Gator

Example usage:

    IndicatorParams iparams;
    Gator_Params iparams(13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN);
    Indi_Gator *gator = new Indi_Gator(iparams, iparams);
    Print("Gator: ", gator.GetValue(LINE_JAW));
    delete gator;

Example changing iparams:

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

    IndicatorParams iparams;
    Indi_HeikenAshi *ha = new Indi_HeikenAshi(iparams);
    Print("HeikenAshi: ", ha.GetValue(HA_OPEN));
    delete ha;

Example using a static call:

    double ha_value = Indi_HeikenAshi::iHeikenAshi(_Symbol, PERIOD_CURRENT, HA_OPEN);

## Ichimoku

Example usage:

    IndicatorParams iparams;
    Ichimoku_Params iparams(9, 26, 52);
    Indi_Ichimoku *ichimoku = new Indi_Ichimoku(iparams, iparams);
    Print("Ichimoku: ", ichimoku.GetValue(LINE_TENKANSEN));
    delete ichimoku;

Example changing iparams:

    ichimoku.SetTenkanSen(ichimoku.GetTenkanSen()+1);
    ichimoku.SetKijunSen(ichimoku.GetKijunSen()+1);
    ichimoku.SetSenkouSpanB(ichimoku.GetSenkouSpanB()+1);

Example using a static call:

    double ichimoku_value = Indi_Ichimoku::iIchimoku( _Symbol, PERIOD_CURRENT, 9, 26, 52, LINE_TENKANSEN);

## MA

Example usage:

    IndicatorParams iparams;
    MA_Params iparams(13, 10, MODE_SMA, PRICE_CLOSE);
    Indi_MA *ma = new Indi_MA(iparams, iparams);
    Print("MA: ", ma.GetValue());
    delete ma;

Example changing iparams:

    ma.SetPeriod(ma.GetPeriod()+1);
    ma.SetMAShift(ma.GetMAShift()+1);
    ma.SetMAMethod(MODE_SMA);
    ma.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double ma_value = Indi_MA::iMA( _Symbol, PERIOD_CURRENT, 13, 0, MODE_SMA, PRICE_CLOSE);

## MACD

Example usage:

    IndicatorParams iparams;
    MACD_Params iparams(12, 26, 9, PRICE_CLOSE);
    Indi_MACD *macd = new Indi_MACD(iparams, iparams);
    Print("MACD: ", macd.GetValue(LINE_MAIN));
    delete macd;

Example changing iparams:

    macd.SetEmaFastPeriod(macd.GetEmaFastPeriod()+1);
    macd.SetEmaSlowPeriod(macd.GetEmaSlowPeriod()+1);
    macd.SetSignalPeriod(macd.GetSignalPeriod()+1);
    macd.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double macd_value = Indi_MACD::iMACD( _Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE, LINE_MAIN);

## MFI

Example usage:

    IndicatorParams iparams;
    MFI_Params iparams;
    iparams.ma_period = 14;
    iparams.applied_volume = VOLUME_TICK; // Used in MT5 only.
    Indi_MFI *mfi = new Indi_MFI(iparams, iparams);
    Print("MFI: ", mfi.GetValue());

Example changing iparams:

    mfi.SetPeriod(mfi.GetPeriod()+1);
    mfi.SetAppliedVolume(VOLUME_REAL);

Example using a static call:

    double mfi_value = Indi_MFI::iMFI(_Symbol, PERIOD_CURRENT, 14);

## Momentum

Example usage:

    IndicatorParams iparams;
    Momentum_Params iparams(12, PRICE_CLOSE);
    Indi_Momentum *mom = new Indi_Momentum(iparams, iparams);
    Print("Momentum: ", mom.GetValue());
    delete mom;

Example changing iparams:

    mom.SetPeriod(mom.GetPeriod()+1);
    mom.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double mom_value = Indi_Momentum::iMomentum(_Symbol, PERIOD_CURRENT, 12, PRICE_CLOSE);

## OBV

Example usage:

    IndicatorParams iparams;
    OBV_Params iparams;
    iparams.applied_price = PRICE_CLOSE; // Used in MT4.
    iparams.applied_volume = VOLUME_TICK; // Used in MT5.
    Indi_OBV *obv = new Indi_OBV(iparams, iparams);
    Print("OBV: ", obv.GetValue());
    delete obv;

Example changing iparams:

    obv.SetAppliedPrice(PRICE_MEDIAN);
    obv.SetAppliedVolume(VOLUME_REAL);

Example using a static call:

    double obv_value = Indi_OBV::iOBV(_Symbol, PERIOD_CURRENT, PRICE_CLOSE);

## OsMA

Example usage:

    IndicatorParams iparams;
    OsMA_Params iparams(12, 26, 9, PRICE_CLOSE);
    iparams.applied_price = PRICE_CLOSE;
    Indi_OsMA *osma = new Indi_OsMA(iparams, iparams);
    Print("OsMA: ", osma.GetValue());
    delete osma;

Example changing iparams:

    osma.SetEmaFastPeriod(osma.GetEmaFastPeriod()+1);
    osma.SetEmaSlowPeriod(osma.GetEmaSlowPeriod()+1);
    osma.SetSignalPeriod(osma.GetSignalPeriod()+1);
    osma.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double osma_value = Indi_OsMA::iOsMA( _Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);

## RSI

Example usage:

    IndicatorParams iparams;
    RSI_Params iparams(14, PRICE_CLOSE);
    Indi_RSI *rsi = new Indi_RSI(iparams, iparams);
    Print("RSI: ", rsi.GetValue());
    delete rsi;

Example changing iparams:

    rsi.SetPeriod(rsi.GetPeriod()+1);
    rsi.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double rsi_value = Indi_RSI::iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);

## RVI

Example usage:

    IndicatorParams iparams;
    RVI_Params iparams(14);
    Indi_RVI *rvi = new Indi_RVI(iparams, iparams);
    Print("RVI: ", rvi.GetValue(LINE_MAIN));
    delete rvi;

Example changing iparams:

    rvi.SetPeriod(rvi.GetPeriod()+1);

Example using a static call:

    double rvi_value = Indi_RVI::iRVI(_Symbol, PERIOD_CURRENT, 14, LINE_MAIN);

## SAR

Example usage:

    IndicatorParams iparams;
    SAR_Params iparams(0.02, 0.2);
    Indi_SAR *sar = new Indi_SAR(iparams, iparams);
    Print("SAR: ", sar.GetValue());
    delete sar;

Example changing iparams:

    sar.SetStep(sar.GetStep()*2);
    sar.SetMax(sar.GetMax()*2);

Example using a static call:

    double sar_value = Indi_SAR::iSAR();

## StdDev

Example usage:

    IndicatorParams iparams;
    StdDev_Params iparams(13, 10, MODE_SMA, PRICE_CLOSE);
    Indi_StdDev *sd = new Indi_StdDev(iparams, iparams);
    Print("StdDev: ", sd.GetValue());
    delete sd;

Example changing iparams:

    sd.SetPeriod(sd.GetPeriod()+1);
    sd.SetMAShift(sd.GetMAShift()+1);
    sd.SetMAMethod(MODE_SMA);
    sd.SetAppliedPrice(PRICE_MEDIAN);

Example using a static call:

    double sd_value = Indi_StdDev::iStdDev( _Symbol, PERIOD_CURRENT, 13, 10, MODE_SMA, PRICE_CLOSE);

## Stochastic

Example usage:

    IndicatorParams iparams;
    Stoch_Params iparams(5, 3, 3, MODE_SMMA, STO_LOWHIGH);
    Indi_Stochastic *stoch = new Indi_Stochastic(iparams, iparams);
    Print("Stochastic: ", stoch.GetValue());
    delete stoch;

Example changing iparams:

    stoch.SetKPeriod(stoch.GetKPeriod()+1);
    stoch.SetDPeriod(stoch.GetDPeriod()+1);
    stoch.SetSlowing(stoch.GetSlowing()+1);
    stoch.SetMAMethod(MODE_SMA);
    stoch.SetPriceField(STO_CLOSECLOSE);

Example using a static call:

    double stoch_value = Indi_Stochastic::iStochastic(_Symbol, PERIOD_CURRENT, 5, 3, 3, MODE_SMMA, STO_LOWHIGH, LINE_MAIN);

## WPR

Example usage:

    IndicatorParams iparams;
    WPR_Params iparams(14);
    Indi_WPR *wpr = new Indi_WPR(iparams, iparams);
    Print("WPR: ", wpr.GetValue());
    delete wpr;

Example changing iparams:

    wpr.SetPeriod(wpr.GetPeriod()+1);

Example using a static call:

    double wpr_value = Indi_WPR::iWPR(_Symbol, PERIOD_CURRENT, 14, 0);

## ZigZag

Example usage:

    IndicatorParams iparams;
    ZigZag_Params iparams(12, 5, 3);
    Indi_ZigZag *zz = new Indi_ZigZag(iparams, iparams);
    Print("ZigZag: ", zz.GetValue());
    delete zz;

Example changing iparams:

    zz.SetDepth(zz.GetDepth()+1);
    zz.SetDeviation(zz.GetDeviation()+1);
    zz.SetBackstep(zz.GetBackstep()+1);

Example using a static call:

    double zz_value = Indi_ZigZag::iZigZag(_Symbol, PERIOD_CURRENT, 12, 5, 3);

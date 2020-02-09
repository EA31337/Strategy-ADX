//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ADX_EURUSD_M5_Params : Stg_ADX_Params {
  Stg_ADX_EURUSD_M5_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M5;
    ADX_Period = 14;
    ADX_Applied_Price = 1;
    ADX_Shift = 0;
    ADX_SignalOpenMethod = 0;
    ADX_SignalOpenLevel = 0;
    ADX_SignalCloseMethod = 0;
    ADX_SignalCloseLevel = 0;
    ADX_PriceLimitMethod = 0;
    ADX_PriceLimitLevel = 0;
    ADX_MaxSpread = 0;
  }
} stg_adx_m5;

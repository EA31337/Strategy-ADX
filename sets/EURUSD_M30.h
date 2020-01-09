//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ADX_EURUSD_M30_Params : Stg_ADX_Params {
  Stg_ADX_EURUSD_M30_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M30;
    ADX_Period = 14;
    ADX_Applied_Price = 1;
    ADX_Shift = 0;
    ADX_TrailingStopMethod = 0;
    ADX_TrailingProfitMethod = 0;
    ADX_SignalOpenLevel = 0;
    ADX_SignalBaseMethod = 0;
    ADX_SignalOpenMethod1 = 0;
    ADX_SignalOpenMethod2 = 0;
    ADX_SignalCloseLevel = 0;
    ADX_SignalCloseMethod1 = 0;
    ADX_SignalCloseMethod2 = 0;
    ADX_MaxSpread = 0;
  }
};

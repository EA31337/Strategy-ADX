/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_ADX_Params_M1 : ADXParams {
  Indi_ADX_Params_M1() : ADXParams(indi_adx_defaults, PERIOD_M1) {
    applied_price = (ENUM_APPLIED_PRICE)3;
    period = 24;
    shift = 0;
  }
} indi_adx_m1;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ADX_Params_M1 : StgParams {
  // Struct constructor.
  Stg_ADX_Params_M1() : StgParams(stg_adx_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)100;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0;
    price_stop_method = 0;
    price_stop_level = (float)1;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_adx_m1;

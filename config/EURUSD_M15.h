/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_ADX_Params_M15 : Indi_ADX_Params {
  Indi_ADX_Params_M15() : Indi_ADX_Params(indi_force_defaults, PERIOD_M15) {
    applied_price = (ENUM_APPLIED_PRICE)2;
    ma_method = 0;
    period = 16;
    shift = 0;
  }
} indi_force_m15;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ADX_Params_M15 : StgParams {
  // Struct constructor.
  Stg_ADX_Params_M15() : StgParams(stg_force_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = 100;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = 0;
    price_stop_method = 0;
    price_stop_level = 1;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_force_m15;

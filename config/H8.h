/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_ADX_Params_H8 : ADXParams {
  Indi_ADX_Params_H8() : ADXParams(indi_adx_defaults, PERIOD_H8) {
    period = 16;
    applied_price = (ENUM_APPLIED_PRICE)0;
    shift = 0;
  }
} indi_adx_h8;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ADX_Params_H8 : StgParams {
  // Struct constructor.
  Stg_ADX_Params_H8() : StgParams(stg_adx_defaults) {
    lot_size = 0;
    signal_open_method = -34;
    signal_open_level = (float)0;
    signal_open_boost = 0;
    signal_close_method = 4;
    signal_close_level = (float)0;
    price_profit_method = 60;
    price_profit_level = (float)6;
    price_stop_method = 60;
    price_stop_level = (float)6;
    tick_filter_method = 32;
    max_spread = 0;
  }
} stg_adx_h8;

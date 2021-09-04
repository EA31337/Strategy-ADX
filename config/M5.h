/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_ADX_Params_M5 : ADXParams {
  Indi_ADX_Params_M5() : ADXParams(indi_adx_defaults, PERIOD_M5) {}
} indi_adx_m5;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ADX_Params_M5 : StgParams {
  // Struct constructor.
  Stg_ADX_Params_M5() : StgParams(stg_adx_defaults) {}
} stg_adx_m5;

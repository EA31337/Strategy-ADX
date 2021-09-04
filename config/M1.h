/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_ADX_Params_M1 : ADXParams {
  Indi_ADX_Params_M1() : ADXParams(indi_adx_defaults, PERIOD_M1) {}
} indi_adx_m1;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ADX_Params_M1 : StgParams {
  // Struct constructor.
  Stg_ADX_Params_M1() : StgParams(stg_adx_defaults) {}
} stg_adx_m1;

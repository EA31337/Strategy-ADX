/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_ADX_Params_M15 : IndiADXParams {
  Indi_ADX_Params_M15() : IndiADXParams(indi_adx_defaults, PERIOD_M15) {}
} indi_adx_m15;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ADX_Params_M15 : StgParams {
  // Struct constructor.
  Stg_ADX_Params_M15() : StgParams(stg_adx_defaults) {}
} stg_adx_m15;

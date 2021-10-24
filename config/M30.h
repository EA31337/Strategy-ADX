/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_ADX_Params_M30 : IndiADXParams {
  Indi_ADX_Params_M30() : IndiADXParams(indi_adx_defaults, PERIOD_M30) {}
} indi_adx_m30;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ADX_Params_M30 : StgParams {
  // Struct constructor.
  Stg_ADX_Params_M30() : StgParams(stg_adx_defaults) {}
} stg_adx_m30;

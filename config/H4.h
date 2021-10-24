/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_ADX_Params_H4 : IndiADXParams {
  Indi_ADX_Params_H4() : IndiADXParams(indi_adx_defaults, PERIOD_H4) {}
} indi_adx_h4;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ADX_Params_H4 : StgParams {
  // Struct constructor.
  Stg_ADX_Params_H4() : StgParams(stg_adx_defaults) {}
} stg_adx_h4;

/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_ADX_Params_H1 : IndiADXParams {
  Indi_ADX_Params_H1() : IndiADXParams(indi_adx_defaults, PERIOD_H1) {}
} indi_adx_h1;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ADX_Params_H1 : StgParams {
  // Struct constructor.
  Stg_ADX_Params_H1() : StgParams(stg_adx_defaults) {}
} stg_adx_h1;

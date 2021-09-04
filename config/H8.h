/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_ADX_Params_H8 : ADXParams {
  Indi_ADX_Params_H8() : ADXParams(indi_adx_defaults, PERIOD_H8) {}
} indi_adx_h8;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_ADX_Params_H8 : StgParams {
  // Struct constructor.
  Stg_ADX_Params_H8() : StgParams(stg_adx_defaults) {}
} stg_adx_h8;

/**
 * @file
 * Implements ADX strategy based on the Average Directional Movement Index indicator.
 */

// User input params.
INPUT_GROUP("ADX strategy: strategy params");
INPUT float ADX_LotSize = 0;                // Lot size
INPUT int ADX_SignalOpenMethod = 16;        // Signal open method (-127-127)
INPUT float ADX_SignalOpenLevel = 3.0f;     // Signal open level
INPUT int ADX_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int ADX_SignalOpenFilterTime = 10;    // Signal open filter time
INPUT int ADX_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int ADX_SignalCloseMethod = 4;        // Signal close method (-127-127)
INPUT int ADX_SignalCloseFilter = 0;        // Signal close filter (-127-127)
INPUT float ADX_SignalCloseLevel = 0.0f;    // Signal close level (>0.0001)
INPUT int ADX_PriceStopMethod = 3;          // Price stop method (0-127)
INPUT float ADX_PriceStopLevel = 2;         // Price stop level
INPUT int ADX_TickFilterMethod = -48;       // Tick filter method
INPUT float ADX_MaxSpread = 4.0;            // Max spread to trade (pips)
INPUT short ADX_Shift = 0;                  // Shift (relative to the current bar, 0 - default)
INPUT float ADX_OrderCloseLoss = 0;         // Order close loss
INPUT float ADX_OrderCloseProfit = 0;       // Order close profit
INPUT int ADX_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("ADX strategy: ADX indicator params");
INPUT int ADX_Indi_ADX_Period = 14;                                // Averaging period
INPUT ENUM_APPLIED_PRICE ADX_Indi_ADX_Applied_Price = PRICE_HIGH;  // Applied price.
INPUT int ADX_Indi_ADX_Shift = 0;                                  // Shift

// Structs.

// Defines struct with default user indicator values.
struct Indi_ADX_Params_Defaults : ADXParams {
  Indi_ADX_Params_Defaults() : ADXParams(::ADX_Indi_ADX_Period, ::ADX_Indi_ADX_Applied_Price, ::ADX_Indi_ADX_Shift) {}
} indi_adx_defaults;

// Defines struct with default user strategy values.
struct Stg_ADX_Params_Defaults : StgParams {
  Stg_ADX_Params_Defaults()
      : StgParams(::ADX_SignalOpenMethod, ::ADX_SignalOpenFilterMethod, ::ADX_SignalOpenLevel,
                  ::ADX_SignalOpenBoostMethod, ::ADX_SignalCloseMethod, ::ADX_SignalCloseFilter, ::ADX_SignalCloseLevel,
                  ::ADX_PriceStopMethod, ::ADX_PriceStopLevel, ::ADX_TickFilterMethod, ::ADX_MaxSpread, ::ADX_Shift) {
    Set(STRAT_PARAM_OCL, ADX_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, ADX_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, ADX_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, ADX_SignalOpenFilterTime);
  }
} stg_adx_defaults;

// Struct to define strategy parameters to override.
struct Stg_ADX_Params : StgParams {
  ADXParams iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_ADX_Params(ADXParams &_iparams, StgParams &_sparams)
      : iparams(indi_adx_defaults, _iparams.tf.GetTf()), sparams(stg_adx_defaults) {
    iparams = _iparams;
    sparams = _sparams;
  }
};

#ifdef __config__
// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"
#endif

class Stg_ADX : public Strategy {
 public:
  Stg_ADX(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_ADX *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    ADXParams _indi_params(indi_adx_defaults, _tf);
    StgParams _stg_params(stg_adx_defaults);
#ifdef __config__
    SetParamsByTf<ADXParams>(_indi_params, _tf, indi_adx_m1, indi_adx_m5, indi_adx_m15, indi_adx_m30, indi_adx_h1,
                             indi_adx_h4, indi_adx_h8);
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_adx_m1, stg_adx_m5, stg_adx_m15, stg_adx_m30, stg_adx_h1, stg_adx_h4,
                             stg_adx_h8);
#endif
    // Initialize indicator.
    ADXParams adx_params(_indi_params);
    _stg_params.SetIndicator(new Indi_ADX(_indi_params));
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams(_magic_no, _log_level);
    Strategy *_strat = new Stg_ADX(_stg_params, _tparams, _cparams, "ADX");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_ADX *_indi = GetIndicator();
    bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    IndicatorSignal _signals = _indi.GetSignals(4, _shift, LINE_MINUSDI, LINE_PLUSDI);
    switch (_cmd) {
      // Buy: +DI line is above -DI line, ADX is more than a certain value and grows (i.e. trend strengthens).
      case ORDER_TYPE_BUY:
        _result &= _indi[CURR][(int)LINE_MINUSDI] < _indi[CURR][(int)LINE_PLUSDI];
        _result &= _indi.IsIncByPct(_level, 0, 0, 3);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
      // Sell: -DI line is above +DI line, ADX is more than a certain value and grows (i.e. trend strengthens).
      case ORDER_TYPE_SELL:
        _result &= _indi[CURR][(int)LINE_MINUSDI] > _indi[CURR][(int)LINE_PLUSDI];
        _result &= _indi.IsDecByPct(-_level, 0, 0, 3);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
    }
    return _result;
  }
};

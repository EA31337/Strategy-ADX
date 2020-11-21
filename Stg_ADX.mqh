/**
 * @file
 * Implements ADX strategy based on the Average Directional Movement Index indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_ADX.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT float ADX_LotSize = 0;                 // Lot size
INPUT int ADX_SignalOpenMethod = 0;          // Signal open method
INPUT float ADX_SignalOpenLevel = 0.0004f;   // Signal open level (>0.0001)
INPUT int ADX_SignalOpenFilterMethod = 0;    // Signal open filter method
INPUT int ADX_SignalOpenBoostMethod = 0;     // Signal open boost method
INPUT int ADX_SignalCloseMethod = 0;         // Signal close method
INPUT float ADX_SignalCloseLevel = 0.0004f;  // Signal close level (>0.0001)
INPUT int ADX_PriceLimitMethod = 0;          // Price limit method
INPUT float ADX_PriceLimitLevel = 2;         // Price limit level
INPUT int ADX_TickFilterMethod = 0;          // Tick filter method
INPUT float ADX_MaxSpread = 6.0;             // Max spread to trade (pips)
INPUT int ADX_Shift = 0;                     // Shift (relative to the current bar, 0 - default)
INPUT string __ADX_Indi_ADX_Parameters__ =
    "-- ADX strategy: ADX indicator params --";                // >>> ADX strategy: ADX indicator <<<
INPUT int Indi_ADX_Period = 14;                                // Averaging period
INPUT ENUM_APPLIED_PRICE Indi_ADX_Applied_Price = PRICE_HIGH;  // Applied price.

// Structs.

// Defines struct with default user indicator values.
struct Indi_ADX_Params_Defaults : ADXParams {
  Indi_ADX_Params_Defaults() : ADXParams(::Indi_ADX_Period, ::Indi_ADX_Applied_Price) {}
} indi_adx_defaults;

// Defines struct to store indicator parameter values.
struct Indi_ADX_Params : public ADXParams {
  // Struct constructors.
  void Indi_ADX_Params(ADXParams &_params, ENUM_TIMEFRAMES _tf) : ADXParams(_params, _tf) {}
};

// Defines struct with default user strategy values.
struct Stg_ADX_Params_Defaults : StgParams {
  Stg_ADX_Params_Defaults()
      : StgParams(::ADX_SignalOpenMethod, ::ADX_SignalOpenFilterMethod, ::ADX_SignalOpenLevel,
                  ::ADX_SignalOpenBoostMethod, ::ADX_SignalCloseMethod, ::ADX_SignalCloseLevel, ::ADX_PriceLimitMethod,
                  ::ADX_PriceLimitLevel, ::ADX_TickFilterMethod, ::ADX_MaxSpread, ::ADX_Shift) {}
} stg_adx_defaults;

// Struct to define strategy parameters to override.
struct Stg_ADX_Params : StgParams {
  Indi_ADX_Params iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_ADX_Params(Indi_ADX_Params &_iparams, StgParams &_sparams)
      : iparams(indi_adx_defaults, _iparams.tf), sparams(stg_adx_defaults) {
    iparams = _iparams;
    sparams = _sparams;
  }
};

// Loads pair specific param values.
#include "config/EURUSD_H1.h"
#include "config/EURUSD_H4.h"
#include "config/EURUSD_H8.h"
#include "config/EURUSD_M1.h"
#include "config/EURUSD_M15.h"
#include "config/EURUSD_M30.h"
#include "config/EURUSD_M5.h"

class Stg_ADX : public Strategy {
 public:
  Stg_ADX(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_ADX *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Indi_ADX_Params _indi_params(indi_adx_defaults, _tf);
    StgParams _stg_params(stg_adx_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Indi_ADX_Params>(_indi_params, _tf, indi_adx_m1, indi_adx_m5, indi_adx_m15, indi_adx_m30,
                                     indi_adx_h1, indi_adx_h4, indi_adx_h8);
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_adx_m1, stg_adx_m5, stg_adx_m15, stg_adx_m30, stg_adx_h1,
                               stg_adx_h4, stg_adx_h8);
    }
    // Initialize indicator.
    ADXParams adx_params(_indi_params);
    _stg_params.SetIndicator(new Indi_ADX(_indi_params));
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_ADX(_stg_params, "ADX");
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0) {
    Indi_ADX *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid();
    bool _result = _is_valid;
    switch (_cmd) {
      // Buy: +DI line is above -DI line, ADX is more than a certain value and grows (i.e. trend strengthens).
      case ORDER_TYPE_BUY:
        _result &= _indi[CURR].value[LINE_MINUSDI] < _indi[CURR].value[LINE_PLUSDI] &&
                   _indi[CURR].value[LINE_MAIN_ADX] >= _level;
        if (METHOD(_method, 0)) _result &= _indi[CURR].value[LINE_MAIN_ADX] > _indi[PREV].value[LINE_MAIN_ADX];
        if (METHOD(_method, 1)) _result &= _indi[PREV].value[LINE_MAIN_ADX] > _indi[PPREV].value[LINE_MAIN_ADX];
        break;
      // Sell: -DI line is above +DI line, ADX is more than a certain value and grows (i.e. trend strengthens).
      case ORDER_TYPE_SELL:
        _result &= _indi[CURR].value[LINE_MINUSDI] > _indi[CURR].value[LINE_PLUSDI] &&
                   _indi[CURR].value[LINE_MAIN_ADX] >= _level;
        if (METHOD(_method, 0)) _result &= _indi[CURR].value[LINE_MAIN_ADX] > _indi[PREV].value[LINE_MAIN_ADX];
        if (METHOD(_method, 1)) _result &= _indi[PREV].value[LINE_MAIN_ADX] > _indi[PPREV].value[LINE_MAIN_ADX];
        break;
    }
    return _result;
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  float PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_ADX *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid();
    double _trail = _level * Market().GetPipSize();
    int _bar_count = (int)_level * (int)_indi.GetPeriod();
    int _bar_lowest = _indi.GetLowest(_bar_count), _bar_highest = _indi.GetHighest(_bar_count);
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    ENUM_APPLIED_PRICE _ap = _direction > 0 ? PRICE_HIGH : PRICE_LOW;
    switch (_method) {
      case 0:
        _result = _direction > 0 ? _indi.GetPrice(_ap, _bar_highest) : _indi.GetPrice(_ap, _bar_lowest);
        break;
      case 1:
        _result = _direction > 0 ? fmax(_indi.GetPrice(_ap, _bar_lowest), _indi.GetPrice(_ap, _bar_highest))
                                 : fmin(_indi.GetPrice(_ap, _bar_lowest), _indi.GetPrice(_ap, _bar_highest));
        break;
    }
    return (float)_result;
  }
};

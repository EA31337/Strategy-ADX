/**
 * @file
 * Implements ADX strategy based on the Average Directional Movement Index indicator.
 */

// User input params.
INPUT int ADX_Period = 14;                                // Averaging period
INPUT ENUM_APPLIED_PRICE ADX_Applied_Price = PRICE_HIGH;  // Applied price.
INPUT int ADX_Shift = 0;                                  // Shift (relative to the current bar, 0 - default)
INPUT int ADX_SignalOpenMethod = 0;                       // Signal open method
INPUT float ADX_SignalOpenLevel = 0.0004f;                // Signal open level (>0.0001)
INPUT int ADX_SignalOpenFilterMethod = 0;                 // Signal open filter method
INPUT int ADX_SignalOpenBoostMethod = 0;                  // Signal open boost method
INPUT int ADX_SignalCloseMethod = 0;                      // Signal close method
INPUT float ADX_SignalCloseLevel = 0.0004f;               // Signal close level (>0.0001)
INPUT int ADX_PriceLimitMethod = 0;                       // Price limit method
INPUT float ADX_PriceLimitLevel = 2;                      // Price limit level
INPUT float ADX_MaxSpread = 6.0;                          // Max spread to trade (pips)

// Includes.
#include <EA31337-classes/Indicators/Indi_ADX.mqh>
#include <EA31337-classes/Strategy.mqh>

// Struct to define strategy parameters to override.
struct Stg_ADX_Params : StgParams {
  unsigned int ADX_Period;
  ENUM_APPLIED_PRICE ADX_Applied_Price;
  int ADX_Shift;
  int ADX_SignalOpenMethod;
  float ADX_SignalOpenLevel;
  int ADX_SignalOpenFilterMethod;
  int ADX_SignalOpenBoostMethod;
  int ADX_SignalCloseMethod;
  float ADX_SignalCloseLevel;
  int ADX_PriceLimitMethod;
  float ADX_PriceLimitLevel;
  float ADX_MaxSpread;

  // Constructor: Set default param values.
  Stg_ADX_Params()
      : ADX_Period(::ADX_Period),
        ADX_Applied_Price(::ADX_Applied_Price),
        ADX_Shift(::ADX_Shift),
        ADX_SignalOpenMethod(::ADX_SignalOpenMethod),
        ADX_SignalOpenLevel(::ADX_SignalOpenLevel),
        ADX_SignalOpenFilterMethod(::ADX_SignalOpenFilterMethod),
        ADX_SignalOpenBoostMethod(::ADX_SignalOpenBoostMethod),
        ADX_SignalCloseMethod(::ADX_SignalCloseMethod),
        ADX_SignalCloseLevel(::ADX_SignalCloseLevel),
        ADX_PriceLimitMethod(::ADX_PriceLimitMethod),
        ADX_PriceLimitLevel(::ADX_PriceLimitLevel),
        ADX_MaxSpread(::ADX_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_ADX : public Strategy {
 public:
  Stg_ADX(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_ADX *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_ADX_Params _params;
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Stg_ADX_Params>(_params, _tf, stg_adx_m1, stg_adx_m5, stg_adx_m15, stg_adx_m30, stg_adx_h1,
                                    stg_adx_h4, stg_adx_h4);
    }
    // Initialize strategy parameters.
    ADXParams adx_params(_params.ADX_Period, _params.ADX_Applied_Price);
    adx_params.SetTf(_tf);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_ADX(adx_params), NULL, NULL);
    sparams.logger.Ptr().SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.ADX_SignalOpenMethod, _params.ADX_SignalOpenLevel, _params.ADX_SignalOpenFilterMethod,
                       _params.ADX_SignalOpenBoostMethod, _params.ADX_SignalCloseMethod, _params.ADX_SignalCloseLevel);
    sparams.SetPriceLimits(_params.ADX_PriceLimitMethod, _params.ADX_PriceLimitLevel);
    sparams.SetMaxSpread(_params.ADX_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_ADX(sparams, "ADX");
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

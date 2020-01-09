//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements ADX strategy based on the Average Directional Movement Index indicator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_ADX.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __ADX_Parameters__ = "-- ADX strategy params --";  // >>> ADX <<<
INPUT int ADX_Active_Tf = 0;  // Activate timeframes (1-255, e.g. M1=1,M5=2,M15=4,M30=8,H1=16,H2=32,H4=64...)
INPUT int ADX_Period = 14;    // Averaging period
INPUT ENUM_APPLIED_PRICE ADX_Applied_Price = PRICE_HIGH;  // Applied price.
INPUT ENUM_TRAIL_TYPE ADX_TrailingStopMethod = 3;         // Trail stop method
INPUT ENUM_TRAIL_TYPE ADX_TrailingProfitMethod = 22;      // Trail profit method
INPUT int ADX_Shift = 0;                                  // Shift (relative to the current bar, 0 - default)
INPUT double ADX_SignalOpenLevel = 0.0004;                // Signal open level (>0.0001)
INPUT int ADX_SignalBaseMethod = 0;                       // Signal base method (0-1)
INPUT int ADX_SignalOpenMethod1 = 0;                      // Open condition 1 (0-1023)
INPUT int ADX_SignalOpenMethod2 = 0;                      // Open condition 2 (0-)
INPUT double ADX_SignalCloseLevel = 0.0004;               // Signal close level (>0.0001)
INPUT ENUM_MARKET_EVENT ADX_SignalCloseMethod1 = 0;       // Signal close method 1
INPUT ENUM_MARKET_EVENT ADX_SignalCloseMethod2 = 0;       // Signal close method 2
INPUT double ADX_MaxSpread = 6.0;                         // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_ADX_Params : Stg_Params {
  unsigned int ADX_Period;
  ENUM_APPLIED_PRICE ADX_Applied_Price;
  int ADX_Shift;
  ENUM_TRAIL_TYPE ADX_TrailingStopMethod;
  ENUM_TRAIL_TYPE ADX_TrailingProfitMethod;
  double ADX_SignalOpenLevel;
  long ADX_SignalBaseMethod;
  long ADX_SignalOpenMethod1;
  long ADX_SignalOpenMethod2;
  double ADX_SignalCloseLevel;
  ENUM_MARKET_EVENT ADX_SignalCloseMethod1;
  ENUM_MARKET_EVENT ADX_SignalCloseMethod2;
  double ADX_MaxSpread;

  // Constructor: Set default param values.
  Stg_ADX_Params()
      : ADX_Period(::ADX_Period),
        ADX_Applied_Price(::ADX_Applied_Price),
        ADX_Shift(::ADX_Shift),
        ADX_TrailingStopMethod(::ADX_TrailingStopMethod),
        ADX_TrailingProfitMethod(::ADX_TrailingProfitMethod),
        ADX_SignalOpenLevel(::ADX_SignalOpenLevel),
        ADX_SignalBaseMethod(::ADX_SignalBaseMethod),
        ADX_SignalOpenMethod1(::ADX_SignalOpenMethod1),
        ADX_SignalOpenMethod2(::ADX_SignalOpenMethod2),
        ADX_SignalCloseLevel(::ADX_SignalCloseLevel),
        ADX_SignalCloseMethod1(::ADX_SignalCloseMethod1),
        ADX_SignalCloseMethod2(::ADX_SignalCloseMethod2),
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
    switch (_tf) {
      case PERIOD_M1: {
        Stg_ADX_EURUSD_M1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M5: {
        Stg_ADX_EURUSD_M5_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M15: {
        Stg_ADX_EURUSD_M15_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M30: {
        Stg_ADX_EURUSD_M30_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H1: {
        Stg_ADX_EURUSD_H1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H4: {
        Stg_ADX_EURUSD_H4_Params _new_params;
        _params = _new_params;
      }
    }
    // Initialize strategy parameters.
    ChartParams cparams(_tf);
    ADX_Params adx_params(_params.ADX_Period, _params.ADX_Applied_Price);
    IndicatorParams adx_iparams(10, INDI_ADX);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_ADX(adx_params, adx_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.ADX_SignalBaseMethod, _params.ADX_SignalOpenMethod1, _params.ADX_SignalOpenMethod2,
                       _params.ADX_SignalCloseMethod1, _params.ADX_SignalCloseMethod2, _params.ADX_SignalOpenLevel,
                       _params.ADX_SignalCloseLevel);
    sparams.SetStops(_params.ADX_TrailingProfitMethod, _params.ADX_TrailingStopMethod);
    sparams.SetMaxSpread(_params.ADX_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_ADX(sparams, "ADX");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    bool _result = false;
    double adx_0_main = ((Indi_ADX *)this.Data()).GetValue(LINE_MAIN_ADX, 0);
    double adx_0_plusdi = ((Indi_ADX *)this.Data()).GetValue(LINE_PLUSDI, 0);
    double adx_0_minusdi = ((Indi_ADX *)this.Data()).GetValue(LINE_MINUSDI, 0);
    double adx_1_main = ((Indi_ADX *)this.Data()).GetValue(LINE_MAIN_ADX, 1);
    double adx_1_plusdi = ((Indi_ADX *)this.Data()).GetValue(LINE_PLUSDI, 1);
    double adx_1_minusdi = ((Indi_ADX *)this.Data()).GetValue(LINE_MINUSDI, 1);
    double adx_2_main = ((Indi_ADX *)this.Data()).GetValue(LINE_MAIN_ADX, 2);
    double adx_2_plusdi = ((Indi_ADX *)this.Data()).GetValue(LINE_PLUSDI, 2);
    double adx_2_minusdi = ((Indi_ADX *)this.Data()).GetValue(LINE_MINUSDI, 2);
    if (_signal_method == EMPTY) _signal_method = GetSignalBaseMethod();
    if (_signal_level == EMPTY) _signal_level = GetSignalOpenLevel();
    switch (_cmd) {
      // Buy: +DI line is above -DI line, ADX is more than a certain value and grows (i.e. trend strengthens).
      case ORDER_TYPE_BUY:
        _result = adx_0_minusdi < adx_0_plusdi && adx_0_main >= _signal_level;
        if (METHOD(_signal_method, 0)) _result &= adx_0_main > adx_1_main;
        if (METHOD(_signal_method, 1)) _result &= adx_1_main > adx_2_main;
        break;
      // Sell: -DI line is above +DI line, ADX is more than a certain value and grows (i.e. trend strengthens).
      case ORDER_TYPE_SELL:
        _result = adx_0_minusdi > adx_0_plusdi && adx_0_main >= _signal_level;
        if (METHOD(_signal_method, 0)) _result &= adx_0_main > adx_1_main;
        if (METHOD(_signal_method, 1)) _result &= adx_1_main > adx_2_main;
        break;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    if (_signal_level == EMPTY) _signal_level = GetSignalCloseLevel();
    return SignalOpen(Order::NegateOrderType(_cmd), _signal_method, _signal_level);
  }
};

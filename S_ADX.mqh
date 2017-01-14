//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

/**
 * @file
 * Implementation of ADX Strategy based on the Average Directional Movement Index (ADX).
 *
 * Main principle: convergence/divergence.
 *
 * @docs
 * - https://docs.mql4.com/indicators/iADX
 * - https://www.mql5.com/en/docs/indicators/iADX
 */

// Includes.
#include <EA31337-classes\Strategy.mqh>
#include <EA31337-classes\Strategies.mqh>

// User inputs.
#ifdef __input__ input #endif string __ADX_Parameters__ = "-- Settings for the Average Directional Movement Index indicator --"; // >>> ADX (NOT IMPLEMENTED YET) <<<
#ifdef __input__ input #endif int ADX_Period = 14; // Period
#ifdef __input__ input #endif int ADX_Periods = 14; // Periods per timeframes
#ifdef __input__ input #endif ENUM_APPLIED_PRICE ADX_Applied_Price = 2; // Applied price
#ifdef __input__ input #endif double ADX_SignalLevel = 0.00000000; // Signal level
#ifdef __input__ input #endif string ADX_SignalLevels = 0.00000000; // Signal levels per timeframes
#ifdef __input__ input #endif int ADX_SignalMethod = 15; // Signal method (0-?)
#ifdef __input__ input #endif string ADX_SignalMethods = ""; // Signal methods per timeframes (0-?)

class ADX: public Strategy {
protected:

  int       open_method = EMPTY;    // Open method.
  double    open_level  = 0.0;     // Open level.

    public:

  /**
   * Update indicator values.
   */
  bool Update(int tf = EMPTY) {
    // Calculates the Average Directional Movement Index indicator.
    for (i = 0; i < FINAL_ENUM_INDICATOR_INDEX; i++) {
      adx[index][i][MODE_MAIN]    = iADX(symbol, tf, ADX_Period, ADX_Applied_Price, MODE_MAIN, i);    // Base indicator line
      adx[index][i][MODE_PLUSDI]  = iADX(symbol, tf, ADX_Period, ADX_Applied_Price, MODE_PLUSDI, i);  // +DI indicator line
      adx[index][i][MODE_MINUSDI] = iADX(symbol, tf, ADX_Period, ADX_Applied_Price, MODE_MINUSDI, i); // -DI indicator line
    }
  }

  /**
   * Check if ADX indicator is on buy or sell.
   *
   * @param
   *   cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   signal_method (int) - signal method to use by using bitwise AND operation
   *   signal_level (double) - signal level to consider the signal
   */
  bool Signal(int cmd, int tf = EMPTY, int open_method = 0, open_level = 0.0) {
            bool result = FALSE;
            if (open_method == EMPTY) open_method = this->open_method; // @fixme: This means to get the value from the class.
            int period = Convert::TimeframeToPeriod(tf); // Convert.mqh

            switch (cmd) {
                case OP_BUY: // Indicator growth at downtrend.
                    bool result = @fixme; //Buy: +DI line is above -DI line, ADX is more than a certain value and grows (i.e. trend strengthens)
                    if ((open_method &   1) != 0) result = result && Open[CURR] > Close[CURR];
                    if ((open_method &   2) != 0) result = result && Trade(Convert::CmdOpp); // Check if position on sell.
                    if ((open_method &   4) != 0) result = result && Trade(MathMin(period + 1, M30)); // Check if strategy is signaled on higher period.
                    if ((open_method &   8) != 0) result = result && Trade(cmd, M30); // Check if there is signal on M30.
                    if ((open_method &  16) != 0) result = result && // condition here
                    // @todo: Add these conditions in separate bitwise conditions.
                    // (iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MINUSDI,0)<iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_PLUSDI,0)
                    // &&iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MAIN,0)>=minadx
                    // &&iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MAIN,0)>iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MAIN,1))
                    //   if(iADX(NULL,0,14,PRICE_HIGH,MODE_MAIN,0)>iADX(NULL,0,14,PRICE_HIGH,MODE_PLUSDI,0)) return(0);
                    break;
                case OP_SELL: // Indicator fall at uptrend.
                    bool result = @fixme; //Sell: -DI line is above +DI line, ADX is more than a certain value and grows (i.e. trend strengthens)
                    if ((open_method &   1) != 0) result = result && Open[CURR] < Close[CURR];
                    if ((open_method &   2) != 0) result = result && Trade(Convert::CmdOpp);
                    if ((open_method &   4) != 0) result = result && Trade(cmd, MathMin(period + 1, M30));
                    if ((open_method &   8) != 0) result = result && Trade(cmd, M30);
                    if ((open_method &  16) != 0) result = result && // condition here
                    // @todo: Add these conditions in separate bitwise conditions.
                    // (iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MINUSDI,0)>iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_PLUSDI,0)
                    // &&iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MAIN,0)>=minadx
                    // &&iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MAIN,0)>iADX(NULL,piadx,piadu,PRICE_CLOSE,MODE_MAIN,1))
                    //   if(iADX(NULL,0,14,PRICE_HIGH,MODE_MAIN,0)>iADX(NULL,0,14,PRICE_HIGH,MODE_PLUSDI,0)) return(0);
                    break;
            }

    result &= signal_method <= 0 || Convert::ValueToOp(curr_trend) == cmd;
    return result;
  }
};

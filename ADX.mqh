//+------------------------------------------------------------------+
//|                                                          ADX.mqh |
//|                            Copyright 2016, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Implementation of ADX Strategy based on ADX indicator.
//| Average Directional Movement Index - ADX
//| Docs: https://docs.mql4.com/indicators/iadx, https://www.mql5.com/en/docs/indicators/iadx
//+------------------------------------------------------------------+
class ADX: public Strategy {
    protected:
        int       open_method = EMPTY;    // Open method.
        double    open_level  = 0.0;     // Open level.

    public:
        // Update indicator values.
        bool Update(int tf = EMPTY) {
            for (i = 0; i < FINAL_INDICATOR_INDEX_ENTRY; i++) {
                // @fixme: We need to find some way to support 2-dim and 3-dim arrays, depending on the indicator. Maybe as separate data2 & data3 arrays?
                // Or we can define unknown array size and change it on constructor and we could define dimension using ArrayResize/ArraySize/ArrayRange
                data[period][i][MODE_MAIN]    = iADX(_Symbol, tf, ADX_Period, ADX_Applied_Price, MODE_MAIN, i);    // Base indicator line
                data[period][i][MODE_PLUSDI]  = iADX(_Symbol, tf, ADX_Period, ADX_Applied_Price, MODE_PLUSDI, i);  // +DI indicator line
                data[period][i][MODE_MINUSDI] = iADX(_Symbol, tf, ADX_Period, ADX_Applied_Price, MODE_MINUSDI, i); // -DI indicator line
            }
        }
        bool Trade(int cmd, int tf = EMPTY, int open_method = 0, open_level = 0.0) {
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

            return result;
        }
};

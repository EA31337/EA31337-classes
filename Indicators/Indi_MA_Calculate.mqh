//+------------------------------------------------------------------+
//|   simple moving average                                          |
//+------------------------------------------------------------------+
void CalculateSimpleMA(int rates_total,int prev_calculated,int begin,const double &price[], double &ExtLineBuffer[], int InpMAPeriod)
  {
   int i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)// first calculation
     {
      limit=InpMAPeriod+begin;
      //--- set empty value for first limit bars
      for(i=0;i<limit-1;i++) ExtLineBuffer[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++)
         firstValue+=price[i];
      firstValue/=InpMAPeriod;
      ExtLineBuffer[limit-1]=firstValue;
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
      ExtLineBuffer[i]=ExtLineBuffer[i-1]+(price[i]-price[i-InpMAPeriod])/InpMAPeriod;
//---
  }
//+------------------------------------------------------------------+
//|  exponential moving average                                      |
//+------------------------------------------------------------------+
void CalculateEMA(int rates_total,int prev_calculated,int begin,const double &price[], double &ExtLineBuffer[], int InpMAPeriod)
  {
   int    i,limit;
   double SmoothFactor=2.0/(1.0+InpMAPeriod);
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=InpMAPeriod+begin;
      ExtLineBuffer[begin]=price[begin];
      for(i=begin+1;i<limit;i++)
         ExtLineBuffer[i]=price[i]*SmoothFactor+ExtLineBuffer[i-1]*(1.0-SmoothFactor);
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
      ExtLineBuffer[i]=price[i]*SmoothFactor+ExtLineBuffer[i-1]*(1.0-SmoothFactor);
//---
  }
//+------------------------------------------------------------------+
//|  linear weighted moving average                                  |
//+------------------------------------------------------------------+
void CalculateLWMA(int rates_total,int prev_calculated,int begin,const double &price[], double &ExtLineBuffer[], int InpMAPeriod)
  {
   int        i,limit;
   static int weightsum;
   double     sum;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      weightsum=0;
      limit=InpMAPeriod+begin;
      //--- set empty value for first limit bars
      for(i=0;i<limit;i++) ExtLineBuffer[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++)
        {
         int k=i-begin+1;
         weightsum+=k;
         firstValue+=k*price[i];
        }
      firstValue/=(double)weightsum;
      ExtLineBuffer[limit-1]=firstValue;
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      sum=0;
      for(int j=0;j<InpMAPeriod;j++) sum+=(InpMAPeriod-j)*price[i-j];
      ExtLineBuffer[i]=sum/weightsum;
     }
//---
  }
//+------------------------------------------------------------------+
//|  smoothed moving average                                         |
//+------------------------------------------------------------------+
void CalculateSmoothedMA(int rates_total,int prev_calculated,int begin,const double &price[], double &ExtLineBuffer[], int InpMAPeriod)
  {
   int i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=InpMAPeriod+begin;
      //--- set empty value for first limit bars
      for(i=0;i<limit-1;i++) ExtLineBuffer[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++)
         firstValue+=price[i];
      firstValue/=InpMAPeriod;
      ExtLineBuffer[limit-1]=firstValue;
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
      ExtLineBuffer[i]=(ExtLineBuffer[i-1]*(InpMAPeriod-1)+price[i])/InpMAPeriod;
//---
  }

//+------------------------------------------------------------------+
//|  Moving Average                                                  |
//+------------------------------------------------------------------+
int MA_OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[],
                double &ExtLineBuffer[],
                int InpMAMethod,
                int InpMAPeriod)
  {
//--- check for bars count
   if(rates_total<InpMAPeriod-1+begin)
      return(0);// not enough bars for calculation
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
      ArrayInitialize(ExtLineBuffer,0);

//--- calculation
   switch(InpMAMethod)
     {
      case MODE_EMA:  CalculateEMA(rates_total,prev_calculated,begin,price, ExtLineBuffer, InpMAPeriod);        break;
      case MODE_LWMA: CalculateLWMA(rates_total,prev_calculated,begin,price, ExtLineBuffer, InpMAPeriod);       break;
      case MODE_SMMA: CalculateSmoothedMA(rates_total,prev_calculated,begin,price, ExtLineBuffer, InpMAPeriod); break;
      case MODE_SMA:  CalculateSimpleMA(rates_total,prev_calculated,begin,price, ExtLineBuffer, InpMAPeriod);   break;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

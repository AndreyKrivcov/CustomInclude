//+------------------------------------------------------------------+
//|                                              CustomComission.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| Класс - хранитель комиссий и проскальзываний                     |
//+------------------------------------------------------------------+
class CCCM
  {
private:
   struct Keeper // Структура описывающая комиссию и проскальзывание для конкретного символа
     {
      string            symbol;
      double            comission;
      double            shift;
     };

   Keeper            comission_data[]; // Массив структур с комиссиями и проскальзываниями
public:

   void              add(string symbol,double comission,double shift); // Добавление нового стмвола

   double            get(string symbol,double price,double volume); // Получение суммарного результата комиссии и проскальзывания в деньгах
   void              remove(string symbol); // Удаление переданного символа
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Добавление нового символа                                        |
//+------------------------------------------------------------------+
void CCCM::add(string symbol,double comission,double shift)
  {
   int s=ArraySize(comission_data);

   for(int i=0; i<s; i++)
     {
      if(comission_data[i].symbol==symbol)
         return;
     }

   ArrayResize(comission_data,s+1,s+1);

   Keeper keeper;
   keeper.symbol=symbol;
   keeper.comission=MathAbs(comission);
   keeper.shift=MathAbs(shift);

   comission_data[s]=keeper;
  }
//+------------------------------------------------------------------+
//| Удаление переданного символа                                     |
//+------------------------------------------------------------------+
void CCCM::remove(string symbol)
  {
   int total=ArraySize(comission_data);
   int ind=-1;
   for(int i=0; i<total; i++)
     {
      if(comission_data[i].symbol==symbol)
        {
         ind=i;
         break;
        }
     }

   if(ind!=-1)
      ArrayRemove(comission_data,ind,1);
  }
//+------------------------------------------------------------------+
//| Получение запрашиваемого символа                                 |
//+------------------------------------------------------------------+
double CCCM::get(string symbol,double price,double volume)
  {

   int total=ArraySize(comission_data);
   for(int i=0; i<total; i++)
     {
      if(comission_data[i].symbol==symbol)
        {
         // Узнаем тип рассчетов по символу
         ENUM_SYMBOL_CALC_MODE mode=(ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE);

         // Получаем значение сдвига в деньгах
         double shift=comission_data[i].shift*SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);

         double ans;
         // в зависимости от типа рассчетов подсчитываем комиссию
         switch(mode)
           {
            case SYMBOL_CALC_MODE_FOREX :
               ans=(comission_data[i].comission+shift)*volume;
               break;
            case SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE :
               ans=(comission_data[i].comission+shift)*volume;
               break;
            case SYMBOL_CALC_MODE_FUTURES :
               ans=(comission_data[i].comission+shift)*volume;
               break;
            case SYMBOL_CALC_MODE_CFD :
               ans=(comission_data[i].comission+shift)*volume;
               break;
            case SYMBOL_CALC_MODE_CFDINDEX :
               ans=(comission_data[i].comission+shift)*volume;
               break;
            case SYMBOL_CALC_MODE_CFDLEVERAGE :
               ans=(comission_data[i].comission+shift)*volume;
               break;
            case SYMBOL_CALC_MODE_EXCH_STOCKS :
              {
               double trading_volume=price*volume*SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);
               ans=trading_volume*comission_data[i].comission/100+shift*volume;
              }
            break;
            case SYMBOL_CALC_MODE_EXCH_FUTURES :
               ans=(comission_data[i].comission+shift)*volume;
               break;
            case SYMBOL_CALC_MODE_EXCH_FUTURES_FORTS :
               ans=(comission_data[i].comission+shift)*volume;
               break;
            case SYMBOL_CALC_MODE_EXCH_BONDS :
              {
               double trading_volume=price*volume*SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);
               ans=trading_volume*comission_data[i].comission/100+shift*volume;
              }
            break;
            case SYMBOL_CALC_MODE_EXCH_STOCKS_MOEX :
              {
               double trading_volume=price*volume*SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);
               ans=trading_volume*comission_data[i].comission/100+shift*volume;
              }
            break;
            case SYMBOL_CALC_MODE_EXCH_BONDS_MOEX :
              {
               double trading_volume=price*volume*SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE);
               ans=trading_volume*comission_data[i].comission/100+shift*volume;
              }
            break;
            case SYMBOL_CALC_MODE_SERV_COLLATERAL :
               ans=(comission_data[i].comission+shift)*volume;
               break;
            default:
               ans=0;
               break;
           }

         if(ans!=0)
            return -ans;

        }
     }

   return 0;
  }
//+------------------------------------------------------------------+

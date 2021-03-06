//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "CustomComissionManager.mqh"
//+------------------------------------------------------------------+
//| Структура данных одной выбранной сделки                          |
//+------------------------------------------------------------------+
struct DealData
  {
   long              ticket;        // Тикет сделки
   long              order;         // Номер ордера открывшего сделку
   datetime          DT;            // Дата открытия позиции
   long              DT_msc;        // Дата открытия позиции в милисекундах
   ENUM_DEAL_TYPE    type;          // Тип открытой позиции
   ENUM_DEAL_ENTRY   entry;         // Тип входа в позицию
   long              magic;         // Уникальный номер позиции
   ENUM_DEAL_REASON  reason;        // От куда был выставлен ордер
   long              ID;            // ID позиции
   double            volume;        // Объем позиции (лоты)
   double            price;         // Цена входа в позицию
   double            comission;     // Комиссия уплаченая
   double            swap;          // Своп
   double            profit;        // Прибыль / убыток
   string            symbol;        // Символ
   string            comment;       // Комментарий указанный во время открытия
   string            ID_external;   // Внешний ID
  };
//+------------------------------------------------------------------+
//| Структура хранящая в себе все сделки по определенной позиции     |
//| которая была выбрана по ID                                       |
//+------------------------------------------------------------------+
struct DealKeeper
  {
   DealData          deals[]; /* Список всех сделок для данноы позиции
                              (или же нескольких позиций в случае если имел место быть переворот сделки)*/
   string            symbol;  // Символ
   long              ID;      // ID данной позиции (позициЙ)
   datetime          DT_min;  // дата открытия (или же дата самой первой позиции)
   datetime          DT_max;  // дата закрытия
  };
//+------------------------------------------------------------------+
//| Структура хрящящая в себе ID позиции и символ данной позиции     |
//+------------------------------------------------------------------+
struct ID_struct
  {
   string            Symb;
   long              ID;
  };
//+------------------------------------------------------------------+
//| Структура хранящая в себе весь финансовый результат и            |
//| основную информацию по выбранной позиции.                        |
//+------------------------------------------------------------------+
struct DealDetales
  {
   string            symbol;        // символ
   datetime          DT_open;       // Дата открытия
   ENUM_DAY_OF_WEEK  day_open;      // День открытия
   datetime          DT_close;      // Дата закрытия
   ENUM_DAY_OF_WEEK  day_close;     // День закрытия
   double            volume;        // Объем (лоты)
   bool              isLong;        // признак Лонт / шорт
   double            price_in;      // Цена входа в позицию
   double            price_out;     // Цена вызода из позиции
   double            pl_oneLot;     // прибыль / убыток если бы торговали одним лотом
   double            pl_forDeal;    // прибыль / убыток который реально был с учетом комиссии
   string            open_comment;  // Комментарий на момент открытия
   string            close_comment; // Комментарий на момент закрытия
  };
//+------------------------------------------------------------------+
//| Вспомогательное перечисление указывающее на тип конкретной записи|
//| Сама запись представлена структурой DealData                     |
//+------------------------------------------------------------------+
enum BorderPointType
  {
   UsualInput,    // Обычный тип входа (DEAL_ENTRY_IN) - Начало трейда
   UsualOut,      // Обычный тип выхода (DEAL_ENTRY_OUT) - Завершение трейда
   OtherPoint,    // Начисление баланса, корректировки позиции, выводы, вариационная маржа... всё это игнорируем
   InOut,         // Переворот позиции (DEAL_ENTRY_INOUT)
   OutBy          // Выход из позиции по встречному ордеру (DEAL_ENTRY_OUT_BY)
  };
//+------------------------------------------------------------------+
//| Вспомогательное перечисление, помогает расчитывать объем позиции |
//| исходя из массива DealData                                       |
//+------------------------------------------------------------------+
enum GetContractType
  {
   GET_REAL_CONTRACT,// Получение данных по максимально открытому контракту
   GET_LAST_CONTRACT // Получение данных по последнему контракту, что был в рынке перед тем как позиция закрылась
  };
//+------------------------------------------------------------------+
//| Класс достающий историю торгов из Mt5 и преобрпзующий ее в       |
//| удобный для анализа вид                                          |
//+------------------------------------------------------------------+
class CDealHistoryGetter
  {
public:
                     CDealHistoryGetter(CCCM *_comission_manager) : comission_manager(_comission_manager)
     {}
   bool              getHistory(DealKeeper &deals[],datetime from,datetime till);     // возвращает все данные по историческим сделкам
   bool              getIDArr(ID_struct &ID_arr[],datetime from,datetime till);       // возвращает уникальный массив ID сделок
   bool              getDealsDetales(DealDetales &ans[],datetime from,datetime till); // возвращает массив сделок где каждая строка - одна конкретная сделка
   double            getBalance(datetime toDate);
   double            getBalanceWithPL(datetime toDate);
private:
   CCCM              *comission_manager;

   void              addArray(ID_struct &Arr[],const ID_struct &value);    // добавить в динамический массив
   void              addArray(DealKeeper &Arr[],const DealKeeper &value);  // добавить в динамический массив
   void              addArray(DealData &Arr[],const DealData &value);      // добавить в динамический массив
   void              addArr(DealDetales &Arr[],DealDetales &value);        // добавить в динамический массив
   void              addArr(double &Arr[],double value);                   // добавить в динамический массив

   /*
       Если есть выходы по InOut, то в inputParam будет более чем одна позиция.
       Если нет выходов по InOut, то в inputParam будет только одна сделка !
   */
   void              getDeals_forSelectedKeeper(DealKeeper &inputParam,DealDetales &ans[]); // Формируется единая запись по одной выбранной позиции для всех позиций что есть в inputParam
   double            MA_price(double &prices[],double &lots[]);// Подсчитывается средневзвешенная цена открытия
   bool              isBorderPoint(DealData &data,BorderPointType &type);// Получаем информацию - пограничная ли это точка и какой именно тип точки
   ENUM_DAY_OF_WEEK  getDay(datetime DT);// Получаем день из даты
   double            calcContracts(double &Arr[],GetContractType type); // Рассчитываем какой объем позиции был на самом деле, и получаем информацию об объеме самой последней позиции

   void              inputDeals_calc(DealDetales &detales,
                                     const DealKeeper &inputParam,
                                     const int i,
                                     double &price_In[],
                                     double &lot_In[],
                                     double &pl_total,
                                     bool &firstPL_setted,
                                     double &contracts[]); //Обработка открытий позиций

   void              outputDeals_calc(bool &isAdd,
                                      DealDetales &detales,
                                      const DealKeeper &inputParam,
                                      const int i,
                                      double &price_Out[],
                                      double &lot_Out[],
                                      double &pl_total,
                                      const int total,
                                      double &contracts[]); // Обработка закрытий позиций

   void              reverceDeals_calc(bool &firstPL_setted,
                                       double &contracts[],
                                       const DealKeeper &inputParam,
                                       const int i,
                                       DealDetales &detales,
                                       double &price_Out[],
                                       double &lot_Out[],
                                       double &price_In[],
                                       double &lot_In[],
                                       double &pl_total,
                                       DealDetales &ans[],
                                       bool &isAdd); // Обработка перевоторов

   void              concanateString(string &dist,string s,string delemetr); // Соединение строк
  };
//+------------------------------------------------------------------+
//| возвращает значение баланса на выбранную дату                    |
//+------------------------------------------------------------------+
double CDealHistoryGetter::getBalanceWithPL(datetime toDate)
  {
   if(HistorySelect(0,(toDate>0 ? toDate : TimeCurrent())))
     {
      int total=HistoryDealsTotal(); // Получаем общее количество позиций
      double balance=0;
      bool wasBalance=false;
      for(int i=0; i<total; i++)
        {
         long ticket=(long)HistoryDealGetTicket(i);
         if(wasBalance)
           {
            if(HistoryDealGetInteger(ticket,DEAL_TIME)<=toDate)
              {
#ifndef ONLY_CUSTOM_COMISSION
               if(comission_manager!=NULL)
                 {
#endif
                  balance+=HistoryDealGetDouble(ticket,DEAL_PROFIT)+
                           comission_manager.get(HistoryDealGetString(ticket,DEAL_SYMBOL),
                                                 HistoryDealGetDouble(ticket,DEAL_PRICE),
                                                 HistoryDealGetDouble(ticket,DEAL_VOLUME));
#ifndef ONLY_CUSTOM_COMISSION
                 }
               else
                  balance+=HistoryDealGetDouble(ticket,DEAL_PROFIT);
#endif
              }
            else
               break;
           }
         else
            if(HistoryDealGetInteger(ticket,DEAL_TYPE)==DEAL_TYPE_BALANCE)
              {
               wasBalance=true;
               balance=HistoryDealGetDouble(ticket,DEAL_PROFIT);
               if(toDate<=0)
                  break;
              }
        }
      return balance;
     }
   else
      return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CDealHistoryGetter::getBalance(datetime toDate)
  {
   if(HistorySelect(0,(toDate>0 ? toDate : TimeCurrent())))
     {
      int total=HistoryDealsTotal(); // Получаем общее количество позиций
      double balance=0;
      for(int i=0; i<total; i++)
        {
         long ticket=(long)HistoryDealGetTicket(i);

         ENUM_DEAL_TYPE dealType=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);
         if(dealType==DEAL_TYPE_BALANCE ||
            dealType == DEAL_TYPE_CORRECTION ||
            dealType == DEAL_TYPE_COMMISSION)
           {
            balance+=HistoryDealGetDouble(ticket,DEAL_PROFIT);

            if(toDate<=0)
               break;
           }
        }
      return balance;
     }
   else
      return 0;
  }
//+------------------------------------------------------------------+
//| возвращает уникальный массив ID сделок                           |
//+------------------------------------------------------------------+
bool CDealHistoryGetter::getIDArr(ID_struct &ID_arr[],datetime from,datetime till)
  {
   ArrayFree(ID_arr); // Очищаем массив, куда после возвращаем данные

   if(HistorySelect(from,till)) // Выбор истории за определенный интервал времени
     {
      int total=HistoryDealsTotal(); // Получаем общее количество позиций
      for(int i=0; i<total; i++)
        {
         long ticket=(long)HistoryDealGetTicket(i);

         // Формируем ID_struct
         ID_struct S;
         S.ID=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
         S.Symb=HistoryDealGetString(ticket,DEAL_SYMBOL);

         // Проверяем ID_struct на уникальность
         int total_2=ArraySize(ID_arr);
         bool add_ByID=true;
         for(int n=0; n<total_2; n++)
           {
            if(S.ID==ID_arr[n].ID)
              {
               add_ByID=false;
               break;
              }
           }
         if(add_ByID && S.ID>0)
            addArray(ID_arr,S); // Добавляем в массив новое уникальное значение
        }

      return ArraySize(ID_arr) > 0;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
//| Добавить в динамический массив                                   |
//+------------------------------------------------------------------+
void CDealHistoryGetter::addArray(ID_struct &Arr[],const ID_struct &value)
  {
   int s=ArraySize(Arr);      // Получаем размерность
   ArrayResize(Arr,s+1,s+1);  // Увеличиваем размер с сохранением ранее записанного
   Arr[s]=value;              // Добавляем новое значение
  }
//+------------------------------------------------------------------+
//| Добавить в динамический массив                                   |
//+------------------------------------------------------------------+
void CDealHistoryGetter::addArray(DealKeeper &Arr[],const DealKeeper &value)
  {
   int s=ArraySize(Arr);
   ArrayResize(Arr,s+1,s+1);
   Arr[s]=value;
  }
//+------------------------------------------------------------------+
//| Добавить в динамический массив                                   |
//+------------------------------------------------------------------+
void CDealHistoryGetter::addArray(DealData &Arr[],const DealData &value)
  {
   int s=ArraySize(Arr);
   ArrayResize(Arr,s+1,s+1);
   Arr[s]=value;
  }
//+------------------------------------------------------------------+
//| возвращает все данные по историческим сделкам                    |
//+------------------------------------------------------------------+
bool CDealHistoryGetter::getHistory(DealKeeper &deals[],datetime from,datetime till)
  {
   ArrayFree(deals);                // Очищаем массив в результатами
   ID_struct ID_arr[];
   if(getIDArr(ID_arr,from,till)) // Получаем уникальные ID
     {
      int total=ArraySize(ID_arr);
      for(int i=0; i<total; i++) // Цикл по ID
        {
         DealKeeper keeper;         // Накопитель сделок по позиции
         keeper.ID=ID_arr[i].ID;
         keeper.symbol=ID_arr[i].Symb;
         keeper.DT_max = LONG_MIN;
         keeper.DT_min = LONG_MAX;
         if(HistorySelectByPosition(ID_arr[i].ID)) // Выбираем все сделки с заданным ID
           {

            int total_2=HistoryDealsTotal();
            for(int n=0; n<total_2; n++) // Цикл по выбранным сделкам
              {
               long ticket=(long)HistoryDealGetTicket(n);
               DealData data;
               data.ID=keeper.ID;
               data.symbol=keeper.symbol;
               data.ticket= ticket;

               data.DT=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
               keeper.DT_max=MathMax(keeper.DT_max,data.DT);
               keeper.DT_min=MathMin(keeper.DT_min,data.DT);
               data.order= HistoryDealGetInteger(ticket,DEAL_ORDER);
               data.type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);
               data.DT_msc=HistoryDealGetInteger(ticket,DEAL_TIME_MSC);
               data.entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
               data.magic = HistoryDealGetInteger(ticket,DEAL_MAGIC);
               data.reason= (ENUM_DEAL_REASON)HistoryDealGetInteger(ticket,DEAL_REASON);
               data.volume= HistoryDealGetDouble(ticket,DEAL_VOLUME);
               data.price = HistoryDealGetDouble(ticket,DEAL_PRICE);
               data.swap=HistoryDealGetDouble(ticket,DEAL_SWAP);
               data.profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
               data.comment=HistoryDealGetString(ticket,DEAL_COMMENT);
               data.ID_external=HistoryDealGetString(ticket,DEAL_EXTERNAL_ID);
               data.comission=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
#ifndef ONLY_CUSTOM_COMISSION
               if(data.comission==0 && comission_manager != NULL)
                 {
                  data.comission=comission_manager.get(data.symbol,data.price,data.volume);
                 }
#else
               data.comission=comission_manager.get(data.symbol,data.price,data.volume);
#endif

               addArray(keeper.deals,data); // Добавляем сделки
              }

            if(ArraySize(keeper.deals)>0)
               addArray(deals,keeper); // Добавляем позицию
           }
        }
      return ArraySize(deals) > 0;
     }
   else
      return false; // Если нет уникальных ID
  }
//+------------------------------------------------------------------+
//| Подсчитывается средневзвешенная цена открытия                    |
//+------------------------------------------------------------------+
double CDealHistoryGetter::MA_price(double &prices[],double &lots[])
  {
   double summ=0;          // Сумма взвешенных цен
   double delemetr=0;      // Сумма весов
   int total=ArraySize(prices);
   for(int i=0; i<total; i++) // Цикл суммирования
     {
      summ+=(prices[i]*lots[i]);
      delemetr+=lots[i];
     }
   return summ/delemetr;   // Расчет средней
  }
//+-----------------------------------------------------------------------+
//| Получаем информацию пограничная ли это точка и какой именно тип точки |
//+-----------------------------------------------------------------------+
bool CDealHistoryGetter::isBorderPoint(DealData &data,BorderPointType &type)
  {
   /*
      Фильтр типов исследуемой сделки. Фильтруется по следующим показателям:
      ENUM_DEAL_ENTRY - вход, выход, переворот
      ENUM_DEAL_TYPE - покупка / продажа
      ENUM_DEAL_REASON - через что было выставлено поручение
   */
   if(data.entry==DEAL_ENTRY_IN &&
      (data.type==DEAL_TYPE_BUY || data.type==DEAL_TYPE_SELL) &&
      (data.reason==DEAL_REASON_CLIENT || data.reason==DEAL_REASON_EXPERT ||
       data.reason==DEAL_REASON_WEB || data.reason==DEAL_REASON_MOBILE))
     {
      /*
            Определяется простая точка входа, т.е. обычная сделка на покупку или продажу, если до ее совершения
            на счете не было активных позиций по выбранному символу
            Либо наращивание имеющейся позиции
      */
      type=UsualInput;
      return true;
     }
   else
      if(data.entry==DEAL_ENTRY_OUT &&
         (data.type==DEAL_TYPE_BUY || data.type==DEAL_TYPE_SELL) &&
         (data.reason==DEAL_REASON_CLIENT || data.reason==DEAL_REASON_EXPERT ||
          data.reason==DEAL_REASON_WEB || data.reason==DEAL_REASON_MOBILE ||
          data.reason == DEAL_REASON_SL || data.reason == DEAL_REASON_TP ||
          data.reason == DEAL_REASON_SO))
        {
         /*
               Определяется простая точка выхода, т.е. обычная сделка на покупку или продажу, если до ее совершения
               на счете уже была активная позиция по выбранному символу и текущая сделка, просто закрыла существующую.
         */
         type=UsualOut;
         return true;
        }
      else
         if(data.entry==DEAL_ENTRY_INOUT &&
            (data.type==DEAL_TYPE_BUY || data.type==DEAL_TYPE_SELL) &&
            (data.reason==DEAL_REASON_CLIENT || data.reason==DEAL_REASON_EXPERT ||
             data.reason==DEAL_REASON_WEB || data.reason==DEAL_REASON_MOBILE))
           {
            /*
                  Определяется переворот позиции, т.е. сделка на покупку или продажу, если до ее совершения
                  на счетеуже была активная позиция по выбранному символу и текущая сделка, закрыла предшествующую позицию и открыла новую,
                  в новом направлении
            */
            type=InOut;
            return true;
           }
         else
            if(data.entry==DEAL_ENTRY_OUT_BY &&
               (data.type==DEAL_TYPE_BUY || data.type==DEAL_TYPE_SELL) &&
               (data.reason==DEAL_REASON_CLIENT || data.reason==DEAL_REASON_EXPERT ||
                data.reason==DEAL_REASON_WEB || data.reason==DEAL_REASON_MOBILE))
              {
               /*
                     По сути иной вариант UsualOutput
               */
               type=OutBy;
               return true;
              }
            else
              {
               /*
                     Все сделки которые в итоге не приводят к открытию новой, наращиванию или же сокрыщению позиции.
               */
               type=OtherPoint;
               return false;
              }
  }
//+------------------------------------------------------------------+
//| Получаем день из даты                                            |
//+------------------------------------------------------------------+
ENUM_DAY_OF_WEEK CDealHistoryGetter::getDay(datetime DT)
  {
   MqlDateTime _DT;
   TimeToStruct(DT,_DT);
   return (ENUM_DAY_OF_WEEK)_DT.day_of_week;
  }
//+------------------------------------------------------------------+
//| Добавить в динамический массив                                   |
//+------------------------------------------------------------------+
void CDealHistoryGetter::addArr(DealDetales &Arr[],DealDetales &value)
  {
   int s=ArraySize(Arr);
   ArrayResize(Arr,s+1,s+1);
   Arr[s]=value;
  }
//+------------------------------------------------------------------+
//| Добавить в динамический массив                                   |
//+------------------------------------------------------------------+
void CDealHistoryGetter::addArr(double &Arr[],double value)
  {
   int s=ArraySize(Arr);
   ArrayResize(Arr,s+1,s+1);
   Arr[s]=value;
  }
//+------------------------------------------------------------------+
//| Рассчитываем какой объем позиции был на самом деле,              |
//| и получаем информацию об объеме самой последней позиции          |
//+------------------------------------------------------------------+
double CDealHistoryGetter::calcContracts(double &Arr[],GetContractType type)
  {
   int total;

   if((total=ArraySize(Arr))>1) // Если размер массива более одного
     {
      double lotArr[];
      addArr(lotArr,Arr[0]);     // Добавляем в массив лотов, первый лот
      for(int i=1; i<total; i++) // Цикл со втолого элемента массива
         addArr(lotArr,(lotArr[i-1]+Arr[i])); // Добавляем сумму прошлого и текущего лотов в массив (lotArr[i-1]+Arr[i]))

      if(type==GET_REAL_CONTRACT)
         return lotArr[ArrayMaximum(lotArr)];   // Возвращаем максимально реально торговавнийся лот
      else
         return MathAbs(lotArr[ArraySize(lotArr)-1]!=0 ? lotArr[ArraySize(lotArr)-1]: Arr[ArraySize(Arr)-1]);    // Возвращяем самый последний торговавнийся лот
     }
   else
      return Arr[0];
  }
//+------------------------------------------------------------------+
//| Соединение строк                                                 |
//+------------------------------------------------------------------+
void CDealHistoryGetter::concanateString(string &dist,string s,string delemetr)
  {
   if(StringCompare(s,"")!=0 && s!=NULL)
     {
      if(StringCompare(dist,"")!=0 && dist!=NULL)
         dist+=delemetr+s;
      else
         dist=s;
     }
  }
//+------------------------------------------------------------------+
//| Обработка входов в позицию                                       |
//+------------------------------------------------------------------+
void  CDealHistoryGetter::inputDeals_calc(DealDetales &detales,
      const DealKeeper &inputParam,
      const int i,
      double &price_In[],
      double &lot_In[],
      double &pl_total,
      bool &firstPL_setted,
      double &contracts[])
  {
   if(detales.DT_open==0) // Присваиваем дату открытия позиции
     {
      detales.DT_open=inputParam.deals[i].DT;
      detales.day_open=getDay(inputParam.deals[i].DT);
     }
   detales.isLong=inputParam.deals[i].type==DEAL_TYPE_BUY; // Определяем направление позиции
   addArr(price_In,inputParam.deals[i].price);  // Сохраняем цену входа
   addArr(lot_In,inputParam.deals[i].volume);   // Сохраняем кол - во лотов

   pl_total=(inputParam.deals[i].profit+inputParam.deals[i].comission);
   detales.pl_forDeal+=pl_total; // Прибыль / убыток от сделки с учетом комиссии
   if(!firstPL_setted)
     {
      detales.pl_oneLot=pl_total/inputParam.deals[i].volume; //  Прибыль / убыток от сделки с учетом комиссии если торговать одним лотом
      firstPL_setted=true;
     }
   else
      detales.pl_oneLot=inputParam.deals[i].profit/calcContracts(contracts,GET_LAST_CONTRACT); //  Прибыль / убыток от сделки с учетом комиссии если торговать одним лотом

   concanateString(detales.open_comment,inputParam.deals[i].comment," | ");
   addArr(contracts,inputParam.deals[i].volume); // Добавляем объем сделки со знаком "+"
  }
//+------------------------------------------------------------------+
//| Обработка выходов из позиции                                     |
//+------------------------------------------------------------------+
void CDealHistoryGetter::outputDeals_calc(bool &isAdd,
      DealDetales &detales,
      const DealKeeper &inputParam,
      const int i,
      double &price_Out[],
      double &lot_Out[],
      double &pl_total,
      const int total,
      double &contracts[])
  {
   /*
              Не сохраняем сразу, так как входов может быть несколько (они могут идти постепенно один за другим)
              По этому во избежание потери части даннх просто устанавливаем флаг включенным
   */
   if(!isAdd)
      isAdd=true; // флаг на сохранение позиции

   detales.DT_close=inputParam.deals[i].DT;           // Дата закрытия
   detales.day_close=getDay(inputParam.deals[i].DT);  // День закрытия
   addArr(price_Out,inputParam.deals[i].price);       // Сохраняем цены выхода
   addArr(lot_Out,inputParam.deals[i].volume);        // Сохраняем объем выхода

   pl_total=(inputParam.deals[i].profit+inputParam.deals[i].comission);// Прибыль / убыток от сделки с учетом комиссии
   detales.pl_forDeal+=pl_total;

   if(i==total-1)
      detales.pl_oneLot+=pl_total/calcContracts(contracts,GET_LAST_CONTRACT); //  Прибыль / убыток от сделки с учетом комиссии если торговать одним лотом
   else
      detales.pl_oneLot+=inputParam.deals[i].profit/calcContracts(contracts,GET_LAST_CONTRACT); //  Прибыль / убыток от сделки с учетом комиссии если торговать одним лотом

   concanateString(detales.close_comment,inputParam.deals[i].comment," | ");
   addArr(contracts,-inputParam.deals[i].volume); // Добавляем объем сделки со знаком "-"
  }
//+------------------------------------------------------------------+
//| Обработка переворотов                                            |
//+------------------------------------------------------------------+
void CDealHistoryGetter::reverceDeals_calc(bool &firstPL_setted,
      double &contracts[],
      const DealKeeper &inputParam,
      const int i,
      DealDetales &detales,
      double &price_Out[],
      double &lot_Out[],
      double &price_In[],
      double &lot_In[],
      double &pl_total,
      DealDetales &ans[],
      bool &isAdd)
  {
   /*
              Часть 1:
              Сохраняем предыдущую позицию
   */
   firstPL_setted=true;
   double closingContract=calcContracts(contracts,GET_LAST_CONTRACT); // закрываемый контракт
   double myLot=inputParam.deals[i].volume-closingContract; // открываемый контракт

   addArr(contracts,-closingContract); // Добавляем объем сделки со знаком "-"
   detales.volume=calcContracts(contracts,GET_REAL_CONTRACT); // Получаем максимальный реально существовавший объем сделки

   detales.DT_close=inputParam.deals[i].DT; // Дата закрытия
   detales.day_close=getDay(inputParam.deals[i].DT); // День закрытия
   addArr(price_Out,inputParam.deals[i].price); // Цена выхода
   addArr(lot_Out,closingContract); // Объем выхода

   pl_total=(inputParam.deals[i].profit*closingContract)/inputParam.deals[i].volume; // Высчитываем PL за сделку закрытия
   double commission_total=(inputParam.deals[i].comission*closingContract)/inputParam.deals[i].volume;
   detales.pl_forDeal+=(pl_total+commission_total);
   detales.pl_oneLot+=(pl_total+commission_total)/closingContract;// Прибыль / убыток от сделки с учетом комиссии если торговать одним лотом

   concanateString(detales.close_comment,inputParam.deals[i].comment," | ");

   detales.price_in=MA_price(price_In,lot_In); // Получаем цены входа в позицию (усредненную)
   detales.price_out=MA_price(price_Out,lot_Out); // Получаем цены выхода из позиции (усредненную)
   addArr(ans,detales); // Добавляем сформированую позицию
   if(isAdd)
      isAdd=false; // Зануляем флаг если тот был вклюен

// Чистка части данных
   ArrayFree(price_In);
   ArrayFree(price_Out);
   ArrayFree(lot_In);
   ArrayFree(lot_Out);
   ArrayFree(contracts);
   detales.close_comment="";
   detales.open_comment="";
   detales.volume=0;

   concanateString(detales.open_comment,inputParam.deals[i].comment," | ");
   /*
              Часть 2:
              Сохраняем новую позицию предварительно отчистив часть данных из массива detales
   */

   addArr(contracts,myLot); // Добавляем лот открытия позиции

   pl_total=((inputParam.deals[i].profit+inputParam.deals[i].comission)*myLot)/inputParam.deals[i].volume; // Прибыль / убыток от сделки с учетом комиссии
   detales.pl_forDeal=pl_total;
   detales.pl_oneLot=pl_total/myLot; //Прибыль / убыток от сделки с учетом комиссии если торговать одним лотом
   addArr(lot_In,myLot); // Добавляемлот входа

   detales.open_comment=inputParam.deals[i].comment; // Созраняем комметарий

   detales.DT_open=inputParam.deals[i].DT; // Сохранем дату открытия
   detales.day_open=getDay(inputParam.deals[i].DT); // Сохраняем день открытия
   detales.isLong=inputParam.deals[i].type==DEAL_TYPE_BUY; // Определяем направление сделки
   addArr(price_In,inputParam.deals[i].price); // Сохраняем цену входа
  }
//+------------------------------------------------------------------+
//| Формируется единая запись по одной выбранной позиции             |
//| для всех позиций что есть в inputParam                           |
//+------------------------------------------------------------------+
void CDealHistoryGetter::getDeals_forSelectedKeeper(DealKeeper &inputParam,DealDetales &ans[])
  {
   ArrayFree(ans);
   int total=ArraySize(inputParam.deals);
   DealDetales detales; // Переменная куда складываются результаты из последующего цикла
   ZeroMemory(detales);
   detales.symbol=inputParam.symbol;
   detales.open_comment="";
   detales.close_comment="";

// Флаг нужно ли добавлять данную позицию в набор
   bool isAdd=false;
   bool firstPL_setted=false;
// Массивы цен входа, цен выхода, лоты входа, лоты выхода, контракты
   double price_In[],price_Out[],lot_In[],lot_Out[],contracts[];

   for(int i=0; i<total; i++) // Цикл по сделкам (у всех сделок единый ID, но позиций может быть более чем одна если тип сделки InOut)
     {
      BorderPointType type; // тип сделки
      double pl_total=0;
      //Print(inputParam.ID);
      if(isBorderPoint(inputParam.deals[i],type)) // Узнаем пограничная ли это сделка и ее тип
        {
         if(type==UsualInput) // Если первоначальный вход, или же увеличение позиции
           {
            inputDeals_calc(detales,inputParam,i,price_In,lot_In,pl_total,firstPL_setted,contracts);
           }
         if(type==UsualOut || type==OutBy) // Закрытие позиции
           {
            outputDeals_calc(isAdd,detales,inputParam,i,price_Out,lot_Out,pl_total,total,contracts);
           }
         if(type==InOut) // Переворот позиии
           {
            reverceDeals_calc(firstPL_setted,contracts,inputParam,i,detales,price_Out,lot_Out,price_In,lot_In,pl_total,ans,isAdd);
           }
        }
      else
        {
         /*
                  Если сделка не пограничная, то просто фиксируем финансовый результат.
                  Тут могут быть только лишь вариационная маржа и различые коррекции.
                  Пополнения и снятия со счета фильтруются при получении исходных для данной функции данных
         */
         detales.pl_forDeal+=(inputParam.deals[i].profit+inputParam.deals[i].comission);
         detales.pl_oneLot+=inputParam.deals[i].profit/calcContracts(contracts,GET_LAST_CONTRACT);
        }
     }

// Фильтруем активные позиции и не сохраняем их
   if(isAdd && PositionSelect(inputParam.symbol))
     {
      if(PositionGetInteger(POSITION_IDENTIFIER)==inputParam.ID)
         isAdd=false;
     }

// Сохраняем зафиксированные и более не активные позиции
   if(isAdd)
     {
      detales.price_in=MA_price(price_In,lot_In);
      detales.price_out=MA_price(price_Out,lot_Out);

      detales.volume=calcContracts(contracts,GET_REAL_CONTRACT);
      addArr(ans,detales);
     }
  }
//+--------------------------------------------------------------------+
//| Возвращает массив сделок где каждая строка - одна конкретная сделка|
//+--------------------------------------------------------------------+
bool CDealHistoryGetter::getDealsDetales(DealDetales &ans[],datetime from,datetime till)
  {
   ArrayFree(ans); // Освобождаем массив
   DealKeeper deals[];
   if(getHistory(deals,from,till)) // Получаем историю сделок
     {
      int total=ArraySize(deals);
      for(int i=0; i<total; i++) // Цикл по всей истории сделок
        {
         DealDetales deals_forID[]; // Массив куда попадает однаили несколько позиций
         getDeals_forSelectedKeeper(deals[i],deals_forID); // Формируем позиции из сделок
         int total_2;
         if((total_2=ArraySize(deals_forID))>0) // Если массив не пуст, то созраняем его в возвращаемом массиве
           {
            for(int n=0; n<total_2; n++)
               addArr(ans,deals_forID[n]);
           }
        }
      return ArraySize(ans) > 0;
     }
   else
      return false;

  }
//+------------------------------------------------------------------+

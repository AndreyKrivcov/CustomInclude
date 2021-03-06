//+------------------------------------------------------------------+
//|                                                ReportCreator.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <CustomInclude/CustomGeneric/GenericSorter.mqh>
#include "DealHistoryGetter.mqh"

#define Q_90 1.282 // Квантиль 90
#define Q_95 1.645 // Квантиль 95
#define Q_99 2.326 // Квантиль 99
//+------------------------------------------------------------------+
//| Структура прибыли и убытка                                       |
//+------------------------------------------------------------------+
struct ProfitDrawdown
  {
   double            Profit; // В некоторых случаях - Прибыль, иногда - прибыль / убыток
   double            Drawdown; // Просадка
  };
//+------------------------------------------------------------------+
//| Структура графиков PL                                            |
//+------------------------------------------------------------------+
struct PLChart_item : public ProfitDrawdown
  {
   datetime          DT;
  };
//+------------------------------------------------------------------+
//| Структура прибыли и просадки                                     |
//+------------------------------------------------------------------+
struct PLDrawdown : public ProfitDrawdown
  {
   int               numTrades_profit; // Количество прибыльных сделок
   int               numTrades_drawdown; // Количество убыточных сделок
  };
//+------------------------------------------------------------------+
//| Структура прибыли и убытка по дням торговой недели               |
//+------------------------------------------------------------------+
struct DailyPL
  {
   PLDrawdown        Mn; // Пн
   PLDrawdown        Tu; // Вт
   PLDrawdown        We; // Ср
   PLDrawdown        Th; // Чт
   PLDrawdown        Fr; // Пт
  };
//+----------------------------------------------------------------------------+
//| Перечисление - указывает как именно требуется совершить подсчет PL по дням |
//+----------------------------------------------------------------------------+
enum DailyPL_calcType
  {
   AVERAGE_DATA, // Усредненные данные
   ABSOLUTE_DATA // Абсолютные данные (просто сумма)
  };
//+--------------------------------------------------------------------------+
//| Перечисление - указывает по каким величинам требуется подсчет PL по дням |
//+--------------------------------------------------------------------------+
enum DailyPL_calcBy
  {
   CALC_FOR_CLOSE,// Подсчет на дату закрытия
   CALC_FOR_OPEN // Подсчет на дату открытия
  };
//+------------------------------------------------------------------+
//| Структура - содержит в себе "Крайние значения" статистики торгов |
//+------------------------------------------------------------------+
struct TotalResult_PLDD
  {
   double            byPL;// по PL
   double            forDeal;// за сделку
   double            inPercents;// в процентах к текущему балансу
   datetime          byPL_DT;// дата по PL
   datetime          forDeal_DT;// дата за сделку
  };
//+------------------------------------------------------------------+
//| Структура - содержит в себе значение VaR                         |
//+------------------------------------------------------------------+
struct VAR
  {
   double            VAR_90,VAR_95,VAR_99;
   double            Mx,Std;
  };
//+------------------------------------------------------------------+
//| Структура - Показывает краткую сводку по статистике торгов       |
//+------------------------------------------------------------------+
struct TotalResult_item
  {
   double            PL;// Общая прибыль или убыток
   double            PL_to_Balance;// Отношение PL к текущему баллансу
   double            averagePL;// Средняя прибыль или убыток
   double            averageDD; // Средняя просадна
   double            averageProfit; // Средняя прибыль
   double            averagePL_to_Balance;// Отношение averagePL к текущему балансу
   double            profitFactor;// Фактор прибыльности
   double            recoveryFactor;// Фактор востановления
   double            sharpRatio; // Коэфицент шарпа
   double            altman_Z_Score; // Z счет Альтмана
   VAR               VaR_absolute,VaR_growth; // VAR
   double            winCoef;// Коэффицент выигрыша
   double            dealsInARow_to_reducePLTo_zerro;/* Если сейчас прибыль - сделок подряд с максимальным убытком за сделку
                                                        для того что бы свести текущую Прибыль по счету в нуль
                                                        Если сейчас убыток - сделок подряд максимальной прибылью за сделку
                                                        для того что бы убыток свести в нуль*/
   TotalResult_PLDD  maxDrawdown;// Максимальная просадка
   TotalResult_PLDD  maxProfit;// Максимальная прибыль
  };
//+------------------------------------------------------------------+
//| Структура результатов торговли                                   |
//+------------------------------------------------------------------+
struct TotalResult
  {
   TotalResult_item  total,oneLot;
  };
//+------------------------------------------------------------------+
//| Часть структуры PL_detales (объявлена ниже)                      |
//+------------------------------------------------------------------+
struct PL_detales_PLDD
  {
   int               orders; // кол - во сделок
   double            orders_in_Percent; // кол - во ордеров в % к общему кол - ву ордеров
   int               dealsInARow; // Сделок подряд
   double            totalResult; // Суммарный результат в деньгах
   double            averageResult; // Средний результат в деньгах
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct PL_detales_item
  {
   PL_detales_PLDD   profit; // Информация по прибыльным сделкам
   PL_detales_PLDD   drawdown; // Информация по убыточным сделкам
  };
//+-------------------------------------------------------------------+
//| Краткая сводка по графику PL разбитая на 2 основопологающих блока |
//+-------------------------------------------------------------------+
struct PL_detales
  {
   PL_detales_item   total,oneLot;
  };
//+------------------------------------------------------------------+
//| Перечисление - Возможные типы графиков                           |
//+------------------------------------------------------------------+
enum CalcType
  {
   _Total,// Реально торгуемый лот
   _OneLot,// Торговля одним лотом
   _Indicative // Исчисляется из _Total - Показывает сколько макс. проигрышей (или мак. выигрышей) подряд нужно что бы вытянуть кревую PL в нуль
  };
//+------------------------------------------------------------------+
//| Перечисление - возможные типы истории торгов                     |
//+------------------------------------------------------------------+
enum ChartType
  {
   _PL, // История торгов
   _BH, // История Buy and Hold
   _Hist_PL,// Гистограмма торгов
   _Hist_BH // Гистограмма Buy and Hold
  };
//+------------------------------------------------------------------+
//| Типы запрашиваемых параметров прибыли и убытка                   |
//+------------------------------------------------------------------+
enum ProfitDrawdownType
  {
   _Max,// Максимальные значения
   _Absolute,// Абсолютные (в деньгах)
   _Percent // В процентах
  };
//+------------------------------------------------------------------+
//| Струкрута - используется для сохранения графиков распределений   |
//+------------------------------------------------------------------+
struct Chart_item
  {
   double            y; // ось y
   double            x; // ось x
  };
//+------------------------------------------------------------------+
//| Структура - используется для сохранения графика коэфицентов      |
//+------------------------------------------------------------------+
struct CoefChart_item
  {
   double            coef; // Значение коэфицента
   datetime          DT; // Значение даты
  };
//+------------------------------------------------------------------+
//| Структура - Используется для зранения графиков распределения,    |
//| а так же значений VaR                                            |
//+------------------------------------------------------------------+
struct Distribution_item
  {
   Chart_item        distribution[]; // График распределния
   VAR               VaR; // VaR
  };
//+------------------------------------------------------------------+
//| Структура - Хранит данные о распределении. Разбита на 2 блока    |
//+------------------------------------------------------------------+
struct DistributionChart
  {
   Distribution_item absolute,growth;
  };
//+------------------------------------------------------------------+
//| Перечисление - Типы графиков коэфиуентов.                        |
//+------------------------------------------------------------------+
enum CoefChartType
  {
   _ShartRatio_chart,//Коэфицент Шарпа
   _WinCoef_chart,//Коэфицент выигрыша
   _RecoveryFactor_chart,//Коэфицент востановления
   _ProfitFactor_chart,//Профит фактор
   _AltmanZScore_chart//Z-счет альтмана
  };
//+------------------------------------------------------------------+
//| Класс - комперер. Помогает сортировать графики распределения     |
//+------------------------------------------------------------------+
class CChartComparer : public ICustomComparer<Chart_item>
  {
public:
   int               Compare(Chart_item &x,Chart_item &y);// Метод сравленения
  };
//+------------------------------------------------------------------+
//| Класс создания статистики истории торгов                         |
//+------------------------------------------------------------------+
class CReportCreator
  {
public:
                     CReportCreator(CCCM *_comission_manager) : comission_manager(_comission_manager)
     {}

   //=============================================================================================================================================
   // Calculation/ Recalculation:
   //=============================================================================================================================================

   void              Create(DealDetales &history[],DealDetales &BH_history[],const double balance,const string &Symb[],double r);
   void              Create(DealDetales &history[],DealDetales &BH_history[],const string &Symb[],double r);
   void              Create(DealDetales &history[],const string &Symb[],const double balance,double r);
   void              Create(DealDetales &history[],double r);
   bool              Create(const string &Symb[],double r);
   bool              Create(double r=0);

   //=============================================================================================================================================
   // Getters:
   //=============================================================================================================================================

   bool              GetChart(ChartType chart_type,CalcType calc_type,PLChart_item &out[]); // Получение графиков PL
   bool              GetDistributionChart(bool isOneLot,DistributionChart &out); // Получение графиков распределения
   bool              GetCoefChart(bool isOneLot,CoefChartType type,CoefChart_item &out[]); // Полечение графиков коэфицентов
   bool              GetDailyPL(DailyPL_calcBy calcBy,DailyPL_calcType calcType,DailyPL &out); // Получение графика PL по дням
   bool              GetRatioTable(bool isOneLot,ProfitDrawdownType type,ProfitDrawdown &out); // Получение таблицы крайних точек
   bool              GetTotalResult(TotalResult &out); // Получение таблицы TotalResult
   bool              GetPL_detales(PL_detales &out); // Получение таблицы PL_detales
   void              Get_Symb(const DealDetales &history[],string &Symb[]); // Получение массива инструментов которые участвовали в торгах

   void              Clear(); // Отчистка статистики
   double            GetBalance() {return balance;}

private:
   CCCM              *comission_manager;
   //=============================================================================================================================================
   // Private data types:
   //=============================================================================================================================================
   // Структура типок графика PL
   struct PL_keeper
     {
      PLChart_item      PL_total[];
      PLChart_item      PL_oneLot[];
      PLChart_item      PL_Indicative[];
     };
   // Структура типов графика дневной Прибыли/Убытка
   struct DailyPL_keeper
     {
      DailyPL           avarage_open,avarage_close,absolute_open,absolute_close;
     };
   // Структура таблиц крайних точек
   struct RatioTable_keeper
     {
      ProfitDrawdown    Total_max,Total_absolute,Total_percent;
      ProfitDrawdown    OneLot_max,OneLot_absolute,OneLot_percent;
     };
   // Структуры для подсчета кол - ва прибылей и убытка подряд
   struct S_dealsCounter
     {
      int               Profit,DD;
     };
   struct S_dealsInARow : public S_dealsCounter
     {
      S_dealsCounter    Counter;
     };
   // Структуры для расчета вспомогательных данных
   struct CalculationData_item
     {
      S_dealsInARow     dealsCounter;
      int               R_arr[];
      double            DD_percent;
      double            Accomulated_DD,Accomulated_Profit;
      double            PL;
      double            Max_DD_forDeal,Max_Profit_forDeal;
      double            Max_DD_byPL,Max_Profit_byPL;
      datetime          DT_Max_DD_byPL,DT_Max_Profit_byPL;
      datetime          DT_Max_DD_forDeal,DT_Max_Profit_forDeal;
      int               Total_DD_numDeals,Total_Profit_numDeals;
     };
   struct CalculationData
     {
      CalculationData_item total,oneLot;
      int               num_deals;
      bool              isNot_firstDeal;
     };
   // Структура для созранения графиков каэфицентов
   struct CoefChart_keeper
     {
      CoefChart_item    OneLot_ShartRatio_chart[],Total_ShartRatio_chart[];
      CoefChart_item    OneLot_WinCoef_chart[],Total_WinCoef_chart[];
      CoefChart_item    OneLot_RecoveryFactor_chart[],Total_RecoveryFactor_chart[];
      CoefChart_item    OneLot_ProfitFactor_chart[],Total_ProfitFactor_chart[];
      CoefChart_item    OneLot_AltmanZScore_chart[],Total_AltmanZScore_chart[];
     };
   // Класс участвующий в сортировки истории торгов по дате закрытия.
   class CHistoryComparer : public ICustomComparer<DealDetales>
     {
   public:
      int               Compare(DealDetales &x,DealDetales &y);
     };
   //=============================================================================================================================================
   // Keepers:
   //=============================================================================================================================================
   CHistoryComparer  historyComparer; // Сравнивающий класс
   CChartComparer    chartComparer; // Сравнивающий класс

   // Вспомогательные структуры
   PL_keeper         PL,PL_hist,BH,BH_hist;
   DailyPL_keeper    DailyPL_data;
   RatioTable_keeper RatioTable_data;
   TotalResult       TotalResult_data;
   PL_detales        PL_detales_data;
   DistributionChart OneLot_PDF_chart,Total_PDF_chart;
   CoefChart_keeper  CoefChart_data;

   double            balance,r; // Начальный депозит и безрисковая ставка
   // Класс кортировщик
   CGenericSorter    sorter;

   //=============================================================================================================================================
   // Calculations:
   //=============================================================================================================================================
   // Подсчет PL
   void              CalcPL(const DealDetales &deal,CalculationData &data,PLChart_item &pl_out[],CalcType type);
   // Подсчет Гистограмм PL
   void              CalcPLHist(const DealDetales &deal,CalculationData &data,PLChart_item &pl_out[],CalcType type);
   // Подсчет вспомогательных структур по которым все строится
   void              CalcData(const DealDetales &deal,CalculationData &out,bool isBH);
   void              CalcData_item(const DealDetales &deal,CalculationData_item &out,bool isOneLot);
   // Подсчет Дневного прибыли/убытка
   void              CalcDailyPL(DailyPL &out,DailyPL_calcBy calcBy,const DealDetales &deal);
   void              cmpDay(const DealDetales &deal,ENUM_DAY_OF_WEEK etalone,PLDrawdown &ans,DailyPL_calcBy calcBy);
   void              avarageDay(PLDrawdown &day);
   // Сопоставление символов
   bool              isSymb(const string &Symb[],string symbol);
   // Подсчет Профит фактора
   void              ProfitFactor_chart_calc(CoefChart_item &out[],CalculationData &data,const DealDetales &deal,bool isOneLot);
   // Подсчет Фактора востановления
   void              RecoveryFactor_chart_calc(CoefChart_item &out[],CalculationData &data,const DealDetales &deal,bool isOneLot);
   // Подсчет Коэфицента выигрыша
   void              WinCoef_chart_calc(CoefChart_item &out[],CalculationData &data,const DealDetales &deal,bool isOneLot);
   // Подсчет Коэфицента Шарпа
   double            ShartRatio_calc(PLChart_item &data[]);
   void              ShartRatio_chart_calc(CoefChart_item &out[],PLChart_item &data[],const DealDetales &deal);
   // Подсчет Распределения
   void              NormalPDF_chart_calc(DistributionChart &out,PLChart_item &data[]);
   double            PDF_calc(double Mx,double Std,double x);
   // Подсчет VaR
   double            VaR(double quantile,double Mx,double Std);
   // Подсчет Z-счета
   void              AltmanZScore_chart_calc(CoefChart_item &out[],double N,double R,double W,double L,const DealDetales &deal);
   // Подсчет струтуры TotalResult_item
   void              CalcTotalResult(CalculationData &data,bool isOneLot,TotalResult_item &out);
   // Подсчет структуры PL_detales_item
   void              CalcPL_detales(CalculationData_item &data,int deals_num,PL_detales_item &out);
   // Получение дня из даты
   ENUM_DAY_OF_WEEK  getDay(datetime DT);
   // Отчистка данных
   void              Clear_PL_keeper(PL_keeper &data);
   void              Clear_DailyPL(DailyPL &data);
   void              Clear_RatioTable(RatioTable_keeper &data);
   void              Clear_TotalResult_item(TotalResult_item &data);
   void              Clear_PL_detales(PL_detales &data);
   void              Clear_DistributionChart(DistributionChart &data);
   void              Clear_CoefChart_keeper(CoefChart_keeper &data);

   //=============================================================================================================================================
   // Copy:
   //=============================================================================================================================================
   void              CopyPL(const PLChart_item &src[],PLChart_item &out[]); // Копирование графиков PL
   void              CopyCoefChart(const CoefChart_item &src[],CoefChart_item &out[]); // Копирование графиков коэфицентов

  };
//+------------------------------------------------------------------+
//| Сортировка по оси x                                              |
//+------------------------------------------------------------------+
int CChartComparer::Compare(Chart_item &x,Chart_item &y)
  {
   return compareDouble(x.x,y.x);
  }
//+------------------------------------------------------------------+
//| Сортировка по дате завершения сделки                             |
//+------------------------------------------------------------------+
int CReportCreator::CHistoryComparer::Compare(DealDetales &x,DealDetales &y)
  {
   return(x.DT_close == y.DT_close ? 0 : (x.DT_close > y.DT_close ? 1 : -1));
  }
//+------------------------------------------------------------------+
//| Отчистка данных                                                  |
//+------------------------------------------------------------------+
void CReportCreator::Clear(void)
  {
   Clear_PL_keeper(PL);
   Clear_PL_keeper(BH);
   Clear_PL_keeper(PL_hist);
   Clear_PL_keeper(BH_hist);
   Clear_DailyPL(DailyPL_data.absolute_close);
   Clear_DailyPL(DailyPL_data.absolute_open);
   Clear_DailyPL(DailyPL_data.avarage_close);
   Clear_DailyPL(DailyPL_data.avarage_open);
   Clear_RatioTable(RatioTable_data);
   Clear_TotalResult_item(TotalResult_data.oneLot);
   Clear_TotalResult_item(TotalResult_data.total);
   Clear_PL_detales(PL_detales_data);
   Clear_DistributionChart(OneLot_PDF_chart);
   Clear_DistributionChart(Total_PDF_chart);
   Clear_CoefChart_keeper(CoefChart_data);
   balance=0;
   r=0;
  }
//+------------------------------------------------------------------+
//| Отчистка данных                                                  |
//+------------------------------------------------------------------+
void CReportCreator::Clear_PL_keeper(PL_keeper &data)
  {
   ArrayFree(data.PL_Indicative);
   ArrayFree(data.PL_oneLot);
   ArrayFree(data.PL_total);
  }
//+------------------------------------------------------------------+
//| Отчистка данных                                                  |
//+------------------------------------------------------------------+
void CReportCreator::Clear_DailyPL(DailyPL &data)
  {
   ZeroMemory(data.Mn);
   ZeroMemory(data.Tu);
   ZeroMemory(data.We);
   ZeroMemory(data.Th);
   ZeroMemory(data.Fr);
  }
//+------------------------------------------------------------------+
//| Отчистка данных                                                  |
//+------------------------------------------------------------------+
void CReportCreator::Clear_RatioTable(RatioTable_keeper &data)
  {
   ZeroMemory(data.OneLot_absolute);
   ZeroMemory(data.OneLot_max);
   ZeroMemory(data.OneLot_percent);
   ZeroMemory(data.Total_absolute);
   ZeroMemory(data.Total_max);
   ZeroMemory(data.Total_percent);
  }
//+------------------------------------------------------------------+
//| Отчистка данных                                                  |
//+------------------------------------------------------------------+
void CReportCreator::Clear_TotalResult_item(TotalResult_item &data)
  {
   ZeroMemory(data);
   ZeroMemory(data.VaR_absolute);
   ZeroMemory(data.VaR_growth);
   ZeroMemory(data.maxDrawdown);
   ZeroMemory(data.maxProfit);
  }
//+------------------------------------------------------------------+
//| Отчистка данных                                                  |
//+------------------------------------------------------------------+
void CReportCreator::Clear_PL_detales(PL_detales &data)
  {
   ZeroMemory(data.oneLot.drawdown);
   ZeroMemory(data.oneLot.profit);
   ZeroMemory(data.total.drawdown);
   ZeroMemory(data.total.profit);
  }
//+------------------------------------------------------------------+
//| Отчистка данных                                                  |
//+------------------------------------------------------------------+
void CReportCreator::Clear_DistributionChart(DistributionChart &data)
  {
   ZeroMemory(data.absolute.VaR);
   ArrayFree(data.absolute.distribution);
   ZeroMemory(data.growth.VaR);
   ArrayFree(data.growth.distribution);
  }
//+------------------------------------------------------------------+
//| Отчистка данных                                                  |
//+------------------------------------------------------------------+
void CReportCreator::Clear_CoefChart_keeper(CoefChart_keeper &data)
  {
   ArrayFree(data.OneLot_AltmanZScore_chart);
   ArrayFree(data.OneLot_ProfitFactor_chart);
   ArrayFree(data.OneLot_RecoveryFactor_chart);
   ArrayFree(data.OneLot_ShartRatio_chart);
   ArrayFree(data.OneLot_WinCoef_chart);
   ArrayFree(data.Total_AltmanZScore_chart);
   ArrayFree(data.Total_ProfitFactor_chart);
   ArrayFree(data.Total_RecoveryFactor_chart);
   ArrayFree(data.Total_ShartRatio_chart);
   ArrayFree(data.Total_WinCoef_chart);
  }
//+------------------------------------------------------------------+
//| Получение таблицы PL_detales                                     |
//+------------------------------------------------------------------+
bool CReportCreator::GetPL_detales(PL_detales &out)
  {
   out=PL_detales_data;
   return out.oneLot.drawdown.orders > 0 || out.oneLot.profit.orders > 0 ||
          out.total.drawdown.orders>0 || out.total.profit.orders>0;
  }
//+------------------------------------------------------------------+
//| Получение таблицы TotalResult                                    |
//+------------------------------------------------------------------+
bool CReportCreator::GetTotalResult(TotalResult &out)
  {
   out=TotalResult_data;
   return out.oneLot.VaR_absolute.Std !=0 || out.total.VaR_absolute.Std !=0;
  }
//+------------------------------------------------------------------+
//| Получение таблицы крайних точек                                  |
//+------------------------------------------------------------------+
bool CReportCreator::GetRatioTable(bool isOneLot,ProfitDrawdownType type,ProfitDrawdown &out)
  {
   switch(type)
     {
      case _Max :
         out=(isOneLot ? RatioTable_data.OneLot_max : RatioTable_data.Total_max);
         break;
      case _Absolute :
         out=(isOneLot ? RatioTable_data.OneLot_absolute : RatioTable_data.Total_absolute);
         break;
      case _Percent :
         out=(isOneLot ? RatioTable_data.OneLot_percent : RatioTable_data.Total_percent);
         break;
     }
   return out.Drawdown < 0 || out.Profit > 0;
  }
//+------------------------------------------------------------------+
//| Получение графика PL по дням                                     |
//+------------------------------------------------------------------+
bool CReportCreator::GetDailyPL(DailyPL_calcBy calcBy,DailyPL_calcType calcType,DailyPL &out)
  {
   if(calcBy==CALC_FOR_CLOSE)
     {
      if(calcType==AVERAGE_DATA)
         out=DailyPL_data.avarage_close;
      else
         out=DailyPL_data.absolute_close;
     }
   else
     {
      if(calcType==AVERAGE_DATA)
         out=DailyPL_data.avarage_open;
      else
         out=DailyPL_data.absolute_open;
     }
   bool Mn = out.Mn.numTrades_profit > 0 || out.Mn.numTrades_drawdown > 0;
   bool Tu = out.Tu.numTrades_profit > 0 || out.Tu.numTrades_drawdown > 0;
   bool We = out.We.numTrades_profit > 0 || out.We.numTrades_drawdown > 0;
   bool Th = out.Th.numTrades_profit > 0 || out.Th.numTrades_drawdown > 0;
   bool Fr = out.Fr.numTrades_profit > 0 || out.Fr.numTrades_drawdown > 0;
   return Mn || Tu || We || Th || Fr;
  }
//+------------------------------------------------------------------+
//| Копирование графиков коэфицентов                                 |
//+------------------------------------------------------------------+
void CReportCreator::CopyCoefChart(const CoefChart_item &src[],CoefChart_item &out[])
  {
   for(int i=0; i<ArraySize(src); i++)
     {
      int s=ArraySize(out);
      ArrayResize(out,s+1,s+1);
      out[i]=src[i];
     }
  }
//+------------------------------------------------------------------+
//| Полечение графиков коэфицентов                                         |
//+------------------------------------------------------------------+
bool CReportCreator::GetCoefChart(bool isOneLot,CoefChartType type,CoefChart_item &out[])
  {
   ArrayFree(out);
   switch(type)
     {
      case _ShartRatio_chart :
        {
         if(isOneLot)
            CopyCoefChart(CoefChart_data.OneLot_ShartRatio_chart,out);
         else
            CopyCoefChart(CoefChart_data.Total_ShartRatio_chart,out);
        }
      break;
      case _WinCoef_chart :
        {
         if(isOneLot)
            CopyCoefChart(CoefChart_data.OneLot_WinCoef_chart,out);
         else
            CopyCoefChart(CoefChart_data.Total_WinCoef_chart,out);
        }
      break;
      case _RecoveryFactor_chart :
        {
         if(isOneLot)
            CopyCoefChart(CoefChart_data.OneLot_RecoveryFactor_chart,out);
         else
            CopyCoefChart(CoefChart_data.Total_RecoveryFactor_chart,out);
        }
      break;
      case _ProfitFactor_chart:
        {
         if(isOneLot)
            CopyCoefChart(CoefChart_data.OneLot_ProfitFactor_chart,out);
         else
            CopyCoefChart(CoefChart_data.Total_ProfitFactor_chart,out);
        }
      break;
      case _AltmanZScore_chart :
        {
         if(isOneLot)
            CopyCoefChart(CoefChart_data.OneLot_AltmanZScore_chart,out);
         else
            CopyCoefChart(CoefChart_data.Total_AltmanZScore_chart,out);
        }
      break;
     }
   return ArraySize(out)>0;
  }
//+------------------------------------------------------------------+
//| Получение графиков распределения                                 |
//+------------------------------------------------------------------+
bool CReportCreator::GetDistributionChart(bool isOneLot,DistributionChart &out)
  {
   if(isOneLot)
      out=OneLot_PDF_chart;
   else
      out=Total_PDF_chart;
   bool absolut_pdf= ArraySize(out.absolute.distribution)>0;
   bool growth_pdf = ArraySize(out.growth.distribution)>0;
   return absolut_pdf && growth_pdf;
  }
//+------------------------------------------------------------------+
//| Копирование графиков PL                                          |
//+------------------------------------------------------------------+
void CReportCreator::CopyPL(const PLChart_item &src[],PLChart_item &out[])
  {
   for(int i=0; i<ArraySize(src); i++)
     {
      int s=ArraySize(out);
      ArrayResize(out,s+1,s+1);
      out[s]=src[i];
     }
  }
//+------------------------------------------------------------------+
//| Получение графиков PL                                            |
//+------------------------------------------------------------------+
bool CReportCreator::GetChart(ChartType chart_type,CalcType calc_type,PLChart_item &out[])
  {
   ArrayFree(out);

   switch(chart_type)
     {
      case _PL :
        {
         switch(calc_type)
           {
            case _Total :
               CopyPL(PL.PL_total,out);
               break;
            case _OneLot :
               CopyPL(PL.PL_oneLot,out);
               break;
            case _Indicative :
               CopyPL(PL.PL_Indicative,out);
               break;
           }
        }
      break;
      case _BH:
        {
         switch(calc_type)
           {
            case _Total :
               CopyPL(BH.PL_total,out);
               break;
            case _OneLot :
               CopyPL(BH.PL_oneLot,out);
               break;
            case _Indicative :
               CopyPL(BH.PL_Indicative,out);
               break;
           }
        }
      break;
      case _Hist_PL:
        {
         switch(calc_type)
           {
            case _Total :
               CopyPL(PL_hist.PL_total,out);
               break;
            case _OneLot :
               CopyPL(PL_hist.PL_oneLot,out);
               break;
            case _Indicative :
               CopyPL(PL_hist.PL_Indicative,out);
               break;
           }
        }
      break;
      case _Hist_BH:
        {
         switch(calc_type)
           {
            case _Total :
               CopyPL(BH_hist.PL_total,out);
               break;
            case _OneLot :
               CopyPL(BH_hist.PL_oneLot,out);
               break;
            case _Indicative :
               CopyPL(BH_hist.PL_Indicative,out);
               break;
           }
        }
      break;
     }

   return ArraySize(out)>0;
  }
//+------------------------------------------------------------------+
//| Подсчет структуры PL_detales_item                                |
//+------------------------------------------------------------------+
void CReportCreator::CalcPL_detales(CalculationData_item &data,int deals_num,PL_detales_item &out)
  {
   ZeroMemory(out.drawdown);
   ZeroMemory(out.profit);

   if(data.Total_DD_numDeals>0)
      out.drawdown.averageResult=data.Accomulated_DD/data.Total_DD_numDeals;
   out.drawdown.dealsInARow=data.dealsCounter.DD;
   out.drawdown.orders=data.Total_DD_numDeals;
   out.drawdown.orders_in_Percent=(double)data.Total_DD_numDeals/(double)deals_num;
   out.drawdown.totalResult=data.Accomulated_DD;

   if(data.Total_Profit_numDeals>0)
      out.profit.averageResult=data.Accomulated_Profit/data.Total_Profit_numDeals;
   out.profit.dealsInARow=data.dealsCounter.Profit;
   out.profit.orders=data.Total_Profit_numDeals;
   out.profit.orders_in_Percent=(double)data.Total_Profit_numDeals/(double)deals_num;
   out.profit.totalResult=data.Accomulated_Profit;
  }
//+------------------------------------------------------------------+
//| Подсчет струтуры TotalResult_item                                |
//+------------------------------------------------------------------+
void CReportCreator::CalcTotalResult(CalculationData &data,bool isOneLot,TotalResult_item &out)
  {
   ZeroMemory(out.VaR_absolute);
   ZeroMemory(out.VaR_growth);
   ZeroMemory(out.maxDrawdown);
   ZeroMemory(out.maxProfit);

   CalculationData_item _data;
   DistributionChart pdf;
   double Z_score,profitFactor,recoveryFactor;
   double sharpRatio,winCoef;

// Расчет данных в соответствии с лотом
   if(isOneLot)
     {
      _data=data.oneLot;
      pdf=OneLot_PDF_chart;
      Z_score=CoefChart_data.OneLot_AltmanZScore_chart[ArraySize(CoefChart_data.OneLot_AltmanZScore_chart)-1].coef;
      profitFactor=CoefChart_data.OneLot_ProfitFactor_chart[ArraySize(CoefChart_data.OneLot_ProfitFactor_chart)-1].coef;
      recoveryFactor=CoefChart_data.OneLot_RecoveryFactor_chart[ArraySize(CoefChart_data.OneLot_RecoveryFactor_chart)-1].coef;
      sharpRatio=CoefChart_data.OneLot_ShartRatio_chart[ArraySize(CoefChart_data.OneLot_ShartRatio_chart)-1].coef;
      winCoef=CoefChart_data.OneLot_WinCoef_chart[ArraySize(CoefChart_data.OneLot_WinCoef_chart)-1].coef;
      if(_data.Total_DD_numDeals>0)
         out.averageDD=data.oneLot.Accomulated_DD/_data.Total_DD_numDeals;
      if(_data.Total_Profit_numDeals>0)
         out.averageProfit=data.oneLot.Accomulated_Profit/_data.Total_Profit_numDeals;
      if(data.oneLot.PL>=0)
         out.dealsInARow_to_reducePLTo_zerro=(data.oneLot.Max_DD_forDeal!=0 ?(data.oneLot.PL/MathAbs(data.oneLot.Max_DD_forDeal)) : 0);
      else
         out.dealsInARow_to_reducePLTo_zerro=(data.oneLot.Max_Profit_forDeal!=0 ?(data.oneLot.PL/data.oneLot.Max_Profit_forDeal) : 0);
     }
   else
     {
      _data=data.total;
      pdf=Total_PDF_chart;
      Z_score=CoefChart_data.Total_AltmanZScore_chart[ArraySize(CoefChart_data.Total_AltmanZScore_chart)-1].coef;
      profitFactor=CoefChart_data.Total_ProfitFactor_chart[ArraySize(CoefChart_data.Total_ProfitFactor_chart)-1].coef;
      recoveryFactor=CoefChart_data.Total_RecoveryFactor_chart[ArraySize(CoefChart_data.Total_RecoveryFactor_chart)-1].coef;
      sharpRatio=CoefChart_data.Total_ShartRatio_chart[ArraySize(CoefChart_data.Total_ShartRatio_chart)-1].coef;
      winCoef=CoefChart_data.Total_WinCoef_chart[ArraySize(CoefChart_data.Total_WinCoef_chart)-1].coef;
      if(_data.Total_DD_numDeals>0)
         out.averageDD=data.total.Accomulated_DD/_data.Total_DD_numDeals;
      if(_data.Total_Profit_numDeals > 0)
         out.averageProfit=data.total.Accomulated_Profit/_data.Total_Profit_numDeals;
      out.dealsInARow_to_reducePLTo_zerro=PL.PL_Indicative[ArraySize(PL.PL_Indicative)-1].Profit;
     }

// Расчет данных и заполнение структуры
   out.PL=_data.PL;
   out.PL_to_Balance=(balance>0 ? (_data.PL/balance) : 0);
   out.VaR_absolute = pdf.absolute.VaR;
   out.VaR_growth=pdf.growth.VaR;
   out.altman_Z_Score=Z_score;
   out.averagePL=pdf.absolute.VaR.Mx;
   out.averagePL_to_Balance=(balance>0 ?(out.averagePL/balance) : 0);

   out.maxDrawdown.byPL=_data.Max_DD_byPL;
   out.maxDrawdown.byPL_DT = _data.DT_Max_DD_byPL;
   out.maxDrawdown.forDeal = _data.Max_DD_forDeal;
   out.maxDrawdown.forDeal_DT=_data.DT_Max_DD_forDeal;
   out.maxDrawdown.inPercents=(balance > 0 ? (MathAbs(_data.Max_DD_byPL)/balance) : 0);

   out.maxProfit.byPL=_data.Max_Profit_byPL;
   out.maxProfit.byPL_DT = _data.DT_Max_Profit_byPL;
   out.maxProfit.forDeal = _data.Max_Profit_forDeal;
   out.maxProfit.forDeal_DT=_data.DT_Max_Profit_forDeal;
   out.maxProfit.inPercents=(balance > 0 ? (MathAbs(_data.Max_Profit_byPL)/balance) : 0);

   out.profitFactor=profitFactor;
   out.recoveryFactor=recoveryFactor;
   out.sharpRatio=sharpRatio;
   out.winCoef=winCoef;
  }
//+------------------------------------------------------------------+
//| Подсчет Распределения                                            |
//+------------------------------------------------------------------+
void CReportCreator::NormalPDF_chart_calc(DistributionChart &out,PLChart_item &data[])
  {
   double Mx_absolute=0,Mx_growth=0,Std_absolute=0,Std_growth=0;
   int total=ArraySize(data);
   ZeroMemory(out.absolute);
   ZeroMemory(out.growth);
   ZeroMemory(out.absolute.VaR);
   ZeroMemory(out.growth.VaR);
   ArrayFree(out.absolute.distribution);
   ArrayFree(out.growth.distribution);

// Расчет параметров распределения
   if(total>=2)
     {
      int n=0;
      for(int i=0; i<total; i++)
        {
         Mx_absolute+=data[i].Profit;
         if(i>0 && data[i-1].Profit!=0)
           {
            Mx_growth+=(data[i].Profit-data[i-1].Profit)/data[i-1].Profit;
            n++;
           }
        }
      Mx_absolute/=(double)total;
      if(n>=2)
         Mx_growth/=(double)n;

      n=0;
      for(int i=0; i<total; i++)
        {
         Std_absolute+=MathPow(data[i].Profit-Mx_absolute,2);
         if(i>0 && data[i-1].Profit!=0)
           {
            Std_growth+=MathPow((data[i].Profit-data[i-1].Profit)/data[i-1].Profit-Mx_growth,2);
            n++;
           }
        }
      Std_absolute=MathSqrt(Std_absolute/(double)(total-1));
      if(n>=2)
         Std_growth=MathSqrt(Std_growth/(double)(n-1));

      // Подсчет VaR
      out.absolute.VaR.Mx=Mx_absolute;
      out.absolute.VaR.Std=Std_absolute;
      out.absolute.VaR.VAR_90=VaR(Q_90,Mx_absolute,Std_absolute);
      out.absolute.VaR.VAR_95=VaR(Q_95,Mx_absolute,Std_absolute);
      out.absolute.VaR.VAR_99=VaR(Q_99,Mx_absolute,Std_absolute);
      out.growth.VaR.Mx=Mx_growth;
      out.growth.VaR.Std=Std_growth;
      out.growth.VaR.VAR_90=VaR(Q_90,Mx_growth,Std_growth);
      out.growth.VaR.VAR_95=VaR(Q_95,Mx_growth,Std_growth);
      out.growth.VaR.VAR_99=VaR(Q_99,Mx_growth,Std_growth);

      // Расчет распределения
      for(int i=0; i<total; i++)
        {
         Chart_item  item_a,item_g;
         ZeroMemory(item_a);
         ZeroMemory(item_g);
         item_a.x=data[i].Profit;
         item_a.y=PDF_calc(Mx_absolute,Std_absolute,data[i].Profit);
         if(i>0)
           {
            item_g.x=(data[i-1].Profit != 0 ?(data[i].Profit-data[i-1].Profit)/data[i-1].Profit : 0);
            item_g.y=PDF_calc(Mx_growth,Std_growth,item_g.x);
           }
         int s=ArraySize(out.absolute.distribution);
         ArrayResize(out.absolute.distribution,s+1,s+1);
         out.absolute.distribution[s]=item_a;
         s=ArraySize(out.growth.distribution);
         ArrayResize(out.growth.distribution,s+1,s+1);
         out.growth.distribution[s]=item_g;
        }
      // Acending
      sorter.Sort<Chart_item>(out.absolute.distribution,&chartComparer);
      sorter.Sort<Chart_item>(out.growth.distribution,&chartComparer);
     }
  }
//+------------------------------------------------------------------+
//| Подсчет VaR                                                      |
//+------------------------------------------------------------------+
double CReportCreator::VaR(double quantile,double Mx,double Std)
  {
   return Mx-quantile*Std;
  }
//+------------------------------------------------------------------+
//| Подсчет Распределения                                            |
//+------------------------------------------------------------------+
double CReportCreator::PDF_calc(double Mx,double Std,double x)
  {
   if(Std!=0)
      return MathExp(-0.5*MathPow((x-Mx)/Std,2))/(MathSqrt(2*M_PI)*Std);
   else
      return 0;
  }
//+------------------------------------------------------------------+
//| Подсчет Коэфицента Шарпа                                         |
//+------------------------------------------------------------------+
double CReportCreator::ShartRatio_calc(PLChart_item &data[])
  {
   int total=ArraySize(data);
   double ans=0;
   if(total>=2)
     {
      double pl_r=0;
      int n=0;
      for(int i=1; i<total; i++)
        {
         if(data[i-1].Profit!=0)
           {
            pl_r+=(data[i].Profit-data[i-1].Profit)/data[i-1].Profit;
            n++;
           }
        }
      if(n>=2)
         pl_r/=(double)n;
      double std=0;
      n=0;
      for(int i=1; i<total; i++)
        {
         if(data[i-1].Profit!=0)
           {
            std+=MathPow((data[i].Profit-data[i-1].Profit)/data[i-1].Profit-pl_r,2);
            n++;
           }
        }
      if(n>=2)
         std=MathSqrt(std/(double)(n-1));

      ans=(std!=0 ?(pl_r-r)/std : 0);
     }
   return ans;
  }
//+------------------------------------------------------------------+
//| Подсчет Z-счета                                                  |
//+------------------------------------------------------------------+
void CReportCreator::AltmanZScore_chart_calc(CoefChart_item &out[],double N,double R,double W,double L,/*bool isNot_firstDeal,*/const DealDetales &deal)
  {
   CoefChart_item item;
   item.DT=deal.DT_close;
   item.coef=0;
   double P = 2*W*L;
   if(R>1 && P!=N)
      item.coef=(N*(R-0.5)-P)/MathPow((P*(P-N))/(N-1),0.5);
   int s=ArraySize(out);
   ArrayResize(out,s+1,s+1);
   out[s]=item;
  }
//+------------------------------------------------------------------+
//| Подсчет Коэфицента Шарпа                                         |
//+------------------------------------------------------------------+
void CReportCreator::ShartRatio_chart_calc(CoefChart_item &out[],PLChart_item &data[],const DealDetales &deal/*,bool isNot_firstDeal*/)
  {
   CoefChart_item item;
   item.DT=deal.DT_close;
   item.coef=ShartRatio_calc(data);
   int s=ArraySize(out);
   ArrayResize(out,s+1,s+1);
   out[s]=item;
  }
//+------------------------------------------------------------------+
//| Подсчет Коэфицента выигрыша                                      |
//+------------------------------------------------------------------+
void CReportCreator::WinCoef_chart_calc(CoefChart_item &out[],CalculationData &data,const DealDetales &deal,bool isOneLot)
  {
   CoefChart_item item;
   item.DT=deal.DT_close;
   double profit=(isOneLot ? data.oneLot.Accomulated_Profit : data.total.Accomulated_Profit);
   double dd=MathAbs(isOneLot ? data.oneLot.Accomulated_DD : data.total.Accomulated_DD);
   int n_profit=(isOneLot ? data.oneLot.Total_Profit_numDeals : data.total.Total_Profit_numDeals);
   int n_dd=(isOneLot ? data.oneLot.Total_DD_numDeals : data.total.Total_DD_numDeals);
   if(n_dd == 0 || n_profit == 0)
      item.coef = 0;
   else
      item.coef=(profit/n_profit)/(dd/n_dd);
   int s=ArraySize(out);
   ArrayResize(out,s+1,s+1);
   out[s]=item;
  }
//+------------------------------------------------------------------+
//| Подсчет Фактора востановления                                    |
//+------------------------------------------------------------------+
void CReportCreator::RecoveryFactor_chart_calc(CoefChart_item &out[],CalculationData &data,const DealDetales &deal,bool isOneLot)
  {
   CoefChart_item item;
   item.DT=deal.DT_close;
   double pl=(isOneLot ? data.oneLot.PL : data.total.PL);
   double dd=MathAbs(isOneLot ? data.oneLot.Max_DD_byPL : data.total.Max_DD_byPL);
   if(dd==0)
      item.coef=0;//по хорошему - это плюс бесконечность
   else
      item.coef=pl/dd;
   int s=ArraySize(out);
   ArrayResize(out,s+1,s+1);
   out[s]=item;
  }
//+------------------------------------------------------------------+
//| Подсчет Профит фактора                                           |
//+------------------------------------------------------------------+
void CReportCreator::ProfitFactor_chart_calc(CoefChart_item &out[],CalculationData &data,const DealDetales &deal,bool isOneLot)
  {
   CoefChart_item item;
   item.DT=deal.DT_close;
   double profit=(isOneLot ? data.oneLot.Accomulated_Profit : data.total.Accomulated_Profit);
   double dd=MathAbs(isOneLot ? data.oneLot.Accomulated_DD : data.total.Accomulated_DD);
   if(dd==0)
      item.coef=0;
   else
      item.coef=profit/dd;
   int s=ArraySize(out);
   ArrayResize(out,s+1,s+1);
   out[s]=item;
  }
//+------------------------------------------------------------------+
//| Сопоставление символов                                           |
//+------------------------------------------------------------------+
bool CReportCreator::isSymb(const string &Symb[],string symbol)
  {
   bool ans=false;
   for(int i=0; i<ArraySize(Symb); i++)
     {
      if(StringCompare(Symb[i],symbol)==0)
        {
         ans=true;
         break;
        }
     }
   return ans;
  }
//+------------------------------------------------------------------+
//| Сравнение типов Double с точностью до 10 знака                   |
//+------------------------------------------------------------------+
int compareDouble(double x,double y)
  {
   double diff=NormalizeDouble(x-y,10);
   if(diff>0)
      return 1;
   else
      if(diff<0)
         return -1;
      else
         return 0;
  }
//+------------------------------------------------------------------+
//| Усреднение PL/DD наторгованныз за день                           |
//+------------------------------------------------------------------+
void CReportCreator::avarageDay(PLDrawdown &day)
  {
   if(day.numTrades_profit>0)
      day.Profit/=day.numTrades_profit;
   if(day.numTrades_drawdown > 0)
      day.Drawdown/=day.numTrades_drawdown;
  }
//+------------------------------------------------------------------+
//| Сохранение PL/DD наторгованных да день                           |
//+------------------------------------------------------------------+
void CReportCreator::cmpDay(const DealDetales &deal,ENUM_DAY_OF_WEEK etalone,PLDrawdown &ans,DailyPL_calcBy calcBy)
  {
   ENUM_DAY_OF_WEEK day=(calcBy==CALC_FOR_CLOSE ? deal.day_close : deal.day_open);
   if(day==etalone)
     {
      if(deal.pl_forDeal>0)
        {
         ans.Profit+=deal.pl_forDeal;
         ans.numTrades_profit++;
        }
      else
         if(deal.pl_forDeal<0)
           {
            ans.Drawdown+=MathAbs(deal.pl_forDeal);
            ans.numTrades_drawdown++;
           }
     }
  }
//+------------------------------------------------------------------+
//| Создание структуры торговли в течении дня                        |
//+------------------------------------------------------------------+
void CReportCreator::CalcDailyPL(DailyPL &out,DailyPL_calcBy calcBy,const DealDetales &deal)
  {
   cmpDay(deal,MONDAY,out.Mn,calcBy);
   cmpDay(deal,TUESDAY,out.Tu,calcBy);
   cmpDay(deal,WEDNESDAY,out.We,calcBy);
   cmpDay(deal,THURSDAY,out.Th,calcBy);
   cmpDay(deal,FRIDAY,out.Fr,calcBy);
  }
//+------------------------------------------------------------------+
//| Подсчет вспомогательныз данных                                   |
//+------------------------------------------------------------------+
void CReportCreator::CalcData_item(const DealDetales &deal,CalculationData_item &out,
                                   bool isOneLot)
  {
   double pl=(isOneLot ? deal.pl_oneLot : deal.pl_forDeal); //PL
   int n=0;
// Кол - прибылей и убытков
   if(pl>=0)
     {
      out.Total_Profit_numDeals++;
      n=1;
      out.dealsCounter.Counter.DD=0;
      out.dealsCounter.Counter.Profit++;
     }
   else
     {
      out.Total_DD_numDeals++;
      out.dealsCounter.Counter.DD++;
      out.dealsCounter.Counter.Profit=0;
     }
   out.dealsCounter.DD=MathMax(out.dealsCounter.DD,out.dealsCounter.Counter.DD);
   out.dealsCounter.Profit=MathMax(out.dealsCounter.Profit,out.dealsCounter.Counter.Profit);

// Серии из прибылей и убытков
   int s=ArraySize(out.R_arr);
   if(!(s>0 && out.R_arr[s-1]==n))
     {
      ArrayResize(out.R_arr,s+1,s+1);
      out.R_arr[s]=n;
     }

   out.PL+=pl; //PL общий
// Макс Profit / DD
   if(out.Max_DD_forDeal>pl)
     {
      out.Max_DD_forDeal=pl;
      out.DT_Max_DD_forDeal=deal.DT_close;
     }
   if(out.Max_Profit_forDeal<pl)
     {
      out.Max_Profit_forDeal=pl;
      out.DT_Max_Profit_forDeal=deal.DT_close;
     }
// Накопленная Profit / DD
   out.Accomulated_DD+=(pl>0 ? 0 : pl);
   out.Accomulated_Profit+=(pl>0 ? pl : 0);
// Крайние точки по прибыли
   double maxPL=MathMax(out.Max_Profit_byPL,out.PL);
   if(compareDouble(maxPL,out.Max_Profit_byPL)==1/* || !isNot_firstDeal*/)// для созранения даты нужна еще одна проверка
     {
      out.DT_Max_Profit_byPL=deal.DT_close;
      out.Max_Profit_byPL=maxPL;
     }
   double maxDD=out.Max_DD_byPL;
   double DD=0;
   if(out.PL>0)
      DD=out.PL-maxPL;
   else
      DD=-(MathAbs(out.PL)+maxPL);
   maxDD=MathMin(maxDD,DD);
   if(compareDouble(maxDD,out.Max_DD_byPL)==-1/* || !isNot_firstDeal*/)// для созранения даты нужна еще одна проверка
     {
      out.Max_DD_byPL=maxDD;
      out.DT_Max_DD_byPL=deal.DT_close;
     }
   out.DD_percent=(balance>0 ?(MathAbs(DD)/(maxPL>0 ? maxPL : balance)) :(maxPL>0 ?(MathAbs(DD)/maxPL) : 0));
  }
//+------------------------------------------------------------------+
//| Подсчет графиков                                                 |
//+------------------------------------------------------------------+
void CReportCreator::CalcData(const DealDetales &deal,CalculationData &out,bool isBH)
  {
   out.num_deals++; // Подсчет одщего кол - ва сделок
   CalcData_item(deal,out.oneLot,true);
   CalcData_item(deal,out.total,false);

   if(!isBH)
     {
      // Заполняем графики PL
      CalcPL(deal,out,PL.PL_total,_Total);
      CalcPL(deal,out,PL.PL_oneLot,_OneLot);
      CalcPL(deal,out,PL.PL_Indicative,_Indicative);

      // Заполняем графики Гистограмм PL
      CalcPLHist(deal,out,PL_hist.PL_total,_Total);
      CalcPLHist(deal,out,PL_hist.PL_oneLot,_OneLot);
      CalcPLHist(deal,out,PL_hist.PL_Indicative,_Indicative);

      // Заполняем графики PL по дням
      CalcDailyPL(DailyPL_data.absolute_close,CALC_FOR_CLOSE,deal);
      CalcDailyPL(DailyPL_data.absolute_open,CALC_FOR_OPEN,deal);
      CalcDailyPL(DailyPL_data.avarage_close,CALC_FOR_CLOSE,deal);
      CalcDailyPL(DailyPL_data.avarage_open,CALC_FOR_OPEN,deal);

      // Заполняем графики Профит фактора
      ProfitFactor_chart_calc(CoefChart_data.OneLot_ProfitFactor_chart,out,deal,true);
      ProfitFactor_chart_calc(CoefChart_data.Total_ProfitFactor_chart,out,deal,false);

      // Заполняем графики Фактора востановления
      RecoveryFactor_chart_calc(CoefChart_data.OneLot_RecoveryFactor_chart,out,deal,true);
      RecoveryFactor_chart_calc(CoefChart_data.Total_RecoveryFactor_chart,out,deal,false);

      // Заполняем графики коэфицента выигрыша
      WinCoef_chart_calc(CoefChart_data.OneLot_WinCoef_chart,out,deal,true);
      WinCoef_chart_calc(CoefChart_data.Total_WinCoef_chart,out,deal,false);

      // Заполняем графики Коэфицента шарпа
      ShartRatio_chart_calc(CoefChart_data.OneLot_ShartRatio_chart,PL.PL_oneLot,deal/*,out.isNot_firstDeal*/);
      ShartRatio_chart_calc(CoefChart_data.Total_ShartRatio_chart,PL.PL_total,deal/*,out.isNot_firstDeal*/);

      // Заполняем графики Z-счета
      AltmanZScore_chart_calc(CoefChart_data.OneLot_AltmanZScore_chart,(double)out.num_deals,
                              (double)ArraySize(out.oneLot.R_arr),(double)out.oneLot.Total_Profit_numDeals,
                              (double)out.oneLot.Total_DD_numDeals/*,out.isNot_firstDeal*/,deal);
      AltmanZScore_chart_calc(CoefChart_data.Total_AltmanZScore_chart,(double)out.num_deals,
                              (double)ArraySize(out.total.R_arr),(double)out.total.Total_Profit_numDeals,
                              (double)out.total.Total_DD_numDeals/*,out.isNot_firstDeal*/,deal);
     }
   else // Заполняем графики PL Buy and Hold
     {
      CalcPL(deal,out,BH.PL_total,_Total);
      CalcPL(deal,out,BH.PL_oneLot,_OneLot);
      CalcPL(deal,out,BH.PL_Indicative,_Indicative);

      CalcPLHist(deal,out,BH_hist.PL_total,_Total);
      CalcPLHist(deal,out,BH_hist.PL_oneLot,_OneLot);
      CalcPLHist(deal,out,BH_hist.PL_Indicative,_Indicative);
     }

   if(!out.isNot_firstDeal)
      out.isNot_firstDeal=true; // Флаг "Это НЕ первая сделка"
  }
//+------------------------------------------------------------------+
//| Расчет PL                                                        |
//+------------------------------------------------------------------+
void CReportCreator::CalcPL(const DealDetales &deal,CalculationData &data,PLChart_item &pl_out[],CalcType type)
  {
   PLChart_item item;
   ZeroMemory(item);
   item.DT=deal.DT_close; // Созранение даты

   if(type!=_Indicative)
     {
      item.Profit=(type==_Total ? data.total.PL : data.oneLot.PL); // Созранение прибыли
      item.Drawdown=(type==_Total ? data.total.DD_percent : data.oneLot.DD_percent); // Созранение просадки
     }
   else // Расчет индикатиивного графика
     {
      if(data.isNot_firstDeal)
        {
         if(data.total.PL!=0)
           {
            if(data.total.PL > 0 && data.total.Max_DD_forDeal < 0)
               item.Profit=data.total.PL/MathAbs(data.total.Max_DD_forDeal);
            else
               if(data.total.PL<0 && data.total.Max_Profit_forDeal>0)
                  item.Profit=data.total.PL/data.total.Max_Profit_forDeal;
           }
        }
     }
// Добавление данны в массив
   int s=ArraySize(pl_out);
   ArrayResize(pl_out,s+1,s+1);
   pl_out[s]=item;
  }
//+------------------------------------------------------------------+
//| Расчет Гистограммы PL                                            |
//+------------------------------------------------------------------+
void CReportCreator::CalcPLHist(const DealDetales &deal,CalculationData &data,PLChart_item &pl_out[],CalcType type)
  {
   PLChart_item item;
   ZeroMemory(item);
   item.DT=deal.DT_close;

   if(type==_OneLot || type==_Total) // Обычная
     {
      item.Drawdown=MathAbs(type==_OneLot ? data.oneLot.Accomulated_DD : data.total.Accomulated_DD);
      item.Profit=(type==_OneLot ? data.oneLot.Accomulated_Profit : data.total.Accomulated_Profit);
     }
   else // индикативная
     {
      if(data.total.Max_DD_forDeal < 0)
         item.Profit=data.total.Accomulated_Profit/MathAbs(data.total.Max_DD_forDeal);
      if(data.total.Max_Profit_forDeal > 0)
         item.Drawdown=MathAbs(data.total.Accomulated_DD)/data.total.Max_Profit_forDeal;
     }
   int s=ArraySize(pl_out);
   ArrayResize(pl_out,s+1,s+1);
   pl_out[s]=item;
  }
//+------------------------------------------------------------------+
//| Рачет / Пересчет коэфицентов                                     |
//+------------------------------------------------------------------+
void CReportCreator::Create(DealDetales &history[],DealDetales &BH_history[],const double _balance,const string &Symb[],double _r)
  {
   Clear(); // Отчистка данных
// Сохранение баланса
   this.balance=_balance;
   if(this.balance<=0)
     {
      CDealHistoryGetter dealGetter(comission_manager);
      this.balance=dealGetter.getBalance(history[ArraySize(history)-1].DT_open);
     }
   if(this.balance<0)
      this.balance=0;
// Сохранение ставки безриска
   if(_r<0)
      _r=0;
   this.r=r;

// Вспомогательные структуры
   CalculationData data_H,data_BH;
   ZeroMemory(data_H);
   ZeroMemory(data_BH);
// Сортировка истории торгов
   sorter.Method(Sort_Ascending);
   sorter.Sort<DealDetales>(history,&historyComparer);
//Цикл по истории торгов
   for(int i=0; i<ArraySize(history); i++)
     {
      if(isSymb(Symb,history[i].symbol))
         CalcData(history[i],data_H,false);
     }
// Сортировка истории Buy And Hold и цикл по ней
   sorter.Sort<DealDetales>(BH_history,&historyComparer);
   for(int i=0; i<ArraySize(BH_history); i++)
     {
      if(isSymb(Symb,BH_history[i].symbol))
         CalcData(BH_history[i],data_BH,true);
     }

// усредняем дневные PL (усредненного типа)
   avarageDay(DailyPL_data.avarage_close.Mn);
   avarageDay(DailyPL_data.avarage_close.Tu);
   avarageDay(DailyPL_data.avarage_close.We);
   avarageDay(DailyPL_data.avarage_close.Th);
   avarageDay(DailyPL_data.avarage_close.Fr);

   avarageDay(DailyPL_data.avarage_open.Mn);
   avarageDay(DailyPL_data.avarage_open.Tu);
   avarageDay(DailyPL_data.avarage_open.We);
   avarageDay(DailyPL_data.avarage_open.Th);
   avarageDay(DailyPL_data.avarage_open.Fr);

// Заполняем таблицы соотношений прибылей и убытков
   RatioTable_data.OneLot_absolute.Profit=data_H.oneLot.Accomulated_Profit;
   RatioTable_data.OneLot_absolute.Drawdown=data_H.oneLot.Accomulated_DD;
   RatioTable_data.OneLot_max.Profit=data_H.oneLot.Max_Profit_forDeal;
   RatioTable_data.OneLot_max.Drawdown=data_H.oneLot.Max_DD_forDeal;
   RatioTable_data.OneLot_percent.Profit=data_H.oneLot.Total_Profit_numDeals/data_H.num_deals;
   RatioTable_data.OneLot_percent.Drawdown=data_H.oneLot.Total_DD_numDeals/data_H.num_deals;

   RatioTable_data.Total_absolute.Profit=data_H.total.Accomulated_Profit;
   RatioTable_data.Total_absolute.Drawdown=data_H.total.Accomulated_DD;
   RatioTable_data.Total_max.Profit=data_H.total.Max_Profit_forDeal;
   RatioTable_data.Total_max.Drawdown=data_H.total.Max_DD_forDeal;
   RatioTable_data.Total_percent.Profit=data_H.total.Total_Profit_numDeals/data_H.num_deals;
   RatioTable_data.Total_percent.Drawdown=data_H.total.Total_DD_numDeals/data_H.num_deals;

// Подсчет нормального распределения
   NormalPDF_chart_calc(OneLot_PDF_chart,PL.PL_oneLot);
   NormalPDF_chart_calc(Total_PDF_chart,PL.PL_total);

// TotalResult
   CalcTotalResult(data_H,true,TotalResult_data.oneLot);
   CalcTotalResult(data_H,false,TotalResult_data.total);

// PL_detales
   CalcPL_detales(data_H.oneLot,data_H.num_deals,PL_detales_data.oneLot);
   CalcPL_detales(data_H.total,data_H.num_deals,PL_detales_data.total);
  }
//+------------------------------------------------------------------+
//| Рачет / Пересчет коэфицентов                                     |
//+------------------------------------------------------------------+
void CReportCreator::Create(DealDetales &history[],DealDetales &BH_history[],const string &Symb[],double _r)
  {
   CDealHistoryGetter dealGetter(comission_manager);
   double _balance=dealGetter.getBalance(history[ArraySize(history)-1].DT_open);
   Create(history,BH_history,_balance,Symb,_r);
  }
//+------------------------------------------------------------------+
//| Получение дня из даты                                            |
//+------------------------------------------------------------------+
ENUM_DAY_OF_WEEK CReportCreator::getDay(datetime DT)
  {
   MqlDateTime _DT;
   TimeToStruct(DT,_DT);
   return (ENUM_DAY_OF_WEEK)_DT.day_of_week;
  }
//+------------------------------------------------------------------+
//| Рачет / Пересчет коэфицентов                                     |
//+------------------------------------------------------------------+
void CReportCreator::Create(DealDetales &history[],const string &Symb[],const double _balance,double _r)
  {
// Создание истории Buy And Hold по дневному таймфрейму
// 1 запись сделки = 1 день
   DealDetales BH_history[];

   datetime from,till; // Пограничные даты - берутся из реальный истории
   from = history[0].DT_open;
   till = history[ArraySize(history)-1].DT_close;

// Цикл по символам
   for(int i=0; i<ArraySize(Symb); i++)
     {
      double close[]; // Цены закрытия
      datetime closeDT[]; // Даты закрытия
      CopyClose(Symb[i],PERIOD_D1,from,till,close); // Копирование цен закрытия
      CopyTime(Symb[i],PERIOD_D1,from,till,closeDT); // Копирование дат закрытия

      // Цикл по енам закрытия
      for(int j=1; j<ArraySize(close); j++)
        {
         double diff=close[j]-close[j-1];
         double lot = 0;
         for(int n=0; n<ArraySize(history); n++) // Цикл по истории реальной с целью поиска лота
           {
            if(history[n].DT_close>=closeDT[j])
               break;
            if(StringCompare(history[n].symbol,Symb[i])==0)
               lot=MathAbs(history[n].volume);
           }
         // Формирование сделки Buy and Hold
         if(lot==0)
            lot=1;
         DealDetales data;
         data.DT_close=closeDT[j];
         data.DT_open=closeDT[j-1];
         data.close_comment="";
         data.day_close=getDay(closeDT[j]);
         data.day_open=getDay(closeDT[j-1]);
         data.isLong=true;
         data.open_comment="";
         data.pl_forDeal=lot*diff;
         data.pl_oneLot=diff;
         data.price_in=close[j-1];
         data.price_out=close[j];
         data.symbol=Symb[i];
         data.volume=lot;

         // Созранение сделки
         int s=ArraySize(BH_history);
         ArrayResize(BH_history,s+1,s+1);
         BH_history[s]=data;
        }
     }

   Create(history,BH_history,_balance,Symb,_r); // Вызов обработки истории
  }
//+------------------------------------------------------------------+
//| Рачет / Пересчет коэфицентов                                     |
//+------------------------------------------------------------------+
void CReportCreator::Create(DealDetales &history[],double _r)
  {
   string Symb[];
   Get_Symb(history,Symb);
   CDealHistoryGetter dealGetter(comission_manager);
   double _balance=dealGetter.getBalance(history[ArraySize(history)-1].DT_open);
   Create(history,Symb,_balance,_r);
  }
//+------------------------------------------------------------------+
//| Рачет / Пересчет коэфицентов                                     |
//+------------------------------------------------------------------+
bool CReportCreator::Create(const string &Symb[],double _r)
  {
   DealDetales history[];
   CDealHistoryGetter dealGetter(comission_manager);
   if(!dealGetter.getDealsDetales(history,0,TimeCurrent()))
      return false;
   double _balance=dealGetter.getBalance(history[ArraySize(history)-1].DT_open);
   Create(history,Symb,_balance,_r);

   return true;
  }
//+------------------------------------------------------------------+
//| Рачет / Пересчет коэфицентов                                     |
//+------------------------------------------------------------------+
bool CReportCreator::Create(double _r=0)
  {
   DealDetales history[];
   CDealHistoryGetter dealGetter(comission_manager);
   if(!dealGetter.getDealsDetales(history,0,TimeCurrent()))
      return false;
   string Symb[];
   Get_Symb(history,Symb);
   double _balance=dealGetter.getBalance(history[ArraySize(history)-1].DT_open);
   Create(history,Symb,_balance,_r);

   return true;
  }
//+------------------------------------------------------------------+
//| Получение уникальных символов из переданной истории              |
//+------------------------------------------------------------------+
void CReportCreator::Get_Symb(const DealDetales &history[],string &Symb[])
  {
   ArrayFree(Symb); // Освобожждение массива символов
   for(int i=0; i<ArraySize(history); i++) // Цикл по истории
     {
      bool isAdd=true;
      for(int n=0; n<ArraySize(Symb); n++) // Цикл по имеющимся значениям
        {
         if(StringCompare(Symb[n],history[i].symbol)==0)
           {
            isAdd=false; // Флаг говорящий что данное значение уже встречалось
            break;
           }
        }
      if(isAdd)// Добавление нового, уникального значения
        {
         int s=ArraySize(Symb);
         ArrayResize(Symb,s+1,s+1);
         Symb[s]=history[i].symbol;
        }
     }
  }
//+------------------------------------------------------------------+

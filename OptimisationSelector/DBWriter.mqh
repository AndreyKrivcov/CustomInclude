//+------------------------------------------------------------------+
//|                                                Sqlite_writer.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Sqlite3/SqliteManager.mqh>
#include <Sqlite3/SqliteReader.mqh>
#include <History manager/ReportCreator.mqh>
#include <WinApi/Mutex.mqh>
#include "DataKeeper.mqh"
//+------------------------------------------------------------------+
//| Коллбек расчитывающий пользовательский коэфицент                 |
//| На вход передаются данные истории и флаг для акого типа истории  |
//| требуется расчет коэфицента                                      |
//+------------------------------------------------------------------+
typedef double(*customScoring_1)(const DealDetales &history[],bool isOneLot);
//+------------------------------------------------------------------+
//| Коллбек расчитывающий пользовательский коэфицент                 |
//| На вход передаются подключение к базе данных (только чтение)     |
//| история, флаг типа запрашиваемого коэфицента                     |
//+------------------------------------------------------------------+
typedef double(*customScoring_2)(CSqliteManager *dbManager,const DealDetales &history[],bool isOneLot);
//+------------------------------------------------------------------+
//| Класс сохраняющий данные в базе и создающий базу перед этим      |
//+------------------------------------------------------------------+
class CDBWriter
  {
public:
   // Вызывать в OnInit одну из перегрузок
   void              OnInitEvent(const string DBPath,const CDataKeeper &inputData_array[],customScoring_1 scoringFunction,double r,ENUM_TIMEFRAMES TF=PERIOD_CURRENT); // коллбек №1
   void              OnInitEvent(const string DBPath,const CDataKeeper &inputData_array[],customScoring_2 scoringFunction,double r,ENUM_TIMEFRAMES TF=PERIOD_CURRENT); // Коллбек №2
   void              OnInitEvent(const string DBPath,const CDataKeeper &inputData_array[],double r,ENUM_TIMEFRAMES TF=PERIOD_CURRENT);// Без коллбека, и пользовательского коэфицента (равен нулю)
   double            OnTesterEvent();// Вызывать в OnTester
   void              OnTickEvent();// Вызывать в OnTick

private:
   CSqliteManager    dbManager; // Коннектор к базе
   CDataKeeper       coef_array[]; // Входные параметры
   datetime          DT_Border; // Дата самой последней свечи (вычисляется в OnTickEvent)
   double            r; // Безриск

   customScoring_1   scoring_1; // Коллбек
   customScoring_2   scoring_2; // Коллбек
   int               scoring_type; // Тип коллбека [1,2]
   string            DBPath; // Путь к базе 
   double            balance; // Баланс
   ENUM_TIMEFRAMES   TF; // Таймфрейм

   void              CreateDB(const string DBPath,const CDataKeeper &inputData_array[],double r,ENUM_TIMEFRAMES TF);// Создается база ивсе прилагающееся
   bool              isForvard();// Определение типа текущей оптимизации (историческая / форвардная)
   void              WriteLog(string s,string where);//Запись лог файла

   int               setParams(bool IsForvard,CReportCreator *reportCreator,DealDetales &history[],double &customCoef);//Заполнение таблицы входных параметров
   void              setBuyAndHold(bool IsForvard,CReportCreator *reportCreator);//Заполнение истории BuyAnd Hold
   bool              setTraidingHistory(bool IsForvard,DealDetales &history[],int ID);//Заполнение истории торгов
   bool              setTotalResult(TotalResult &coefData,bool isOneLot,long ID,bool IsForvard,double customCoef);//Заполнение таблицы с коэфицентами
   bool              isHistoryItem(bool IsForvard,DealDetales &item,int ID); // Проверка существуют ли уже эти параметры в таблице истории торгов или же нет

  };
//+------------------------------------------------------------------+
//| Проверка существования сделки в таблице торгов                   |
//+------------------------------------------------------------------+
bool CDBWriter::isHistoryItem(bool IsForvard,DealDetales &item,int ID)
  {
   string s="SELECT Count(*) FROM TradingHistory WHERE (ID="+IntegerToString(ID)+
            " AND Symbol='"+item.symbol+
            "' AND DT_open="+(string)(long)item.DT_open+
            " AND DT_close="+(string)(long)item.DT_close+");"; // Формирование запроса
   CStatement stmt(dbManager.Create_statement(s)); // Создание запроса
   CSqliteReader reader(stmt.get()); // Создание ридера
   reader.Read();
   return reader.GetInt64(0)>0; // Проверка условия
  }
//+------------------------------------------------------------------+
//| Установка значения истории Buy and Hold                          |
//+------------------------------------------------------------------+
void CDBWriter::setBuyAndHold(bool IsForvard,CReportCreator *reportCreator)
  {
   CStatement stmt(dbManager.Create_statement("INSERT OR IGNORE INTO BuyAndHold VALUES (@Time,@PL_total,@PL_oneLot,@DD_total,@DD_oneLot,@isForvard);")); // Запрос на вставку значений
   PLChart_item BH_history_total[],BH_history_oneLot[]; // Струры с данными
   if(reportCreator.GetChart(_BH,_Total,BH_history_total) &&
      reportCreator.GetChart(_BH,_OneLot,BH_history_oneLot)) // Получаем данные и за раз проверяем их наличие
     {
      // В цикле перебираем элементы Buy And Hold
      for(int i=0;i<ArraySize(BH_history_total);i++)
        {
         // Заполняем запрос данными
         stmt.Parameter(1,(long)BH_history_total[i].DT);
         stmt.Parameter(2,BH_history_total[i].Profit);
         stmt.Parameter(3,BH_history_oneLot[i].Profit);
         stmt.Parameter(4,BH_history_total[i].Drawdown);
         stmt.Parameter(5,BH_history_oneLot[i].Drawdown);
         stmt.Parameter(6,(IsForvard ? 1 : 0));
         if(!stmt.Execute()) // Отправляем данные и пишем в лог в лучае ошибки
           {
            string s="Can`t insert value | INSERT OR IGNORE INTO BuyAndHold VALUES ("+
                     ","+(string)BH_history_total[i].DT+
                     ","+DoubleToString(BH_history_total[i].Profit)+
                     ","+DoubleToString(BH_history_oneLot[i].Profit)+
                     ","+DoubleToString(BH_history_total[i].Drawdown)+
                     ","+DoubleToString(BH_history_oneLot[i].Drawdown)+
                     ","+IntegerToString((IsForvard ? 1 : 0))+");";
            Print(s);
            WriteLog(s,"Line: "+(string)__LINE__+" Function: "+__FUNCTION__);
           }
        };
     }
   else // Пишем в лог если не смогли заполнить данные Buy And Hold 
     {
      string s="Buy And Hold history was`n created!";
      Print(s);
      WriteLog(s,"Line: "+(string)__LINE__+" Function: "+__FUNCTION__);
     }
  }
//+------------------------------------------------------------------+
//| Заполнение таблицы с коэфицентами                                |
//+------------------------------------------------------------------+
int CDBWriter::setParams(bool IsForvard,CReportCreator *reportCreator,DealDetales &history[],double &customCoef)
  {
   int ID=0;
   bool isExist=IsForvard;

   CStatement stmt;
   CSqliteReader reader;
// Проверка на существование записи если текущий период не является форвардным.
   if(!isExist)
     {
      string query="SELECT Count(*) FROM OptimisationParams WHERE (TF="+(string)(int)TF+" AND ";
      for(int i=0;i<ArraySize(coef_array);i++)
        {
         query+=coef_array[i].getName()+"="+coef_array[i].ToString();
         if(i<ArraySize(coef_array)-1)
            query+=" AND ";
        }
      query+=");"; // Формируем запрос
      stmt.set(dbManager.Create_statement(query)); // Создаем запрос
      reader.set(stmt.get()); // Создаем ридер

      if(reader.Read())
         isExist=reader.GetInt64(0)>0; // Проверяем условие
     }

   if(!isExist || IsForvard) // Заносим в базу если (либо новое значение либо форвардное)
     {
      // set Params
      string query="INSERT INTO OptimisationParams(HistoryBorder,TF,";
      string query_2="SELECT ID FROM OptimisationParams WHERE (TF="+(string)(int)TF+" AND ";
      string s;
      for(int i=0;i<ArraySize(coef_array);i++)
        {
         if(!IsForvard)query+=coef_array[i].getName();
         query_2+=coef_array[i].getName()+"="+coef_array[i].ToString();
         if(!IsForvard)s+=coef_array[i].ToString();

         if(i<ArraySize(coef_array)-1)
           {
            if(!IsForvard)query+=",";
            query_2+=" AND ";
            if(!IsForvard)s+=",";
           }
        }

      if(!IsForvard)query+=", InitalBalance) VALUES ("+(string)(long)DT_Border+","+(string)(int)TF+","+s+","+DoubleToString(balance)+");"; // Формируем запрос на вставку
      query_2+=");"; // Формируем запрос на получение ID
      if((!IsForvard && dbManager.Execute(query)) || IsForvard) // Если вставка удалась, или же форвардный период (в таком случае не вставляемзначение) 
        {
         stmt.set(dbManager.Create_statement(query_2)); // Создаем запрос на выбор ID
         reader.set(stmt.get()); // Создаем Ридер

         if(reader.Read()) // Если есть возвращаемое значение
           {
            ID=(int)reader.GetInt64(0); // Читаем ID 

            customCoef=0;
            double customCoef_1Lot=0;

            if(scoring_type==1) // Расчитываем коэфицент по первому коллбеку
              {
               customCoef=scoring_1(history,false);
               customCoef_1Lot=scoring_1(history,true);
              }
            if(scoring_type==2) // Расчитываем коэфицент по второму коллбеку
              {
               CSqliteManager dbManager_readOnly;
               dbManager_readOnly.Connect(DBPath,SQLITE_OPEN_READONLY|SQLITE_OPEN_NOMUTEX|SQLITE_OPEN_SHAREDCACHE,NULL);
               customCoef=scoring_2(&dbManager_readOnly,history,false);
               customCoef_1Lot=scoring_2(&dbManager_readOnly,history,true);
              }

            TotalResult coefData;
            if(reportCreator.GetTotalResult(coefData)) // Получаем таблицу с коэфицентами
              {
               if(!setTotalResult(coefData,true,ID,IsForvard,customCoef_1Lot)) // Заполняем таблицу с коэфицентами для одного лота
                  return 0;
               if(!setTotalResult(coefData,false,ID,IsForvard,customCoef)) // Заполняем таблицу с коэфицентами для реального лота
                  return 0;
              }
           }
         else
            customCoef=0; // Если не получилось заполнить таблицы - коэфицент пользовательский приравниваем к нулю
        }
     }
   return ID; // В случае успеха - возвращаем ID
  }
//+------------------------------------------------------------------+
//| Заполнение таблицы с коэфицентами                                |
//+------------------------------------------------------------------+
bool  CDBWriter::setTotalResult(TotalResult &coefData,bool isOneLot,long ID,bool IsForvard,double customCoef)
  {
// Создание запроса
   CStatement stmt(dbManager.Create_statement("INSERT INTO ParamsCoefitients VALUES (@ID,@isForvard,@isOneLot,@PL,@DD,@averagePL,@averageDD,"+
                   "@averageProfit,@profitFactor,@recoveryFactor,@sharpRatio,@altman_Z_Score,@VaR_absolute_90,@VaR_absolute_95,@VaR_absolute_99, "+
                   "@VaR_growth_90,@VaR_growth_95,@VaR_growth_99,@winCoef,@customCoef);"));
// Удаление уз базы ранеезанесенный такой же строки (если была)
   dbManager.Execute("DELETE FROM ParamsCoefitients WHERE (ID="+IntegerToString(ID)+" AND isForvard = "+(IsForvard ? "1" : "0")+" AND isOneLot = "+(isOneLot ? "1" : "0")+");");
// Заполнение запроса
   stmt.Parameter(1,ID);
   stmt.Parameter(2,(IsForvard ? 1 : 0));
   stmt.Parameter(3,(isOneLot ? 1 : 0));
   stmt.Parameter(4,(isOneLot ? coefData.oneLot.PL : coefData.total.PL));
   stmt.Parameter(5,(isOneLot ? coefData.oneLot.maxDrawdown.byPL : coefData.total.maxDrawdown.byPL));
   stmt.Parameter(6,(isOneLot ? coefData.oneLot.averagePL : coefData.total.averagePL));
   stmt.Parameter(7,(isOneLot ? coefData.oneLot.averageDD : coefData.total.averageDD));
   stmt.Parameter(8,(isOneLot ? coefData.oneLot.averageProfit : coefData.total.averageProfit));
   stmt.Parameter(9,(isOneLot ? coefData.oneLot.profitFactor : coefData.total.profitFactor));
   stmt.Parameter(10,(isOneLot ? coefData.oneLot.recoveryFactor : coefData.total.recoveryFactor));
   stmt.Parameter(11,(isOneLot ? coefData.oneLot.sharpRatio : coefData.total.sharpRatio));
   stmt.Parameter(12,(isOneLot ? coefData.oneLot.altman_Z_Score : coefData.total.altman_Z_Score));
   stmt.Parameter(13,(isOneLot ? coefData.oneLot.VaR_absolute.VAR_90 : coefData.total.VaR_absolute.VAR_90));
   stmt.Parameter(14,(isOneLot ? coefData.oneLot.VaR_absolute.VAR_95 : coefData.total.VaR_absolute.VAR_95));
   stmt.Parameter(15,(isOneLot ? coefData.oneLot.VaR_absolute.VAR_99 : coefData.total.VaR_absolute.VAR_99));
   stmt.Parameter(16,(isOneLot ? coefData.oneLot.VaR_growth.VAR_90 : coefData.total.VaR_growth.VAR_90));
   stmt.Parameter(17,(isOneLot ? coefData.oneLot.VaR_growth.VAR_95 : coefData.total.VaR_growth.VAR_95));
   stmt.Parameter(18,(isOneLot ? coefData.oneLot.VaR_growth.VAR_99 : coefData.total.VaR_growth.VAR_99));
   stmt.Parameter(19,(isOneLot ? coefData.oneLot.winCoef : coefData.total.winCoef));
   stmt.Parameter(20,customCoef);
   if(!stmt.Execute()) // Занесение данных в базу
     {
      // Записьлога в случае ошибки
      string s="Can`t insert valuies | INSERT INTO ParamsCoefitients VALUES ("+
               IntegerToString(ID)+
               ","+IntegerToString(IsForvard ? 1 : 0)+
               ","+IntegerToString(isOneLot ? 1 : 0)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.PL : coefData.total.PL)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.maxDrawdown.byPL : coefData.total.maxDrawdown.byPL)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.averagePL : coefData.total.averagePL)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.averageDD : coefData.total.averageDD)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.averageProfit : coefData.total.averageProfit)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.profitFactor : coefData.total.profitFactor)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.recoveryFactor : coefData.total.recoveryFactor)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.sharpRatio : coefData.total.sharpRatio)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.altman_Z_Score : coefData.total.altman_Z_Score)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.VaR_absolute.VAR_90 : coefData.total.VaR_absolute.VAR_90)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.VaR_absolute.VAR_95 : coefData.total.VaR_absolute.VAR_95)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.VaR_absolute.VAR_99 : coefData.total.VaR_absolute.VAR_99)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.VaR_growth.VAR_90 : coefData.total.VaR_growth.VAR_90)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.VaR_growth.VAR_95 : coefData.total.VaR_growth.VAR_95)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.VaR_growth.VAR_99 : coefData.total.VaR_growth.VAR_99)+
               ","+DoubleToString(isOneLot ? coefData.oneLot.winCoef : coefData.total.winCoef)+
               ","+DoubleToString(customCoef)+");";
      WriteLog(s,"Line: "+(string)__LINE__+" Function: "+__FUNCTION__);
      Print(s);
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Проверка форвардная ли текущая история                           |
//+------------------------------------------------------------------+
bool CDBWriter::isForvard()
  {
   bool ans=false;
   string query="SELECT HistoryBorder FROM OptimisationParams WHERE (TF="+(string)(int)TF+" AND ";
   for(int i=0;i<ArraySize(coef_array);i++)
     {
      query+=coef_array[i].getName()+"="+coef_array[i].ToString();
      if(i<ArraySize(coef_array)-1)
         query+=" AND ";
     }
   query+=");"; // Создание запроса на получение созраненной даты
   CStatement stmt_params_check(dbManager.Create_statement(query)); // Создание запроса
   CSqliteReader reader(stmt_params_check.get()); // Создание ридера
   ans=(reader.Read() && ((datetime)reader.GetInt64(0)<DT_Border)); // Проверка условия

   return ans;
  }
//+------------------------------------------------------------------+
//| Создание базы и инициализация класса                             |
//+------------------------------------------------------------------+
void CDBWriter::CreateDB(const string _DBPath,const CDataKeeper &inputData_array[],double _r,ENUM_TIMEFRAMES _TF)
  {
// Созранение безрисковойставки и Таймфрейса
   this.r=_r;
   if(_TF!=PERIOD_CURRENT)
      this.TF=_TF;
   else
      this.TF=Period();

// Сохранение коэфицентов
   ArrayResize(coef_array,ArraySize(inputData_array));
   for(int i=0;i<ArraySize(inputData_array);i++)
      coef_array[i]=inputData_array[i];

// Подключение к базе
   this.DBPath=_DBPath;
   dbManager.Connect(DBPath,SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE|SQLITE_OPEN_NOMUTEX|SQLITE_OPEN_SHAREDCACHE,NULL);

// Создаем Мьютекс и блокируем
   CMutexSync sync; // сам объект синронизации 
   if(!sync.Create(getMutexName(DBPath))) { Print(Symbol()+" MutexSync create ERROR!"); return; }
   CMutexLock lock(sync,(DWORD)INFINITE); // лочим участок в этих скобках

                                          // Создание таблиц если те ранее не были созданы
   string query[5];
   dbManager.Execute("PRAGMA foreign_keys = ON;");
   query[0]="CREATE TABLE IF NOT EXISTS OptimisationParams (ID INTEGER PRIMARY KEY AUTOINCREMENT, HistoryBorder INTEGER, TF INTEGER";
   for(int i=0;i<ArraySize(coef_array);i++)
     {
      query[0]+=","+coef_array[i].getName();
      switch(coef_array[i].getType())
        {
         case Type_INTEGER : query[0]+=" INTEGER"; break;
         case Type_REAL : query[0]+= " REAL"; break;
         case Type_Text : query[0]+= " TEXT"; break;
        }
     }
   query[0]+=", InitalBalance REAL);";
   query[1]="CREATE TABLE IF NOT EXISTS ParamsType (ParamName TEXT NOT NULL UNIQUE, ParamType INTEGER);";
   query[2]="CREATE TABLE IF NOT EXISTS TradingHistory(ID	INTEGER NOT NULL REFERENCES OptimisationParams(ID),"+
            "isForvard	INTEGER NOT NULL CHECK(isForvard = 0 or isForvard = 1),Symbol	TEXT NOT NULL,DT_open	NUMERIC NOT NULL,"+
            "Day_open	NUMERIC NOT NULL,DT_close	INTEGER NOT NULL,Day_close	INTEGER NOT NULL,Volume	REAL NOT NULL,"+
            "isLong	INTEGER NOT NULL CHECK(isForvard = 0 or isForvard = 1),Price_in	REAL NOT NULL,Price_out	REAL NOT NULL,"+
            "PL_oneLot	REAL,PL_forDeal	REAL,OpenComment	TEXT,CloseComment	TEXT);";
   query[3]="CREATE TABLE IF NOT EXISTS BuyAndHold(Time	INTEGER NOT NULL UNIQUE,PL_total	REAL,PL_oneLot	REAL,DD_total REAL,"+
            "DD_oneLot REAL,isForvard	INTEGER CHECK(isForvard = 0 or isForvard = 1));";
   query[4]="CREATE TABLE IF NOT EXISTS ParamsCoefitients(ID	INTEGER NOT NULL REFERENCES OptimisationParams(ID),"+
            "isForvard INTEGER NOT NULL CHECK(isForvard = 0 or isForvard = 1),"+
            "isOneLot NOT NULL CHECK(isForvard = 0 or isForvard = 1),"
            "PL REAL, DD REAL, averagePL REAL, averageDD REAL, averageProfit REAL, profitFactor REAL, recoveryFactor REAL, sharpRatio REAL, "+
            "altman_Z_Score REAL, VaR_absolute_90 REAL, VaR_absolute_95 REAL, VaR_absolute_99 REAL, "+
            "VaR_growth_90 REAL, VaR_growth_95 REAL, VaR_growth_99 REAL, winCoef REAL,customCoef REAL);";

// Исполнение запросов поочередно через транзакцию
   dbManager.BeginTransaction();
   bool cond=true;
   for(int i=0;i<ArraySize(query);i++)
     {
      cond=dbManager.Execute(query[i]);
      if(!cond)
        {
         Print("Cant execute sqlwuery: "+query[i]);
         break;
        }
     }
   if(cond)dbManager.CommitTransaction();
   else dbManager.RollbackTransaction();

// Заболнение баланса и текущей даты
   balance=AccountInfoDouble(ACCOUNT_BALANCE);
   DT_Border=TimeCurrent();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
bool CDBWriter::ClearDB()
  {
   CMutexSync sync; // сам объект синронизации 
   if(!sync.Create(getMutexName(DBPath))) { Print(Symbol()+" MutexSync create ERROR!"); return false; }
   CMutexLock lock(sync,(DWORD)INFINITE); // лочим участок в этих скобках

   return dbManager.Execute("DELETE FROM TradingHistory;"+
                            "DELETE FROM ParamsCoefitients;"+
                            "DELETE FROM ParamsType;"+
                            "DELETE FROM BuyAndHold;"+
                            "DELETE FROM OptimisationParams;"+
                            "DELETE FROM sqlite_sequence;");
  }
  */
//+------------------------------------------------------------------+
//| Создание базы и подключея                                        |
//+------------------------------------------------------------------+
void CDBWriter::OnInitEvent(const string _DBPath,const CDataKeeper &inputData_array[],customScoring_2 scoringFunction,double _r,ENUM_TIMEFRAMES _TF)
  {
   CreateDB(_DBPath,inputData_array,_r,_TF);
   scoring_2=scoringFunction;
   scoring_type=2;
  }
//+------------------------------------------------------------------+
//| Создание базы и подключения                                      |
//+------------------------------------------------------------------+
void CDBWriter::OnInitEvent(const string _DBPath,const CDataKeeper &inputData_array[],customScoring_1 scoringFunction,double _r,ENUM_TIMEFRAMES _TF)
  {
   CreateDB(_DBPath,inputData_array,_r,_TF);
   scoring_1=scoringFunction;
   scoring_type=1;
  }
//+------------------------------------------------------------------+
//| Создание базыи подключения                                       |
//+------------------------------------------------------------------+
void CDBWriter::OnInitEvent(const string _DBPath,const CDataKeeper &inputData_array[],double _r,ENUM_TIMEFRAMES _TF)
  {
   CreateDB(_DBPath,inputData_array,_r,_TF);
   scoring_type=0;
  }
//+------------------------------------------------------------------+
//| Получение дня из даты                                                                 |
//+------------------------------------------------------------------+
ENUM_DAY_OF_WEEK getDay(datetime DT)
  {
   MqlDateTime _DT;
   TimeToStruct(DT,_DT);
   return (ENUM_DAY_OF_WEEK)_DT.day_of_week;
  }
//+------------------------------------------------------------------+
//| Cохранение всех данных в базе и возврат                          |
//| пользовательского коэфицента                                     |
//+------------------------------------------------------------------+
double CDBWriter::OnTesterEvent()
  {

   DealDetales history[];

   CDealHistoryGetter historyGetter;
   historyGetter.getDealsDetales(history,0,TimeCurrent()); // ПОлучение истории торгов

   CMutexSync sync; // сам объект синронизации 
   if(!sync.Create(getMutexName(DBPath))) { Print(Symbol()+" MutexSync create ERROR!"); return 0; }
   CMutexLock lock(sync,(DWORD)INFINITE); // лочим участок в этих скобках

   bool IsForvard=isForvard(); // Узнаем является ли текущая итеррация тестера - форвардной
   CReportCreator rc;
   string Symb[];
   rc.Get_Symb(history,Symb); // Получаем список символов
   rc.Create(history,Symb,balance,r); // Создаем отчет (отчет Buy And Hold - создается самостоятельно)

   double ans=0;
   dbManager.BeginTransaction(); // Начало транзакции

   CStatement stmt(dbManager.Create_statement("INSERT OR IGNORE INTO ParamsType VALUES(@ParamName,@ParamType);")); // Запрос на сохранение списка типов параметров робота
   if(stmt.get()!=NULL)
     {
      for(int i=0;i<ArraySize(coef_array);i++)
        {
         stmt.Parameter(1,coef_array[i].getName());
         stmt.Parameter(2,(int)coef_array[i].getType());
         stmt.Execute(); // сохраняем типы параметров и из наименования
        }
     }

   int ID=setParams(IsForvard,&rc,history,ans); // Сохраняем параметры робота, оценочные коэфиценты и получаем ID
   if(ID>0)// Если ID > 0 то параметры сохранены успешно 
     {
      if(setTraidingHistory(IsForvard,history,ID)) // Созраняем торговую историю и проверяем созранилась ли она
        {
         setBuyAndHold(IsForvard,&rc); // Сохраняем историю Buy And Hold (созранится лишь раз - во время первого созранения)
         dbManager.CommitTransaction(); // ПОдтверждаем завершение транзакции
        }
      else
        {
         dbManager.RollbackTransaction(); // Иначе - отменяем транзакцию
         WriteLog("Rollback Transaction","CDBWriter::OnTesterEvent");
        }
     }
   else
     {
      dbManager.RollbackTransaction(); // Иначе отменяем транзакцию
      WriteLog("Rollback Transaction","CDBWriter::OnTesterEvent");
     }

   return ans;
  }
//+------------------------------------------------------------------+
//| Собылие вызываемое при каждом тике - сохраняем последнюю дату    |
//| которая была доступна                                            |
//+------------------------------------------------------------------+
void CDBWriter::OnTickEvent(void)
  {
   datetime time[];
   CopyTime(_Symbol,PERIOD_M1,0,1,time);
   DT_Border=time[0];
  }
//+------------------------------------------------------------------+
//| Созранение торговой истории                                      |
//+------------------------------------------------------------------+
bool CDBWriter::setTraidingHistory(bool IsForvard,DealDetales &history[],int ID)
  {
   CStatement stmt(dbManager.Create_statement("INSERT INTO TradingHistory VALUES(@ID,@isForvard,@Symbol,@DT_open,@Day_open,@DT_close,@Day_close,@Volume,"+
                   "@isLong,@Price_in,@Price_out,@PL_oneLot,@PL_forDeal,@OpenComment,@CloseComment);")); // Запрос на созранение истории

   bool ans=false; // Флаг бала ли созранена хоть одна строка.
   for(int i=0;i<ArraySize(history);i++)
     {
      bool isExecuted=false;

      if(!isHistoryItem(IsForvard,history[i],ID))
        {
         // Присвоение параметров
         stmt.Parameter(1,ID);
         stmt.Parameter(2,(IsForvard ? 1 : 0));
         stmt.Parameter(3,history[i].symbol);
         stmt.Parameter(4,(long)history[i].DT_open);
         stmt.Parameter(5,(int)history[i].day_open);
         stmt.Parameter(6,(long)history[i].DT_close);
         stmt.Parameter(7,(int)history[i].day_close);
         stmt.Parameter(8, history[i].volume);
         stmt.Parameter(9,(history[i].isLong ? 1 : 0));
         stmt.Parameter(10,history[i].price_in);
         stmt.Parameter(11,history[i].price_out);
         stmt.Parameter(12,history[i].pl_oneLot);
         stmt.Parameter(13,history[i].pl_forDeal);
         stmt.Parameter(14,history[i].open_comment);
         stmt.Parameter(15,history[i].close_comment);
         isExecuted=stmt.Execute();// Исполняем
         if(!ans && isExecuted)// Если исполнили то флаг равен true  
            ans=true;
        }

      if(!isExecuted) // Если не исполнили, то пишем Лог файл
        {
         string s="Can`t insert valuies | INSERT INTO TradingHistory VALUES("+
                  IntegerToString(ID)+","+IntegerToString(IsForvard ? 1 : 0)+","+
                  "'"+history[i].symbol+"',"+
                  (string)history[i].DT_open+","+
                  (string)(int)history[i].day_open+","+
                  (string)history[i].DT_close+","+
                  (string)history[i].day_close+","+
                  DoubleToString(history[i].volume)+","+
                  IntegerToString(history[i].isLong ? 1 : 0)+","+
                  DoubleToString(history[i].price_in)+","+
                  DoubleToString(history[i].price_out)+","+
                  DoubleToString(history[i].pl_oneLot)+","+
                  DoubleToString(history[i].pl_forDeal)+","+
                  "'"+history[i].open_comment+"',"+
                  "'"+history[i].close_comment+"');";
         WriteLog(s,"Line: "+(string)__LINE__+" Function: "+__FUNCTION__);
         Print(s);
        }
     }
   return ans;
  }
//+------------------------------------------------------------------+
//| Запись в Логи файл.                                              |
//+------------------------------------------------------------------+
void CDBWriter::WriteLog(string s,string where)
  {
   string fileName="Log file "+MQLInfoString(MQL_PROGRAM_NAME)+"_"+EnumToString(Period())+"_"+_Symbol+".csv"; // Формируем название файла
   bool isFile=FileIsExist(fileName,FILE_COMMON); // Флаг существует ли файл
   int file_handle=FileOpen(fileName,FILE_READ|FILE_WRITE|FILE_CSV|FILE_COMMON|FILE_SHARE_WRITE|FILE_SHARE_READ); // Открываем файл
   if(file_handle) // Если файл открылся
     {
      FileSeek(file_handle,0,SEEK_END); // Перемещаем курсор в конец файла
      if(!isFile) // Еси это новосозданный фай - пишем заголовок
         FileWrite(file_handle,"Time;Error point;Msg");
      string Msg=TimeToString(DT_Border)+";"+where+";"+s; // Формируем сообщение
      FileWrite(file_handle,Msg); // Пишем сообщение
      FileClose(file_handle); // Закрываем файл
     }
  }
//+------------------------------------------------------------------+

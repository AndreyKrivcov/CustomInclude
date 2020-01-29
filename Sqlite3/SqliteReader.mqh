//+------------------------------------------------------------------+
//|                                                 SqliteReader.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "sqlite_amalgmation.mqh"
#include <WinApi/memcpy.mqh>
//+------------------------------------------------------------------+
//| Класс читающий ответы от баз                                     |
//+------------------------------------------------------------------+
class CSqliteReader
  {
public:
                     CSqliteReader(){statement=NULL;} // пустой конструктор
                     CSqliteReader(sqlite3_stmt_p64 _statement) { this.statement=_statement; }; // Конструктор принимающий указатель на стейтмент
                     CSqliteReader(CSqliteReader  &other) : statement(other.statement) {} // Конструктор копирования
                    ~CSqliteReader() { Sqlite3_reset(statement); } // Деструктор

   void              set(sqlite3_stmt_p64 _statement); // Добавить ссылку на стейтмент
   void operator=(CSqliteReader  &other){statement=other.statement;}// Оператор присвоения Ридера
   void operator=(sqlite3_stmt_p64 _statement) {set(_statement);}// Оператор присвоения cтейтмента

   bool              Read(); // Чтение строки
   int               FieldsCount(); // Подсчет ко - ва столбцов
   int               ColumnType(int col); // Полечение типа колонки

   bool              IsNull(int col); // Проверка является ли значение == SQLITE_NULL
   long              GetInt64(int col); // Конвертация в int
   double            GetDouble(int col);// Конвертация в double
   string            GetText(int col);// Конвертация в string

private:
   sqlite3_stmt_p64  statement; // указатель на стейтмент
  };
//+------------------------------------------------------------------+
//| Добавить ссылку на стейтмент                                     |
//+------------------------------------------------------------------+
void CSqliteReader::set(long _statement)
  {
   if(this.statement!=NULL)
      Sqlite3_reset(this.statement);
   this.statement=_statement;
  }
//+------------------------------------------------------------------+
//| Чтение строки                                                    |
//+------------------------------------------------------------------+
bool CSqliteReader::Read(void)
  {
   int rc= Sqlite3_step(statement);
   if(rc == SQLITE_OK|| rc == SQLITE_DONE)
     {
      if(rc==SQLITE_DONE)
         Sqlite3_reset(statement);
      return false;
     }
   else if(rc==SQLITE_ROW)
      return true;
   else
      printErrorStatus(rc);
   return false;
  }
//+------------------------------------------------------------------+
//| Подсчет кол - ва столбцов                                        |
//+------------------------------------------------------------------+
int CSqliteReader::FieldsCount(void)
  {
   return Sqlite3_column_count(statement);
  }
//+------------------------------------------------------------------+
//| Получение типа колонки                                           |
//+------------------------------------------------------------------+
int CSqliteReader::ColumnType(int col)
  {
   return Sqlite3_column_type(statement, col);
  }
//+------------------------------------------------------------------+
//| Проверка является ли ячейка == SQLITE_NULL                       |
//+------------------------------------------------------------------+
bool CSqliteReader::IsNull(int col)
  {
   return ColumnType(col) == SQLITE_NULL;
  }
//+------------------------------------------------------------------+
//| Поление long параметра                                           |
//+------------------------------------------------------------------+
long CSqliteReader::GetInt64(int col)
  {
   return Sqlite3_column_int64(statement, col);
  }
//+------------------------------------------------------------------+
//| Получение double параметра                                       |
//+------------------------------------------------------------------+
double CSqliteReader::GetDouble(int col)
  {
   return Sqlite3_column_double(statement, col);
  }
//+------------------------------------------------------------------+
//| Получение String параметра                                       |
//+------------------------------------------------------------------+
string CSqliteReader::GetText(int col)
  {
   uchar dst[];
   PTR64 ptr=Sqlite3_column_text(statement,col);
   int bytes= Sqlite3_column_bytes(statement,col);
   ArrayResize(dst,bytes);
   memcpy(dst,ptr,bytes);

   return CharArrayToString(dst);
  }

//+------------------------------------------------------------------+

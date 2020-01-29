//+------------------------------------------------------------------+
//|                                           sqlite_amalgmation.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#define SQLITE_OK           0   /* Successful result */

/* beginning-of-error-codes */

#define SQLITE_ERROR        1   /* Generic error */
#define SQLITE_INTERNAL     2   /* Internal logic error in SQLite */
#define SQLITE_PERM         3   /* Access permission denied */
#define SQLITE_ABORT        4   /* Callback routine requested an abort */
#define SQLITE_BUSY         5   /* The database file is locked */
#define SQLITE_LOCKED       6   /* A table in the database is locked */
#define SQLITE_NOMEM        7   /* A malloc() failed */
#define SQLITE_READONLY     8   /* Attempt to write a readonly database */
#define SQLITE_INTERRUPT    9   /* Operation terminated by sqlite3_interrupt()*/
#define SQLITE_IOERR       10   /* Some kind of disk I/O error occurred */
#define SQLITE_CORRUPT     11   /* The database disk image is malformed */
#define SQLITE_NOTFOUND    12   /* Unknown opcode in sqlite3_file_control() */
#define SQLITE_FULL        13   /* Insertion failed because database is full */
#define SQLITE_CANTOPEN    14   /* Unable to open the database file */
#define SQLITE_PROTOCOL    15   /* Database lock protocol error */
#define SQLITE_EMPTY       16   /* Internal use only */
#define SQLITE_SCHEMA      17   /* The database schema changed */
#define SQLITE_TOOBIG      18   /* String or BLOB exceeds size limit */
#define SQLITE_CONSTRAINT  19   /* Abort due to constraint violation */
#define SQLITE_MISMATCH    20   /* Data type mismatch */
#define SQLITE_MISUSE      21   /* Library used incorrectly */
#define SQLITE_NOLFS       22   /* Uses OS features not supported on host */
#define SQLITE_AUTH        23   /* Authorization denied */
#define SQLITE_FORMAT      24   /* Not used */
#define SQLITE_RANGE       25   /* 2nd parameter to sqlite3_bind out of range */
#define SQLITE_NOTADB      26   /* File opened that is not a database file */
#define SQLITE_NOTICE      27   /* Notifications from sqlite3_log() */
#define SQLITE_WARNING     28   /* Warnings from sqlite3_log() */
#define SQLITE_ROW         100  /* sqlite3_step() has another row ready */
#define SQLITE_DONE        101  /* sqlite3_step() has finished executing */

#define SQLITE_INTEGER  1

#define SQLITE_FLOAT    2

#define SQLITE_BLOB     4

#define SQLITE_NULL     5


#ifdef SQLITE_TEXT
#undef SQLITE_TEXT
#else
#define SQLITE_TEXT     3
#endif


#define SQLITE3_TEXT     3


#define PTR32              int
#define sqlite3_stmt_p32   PTR32
#define sqlite3_p32        PTR32
#define PTRPTR32           PTR32

#define PTR64              long
#define sqlite3_stmt_p64   PTR64
#define sqlite3_p64        PTR64
#define PTRPTR64           PTR64

#define SQLITE_STATIC      0
#define SQLITE_TRANSIENT  -1

#define SQLITE_OPEN_READONLY         0x00000001  /* Ok for sqlite3_open_v2() */
#define SQLITE_OPEN_READWRITE        0x00000002  /* Ok for sqlite3_open_v2() */
#define SQLITE_OPEN_CREATE           0x00000004  /* Ok for sqlite3_open_v2() */
#define SQLITE_OPEN_DELETEONCLOSE    0x00000008  /* VFS only */
#define SQLITE_OPEN_EXCLUSIVE        0x00000010  /* VFS only */
#define SQLITE_OPEN_AUTOPROXY        0x00000020  /* VFS only */
#define SQLITE_OPEN_URI              0x00000040  /* Ok for sqlite3_open_v2() */
#define SQLITE_OPEN_MEMORY           0x00000080  /* Ok for sqlite3_open_v2() */
#define SQLITE_OPEN_MAIN_DB          0x00000100  /* VFS only */
#define SQLITE_OPEN_TEMP_DB          0x00000200  /* VFS only */
#define SQLITE_OPEN_TRANSIENT_DB     0x00000400  /* VFS only */
#define SQLITE_OPEN_MAIN_JOURNAL     0x00000800  /* VFS only */
#define SQLITE_OPEN_TEMP_JOURNAL     0x00001000  /* VFS only */
#define SQLITE_OPEN_SUBJOURNAL       0x00002000  /* VFS only */
#define SQLITE_OPEN_MASTER_JOURNAL   0x00004000  /* VFS only */
#define SQLITE_OPEN_NOMUTEX          0x00008000  /* Ok for sqlite3_open_v2() */
#define SQLITE_OPEN_FULLMUTEX        0x00010000  /* Ok for sqlite3_open_v2() */
#define SQLITE_OPEN_SHAREDCACHE      0x00020000  /* Ok for sqlite3_open_v2() */
#define SQLITE_OPEN_PRIVATECACHE     0x00040000  /* Ok for sqlite3_open_v2() */
#define SQLITE_OPEN_WAL              0x00080000  /* VFS only */


#import "Sqlite3_32.dll"
int sqlite3_open(const uchar &filename[],sqlite3_p32 &paDb);// Открытие базы
int sqlite3_close(sqlite3_p32 aDb); // Закрытие базы
int sqlite3_finalize(sqlite3_stmt_p32 pStmt);// Завершение трейтмента
int sqlite3_reset(sqlite3_stmt_p32 pStmt); // Сброс стейтмента
int sqlite3_step(sqlite3_stmt_p32 pStmt); // Переход на следующую строку при чтении стейтмента
int sqlite3_column_count(sqlite3_stmt_p32 pStmt); // Подсчет кол - ва колонок
int sqlite3_column_type(sqlite3_stmt_p32 pStmt,int iCol); // Получение типа выбранной колонки
int sqlite3_column_int(sqlite3_stmt_p32 pStmt,int iCol);// Преобразование значения в int
long sqlite3_column_int64(sqlite3_stmt_p32 pStmt,int iCol); // Преобразование значения в int64
double sqlite3_column_double(sqlite3_stmt_p32 pStmt,int iCol); // Преобразование значения в double
const PTR32 sqlite3_column_text(sqlite3_stmt_p32 pStmt,int iCol);// Получение текстового значения
int sqlite3_column_bytes(sqlite3_stmt_p32 apstmt,int iCol); // Получение кол - ва байтов занимаемых сторокой из переданной ячейки
int sqlite3_bind_int64(sqlite3_stmt_p32 apstmt,int icol,long a);// Объеденение запроса со значением (типа int64)
int sqlite3_bind_double(sqlite3_stmt_p32 apstmt,int icol,double a);// Объеденение запроса со значением (типа double)
int sqlite3_bind_text(sqlite3_stmt_p32 apstmt,int icol,char &a[],int len,PTRPTR32 destr);// Объеденение запроса со значением (типа string (char* - в C++))
int sqlite3_prepare_v2(sqlite3_p32 db,const uchar &zSql[],int nByte,PTRPTR32 &ppStmt,PTRPTR32 &pzTail);// Подготовка запроса
int sqlite3_exec(sqlite3_p32 aDb,const char &sql[],PTR32 acallback,PTR32 avoid,PTRPTR32 &errmsg);// Исполнение Sql
int sqlite3_open_v2(const uchar &filename[],sqlite3_p32 &ppDb,int flags,const char &zVfs[]); // Открытие базы с параметрами
#import

#import "Sqlite3_64.dll"
int sqlite3_open(const uchar &filename[],sqlite3_p64 &paDb);
int sqlite3_close(sqlite3_p64 aDb);
int sqlite3_finalize(sqlite3_stmt_p64 pStmt);
int sqlite3_reset(sqlite3_stmt_p64 pStmt);
int sqlite3_step(sqlite3_stmt_p64 pStmt);
int sqlite3_column_count(sqlite3_stmt_p64 pStmt);
int sqlite3_column_type(sqlite3_stmt_p64 pStmt,int iCol);
int sqlite3_column_int(sqlite3_stmt_p64 pStmt,int iCol);
long sqlite3_column_int64(sqlite3_stmt_p64 pStmt,int iCol);
double sqlite3_column_double(sqlite3_stmt_p64 pStmt,int iCol);
const PTR64 sqlite3_column_text(sqlite3_stmt_p64 pStmt,int iCol);
int sqlite3_column_bytes(sqlite3_stmt_p64 apstmt,int iCol);
int sqlite3_bind_int64(sqlite3_stmt_p64 apstmt,int icol,long a);
int sqlite3_bind_double(sqlite3_stmt_p64 apstmt,int icol,double a);
int sqlite3_bind_text(sqlite3_stmt_p64 apstmt,int icol,char &a[],int len,PTRPTR64 destr);
int sqlite3_prepare_v2(sqlite3_p64 db,const uchar &zSql[],int nByte,PTRPTR64 &ppStmt,PTRPTR64 &pzTail);
int sqlite3_exec(sqlite3_p64 aDb,const char &sql[],PTR64 acallback,PTR64 avoid,PTRPTR64 &errmsg);
int sqlite3_open_v2(const uchar &filename[],sqlite3_p64 &ppDb,int flags,const char &zVfs[]);
#import
//+------------------------------------------------------------------+
//| Sqlite3_open                                                     |
//+------------------------------------------------------------------+
int Sqlite3_open(const uchar &filename[],sqlite3_p64 &paDb)
  {
   if(_IsX64)
      return sqlite3_64::sqlite3_open(filename,paDb);
   else
     {
      sqlite3_p32 pdb=NULL;
      int r=sqlite3_32::sqlite3_open(filename,pdb);
      paDb=pdb;
      return(r);
     }
  }
//+------------------------------------------------------------------+
//| Sqlite3_close                                                    |
//+------------------------------------------------------------------+
int Sqlite3_close(sqlite3_p64 aDb)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_close(aDb) : sqlite3_32::sqlite3_close((PTR32)aDb));
  }
//+------------------------------------------------------------------+
//| Sqlite3_finalize                                                 |
//+------------------------------------------------------------------+
int Sqlite3_finalize(sqlite3_stmt_p64 pStmt)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_finalize(pStmt) : sqlite3_32::sqlite3_finalize((sqlite3_stmt_p32)pStmt));
  }
//+------------------------------------------------------------------+
//| Sqlite3_reset                                                    |
//+------------------------------------------------------------------+
int Sqlite3_reset(sqlite3_stmt_p64 pStmt)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_reset(pStmt) : sqlite3_32::sqlite3_reset((sqlite3_stmt_p32)pStmt));
  }
//+------------------------------------------------------------------+
//| Sqlite3_step                                                     |
//+------------------------------------------------------------------+
int Sqlite3_step(sqlite3_stmt_p64 pStmt)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_step(pStmt) : sqlite3_32::sqlite3_step((sqlite3_stmt_p32) pStmt));
  }
//+------------------------------------------------------------------+
//| Sqlite3_column_count                                             |
//+------------------------------------------------------------------+
int Sqlite3_column_count(sqlite3_stmt_p64 pStmt)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_column_count(pStmt) : sqlite3_32::sqlite3_column_count((sqlite3_stmt_p32) pStmt));
  }
//+------------------------------------------------------------------+
//| Sqlite3_column_type                                              |
//+------------------------------------------------------------------+
int Sqlite3_column_type(sqlite3_stmt_p64 pStmt,int iCol)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_column_type(pStmt,iCol) : sqlite3_32::sqlite3_column_type((sqlite3_stmt_p32)pStmt,iCol));
  }
//+------------------------------------------------------------------+
//| Sqlite3_column_int                                               |
//+------------------------------------------------------------------+
int Sqlite3_column_int(sqlite3_stmt_p64 pStmt,int iCol)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_column_int(pStmt,iCol) : sqlite3_32::sqlite3_column_int((sqlite3_stmt_p32)pStmt,iCol));
  }
//+------------------------------------------------------------------+
//| Sqlite3_column_int64                                             |
//+------------------------------------------------------------------+
long Sqlite3_column_int64(sqlite3_stmt_p64 pStmt,int iCol)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_column_int64(pStmt,iCol) : sqlite3_32::sqlite3_column_int64((sqlite3_stmt_p32)pStmt,iCol));
  }
//+------------------------------------------------------------------+
//| Sqlite3_column_double                                            |
//+------------------------------------------------------------------+
double Sqlite3_column_double(sqlite3_stmt_p64 pStmt,int iCol)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_column_double(pStmt,iCol) : sqlite3_32::sqlite3_column_double((sqlite3_stmt_p32)pStmt,iCol));
  }
//+------------------------------------------------------------------+
//| Sqlite3_column_text                                              |
//+------------------------------------------------------------------+
const PTR64 Sqlite3_column_text(sqlite3_stmt_p64 pStmt,int iCol)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_column_text(pStmt,iCol) : sqlite3_32::sqlite3_column_text((sqlite3_stmt_p32)pStmt,iCol));
  }
//+------------------------------------------------------------------+
//| Sqlite3_column_bytes                                             |
//+------------------------------------------------------------------+
int Sqlite3_column_bytes(sqlite3_stmt_p64 apstmt,int iCol)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_column_bytes(apstmt,iCol) : sqlite3_32::sqlite3_column_bytes((sqlite3_stmt_p32)apstmt,iCol));
  }
//+------------------------------------------------------------------+
//| Sqlite3_prepare_v2                                               |
//+------------------------------------------------------------------+
int Sqlite3_prepare_v2(sqlite3_p64 db,const uchar &zSql[],int nByte,PTRPTR64 &ppStmt,PTRPTR64 &pzTail)
  {
   if(_IsX64)
      return sqlite3_64::sqlite3_prepare_v2(db,zSql,nByte,ppStmt,pzTail);
   else
     {
      PTRPTR32 _ppStmt = (PTRPTR32)ppStmt;// OUT: Statement handle 
      PTRPTR32 _pzTail = (PTRPTR32)pzTail;// OUT: Pointer to unused portion of zSql 
      int rc = sqlite3_32::sqlite3_prepare_v2((sqlite3_p32)db,zSql,nByte,_ppStmt,_pzTail);
      ppStmt = _ppStmt;// OUT: Statement handle 
      pzTail = _pzTail;// OUT: Pointer to unused portion of zSql 

      return rc;
     }
  }
//+------------------------------------------------------------------+
//| Sqlite3_exec                                                     |
//+------------------------------------------------------------------+
int Sqlite3_exec(sqlite3_p64 aDb,const char &sql[],PTR64 acallback,PTR64 avoid,PTRPTR64 &errmsg)
  {
   if(_IsX64)
      return sqlite3_64::sqlite3_exec(aDb,sql,acallback,avoid,errmsg);
   else
     {
      PTRPTR32 msg;
      int ans=sqlite3_32::sqlite3_exec((sqlite3_p32)aDb,sql,(PTR32)acallback,(PTR32)avoid,msg);
      errmsg=msg;
      return ans;
     }
  }
//+------------------------------------------------------------------+
//| Sqlite3_bind_int64                                               |
//+------------------------------------------------------------------+
int Sqlite3_bind_int64(sqlite3_stmt_p64 apstmt,int icol,long a)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_bind_int64(apstmt,icol,a) : sqlite3_32::sqlite3_bind_int64((sqlite3_stmt_p32)apstmt,icol,a));
  }
//+------------------------------------------------------------------+
//| Sqlite3_bind_double                                              |
//+------------------------------------------------------------------+
int Sqlite3_bind_double(sqlite3_stmt_p64 apstmt,int icol,double a)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_bind_double(apstmt,icol,a) : sqlite3_32::sqlite3_bind_double((sqlite3_stmt_p32) apstmt,icol,a));
  }
//+------------------------------------------------------------------+
//| Sqlite3_bind_text                                                |
//+------------------------------------------------------------------+
int Sqlite3_bind_text(sqlite3_stmt_p64 apstmt,int icol,char &a[],int len,PTRPTR64 destr)
  {
   return (_IsX64 ? sqlite3_64::sqlite3_bind_text(apstmt,icol,a,len,destr) : sqlite3_32::sqlite3_bind_text((sqlite3_stmt_p32)apstmt,icol,a,len,(PTRPTR32)destr));
  }
//+------------------------------------------------------------------+
//| Sqlite3_open_v2                                                  |
//+------------------------------------------------------------------+
int Sqlite3_open_v2(
                    const uchar &filename[],/* Database filename (UTF-8) */
                    sqlite3_p64 &ppDb,/* OUT: SQLite db handle */
                    int flags,/* Flags */
                    const char &zVfs[]/* Name of VFS module to use */
                    )
  {
   if(_IsX64)
      return sqlite3_64::sqlite3_open_v2(filename,ppDb,flags,zVfs);
   else
     {
      PTRPTR32 db=NULL;
      int n=sqlite3_32::sqlite3_open_v2(filename,db,flags,zVfs);
      ppDb = db;
      return n;
     }
  }
//+------------------------------------------------------------------+
//| Вывод ошибок                                                     |
//+------------------------------------------------------------------+
void printErrorStatus(int n)
  {
   switch(n)
     {
      case SQLITE_ERROR : Print("Sqlite3 error : Generic error"); break;
      case SQLITE_INTERNAL : Print("Sqlite3 error : Internal logic error in SQLite"); break;
      case SQLITE_PERM : Print("Sqlite3 error : Access permission denied"); break;
      case SQLITE_ABORT : Print("Sqlite3 error : Callback routine requested an abort"); break;
      case SQLITE_BUSY : Print("Sqlite3 error : The database file is locked"); break;
      case SQLITE_LOCKED : Print("Sqlite3 error : A table in the database is locked"); break;
      case SQLITE_NOMEM : Print("Sqlite3 error : A malloc() failed"); break;
      case SQLITE_READONLY : Print("Sqlite3 error : Attempt to write a readonly database"); break;
      case SQLITE_INTERRUPT : Print("Sqlite3 error : Operation terminated by sqlite3_interrupt()"); break;
      case SQLITE_IOERR : Print("Sqlite3 error : Some kind of disk I/O error occurred"); break;
      case SQLITE_CORRUPT : Print("Sqlite3 error : The database disk image is malformed"); break;
      case SQLITE_NOTFOUND : Print("Sqlite3 error : Unknown opcode in sqlite3_file_control()"); break;
      case SQLITE_FULL : Print("Sqlite3 error : Insertion failed because database is full"); break;
      case SQLITE_CANTOPEN : Print("Sqlite3 error : Unable to open the database file"); break;
      case SQLITE_PROTOCOL : Print("Sqlite3 error : Database lock protocol error"); break;
      case SQLITE_EMPTY : Print("Sqlite3 error : Internal use only"); break;
      case SQLITE_SCHEMA : Print("Sqlite3 error : The database schema changed"); break;
      case SQLITE_TOOBIG : Print("Sqlite3 error : String or BLOB exceeds size limit"); break;
      case SQLITE_CONSTRAINT : Print("Sqlite3 error : Abort due to constraint violation"); break;
      case SQLITE_MISMATCH : Print("Sqlite3 error : Data type mismatch"); break;
      case SQLITE_MISUSE : Print("Sqlite3 error : Library used incorrectly"); break;
      case SQLITE_NOLFS : Print("Sqlite3 error : Uses OS features not supported on host"); break;
      case SQLITE_AUTH : Print("Sqlite3 error : Authorization denied"); break;
      case SQLITE_FORMAT : Print("Sqlite3 error : Not used"); break;
      case SQLITE_RANGE : Print("Sqlite3 error : 2nd parameter to sqlite3_bind out of range"); break;
      case SQLITE_NOTADB : Print("Sqlite3 error : File opened that is not a database file"); break;
      case SQLITE_NOTICE : Print("Sqlite3 error : Notifications from sqlite3_log()"); break;
      case SQLITE_WARNING : Print("Sqlite3 error : Warnings from sqlite3_log()"); break;
     }
  }
//+------------------------------------------------------------------+

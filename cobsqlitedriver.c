#include <stdio.h>
#include <stdlib.h>
#include <sqlite3.h>
#include <libcob.h>
#include <string.h>
#include <math.h>

sqlite3 *database;

void sqliteConnect(sqlite3 **db, char *filename, ...)
{

    const char *file = cob_get_picx_param(2, NULL, 0);

    int errcod = 0;

    int rc = sqlite3_open(file, &database);
    *db = database;

    if (rc != SQLITE_OK)
    {
        errcod = sqlite3_errcode(database);
        const char *errmsg = sqlite3_errstr(errcod);
        cob_put_u64_param(3, errcod);
        cob_put_picx_param(4, (void *)errmsg);
    }
    else
    {
        cob_put_u64_param(3, errcod);
        const char *errmsg = "Success";
        cob_put_picx_param(4, (void *)errmsg);
    }
}

void sqliteOpenCursor(sqlite3 **db, char *query, sqlite3_stmt **stmt)
{
    database = *db;
    char *err_msg = 0;
    long long errcod = 0;
    int rc = 0;

    sqlite3_stmt *res;

    char *sql = cob_get_picx_param(2, NULL, 0);

    rc = sqlite3_prepare_v2(database, sql, -1, &res, NULL);
    if (rc != SQLITE_OK)
    {
        errcod = sqlite3_errcode(database);
        const char *errmsg = sqlite3_errstr(errcod);
        cob_put_u64_param(4, errcod);
        cob_put_picx_param(5, (void *)errmsg);
        *stmt = NULL;
    }
    else
    {
        cob_put_u64_param(4, errcod);
        const char *errmsg = "Success";
        cob_put_picx_param(5, (void *)errmsg);
        *stmt = res;
    }
    cob_free((void *)sql);
}

void sqlitefetch(sqlite3_stmt **_stmt, ...)
{

    double _scale;
    double _fdata;
    double _mantiss;

    sqlite3_stmt *stmt = *_stmt;
    cob_s64_t result;

    result = cob_get_s64_param(2);
    result = 0;

    int num_cols = sqlite3_column_count(stmt);

    if (sqlite3_step(stmt) == SQLITE_DONE)
    {
        result = cob_get_s64_param(2);
        cob_put_s64_param(2, result + 1);
        return;
    }
    for (int i = 0; i < num_cols; i++)
    {
        switch (sqlite3_column_type(stmt, i))
        {
        case (SQLITE3_TEXT):
            cob_put_picx_param(i + 3, (void *)sqlite3_column_text(stmt, i));
            break;
        case (SQLITE_INTEGER):
            cob_put_u64_param(i + 3, sqlite3_column_int(stmt, i));
            break;
        case (SQLITE_FLOAT):
            _scale = cob_get_param_scale(i + 3);
            _fdata = sqlite3_column_double(stmt, i);
            _mantiss = pow(10.0, _scale);
            result = _fdata * _mantiss;
            cob_put_u64_param(i + 3, result);
            break;

        default:
            break;
        }
    }
}

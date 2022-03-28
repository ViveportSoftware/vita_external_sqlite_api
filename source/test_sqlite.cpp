#include <string>

#include "sqlite3.h"

void open_database_file()
{
    sqlite3* db;

    auto result = sqlite3_open("test.db", &db);
    if (result != SQLITE_OK)
    {
        return;
    }
    result = sqlite3_close(db);
    if (result != SQLITE_OK)
    {
        return;
    }
}

int main(int argc, char* argv[])
{
    open_database_file();

    getchar();

    return 0;
}

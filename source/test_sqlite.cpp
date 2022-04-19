#define CATCH_CONFIG_MAIN

#include <string>

#include "catch.hpp"
#include "sqlite3.h"

TEST_CASE("Database can be opened and closed", "[sqlite3]")
{
    sqlite3* db;

    auto result = sqlite3_open("test.db", &db);
    REQUIRE(result == SQLITE_OK);

    result = sqlite3_close(db);
    REQUIRE(result == SQLITE_OK);
}

package com.ice.himnarioiglesiacristianaevangelica.Service

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class SQLiteHelper(
    context: Context?,
    name: String?,
    factory: SQLiteDatabase.CursorFactory?,
    version: Int
) : SQLiteOpenHelper(context, name, factory, version) {

    val tabla : String = "CREATE TABLE \"Himnos\" ( \"id\" INTEGER NOT NULL UNIQUE, \"cancion\" TEXT NOT NULL, \"coro\" TEXT, \"titulo\" TEXT NOT NULL, \"versiculo\" TEXT NOT NULL, \"notas\" TEXT, PRIMARY KEY(\"id\" AUTOINCREMENT))"

    override fun onCreate(db: SQLiteDatabase?) {
        if (db != null) {
            db.execSQL(tabla)
        }
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        TODO("Not yet implemented")
    }



}
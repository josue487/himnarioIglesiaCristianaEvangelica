package com.ice.himnarioiglesiacristianaevangelica.Service

import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import com.ice.himnarioiglesiacristianaevangelica.ClasesBase.Himno
import java.lang.Error

class SQLiteHelper(
    context: Context?,
    name: String?,
    factory: SQLiteDatabase.CursorFactory?,
    version: Int
) : SQLiteOpenHelper(context, name, factory, version) {

    val tabla : String = "CREATE TABLE \"Himnario\" ( \"id\" INTEGER NOT NULL UNIQUE, \"coro\" TEXT, \"titulo\" TEXT NOT NULL, \"versiculo\" TEXT NOT NULL, \"notas\" TEXT, PRIMARY KEY(\"id\" AUTOINCREMENT))"

    override fun onCreate(db: SQLiteDatabase?) {

    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        TODO("Not yet implemented")
    }

    fun buscarHimno (idHimno : Int) : Himno{
        var bd : SQLiteDatabase = readableDatabase;
        var cursor : Cursor = bd.rawQuery("SELECT * FROM Himnos WHERE $idHimno LIKE id", null)
        var himnoBuscado : Himno = Himno()
        if(cursor.moveToFirst()){
            do {
                himnoBuscado.cancion = cursor.getString(1)
                himnoBuscado.coro = cursor.getString(2)
                himnoBuscado.titulo = cursor.getString(3)
                himnoBuscado.versiculo = cursor.getString(4)
                //error null mejor guardar en bd comillas dobles
                //himnoBuscado.notas = cursor.getString(5)
                himnoBuscado.id = cursor.getInt(0)
            }while (cursor.moveToNext())
        }
        return himnoBuscado
    }

}
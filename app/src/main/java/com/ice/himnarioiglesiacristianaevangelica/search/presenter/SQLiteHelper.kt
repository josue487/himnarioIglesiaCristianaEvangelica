package com.ice.himnarioiglesiacristianaevangelica.search.presenter

import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import com.ice.himnarioiglesiacristianaevangelica.search.model.Himno

class SQLiteHelper(
    context: Context?,
    name: String?,
    factory: SQLiteDatabase.CursorFactory?,
    version: Int
) : SQLiteOpenHelper(context, name, factory, version) {


    override fun onCreate(db: SQLiteDatabase?) {

    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
    }

    fun searchSong (idHimno : Int) : Himno {
        val bd : SQLiteDatabase = readableDatabase
        val cursor : Cursor = bd.rawQuery("SELECT * FROM Himnos WHERE $idHimno LIKE id", null)
        var song = Himno(1,"","","","","",false,"")
        if(cursor.moveToFirst()){

            do {
                song = Himno (cursor.getInt(0),cursor.getString(1), cursor.getString(2),cursor.getString(3), cursor.getString(4), cursor.getString(5),cursor.getInt(6) == 1,cursor.getString(7))
            }while (cursor.moveToNext())
        }
        cursor.close()
        return song
    }

    fun searchFavorite () :  ArrayList<Himno>{
        val bd : SQLiteDatabase = readableDatabase
        val cursor : Cursor = bd.rawQuery("SELECT * FROM Himnos WHERE favorito LIKE 1", null)
        val listaFavoritos = ArrayList<Himno>()
        if(cursor.moveToFirst()){
            do {
                val himnoFavorito = Himno (cursor.getInt(0),cursor.getString(1), cursor.getString(2),cursor.getString(3), cursor.getString(4), cursor.getString(5),cursor.getInt(6) == 1,cursor.getString(7))
                listaFavoritos.add(himnoFavorito)
            }while (cursor.moveToNext())
        }
        cursor.close()
        return listaFavoritos
    }



    fun changeStateFavorite(idHimno : Int) : Boolean{
        val bd : SQLiteDatabase = readableDatabase
        val cursor : Cursor = bd.rawQuery("SELECT * FROM Himnos WHERE $idHimno LIKE id", null)
        var favorite : Boolean = false
        if(cursor.moveToFirst()){
            favorite = cursor.getInt(6) == 1
        }
        cursor.close()
        favorite=favorite.not()
        val idFavorite : Int = if (favorite) 1 else 0
        bd.execSQL("UPDATE Himnos SET favorito = $idFavorite WHERE $idHimno LIKE id")
        return favorite
    }

}
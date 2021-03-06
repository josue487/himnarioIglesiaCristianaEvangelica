package com.ice.himnarioiglesiacristianaevangelica.Service

import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import com.ice.himnarioiglesiacristianaevangelica.ClasesBase.Himno

class SQLiteHelper(
    context: Context?,
    name: String?,
    factory: SQLiteDatabase.CursorFactory?,
    version: Int
) : SQLiteOpenHelper(context, name, factory, version) {


    override fun onCreate(db: SQLiteDatabase?) {

    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        TODO("Not yet implemented")
    }

    fun buscarHimno (idHimno : Int) : Himno{
        val bd : SQLiteDatabase = readableDatabase
        val cursor : Cursor = bd.rawQuery("SELECT * FROM Himnos WHERE $idHimno LIKE id", null)
        val himnoBuscado = Himno()
        if(cursor.moveToFirst()){
            do {
                himnoBuscado.cancion = cursor.getString(1)
                himnoBuscado.coro = cursor.getString(2)
                himnoBuscado.titulo = cursor.getString(3)
                himnoBuscado.versiculo = cursor.getString(4)
                himnoBuscado.notas = cursor.getString(5)
                himnoBuscado.favorito = cursor.getInt(6) == 1
                himnoBuscado.notasCoro = cursor.getString(7)
                himnoBuscado.id = cursor.getInt(0)
            }while (cursor.moveToNext())
        }
        cursor.close()
        return himnoBuscado
    }

    fun buscarFavoritos () :  ArrayList<Himno>{
        val bd : SQLiteDatabase = readableDatabase
        val cursor : Cursor = bd.rawQuery("SELECT * FROM Himnos WHERE favorito LIKE 1", null)
        var listaFavoritos = ArrayList<Himno>()
        if(cursor.moveToFirst()){
            do {
                val himnoBuscado = Himno()
                himnoBuscado.cancion = cursor.getString(1)
                himnoBuscado.coro = cursor.getString(2)
                himnoBuscado.titulo = cursor.getString(3)
                himnoBuscado.versiculo = cursor.getString(4)
                himnoBuscado.notas = cursor.getString(5)
                himnoBuscado.favorito = cursor.getInt(6) == 1
                himnoBuscado.notasCoro = cursor.getString(7)
                himnoBuscado.id = cursor.getInt(0)
                listaFavoritos.add(himnoBuscado)
            }while (cursor.moveToNext())
        }
        cursor.close()
        return listaFavoritos
    }



    fun cambiarEstadoFavorito(idHimno : Int) : Boolean{
        val bd : SQLiteDatabase = readableDatabase
        val cursor : Cursor = bd.rawQuery("SELECT * FROM Himnos WHERE $idHimno LIKE id", null)
        var favorito : Boolean = false
        if(cursor.moveToFirst()){
            favorito = cursor.getInt(6) == 1
        }
        cursor.close()
        favorito=favorito.not()
        val numeroFavorito : Int = if (favorito) 1 else 0
        bd.execSQL("UPDATE Himnos SET favorito = $numeroFavorito WHERE $idHimno LIKE id")
        return favorito
    }

}
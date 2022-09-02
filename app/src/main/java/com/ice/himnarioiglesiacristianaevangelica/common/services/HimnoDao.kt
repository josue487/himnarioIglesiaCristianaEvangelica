package com.ice.himnarioiglesiacristianaevangelica.common.services

import androidx.room.Dao
import androidx.room.Query
import com.ice.himnarioiglesiacristianaevangelica.search.model.Himno

@Dao
interface HimnoDao {

    @Query ("SELECT * FROM Himno")
    fun getAll() :  List<Himno>

    @Query("SELECT * FROM Himno WHERE favorito = 1")
    fun listarFavoritos() : List<Himno>

    @Query("SELECT * FROM Himno WHERE id = :id")
    fun buscarHimno(id : Int) : Himno

    @Query("UPDATE Himno SET favorito = :numeroFavorito WHERE :id LIKE id")
    fun cambiarEstadoFavorito(id : Int, numeroFavorito : Int )

}
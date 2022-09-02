package com.ice.himnarioiglesiacristianaevangelica.search.model

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity
data class Himno(
    @PrimaryKey(autoGenerate = true)
    val id : Int,
    @ColumnInfo(name = "cancion")
    val cancion : String,
    @ColumnInfo(name = "coro")
    val coro : String,
    @ColumnInfo(name = "titulo")
    val titulo : String,
    @ColumnInfo(name = "versiculo")
    val versiculo : String,
    @ColumnInfo(name = "notas")
    val notas : String,
    @ColumnInfo(name = "favorito")
    val favorito : Boolean,
    @ColumnInfo(name = "notasCoro")
    val notasCoro : String
)

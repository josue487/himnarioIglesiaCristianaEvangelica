package com.ice.himnarioiglesiacristianaevangelica.Actividades

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.AdapterView
import android.widget.ArrayAdapter
import com.ice.himnarioiglesiacristianaevangelica.ClasesBase.Himno
import com.ice.himnarioiglesiacristianaevangelica.R
import com.ice.himnarioiglesiacristianaevangelica.Service.SQLiteHelper
import com.ice.himnarioiglesiacristianaevangelica.databinding.ActivityFavoritosBinding

class FavoritosActivity : AppCompatActivity() {


    val servicioBD : SQLiteHelper = SQLiteHelper(this,"dbHimnosEstructuraCompleta.db",null,1)
    //Necesario para trabajar con viewbinding
    private lateinit var binding : ActivityFavoritosBinding

    var listaInformacion = ArrayList<String>()
    var listaFavoritos = ArrayList<Himno>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_favoritos)
        //inflar la actividad
        binding = ActivityFavoritosBinding.inflate(layoutInflater)
        //seteo del content view
        setContentView(binding.root)
        cargarFavoritos()
        binding.lViewFavoritos.setOnItemClickListener(AdapterView.OnItemClickListener { parent, view, position, id ->

            val intent = Intent(this, BusquedaActivity::class.java)
            intent.putExtra("id", listaFavoritos.get(position).id)
            startActivity(intent)
        })
    }



    fun cargarFavoritos(){
        listaFavoritos = servicioBD.buscarFavoritos()
        for (i in listaFavoritos){
            listaInformacion.add("${i.id} - ${i.titulo}")
        }
        var adaptador = ArrayAdapter(this, android.R.layout.simple_list_item_1,listaInformacion)
        binding.lViewFavoritos.adapter = adaptador
    }


}
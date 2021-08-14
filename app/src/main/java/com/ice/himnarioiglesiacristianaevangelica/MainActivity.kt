package com.ice.himnarioiglesiacristianaevangelica

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.Toast
import com.ice.himnarioiglesiacristianaevangelica.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    //necesario para trabajar con viewbinding
    private lateinit var binding : ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //inflar la actividad
        binding= ActivityMainBinding.inflate(layoutInflater)
        //seteo del content view
        setContentView(binding.root)
    }


    fun btnBuscar(v: View){
        if(binding.txtNumeroHimno.text.isNotEmpty()){
            val intent = Intent(this, BusquedaActivity::class.java)
            startActivity(intent)
        }else{
            Toast.makeText(this, "Debe Ingresar un himno valido", Toast.LENGTH_SHORT).show()
        }
    }
}
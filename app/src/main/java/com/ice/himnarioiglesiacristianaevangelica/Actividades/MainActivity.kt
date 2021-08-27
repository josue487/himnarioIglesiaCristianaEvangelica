package com.ice.himnarioiglesiacristianaevangelica.Actividades

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Toast
import com.ice.himnarioiglesiacristianaevangelica.databinding.ActivityMainBinding
import java.io.*

class MainActivity : AppCompatActivity() {

    //necesario para trabajar con viewbinding
    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //inflar la actividad
        binding = ActivityMainBinding.inflate(layoutInflater)
        //seteo del content view
        setContentView(binding.root)
        copiarBaseDatos()

    }

    fun btnBuscar(@Suppress("UNUSED_PARAMETER") v: View) {
        if (binding.txtNumeroHimno.text.isNotEmpty()) {
            val intent = Intent(this, BusquedaActivity::class.java)
            intent.putExtra("id",binding.txtNumeroHimno.text.toString().toInt())
            startActivity(intent)
        } else {
            Toast.makeText(this, "Debe Ingresar un himno valido", Toast.LENGTH_SHORT).show()
        }
    }


    fun copiarBaseDatos() {
        val ruta = "/data/data/com.ice.himnarioiglesiacristianaevangelica/databases/"
        val archivo = "dbHimnosEstructuraCompleta.db"
        val archivoDB = File(ruta + archivo)
        if (!archivoDB.exists()) {
            try {
                val IS: InputStream = getApplicationContext().getAssets().open(archivo)
                val OS: OutputStream = FileOutputStream(archivoDB)
                val buffer = ByteArray(1024)
                var length : Int
                length = IS.read(buffer)
                while (length > 0) {
                    OS.write(buffer, 0, length)
                    length = IS.read(buffer)
                }
                OS.flush()
                OS.close()
                IS.close()
            } catch (e : FileNotFoundException) {
                Log.d("ERROR", "Archivo no encontrado, " + e.toString())
            } catch (e : IOException) {
                Log.d("ERROR", "Error al copiar la Base de Datos, " + e.toString())
            }
        }
    }
}
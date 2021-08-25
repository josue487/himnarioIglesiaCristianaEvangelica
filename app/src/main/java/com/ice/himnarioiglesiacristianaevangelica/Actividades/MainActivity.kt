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

    fun btnBuscar(v: View) {
        if (binding.txtNumeroHimno.text.isNotEmpty()) {
            var intent = Intent(this, BusquedaActivity::class.java)
            intent.putExtra("id",binding.txtNumeroHimno.text.toString().toInt())
            startActivity(intent)
        } else {
            Toast.makeText(this, "Debe Ingresar un himno valido", Toast.LENGTH_SHORT).show()
        }
    }


    fun copiarBaseDatos() {
        val ruta: String = "/data/data/com.ice.himnarioiglesiacristianaevangelica/databases/";
        val archivo: String = "dbHimnosEstructuraCompleta.db";
        val archivoDB: File = File(ruta + archivo);
        if (!archivoDB.exists()) {
            try {
                var IS: InputStream = getApplicationContext().getAssets().open(archivo);
                var OS: OutputStream = FileOutputStream(archivoDB)
                var buffer: ByteArray = ByteArray(1024)
                var length : Int = 0;
                length = IS.read(buffer)
                while (length > 0) {
                    OS.write(buffer, 0, length);
                    length = IS.read(buffer)
                }
                OS.flush();
                OS.close();
                IS.close();
                Toast.makeText(this, "se copio la bd con exito", Toast.LENGTH_LONG).show()
            } catch (e : FileNotFoundException) {
                Log.d("ERROR", "Archivo no encontrado, " + e.toString());
                Toast.makeText(this, "Archivo no encontrado, "+ e.toString(), Toast.LENGTH_LONG).show()
            } catch (e : IOException) {
                Log.d("ERROR", "Error al copiar la Base de Datos, " + e.toString());
                Toast.makeText(this, "Error al copiar la Base de Datos,  " + e.toString(), Toast.LENGTH_LONG).show()
            }
        }else{
            Toast.makeText(this, "Existe la bd", Toast.LENGTH_SHORT).show()
        }


    }
}
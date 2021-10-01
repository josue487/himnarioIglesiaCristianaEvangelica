package com.ice.himnarioiglesiacristianaevangelica.Actividades

import android.content.Intent
import android.graphics.Typeface
import android.os.Bundle
import android.text.SpannableString
import android.text.Spanned
import android.text.method.ScrollingMovementMethod
import android.text.style.StyleSpan
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.ice.himnarioiglesiacristianaevangelica.ClasesBase.Himno
import com.ice.himnarioiglesiacristianaevangelica.R
import com.ice.himnarioiglesiacristianaevangelica.Service.SQLiteHelper
import com.ice.himnarioiglesiacristianaevangelica.databinding.ActivityBusquedaBinding

class BusquedaActivity : AppCompatActivity() {


    val servicioBD : SQLiteHelper = SQLiteHelper(this,"dbHimnosEstructuraCompleta.db",null,1)

    //Necesario para trabajar con viewbinding
    private lateinit var binding : ActivityBusquedaBinding

    //Comentario Formato de la Base de Datos para trabajar
    // Simbolos
    // / significa salto de linea
    // * significa que en este lugar va el coro si o si
    // + Significa que en este lugar va el coro opcionalmente como para que aparezca en multiples ocaciones


    var posicion : Int = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //inflar la actividad
        binding= ActivityBusquedaBinding.inflate(layoutInflater)
        //seteo del content view
        setContentView(binding.root)
        //agregado de scrollbar para la cancion que va a ser larga
        binding.lblCancion.movementMethod = ScrollingMovementMethod()
        val datos : Intent = getIntent()
        val idHimno: Int = datos.getIntExtra("id",0)
        cargarHimno(idHimno)
    }

    //Codigo para boton atras
    fun atras(@Suppress("UNUSED_PARAMETER") v : View){
        onBackPressed()
    }

    //Codigo para boton atras
    fun siguiente(@Suppress("UNUSED_PARAMETER") v : View){
        if(posicion+1 != 518){
            cargarHimno(posicion+1)
        }
        else{
            Toast.makeText(this,"Llegaste al Final",Toast.LENGTH_LONG)
        }
    }

    //Codigo para boton atras
    fun anterior(@Suppress("UNUSED_PARAMETER") v : View){
        if(posicion-1 != 0){
            cargarHimno(posicion-1)
        }
        else{
            Toast.makeText(this,"Llegaste al Inicio",Toast.LENGTH_LONG)
        }
    }

    //Formatea el texto ejm los espacios determinados con / el coro determinado con * y el coro repetido determinado por +
    fun formatearYCargarHimno (himnoBuscado : Himno){
        //Creacion de titulo con su id
        val tituloFinal:String = himnoBuscado.id.toString() + " " + himnoBuscado.titulo
        //Agregado de separadores de linea al reemplazarlos del texto original (variable reservada para eso '/') en la cancion
        var cancionFinal:String = himnoBuscado.cancion.replace("/", System.getProperty("line.separator"))
        //Agregado de separadores de linea al reemplazarlos del texto original (variable reservada para eso '/') en el coro
        val coroFinal:String = himnoBuscado.coro.replace("/", System.getProperty("line.separator"))

        //agregado del coro a la cancion para obtener la cancion final
        cancionFinal=cancionFinal.replace("*", coroFinal)


        if(false){
            //Variable situacional '+' para evaluar a futuro la posibilidad de poner el coro en distintas lineas de la cancion donde esta lo amerite
            cancionFinal = cancionFinal.replace("+", "")
        }else{
            cancionFinal = cancionFinal.replace("+", coroFinal)
        }
        //Una vez formateado lo carga en la vista de acuerdo al formato aplicado
        cargarEnLaVista(cancionFinal, tituloFinal, himnoBuscado.versiculo)
    }


    fun cargarEnLaVista(cancionFinal : String , tituloFinal : String, versiculos : String){

        var cancionFormateada = cancionFinal
        var inicioCoro = 0
        var finalCoro = 0
        // creacion del estilo negrita
        var negrita = StyleSpan(Typeface.BOLD_ITALIC)
        //una vez guardadas las 2 posiciones mencionadas anteriormente se crea el objeto Spannable para asi poder aplicar negrita
        val ss = SpannableString(cancionFinal.replace("(negrita)","").replace("(finNegrita)", ""))

        while(cancionFormateada.indexOf("(negrita)",inicioCoro) != -1){
            //bloque de codigo que lo que hace es:
            //1) obtener el indice de inicio de coro para despues poner en negrita y guardarlo en una variable
            inicioCoro = cancionFormateada.indexOf("(negrita)",inicioCoro)
            //2) quitar el texto reservado (negrita) que identificaba el inicio del coro
            cancionFormateada = cancionFormateada.replaceFirst("(negrita)", "")
            //3) obtener el indice de final de coro para delimitar el tamaño de la negrita y guardarlo en una variable
            finalCoro = cancionFormateada.indexOf("(finNegrita)",finalCoro)
            //4) quitar el texto reservado (finNegrita) que identificaba el fin del coro
            cancionFormateada = cancionFormateada.replaceFirst("(finNegrita)", "")
            negrita = StyleSpan(Typeface.BOLD_ITALIC)
            //formateo del texto final con el coro en negrita delimitado por inicioCoro y finalCoro
            ss.setSpan(negrita,inicioCoro,finalCoro,Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
        }


        //bindeo con la vista para mostrar titulo con el id y el titulo del himnario
        binding.lblTitulo.text=tituloFinal
        //bindeo con la vista para mostrar la cancion completa y formateada
        binding.lblCancion.text=ss
        //bindeo con la vista para mostrar los versiculos basados en la creacion del himno
        binding.lblVersiculos.text=versiculos

    }

    //Boton de favorito
    fun formatearFavorito(himnoFavorito : Boolean){
        if(himnoFavorito)
        {
            binding.btnFavorito.setImageResource(R.drawable.favorito_on)
        }
        else{
            binding.btnFavorito.setImageResource(R.drawable.favorito_off)
        }
    }

    fun btnFavorito(v: View){
        formatearFavorito(servicioBD.cambiarEstadoFavorito(posicion))
    }

    fun cargarHimno(idHimno : Int){

        posicion=idHimno
        val himnoBuscado : Himno = servicioBD.buscarHimno(idHimno)
        if (himnoBuscado.cancion != ""){
            formatearFavorito(himnoBuscado.favorito)
            formatearYCargarHimno(himnoBuscado)
        }else{
            Toast.makeText(this, "No existe el himno buscado", Toast.LENGTH_LONG).show()
            onBackPressed()
        }
    }
}
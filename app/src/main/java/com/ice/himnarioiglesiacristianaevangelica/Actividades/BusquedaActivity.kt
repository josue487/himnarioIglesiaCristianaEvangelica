package com.ice.himnarioiglesiacristianaevangelica.Actividades

import android.graphics.Typeface
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.text.SpannableString
import android.text.Spanned
import android.text.method.ScrollingMovementMethod
import android.text.style.StyleSpan
import android.view.View
import com.ice.himnarioiglesiacristianaevangelica.databinding.ActivityBusquedaBinding

class BusquedaActivity : AppCompatActivity() {

    //Necesario para trabajar con viewbinding
    private lateinit var binding : ActivityBusquedaBinding

    //Contenido del himno promedio (ToDo Base de datos con estos atributos)
    val id:Int = 1;
    val titulo:String = "A casa vete y cuenta allí"
    val cancion:String ="A casa vete y cuenta allí / que Cristo te libró; / que tus amigos vean en ti /" +
            " lo que Él por gracia obró. //* A casa vete y cuenta allí / que Cristo comprendió / " +
            "tu gran necesidad, y así / su sangre derramó. //+ Ve, cuenta a los de en derredor / " +
            "que Él satisfará / sus almas, puesto que en su amor / la cruz sufrido ha. //+ Ve, cuenta a " +
            "los de más allá / que en Cristo hay perdón, / y que Él a todos salvará, / si quieren salvación. //+ "
    val coro : String = "(negrita)A casa vete y lo que en ti / Ha hecho Dios, que vean, / y puede ser que los de allí / lo buscarán también. (finNegrita)//"
    val versiculos : String = "Marcos 5.19  Hechos 10.42,43"


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //inflar la actividad
        binding= ActivityBusquedaBinding.inflate(layoutInflater)
        //seteo del content view
        setContentView(binding.root)
        //agregado de scrollbar para la cancion que va a ser larga
        binding.lblCancion.movementMethod = ScrollingMovementMethod()
        //carga himno ToDo Base de datos y conexcion con la otra vista
        cargarHimno()
    }

    //Codigo para boton atras
    fun atras(v : View){
        onBackPressed()
    }




fun cargarHimno(){
    //Creacion de titulo con su id
    var tituloFinal:String = "$id $titulo";
    //Agregado de separadores de linea al reemplazarlos del texto original (variable reservada para eso '/') en la cancion
    var cancionFinal:String = cancion.replace("/", System.getProperty("line.separator"))
    //Agregado de separadores de linea al reemplazarlos del texto original (variable reservada para eso '/') en el coro
    var coroFinal:String = coro.replace("/", System.getProperty("line.separator"))

    //agregado del coro a la cancion para obtener la cancion final
    cancionFinal=cancionFinal.replace("*", coroFinal)

    //ToDO evaluacion de configuraciones para determinar si quiere ver que el coro se repita o no
    if(true){
        //Variable situacional '+' para evaluar a futuro la posibilidad de poner el coro en distintas lineas de la cancion donde esta lo amerite
        cancionFinal = cancionFinal.replace("+", "")
    }else{
        cancionFinal = cancionFinal.replace("+", coroFinal)
    }







    //bloque de codigo que lo que hace es:
    //1) obtener el indice de inicio de coro para despues poner en negrita y guardarlo en una variable
    val inicioCoro : Int = cancionFinal.indexOf("(negrita)")
    //2) quitar el texto reservado (negrita) que identificaba el inicio del coro
    cancionFinal=cancionFinal.replace("(negrita)", "")
    //3) obtener el indice de final de coro para delimitar el tamaño de la negrita y guardarlo en una variable
    val finalCoro : Int = cancionFinal.indexOf("(finNegrita)")
    //4) quitar el texto reservado (finNegrita) que identificaba el fin del coro
    cancionFinal=cancionFinal.replace("(finNegrita)", "")

    //una vez guardadas las 2 posiciones mencionadas anteriormente se crea el objeto Spannable para asi poder aplicar negrita
    val ss = SpannableString(cancionFinal)
    // creacion del estilo negrita
    val negrita = StyleSpan(Typeface.BOLD_ITALIC)
    //formateo del texto final con el coro en negrita delimitado por inicioCoro y finalCoro
    ss.setSpan(negrita,inicioCoro,finalCoro,Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)


    //bindeo con la vista para mostrar titulo con el id y el titulo del himnario
    binding.lblTitulo.text=tituloFinal
    //bindeo con la vista para mostrar la cancion completa y formateada
    binding.lblCancion.text=ss
    //bindeo con la vista para mostrar los versiculos basados en la creacion del himno
    binding.lblVersiculos.text=versiculos

}


}
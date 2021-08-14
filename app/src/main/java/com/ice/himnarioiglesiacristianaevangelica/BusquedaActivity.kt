package com.ice.himnarioiglesiacristianaevangelica

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.ice.himnarioiglesiacristianaevangelica.databinding.ActivityBusquedaBinding
import com.ice.himnarioiglesiacristianaevangelica.databinding.ActivityMainBinding

class BusquedaActivity : AppCompatActivity() {

    //Necesario para trabajar con viewbinding
    private lateinit var binding : ActivityBusquedaBinding

    //Contenido del himno promedio (ToDo Base de datos con estos atributos)
    var id:Int = 1;
    var titulo:String="A casa vete y cuenta allí"
    var cancion:String="A casa vete y cuenta allí / que Cristo te libró; / que tus amigos vean en ti /" +
            " lo que Él por gracia obró. + A casa vete y cuenta allí / que Cristo comprendió / " +
            "tu gran necesidad, y así / su sangre derramó. + Ve, cuenta a los de en derredor / " +
            "que Él satisfará / sus almas, puesto que en su amor / la cruz sufrido ha. + Ve, cuenta a " +
            "los de más allá / que en Cristo hay perdón, / y que Él a todos salvará, / si quieren salvación. + "
    var coro : String="A casa vete y lo que en ti / Ha hecho Dios, que vean, / y puede ser que los de allí / lo buscarán también. + "



    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //inflar la actividad
        binding= ActivityBusquedaBinding.inflate(layoutInflater)
        //seteo del content view
        setContentView(binding.root)
        cargarHimno()
    }




fun cargarHimno(){
    var tituloBusqueda:String = "$id $titulo";
    var cancionBusqueda:String = cancion.replace("/", System.getProperty("line.separator"));
    var coroBuscado:String = coro.replace("/", System.getProperty("line.separator"));
    binding.lblTitulo.text=tituloBusqueda
    binding.lblCancion.text=cancionBusqueda

}


}
const iniciar = document.getElementById('iniciar');
iniciar.onclick = async  function() {
    console.log(boardError[0]);
    try{
        console.log("iniciar");
        startRead[0] = true;
        await socket.emit('arduinoData',{message:'iniciar'});   
        addTitle(); 
    }catch{
        console.log(e);
    }
}

const detener = document.getElementById('detener');

detener.onclick = async (e) => {
    try{
        //await socket.emit('arduinoData',{message:'detener'});
        //detenerPintado[0] = true;
        startRead[0] = false;
        removeTitle();
        console.log('detener')
    }catch(e){
        console.log(e)
    } 
}

const guardar = document.getElementById('guardar');

guardar.onclick = (e) => {
    if(startRead[0]){ 
        alert("detener las adquisición");
        return;
    }
    if(confirm('Guardando Datos')){

        let strdata = "celda,encoder,flujo,rpm,tps1,temperatura,voltaje,tps2,marcha\n" ;
        let auxCeldaArr = dataSave['fun0'];
        let size = auxCeldaArr.length;
        let auxEncoderArr = dataSave['fun1'];
        let auxFlujoArr = dataSave['fun2'];
        let auxEcuArr = dataSave['fun3'];

        console.log(auxCeldaArr.length)
        console.log(auxEcuArr.length)

        let k = 0;
        let saltos = -1;
        for(let i=0;i<size;i++){
            if(k === 0){
                strdata +=  auxCeldaArr[i] + "," + auxEncoderArr[i] + "," + auxFlujoArr[i] + "," + auxEcuArr[saltos*10] + "," + auxEcuArr[1 + saltos*10] + "," + auxEcuArr[2 + saltos*10] + "," + auxEcuArr[3 + saltos*10] + "," + auxEcuArr[4 + saltos*10 ] + "," + auxEcuArr[5 + saltos*10] + "\n"
                saltos++;
            }else
                strdata +=  auxCeldaArr[i] + "," + auxEncoderArr[i] + "," + auxFlujoArr[i] + ",0,0,0,0,0\n";
            k < 10 ? k++ : k =0; 
        }

        console.log(auxEcuArr);

        const blob = new Blob([strdata],{type:'text/plain; charset=utf-8'});
        let a = document.createElement('a');
        a.download = 'prueba.csv';
        a.href = window.URL.createObjectURL(blob);
        a.click();
        
        torqueArrayTest.clear();
        potenciaArrayTest.clear();
        chartTest.update();
    }
}
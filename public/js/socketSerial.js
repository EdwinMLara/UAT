var socket = io();
const bateriaVoltaje = document.getElementById('bateriaVoltaje');
const tps = document.getElementById('tps');
const tps2 = document.getElementById('tps2');
const rpmData = document.getElementById('rpm');
const gp = document.getElementsByClassName('gear');
const title = document.getElementById('title');
const gpActive = [0];
const startRead = [false];
const boardError = [true];
// Distancia del brazo del freno 0.16007 y agregando la gravedad
const d = 0.16007*9.806;
const gearTransmicionConvertions = [1,2.714,2.200,1.850,1.600,1.421,1.300];
const gearReduccionClutch = 1.900;

function decimalAdjust(type, value, exp) {
    // If the exp is undefined or zero...
    if (typeof exp === 'undefined' || +exp === 0) {
        return Math[type](value);
    }
    value = +value;
    exp = +exp;
    // If the value is not a number or the exp is not an integer...
    if (isNaN(value) || !(typeof exp === 'number' && exp % 1 === 0)) {
        return NaN;
    }
    // Shift
    value = value.toString().split('e');
    value = Math[type](+(value[0] + 'e' + (value[1] ? (+value[1] - exp) : -exp)));
    // Shift back
    value = value.toString().split('e');
    return +(value[0] + 'e' + (value[1] ? (+value[1] + exp) : exp));
}

const floor10 = (value, exp) => decimalAdjust('floor', value, exp);

function addTitle(){
    title.classList.add('divtitle');
    title.innerHTML = "<h1>Adquiriendo...</h1>";
}

function removeTitle(){
    title.classList.remove("divtitle");
    title.innerHTML = "<h1>Dinamómetro UAT</h1>"
}

socket.on('arduinoData', data => {
    //console.log(data);
    if (typeof data === 'object') {
        if (data.hasOwnProperty('value')) {
            let serialData = data.value;
            let parseData = serialData.split(' ').map(num => parseFloat(num));
    
            let objAux = {
                celda: [],
                encoder: [],
                flujo: [],
                ecu: []
            }

            /**
             * Variable para la posicion en el array para graficar en RPM
             */
            let position;

            for (let i = 0; i < 4; i++) {
                let newData = parseData.splice(0, 11);
                let indentificador = newData.shift();
                if(startRead[0]){
                    dataSave['fun' + i].push.apply(dataSave['fun' + i], newData);
                }
                //console.log(newData);
                if (Array.isArray(newData) && i !== 3) {
                    let value = (newData.reduce((total, num) => {
                        return total + num;
                    })) / 10;
                    newData = value;
                }

                /** aqui voy a poner condicion para cuando se active el guardado ponerlo wn el
                 * objeto global, mientras pinto
                 */

                switch (indentificador) {
                    case 0:
                        //Se va a guardar en el objecto torque
                        objAux.celda = newData;
                        break;
                    case 1:
                        /**
                         * el enconder me esta entregando RPM del freno que son las que voy a utlizar para graficar
                         * se normaliza el vector para encontrar un posicion entre 0 y 160
                        */
                        objAux.encoder = newData;
                        break;
                    case 2:
                        let flujo = floor10(newData, -1);
                        gaugeflujo.set(flujo);
                        flujoDataP.innerHTML = flujo;
                        break;
                    case 3:
                        /**Valores entregados por la ECU */
                        objAux.ecu = newData;
                        rpmData.innerHTML = newData[0] + ' rpm';

                        tps.innerHTML = newData[1] + ' %';

                        gaugeTemperatura.set(newData[2]);
                        temperaturaDataP.innerHTML = newData[2];

                        bateriaVoltaje.innerHTML = newData[3] + ' V';
                        
                        tps2.innerHTML = newData[4] + ' %';

                        if (gpActive[0] !== newData[5]) {
                            gp[newData[5]].classList.add("gearActive");
                            gp[gpActive[0]].classList.remove("gearActive");
                            gpActive[0] = newData[5];
                        }   

                        //**graficas de toque y potencia respecto al freno */
                        let torque = objAux.celda*d;                       
                        
                        let rpmMotor = objAux.encoder*gearTransmicionConvertions[newData[5]]*gearReduccionClutch;
    
                        position = Math.floor((rpmMotor / maxRPM) * numDataTest);

                        let potencia = torque*rpmMotor*0.0001904;

                        dataChartTest.fun0[position] = {x:rpmMotor,y:torque};
                        dataChartTest.fun1[position] = {x:rpmMotor,y:potencia};

                        chartTest.update();
                        break;
                    default:
                        console.log("Error en los datos");
                }
            }
            return;
        }

        if (data.hasOwnProperty('error')) {
            startRead[0] = false;
            alert("ERROR de comunicacion de la targeta de adquisición")
            removeTitle();
        }else{
            boardError[0] = false;
        }
    }
});
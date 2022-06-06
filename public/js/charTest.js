const numDataTest = 160;
const incrementTest = 16000/numDataTest;
const rpmTest = new Array(numDataTest);

Array.prototype.clear = function() {
    this.splice(0, this.length);
};

for(let i=0;i<numDataTest;i++){
    rpmTest[i] = i*incrementTest;
}

const torqueArrayTest = new Array(numDataTest);
const potenciaArrayTest = new Array(numDataTest);

const dataChartTest = {
    fun0 : torqueArrayTest,
    fun1 : potenciaArrayTest
}

const dataTest = {
    labels : rpmTest,
    datasets:[{
        label:'Torque',
        data:dataChartTest.fun0,
        backgroundColor:'red',
        yAxisId:'torque'
    },{
        label:'Potencia',
        data:dataChartTest.fun1,
        backgroundColor:'blue',
        yAxisId:'potencia'
    }]
}

const confTest = {
    type:'line',
    data:dataTest,
    options:{
        responsive:false,
        scales:{
            torque:{
                type:'linear',
                display:true,
                position:'left',
                min:0,
                max:80,
                title:{
                    display:true,
                    text:'Torque',
                    font:{
                        size: 15
                    }
                }
            },
            potencia:{
                type:'linear',
                display:true,
                position:'right',
                min:0,
                max:110,
                title:{
                    display:true,
                    text:'Potencia',
                    font:{
                        size:15
                    }
                }
            }
        },
        animation:false
    }
}

const ctxTest = document.getElementById('myChart').getContext('2d');
const chartTest = new Chart(ctxTest,confTest);

function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min)) + min;
}

let incrementValueTest = 0;
let decrementValueTest = 100;
let rpmValuesTest = 0;

/*function updateTest (){
    rpmValuesTest += 300;
    if(rpmValuesTest >= 16000){
        rpmValuesTest = 0;
    }
    if(incrementValueTest === 150){
        incrementValueTest = 0;   
    }
    if(decrementValueTest === 0){
        decrementValueTest = 100;   
    }
    let position = Math.floor((rpmValuesTest/16000)*160);
    dataChartTest.fun0[position] = incrementValueTest;
    dataChartTest.fun1[position] = decrementValueTest;
    incrementValueTest++;
    decrementValueTest--;
    chartTest.update();
}

const interval = setInterval(updateTest,100);*/
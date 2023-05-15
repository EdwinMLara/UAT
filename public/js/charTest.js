const numDataTest = 320;
const maxRPM = 16000
const incrementTest = maxRPM / numDataTest;
const rpmTest = new Array(numDataTest);

Array.prototype.clear = function () {
    this.splice(0, this.length);
};

const torqueArrayTest = new Array(numDataTest);
const potenciaArrayTest = new Array(numDataTest);

for(let i=0;i<numDataTest;i++){
    torqueArrayTest[i] = {x:i*incrementTest,y:0}
    potenciaArrayTest[i] = {x:i*incrementTest,y:0}
}

const dataChartTest = {
    fun0: torqueArrayTest,
    fun1: potenciaArrayTest
}

const dataTest = {
    datasets: [{
        label: 'Torque',
        data: dataChartTest.fun0,
        backgroundColor: 'red',
        yAxisId: 'torque'
    }, {
        label: 'Potencia',
        data: dataChartTest.fun1,
        backgroundColor: 'blue',
        yAxisId: 'potencia'
    }]
}

const confTest = {
    type: 'scatter',
    data: dataTest,
    options: {
        responsive: false,
        scales: {
            torque: {
                display: true,
                position: 'left',
                min: 0,
                max: 150,
                title: {
                    display: true,
                    text: 'Torque',
                    font: {
                        size: 15
                    }
                }
            },
            potencia: {
                display: true,
                position: 'right',
                min: 0,
                max: 150,
                title: {
                    display: true,
                    text: 'Potencia',
                    font: {
                        size: 15
                    }
                }
            },
            x: {
                min: 0,
                max: maxRPM,
                type: 'linear',
                position: 'bottom'
            }

        },
        animation: false
    }
}

const ctxTest = document.getElementById('myChart').getContext('2d');
const chartTest = new Chart(ctxTest, confTest);

function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min)) + min;
}
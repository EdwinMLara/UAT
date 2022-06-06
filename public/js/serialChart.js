const numData = 200;
const increment = 16000/numData;
const rpm = new Array(numData);

for(let i=0;i<numData;i++){
    rpm[i] = i*increment;
}

const dataSave = {
    fun0 : [],
    fun1 : [],
    fun2 : [],
    fun3 : []
};

const dataChart = {
    fun0 : [],
    fun1 : []
};

const data = {
    labels:rpm,
    datasets:[
        {
            label:'Torque',
            data:dataChart.fun0,
            backgroundColor:'red',
            yAxisId:'torque'
        },
        {
            label:'Potencia',
            data:dataChart.fun1,
            backgroundColor:'blue',
            yAxisId:'potencia'
        }
    ]
}

const conf = {
    type:'line',
    data:data,
    options:{
        responsive:false,
        plugins:{
            title:{
                display:true,
                text:'Eje izquierdo Torque, Derecho potencia'
            }
        },
        scales:{
            torque:{
                type:'linear',
                display:true,
                position:'left',
                min:0,
                max:150,
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
                max:100,
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

//const ctx = document.getElementById('myChart').getContext('2d');
//const chart = new Chart(ctx,conf);
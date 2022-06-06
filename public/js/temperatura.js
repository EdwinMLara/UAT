const optsTemperatura = {
    angle: 0.15, 
    lineWidth: 0.44, 
    radiusScale: 1, 
    pointer:{
        length:0.6,
        strokeWidth:0.035,
        color:'#000000'
    },
    limitMax:true,
    limitMin:true,
    renderTicks:{
        divisions:9,
        divWidth:1.1,
        divLength:0.7,
        divColor:'#333333',
        subDivitions:3,
        sunLength:0.5,
        subWidth:0.6,
        subColor:'#666666'
    },
    staticLabels:{
        font:'10px sans-serif',
        labels:[0,30,60,80,110,130,150,180],
        color:'#000000',
        fractionsDigits:0
    },
    staticZones:[
        {strokeStyle:'#335EFF',min:0,max:95},
        {strokeStyle:'#30B32D',min:95,max:150},
        {strokeStyle:'#F03E3E',min:150,max:180},
    ]
}

const targetTemperatura = document.getElementById('canvasTemperatura');
const gaugeTemperatura = new Gauge(targetTemperatura).setOptions(optsTemperatura);
gaugeTemperatura.maxValue = 180;
gaugeTemperatura.setMinValue(0);
gaugeTemperatura.animationSpeed = 1;
gaugeTemperatura.set(100);

const temperaturaDataP = document.getElementById('temperaturaData');
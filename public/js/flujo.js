const  optsFlujo = {
    angle: 0.15, 
    lineWidth: 0.44, 
    radiusScale: 1, 
    pointer: {
        length: 0.6, 
        strokeWidth: 0.035,
        color: '#000000'
    },
    limitMax: true,
    limitMin: true,
    colorStart: '#6FADCF',
    colorStop: '#8FC0DA',
    strokeColor: '#E0E0E0',
    generateGradient: true,
    highDpiSupport: true,
};

const targetFlujo = document.getElementById('canvasFlujo');
const gaugeflujo = new Gauge(targetFlujo).setOptions(optsFlujo);
gaugeflujo.maxValue = 30;
gaugeflujo.setMinValue(0);
gaugeflujo.animationSpeed = 1;
gaugeflujo.set(15);

const flujoDataP = document.getElementById('flujoData');
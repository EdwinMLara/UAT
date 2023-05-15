import express from 'express';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import SerialPort from 'serialport';
import http from 'http';
import {Server} from 'socket.io';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config();

const app = express();
const httpPort = process.env.PUERTO_HTTP;
const serialPort = process.env.PUERTO_SERIAL_WINDOWS;
const serialstatus = [false];


const server = http.createServer(app);
const io = new Server(server);

app.use(express.static(__dirname+'/node_modules/chart.js/dist/'));
app.use(express.static(__dirname+'/public'));

const serial = new SerialPort(process.env.PUERTO_SERIAL_WINDOWS,{
    baudRate:115200
});

const ReadLine = SerialPort.parsers.Readline;
const parser = serial.pipe(new ReadLine({delimiter: '\r\n'}));

serial.on('open',() =>{
    console.log(`Se abrio del puerto serial ${serialPort}`);
    serialstatus[0] = false;
});

parser.on('data',(data)=>{
    //console.log(data);
    io.emit('arduinoData',{
        value: data.toString()
    });
});

serial.on('error',(err) =>{
    console.log(`Se genero un error: ${err.message}`);
    serialstatus[0] = true;
});

serial.on('close',()=>{
    console.log("Serial Cerrado");
});
    
app.get('/',(req,res)=>{
    console.log(req);
    res.sendFile(index);
});

io.on('connection', socket =>{
    console.log('Se ha iniciado una conecxion');

    socket.on('arduinoData',data =>{
        //console.log(data);
        if(data.hasOwnProperty('message')){
            if(data.message.localeCompare('iniciar') === 0){
                if(serialstatus[0]){
                    console.log("Enviando Error");
                    socket.emit('arduinoData',{error:'serial'});
                }
            }
        }

     });

    socket.on('disconnect', function() {
        console.log('Socket disconnected');
    });
});

server.listen(httpPort,() => {
    console.log(`Se inicio el servidor en el puerto ${httpPort}`);
});
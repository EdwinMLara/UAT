import {createReadStream,writeFile } from 'fs';
import csv from 'csv-parser';

const csvFilePath = './prueba.csv';


function readCsv(csvFilePath) {
    return new Promise((resolve, reject) => {
        const array = [];

        createReadStream(csvFilePath)
        .pipe(csv())
        .on('data', (row) => {
            array.push(row);
        })
        .on('end', () => {
            resolve(array);
        })
        .on('error',(error) => {
            reject(error);
        })
    })
}

readCsv(csvFilePath)
.then((values) => {
    let suma = 0;
    let sumaEncoder = 0;
    let count = 0;
    let csvContent = '';
    let csvContentEncoder = '';
    for(let i = 0; i < values.length ; i++){
        if (count === 10){
            let torque = suma*0.1*0.16007*9.806
            let rpm = sumaEncoder*0.1*1.3*1.9;
            suma = 0;
            sumaEncoder = 0;
            count = 0;
            csvContent += torque + ',';
            csvContentEncoder += rpm + ',';
        }
        suma += parseFloat(values[i].celda);
        sumaEncoder += parseFloat(values[i].encoder);
        count+=1;
    }
    csvContent += '\n' + csvContentEncoder; 
    let saveFilePath = './Prueba11.csv'; 
    writeFile(saveFilePath, csvContent, (err) => {
        if (err) {
          console.error('Error creating CSV file:', err);
        } else {
          console.log('CSV file created successfully:', saveFilePath);
        }
    });
})
.catch(error => {
    console.log(error);   
})
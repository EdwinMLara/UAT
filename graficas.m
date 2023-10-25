clear all;
clc;
M = csvread('prueba.csv',1,0);
torque = M(:,1).*0.16007.*9.806;
encoder = M(1:end-100,2).*1.3.*1.9;
flujo = M(:,3);
RPM = M(:,4);

nDatosTorque = size(torque);
total = floor(nDatosTorque(1)/10);
RPM10mado = zeros(total,1);

nDatosRPM = size(RPM);
con = 1;

for k=1:1:nDatosRPM(1)
    if con == total
        break;
    end
    if RPM(k,1) ~= 0
        RPM10mado(con,1) = RPM(k,1);
        con = con + 1;
    end    
end

torque10Mado = zeros(total,1);
encoder10Mado = zeros(total,1);
flujo10Mado = zeros(total,1);

con = 1;
max = nDatosTorque(1)-9;

for i=1:10:max
    auxSumaTorqueP = sum(torque(i:i+9))/10;
    torque10Mado(con,1) = auxSumaTorqueP;
    
    auxSumaEncoderP =  sum(encoder(i:i+9)/10);
    encoder10Mado(con,1) = auxSumaEncoderP;
    
    auxSumaFlujoP = sum(flujo(i:i+9)/10);
    flujo10Mado(con,1) = auxSumaFlujoP;
    
    con = con + 1;
end

figure(1);
plot(encoder10Mado,torque10Mado);
grid on;
ylabel('Torque');
xlabel('RPM');

errorRPM = RPM10mado - encoder10Mado;
errorPromedio = mean(errorRPM);
errorPromedio

figure(2);
plot(RPM10mado,'r');
hold on;
plot(encoder10Mado,'b');
grid on;
ylabel('RPM');
xlabel('N datos');
legend('ECU','Encoder');
hold off;

figure(3)
plot(encoder10Mado,flujo10Mado);
grid on;
xlabel('RPM - encoder');
ylabel('Flujo');
datosSensor = ImportarDatos.Sensor();
datosCordenadasSensor = ImportarDatos.SensorCordenadas(datosSensor);

Graficas.velocidadTiempo(datosCordenadasSensor, '2024-02-15 00:30:00.434', '2024-02-15 23:35:00.434')
Graficas.aceleracionTiempo(datosCordenadasSensor, '2024-02-15 00:30:00.434', '2024-02-15 23:35:00.434')
%%
datosP20 = ImportarDatos.P20();
datosCordenadasP20 = ImportarDatos.P20Cordenadas(datosP20);
mygrafica = Graficas.velocidadTiempo(datosCordenadasP20, '2024-02-14 00:30:00.434', '2024-02-15 23:35:00.434');
Graficas.aceleracionTiempo(datosCordenadasP20, '2024-02-14 00:30:00.434', '2024-02-15 23:35:00.434')




mymap = Map.FiltrarYMostrarRuta(datosCordenadasP20, '2024-02-14 07:30:00.434', '2024-02-14 07:59:00.434');
%%
datosEventos = ImportarDatos.Evento1();
datosEventosCord = ImportarDatos.Evento1Coordenadas(datosEventos);
Graficas.Evento1(datosEventosCord, '2024-02-14 00:30:00.434', '2024-02-15 23:35:00.434', mygrafica)
%%

%mymap = Map.FiltrarYDibujarVelocidad(datosCordenadasSensor, '2024-02-15 08:45:00.434', '2024-02-15 08:49:00.434');
mymap = Map.FiltrarYDibujarCurvatura(datosCordenadasSensor, '2024-02-15 08:00:00.434', '2024-02-15 08:49:00.434');
%%
velocidadSensor = Calculos.calcularVelocidad(datosCordenadasSensor);
aceleracion= Calculos.calcularAceleracion(datosCordenadasSensor);
%%
datosP20 = ImportarDatos.P20();
datosCordenadasP20 = ImportarDatos.P20Cordenadas(datosP20);
%mymap = Map.FiltrarYMostrarRuta(datosCordenadasP20, '2024-02-14 07:30:00.434', '2024-02-14 07:59:00.434');
%%
datosEventos = ImportarDatos.Evento1();
datosEventosCord = ImportarDatos.Evento1Coordenadas(datosEventos);
%mymap = Map.FiltrarYAgregarMarcadores(datosEventosCord, '2024-02-14 07:30:00.434', '2024-02-14 07:59:00.434', mymap);


%%
mymap = Map.FiltrarYDibujarVelocidad(datosCordenadasSensor, '2024-02-15 08:45:00.434', '2024-02-15 08:49:00.434');
%%
%calcular aceleración
%T=seconds(diff(datosCordenadasSensor.time));

%%
for k=1:size(aceleracion)
    try
            if (abs(aceleracion(k))>3)%determina el limite de aceleración 
                for b=k:size(aceleracion)
                    if(abs(aceleracion(b))<3)%busca el siguiente punto bueno
                        a=b;
                        break;
                    end
                end
                p=((velocidadSensor(b)-velocidadSensor(k-1))/(b-k));
                z=0;
                for b=k:a
                    velocidadSensor(b)=(z*p)+velocidadSensor(k-1);
                    z=z+1;
                end
                %velocidades_matriz{j, 1} =correccion(velocidades_matriz,j,k); %se igual a la velocidad normal
                k=a;                
            end
        catch
            velocidadSensor=velocidadSensor;
        end
end

%aceleracion= Calculos.calcularAceleracion(datosCordenadasSensor);





function d = gps_distance(lat1,lon1,lat2,lon2)
    % Distance in km between 2 gps coordinates in decimals
    dlat = deg2rad(lat1-lat2);
    dlon = deg2rad(lon1-lon2);
    lat1 = deg2rad(lat1); 
    lat2 = deg2rad(lat2);
    % lon1 = deg2rad(lon1); lon2 = deg2rad(lon2); 
    a = (sin(dlat/2).*sin(dlat/2)) + ((cos(lat1).*cos(lat2)).*(sin(dlon/2).*sin(dlon/2)));
    b = 2.*atan2(sqrt(a),sqrt(1-a));
    d = 6371*b; % Earth radius = 6371km o 6371000m
end

function radio = determinar_curvatura_3puntos(p1, p2, p3)
    % Determina la curvatura de una curva definida por tres puntos en un plano cartesiano.
    % :param p1: Coordenadas del primer punto (x, y).
    % :param p2: Coordenadas del segundo punto (x, y).
    % :param p3: Coordenadas del tercer punto (x, y).
    % :return: Radio de curvatura de la curva en metros.
    
    % Calcula las diferencias entre las coordenadas de los puntos adyacentes para obtener las pendientes de las líneas.
    %voy a tomar latitud y y longitud x
    a1 = p1.lat - p2.lat;
    b1 = p2.lon - p1.lon;
    a2 = p2.lat - p3.lat;
    b2 = p3.lon - p2.lon;
    
    % Calcula los puntos medios entre p1 y p2, y entre p2 y p3.
    punto_medio1 = [(p1.lon + p2.lon) / 2, (p1.lat + p2.lat) / 2];
    punto_medio2 = [(p2.lon + p3.lon) / 2, (p2.lat + p3.lat) / 2];
    
    % Construye un sistema de ecuaciones lineales con las pendientes calculadas anteriormente.
    ecu = [b1, -a1; b2, -a2];
    sol = [punto_medio1(1) * b1 - a1 * punto_medio1(2) ; punto_medio2(1) * b2 - a2 * punto_medio2(2)];
    
    %try
        % Intenta resolver el sistema de ecuaciones lineales para encontrar el punto de intersección.
        cordInter = linsolve(ecu, sol);
        % Calcula el radio del círculo que mejor se ajusta a los tres puntos dados.
        radio = sqrt(((cordInter(1) - p2.lon) ^ 2) + ((cordInter(2) - p2.lat) ^ 2)) * (111.32 * 1000);%radio en metros
    %catch
        % Si la solución del sistema de ecuaciones falla, establece el radio como -1.
        %radio = -1;
    %end
end



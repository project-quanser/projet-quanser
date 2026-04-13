% chargement de la carte sauvegardé
try
    load('map.mat')
catch
    warning('failed to load map.mat');
end


% SETUP QUANSER QBOT
caseNum = 3; % 1, 2, 3, or 4

slipmat = true; walls = true;

system('quanser_host_peripheral_client.exe -q');
pause(2)
system('quanser_host_peripheral_client.exe  -uri tcpip://localhost:18444 &');

% MATLAB Path

newPathEntry = fullfile(getenv('QAL_DIR'), '0_libraries', 'matlab', 'qvl');
pathCell = regexp(path, pathsep, 'split');
if ispc  % Windows is not case-sensitive
  onPath = any(strcmpi(newPathEntry, pathCell));
else
  onPath = any(strcmp(newPathEntry, pathCell));
end

if onPath == 0
    path(path, newPathEntry)
    savepath
end

% Stop RT models
try
    qc_stop_model('tcpip://localhost:17000', 'qbot_platform_driver_virtual')
    pause(1)
    qc_stop_model('tcpip://localhost:17000', 'QBotPlatform_Workspace')
catch error
end
pause(1)

% QLab connection
qlabs = QuanserInteractiveLabs();
connection_established = qlabs.open('localhost');

if connection_established == false
    disp("Failed to open connection. Are you sure Quanser QLab is running ?")
    return
end
disp('Connected to Quanser Qlab')
verbose = true;
num_destroyed = qlabs.destroy_all_spawned_actors();

% Tapis
if slipmat == true
    hFloor0 = QLabsQBotPlatformFlooring(qlabs);
    % center
    hFloor0.spawn_id(0, [-0.6, 0.6,   0], [0,0,-pi/2], [1,1,1], 5, false); 
    % corners
    hFloor0.spawn_id(1, [ 0.6, 1.8,   0], [0,0,-pi/2], [1,1,1], 0, false);
    hFloor0.spawn_id(2, [ 1.8,-0.6,   0], [0,0, pi  ], [1,1,1], 0, false);
    hFloor0.spawn_id(3, [-0.6,-1.8,   0], [0,0, pi/2], [1,1,1], 0, false);
    hFloor0.spawn_id(4, [-1.8, 0.6,   0], [0,0,    0], [1,1,1], 0, false);
    % sides
    hFloor0.spawn_id(5, [-0.6, 0.6,   0], [0,0,    0], [1,1,1], 5, false);
    hFloor0.spawn_id(6, [ 0.6, 0.6,   0], [0,0,-pi/2], [1,1,1], 5, false);
    hFloor0.spawn_id(7, [ 0.6,-0.6,   0], [0,0, pi  ], [1,1,1], 5, false);
    hFloor0.spawn_id(8, [-0.6,-0.6,   0], [0,0, pi/2], [1,1,1], 5, false);
end


if walls
    % Walls
    hWall = QLabsWalls(qlabs, verbose);
    hWall.spawn_degrees([2, 1.2, 0.1], [0, 0, 0]);
    hWall.set_enable_dynamics(true);
    hWall.spawn_degrees([2, 0, 0.1], [0, 0, 0]);
    hWall.set_enable_dynamics(true);
    hWall.spawn_degrees([2, -1.2, 0.1], [0, 0, 0]);
    hWall.set_enable_dynamics(true);
    hWall.spawn_degrees([-2, 1.2, 0.1], [0, 0, 0]);
    hWall.set_enable_dynamics(true);
    hWall.spawn_degrees([-2, 0, 0.1], [0, 0, 0]);
    hWall.set_enable_dynamics(true);
    hWall.spawn_degrees([-2, -1.2, 0.1], [0, 0, 0]);
    hWall.set_enable_dynamics(true);
    hWall.spawn_degrees([1.2, 2, 0.1], [0, 0, 90]);
    hWall.set_enable_dynamics(true);
    hWall.spawn_degrees([0, 2, 0.1], [0, 0, 90]);
    hWall.set_enable_dynamics(true);
    hWall.spawn_degrees([-1.2, 2, 0.1], [0, 0, 90]);
    hWall.set_enable_dynamics(true);
    hWall.spawn_degrees([1.2, -2, 0.1], [0, 0, 90]);
    hWall.set_enable_dynamics(true);
    hWall.spawn_degrees([0, -2, 0.1], [0, 0, 90]);
    hWall.set_enable_dynamics(true);
    hWall.spawn_degrees([-1.2, -2, 0.1], [0, 0, 90]);
    hWall.set_enable_dynamics(true);
end

% Définir les Waypoints [x, y, theta]
waypoints = [
    0,    0,    0;          % Point de départ 
    1, 0,  -pi/4;
    0,    -1,  -pi;
    -1, 0, pi/2;
    0, .75, -pi/4;
    1, 0, -pi/2;
   % 
   %    0,    0,    0;
   %  1,    0,   -pi/4;
   %  0,   -1,   -pi;
   % -1,    0,    pi/2;
   %  0,   0.75, -pi/4;
   %  1,    0,   -pi/2;

];

% % waypoints
% waypointsObj = QLabsBasicShape(qlabs, verbose);
% 
% % startpoint
% [~, startpoint] = waypointsObj.spawn([waypoints(1,1), waypoints(1,2),0], [0,0,waypoints(1,3)], [0.1,0.3,1], QLabsBasicShape.SHAPE_CUBE);
% waypointsObj.actorNumber = startpoint;
% waypointsObj.set_enable_collisions(false);
% waypointsObj.set_material_properties([0.0, 0.0, 0.7]);
% 
% % waypoints intermediaire
% for w = waypoints(2:end-1, :)' % le ' inverse lignes et colonnes
%     [~, way] = waypointsObj.spawn([w(1),w(2),0], [0,0,w(3)], [0.1,0.3,1], QLabsBasicShape.SHAPE_CUBE);
%     waypointsObj.actorNumber = way;
%     waypointsObj.set_enable_collisions(false);
%     waypointsObj.set_material_properties([0.0, 0.7, 0.7]);
% end
% 
% % Arrivee
% [~, fin] = waypointsObj.spawn([waypoints(end, 1),waypoints(end, 2),0], [0,0, waypoints(end, 3)], [0.1,0.3,1], QLabsBasicShape.SHAPE_CUBE);
% waypointsObj.actorNumber = fin;
% waypointsObj.set_enable_collisions(false);
% waypointsObj.set_material_properties([0.0, 0.7, 0.0]);

% Obstacles depuis la carte
obstaclesObj = QLabsBasicShape(qlabs, verbose);
obstaclesMap = map;
obstacles = [];
rayon = 1/pointPerMeter;
for y = 1:length(map(1, :))
    for x = 1:length(map(:,1))
        if map(x,y) >= .3
            coordinateX = (y/pointPerMeter)-(length(map(1, :))/pointPerMeter)/2; % for sure optimizable
            coordinateY = (x/pointPerMeter)-(length(map(1, :))/pointPerMeter)/2;
            % obstaclesObj.spawn([coordinateX, coordinateY, 0], [0,0,0], [rayon, rayon,1], QLabsBasicShape.SHAPE_CYLINDER);
            obstacles = [obstacles; coordinateX, coordinateY, rayon;]; % pour simulink
        end
    end
end

% Obstacles
obstaclesObj = QLabsBasicShape(qlabs, verbose);

% Obstacles
obs = [
    %-1, 0, 1.0;
     1.0, 1.25, .80;
    % -1.5, -0.1, .2 ; 
    %  1, 0.0, .4;
    %  0.0, -1, 0.5;
];

for obs = obs'
    obstaclesObj.spawn([obs(1), obs(2), 0], [0,0,0], [obs(3),obs(3),1], QLabsBasicShape.SHAPE_CYLINDER);
end


% QBot
hQBot = QLabsQBotPlatform(qlabs, verbose);
location = [0, 0, 0; -1.35, 0.3, 0; -1.5, 0, 0; -1.5, 0, 0];
rotation = [0, 0, 0;    0,   0, 0;   0, 0, 90;  0, 0, -90];
    hQBot.spawn_id_degrees(0, [waypoints(1,1), waypoints(1,2), 0], [0,0,rad2deg(waypoints(1,3))], [1, 1, 1], 1) ;
    hQBot.possess(hQBot.VIEWPOINT_TRAILING);

    file_workspace = fullfile(getenv('RTMODELS_DIR'), 'QBotPlatform', 'QBotPlatform_Workspace.rt-win64');
    file_driver    = fullfile(getenv('RTMODELS_DIR'), 'QBotPlatform', 'qbot_platform_driver_virtual.rt-win64');


% Start RT models
pause(2)
system(['quarc_run -D -r -t tcpip://localhost:17000 ', file_workspace]);
pause(1)
system(['quarc_run -D -r -t tcpip://localhost:17000 ', file_driver, ' -uri tcpip://localhost:17098']);
pause(3)

% Camera
cam = QLabsFreeCamera(qlabs, verbose);
cam.spawn([0.0, 0, 4.0], [0, 90, 90.0], [1 1 1]);
cam.set_camera_properties(90, true, 2.3, 10.0);
cam.set_transform_degrees([0.0, 0, 4.0], [-0, 90.0, 90.0]); % valeurs trouvées manuellement
status = cam.possess();

% VARIABLES UTILISE DANS SIMULINK
%parametre de la simulation
T_sim = 100;                     %Durée de la simulation 
dt = 0.01;                      % Pas de la simulation ( en terme de temps)
time = 0:dt:T_sim;

%Paramètres du controleur ( le fameux "Gain Schduling" du paper)
zeta = 0.7;                     % sqrt(2)/2 cf cours
g = 10;                         % Gain de liberté pour k2

% Conditions initiales du Robot (x, y, theta) 
x0 =  waypoints(1,1);
y0 =  waypoints(1,2);                      
theta0 = waypoints(1,3);

L = 0.390; % entraxe
R = 0.044; % rayon des roues


%% Configuration du Nonlinear MPC
nx = 3; % Nombre d'états (x, y, theta)
ny = 3; % Nombre de sorties mesurées (x, y, theta de l'EKF)
nu = 2; % Nombre de commandes (v, omega)

% Création de l'objet
nlobj = nlmpc(nx, ny, nu);

% Paramètres d'horizon 
nlobj.Ts = 0.1;
nlobj.PredictionHorizon = 25;
nlobj.ControlHorizon = 3; %25

% Assignation du modèle physique
nlobj.Model.StateFcn = "qbot_kinematics";
nlobj.Model.IsContinuousTime = true; % Le solveur discretisera lui-même

% Contraintes sur les commandes 
nlobj.MV(1).Min = -0.5; % v min
nlobj.MV(1).Max =  0.5; % v max
nlobj.MV(2).Min = -2.0; % omega min
nlobj.MV(2).Max =  2.0; % omega max

% Poids par défaut (tes matrices Q, R, S) 
% Poids sur l'erreur de suivi (x, y, theta) - matrice Q
%nlobj.Weights.OutputVariables = [10, 10, 2]; 
%nlobj.Weights.OutputVariables = [10, 10, 5];
nlobj.Weights.OutputVariables = [10, 10, 0.1]; %bof mais good 

% Poids sur l'effort de commande (v, omega) - matrice R
nlobj.Weights.ManipulatedVariables = [0.1, 0.1]; 

% Poids sur la variation de commande (delta u) - matrice S
%nlobj.Weights.ManipulatedVariablesRate = [0.5, 3]; % à tester
%nlobj.Weights.ManipulatedVariablesRate = [1, 1]; % à tester
nlobj.Weights.ManipulatedVariablesRate = [1, 8]; %good
% nlobj.Weights.ManipulatedVariablesRate = [5, 20]; pas fou 
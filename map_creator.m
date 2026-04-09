% Script permettant de creer un fichier de la map à partir des infos du
% Lidar

clearvars;
%% Setup QUanser classique
% On commence par setup le quanser de maniere classique
caseNum = 1; % 1, 2, 3, or 4

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
    disp("Failed to open connection.")
    return
end
disp('Connected')
verbose = true;
num_destroyed = qlabs.destroy_all_spawned_actors();

% Flooring
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

% QBot
hQBot = QLabsQBotPlatform(qlabs, verbose);
location = [0, 0, 0; -1.35, 0.3, 0; -1.5, 0, 0; -1.5, 0, 0];
rotation = [0, 0, 0;    0,   0, 0;   0, 0, 90;  0, 0, -90];
    hQBot.spawn_id_degrees(0, location(caseNum, :), rotation(caseNum, :), [1, 1, 1], 1) ;
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
cam.spawn([0.0, 0, 4.0], [-0, 90.0, 180.0], [1 1 1]);
cam.set_camera_properties(90, true, 2.3, 10.0);
cam.set_transform_degrees([0.0, 0, 4.0], [-0, 90.0, 180.0]); % valeurs trouvées manuellement
status = cam.possess();

if ~status
    disp('Failed to take control of the camera');
end

% Obstacles
obstacles = [
    %-1, 0, 1.0;
    1.0, 1.25, .80;
    % -1.5, -0.1, .2 ; 
    %  1, 0.0, .4;
    %  0.0, -1, 0.5;
];

obstaclesObj = QLabsBasicShape(qlabs, verbose);

for obs = obstacles'
    obstaclesObj.spawn([obs(1), obs(2), 0], [0,0,0], [obs(3),obs(3),1], QLabsBasicShape.SHAPE_CYLINDER);
end

pointPerMeter = 50; % précision a 2cm pres
mapHeight = 7; mapWidth = 7; % en m (avec une certaine marge

map = zeros(mapHeight*pointPerMeter, mapWidth*pointPerMeter);

%% Cartographie
% Fuck la commande en boucle fermee je fais en boucle ouverte
% fuck la boucle ouverte le robot va se TELEPORTER
location=[0, 0, 0];
rotation=[0, 0, 0];
scale=[1, 1, 1];
leftLED=[1, 0, 0];
rightLED=[1, 0, 0];
enableDynamics=true;
waitForConfirmation=true;

locPoints = [
    0 0 0;
    1 -.5 0;
    -1 -1 0; 
    -1 1 0;
    0 1 0;
    -1 1.5 0;
    1 -1.5 0;
    -1 -.5 0;
    0 0 0;
    ];
nbTests = length(locPoints); %  nb de teleportaions du robot
lidarOffset = 9.5*0.0254; % le lidar est 9,5 pouces (~2,54cm) devant le CDG 

for pos = 1:nbTests
    location = locPoints(pos, :);
 
    hQBot.set_transform(location, rotation, scale , leftLED, rightLED, enableDynamics,waitForConfirmation);
    [lidarStatus, angles, distances] = hQBot.get_lidar();
    pause(0.5);

    if lidarStatus
        % On enlève les mesures valant 0 (hors de la reach du LiDAR)
        angles(distances == 0) = [];
        distances(distances == 0) = []; 
        converted_distance = distances.*pointPerMeter; % On se met à l'échelle de la carte
        [x, y] = pol2cart(angles, converted_distance);

        lidar_x = location(1) + lidarOffset; % prise en compte de l'offset (vu que j'ai pas d'angle que le x change)

        offset_x = lidar_x* pointPerMeter; offset_y =  location(2)* pointPerMeter; % prise en compte de la position du robot
        center_x = ceil((mapHeight*pointPerMeter /2) + offset_x); center_y = ceil((mapWidth*pointPerMeter / 2) + offset_y);

        columns = center_x + x; rows = center_y - y;
    
        index = sub2ind(size(map), ceil(rows), ceil(columns));
        map(index) = map(index) + (1 / nbTests);

        % nexttile
        % polarscatter(angles, converted_distance);
        % title("LiDAR n°" + pos);
        % 
        % nexttile
        % colormap jet;
        % imagesc(map);
        % colorbar;
        % title("Cartographie n°" + pos);
    else
        warning('Échec de lecture LIDAR');
    end
end

% Export de la carte
fileName = 'map.mat';
disp("export de la carte dans " + fileName);
elems(1) = Simulink.BusElement;
elems(1).Name = "map";
save(fileName, "map", "pointPerMeter");

%% Traitement d'image
% binarisation de la carte
% figure
% tiledlayout(1, 3);
% 
% % joli mise en forme
% nexttile
colormap parula;
imagesc(map);
colorbar;
title("Cartographie après " + nbTests + " scans.");
% 
% nexttile
% binaryMap = map;
% seuil = .3; % si l'obstacle a été scanné 30% du temps
% binaryMap(map <= seuil) = 0;
% binaryMap(map > seuil) = 1;
% 
% colormap parula;
% imagesc(binaryMap);
% colorbar;
% title("Carte après binarisation")
% 
% % dilatation
% connexite = 2; % on va voir les pixel avec 2 pixels d'ecart
% dilatedMap = binaryMap;
% dilatedMap(connexite+1: end-connexite, connexite+1: end-connexite);


%% test de l'orientation
% margin = 25; % deg
% rotationTest = ceil(linspace(1, 360, 40));
% errorEvolution = zeros(1, length(rotationTest));
% 
% thetaRobot = rotationTest; %awgn(rotationTest, 1.2,'measured');
% noise = (rand(size(thetaRobot)) * 2 * margin) - margin;
% thetaRobot = thetaRobot + noise;
% % for i = 1:length(rotationTest)
% %     thetaRobot(i) = thetaRobot(i) + randi([rotationTest(i)-nbValuesToTest, rotationTest(i)+nbValuesToTest], 1, 1); % en degré
% % end
% 
% location = [0 0 0];
% hQBot.set_transform([0 0 0], rotation, scale , leftLED, rightLED, enableDynamics,waitForConfirmation);
% [lidarStatus, angles, distances] = hQBot.get_lidar();
% 
% historiquetheta = ones(1, length(rotationTest));
% 
% 
% figure
% 
% % on fait x tests pour voir l'erreur moyenne
% for test = 1:length(rotationTest)
%     rotation(3) = deg2rad(rotationTest(test));
%     hQBot.set_transform([0 0 0], rotation, scale , leftLED, rightLED, enableDynamics,waitForConfirmation);
%     [lidarStatus, angles, distances] = hQBot.get_lidar();
%     matchList = zeros(1, length(angles));
% 
%     ecartAngles = mean(diff(angles)); % l'écart moyen etre chaques angles (rad)
% 
%     angles_copy = angles; %circshift(angles, ceil(deg2rad(thetaRobot(test))/ecartAngles));
% 
%     converted_distance = distances.*pointPerMeter; % On se met à l'échelle de la carte
% 
%     for rot = 1:length(angles)
%         [x, y] = pol2cart(angles_copy, converted_distance);
% 
%         columns = center_x + x; rows = center_y - y;
%         index = sub2ind(size(map), ceil(rows), ceil(columns));
%         matchList(rot) = sum(map(index));
% 
% 
%         % disp("La rotation de "+rot+" tours a une correspondance de " + matchList(rot) + "avec la carte.");
% 
%         angles_copy = circshift(angles, rot); % on modifie pas la liste originelle j'ai l'impression ça casse tout sinon
%     end
% 
%     % matchList = circshift(matchList, ceil(deg2rad(thetaRobot(test))/ecartAngles)); % on redécale pour prendre en compte l'angle originel (?)
% 
%     % plot(matchList)
% 
%     % on applique une distribution normale centrée en l'angle perçue par
%     % l'odometrie
%     sigma = 45;
%     x_vector = 1:length(matchList);
%     coeff = exp(-(x_vector - thetaRobot(test)).^2 / (2 * sigma^2));
% 
%     matchList = matchList .* coeff;
% 
%     best_theta = find(matchList == max(matchList), 1 );
%     thetaRad = best_theta * ecartAngles;
%     thetaDeg = rad2deg(thetaRad);
% 
%     % disp("L'erreur de theta est de " + best_theta + " rotations, soit " + thetaRad + "rad, soit " + thetaDeg + "°")
%     historiquetheta(test) = thetaDeg;
%     errorEvolution(test) = thetaDeg - rad2deg(rotation(3)); % mesure déduite - mesure réelle
% end
% 
% plot(rotationTest, errorEvolution);
% 
% plot(rotationTest, rotationTest);
% hold on
% plot(rotationTest, historiquetheta);
% plot(rotationTest, thetaRobot);
% 
% legend \theta_{robot} \theta_{lidar} \theta_{odom}
% title("Evolution de l'angle calculé à partir du LiDAR comparé à l'angle réel.")
% xlabel("n° de test") 
% ylabel('angle (deg)') 
% grid on


qlabs.close();
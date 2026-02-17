% Script permettant de creer un fichier de la map à partir des infos du
% Lidar

clearvars;

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
    1.0, .5, .80;
     % 2, -0.1, 0.0 ; 
     %1.5, 1.5, 0;
     %2.25, 0, 0.5;
];

obstaclesObj = QLabsBasicShape(qlabs, verbose);

for obs = obstacles'
    obstaclesObj.spawn([obs(1), obs(2), 0], [0,0,0], [obs(3),obs(3),1], QLabsBasicShape.SHAPE_CYLINDER);
end

pointPerMeter = 10; % précision au dm
mapHeight = 7; mapWidth = 7; % en m (avec une certaine marge

map = zeros(mapHeight*pointPerMeter, mapWidth*pointPerMeter);

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
    1 1.5 0;
    1 -1.5 0;
    -1 -.5 0;
    ];
nbTests = length(locPoints); %  nb de teleportaions du robot

for pos = 1:nbTests
    location = locPoints(pos, :);
 
    hQBot.set_transform(location, rotation, scale , leftLED, rightLED, enableDynamics,waitForConfirmation);
    [lidarStatus, angles, distances] = hQBot.get_lidar();
    pause(2);

    if lidarStatus
        % On enlève les mesures valant 0 (hors de la reach du LiDAR)
        angles(distances == 0) = [];
        distances(distances == 0) = []; 
        converted_distance = distances.*pointPerMeter; % On se met à l'échelle de la carte
        [x, y] = pol2cart(angles, converted_distance);

        offset_x = location(1)* pointPerMeter; offset_y =  location(2)* pointPerMeter; % prise en compte de la position du robot
        center_x = ceil((mapHeight*pointPerMeter /2) + offset_x); center_y = ceil((mapWidth*pointPerMeter / 2) + offset_y);

        columns = center_x + x; rows = center_y - y;
    
        index = sub2ind(size(map), round(rows), round(columns));
        map(index) = map(index) + (1 / nbTests);

        % nexttile
        % polarscatter(angles, converted_distance);
        % title("LiDAR n°" + pos);
        % 
        % nexttile
        % colorbar;
        % imagesc(map);
        % title("Cartographie n°" + pos);
    else
        warning('Échec de lecture LIDAR');
    end
end

% joli mise en forme
colormap jet;
imagesc(map');
colorbar;
title("Cartographie après " + nbTests + " scans.");

qlabs.close();

fileName = 'map.mat';
disp("export de la carte dans " + fileName);
save(fileName, "map", "pointPerMeter");
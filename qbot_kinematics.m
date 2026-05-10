function dxdt = qbot_kinematics(x, u)
    % Modèle cinématique continu du QBot
    % x(1) = x, x(2) = y, x(3) = theta
    % u(1) = v (vitesse linéaire), u(2) = omega (vitesse angulaire)
    
    dxdt = zeros(3,1);
    dxdt(1) = u(1) * cos(x(3));
    dxdt(2) = u(1) * sin(x(3));
    dxdt(3) = u(2);
end
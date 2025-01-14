tic;
numC = 0; % number of quantum coins
nbQubits = 13; % number of register qubits
nbQubits = nbQubits + numC; %total number of qubits

% Call necessary gates
CX = @qclab.qgates.CNOT;
Rx = @qclab.qgates.RotationX;
Ry = @qclab.qgates.RotationY;
Rz = @qclab.qgates.RotationZ;
S = @qclab.qgates.Phase;
H = @qclab.qgates.Hadamard;
MCP = @qclab.qgates.MCPhase;
Phase90 = @qclab.qgates.Phase90;

% Make 1d Image
% A = [50*ones(floor(nbQubits/3),1);100*ones(nbQubits-2*floor(nbQubits/3),1); 50*ones(floor(nbQubits/3),1)];
A = [50*ones(3,1);100*ones(7,1); 50*ones(3,1)];
%A = 20:10:100;
c = gray(100);
%
%%

% Define labels
%L = [1,2];
% Set seeds: 1 - white, 2 - black
%seeds = [65,1,1; 200, 1, 1;
%    15,1, 2; 120,1, 2];

% 
% Make theta parameters for each location on the ring
seed = 1;
theta_local = zeros(nbQubits,1);
beta = 10;
for i = 1:nbQubits
    if i == nbQubits
        theta_local(i) = 0;
        %theta_local(i) = exp(-beta * ( sum((c(A(i)) - c(A(1))).^2) ));
    else
        %theta_local(i) = exp(-beta * ( sum((c(A(i)) - c(A(i+1))).^2) ));
        theta_local(i) = beta*(sum(c(A(i)) - c(A(i+1))).^2/(sum((c(A(i)) - c(A(i+1))).^2+1) ));
    end
end
theta_local(1:nbQubits-1) = pi/40 + theta_local(1:nbQubits-1);

local_circuit = qclab.QCircuit( nbQubits ) ;

% QASM
fID = 1;
fprintf( fID, '\n\nQASM output:\n\n' );
fprintf( fID, 'OPENQASM 2.0;\ninclude "qelib1.inc";\n\n');
fprintf( fID, 'qreg q[%d];\n',nbQubits);
local_circuit.toQASM( fID );

% 2-qubit block:
% function 

% circuit

for i=0:nbQubits-1
    local_circuit.push_back(H(i));
    local_circuit.push_back(S(i,-pi/2));
    local_circuit.push_back(H(i));
end

for i = 0:2:nbQubits-2
    j = i+1;
    local_circuit.push_back(CX(i,j));
    local_circuit.push_back(Rx(i,2*theta_local(i+1)));
    local_circuit.push_back(Rz(j,2*theta_local(i+1)));
    local_circuit.push_back(CX(i,j));
end

for i = 1:2:nbQubits-2
    j = i+1;
    local_circuit.push_back(CX(i,j));
    local_circuit.push_back(Rx(i,2*theta_local(i+1)));
    local_circuit.push_back(Rz(j,2*theta_local(i+1)));
    local_circuit.push_back(CX(i,j));
end

local_circuit.push_back(CX(nbQubits-1,0));
    local_circuit.push_back(Rx(nbQubits-1,2*theta_local(nbQubits)));
    local_circuit.push_back(Rz(0,2*theta_local(nbQubits)));
    local_circuit.push_back(CX(nbQubits-1,0));

for i=0:nbQubits-1
    local_circuit.push_back(H(i));
    local_circuit.push_back(S(i,pi/2));
    local_circuit.push_back(H(i));
end

local_circuit.draw( fID, 'S' );

% Simulate
qpos = zeros(nbQubits,1);
for i = 0:nbQubits-1
    qpos(i+1) = 2^(i)+1;
end
init = qpos(seed);

psi = zeros(2^nbQubits,1);
psi(init) = 1;
T = 5;
p = zeros(2^nbQubits,T+1);
p(:,1) = abs(psi).^2;

for t = 1:T
    psi = local_circuit.apply('R','N',nbQubits,psi);
    p(:,1+t) = abs(psi).^2;
end

%p_state = p([2,3,5,9,17,33,65,129,257,513,1025],:);
p_state = p(qpos,:);

p_avg_local = zeros(T+1,nbQubits);
for i = 1:T+1
    p_avg_local(i,:) = mean(p_state(:,1:i),2);
end

% figure;
% surf(p_state);
% shading interp;
% title("Distribution of state (1-D case)");
% xlabel("Time (iterations)");
% ylabel("Position of up spin");
% zlabel("Probability mass");

figure;
surf(p_avg_local);
shading interp;
cb = colorbar(); 
ylabel(cb,'Probability','FontSize',16,'Rotation',270)
title("Average distribution of state (1-D case)");
ylabel("Time (iterations)");
xlabel("Position of up spin");
zlabel("Probability mass");

toc;
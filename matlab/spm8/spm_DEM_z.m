function [z,w] = spm_DEM_z(M,N)
% creates hierarchical innovations for generating data
% FORMAT [z w] = spm_DEM_z(M,N)
% M    - model structure
% N    - length of data sequence
%
% z{i} - innovations for level i (N.B. z{end} corresponds to causes)
% w{i} - innovations for level i (state noise)
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_DEM_z.m 1703 2008-05-21 13:59:23Z karl $
 
% temporal convolution matrix (with unit variance)
%--------------------------------------------------------------------------
s  = M(1).E.s + exp(-16);
dt = M(1).E.dt;
t  = ([1:N] - 1)*dt;
K  = toeplitz(exp(-t.^2/(2*s^2)));
C  = inv(sqrt(diag(diag(K*K'))));
K  = C*K;
 
% create innovations z{i} and w{i}
%--------------------------------------------------------------------------
for i = 1:length(M)
 
    % causes
    %----------------------------------------------------------------------
    P     = M(i).V;
    for j = 1:length(M(i).Q)
        P = P + M(i).Q{j}*exp(M(i).hE(j));
    end
    z{i}  = spm_sqrtm(inv(P))*randn(M(i).l,N)*K;
    
    % states
    %----------------------------------------------------------------------
    P     = M(i).W;
    for j = 1:length(M(i).R)
        P = P + M(i).R{j}*exp(M(i).gE(j));
    end
    if length(P)
        w{i} = spm_sqrtm(inv(P))*randn(M(i).n,N)*K*dt;
    else
        w{i} = sparse(0,0);
    end
    
end




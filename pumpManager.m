% ========================================================================
classdef pumpManager
%> @class pumpManager
%> @brief Manages the Simia Pump
%>
%> Copyright ©2014-2023 HuYang — released: LGPL3
% ========================================================================


    %---------------PUBLIC PROPERTIES---------------%
    properties (Constant)
        manufacturer = 'simia'
        product      = 'pump'
    end
    
    %---------------PRIVATE PROPERTIES--------------%
    properties (Access = private)
        pumpIndex
        % pre-defined command
        giveRewardCmd         = single([1, 0, 0, 0, 0])
        giveRewardDurationCmd = single([1, 0, 0, 0, 0])
        stopRewardCmd         = single([0, 0, 1, 0, 0])
        setSpeedCmd           = single([0, 0, 0. 0, 0])
        reverseCmd            = single([0, 0, 0, 0, 1])
    end

    %=======================================================================
	methods %------------------PUBLIC METHODS
	%=======================================================================

        % ===================================================================
        function obj = pumpManager()
        % get pump index
		% ===================================================================
            devices = PsychHID('Devices');
            matchingIndices = find(strcmpi({devices.manufacturer}, obj.manufacturer) & ...
                       strcmpi({devices.product}, 'pump'));
            for idx = matchingIndices
                obj.pumpIndex = devices(idx).index;
            end
        end
        % ===================================================================
        function giveReward(obj)
        % Unlimited give rewards
		% ===================================================================
            cmd = typecast(obj.giveRewardCmd, 'uint8');
            PsychHID('SetReport', obj.pumpIndex, 2, 0, cmd);
        end

        % ===================================================================
        function giveRewardDuration(obj, duration)
        % Give rewards that last a certain amount of time
        %> @fn giveRewardDuration(obj, duration) duration: Duration in milliseconds
		% ===================================================================
            obj.giveRewardDurationCmd(2) = duration;
            cmd = typecast(obj.giveRewardDurationCmd, 'uint8');
            PsychHID('SetReport', obj.pumpIndex, 2, 0, cmd);
        end

        % ===================================================================
        function err = stopReward(obj)
        % Stop rewards
		% ===================================================================
            cmd = typecast(obj.stopRewardCmd, 'uint8');
            err = PsychHID('SetReport', obj.pumpIndex, 2, 0, cmd);
        end

        % ===================================================================
        function err = setSpeed(obj)
        % Set pump speed
		% ===================================================================
            cmd = typecast(obj.setSpeedCmd, 'uint8');
            err = PsychHID('SetReport', obj.pumpIndex, 2, 0, cmd);
        end

        % ===================================================================
        function err = reverse(obj)
        % Reverse pump running direction
		% ===================================================================
            cmd = typecast(obj.reverseCmd, 'uint8');
            err = PsychHID('SetReport', obj.pumpIndex, 2, 0, cmd);
        end
    end
end
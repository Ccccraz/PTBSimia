% ==============================================================================
%> @class pumpManager
%> @brief Manages the Simia Pump
%>
%> Copyright ©2014-2025 HuYang — released: LGPL3
% ==============================================================================
classdef pumpManager
    
    
    %---------------PUBLIC PROPERTIES---------------%
    properties (Constant)
        manufacturer = 'simia'
        product      = 'pump'
    end
    
    %---------------PRIVATE PROPERTIES--------------%
    properties (Access = private)
        pumpIndex
        % pre-defined command
        giveRewardCmd         = uint32([0, 0])
        giveRewardDurationCmd = uint32([0, 0])
        stopRewardCmd         = uint32([1, 0])
        reverseCmd            = uint32([2, 0])
        setSpeedCmd           = uint32([3, 0])
    end
    
    methods
        %========================================================================
        %------------------------------PUBLIC METHODS----------------------------
        %========================================================================
        
        function obj = pumpManager()
            % ===================================================================
            % get pump index
            % ===================================================================
            devices = PsychHID('Devices');
            matchingIndices = find(strcmpi({devices.manufacturer}, obj.manufacturer) & ...
                strcmpi({devices.product}, 'pump'));
            for idx = matchingIndices
                obj.pumpIndex = devices(idx).index;
            end
        end
        function giveReward(obj)
            % ===================================================================
            % Unlimited give rewards
            % ===================================================================
            cmd = typecast(obj.giveRewardCmd, 'uint8');
            PsychHID('SetReport', obj.pumpIndex, 2, 0, cmd);
        end
        
        function giveRewardDuration(obj, duration)
            % ===================================================================
            % Give rewards that last a certain amount of time
            %> @fn giveRewardDuration(obj, duration) duration: Duration in milliseconds
            % ===================================================================
            obj.giveRewardDurationCmd(2) = duration;
            cmd = typecast(obj.giveRewardDurationCmd, 'uint8');
            PsychHID('SetReport', obj.pumpIndex, 2, 0, cmd);
        end
        
        function err = stopReward(obj)
            % ===================================================================
            % Stop rewards
            % ===================================================================
            cmd = typecast(obj.stopRewardCmd, 'uint8');
            err = PsychHID('SetReport', obj.pumpIndex, 2, 0, cmd);
        end
        
        function err = setSpeed(obj, speed)
            % ===================================================================
            % Set pump speed
            %> @fn setSpeed(obj, speed) speed: Speed in 0-100
            % ===================================================================
            obj.setSpeedCmd(2) = speed;
            cmd = typecast(obj.setSpeedCmd, 'uint8');
            err = PsychHID('SetReport', obj.pumpIndex, 2, 0, cmd);
        end
        
        function err = reverse(obj)
            % ===================================================================
            % Reverse pump running direction
            % ===================================================================
            cmd = typecast(obj.reverseCmd, 'uint8');
            err = PsychHID('SetReport', obj.pumpIndex, 2, 0, cmd);
        end
    end
end
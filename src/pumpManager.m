% ==============================================================================
%> @class pumpManager
%> @brief Manages the Simia Pump
%>
%> Copyright ©2014-2025 HuYang — released: LGPL3
% ==============================================================================
classdef pumpManager
    
    
    %---------------PUBLIC PROPERTIES---------------%
    properties (Constant)
        manufacturer   = 'simia'
        product        = 'pump_A100_v0.1.1'
        legacy_product = 'pump'
        
        cmd_t = struct( ...
            'device_id', uint8(0), ...
            'cmd',       uint8(0), ...
            'payload',   uint32(0) ...
            )
    end
    
    %---------------PRIVATE PROPERTIES--------------%
    properties (Access = private)
        pumpIndex
        % pre-defined command
        giveRewardCmd
        giveRewardDurationCmd
        stopRewardCmd
        reverseCmd
        setSpeedCmd
        
        % pre-defined legacy command
        speed = 100
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
                strcmpi({devices.product}, obj.product));
            for idx = matchingIndices
                obj.pumpIndex = devices(idx).index;
            end
            if devices.manufacturer == obj.product
                obj.giveRewardCmd         = uint32([0, 0]);
                obj.giveRewardDurationCmd = uint32([0, 0]);
                obj.stopRewardCmd         = uint32([1, 0]);
                obj.reverseCmd            = uint32([2, 0]);
                obj.setSpeedCmd           = uint32([3, 0]);
            end
            if devices.manufacturer == obj.legacy_product
                obj.giveRewardCmd         = single([1, 0, 0, 0, 0]);
                obj.giveRewardDurationCmd = single([1, 0, 0, 0, 0]);
                obj.stopRewardCmd         = single([0, 0, 1, 0, 0]);
                obj.setSpeedCmd           = single([0, 0, 0. 0, 0]);
                obj.reverseCmd            = single([0, 0, 0, 0, 1]);
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

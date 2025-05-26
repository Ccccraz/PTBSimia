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
    end

    properties
        simiaPumps PTBSimia.simiaPump.pump
    end

    %---------------PRIVATE PROPERTIES--------------%
    properties (Access = private)
        pumpIndex
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
            matchingIndices = find( ...
                strcmpi({devices.manufacturer}, obj.manufacturer) & ...
                strcmpi({devices.product}, obj.product) ...
                );

            for idx = matchingIndices
                obj.pumpIndex = devices(idx).index;
            end

            obj.simiaPumps = PTBSimia.simiaPump.pump(obj.pumpIndex);
        end

        function giveReward(obj)
            % ===================================================================
            % Unlimited give rewards
            % ===================================================================
            obj.simiaPumps.reward();
        end

        function giveRewardWithDuration(obj, duration)
            % ===================================================================
            % Give rewards that last a certain amount of time
            %> @fn giveRewardDuration(obj, duration) duration: Duration in milliseconds
            % ===================================================================
            arguments
                obj
                duration (1, 1) uint32 {mustBePositive, mustBeInteger}
            end

            disp("pumpManager: ")
            disp(duration)
            obj.simiaPumps.rewardWithDuration(duration);
        end

        function stopReward(obj)
            % ===================================================================
            % Stop rewards
            % ===================================================================
            obj.simiaPumps.stopReward();
        end

        function stopCurrentReward(obj)
            obj.simiaPumps.stopCurrentReward()
        end

        function setSpeed(obj, speed)
            % ===================================================================
            % Set pump speed
            %> @fn setSpeed(obj, speed) speed: Speed in 0-100
            % ===================================================================
            obj.simiaPumps.setSpeed(speed);
        end

        function reverse(obj)
            % ===================================================================
            % Reverse pump running direction
            % ===================================================================
            obj.simiaPumps.reverse();
        end
    end
end

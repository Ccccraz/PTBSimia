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

        function giveReward(obj, duration)
            % ===================================================================
            % Unlimited give rewards
            % ===================================================================
            arguments
                obj
                duration (1, 1) uint32 {mustBeNonnegative, mustBeInteger} = 0
            end

            obj.simiaPumps.reward(duration);
        end

        function stopReward(obj, all)
            % ===================================================================
            % Stop rewards
            % ===================================================================
            arguments
                obj
                all logical = true
            end

            obj.simiaPumps.stopReward(all);
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

% ==============================================================================
%> @class pumpManager
%> @brief Manages the Simia Pump
%>
%> Copyright ©2014-2025 HuYang — released: LGPL3
% ==============================================================================
classdef pumpManager < handle
    %---------------PUBLIC PROPERTIES---------------%
    properties (Constant)
        manufacturer   = 'simia'
        product        = 'pump_A100_v0.1.1'
        legacy_product = 'pump'
    end

    properties
        %> Array of pump objects managed by this pumpManager
        simiaPumps (1, :) PTBSimia.simiaPump.pumpBase =PTBSimia.simiaPump.dummyPump.empty(1, 0);
    end

    %========================================================================
    methods (Access = public)%------------------PUBLIC METHODS
        %========================================================================

        % ===================================================================
        function obj = pumpManager(mode)
            %> @fn pumpManager
            %> @brief Class constructor
            %>
            %> Creates pump objects for all matching Simia pumps
            %>
            %> @param mode if enable dummy pump [default=false]
            %> @return obj Initialized pumpManager object
            % ===================================================================
            arguments (Input)
                mode (1, 1) logical = false
            end

            arguments (Output)
                obj PTBSimia.pumpManager
            end

            if mode
                obj.simiaPumps = PTBSimia.simiaPump.dummyPump(1);
            else
                devices = PsychHID('Devices');
                matchRule =  ...
                    strcmpi({devices.manufacturer}, obj.manufacturer) & ...
                    strcmpi({devices.product}, obj.product) ...
                    ;

                matchedPumpIndex = [devices(matchRule).index];

                if ~isempty(matchedPumpIndex)
                    obj.simiaPumps = PTBSimia.simiaPump.pump.empty(1, 0);
                    for idx = matchedPumpIndex
                        obj.simiaPumps(end+1) = PTBSimia.simiaPump.pump(idx);
                    end
                else
                    warning('No Simia pumps found!');
                end
            end
        end

        % ===================================================================
        function giveReward(obj, duration, pumpId)
            %> @fn giveReward
            %> @brief Give rewards to the specified pumps
            %>
            %> @param obj The pumpManager object
            %> @param duration Duration of reward in ms [default=0]
            %> @param pumpId Array of pump IDs to reward [default=all connected pumps]
            % ===================================================================
            arguments
                obj PTBSimia.pumpManager
                duration (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
                pumpId (1, :) double {mustBeNonnegative, mustBeNonempty, mustBeInteger} = [obj.simiaPumps.deviceId]
            end

            matchedPumps = obj.matchPumpsById(pumpId);

            for pump = matchedPumps
                pump.giveReward(duration);
            end
        end

        % ===================================================================
        function stopReward(obj, all, pumpId)
            %> @fn stopReward
            %> @brief Stop rewards on specified pumps
            %>
            %> @param obj The pumpManager object
            %> @param all Whether to stop all reward tasks (true) or just current
            %>            reward task (false) [default=true]
            %> @param pumpId Array of pump IDs to stop [default=all connected pumps]
            % ===================================================================
            arguments
                obj PTBSimia.pumpManager
                all (1, 1) logical = true
                pumpId (1, :) double {mustBeNonnegative, mustBeNonempty, mustBeInteger} = [obj.simiaPumps.deviceId]
            end

            matchedPumps = obj.matchPumpsById(pumpId);

            for pump = matchedPumps
                pump.stopReward(all);
            end
        end

        % ===================================================================
        function setSpeed(obj, speed, pumpId)
            %> @fn setSpeed
            %> @brief Set pump speed
            %>
            %> @param obj The pumpManager object
            %> @param speed Speed value (0-100)
            %> @param pumpId Array of pump IDs to configure [default=all connected pumps]
            % ===================================================================
            arguments
                obj PTBSimia.pumpManager
                speed (1, 1) double {mustBeInRange, mustBeInteger}
                pumpId (1, :) double {mustBeNonnegative, mustBeNonempty, mustBeInteger} = [obj.simiaPumps.deviceId]
            end

            matchedPumps = obj.matchPumpsById(pumpId);

            for pump = matchedPumps
                pump.setSpeed(speed);
            end
        end

        % ===================================================================
        function reverse(obj, pumpId)
            %> @fn reverse
            %> @brief Reverse pump running direction
            %>
            %> @param obj The pumpManager object
            %> @param pumpId Array of pump IDs to reverse [default=all connected pumps]
            % ===================================================================
            arguments
                obj PTBSimia.pumpManager
                pumpId (1, :) double {mustBeNonnegative, mustBeNonempty, mustBeInteger} = [obj.simiaPumps.deviceId]
            end

            matchedPumps = obj.matchPumpsById(pumpId);

            for pump = matchedPumps
                pump.reverse();
            end
        end

        % ===================================================================
        function pumpInfo = GetDeviceInfo(obj, pumpId)
            %> @fn GetDeviceInfo
            %> @brief Get device information for specified pumps
            %>
            %> @param obj The pumpManager object
            %> @param pumpId Array of pump IDs to query [default=all connected pumps]
            %> @return pumpInfo Struct array containing device ID and nickname for each pump
            % ===================================================================
            arguments
                obj PTBSimia.pumpManager
                pumpId (1, :) double {mustBeNonnegative, mustBeNonempty, mustBeInteger} = [obj.simiaPumps.deviceId]
            end

            matchedPumps = obj.matchPumpsById(pumpId);

            pumpIndex = [matchedPumps.deviceIndex];

            pumpInfo(length(pumpIndex)) = struct('device_id', [], 'nickname', '');

            for i = 1:length(pumpIndex)
                [id, name] = obj.simiaPumps(i).getDeviceInfo();
                pumpInfo(i).device_id = id;
                pumpInfo(i).nickname = name;
            end
        end

        % ===================================================================
        function wifiInfo = GetWifiInfo(obj, pumpId)
            %> @fn GetWifiInfo
            %> @brief Get WiFi information for specified pumps
            %>
            %> @param obj The pumpManager object
            %> @param pumpId Array of pump IDs to query [default=all connected pumps]
            %> @return wifiInfo Struct array containing SSID and password for each pump
            % ===================================================================
            arguments
                obj PTBSimia.pumpManager
                pumpId (1, :) double {mustBeNonnegative, mustBeNonempty, mustBeInteger} = [obj.simiaPumps.deviceId]
            end

            matchedPumps = obj.matchPumpsById(pumpId);

            pumpIndex = [matchedPumps.deviceIndex];

            wifiInfo(length(pumpIndex)) = struct('ssid', '', 'password', '');

            for i = 1:length(pumpIndex)
                [ssid, pwd] = obj.simiaPumps(i).getWifi();
                wifiInfo(i).ssid = ssid;
                wifiInfo(i).password = pwd;
            end
        end

        % ===================================================================
        function setDeviceId(obj, newId, pumpId)
            %> @fn setDeviceId
            %> @brief Set device ID for specified pumps
            %>
            %> @param obj The pumpManager object
            %> @param newId New device ID (0-255)
            %> @param pumpId Array of pump IDs to configure [default=all connected pumps]
            % ===================================================================
            arguments
                obj PTBSimia.pumpManager
                newId (1, 1) double {mustBeNonnegative, mustBeInteger, mustBeInRange(newId, 0, 255)}
                pumpId (1, :) double {mustBeNonnegative, mustBeNonempty, mustBeInteger} = [obj.simiaPumps.deviceId]
            end

            matchedPumps = obj.matchPumpsById(pumpId);

            for pump = matchedPumps
                pump.setDeviceId(newId);
            end
        end

        % ===================================================================
        function setDeviceNickname(obj, nickname, pumpId)
            %> @fn setDeviceNickname
            %> @brief Set device nickname for specified pumps
            %>
            %> @param obj The pumpManager object
            %> @param nickname New nickname string
            %> @param pumpId Array of pump IDs to configure [default=all connected pumps]
            % ===================================================================
            arguments
                obj PTBSimia.pumpManager
                nickname (1, 1) string
                pumpId (1, :) double {mustBeNonnegative, mustBeNonempty, mustBeInteger} = [obj.simiaPumps.deviceId]
            end

            matchedPumps = obj.matchPumpsById(pumpId);

            for pump = matchedPumps
                pump.setDeviceNickname(nickname);
            end
        end

        % ===================================================================
        function setDeviceWifi(obj, ssid, password, pumpId)
            %> @fn setDeviceWifi
            %> @brief Set WiFi credentials for specified pumps
            %>
            %> @param obj The pumpManager object
            %> @param ssid WiFi SSID
            %> @param password WiFi password
            %> @param pumpId Array of pump IDs to configure [default=all connected pumps]
            % ===================================================================
            arguments
                obj PTBSimia.pumpManager
                ssid (1, 1) string
                password (1, 1) string
                pumpId (1, :) double {mustBeNonnegative, mustBeNonempty, mustBeInteger} = [obj.simiaPumps.deviceId]
            end

            matchedPumps = obj.matchPumpsById(pumpId);

            for pump = matchedPumps
                pump.setWifi(ssid, password);
            end
        end

        % ===================================================================
        function enableFlashMode(obj, pumpId)
            %> @fn enableFlashMode
            %> @brief Enable flash mode for specified pumps
            %>
            %> @param obj The pumpManager object
            %> @param pumpId Array of pump IDs to configure [default=all connected pumps]
            % ===================================================================
            arguments
                obj PTBSimia.pumpManager
                pumpId (1, :) double {mustBeNonnegative, mustBeNonempty, mustBeInteger} = [obj.simiaPumps.deviceId]
            end

            matchedPumps = obj.matchPumpsById(pumpId);

            for pump = matchedPumps
                pump.enableFlashMode();
            end
        end

        % ===================================================================
        function enableOTAMode(obj, pumpId)
            %> @fn enableOTAMode
            %> @brief Enable OTA (Over-The-Air) mode for specified pumps
            %>
            %> @param obj The pumpManager object
            %> @param pumpId Array of pump IDs to configure [default=all connected pumps]
            % ===================================================================
            arguments
                obj PTBSimia.pumpManager
                pumpId (1, :) double {mustBeNonnegative, mustBeNonempty, mustBeInteger} = [obj.simiaPumps.deviceId]
            end

            matchedPumps = obj.matchPumpsById(pumpId);

            for pump = matchedPumps
                pump.enableOTAMode();
            end
        end

        % ===================================================================
        function pumps = matchPumpsById(obj, pumpId)
            %> @fn matchPumpsById
            %> @brief Match pumps by their IDs
            %>
            %> @param obj The pumpManager object
            %> @param pumpId Array of pump IDs to match
            %> @return pumps Array of matched pump objects
            % ===================================================================
            arguments (Input)
                obj PTBSimia.pumpManager
                pumpId (1, :) double {mustBeNonnegative, mustBeNonempty, mustBeInteger} = [obj.simiaPumps.deviceId]
            end

            arguments (Output)
                pumps (1, :) PTBSimia.simiaPump.pumpBase
            end

            matchRule = ismember([obj.simiaPumps.deviceId], pumpId);
            pumps = obj.simiaPumps(matchRule);
        end

        function delete(~)
            clear PsychHID
        end
    end
end

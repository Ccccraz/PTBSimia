% ==============================================================================
%> @class pump
%> @brief Represents a single Simia pump device
%>
%> This class handles communication and control for individual Simia pump devices,
%> including reward delivery, speed control, and device configuration.
%>
%> Copyright ©2014-2025 HuYang — released: LGPL3
% ==============================================================================
classdef pump < PTBSimia.simiaPump.pumpBase
    properties
        %> Index of the HID device
        deviceIndex double
        %> Unique ID of the pump device
        deviceId uint8
        %> User-assigned nickname for the pump
        nickname string
    end

    %========================================================================
    methods (Access = public)%------------------PUBLIC METHODS
    %========================================================================

        % ===================================================================
        function obj = pump(deviceIndex)
        %> @fn pump
        %> @brief Class constructor
        %>
        %> Initializes a pump object with the given device index and retrieves
        %> its device ID and nickname.
        %>
        %> @param deviceIndex The HID device index for this pump
        %> @return obj Initialized pump object
        % ===================================================================
            arguments (Input)
                deviceIndex (1, 1) double {mustBeNonnegative, mustBeInteger}
            end

            arguments (Output)
                obj PTBSimia.simiaPump.pump
            end

            obj.deviceIndex = deviceIndex;
            [obj.deviceId, obj.nickname] = obj.getDeviceInfo();
        end

        % ===================================================================
        function giveReward(obj, duration)
        %> @fn giveReward
        %> @brief give reward for specified duration
        %>
        %> @param obj The pump object
        %> @param duration Duration of reward in ms (0 for infinite)
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                duration (1, 1) double {mustBeNonnegative, mustBeInteger}
            end

            cmd = obj.createOutputStartCmd(duration);
            obj.sendOutputCmd(cmd);
        end

        % ===================================================================
        function stopReward(obj, all)
        %> @fn stopReward
        %> @brief Stop reward
        %>
        %> @param obj The pump object
        %> @param all If true, stops all reward tasks; if false, stops 
        %> current reward task only
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                all logical
            end

            cmd = obj.createOutputStopCmd(all);
            obj.sendOutputCmd(cmd);
        end

        % ===================================================================
        function reverse(obj)
        %> @fn reverse
        %> @brief Reverse pump direction
        %>
        %> @param obj The pump object
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
            end

            cmd = obj.createOutputReverseCmd();
            obj.sendOutputCmd(cmd);
        end

        % ===================================================================
        function setSpeed(obj, speed)
        %> @fn setSpeed
        %> @brief Set pump speed
        %>
        %> @param obj The pump object
        %> @param speed Speed value (0-100)
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                speed (1, 1) double {mustBeNonnegative, mustBeInteger}
            end

            cmd = obj.createOutputSetSpeedCmd(speed);
            obj.sendOutputCmd(cmd);
        end

        % ===================================================================
        function setDeviceId(obj, deviceId)
        %> @fn setDeviceId
        %> @brief Set device ID
        %>
        %> @param obj The pump object
        %> @param deviceId New device ID (0-255)
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                deviceId (1, 1) double {mustBeNonnegative, mustBeInteger, mustBeInRange(deviceId, 0, 255)}
            end

            report = obj.createFeatureSetDeviceInfo(deviceId, obj.nickname);

            obj.setFeature(PTBSimia.simiaPump.type.set_feature_cmd_t.SET_DEVICE_INFO, report);

            [obj.deviceId, ~] = obj.getDeviceInfo();
        end

        % ===================================================================
        function setDeviceNickname(obj, nickname)
        %> @fn setDeviceNickname
        %> @brief Set device nickname
        %>
        %> @param obj The pump object
        %> @param nickname New nickname string
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                nickname (1, 1) string
            end

            report = obj.createFeatureSetDeviceInfo(obj.deviceId, nickname);
            obj.setFeature(PTBSimia.simiaPump.type.set_feature_cmd_t.SET_DEVICE_INFO, report);

            [~, obj.nickname] = obj.getDeviceInfo();
        end

        % ===================================================================
        function setWifi(obj, ssid, password)
        %> @fn setWifi
        %> @brief Set WiFi credentials
        %>
        %> @param obj The pump object
        %> @param ssid WiFi network name
        %> @param password WiFi password
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                ssid (1, 1) string
                password (1, 1) string
            end

            report = obj.createFeatureSetWifi(ssid, password);
            obj.setFeature(PTBSimia.simiaPump.type.set_feature_cmd_t.SET_WIFI, report);
        end

        % ===================================================================
        function enableOTAMode(obj)
        %> @fn enableOTAMode
        %> @brief Enable OTA (Over-The-Air) update mode
        %>
        %> @param obj The pump object
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
            end

            report = obj.createFeatureSetStartMode(PTBSimia.simiaPump.type.start_mode_t.ACTIVE_OTA);
            obj.setFeature(PTBSimia.simiaPump.type.set_feature_cmd_t.SET_START_MODE, report);
        end

        % ===================================================================
        function enableFlashMode(obj)
        %> @fn enableFlashMode
        %> @brief Enable flash upload mode
        %>
        %> @param obj The pump object
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
            end

            report = obj.createFeatureSetStartMode(PTBSimia.simiaPump.type.start_mode_t.FLASH);
            obj.setFeature(PTBSimia.simiaPump.type.set_feature_cmd_t.SET_START_MODE, report);
        end

        % ===================================================================
        function [deviceId, nickname] = getDeviceInfo(obj)
        %> @fn getDeviceInfo
        %> @brief Get device information
        %>
        %> @param obj The pump object
        %> @return deviceId The device ID
        %> @return nickname The device nickname
        % ===================================================================
            arguments (Input)
                obj PTBSimia.simiaPump.pump
            end

            arguments (Output)
                deviceId (1, 1) uint8
                nickname string
            end

            [report, ~] = obj.getFeature(PTBSimia.simiaPump.type.get_feature_cmd_t.GET_DEVICE_ID);

            report = obj.parseDeviceInfoFeatureReport(report);

            deviceId = report.payload.device_id;
            nickname = string(report.payload.nickname);
        end

        % ===================================================================
        function [ssid, password] = getWifi(obj)
        %> @fn getWifi
        %> @brief Get WiFi information
        %>
        %> @param obj The pump object
        %> @return ssid The stored WiFi SSID
        %> @return password The stored WiFi password
        % ===================================================================
            arguments (Input)
                obj PTBSimia.simiaPump.pump
            end

            arguments (Output)
                ssid string
                password string
            end

            [report, ~] = obj.getFeature(PTBSimia.simiaPump.type.get_feature_cmd_t.GET_WIFI);

            report = obj.parseWifiFeatureReport(report);

            ssid = string(report.payload.ssid);
            password = string(report.payload.password);
        end
    end

    %========================================================================
    methods (Access = private)%------------------PRIVATE METHODS
    %========================================================================

        % ===================================================================
        function sendOutputCmd(obj, cmd)
        %> @fn sendOutputCmd
        %> @brief Send output command to device
        %>
        %> @param obj The pump object
        %> @param cmd The command to send
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                cmd
            end

            PsychHID('SetReport', obj.deviceIndex, 2, 1, cmd);
        end

        % ===================================================================
        function setFeature(obj, reportID, report)
        %> @fn setFeature
        %> @brief Send feature report to device
        %>
        %> @param obj The pump object
        %> @param reportID The feature report ID
        %> @param report The report data (64 bytes)
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                reportID (1, 1) PTBSimia.simiaPump.type.set_feature_cmd_t
                report (1, 64) uint8
            end

            reportID = double(reportID);

            PsychHID('SetReport', obj.deviceIndex, 3, reportID, report);
        end

        % ===================================================================
        function [report, err] = getFeature(obj, reportID)
        %> @fn getFeature
        %> @brief Get feature report from device
        %>
        %> @param obj The pump object
        %> @param reportID The feature report ID
        %> @return report The received report data (64 bytes)
        %> @return err Error code if any
        % ===================================================================
            arguments (Input)
                obj PTBSimia.simiaPump.pump
                reportID (1, 1) PTBSimia.simiaPump.type.get_feature_cmd_t
            end

            arguments (Output)
                report (1, 64) uint8
                err
            end

            reportID = double(reportID);

            [report, err] = PsychHID('GetReport', obj.deviceIndex, 3, reportID, 64);
        end

        % ===================================================================
        function report = parseDeviceInfoFeatureReport(~, reportBytes)
        %> @fn parseDeviceIdFeatureReport
        %> @brief Parse device info feature report
        %>
        %> @param ~ (unused)
        %> @param reportBytes Raw report bytes (64 bytes)
        %> @return report Parsed report structure
        % ===================================================================
            arguments
                ~
                reportBytes (1, 64) uint8
            end

            report = struct();
            report.device_id = reportBytes(2);

            payload = struct();
            payload.device_id = reportBytes(3);
            payload.nickname_len = reportBytes(4);

            nickname_bytes = reportBytes(5:64);

            if payload.nickname_len > 0
                valid_nickname = nickname_bytes(1:payload.nickname_len);
                payload.nickname = char(valid_nickname);
            else
                payload.nickname = '';
            end

            report.payload = payload;
        end

        % ===================================================================
        function report = parseWifiFeatureReport(~, reportBytes)
        %> @fn parseWifiFeatureReport
        %> @brief Parse WiFi feature report
        %>
        %> @param ~ (unused)
        %> @param reportBytes Raw report bytes (64 bytes)
        %> @return report Parsed report structure
        % ===================================================================
            arguments
                ~
                reportBytes (1, 64) uint8
            end

            if length(reportBytes) ~= 64
                error('Invalid report length. Expected 64, got %d.', length(reportBytes));
            end

            report = struct();
            report.device_id = reportBytes(2);

            payload = struct();
            payload.ssid_len = reportBytes(3);
            payload.password_len = reportBytes(4);

            ssid_bytes = reportBytes(5:34);
            password_bytes = reportBytes(35:64);

            if payload.ssid_len > 0
                valid_ssid = ssid_bytes(1:payload.ssid_len);
                payload.ssid = native2unicode(valid_ssid, 'UTF-8');
            else
                payload.ssid = '';
            end

            if payload.password_len > 0
                valid_password = password_bytes(1:payload.password_len);
                payload.password = native2unicode(valid_password, 'UTF-8');
            else
                payload.password = '';
            end

            report.payload = payload;
        end

        % ===================================================================
        function report = createOutputStartCmd(obj, duration)
        %> @fn createOutputStartCmd
        %> @brief Create START output command
        %>
        %> @param obj The pump object
        %> @param duration Reward duration in ms
        %> @return report Formatted command report
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                duration (1, 1) double {mustBeNonnegative, mustBeInteger}
            end

            duration = uint32(duration);
            duration = typecast(duration, "uint8");

            report_info = struct( ...
                'device_id', uint8(obj.deviceId), ...
                'cmd', uint8(PTBSimia.simiaPump.type.output_cmd_t.START), ...
                'payload', duration ...
                );

            report = [
                0x00, ...
                report_info.device_id, ...
                report_info.cmd, ...
                report_info.payload ...
                ];
        end

        % ===================================================================
        function report = createOutputStopCmd(obj, all)
        %> @fn createOutputStopCmd
        %> @brief Create STOP output command
        %>
        %> @param obj The pump object
        %> @param all Whether to stop all rewards
        %> @return report Formatted command report
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                all logical
            end

            if all
                all = uint8(0x00);
            else
                all = uint8(0x01);
            end

            report_info = struct( ...
                'device_id', uint8(obj.deviceId), ...
                'cmd', uint8(PTBSimia.simiaPump.type.output_cmd_t.STOP), ...
                'payload', uint8(all) ...
                );

            report = [
                0x00, ...
                report_info.device_id, ...
                report_info.cmd, ...
                report_info.payload ...
                ];
        end

        % ===================================================================
        function report = createOutputReverseCmd(obj)
        %> @fn createOutputReverseCmd
        %> @brief Create REVERSE output command
        %>
        %> @param obj The pump object
        %> @return report Formatted command report
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
            end

            report_info = struct( ...
                'device_id', uint8(obj.deviceId), ...
                'cmd', uint8(PTBSimia.simiaPump.type.output_cmd_t.REVERSE), ...
                'payload', uint32(0x00) ...
                );

            report = [
                0x00, ...
                report_info.device_id, ...
                report_info.cmd, ...
                report_info.payload ...
                ];
        end

        % ===================================================================
        function report = createOutputSetSpeedCmd(obj, speed)
        %> @fn createOutputSetSpeedCmd
        %> @brief Create SET_SPEED output command
        %>
        %> @param obj The pump object
        %> @param speed Speed value (0-100)
        %> @return report Formatted command report
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                speed (1, 1) double {mustBeNonnegative, mustBeInteger}
            end

            speed = uint32(speed);

            report_info = struct( ...
                'device_id', uint8(obj.deviceId), ...
                'cmd', uint8(PTBSimia.simiaPump.type.output_cmd_t.SET_SPEED), ...
                'payload', typecast(speed, "uint8") ...
                );

            report = [
                0x00, ...
                report_info.device_id, ...
                report_info.cmd, ...
                report_info.payload ...
                ];
        end

        % ===================================================================
        function report = createFeatureSetDeviceInfo(obj, deviceId, nickname)
        %> @fn createFeatureSetDeviceInfo
        %> @brief Create device info feature report
        %>
        %> @param obj The pump object
        %> @param deviceId Device ID to set
        %> @param nickname Nickname to set
        %> @return report Formatted feature report
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                deviceId (1, 1) double {mustBeNonnegative, mustBeInteger, mustBeInRange(deviceId, 0, 255)}
                nickname string
            end

            deviceId = uint8(deviceId);

            device_info = struct( ...
                'device_id', deviceId, ...
                'nickname_len', uint8(strlength(nickname)), ...
                'nickname', zeros(1, 60, "uint8") ...
                );

            device_info.nickname(1:device_info.nickname_len) = uint8(char(nickname));

            report_info = struct( ...
                'device_id', uint8(obj.deviceId), ...
                'payload', device_info ...
                );

            report = [
                0x00, ...
                report_info.device_id, ...
                report_info.payload.device_id, ...
                report_info.payload.nickname_len, ...
                report_info.payload.nickname ...
                ];
        end

        % ===================================================================
        function report = createFeatureSetWifi(obj, ssid, password)
        %> @fn createFeatureSetWifi
        %> @brief Create WiFi feature report
        %>
        %> @param obj The pump object
        %> @param ssid WiFi SSID
        %> @param password WiFi password
        %> @return report Formatted feature report
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                ssid string
                password string
            end

            ssid_utf8 = unicode2native(ssid, 'UTF-8');
            password_utf8 = unicode2native(password, 'UTF-8');

            wifi_info = struct( ...
                'ssid_len', uint8(length(ssid_utf8)), ...
                'password_len', uint8(length(password_utf8)), ...
                'ssid', zeros(1, 30, "uint8"), ...
                'password', zeros(1, 30, "uint8") ...
                );

            disp(wifi_info.ssid_len);
            disp(wifi_info.password_len);

            wifi_info.ssid(1:wifi_info.ssid_len) = ssid_utf8;
            wifi_info.password(1:wifi_info.password_len) = password_utf8;

            report_info = struct( ...
                'device_id', uint8(obj.deviceId), ...
                'payload', wifi_info ...
                );

            report = [
                0x00, ...
                report_info.device_id, ...
                report_info.payload.ssid_len, ...
                report_info.payload.password_len, ...
                report_info.payload.ssid, ...
                report_info.payload.password ...
                ];
        end

        % ===================================================================
        function report = createFeatureSetStartMode(obj, startMode)
        %> @fn createFeatureSetStartMode
        %> @brief Create start mode feature report
        %>
        %> @param obj The pump object
        %> @param startMode Start mode to set
        %> @return report Formatted feature report
        % ===================================================================
            arguments
                obj PTBSimia.simiaPump.pump
                startMode PTBSimia.simiaPump.type.start_mode_t
            end
            report_info = struct( ...
                'device_id', uint8(obj.deviceId), ...
                'payload', zeros(1, 62, "uint8") ...
                );

            report_info.payload(1) = uint8(startMode);

            report = [
                0x00, ...
                report_info.device_id, ...
                report_info.payload ...
                ];
        end
        function delete(~)
            clear PsychHID
        end
    end
end
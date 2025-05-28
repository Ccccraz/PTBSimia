classdef pump < handle
    properties
        deviceIndex double {mustBeNonnegative, mustBeInteger}
        deviceId uint8
        nickname string
    end

    methods (Access = public)
        function obj = pump(deviceIndex)
            obj.deviceIndex = deviceIndex;
            [obj.deviceId, obj.nickname] = obj.getDeviceInfo();
        end

        function reward(obj, duration)
            % 0 for infinite reward
            arguments
                obj
                duration (1, 1) uint32 {mustBeNonnegative, mustBeInteger}
            end

            cmd = obj.createOutputStartCmd(duration);
            obj.sendOutputCmd(cmd);
        end

        function stopReward(obj, all)
            arguments
                obj
                all logical
            end

            cmd = obj.createOutputStopCmd(all);
            obj.sendOutputCmd(cmd);
        end

        function reverse(obj)
            cmd = obj.createOutputReverseCmd();
            obj.sendOutputCmd(cmd);
        end

        function setSpeed(obj, speed)
            arguments
                obj
                speed (1, 1) double {mustBeNonnegative, mustBeInteger}
            end

            cmd = obj.createOutputSetSpeedCmd(speed);
            obj.sendOutputCmd(cmd);
        end

        function setDeviceId(obj, deviceId)
            arguments
                obj
                deviceId (1, 1) double {mustBeNonnegative, mustBeInteger, mustBeInRange(deviceId, 0, 255)}
            end

            report = obj.createFeatureSetDeviceInfo(deviceId, obj.nickname);

            obj.setFeature(PTBSimia.simiaPump.type.set_feature_cmd_t.SET_DEVICE_ID, report);

            [obj.deviceId, ~] = obj.getDeviceInfo();
        end

        function setDeviceNickname(obj, nickname)
            arguments
                obj
                nickname string
            end

            obj.nickname = nickname;
            report = obj.createFeatureSetDeviceInfo(obj.deviceId, nickname);
            obj.setFeature(report);
        end

        function setWifi(obj, ssid, password)
            report = obj.createFeatureSetWifi(ssid, password);
            obj.setFeature(report);
        end

        function enableOTAMode(obj)
            report = obj.createFeatureSetStartMode(1);
            obj.setFeature(report);
        end

        function enableFlashMode(obj)
            report = obj.createFeatureSetStartMode(0);
            obj.setFeature(report);
        end

        function [deviceId, nickname] = getDeviceInfo(obj)
            arguments (Output)
                deviceId (1, 1) uint8
                nickname string
            end

            [report, ~] = obj.getFeature(PTBSimia.simiaPump.type.get_feature_cmd_t.GET_DEVICE_ID);

            report = obj.parseDeviceIdFeatureReport(report);

            deviceId = report.payload.device_id;
            nickname = string(report.payload.nickname);
        end

        function [ssid, password] = getWifi(obj)
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

    methods (Access = private)
        function sendOutputCmd(obj, cmd)
            PsychHID('SetReport', obj.deviceIndex, 2, 1, cmd);
        end

        function setFeature(obj, reportID, report)
            arguments
                obj
                reportID (1, 1) PTBSimia.simiaPump.type.set_feature_cmd_t
                report (1, 64) uint8
            end

            reportID = double(reportID);

            PsychHID('SetReport', obj.deviceIndex, 3, reportID, report);
        end

        function [report, err] = getFeature(obj, reportID)
            arguments
                obj
                reportID (1, 1) PTBSimia.simiaPump.type.get_feature_cmd_t
            end

            reportID = double(reportID);

            [report, err] = PsychHID('GetReport', obj.deviceIndex, 3, reportID, 64);
        end

        function report = parseDeviceIdFeatureReport(~, reportBytes)
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

        function report = parseWifiFeatureReport(~, reportBytes)
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
                payload.ssid = char(valid_ssid);
            else
                payload.ssid = '';
            end

            if payload.password_len > 0
                valid_password = password_bytes(1:payload.password_len);
                payload.password = char(valid_password);
            else
                payload.password = '';
            end

            report.payload = payload;
        end

        function report = createOutputStartCmd(obj, duration)
            arguments
                obj
                duration uint32
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

            disp(report);
        end

        function report = createOutputStopCmd(obj, all)
            arguments
                obj
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

        function report = createOutputReverseCmd(obj)
            arguments
                obj
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

        function report = createOutputSetSpeedCmd(obj, speed)
            arguments
                obj
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

        function report = createFeatureSetDeviceInfo(obj, deviceId, nickname)
            arguments
                obj
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

        function report = createFeatureSetWifi(obj, ssid, password)
            arguments
                obj
                ssid string
                password string
            end

            wifi_info = struct( ...
                'ssid_len', uint8(length(ssid)), ...
                'password_len', uint8(length(password)), ...
                'ssid', zeros(1, 30, "uint8"), ...
                'password', zeros(1, 30, "uint8") ...
                );

            wifi_info.ssid(1:wifi_info.ssid_len) = uint8(ssid);
            wifi_info.password(1:wifi_info.password_len) = uint8(password);

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

        function report = createFeatureSetStartMode(obj, startMode)
            arguments
                obj
                startMode
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
    end
end
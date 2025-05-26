classdef pump
    properties
        deviceIndex double {mustBePositive, mustBeInteger}
        % for all simia devices default deviceId is 0
        deviceId uint8 = 0
    end

    methods (Access = public)
        function obj = pump(deviceIndex)
            obj.deviceIndex = deviceIndex;
        end

        function reward(obj)
            % 0 for infinite reward
            cmd = obj.createStartCmd(0);
            obj.sendOutputCmd(cmd);
        end

        function rewardWithDuration(obj, duration)
            arguments
                obj
                duration (1, 1) uint32 {mustBePositive, mustBeInteger}
            end

            % duration in milliseconds
            cmd = obj.createStartCmd(duration);
            obj.sendOutputCmd(cmd);
            disp(cmd);
        end

        function stopReward(obj)
            cmd = obj.createStopCmd(true);
            obj.sendOutputCmd(cmd);
        end

        function stopCurrentReward(obj)
            cmd = obj.createStopCmd(false);
            obj.sendOutputCmd(cmd);
        end

        function reverse(obj)
            cmd = obj.createReverseCmd();
            obj.sendOutputCmd(cmd);
        end

        function setSpeed(obj, speed)
            cmd = obj.createSetSpeedCmd(speed);
            obj.sendOutputCmd(cmd);
        end

        function setDeviceId(obj, deviceId, nickname)
            report = obj.createSetDeviceId(deviceId, nickname);
            obj.setFeature(report);
        end

        function setWifi(obj, ssid, password)
            report = obj.createSetWifiCmd(ssid, password);
            obj.setFeature(report);
        end

        function enableOTAMode(obj)
            report = obj.createSetStartMode(1);
            obj.setFeature(report);
        end

        function enableFlashMode(obj)
            report = obj.createSetStartMode(0);
            obj.setFeature(report);
        end

        function [deviceId, nickname] = getDeviceInfo(obj)
            [report, ~] = PsychHID('GetReport', obj.deviceIndex, 3, 0, 63);
            report = obj.parseDeviceIdFeatureReport(report);
            deviceId = report.payload.device_id;
            nickname = report.payload.nickname;
        end

        function getWifi(obj)
            PsychHID('GetReport', obj.deviceIndex, 3, 0, report);
        end
    end

    methods (Access = private)
        function sendOutputCmd(obj, cmd)
            PsychHID('SetReport', obj.deviceIndex, 2, 1, cmd);
        end

        function setFeature(obj, report)
            PsychHID('SetReport', obj.deviceIndex, 3, 0, report);
        end

        function [report, err] = getFeature(obj)
            [report, err] = PsychHID('GetReport', obj.deviceIndex, 3, 0, 63);
        end

        function report = parseDeviceIdFeatureReport(reportBytes)
            if length(reportBytes) ~= 63
                error('Invalid report length. Expected 63, got %d.', length(reportBytes));
            end

            report = struct();
            report.device_id = reportBytes(1);

            payload = struct();
            payload.device_id = reportBytes(2);
            payload.nickname_len = reportBytes(3);

            nickname_bytes = reportBytes(4:63);

            if payload.nickname_len > 0
                valid_nickname = nickname_bytes(1:payload.nickname_len);
                payload.nickname = char(valid_nickname);
            else
                payload.nickname = '';
            end

            report.payload = payload;
        end

        function report = parseWifiFeatureReport(report)
        end

        function report = createReportCmd(~, cmd)
            switch cmd
                case type.cmd_t.START
                    report = struct( ...
                        'device_id', uint8(0x00), ...
                        'cmd', type.cmd_t(START), ...
                        'payload', uint32_t(0x00) ...
                        );
                otherwise
            end
        end

        function report = createStartCmd(obj, duration)
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
        end

        function report = createStopCmd(obj, stopAll)
            arguments
                obj
                stopAll logical
            end

            if stopAll
                stopAll = uint8(0x00);
            else
                stopAll = uint8(0x01);
            end

            report_info = struct( ...
                'device_id', uint8(obj.deviceId), ...
                'cmd', uint8(PTBSimia.simiaPump.type.output_cmd_t.STOP), ...
                'payload', uint8(stopAll) ...
                );

            report = [
                0x00, ...
                report_info.device_id, ...
                report_info.cmd, ...
                report_info.payload ...
                ];
        end

        function report = createReverseCmd(obj)
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

        function report = createSetSpeedCmd(obj, speed)
            arguments
                obj
                speed uint32 {mustBeInteger}
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

        function report = createSetDeviceId(obj, deviceId, nickname)
            arguments
                obj
                deviceId (1, 1) uint8
                nickname string
            end

            device_info = struct( ...
                'device_id', deviceId, ...
                'nickname_len', uint8(length(nickname)), ...
                'nickname', zeros(1, 60, "uint8") ...
                );

            device_info.nickname(1:device_info.nickname_len) = uint8(nickname);

            report_info = struct( ...
                'device_id', uint8(obj.deviceId), ...
                'payload', device_info ...
                );

            report = [
                report_info.device_id, ...
                report_info.payload.device_id, ...
                report_info.payload.nickname_len, ...
                report_info.payload.nickname ...
                ];
        end

        function report = createSetWifiCmd(obj, ssid, password)
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
                report_info.device_id, ...
                report_info.payload.ssid_len, ...
                report_info.payload.password_len, ...
                report_info.payload.ssid, ...
                report_info.payload.password ...
                ];
        end

        function report = createSetStartMode(obj, startMode)
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
                report_info.device_id, ...
                report_info.payload ...
                ];
        end
    end
end
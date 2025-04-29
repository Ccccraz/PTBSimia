classdef simiaPump
    properties (Constant)
        manufacturer = 'simia';
        product = 'pump';
    end

    properties (Access = private)
        strat_cmd = struct('device_id', uint8(0x00), 'cmd', type.cmd_t(START), 'payload', uint32_t(0x00));
        device_index = 0x00;
        device_id = 0x00;
    end

    methods
        function obj = simiaPump()
            devices = PsychHID('Devices');
            matchingIndices = find(strcmpi({devices.manufacturer}, obj.manufacturer) & ...
                strcmpi({devices.product}, obj.product));
            for idx = matchingIndices
                obj.device_index = devices(idx).index;
            end
        end

        function reward(~)
            report = obj.createReportCmd(type.cmd_t.START);
            report = typecast(report, 'uint8');
            PsychHID('SetReport', obj.device_index, 2, 0, report);
        end

        function stop(~)
            report = obj.createReportCmd(type.cmd_t.START);
            report = typecast(report, 'uint8');
            PsychHID('SetReport', obj.device_index, 2, 0, report);
        end

        function reverse(~)
            report = obj.createReportCmd(type.cmd_t.START);
            report = typecast(report, 'uint8');
            PsychHID('SetReport', obj.device_index, 2, 0, report);
        end

        function setSpeed(~)
            report = obj.createReportCmd(type.cmd_t.START);
            report = typecast(report, 'uint8');
            PsychHID('SetReport', obj.device_index, 2, 0, report);
        end

        function setDeviceId(~, deviceId)
            report = obj.createReportCmd(deviceId);
            report = typecast(report, 'uint8');
            PsychHID('SetReport', obj.device_index, 3, 0, report);
        end

        function setWifi(~, ssid, password)
            report = obj.createReportCmd(ssid, password);
            report = typecast(report, 'uint8');
            PsychHID('SetReport', obj.device_index, 3, 0, report);
        end

        function setOta(~, source)
            report = obj.createReportCmd(source);
            report = typecast(report, 'uint8');
            PsychHID('SetReport', obj.device_index, 3, 0, report);
        end

        function setWifiRequirement(~, requirement)
            report = obj.createReportCmd(requirement);
            report = typecast(report, 'uint8');
            PsychHID('SetReport', obj.device_index, 3, 0, report);
        end

        function enableFlashMode(~)
            report = obj.createReportCmd(type.cmd_t.START);
            report = typecast(report, 'uint8');
            PsychHID('SetReport', obj.device_index, 3, 0, report);
        end

        function getDeviceId(~)
            report = obj.createReportCmd(type.cmd_t.START);
            report = typecast(report, 'uint8');
            PsychHID('GetReport', obj.device_index, 3, 0, report);
        end

        function getWifi(~)
            report = obj.createReportCmd(type.cmd_t.START);
            report = typecast(report, 'uint8');
            PsychHID('GetReport', obj.device_index, 3, 0, report);
        end

        function getOta(~)
            report = obj.createReportCmd(type.cmd_t.START);
            report = typecast(report, 'uint8');
            PsychHID('GetReport', obj.device_index, 3, 0, report);
        end

        function getWifiRequirement(~)
            report = obj.createReportCmd(type.cmd_t.START);
            report = typecast(report, 'uint8');
            PsychHID('GetReport', obj.device_index, 3, 0, report);
        end
    end

    methods (Access = private)
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

        function report = createFeatureCmd(~, cmd)
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
    end
end
classdef dummyPump < PTBSimia.simiaPump.pumpBase
    properties
        deviceIndex double
        deviceId uint8
        nickname string
        speed = 50    % Default speed in ml/min
    end

    methods
        function obj = dummyPump(deviceIndex)
            obj.deviceIndex = deviceIndex;
            obj.deviceId = 5;
            obj.nickname = 'Dummy Pump';
            fprintf('Dummy Pump %d initialized\n', obj.deviceIndex);
        end

        function giveReward(obj, duration)
            fprintf('[Dummy Pump %d] Simulating reward: %d ms\n', ...
                obj.deviceIndex, duration);
        end

        function stopReward(obj, ~)
            fprintf('[Dummy Pump %d] Reward stopped\n', obj.deviceIndex);
        end

        function setSpeed(obj, speed)
            obj.speed = speed;
            fprintf('[Dummy Pump %d] Speed set to %d\n', obj.deviceIndex, speed);
        end

        function reverse(obj)
            fprintf('[Dummy Pump %d] Reverse command received\n', obj.deviceIndex);
        end

        function getDeviceInfo(obj)
            fprintf('[Dummy Pump %d] Device Info:\n', obj.deviceIndex);
            fprintf('  Nickname: %s\n', obj.nickname);
            fprintf('  Speed: %d\n', obj.speed);
        end

        function getWifi(obj)
            fprintf('[Dummy Pump %d] Wifi: Not available\n', obj.deviceIndex);
        end

        function setDeviceId(obj, newId)
            fprintf('[Dummy Pump %d] ID changed to %d\n', obj.deviceIndex, newId);
            obj.deviceId = uint8(newId);
        end

        function setDeviceNickname(obj, nickname)
            fprintf('[Dummy Pump %d] Nickname set to "%s"\n', obj.deviceIndex, nickname);
            obj.nickname = string(nickname);
        end

        function setWifi(obj, ssid, ~)
            fprintf('[Dummy Pump %d] Wifi set to "%s"\n', obj.deviceIndex, ssid);
        end

        function enableFlashMode(obj)
            fprintf('[Dummy Pump %d] Flash mode enabled\n', obj.deviceIndex);
        end

        function enableOTAMode(obj)
            fprintf('[Dummy Pump %d] OTA mode enabled\n', obj.deviceIndex);
        end
    end
end
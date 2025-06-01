classdef dummyPump < PTBSimia.simiaPump.pumpBase
    properties
        deviceIndex double
        deviceId uint8
        nickname string
        speed = 50
    end

    methods
        function obj = dummyPump(deviceIndex)
            obj.deviceIndex = deviceIndex;
            obj.deviceId = 5;
            obj.nickname = 'Dummy Pump';
            fprintf('[Dummy Pump] Index:%d | ID:%d - Initialized\n', ...
                obj.deviceIndex, obj.deviceId);
        end

        function giveReward(obj, duration)
            fprintf('[Dummy Pump] Index:%d | ID:%d - Simulating reward: %d ms\n', ...
                obj.deviceIndex, obj.deviceId, duration);
        end

        function stopReward(obj, ~)
            fprintf('[Dummy Pump] Index:%d | ID:%d - Reward stopped\n', ...
                obj.deviceIndex, obj.deviceId);
        end

        function setSpeed(obj, speed)
            obj.speed = speed;
            fprintf('[Dummy Pump] Index:%d | ID:%d - Speed set to %d\n', ...
                obj.deviceIndex, obj.deviceId, speed);
        end

        function reverse(obj)
            fprintf('[Dummy Pump] Index:%d | ID:%d - Reverse command received\n', ...
                obj.deviceIndex, obj.deviceId);
        end

        function getDeviceInfo(obj)
            fprintf('[Dummy Pump] Index:%d | ID:%d - Device Info:\n', ...
                obj.deviceIndex, obj.deviceId);
            fprintf('  Nickname: %s\n', obj.nickname);
            fprintf('  Speed: %d\n', obj.speed);
        end

        function getWifi(obj)
            fprintf('[Dummy Pump] Index:%d | ID:%d - Wifi: Not available\n', ...
                obj.deviceIndex, obj.deviceId);
        end

        function setDeviceId(obj, newId)
            fprintf('[Dummy Pump] Index:%d | ID:%d - Changing ID to %d\n', ...
                obj.deviceIndex, obj.deviceId, newId);
            obj.deviceId = uint8(newId);
        end

        function setDeviceNickname(obj, nickname)
            fprintf('[Dummy Pump] Index:%d | ID:%d - Nickname set to "%s"\n', ...
                obj.deviceIndex, obj.deviceId, nickname);
            obj.nickname = string(nickname);
        end

        function setWifi(obj, ssid, ~)
            fprintf('[Dummy Pump] Index:%d | ID:%d - Wifi set to "%s"\n', ...
                obj.deviceIndex, obj.deviceId, ssid);
        end

        function enableFlashMode(obj)
            fprintf('[Dummy Pump] Index:%d | ID:%d - Flash mode enabled\n', ...
                obj.deviceIndex, obj.deviceId);
        end

        function enableOTAMode(obj)
            fprintf('[Dummy Pump] Index:%d | ID:%d - OTA mode enabled\n', ...
                obj.deviceIndex, obj.deviceId);
        end
    end
end
classdef (Abstract) pumpBase < handle
    properties (Abstract)
        %> Index of the HID device
        deviceIndex double
        %> Unique ID of the pump device
        deviceId uint8
        %> User-assigned nickname for the pump
        nickname string
    end

    methods (Abstract)
        giveReward(obj, duration)
        stopReward(obj, all)
        setSpeed(obj, speed)
        reverse(obj)
        getDeviceInfo(obj)
        getWifi(obj)
        setDeviceId(obj, newId)
        setDeviceNickname(obj, nickname)
        setWifi(obj, ssid, password)
        enableFlashMode(obj)
        enableOTAMode(obj)
    end
end
classdef simiaPump
    properties (Constant)
        manufacturer = 'simia';
        report_t = struct( ...
            'device_id', uint8, ...
            'cmd', type.cmd_t, ...
            'payload', uint32_t ...
            )
    end

    methods
        function obj = simiaPump()
        end
    end

    methods (Access = private)
        function report_t = createCmd(obj)
        end
    end
end
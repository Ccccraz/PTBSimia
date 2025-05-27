function give5SecsReward()
    pump = PTBSimia.pumpManager();

    % mililiters
    pump.giveReward(5000);
end
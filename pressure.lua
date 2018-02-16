Pressure = { running = false }

function Pressure:init(config)
    self.pressPin = config.pin
    self.pump = config.pump
    self.tmrId = config.timerId
    gpio.mode(config.pin, gpio.INPUT)
end

function Pressure:levelNow()
    local press = adc.read(self.pressPin)
    print("Level now" .. press)
    local delta = 3000000 / 4096
    print("Delta now" .. delta)
    press = press * delta * 2
    press = (press / 4413) - 50

    return press;
end

function Pressure:measureLevel(callback)
    local last = 10000;
    local diff;
    local cb = callback;
    local timerID = self.tmrId;
    local motor = self.pump;
    local pumpStageFinished = false;
    motor:turnOn("measure pressure");
    tmr.start(timerID, 250, function()
        local press = Pressure:levelNow()
        if pumpStageFinished then
            diff = last - press
            last = press
            if (diff < 6) then
                cb(last)
                tmr.stop(timerID)
            end
        else
            diff = last - press
            last = press
            if (diff < 6) then
                motor:turnOff("measure pressure end at " .. press)
                pumpStageFinished = true
                last = 10000
            end

        end
    end)
end


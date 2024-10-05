utils = {}

utils.name = "MeowCode" -- Set Name --
utils.version = "0.1.0" -- Set Version --
utils.license = "MIT" -- Set License --

--------- Logger ---------
function utils.log(message)
    print(" [INFO/MAIN] "..message)
end

--------- Save Settings ---------
function utils.saveSettings(isDarkMode)
    local file = love.filesystem.newFile("settings.txt", "w")
    file:write(isDarkMode and "dark" or "light")
    file:close()
    utils.log("Saving settings...")
end

--------- Load Settings ---------
function utils.loadSettings()
    local isDarkMode = false
    if love.filesystem.getInfo("settings.txt") then
        local file = love.filesystem.newFile("settings.txt", "r")
        local mode = file:read()
        isDarkMode = (mode == "dark")
        file:close()
    else
    	utils.log("No settings file found, creating new one...")
    	local file = love.filesystem.newFile("settings.txt", "w")
    	utils.log("Saving settings...")
    	file:write(isDarkMode and "dark" or "light")
    	file:close()
    end	
    return isDarkMode
end

--------- Print Info ---------
function utils.printInfo()
    print("----------- Info -----------")
    print(" Welcome to "..utils.name.."!")
    print(" Version: "..utils.version)
    print("\n----------- Legal -----------")
    print(" License: " .. utils.license .. "\n" ..
        " You should have received a copy of the " .. utils.license .. " with " .. utils.name .. ".\n" ..
        " If you did not, you can obtain a copy of it here:\n" ..
        " https://raw.githubusercontent.com/Thoq-jar/MeowCode/refs/heads/main/LICENSE")
    print("\n----------- Status -----------")
end

return utils
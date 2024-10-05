--[[
-- MeowCode Editor
-- By Thoq
-- License: MIT
-- Do not redistribute without MIT License ( as per license )
]]--

--------- Import Utilities ---------
local utils = require("utils")

--------- Initialize Variables ---------
name = utils.name -- Set Name --
version = utils.version -- Set Version --
license = utils.license -- Set License --
local text = "" -- Initialize Text Contents --
local cursorPosition = 1 -- Initialize Cursor Pos --
local selectionStart = nil -- Initialize Selection Start --
local selectionEnd = nil -- Initialize Selection End --
local clipboard = "" -- Initialize Clipboard --
local isDarkMode = utils.loadSettings() -- Load Settings --
local keyStates = {} -- Track Key States --
local keyRepeatDelay = 0.1 -- Delay For Key Repeat ( Seconds )
local keyRepeatTimer = 0 -- Key Repeat Timer 

----------- Initialize love ---------
function love.load()
    utils.printInfo()
    utils.log("Begin window setup [0/4]")

    utils.log("Check settings... [1/4]")
    if isDarkMode == true then
    	utils.log("Using dark mode...")
    elseif isDarkMode == false then
    	utils.log("Using light mode...")
    else
    	utils.log("Failed to load settings!")
    end

    utils.log("Settings up window [2/4]")
    love.window.setTitle("MeowCode")

    utils.log("Setting up window [3/4]")
    love.window.setMode(1000, 700, { resizable = true })

    utils.log("Setting up window [4/4]")
    love.graphics.setFont(love.graphics.newFont(14))

    utils.log("Set up successfully!")

    print("\n----------- Logs -----------")
end

--------- Handle Input ( Text ) ---------
function love.textinput(t)
    if selectionStart and selectionEnd then
        -- If Selection Then Replace With New Text --
        text = text:sub(1, selectionStart - 1) .. t .. text:sub(selectionEnd)
        cursorPosition = selectionStart + #t
        selectionStart = nil
        selectionEnd = nil
    else
        text = text:sub(1, cursorPosition - 1) .. t .. text:sub(cursorPosition)
        cursorPosition = cursorPosition + #t
    end
end

--------- Handle Shortcuts ( Keyboards ) ---------
function love.keypressed(key, scancode, isrepeat)
    keyStates[key] = true -- Mark Key As Pressed --

    -- Check If Shit Pressed --
    local shiftHeld = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

    if key == "backspace" then
        if selectionStart and selectionEnd then
            -- Delete Selected Char(s) --
            text = text:sub(1, selectionStart - 1) .. text:sub(selectionEnd)
            cursorPosition = selectionStart
            selectionStart = nil
            selectionEnd = nil
        elseif cursorPosition > 1 then
            -- Delete Next Char --
            text = text:sub(1, cursorPosition - 2) .. text:sub(cursorPosition)
            cursorPosition = cursorPosition - 1
        end
    elseif key == "delete" then
        -- Delete Char at Current Cursor Pos --
        if cursorPosition <= #text then
            text = text:sub(1, cursorPosition - 1) .. text:sub(cursorPosition + 1)
        end
    elseif key == "left" then
        -- Move Cursor Left --
        if cursorPosition > 1 then
            cursorPosition = cursorPosition - 1
        end
        if not shiftHeld then
            -- Clear selection If Shift Isn't Down --
            selectionStart = nil
            selectionEnd = nil
        end
    elseif key == "right" then
        -- Move Cursor Right --
        if cursorPosition <= #text then
            cursorPosition = cursorPosition + 1
        end
        if not shiftHeld then
            -- Clear selection If Shift Isn't Down --
            selectionStart = nil
            selectionEnd = nil
        end
    elseif key == "return" then
        -- Insert New Line at Cursor Pos --
        text = text:sub(1, cursorPosition - 1) .. "\n" .. text:sub(cursorPosition)
        cursorPosition = cursorPosition + 1 -- Move Cursor To New Line --
    elseif key == "lctrl" or key == "rctrl" then
        -- Do Nothing --
    elseif key == "a" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        -- Select All --
        selectionStart = 1
        selectionEnd = #text + 1
    elseif key == "c" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        -- Copy --
        if selectionStart and selectionEnd then
            clipboard = text:sub(selectionStart, selectionEnd - 1)
        end
    elseif key == "v" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        -- Paste --
        if clipboard then
            text = text:sub(1, cursorPosition - 1) .. clipboard .. text:sub(cursorPosition)
            cursorPosition = cursorPosition + #clipboard
        end
    elseif key == "x" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        -- Cut --
        if selectionStart and selectionEnd then
            clipboard = text:sub(selectionStart, selectionEnd - 1)
            text = text:sub(1, selectionStart - 1) .. text:sub(selectionEnd)
            cursorPosition = selectionStart
            selectionStart = nil
            selectionEnd = nil
        end
    elseif key == "d" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        -- Toggle Dark/Light Mode --
        isDarkMode = not isDarkMode
        utils.saveSettings(isDarkMode)
    else
        -- Clear Selection If *Any* Key Is Pressed And Shift Isn't Down --
        if not shiftHeld then
            selectionStart = nil
            selectionEnd = nil
        end
    end
end

function love.keyreleased(key)
    keyStates[key] = false -- Mark ( Key ) As Released --
end

--------- Update UI ---------
function love.update(dt)
    -- Key Repeating --
    keyRepeatTimer = keyRepeatTimer - dt -- Decrease Timer By Delta --

    -- Repeat Backspace Key --
    if keyStates["backspace"] and keyRepeatTimer <= 0 then
        love.keypressed("backspace")
        keyRepeatTimer = keyRepeatDelay -- Reset Timer --
    end

    -- Repeat Delete Key --
    if keyStates["delete"] and keyRepeatTimer <= 0 then
        love.keypressed("delete")
        keyRepeatTimer = keyRepeatDelay -- Reset Timer --
    end

    -- Repeat Left Key ( Arrow ) --
    if keyStates["left"] and keyRepeatTimer <= 0 then
        love.keypressed("left")
        keyRepeatTimer = keyRepeatDelay -- Reset Timer --
    end

    -- Repeat Right Key ( Arrow ) --
    if keyStates["right"] and keyRepeatTimer <= 0 then
        love.keypressed("right")
        keyRepeatTimer = keyRepeatDelay -- Reset Timer --
    end
end

--------- Draw The Window ---------
function love.draw()
    love.graphics.print("MeowCode Editor", 10, 5)

    -- Set BG And Char Color ( Editor ) --
    if isDarkMode then
        love.graphics.clear(0.1, 0.1, 0.1) -- Dark BG ( Editor ) --
        love.graphics.setColor(1, 1, 1) -- White Chars ( Editor ) --
    else
        love.graphics.clear(1, 1, 1) -- Light BG ( Editor ) --
        love.graphics.setColor(0, 0, 0) -- Black Chars ( Editor ) --
    end

    love.graphics.print(text, 10, 40) -- Draw Chars ( Editor ) --

    -- Draw Selection --
    if selectionStart and selectionEnd then
        local selectionText = text:sub(selectionStart, selectionEnd - 1)
        local selectionWidth = love.graphics.getFont():getWidth(selectionText)
        local selectionX = love.graphics.getFont():getWidth(text:sub(1, selectionStart - 1)) + 10
        love.graphics.setColor(0.7, 0.7, 1, 0.5) -- Light Blue Selection --
        love.graphics.rectangle("fill", selectionX, 40, selectionWidth, love.graphics.getFont():getHeight())
        love.graphics.setColor(isDarkMode and 1 or 0, isDarkMode and 1 or 0, isDarkMode and 1 or 0) -- Reset Char Color --
    end

    -- Draw Cursor --
    if love.timer.getTime() % 1 < 0.5 then
        local cursorX = love.graphics.getFont():getWidth(text:sub(1, cursorPosition - 1)) + 10
        love.graphics.line(cursorX, 40, cursorX, 40 + love.graphics.getFont():getHeight())
    end
end

--------- Handle Exit ---------
function love.quit()
    utils.log("Cleaning up [0/1]")
    utils.log("Cleaned up successfully! [1/1]")
    utils.log("Goodbye!")
end
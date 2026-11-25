--[[
  Rofl's Self Destruct
  Adds a third button to enchant safety StaticPopups. Clicking it accepts the
  current prompt and auto-accepts matching safety nags for the rest of this
  session only (clears on /reload or logout — no SavedVariables).
]]

local ADDON_NAME = ...

-- Session-only flag. Intentionally not SavedVariables.
local ignoreForSession = false

-- Dialogs that share the same enchant/bind safety pattern as the screenshot.
local TARGET_DIALOGS = {
	REPLACE_ENCHANT = true,
	BIND_ENCHANT = true,
	TRADE_REPLACE_ENCHANT = true,
	ACTION_WILL_BIND_ITEM = true,
	REPLACE_TRADESKILL_ENCHANT = true,
}

local BUTTON_LABEL = "Ignore for this session"
local CHAT_PREFIX = "|cff33ff99Rofl's Self Destruct:|r"

local function AcceptDialog(dialog)
	if not dialog or not dialog.which then
		return
	end
	local info = StaticPopupDialogs[dialog.which]
	if info and info.OnAccept then
		info.OnAccept(dialog, dialog.data, dialog.data2)
	end
	dialog:Hide()
end

local function EnableSessionIgnore(dialog)
	ignoreForSession = true
	AcceptDialog(dialog)
	DEFAULT_CHAT_FRAME:AddMessage(
		CHAT_PREFIX .. " Safety warnings ignored for this session. (/reload or logout to restore)"
	)
end

local function PatchDialog(which)
	local info = StaticPopupDialogs[which]
	if not info then
		return
	end

	info.button3 = BUTTON_LABEL
	-- Classic clients fire OnAlt for button3; newer clients also check OnButton3.
	info.OnAlt = EnableSessionIgnore
	info.OnButton3 = EnableSessionIgnore
end

local function PatchAllDialogs()
	for which in pairs(TARGET_DIALOGS) do
		PatchDialog(which)
	end
end

-- Auto-accept while session ignore is active.
hooksecurefunc("StaticPopup_Show", function(which)
	if not ignoreForSession or not TARGET_DIALOGS[which] then
		return
	end

	local dialog = StaticPopup_FindVisible and StaticPopup_FindVisible(which)
	if not dialog then
		-- Fallback: scan StaticPopup1..N
		local num = STATICPOPUP_NUMDIALOGS or 4
		for i = 1, num do
			local frame = _G["StaticPopup" .. i]
			if frame and frame:IsShown() and frame.which == which then
				dialog = frame
				break
			end
		end
	end

	if dialog then
		AcceptDialog(dialog)
	end
end)

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, name)
	if event == "ADDON_LOADED" and name == ADDON_NAME then
		PatchAllDialogs()
		self:UnregisterEvent("ADDON_LOADED")
	end
end)

-- Slash to clear mid-session without reload.
SLASH_ROFLSSELFDESTRUCT1 = "/rsd"
SLASH_ROFLSSELFDESTRUCT2 = "/roflsselfdestruct"
SlashCmdList.ROFLSSELFDESTRUCT = function(msg)
	msg = (msg or ""):lower():match("^%s*(.-)%s*$")
	if msg == "reset" or msg == "clear" or msg == "off" then
		ignoreForSession = false
		DEFAULT_CHAT_FRAME:AddMessage(CHAT_PREFIX .. " Session ignore cleared. Warnings will show again.")
	elseif msg == "status" then
		DEFAULT_CHAT_FRAME:AddMessage(
			CHAT_PREFIX .. " Session ignore is " .. (ignoreForSession and "ON" or "OFF")
		)
	else
		DEFAULT_CHAT_FRAME:AddMessage(CHAT_PREFIX .. " /rsd reset — show warnings again this session")
		DEFAULT_CHAT_FRAME:AddMessage(CHAT_PREFIX .. " /rsd status — check whether ignore is active")
	end
end

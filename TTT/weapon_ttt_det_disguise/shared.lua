AddCSLuaFile()

if SERVER then
--   resource.AddFile("materials/vgui/ttt/icon_confetti_gun.vmt")
end

local function DetDisguiseToggle(ply)
  if IsValid(ply) and ply:IsActiveTraitor() and ply:HasEquipmentItem(EQUIP_DETECTIVE_DISGUISE) then
    local state = ply:GetNWBool("detectiveDisguise")
    if state then
      ply:SetNWBool("detectiveDisguise", false)
    else
      ply:SetNWBool("detectiveDisguise", true)
    end
  end
end

hook.Add("HUDDrawTargetID", "BlueRing", function() --Draw the blue ring overlay
    local ply = LocalPlayer()
    local trace = ply:GetEyeTrace(MASK_SHOT).Entity
    if not trace:IsPlayer() then return end
    if trace:GetNWBool("detectiveDisguise") then
      local x = ScrW() / 2.0
      local y = ScrH() / 2.0
      local ring_tex = surface.GetTextureID("effects/select_ring")
      surface.SetTexture(ring_tex)
      surface.SetDrawColor(0, 0, 255, 220)
      surface.DrawTexturedRect(x - 32, y - 32, 64, 64) --copy core file code and apply it to the players HUD as needed
    end
end)

local EQUIP_DETECTIVE_DISGUISE

hook.Add("InitPostEntity","AddDetDisg", function()

EQUIP_DETECTIVE_DISGUISE = GenerateNewEquipmentID()
table.insert(EquipmentItems[ROLE_TRAITOR], {
  id = EQUIP_DETECTIVE_DISGUISE,
  type = "item_active",

  material = "vgui/ttt/det_disguise",
  name = "Detective Disguise",
  desc = "Equip this to enable the blue ring that detectives have"
})

end)

hook.Add("TTTPrepareRound","ResetDDisguise",function()
  for k, v in pairs(player.GetAll())--every player
  do
    v:SetNWBool("detectiveDisguise", false)
  end
end)

local function DetDisguise(ply)
  print(ply)

  local state = ply:GetNWBool("ttt_det_disguise")
    if ply:HasEquipmentItem(EQUIP_DETECTIVE_DISGUISE) then
      ply:SetNWBool("disguised", not state)
      if CLIENT then
        print("hi")
        RunConsoleCommand("ttt_cl-det_disguise", ply)
      end
    end
    print("state", state)

end

if CLIENT then
  concommand.Add("ttt_detective_disguise", DetDisguise)
  print("CLIENT")
else
  print("SERVER")
  concommand.Add("ttt_cl-det_disguise", DetDisguise)
end

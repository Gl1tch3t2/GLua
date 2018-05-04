--change bullet to tracer line of electricity
AddCSLuaFile()

SWEP.HoldType = "ar2"
local teleTime
if CLIENT then
  SWEP.PrintName = "TeleGun"
  SWEP.Slot = 6

  SWEP.ViewModelFlip = false
  SWEP.ViewModelFOV = 70

  SWEP.EquipMenuData = {
    type = "Weapon",
    desc = "Player switcher\nUseful for tricky situations\n\nNOTE: Has a cool down period \nbefore switching can occur."
  };

  SWEP.Icon = "vgui/ttt/icon_polter"
  SWEP.IconLetter = "a"
end

SWEP.Base = "weapon_tttbase"

SWEP.Primary.Recoil = 1.35
SWEP.Primary.Damage = 2
SWEP.Primary.Delay = 1
SWEP.Primary.Cone = 0.02
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 500
SWEP.Primary.ClipMax = 3
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.Primary.Sound = Sound( "Weapon_USP.SilencedShot" )
-- SWEP.Primary.SoundLevel = 50
SWEP.Primary.NumBullets = 1

SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_TRAITOR}

SWEP.UseHands = false
SWEP.IronSightsPos = Vector( -5.91, - 4, 2.84 )
SWEP.IronSightsAng = Vector(-0.5, 0, 0)

--SWEP unique variables
SWEP.TeleAvail = "Teleport Unavailable"

SWEP.ViewModel = "models/weapons/v_IRifle.mdl"
SWEP.WorldModel = "models/weapons/w_IRifle.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.DeploySpeed = 1

local tele_reel = "Weapon_357.ReplaceLoader"
local tele_shoot = "Weapon_MegaPhysCannon.Launch"

sound.Add({channel 	=	1, level	=	90, name	=	"followSound", pitch = {1, 120}, sound	=	"weapons/stunstick/alyx_stunner2.wav", volume	=	0.25})

function SWEP:WasBought(buyer)
   if IsValid(buyer) then
      buyer:GiveAmmo( 200, "AR2AltFire" )
   end
end

hook.Add("TTTPrepareRound","EndTimersTeleGun",function()
  for k, v in pairs(player.GetAll()) do
    v:SetNWBool("surfaceDiscolor", false)
  end
end)

local function SendTpTime(ply, tpTime)
  if tpTime > 31 then
    tpTime = 31
  elseif tpTime < 0 then
    tpTime = 0
  end
  net.Start("sendTeleTime")
  net.WriteInt(tpTime,5)
  if ply == BROADCAST then
    net.Broadcast()
  else
    net.Send(ply)
  end
end

net.Receive("sendTeleTime",function() teleTime = net.ReadInt(5) end)
local tpTime, tt
if SERVER then
  tpTime = CreateConVar( "telegun_timeBeforeTp", "10", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Changing this value will change how long it takes before a player can teleport with their target")
  util.AddNetworkString("sendTeleTime")
  util.AddNetworkString("sendClTeleOwe")
  tt = tpTime:GetInt()
end

hook.Add("Initialize","SetTeleGunTime",function() teleTime = tt end)

hook.Add("PlayerAuthed","UpdateTeleGunTime",function(ply)

SendTpTime(ply, tt)

end)

local changeCvar = {}
local changeState

local function ChangeCvarEndRound(cvar, ov, nv)
  ov = tonumber(ov)
  PrintTable(changeCvar)
  if GAMEMODE.round_state == ROUND_ACTIVE or ov == nv then
    if changeCvar[cvar] == nil then
      changeCvar[cvar] = tonumber(nv)
      changeState = true
      GetConVar(cvar):SetInt(teleTime)
    else
      GetConVar(cvar):SetInt(teleTime)
    end
    print("You can't change "..cvar.." during the round, that would be most unfair, this will change at end round")

  else
    tt = tpTime:GetInt()
    SendTpTime(BROADCAST, tt)
  end
  -- PrintTable(changeCvar)

end

cvars.AddChangeCallback("telegun_timeBeforeTp",ChangeCvarEndRound)

hook.Add("TTTEndRound","UpdateTeleGunCvar",function()
  if changeState then
    changeState = false

    for k, v in pairs(changeCvar) do
      GetConVar(k):SetInt(v)
    end
    table.Empty(changeCvar)
  end
 end)

local matPath = "models/weapons/v_irifle"--models/weapons/v_irifle/v_irifl
local mat = Material "models/weapons/v_irifle"
local chaPath = "models/props_combine/com_shield001a"

function SWEP:PreDrawViewModel()--Set view model to material
  self.Owner:GetViewModel():SetSubMaterial(0, "models/props_combine/com_shield001a")
  self.Owner:GetViewModel():SetSubMaterial(2, "models/props_combine/com_shield001a")
end

function SWEP:PostDrawViewModel()--Set viewmodel back to original, stops other weapons with same base material being affected
  self.Owner:GetViewModel():SetSubMaterial()
end

function SWEP:Deploy()
  self:EmitSound(tele_reel)
  return self.BaseClass.Deploy(self)
end

function SWEP:PrimaryAttack()
  if self:CanPrimaryAttack() then
    self.Owner:ViewPunch(Angle(math.Rand(1,3),math.Rand(1,3),math.Rand(1,3)))
    self:EmitSound(tele_shoot)
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay)
    self:ShootBullet()
    self:TakePrimaryAmmo(1)
  end
  self:Hud()

end

-- function SWEP:Think()
--   if self.SelTpgunTarg == nil then return end
--   if self.SelTpgunTarg ~= nil then
--   local tc = math.Round( (self.TpTime - CurTime()))
--   if CurTime() < self.TpTime then
--     self.TeleAvail = string.format("Time until teleport available: %ss", tc)
--   else
--     self.TeleAvail = "Teleport available"
--   end
--   if math.fmod(tc,4) == 0 then
--     local edata = EffectData()
--     local pos = self.Weapon:GetPos()
--     pos.z = pos.z + 48
--     edata:SetOrigin(pos)
--     edata:SetMagnitude(600)
--     edata:SetScale(600)
--     self:EmitSound("followSound")
--     util.Effect("StunstickImpact", edata)
--     end
--   end
--   self:CallHelp()
-- end

function SWEP:ShootBullet( damage, num_bullets, aimcone )

  local bullet = {}

  bullet.Num = self.Primary.NumBullets
  bullet.Src = self.Owner:GetShootPos()
  bullet.Dir = self.Owner:GetAimVector()
  bullet.Spread = Vector( self.Primary.Cone, self.Primary.Cone, 0 )
  bullet.Tracer = TRACER_LINE
  bullet.Force = 1
  bullet.Damage = self.Primary.Damage
  bullet.TracerName = "lightning_tracer"

  bullet.Callback = function(att, tr)
    local ent = tr.Entity
    if not ent:IsPlayer() or ent == self.SelTpgunTarg then return end
    self.SelTpgunTarg = ent
    if SERVER then
      self.TpTime = CurTime() + tt
    else
      self.TpTime = CurTime() + teleTime
    end
    ent:SetNWBool("surfaceDiscolor",true)
    ent.TeleOwner = self
    if SERVER then
      net.Start("sendClTeleOwe")
      net.WriteEntity(ent.TeleOwner)
      net.Send(ent)
    end
  end
  self.Owner:FireBullets( bullet )
end

net.Receive("sendClTeleOwe",function() print(LocalPlayer()) LocalPlayer().TeleOwner = net.ReadEntity() end)

local tab = {
  ["$pp_colour_addr"] = 0,
  ["$pp_colour_addg"] = 0.02,
  ["$pp_colour_addb"] = 0,
  ["$pp_colour_brightness"] = -0.08,
  ["$pp_colour_contrast"] = 1.1,
  ["$pp_colour_colour"] = 3,
  ["$pp_colour_mulr"] = 0,
  ["$pp_colour_mulg"] = 0,
  ["$pp_colour_mulb"] = 0
}

-- hook.Add("RenderScreenspaceEffects", "DiscolorTarg", function()
--   local ply = LocalPlayer()
--
--   if ply:GetNWBool("surfaceDiscolorTpGun", true) then
--     DrawColorModify( tab )
--     DrawSobel(0.8)
--   end
-- end)
if CLIENT then
  LocalPlayer():SetNWBool("surfaceDiscolorTpGun",false)
end

function SWEP:SecondaryAttack()
  if self.SelTpgunTarg == nil then return end
  if self.Owner:Crouching() then
    if SERVER then
      LANG.Msg(ply, "tele_no_crouch")
    end
    return
  end
  if CurTime() > self.TpTime and not self.SelTpgunTarg:IsSpec() then
    local chose_pos = self.SelTpgunTarg:GetPos()
    local switch_pos = self.Owner:GetPos()
    local switch_vel = self.Owner:GetVelocity()
    self.Owner:SetPos(chose_pos)
    self.Owner:SetVelocity(switch_vel * - 1)
    self.SelTpgunTarg:SetVelocity(switch_vel)
    self.SelTpgunTarg:SetPos(switch_pos)
    self.CanTp = false
    self.SelTpgunTarg:SetNWBool("surfaceDiscolor", false)
    self.SelTpgunTarg = nil
    self.TeleAvail = "Teleport Unavailable"
    self.Owner:ViewPunch(Angle (1,0,1))
  else
    local stat, check = pcall(function() local target = self.SelTpgunTarg:IsSpec() end)
    if not stat then return end
    if self.SelTpgunTarg:IsSpec() then
      self.SelTpgunTarg = nil
      self.TeleAvail = "Teleport Failed, target dead"
    end
  end
  self:Hud()
end

function SWEP:CallHelp()
  if SERVER then return end
  self:AddHUDHelp(string.format("Current Target: %s.", (self.SelTpgunTarg and self.SelTpgunTarg:Nick()) or "none"), self.TeleAvail)
end

function SWEP:Hud()
  local time_left = cvars.Number("weapon_telegun_timer")
  self:CallHelp()
end

function SWEP:Initialize()
  self:SetMaterial("models/props_combine/com_shield001a")
  self:SetHoldType("ar2")
  PrintTable(EquipmentItems[ROLE_TRAITOR])

  self:CallHelp()
end

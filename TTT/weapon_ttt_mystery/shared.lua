--change bullet to tracer line of electricity

-- This is the last item I worked on and as such has the best code, it is actually not too far from my current skill level.

AddCSLuaFile()

SWEP.HoldType = "ar2"

local mysteryOt = CreateConVar("MysteryBoxOvertime",0,{},"Can the mystery box only be used in overtime")

hook.Add("TTTBeginRound","timeBeforeUse",function()
  if not mysteryOt:GetBool() then return end
  if GetConVar("ttt_haste"):GetBool() then
    mysteryUse.TimeBeforeStart = GetConVar("ttt_haste_starting_minutes"):GetInt() * 60 + CurTime()
  else
    mysteryUse.TimeBeforeStart = GetConVar("ttt_roundtime_minutes"):GetInt() * 20 + CurTime()
  end
end)

if CLIENT then
  SWEP.PrintName = "Mystery Box"
  SWEP.Slot = 8

  SWEP.ViewModelFlip = false
  SWEP.ViewModelFOV = 70
  local add =""
  if mysteryOt:GetBool() then
    add = "Can't be used till overtime"
  end
  SWEP.EquipMenuData = {
    type = "Weapon",
    desc = "Spawn a random traitor weapon"..add
  };

  SWEP.Icon = "vgui/ttt/icon_silenced"
  SWEP.IconLetter = "a"
end

SWEP.Base = "weapon_tttbase"

SWEP.Primary.Recoil = 1.35
SWEP.Primary.Delay = 0.38
SWEP.Primary.Cone = 0.02
SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = false
SWEP.Primary.DefaultClip = 1
SWEP.Primary.ClipMax = 3
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.Primary.Sound = Sound( "Weapon_USP.SilencedShot" )
SWEP.Primary.SoundLevel = 50
SWEP.Primary.NumBullets = 1

SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_DETECTIVE}

SWEP.IsSilent = true
SWEP.UseHands = false
SWEP.IronSightsPos = Vector( -5.91, - 4, 2.84 )
SWEP.IronSightsAng = Vector(-0.5, 0, 0)

SWEP.ViewModel = "models/weapons/v_IRifle.mdl"
SWEP.WorldModel = "models/weapons/w_IRifle.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.DeploySpeed = 1

local mysteryUse = {}

-- Not my code, but I have no idea who the original author is as it is found everywhere
local function CheckIfEmpty(vec)
	local NewVec = vec
	NewVec.z = NewVec.z + 35
	NewVec.x = NewVec.x + 12.5
	NewVec.y = NewVec.y + 12.5
	if util.PointContents(NewVec) == CONTENTS_SOLID then return false end
	NewVec.z = NewVec.z - 35
	if util.PointContents(NewVec) == CONTENTS_SOLID then return false end
	NewVec.z = NewVec.z + 35
	NewVec.x = NewVec.x - 25
	if util.PointContents(NewVec) == CONTENTS_SOLID then return false end
	NewVec.z = NewVec.z - 35
	if util.PointContents(NewVec) == CONTENTS_SOLID then return false end
	NewVec.z = NewVec.z + 35
	NewVec.y = NewVec.y - 25
	if util.PointContents(NewVec) == CONTENTS_SOLID then return false end
	NewVec.z = NewVec.z - 35
	if util.PointContents(NewVec) == CONTENTS_SOLID then return false end
	NewVec.z = NewVec.z + 35
	NewVec.x = NewVec.x + 25
	if util.PointContents(NewVec) == CONTENTS_SOLID then return false end
	NewVec.z = NewVec.z - 35
	if util.PointContents(NewVec) == CONTENTS_SOLID then return false end

	return true
end

function SWEP:PrimaryAttack()
  if mysteryUse.TimeBeforeStart and (mysteryUse.TimeBeforeStart < CurTime()) then
    if CLIENT then
      chat.AddText(Color(100,100,100), "You can't use this item until overtime")
    end
    return
  end
  local ply = self.Owner
	local tr = ply:GetEyeTrace()
  if not tr.HitWorld then return end
  print(tr.HitPos:DistToSqr(ply:GetPos()))
	if tr.HitPos:DistToSqr(ply:GetPos()) > 10000 or tr.HitPos:DistToSqr(ply:GetPos()) < 2000 then return end --If you manage to get it stuck in a wall now, your problem, not mine, sorry
  	-- Although DistToSqr is here, originally this was Distance, this is an expensive function BUT
	-- as it should only ever be called at max a handful of times, it should be fine to use here instead.
	if SERVER and self.Owner:OnGround() then
    local myst = ents.Create("ttt_mystery_wepbox")
    myst:SetPos(self.Owner:GetPos() + self.Owner:GetForward() *50)
    myst:SetPos(Vector(myst:GetPos().x, myst:GetPos().y, self.Owner:GetPos().z))
    if not CheckIfEmpty(myst:GetPos()) then return end
    myst:Spawn()
    self:Remove()
  end
end


AddCSLuaFile()

SWEP.HoldType           = "grenade"

if CLIENT then
   SWEP.PrintName       = "Imploder"
   SWEP.Slot            = 8

   SWEP.ViewModelFlip   = false
   SWEP.ViewModelFOV    = 54

   SWEP.Icon            = "vgui/ttt/icon_nades"
end

SWEP.Base               = "weapon_tttbasegrenade"

SWEP.Spawnable          = true
SWEP.AutoSpawnable      = false

SWEP.UseHands           = true
SWEP.ViewModel          = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel         = "models/weapons/w_eq_fraggrenade.mdl"

SWEP.Weight             = 5

-- really the only difference between grenade weapons: the model and the thrown
-- ent.

function SWEP:GetGrenadeName()
   return "ttt_implodeGrenade"
end

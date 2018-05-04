AddCSLuaFile()
--possibly make grenade
SWEP.HoldType = "pistol"

if CLIENT then
  SWEP.PrintName = "TeleGun"
  SWEP.Slot = 6

  SWEP.ViewModelFlip = false
  SWEP.ViewModelFOV = 70

  SWEP.EquipMenuData = {
    type = "Weapon",
    desc = "Player switcher\nUseful for tricky situations\n\nNOTE: Has a cool down period \nbefore switching can occur."
  };

  SWEP.Icon = "vgui/ttt/icon_nades"
end

SWEP.Base = "weapon_tttbase"

SWEP.Primary.Recoil = 1.35
SWEP.Primary.Damage = 2
SWEP.Primary.Delay = 0.38
SWEP.Primary.Cone = 0.02
SWEP.Primary.ClipSize = 1
SWEP.Primary.Automatic = false
SWEP.Primary.DefaultClip = 1
SWEP.Primary.ClipMax = 1
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.Primary.Sound = Sound( "Weapon_USP.SilencedShot" )
SWEP.Primary.SoundLevel = 50
SWEP.Primary.NumBullets = 1

SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_TRAITOR}

SWEP.IsSilent = true

SWEP.UseHands = false
SWEP.IronSightsPos = Vector( -5.91, - 4, 2.84 )
SWEP.IronSightsAng = Vector(-0.5, 0, 0)


--SWEP unique variables

SWEP.ViewModel = "models/weapons/v_IRifle.mdl"--change to physgun with different colour
SWEP.WorldModel = "models/weapons/w_IRifle.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.DeploySpeed = 1
local tele_reel = "Weapon_357.ReplaceLoader"
local tele_shoot = "Weapon_MegaPhysCannon.Launch"
local hideGrav
local depHid = false

sound.Add({channel 	=	1, level	=	90, name	=	"followSound", pitch = {1, 120}, sound	=	"weapons/stunstick/alyx_stunner2.wav", volume	=	0.25})


if SERVER then
  util.AddNetworkString("hideGravChange")
  util.AddNetworkString("broadHide")

  net.Receive("hideGravChange",function()
      local hide = tobool(net.ReadBit())
      local amm = net.ReadInt(12)
      net.Start("broadHide")
      net.WriteBit(hide)
      net.Broadcast()
      -- for k, v in pairs(player.GetAll()) do
        -- if not v:IsTraitor() then
          -- print("Player v is" ..tostring(v))
          -- net.Send(v)
        -- end
      -- end
      timer.Simple(0.01, function() RunConsoleCommand("sv_gravity", amm) end)
    end)
  --convars
end

if CLIENT then
  net.Receive("broadHide",function() hideGrav = tobool(net.ReadBit()) print("THIS IS WHAT WE CALL hideGrav"..tostring(hideGrav)) end)
end
-- 600 not being read when it should, 100 working
hook.Add( "ChatText", "hide_gravChange", function( index, name, text, typ )
  local dibs = LocalPlayer()
  print("hideGrav"..tostring(hideGrav))
  -- print("condition"..tostring( typ == "servermsg" and (text == "Server cvar 'sv_gravity' changed to 600.00" or text == "Server cvar 'sv_gravity' changed to 100.00" and hideGrav)))
	if ( typ == "servermsg") then
     if text == "Server cvar 'sv_gravity' changed to 600.00" or text == "Server cvar 'sv_gravity' changed to 100.00" then
       if dibs:IsTraitor() and hideGrav then return
       else
         return true
       end

      --  for k, v in pairs(player.GetAll()) do
      --    print(v:GetActiveWeapon())
      --    if v:IsTraitor() and v:GetActiveWeapon() ~= "weapon_ttt_phys" then
      --      print(v:IsTraitor() )
      --      return true
      --     end
      --   end
     end
   end
end )

-- hook.Add( "ChatText", "hide_gravChange", function( index, name, text, typ )
--     local isHoldingGun = false
--     local ply = LocalPlayer()
--     local weaponclass = "weapon_ttt_phys"
--     local noddy = false
--     local normgrav = "Server cvar 'sv_gravity' changed to 600.00"
--     local lowgrav = "Server cvar 'sv_gravity' changed to 100.00"
--     if ( typ == "servermsg" ) and ( text == normgrav or lowgrav ) then
--         for k, v in pairs( player.GetAll() ) do
--           print(v.Modify)
--             if (v:GetActiveWeapon():GetClass() == weaponclass and v.Modify) then
--                 isHoldingGun = true
--                 noddy = true
--                 ply.Modify = false
--                 break -- No need to check if more then one player is holding it out
--             else
--                 isHoldingGun = false
--             end
--         end
--         if (isHoldingGun and noddy) then
--             if ( !ply:IsTraitor() ) then
--                 return true
--             else
--                 return false
--             end
--         else
--             return false
--         end
--     end
-- end)

-- local matPath = "models/weapons/v_irifle/v_irifle_sheet"--models/weapons/v_irifle/v_irifl
--
-- function SWEP:PreDrawViewModel( vm )--Set view model to material
--   Material(matPath):SetTexture("$basetexture", "models/props_combine/com_shield001a")
-- end
--
-- function SWEP:PostDrawViewModel( vm )--Set viewmodel back to original, stops other weapons with same base material being affected
--   Material(matPath):SetTexture("$basetexture", matPath)
-- end

function SWEP:Deploy()
  self:SetDeploySpeed(self.DeploySpeed)
  self:EmitSound(tele_reel)
  return self.BaseClass.Deploy(self)
end

function SWEP:TakePrimaryAmmo( num )
if ( self.Weapon:Clip1() <= 0 ) then
  if ( self:Ammo1() <= 0 ) then return end
  self.Owner:RemoveAmmo( num, self.Weapon:GetPrimaryAmmoType() )
  return end
  self.Weapon:SetClip1( self.Weapon:Clip1() - num )
end


function SWEP:GravModify(ply, type, amm)
  if not ply:IsTraitor() then return end
  if depHid then
    depHid = false
  else
    depHid = true
  end
  if amm > 1000 then
    amm = 1000
  elseif amm < -1000 then
    amm = -1000
  end
  if CLIENT then
    net.Start("hideGravChange")
    net.WriteBit(depHid)
    net.WriteUInt(amm,12)
    net.SendToServer()
  end
end


function SWEP:PrimaryAttack()
    self:EmitSound(tele_shoot)
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay)
    -- self:ShootBullet()
    -- self:TakePrimaryAmmo(1)
    self.Owner.Modify = true
    self:GravModify(self.Owner, nil, 100)
  -- target:SelectWeightedSequence(ACT_BIG_FLINCH)
  -- self.Owner:FireBullets( bullet )
end

function SWEP:SecondaryAttack()
  self:GravModify(self.Owner, nil, 600)
end

function SWEP:Initialize()
  self:SetMaterial("models/props_combine/com_shield001a")
end

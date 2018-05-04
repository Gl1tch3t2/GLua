include("shared.lua")


-- AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/w_eq_fraggrenade_thrown.mdl")

DEFINE_BASECLASS "ttt_basegrenade_proj"

function ENT:Initialize()
  BaseClass.Initialize(self)
  self.velCount = 0
  self.freeze = true
  self.affPly = {}
end

local function PushPullRadius(pos, pusher, self)
  print(self.velCount)
  if self.velCount > 0 then return end
   local radius = 400 --400
   local phys_force = -1500
   local push_force = 256
   -- pull physics objects and push players
   for k, target in pairs(ents.FindInSphere(pos, radius)) do
      if IsValid(target) and target:IsPlayer() and target:Alive() and target ~= self then
        --Get max distance affected - get normal
        --Get distance between player pos and grenade pos
        --muliply maxDist * actDist
        -- local maxDist = pos

        local targ_pos = target:GetPos()
        local dis = (pos - targ_pos):GetNormal() --number between 0 - 1
        local vel = dis * pos:DistToSqr(targ_pos) / 50
        target:SetVelocity(Vector(vel.x, vel.y, target:GetPos().z + 600))
        print(target:GetVelocity())
        -- target.ImpFreeze = true
        self.Implode = true
        table.insert(self.affPly,target)
        -- timer.Simple(0.3, function() print(pos:DistToSqr(targ_pos), "\t", pos:Distance(targ_pos), "\r\n ") end)
        -- timer.Simple(3.5, function() target:SetVelocity(target:GetVelocity() * - 1) target:SetMoveType(MOVETYPE_WALK) end)
      end
   end

   -- for k = 1, player.GetCount() do
   --   local v = player.GetAll()[k]
   --   if not v:Alive() then continue end
   --   if pos:DistToSqr(v:GetPos()) < radius then
   --     local maxDist =
   -- end

   local phexp = ents.Create("env_physexplosion")
   if IsValid(phexp) then
      phexp:SetPos(pos)
      phexp:SetKeyValue("magnitude", 100) --max
      phexp:SetKeyValue("radius", radius)
      -- 1 = no dmg, 2 = push ply, 4 = push radial, 8 = los, 16 = viewpunch
      phexp:SetKeyValue("spawnflags", 3)
      phexp:Spawn()
      phexp:Fire("Explode", "", 0.2)
   end
end

function ENT:Think()
  BaseClass.Think(self)
  if self.Implode then
    if self.freeze then self.freeze = false return end
    for k, v in pairs(self.affPly) do
      if self.velCount == 0 then
        v:SetMoveType(MOVETYPE_NONE)
        v:SetVelocity(v:GetVelocity() * -1)
      elseif self.velCount >= 10 then
        v:SetVelocity(v:GetVelocity() * -1)
        v:SetMoveType(MOVETYPE_WALK)
      else
        -- local xRand, yRand, zRand = math.Rand(0,10)
        -- v:SetVelocity(VectorRand())
      end
      self.velCount = self.velCount + 0.5
    end
  end
end

local zapsound = Sound("npc/assassin/ball_zap1.wav")
function ENT:Explode(tr)
   if SERVER then
      self:SetNoDraw(true)
      self:SetSolid(SOLID_NONE)
      self:SetMoveType(MOVETYPE_NONE)
      self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)


      -- pull out of the surface
      if tr.Fraction ~= 1.0 then
         self:SetPos(tr.HitPos + tr.HitNormal * 0.6)
      end

      local pos = self:GetPos()

      PushPullRadius(pos, self:GetThrower(), self)
      -- make sure we are removed, even if errors occur later
      if self.velCount < 10 then return end
      self:Remove()

      local effect = EffectData()
      effect:SetStart(pos)
      effect:SetOrigin(pos)

      if tr.Fraction ~= 1.0 then
         effect:SetNormal(tr.HitNormal)
      end

      util.Effect("Explosion", effect, true, true)
      util.Effect("cball_explode", effect, true, true)

      sound.Play(zapsound, pos, 100, 100)
   else
      local spos = self:GetPos()
      local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
      util.Decal("SmallScorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)

      self:SetDetonateExact(0)
   end
end

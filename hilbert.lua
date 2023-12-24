local NOT, AND, XOR, OR, SHL, SAR, SHR; do
    local bit = require("bit")
    NOT = bit.bnot
    AND = bit.band
    XOR = bit.bxor
    OR = bit.bor
    SHL = bit.lshift
    SAR = bit.arshift
    SHR = bit.rshift
    bit = nil
end

local function xy2d(n, x, y)
    n = SHR(n, 1)
    local rx, ry, d = 0, 0, 0
    while n > 0 do
        -- BAND(x, n) > 0 and -1 or 0
        rx = SAR(NOT(AND(x, n) - 1), 31) -- -1|0
        -- BAND(y, n) > 0 and 1 or 0
        ry = SHR(NOT(AND(y, n) - 1), 31) -- 1|0
        
        --[[ mbmb
            qn = n*n
            LOOP:
            rx = SHR(NOT(AND(x, n) - 1), 31) -- 1|0
            ry = SHR(NOT(AND(y, n) - 1), 31) -- 1|0
            
            rx == 0 and ry == 0 --> 0*qn --> 0
            rx == 0 and ry == 1 --> 1*qn --> qn
            rx == 1 and ry == 1 --> 2*qn --> qn + qn
            rx == 1 and ry == 0 --> 3*qn --> qn + qn + qn
            
            d = d + OR( AND(qn, -XOR(rx, ry)) + AND(SHL(qn, 1), -rx) )
            
            qn = SHR(qn, 2)
        --]]
        d = d + XOR(AND(3, rx), ry)*n*n
        
        -- if ry == 0 then XOR SWAP(x, y)
        -- -- if rx ~= 0 then x, y = NOT(x), NOT(y) 
        x = XOR(x, AND(y, ry - 1) + AND(NOT(y + y), rx)) -- NOT(y + y) == 1 - y - y
        y = XOR(y, AND(x, ry - 1))
        x = XOR(x, AND(y, ry - 1) + AND(NOT(y + y), rx))
        n = SHR(n, 1) -- n = floor(n/2)
    end
    return d
end

local function d2xy(n, d)
    local rx, ry, x, y = 0, 0, 0, 0
    local s, t = 1, d
    while s < n do
        rx = AND(1, SHR(t, 1)) -- 1|0
        ry = AND(1, XOR(t, rx)) -- 1|0
        
        -- if ry == 0 then XOR SWAP(x, y)
        -- -- if rx ~= 0 then x, y = s + NOT(x), s + NOT(y) 
        x = XOR(x, AND(y, ry - 1) + AND(s + NOT(y + y), -rx))
        y = XOR(y, AND(x, ry - 1))
        x = XOR(x, AND(y, ry - 1) + AND(s + NOT(y + y), -rx))
        x = OR(x + AND(s, -rx)) -- x = x | x = x + s
        y = OR(y + AND(s, -ry)) -- y = y | y = y + s
        s = SHL(s, 1) -- s = s*2
        t = SHR(t, 2) -- t = t/4
    end
    return x, y
end

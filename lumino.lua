-- Copyright github.com/kengonakajima 2012
-- License: Apache 2.0
-- Compatibility: server: luvit, client: MoaiSDK

-- envs
local luvit, moai = {}, {}

pcall( function()
    _G.socket = require("socket")
  end)

if MOAISim then
  
else
  _G.table = require("table")
  _G.math = require("math")
  _G.io = require("io")
  _G.string = require("string")
  _G.os = require("os")
  local res,mod = pcall( function() return require("uv_native") end)
  if res then _G.uv = mod end -- luvit only
  res, mod = pcall( function() return require("ffi") end) 
  if res then _G.ffi = mod end -- luajit only
  res, mod = pcall( function() return require("net") end)
  if res then _G.net = mod end  
end

-- math and lua values
-- bool to integer
function _G.b2i(b) if b then return 1 else return 0 end end
function _G.nilzero(v) if v == nil then return 0 else return v end end
_G.abs = math.abs
_G.sqrt = math.sqrt
_G.epsilon = 0.000001
function _G.neareq(v1,v2) return (abs(v2-v1) < epsilon) end
function _G.len(x0,y0,x1,y1) return math.sqrt( (x0-x1)*(x0-x1) + (y0-y1)*(y0-y1) ) end
function _G.normalize(x,y,l)
  ll = len(0,0,x,y)
  return x / ll * l, y / ll * l
end
function _G.int(x)
  if not x then
    return 0
  else
    if type(x) == "boolean" then
      return 1
    else
      return math.floor(x)
    end
  end  
end
function _G.int2(x,y) return int(x), int(y) end
function _G.int3(a,b,c) return int(a),int(b),int(c) end
function _G.range(a,b) return a + ( b - a ) * math.random() end
function _G.irange(a,b) return math.floor(range(a,b)) end
function _G.birandom() return (math.random() < 0.5) end
function _G.plusminus(x) if math.random()<0.5 then return x else return x *-1 end end
function _G.avg(a,b) return (a+b)/2 end
function _G.avgs(...)
  local t = {...}
  local total = 0
  for _,v in ipairs(t) do total = total + v end
  return total / #t
end
function _G.sign(x) if x>0 then return 1 elseif x < 0 then return -1 else return 0 end end
-- get between a,b by ratio of aa<=v<=bb
-- get 3 if a,b=1,10 and aa=10,bb=100 and v=30
function _G.ratio(a,b,aa,bb, v)
  local da = v - aa
  local d = bb - aa
  local r = da / d
  return a + (b-a) * r
end

function _G.min(a,b)
  if not a and not b then return 0 end
  if not a then return b end
  if not b then return a end
  if a < b then return a else return b end
end
function _G.max(a,b)
  if not a and not b then return 0 end
  if not a then return b end
  if not b then return a end   
  if a > b then return a else return b end
end

-- table funcs
function _G.merge(to,from)  -- overwrite merge
  for k,v in pairs(from) do
    to[k]=v
  end
  return to
end
function _G.sort(t,f)
  table.sort(t,f)
  return t  
end
function _G.choose(ary) return ary[ int(  math.random() * #ary ) + 1] end
function _G.shuffle(array)
  local arrayCount = #array
  for i = arrayCount, 2, -1 do
    local j = math.random(1, i)
    array[i], array[j] = array[j], array[i]
  end
  return array
end
function _G.find(t,f)
  if type(f)=="function" then
    for i,v in ipairs(t) do
      if f(v) then return v end
    end
  else
    for i,v in ipairs(t) do
      if v==f then return v end
    end
  end
  return nil  
end
function _G.scan(t,f)
  for i,v in ipairs(t) do
    f(v)
  end  
end
function _G.filter(t,f)
 local out={}
  for i,v in ipairs(t) do
    local r = f(v)
    if r then 
      table.insert(out, r)
    end
  end
  return out
end
function _G.count(t,f)
  local cnt=0
  for i,v in ipairs(t) do
    if (not f) or f(v) then cnt = cnt + 1 end
  end
  return cnt
end
function _G.sumValues(t)
  local tot=0
  for k,v in pairs(t) do
    tot = tot + v
  end
  return tot
end
function _G.table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end
function _G.table.dupArray(t)
  local out={}
  for i,v in ipairs(t) do
    out[i] = v
  end
  return out  
end
function _G.map(tbl,fncname, ...)
  assert(fncname)
  local out={}
  for k,v in pairs(tbl) do
    if type(v) == "table" then
      local f = v[fncname]
      if type(f) == "function" then
        out[k] = f( v, ... )
      end
    end    
  end
  return out
end
function _G.valcopy( tbl )
  local out ={}
  for k,v in pairs(tbl) do
    if type(v)=="number" or type(v)=="string" or type(v)=="boolean" or type(v) == "boolean" then
      out[k] = v
    end
  end
  return out
end
function _G.deepcompare(t1,t2,ignore_mt,eps)
  local ty1 = type(t1)
  local ty2 = type(t2)

  if ty1 ~= ty2 then return false end
  -- non-table types can be directly compared
  if ty1 ~= 'table' then
    if ty1 == 'number' and eps then return abs(t1-t2) < eps end
    return t1 == t2
  end
  -- as well as tables which have the metamethod __eq
  local mt = getmetatable(t1)
  if not ignore_mt and mt and mt.__eq then
    return t1 == t2
  end
  for k1,v1 in pairs(t1) do
    local v2 = t2[k1]
    if v2 == nil or not deepcompare(v1,v2,ignore_mt,eps) then
      return false
    end
  end
  for k2,v2 in pairs(t2) do
    local v1 = t1[k2]
    if v1 == nil or not deepcompare(v1,v2,ignore_mt,eps) then
      return false
    end
  end
  return true
end

-- string funcs
_G.byte = string.byte
function _G.split(str, delim)
  assert(delim)
  if string.find(str, delim) == nil then
    return { str }
  end

  local result = {}
  local pat = "(.-)" .. delim .. "()"
  local lastPos
  for part, pos in string.gfind(str, pat) do
    table.insert(result, part)
    lastPos = pos
  end
  table.insert(result, string.sub(str, lastPos))
  return result
end
_G.string.split = split



-- return value nearer to __from__
function _G.nearer(from,a,b)
  local da = math.abs(a-from)
  local db = math.abs(b-from)
  if da < db then
    return a
  else
    return b
  end   
end

-- log funcs
function _G.dump1(s,t)
  for k,v in pairs(t) do print( s, k,v ) end
end
function _G.printTrace(erro)
  print( erro )
  print( debug.traceback(100) )
end
function _G.sprintf(...) return string.format(...) end
function _G.printf(...) return io.stdout:write( sprintf(...) ) end 
function _G.prt(...)
  local s = table.concat({...}," ")
  io.stdout:write(s)
end
function _G.dump(t)
  for i=1,#t do
    print( "["..i.."]", t[i])
  end
  for k,v in pairs(t) do
    print(k,v)
    if type(v) == "table" then
      dump(v)
    end
  end
end
function _G.num2digitString(n)
  local s
  if n == 1 then
    s = ""
  elseif n < 10 then
    s = string.format( " %d", n )
  else
    s = string.format( "%d", n )
  end
  return s
end
function _G.appendLog(path,s)
  local fp = assert(io.open(path,"a+"))
  fp:write("["..os.date().."] "..s.."\n")
  fp:close()
end
function _G.TextTable(w,h,default)
  local t = {
    data = {},
    w = w,
    h = h
  }
  
  for y=1,h do
    t.data[y] = {}
    for x=1,w do
      t.data[y][x] = default
    end
  end
  function t:getChar(x,y)
    return self.data[int(y)][int(x)] 
  end  
  function t:setChar(x,y,c)
    self.data[int(y)][int(x)] = c    
  end
  function t:toString()
    local ary = {}
    for y=self.h-1,1,-1 do
      table.insert( ary, table.concat( self.data[y] ) )
    end
    return table.concat( ary, "\n" )
  end  
  
  return t    
end



-- timer funcs
_G.now = os.time -- overwritten by UV and MOAI on last merge
function _G.measure( f )
  local st = now()
  f()
  local et = now()
  return (et-st)
end

_G.laterCalls={}
function _G.later(latency,f)
  table.insert( laterCalls, { callAt = now() + latency, func = f } )
end

function _G.pollLater()
  local nt = now()
  for i,v in ipairs(laterCalls) do
    if v.callAt < nt then
      v.func()
      table.remove(laterCalls,i)
    end    
  end  
end


-- file funcs
function _G.readFile(path)
  local fp = io.open(path)
  local s = fp:read(1024*1024*1024)
  fp:close()
  return s
end
function _G.writeFile(path,data)
  local fp = io.open(path,"w")
  fp:write(data)
  fp:close()
end
function _G.existFile(fn)
  local f = io.open(fn)
  if not f then
    return false
  else
    f:close()
    return true
  end
end


-- csv funcs
function _G.loadTableFromCSV(fn)
  if existFile(fn) then
    local csv = readCSV(fn)
    return csvToTable(csv)
  else
    return {}
  end
end

function _G.saveTableToCSV(fn,t)
  local csv={}
  local cnt=1
  for k,v in pairs(t) do
    table.insert( csv, { [1]=k,[2]=v } )
  end
  writeCSV(fn,csv)
end

-- csv: array of array
function _G.csvToTable(csv)
  local out={}
  for i,row in ipairs(csv) do
    out[ row[1] ] = row[2]
  end
  return out
end

function _G.readCSV(file)
  local fp = assert(io.open (file))
  local csv = {} 
  for line in fp:lines() do
    if not line then break end
    local row = split(line,",")
    csv[#csv+1] = row
  end
  fp:close()
  return csv
end

function _G.writeCSV(file,tab)
  local fp = assert(io.open(file,"w"))
  for i,row in ipairs(tab) do
    for i,value in ipairs(row) do
      fp:write(tostring(value)..",")
    end
    fp:write "\n"
  end
  fp:close()
end



-- 2D/3D funcs
function _G.randomize2D(x,y,r) return x + ( -r  + math.random() * (r*2) ), y + ( -r  + math.random() * (r*2) ) end
function _G.expandVec(fromx,fromy,tox,toy,tolen)
  local dx,dy = (tox-fromx),(toy-fromy)
  local nx,ny = normalize(dx,dy,tolen)
  return fromx + nx, fromy + ny  
end
function _G.len3d(x0,y0,z0,x1,y1,z1)   return math.sqrt( (x0-x1)*(x0-x1) + (y0-y1)*(y0-y1) + (z0-z1)*(z0-z1) ) end
function _G.vec3len(va,vb) return math.sqrt( (va.x-vb.x)*(va.x-vb.x) + (va.y-vb.y)*(va.y-vb.y) + (va.z-vb.z)*(va.z-vb.z) ) end
function _G.vec3sub(va,vb) return { x = vb.x-va.x, y = vb.y-va.y, z = vb.z-va.z } end
function _G.vec3eq(va,vb) return ( va.x==vb.x and va.y==vb.y and va.z==vb.z) end
function _G.vec3cross(v1,v2)
  local x1,y1,z1 = v1.x, v1.y, v1.z
  local x2,y2,z2 = v2.x, v2.y, v2.z
  return { 
    x = y1 * z2 - z1 * y2,
    y = z1 * x2 - x1 * z2,
    z = x1 * y2 - y1 * x2
  }  
end
function _G.vec3dot(v1,v2) return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z end
function _G.vec3normalize(v)
  local l = math.sqrt( v.x*v.x + v.y*v.y + v.z*v.z )
  return vec3(v.x/l, v.y/l, v.z/l)
end
function _G.vec3(x,y,z) return {x=x,y=y,z=z} end
function _G.vec3toString(v) return string.format("(%f,%f,%f)", v.x, v.y, v.z ) end
function _G.vec3toIntString(v) return string.format("(%d,%d,%d)", v.x, v.y, v.z ) end
-- t, u,v 
function _G.triangleIntersect( orig, dir, v0,v1,v2 )
  local e1 = vec3sub(v1,v0)
  local e2 = vec3sub(v2,v0)
  local pvec = vec3cross(dir,e2)
  local det = vec3dot(e1,pvec)
  
  local tvec = vec3sub(orig,v0)
  local u = vec3dot(tvec,pvec)
  local qvec
  local v
  if det > 1e-3 then
    if u < 0 or u > det then return nil end
    qvec = vec3cross(tvec,e1)
    v = vec3dot(dir,qvec)
    if v < 0 or u+v >det then return nil end
  elseif det < - 1e-3 then
    if u > 0 or u < det then return nil end
    qvec = vec3cross(tvec,e1)
    v = vec3dot(dir,qvec)
    if v > 0 or u+v <det then return nil end
  else
    return nil
  end
  local inv_det = 1 / det  
  local t = vec3dot(e2,qvec)
  t = t * inv_det * -1
  u = u * inv_det
  v = v * inv_det
  return t,u,v
end


-- rect funcs
function _G.Rect(minx,miny,maxx,maxy)
  local r = { minx=minx, maxx=maxx, miny=miny,maxy=maxy }
  function r:include(x,y) return ( x >= self.minx and x <= self.maxx and y >= self.miny and y <= self.maxy ) end  
  return r
end
function _G.squareRect(cx,cy,w)
  assert(cx and cy and w )
  return Rect( cx-w,cy-w,  cx+w,cy+w )
end

-- sz from center
function _G.makeHitRect(prop, sz )
  assert(sz)
  local x,y = prop:getLoc()
  return { x0 = x - sz, y0 = y - sz, x1 = x + sz, y1 = y + sz }
end
function _G.checkHitRects(rects, x,y,arg, cb)
  for i,v in ipairs(rects) do
    if x >= v.hitRect.minx and x <= v.hitRect.maxx and y >= v.hitRect.miny and y <= v.hitRect.maxy then
      if cb then
        cb(v,x,y,arg)
      elseif v.callback then
        v:callback(x,y,arg)
      end
    end
  end  
end
function _G.scanCircle(cx,cy,dia,step,fn)
  local rdia = int(dia*1.41)
  for x=cx-rdia,cx+rdia,step do
    for y=cy-rdia,cy+rdia,step do
      if len( cx,cy,x,y) < dia then
        fn(x,y)
      end         
    end
  end  
end
function _G.scanRect(x0,y0,x1,y1,fn)
  for y=y0,y1 do
    for x=x0,x1 do
      fn(x,y)
    end
  end
end



-- 4dirs
_G.DIR = { UP=0,RIGHT=1,DOWN=2,LEFT=3 }
_G.DIRS = { DIR.UP, DIR.RIGHT, DIR.DOWN, DIR.LEFT }
_G.DIR2CHAR = { [DIR.UP]="^", [DIR.DOWN]="v", [DIR.LEFT]="<", [DIR.RIGHT]=">"}
function _G.dir2char(d)
  local out = DIR2CHAR[d]  
  if not d or not out then return "+" end
  return out
end
function _G.randomDir() return choose( DIRS ) end

function _G.reverseDir(d)
  if d == DIR.UP then
    return DIR.DOWN
  elseif d == DIR.DOWN then
    return DIR.UP
  elseif d == DIR.LEFT then
    return DIR.RIGHT
  elseif d == DIR.RIGHT then
    return DIR.LEFT
  else
    assert(false)
  end   
end

-- poly: assuming aabb {x,y,x,y,x,y,x,y}
function _G.calcArea( poly )
  x0,y0,x1,y1,x2,y2,x3,y3 = poly[1],poly[2],poly[3],poly[4],poly[5],poly[6],poly[7],poly[8]
  leftx = min( min(x0,x1), min(x2,x3) )
  rightx = max( max(x0,x1), max(x2,x3) )
  bottomy = min( min(y0,y1), min(y2,y3) )
  topy = max( max(y0,y1), max(y2,y3) )
  return ( rightx - leftx ) * ( topy - bottomy )
end


-- networking and DB
function _G.sendmail( from, to, subj, msg )
  assert(msg)
  local cl
  cl = net.createConnection(25, '127.0.0.1', function (err)
      if err then error(err) end

      print("connected")

      cl.got = ""
      cl:on("data", function(data)
          cl.got = cl.got .. data
          local lines = split( cl.got, "\r\n" )
          for i,l in ipairs(lines) do
            local ary = split(l, " " )
            if ary[1] == "221" then
              print("finished")
              native.close( cl._handle ) 
            end
          end
        end)
      cl:on("error", function(e)
          print("error:",e)
        end)
        
      cl:write( "HELO localhost.localdomain\r\n" )

      cl:write( "EHLO localhost.localdomain\r\n")
      cl:write( "MAIL FROM:<" .. from .. ">\r\n") 
      cl:write( "RCPT TO:<" .. to .. ">\r\n") 
      cl:write( "DATA\r\n")                 
      cl:write( "Subject: " .. subj .. "\r\n") 
      cl:write( "From: " .. from .. "\r\n")   
      cl:write( "Content-type: text/plain; charset=iso-2022-jp\r\n")
      cl:write( "Sender: " .. from .. "\r\n" )
      cl:write( "Date: " .. os.date() .. "\r\n" )
      cl:write( "To: " .. to .. "\r\n" )
      cl:write( "\r\n" )
      cl:write( "\r\n" )
      cl:write( msg )
      cl:write( "\r\n" )      
      cl:write( ".\r\n" )
      cl:write( "QUIT\r\n" )
    end)
end


function _G.isByteUsableInName(b)
  -- 0-9 A-Z a-z _ -
  return (b >= 48 and b <= 57) or (b>=65 and b<=90) or (b>=97 and b<=122) or b==95 or b==45
end
function _G.isUsableInName(str)
  for i=1,#str do
    if not isByteUsableInName(str:byte(i,i)) then
      return false
    end    
  end
  return true
end
  
_G.globalCounterGen = 0
function _G.generateNewId()
  globalCounterGen = globalCounterGen + 1
  return globalCounterGen
end

-- UNIX funcs
if ffi then 
  ffi.cdef[[
      int getpid();
      int sigignore(int sig);

      struct timeval {
        long  tv_sec;   
        long  tv_usec;  
      };    
      int gettimeofday(struct timeval *restrict tp, void *restrict tzp);
  ]]
  function _G.now()
    local tmv = ffi.new( "struct timeval")
    ffi.C.gettimeofday( tmv, nil )
    return tonumber(tmv.tv_sec) + tonumber(tmv.tv_usec) / 1000000
  end

  function _G.getpid()
    return ffi.C.getpid()
  end
  function _G.sigignore(sig)
    return ffi.C.sigignore(sig)
  end
  function _G.ignoreSIGPIPE() 
    sigignore(13) -- works for linux and osx
  end
  function _G.savePidFile(path)
    writeFile(path, ""..getpid().."\n")
  end
end

-- MOAI funcs
function moai.now() return MOAISim.getDeviceTime() end
function moai.propDistance(p0,p1)
  local x0,y0 = p0:getLoc()
  local x1,y1 = p1:getLoc()
  return len(x0,y0,x1,y1)
end
function moai.swapPropPrio(ap,bp)
  ai = ap:getPriority()
  bi = bp:getPriority()
  ap:setPriority(bi)
  bp:setPriority(ai)
end
function moai.loadTileDeck( path, w, h, fil, wrp )
   local t = MOAITexture.new()
   t:load(path)
   if fil then t:setFilter(fil) end
   if wrp then t:setWrap(wrp) end
   local d = MOAITileDeck2D.new()
   d:setTexture(t)
   d:setSize(w,h,1/w,1/h,0,0,1/w,1/h)
   
   d:setRect( -0.5, -0.5, 0.5, 0.5 )
   return d
end

function moai.loadTileDeck2( path, w, h, sz, fullxsz, fullysz, fil, wrp )
   local t = MOAITexture.new()
   t:load(path)
   if fil then t:setFilter(fil) end
   if wrp then t:setWrap(wrp) end
   local d = MOAITileDeck2D.new()
   d:setTexture(t)
--   d:setSize(w,h,1/w,1/h,0,0,1/w,1/h)
   local xr,yr = sz/fullxsz, sz/fullysz
   d:setSize(w,h,  xr,yr, 0,0, xr,yr )
   
   d:setRect( -0.5, -0.5, 0.5, 0.5 )
   return d
 end

function moai.loadTex( path )
  local t = MOAITexture.new()
  t:load( path )
  return t
end

function moai.loadGfxQuad( path )
  local gq = MOAIGfxQuad2D.new()
  gq:setTexture( path )
  gq:setRect( -64,-64,64,64 )
  gq:setUVRect( 0,1,1,0)
  return gq    
end
function moai.loadImage(path)
   local img = MOAIImage.new()
   img:load( path, 0 )
   return img
end


function moai.loadWav( fn ,v)
  if not hasSound then
    local dummy = {}
    function dummy:play()    end
    function dummy:playDistance()    end    
    return dummy
  end
    
  local s = MOAIUntzSound.new()
  s:load( fn,true )    -- 8/15のバージョンで３つ目の引数にtrueつけると何度も再生できた
  s:setVolume(v)
  s.baseVolume = v
  s:setLooping(false)
  s:setPosition(0)
  print( "loadWav:", fn )
  function s:playDistance(x0,y0,x1,y1)
    local d = len(x0,y0,x1,y1) / ( 32 * 8 ) -- 16セルで半分
    if d < 1 then d = 1 end
    local v = self.baseVolume * 1 / d
    self:setVolume( v )
    self:play()
  end
  return s
end


-- Emulate luvit's net with luasocket. (Client only)
function moai_luvit_net_createConnection(port,ip,cb)
  print("net_createConnection called. port:",port,"ip:",ip,"cb:",cb)
  local conn = {}
  conn.sock = socket.tcp()
  conn.sock:settimeout(0)
  conn.sock:connect(ip,port)
  conn.state = "connecting"
  
  conn.callbacks = {}
  function conn:on(ev,cb)
    self.callbacks[ev] = cb
  end
  function conn:emit(data,cb)
    self:write(data,cb)
  end
  function conn:write(data,cb)
    if self.closed then
      print("write: socket closed!")
      return 0
    end
    return self.sock:send(data)
  end

  function conn:close()
    self.closed = true
    return self.sock:close()
  end
  
  function conn:poll()
    if self.closed then error("socket closed") end    
    if not self.counter then self.counter = 1 end

    self.counter = self.counter + 1
    local sendt,recvt = {},{}
    table.insert(sendt,self.sock)
    table.insert(recvt,self.sock)         
    local rs,ws,e = socket.select(recvt,sendt,0)

    if ws[1] == self.sock then
      if self.state == "connecting" then
        print("luvitemu: connected!")
        if self.callbacks["complete"] then
          self.callbacks["complete"]()
        end
        self.state = "connected"
      end
    end
    if rs[1] == self.sock then
      if self.state == "connected" then
        local res, msg, partial = self.sock:receive(1024*1024*16) -- try to get everything
        if not res and msg == "closed" then
          self.state = "closed"
          if self.callbacks["end"] then
            self.callbacks["end"]()
          end                  
        else
          local got
          if partial then got = partial end
          if res then got = res end
          if got then
            if self.callbacks["data"] then
              self.callbacks["data"](got)
            end
          end
        end               
      end
    end
  end
  return conn
end

moai.LuvitNetEmu = {
  createConnection = moai_luvit_net_createConnection
}


function mprpc_init_conn(conn)
  conn.super_on = conn.on -- replace superclass "on" func..

  if conn._handle then
    conn.hasHandle = true
  end
    
  conn.doLog = false

  if not conn._pendingWriteRequests then -- in MOAI and other luasocket environments
    conn._pendingWriteRequests = 0
  end
  
  conn.packetID = 0
  conn.roundTripFuncID = 1

  conn.recvbuf = ""
  function conn:log(...)
    if self.doLog then print(...) end
  end

  conn.doSelfTest = false

  conn.packetID = 0
  conn.waitfuncs = {}

  conn.tmpwbufs = {}
  
  conn.rpcfuncs = {}
  function conn:on(evname,fn)
    if evname == "data" then
      error("MP need data event!")
    elseif evname == "complete" or evname == "end" or evname == "error" then
      self:super_on(evname,fn)
      self:log("added default callback:", evname)
    else -- rpcs
      self.rpcfuncs[evname] = fn
      self:log("added rpc func:", evname )
      print("added rpc func:", evname )      
    end
  end
  -- cb can be nil
  function conn:call(meth,arg,cb)
    if self.hasHandle and not self._handle then
      self:log("no handle")
      return
    end
      
    if type(arg) ~= "table" then 
      return self:emit(meth,arg) -- fallback to super class' emit function
    end
    if type(meth) ~= "string" then error("method name required") end
    
    local t = { 1, meth, arg }
    
    if cb then
      t[4] = self.roundTripFuncID
      self.waitfuncs[ self.roundTripFuncID ] = cb
      self.roundTripFuncID = self.roundTripFuncID + 1
    end
    if self.last_call_id and ( meth == self.last_call_method .. "Result" or meth == self.last_call_method .. "_result" )  then
      t[4] = self.last_call_id 
      self.last_call_id = nil
    end

    local packed = self.rpc.mp.pack(t)


    if self.doSelfTest then
      local nread,resulttbl = self.rpc.mp.unpack(packed)
      local isok = deepcompare(resulttbl,t)
      assert(isok, "deepcompare")
    end
    
    local payloadlen = #packed
    local lenpacked = self.rpc.mp.pack(payloadlen)
    if self.doSelfTest then
      local nread,resultval = self.rpc.mp.unpack(lenpacked)
      assert(resultval == payloadlen, "selftestpackedlen")
    end
    
    local tosend = lenpacked .. packed

    self.packetID = self.packetID + 1
    self:log("meth:", meth, "sending actual data bytes:", #tosend, "payloadlen:", payloadlen, "packetID:", self.packetID )

    if self._pendingWriteRequests == 0 then
      self.tmpwbufs = {}
    end
    
    if self._pendingWriteRequests then
      table.insert( self.tmpwbufs, tosend )
    end
    self._pendingWriteRequests = self._pendingWriteRequests + 1
    
    self:write( tosend, function(e)
        if e and e.code == "EFAULT" then
          error( "fatal:EFAULT")
        end
        self._pendingWriteRequests = self._pendingWriteRequests - 1
      end)
  end

  conn:super_on("data", function (chunk)
      conn.lastAliveAt = os.time()
      conn.recvbuf = conn.recvbuf .. chunk
      conn:log("data. chunklen:", string.len(chunk), " recvbuf:", string.len(conn.recvbuf), "alive:", conn.lastAliveAt )
      if conn.autoPollMessage then
        conn:pollMessage()
      end                            
    end)
  function conn:pollMessage(continueFunc )
    local offset=1

    while true do
      if continueFunc and continueFunc() == false then
        break
      end
      if #conn.recvbuf == 0 then
        break
      end
      if #conn.recvbuf == offset-1 then
        self:log( "fully consumed" )
        break
      end

      local pcallret, nread,res
      local envelopebytes = string.sub(conn.recvbuf,offset,offset+8)  -- 8 bytes are enough for payloadlen

      pcallret, nread,res = pcall( function()
          return conn.rpc.mp.unpack(envelopebytes) -- 8 bytes are enough for payloadlen
        end )
      if not pcallret or not nread then
        break  -- no data, so next loop.
      end

      local payloadlen = res
      local bufleft = ( #conn.recvbuf - offset + 1 ) - nread

      self:log("mprpc env!: offset:", offset, "payloadlen:", payloadlen, "envelopelen:", nread, "#recvbuf:", #conn.recvbuf, "bufleft:",bufleft, "packetID:", self.packetID )
      if payloadlen <= 0 then
        self:log( "payloadlen:", payloadlen, "<=0" )
        return true
      end      
      if bufleft < payloadlen then
        self:log("bufleft<payloadlen.",bufleft,"<",payloadlen)
        break
      end


      self.packetID = self.packetID + 1

      offset = offset + nread

      local toread = string.sub(conn.recvbuf,offset,offset+payloadlen-1)  -- should never throws exception
      if #toread == 0 then
        self:log("format error?")
        return false
      end      
      if string.byte( toread,1,1) ~= 0x93 then
        self:log( "not a msgpack map:" .. string.byte(toread,1,1) )
        return false
      end
      
      nread,res = conn.rpc.mp.unpack(toread)
      if nread ~= payloadlen then
        self:log( "nread ~= payloadlen.. nread:" .. nread .. " payloadlen:" .. payloadlen )
        return false
      end
      
      if type(res) ~= "table" or res[1] ~= 1 or type(res[2]) ~= "string" or type(res[3]) ~= "table" then
        print("rpc format error. offset:", offset, "res:", res, "data:", strdump(toread) )
        return false
      else
        local meth = res[2]
        local arg = res[3]
        local call_id = res[4]
        
        local f = self.rpcfuncs[meth]
        if not f and not self.waitfuncs[call_id] then
          self:log("receiver func not found:",meth )
        else
          if call_id then
            local wf = self.waitfuncs[call_id]
            if wf then
              self:log( "waitfunc found. call_id:", call_id )
              wf(arg)
              self.waitfuncs[call_id]=nil
            else
              self:log( "waitfunc not found. call_id:", call_id )
              self.last_call_id = call_id
              self.last_call_method = meth
              self:log("last_call_id set:", self.last_call_id)
              f(arg)
            end
          else
            f( arg )
          end                                     
        end
      end
      offset = offset + nread
    end
    if offset > 1 then
      self.recvbuf = string.sub( self.recvbuf, offset)
    else
    end
    return true
  end
end

function mprpc_createServer(self,cb)
  assert(self.net and self.mp )
  local sv = self.net.createServer( function(client)
      client.lastAliveAt = os.time()
      mprpc_init_conn(client)
      client.rpc = self
      cb(client)
    end)
  
  sv:on("error", function (err)  p("ERROR", err) end)

  return sv
end

function mprpc_connect(self,ip,port,cb)
  assert(self.net and self.mp and cb)
  local conn
  conn = self.net.createConnection( port, ip, cb )
  mprpc_init_conn(conn)
  conn.rpc = self
  return conn
end

function mprpc_create_with_net_and_mp(net,mp)
  assert(mp and mp.pack and mp.unpack)
  local mod = {}
  mod.net = net
  mod.mp = mp
  mod.createServer = mprpc_createServer
  mod.connect = mprpc_connect
  return mod
end

_G.MPRPC = {
  create = mprpc_create_with_net_and_mp
}


-- etc funcs
function _G.Counter(max)
  local t = { max = max, n = max }
  function t:get()
    if self.n > 0 then
      self.n = self.n - 1
      return true
    else
      return false
    end
  end
  function t:put()
    if self.n < self.max then
      self.n = self.n + 1
      return true
    else
      return false
    end    
  end
  return t
end



if MOAISim then
  merge( _G, moai )
else
  merge( _G, luvit )
end


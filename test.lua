-- Copyright github.com/kengonakajima 2012
-- License: Apache 2.0

require("./lumino")

-- basics
assert( isnan(0/0) )
assert( isnan(1/0) == false )
assert( isnan(-1/0) == false )
assert( isnan(1) == false )
assert( b2i(false)==0 )
assert( b2i(true)==1 )
assert( nilzero(nil)==0 )
assert( nilzero(1)==1 )
assert( abs(-10)==10)
assert( neareq(1.000000001,1.000000002) == true )
assert( neareq(1.0001,1.0002) == false )
assert( len(1,1,2,2) == len(2,2,1,1) )
x,y= normalize(2,2,5)
assert( neareq(x,3.535533905) and neareq(y,3.535533905) )
x,y= normalize(0,0,1)
assert(x==0 and y==0)
assert( int(0.5)==0)
assert( int(1.5)==1)
assert( int(true)==1)
assert( int(false)==0)

assert( to_i("0.5")==0)
assert( to_i(true)==1)
assert( to_i(123.5) == 123 )
assert( to_f("0.5")==0.5)
assert( to_s(123)=="123")

assert( round(5.6) == 6 )
assert( round(5.1) == 5 )

a,b=int2(2.5,3.5)
assert(a==2 and b==3)
a,b,c=int3(2.5,3.5,4.5)
assert(a==2 and b==3 and c==4)
for i=1,100 do
  r = range(0,100)
  assert( r>=0 and r < 100 )
  r = irange(0,100)
  assert( r>=0 and r < 100 )
  r = birandom()
  assert( r == false or r == true )
  r = plusminus(10)
  assert( r == 10 or r == -10 )  
end
assert( avg(1,2)==1.5)
assert( avgs(1,2,3,4,5) == 3 )
assert( sign(2) == 1 )
assert( sign(-8) == -1 )
assert( sign(0) == 0 )
assert( int(ratio(1,10,10,100,30))==3)
assert( min(-1,5) == -1 )
assert( min(5,-1) == -1 )
assert( min(nil,5) == 5 )
assert( min(5,nil) == 5 )
assert( max(-1,5) == 5 )
assert( max(5,-1) == 5 )
assert( max(-1,nil) == -1 )
assert( max(nil,-1) == -1 )
assert( ternary(false,1,2)==2)
assert( ternary(true,1,2)==1)
assert( cond(false,1,2)==2)
assert( cond(true,1,2)==1)


-- types
assert( typeof("string") == "string" )
assert( typeof(1) == "number" )
assert( typeof({}) == "table" )

assert( muststring( "aho" )=="aho")
assert( mustnumber( 1.5)==1.5)
musttable( {a=1} )
local ok,ret = pcall(function() muststring(1) end)
assert(not ok)
local ok,ret = pcall(function() mustnumber({a=1}) end)
assert(not ok)
local ok,ret = pcall(function() musttable("q") end)
assert(not ok)

-- table
t1 = {a=1,b=2,c=3}
assert(keynum(t1)==3)
ks = keys(t1)
assert( sort(ks) )
assert( ks[1]=="a")
assert( ks[2]=="b")
assert( ks[3]=="c")
t2 = {d=4,e=5,f=6}
out = merge(t1,t2)
assert(out.d==4 and out.a==1 and out.e==5 and out.f==6 )
t3 = {g=7,h=8,i=9}
out = sort(values(t3))
assert(out[1]==7)
assert(out[2]==8)
assert(out[3]==9)

t0 = {7,3,5}
s = sort(t0)
assert(s[1]==3)
assert(s[2]==5)
assert(s[3]==7)
t1 = {10,15,6,8}
s = sort(t1, function(a,b) return a<b end )
assert( s[1] == 6 and s[2] == 8 and s[3] ==10 and s[4] == 15 )
shuffle(t1)
for i=1,100 do
  local out = choose(t1)
  assert(out==10 or out==15 or out==6 or out==8)
end
assert( choose(nil)==nil)

assert( find(t1,10) == 10 )
assert( find(t1,595) == nil )
assert( find(t1,function(v) return(v==10) end) == 10 )
assert( find(t1,function(v) return(v==595) end) == nil )

tot=0
scan(t1,function(v)
    tot = tot + v
  end)
assert(tot==(6+8+10+15))
out = table.select(t1, function(v) if v~= 15 then return v end end)
table.sort(out)
assert( out[1] == 6 and out[2] == 8 and out[3] == 10 )
assert( count(t1) == 4 )
assert( count(t1,function(v) return (v==6) end) == 1 )
t = { a=1,b=2,c=3}
assert( sumValues(t) == (1+2+3))
tc = table.copy(t)
assert( sumValues(tc) == (1+2+3))
t = {1,2,3}
tc = table.dupArray(t)
assert(tc[1]==1 and tc[2]==2 and tc[3]==3)

function mapf(v,arg) return v[1] * arg end
t = {a={1,fn=mapf}, b={2,fn=mapf}, c={3,fn=mapf}}
out = map(t,"fn",2)
print(out.a)
assert(out.a==2 and out.b==4 and out.c==6 )

t = { a=1,b=2,c= function()end, d=true, e=false}
tc = valcopy(t)
assert( tc.a==1 and tc.b==2 and tc.c==nil and tc.d ==true and tc.e==false )
t1 = { a=1,b=2,c={d={e={1,2,3},f=3},g=4},h=5}
t2 = { a=1,b=2,c={d={e={1,2,3},f=3},g=4},h=5}
assert( deepcompare(t1,t2))
s = "AB"
assert( byte(s,1,1) == 0x41 and byte(s,2,2) == 0x42 )
s = "hello lua world !"
ary = split(s," ")
assert( ary[1] == "hello" and ary[2] == "lua" and ary[3] == "world" and ary[4] == "!" )
ary = s:split(" ")
assert( ary[1] == "hello" and ary[2] == "lua" and ary[3] == "world" and ary[4] == "!" )
s="aho"
dumped = s:dumpbytes()
assert(dumped=="97 104 111")
dumped = s:dumphex()
assert(dumped=="61 68 6f")
assert(trim("aho\naho\n\n")=="aho\naho")

assert( nearer( 1,2,3) == 2 )
assert( nearer( 2,2,3) == 2 )
assert( nearer( 1,3,2) == 2 )

assert( join({1,2,3}," ") == "1 2 3")

t = { 10,20,30,40,50}
st = slice(t,2,-2)
assert(st[1]==20)
assert(st[2]==30)
assert(st[3]==40)

st = slice(t,3)
assert(st[1]==30)
assert(st[2]==40)
assert(st[3]==50)

st = slice(t,8)
assert(#st==0)

tt = { 10,20,30}
remove(tt,1)
assert(#tt==2)
assert(tt[1]==20)
assert(tt[2]==30)
shift(tt)
assert(#tt==1)
assert(tt[1]==30)

t={ a=1, b=2, c=function() end, d={ e=5,f=function() end,g=7 } }
tt=removeTypes(t,"function")
assert( tt.a==1 )
assert( tt.b==2 )
assert( tt.c==nil )
assert( tt.d.e == 5 )
assert( tt.d.f == nil )
assert( tt.d.g == 7 )

t={10,20,30}
tt=reverse(t)
assert( tt[1]==30)
assert( tt[2]==20)
assert( tt[3]==10)

t={10,20,30}
tt=slide(t)
assert(tt[1]==30)
assert(tt[2]==10)
assert(tt[3]==20)
tt=slide({})
assert(tt[1]==nil)
tt=slide({2})
assert(tt[1]==2)

t={10,20}
tt=unshift(t,40)
assert(#tt==3)
assert(tt[1]==40)
assert(tt[2]==10)
assert(tt[3]==20)
t={}
tt=unshift(t,10)
assert(#tt==1)
assert(tt[1]==10)


-- string
origs="ABCABC"
t=origs:divide(3)
assert(#t==2)
assert(t[1]=="ABC")
assert(t[2]=="ABC")
assert(join(t)==origs)

origs="abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz"
t=origs:divide(26)
assert(#t==4)
assert(t[1]=="abcdefghijklmnopqrstuvwxyz")
assert(t[2]==" abcdefghijklmnopqrstuvwxy")
assert(t[3]=="z abcdefghijklmnopqrstuvwx")
assert(t[4]=="yz")
assert(join(t)==origs)

t=utf8div( "風がうたひ　雲ガ應ジ hello\t " )
tt= {"風","が","う","た","ひ","　","雲","ガ","應","ジ"," ","h","e","l","l","o","\t"," " }
for i,v in ipairs(t) do
  assert(v==tt[i])
end

assert( isalpha( "a" ) == true )
assert( isalpha( "1" ) == false )
assert( isalpha( "abc" ) == true )
assert( isalpha( "ab2c" ) == false )
assert( isalpha( "ほげ" ) == false )
assert( isalpha( "ほa" ) == false )

assert( hourMin( 100 ) == "01:40" )
assert( abbreviate( "ringoooooooooooo",3 ) == "rin..")
assert( abbreviate( "ringo",7 ) == "ringo")

-- logging
dump1( "dump1caption", {a=1,b=2,c=3})
xpcall( function()
    intently_not_defined()
  end,
  function(e)
    print("printing trace:")
    printTrace(e)
  end
)
printTrace()

printf("%02x", 1 )
assert(sprintf("%02x", 1 ) == "01" )

for i=1,20 do prt(".") end
prt("\n")
datePrint("datePrint")

t = {a=1,b=2,c=3}
insert(t,1)
insert(t,2)
dump(t)
print( num2digitString(50))
print( num2digitString(150))

-- files
path = "./_test.log"
r=writeFile(path,"")
assert(r)

for i=1,100 do
  appendLog( path, "hoge" .. i )
end

tt = TextTable(5,5,".")
assert( tt:getChar(1,1) == "." )
tt:setChar(2,2,"x")
assert( tt:getChar(2,2) == "x" )
s = tt:toString()
print(s)

-- timer
st=now()
cnt=0
while true do
  if now() > st+1 then
    break
  end
  cnt = cnt + 1
end
print("now() called in 1 sec:",cnt)


measure( function()
    for i=1,1000000 do
    end
  end)

st=now()
latecall=0
later(0.1, function()
    print("deferred func called")
    latecall = latecall + 1
  end)
if not uv then 
  while true do
    local nt = now()
    if nt > st + 1.5 then -- need more than 1 sec because default Lua has no highreso time!
      break
    end
    pollLater()
  end
end


s = readFile(path)
ary = s:split("\n")
assert( #ary == 100+1) -- last line is empty
r=writeFile(path, "hello\n")
assert(r)
assert(existFile(path))
s=readFile(path)
assert(s=="hello\n")
-- file access error test
s=readFile("/t/file_no_exist")
assert(s==nil)
s=writeFile("/t/file_no_exist","hoge")
assert(s==nil)

t={a=1,b=2,c=3}
saveTableToCSV(path,t)
tl=loadTableFromCSV(path)
for k,v in pairs(t) do
  assert( tonumber( tl[k] ) == v )
end

-- r/w
s="hello world!"
path = "./file_test.dat"
writeFile(path,s)
ss=readFile(path)
assert(ss==s)
path2 = "./file_test2.dat"
s1 = "hell"
s2 = "o"
s3 = " world!"
writeFile(path2,"")
overwriteFileOffset(path2,s1,0)
overwriteFileOffset(path2,s2,4)
overwriteFileOffset(path2,s3,5)
ss=readFile(path2)
assert(ss==s)



-- 2D/3D
for i=1,100 do
  local x,y = randomize2D(5,5,2)
  assert( len(x,y,5,5) <= 2*1.415 )
end
assert( randomize2D == randomize )
x,y = expandVec( 1,1,2,2,1 )
assert( neareq(x,1.707106781) )
assert( neareq(y,1.707106781) )

assert( len3d(1,1,1,2,2,2) == sqrt(3) )

v1 = vec3(1,1,1)
v2 = vec3(2,2,2)
dv = vec3sub(v2,v1)
assert( vec3eq( vec3(-1,-1,-1), dv ) )

cv = vec3cross(v2,v1)
assert( cv.x ==0 and cv.y == 0 and cv.z == 0 )
assert( vec3dot(v1,v2) == 6 )
nv = vec3normalize( vec3(5,5,5) )

assert( neareq( vec3len(vec3(5,5,5), vec3(6,6,6)), sqrt(3) ) )
print( vec3toString( vec3(1.2,2.3,3.4) ) )
print( vec3toIntString( vec3(1.2,2.3,3.4) ) )

-- TODO: triangleIntersect( orig, dir, v0,v1,v2 )
r = Rect(0,0,2,2)
sr1 = squareRect(1,1,1)
sr2 = squareRect(2,2,1)
ary={{hitRect=sr1},{hitRect=sr2}}
checkHitRects(ary, 0.5,0.5, "hoge", function(v,x,y,arg)
    assert(v.hitRect==sr1)
    assert(x==0.5 and y == 0.5)
    assert(arg=="hoge")
  end)
scanCircle(0,0,2,1,function(x,y)
    assert(x==-1 or x==0 or x==1)
    assert(y==-1 or y==0 or y==1)    
  end)
cnt=0
scanRect(0,0,2,2,function(x,y)
    cnt = cnt + 1
  end)
assert(cnt==(3*3))
r = Rect(1,1,2,2)
t = r:toData()
assert( t.include==nil)
assert( t.toData==nil)
r = Rect(1,1,2,2)
x,y=r:center()
assert(neareq(x,1.5))
assert(neareq(y,1.5))
r1 = Rect(1,1,3,3)
r2 = Rect(2,2,4,4)
r3 = Rect(4,4,5,5)
assert(r1:intersectRect(r2))
assert(not r1:intersectRect(r3))
tr = r1:translate(2,2)
assert(tr.minx==3)
assert(tr.maxx==5)
assert(tr.miny==3)
assert(tr.maxy==5)


-- 4dirs
assert( dir2char(DIR.UP) == "^")
assert( dir2char(489) == "+")
for i=1,100 do
  local d = randomDir()
  assert( d==DIR.UP or d==DIR.DOWN or d==DIR.LEFT or d==DIR.RIGHT)
end
assert( reverseDir(DIR.UP)==DIR.DOWN)
assert( reverseDir(DIR.RIGHT)==DIR.LEFT)

area = calcArea( {0,0,  0,2,  2,2,  2,0 } )
assert(area ==4)




-- loop
a=1
times(100,function()a=a+1 end)
assert(a==101)

-- strict
strict()
e=false
xpcall( function() hoge = not_declared + 1 end, function() e=true end)
assert(e)
nostrict()

-- dumplocal

function hoge(a,b,c)
  s = dumplocal()
  return s
end

print( hoge(1,2,3))
assert( hoge(1,2,3) == "a:1\tb:2\tc:3\t" )


-- TODO: sendmail( from, to, subj, msg )

assert( isUsableInName( "ringoRINGO_01-83" ) )
assert( not isUsableInName( "ringo:RINGO/01-83" ) )

assert( generateNewId() == 1)
assert( generateNewId() == 2)

-- UNIX funcs (luvit only test)
if uv then
  -- colors (need bitopts)
  r,g,b = i32toRGB( 16777214 )
  assert(r==255)
  assert(g==255)
  assert(b==254)

  -- basic
  pid1 = getpid()
  pid2 = getpid()
  assert( pid1 == pid2 )
  savePidFile(path)
  ignoreSIGPIPE()
  local t = { a=1,b={ 1,2,3,"hoge" },c="ddd"}
  local path = "./_test.json"
  assert(writeJSON( path, t ))
  local r = readJSON(path)
  assert(r)
  assert(r.a==1)
  assert(r.b[1]==1 and r.b[4]=="hoge" and r.c=="ddd" )
  r = readJSON( "file_not_exist" )
  assert( r==nil)
  
  assert(writeJSON( "./_test_j1.json", {a=1,b=2}))
  assert(writeJSON( "./_test_j2.json", {c=3,d=4}))
  r = mergeJSONs( "./_test_j1.json", "./_test_j2.json" )
  assert(r)
  assert(r.a==1 and r.b==2 and r.c==3 and r.d==4)
  assert(writeJSON( "./_test_j3.json",{a=3,b=8}) )
  r = mergeJSONs( "./_test_j1.json", "./_test_j3.json" )
  assert(r)
  assert(r.a==3 and r.b==8)
    
  r = mergeJSONs( "not_found_1", "not_found_2", "not_found_3" )
  assert(r==nil)

  -- read JSON that has number keys and values as numbers
  t = { a = 1, b={2,3}, [7]={ ["9"]="10", [11]="aa"},[15]={ { 20,"21","22" }, {"aa",33,40}, { [50]=60,["70"]=80} } } 
  assert(writeJSON("./_test_j4.json",t))
  r=readJSON("./_test_j4.json")
  assert(r)
  assert(r.a==1)
  assert(r.b[1]==2)
  assert(r.b[2]==3)
  assert(r[7])
  assert(r[7][9]==10) 
  assert(r[7][11]=="aa")
  assert(r[15][1][1]==20)
  assert(r[15][1][2]==21)
  assert(r[15][1][3]==22)
  assert(r[15][2][1]=="aa")
  assert(r[15][2][2]==33)
  assert(r[15][2][3]==40)
  assert(r[15][3][50]==60)
  assert(r[15][3][70]==80)        -- converted to number key

  -- signal
  
  signal(SIGINT,function() print "got signal" end)
  kill(getpid(), SIGINT)

  alrmcnt=0
  addTrap(SIGALRM, function()
      print "alrm1"
      alrmcnt = alrmcnt + 1
    end)
  addTrap(SIGALRM, function()
      print "alrm2"
      alrmcnt = alrmcnt + 1
    end)
  kill(getpid(), SIGALRM)
  assert( alrmcnt == 2 )
  
  assert(writeFile("_test_unlink","hoge"))
  assert(unlink("_test_unlink"))

  local guid1 = getGUID()
  local guid2 = getGUID()
  assert( guid1 ~= guid2)
  local tmp1 = makeTmpPath( "/tmp/lumino")
  local tmp2 = makeTmpPath( "/tmp/lumino")
  assert( tmp1 ~= tmp2 )
  assert( writeFile(tmp1,"hoge"))
  assert( writeFile(tmp2,"hoge"))

  local e = false
  cmd( "command_not_found",function(e,res)
      assert(e)
    end)
  
  local res = cmd( "ls -t ./")
  assert(res)
  print(res)
  local ary = split(res,"\n")
  assert(find(ary,"test.lua"))
  assert(find(ary,"lumino.lua"))

  mkdir("public_html") -- error ok
  assert(existFile("public_html"))
  assert(writeFile("public_html/index.html","hoge"))

  o=cmd("rm -rf a/b/c/d")
  assert(ensureDir("a/b/c/d"))
    
  _G.htok = false
  http.createServer(function(req,res)
      if not httpServeStaticFiles(req,res,"public_html",{"html","png"}) then
        local funcs={}
        funcs.default= function(req,res) res:sendFile("index.html") end
        funcs.f1 = function(req,res) res:sendJSON({a=1,b=req.paths}) end
        httpRespond(req,res,funcs)
      end
    end):listen(57589,"127.0.0.1",function(e)
      assert(not e)
      htok = true
      every(0.1, function()
          checkEverythingOK() 
        end)

--       later( 300, function()
--           local s=cmd("curl http://localhost:57589/index.html")
--           assert(s=="hoge")
--           s=cmd("curl http://localhost:57589/f1/a/b")
--           assert(s)
--           local o = JSON.parse(s)
--           assert(o.a == 1)
--           assert(o.b)
--           assert(o.b[1] == "a")
--           assert(o.b[2] == "b")
--           print("http done")
--         end)
    end)

  monitorFiles( { "./*.lua" }, function() end )
end

if uv then
  assert( JSON.parse( "{" ) == nil )
  assert( JSON.parse( "{}" ) ~= nil )  
  local s="a ほげ +az;&%'$#\"\'"
  assert( urldecode( urlencode(s))==s)
  local qs = "payload={\"a\":1,\"b\":2}&opt=AAA"
  local parsed = parseQueryString( qs )
  assert( parsed.payload=="{\"a\":1,\"b\":2}")
  assert( parsed.opt=="AAA")
  local t = JSON.parse(parsed.payload)
  assert( t.a==1 )
  assert( t.b==2 )
  pp(t)
end


if MOAISim then
  -- TODO: makeHitRect(prop, sz )
  -- TODO: propDistance(p0,p1)
  -- TODO: swapPropPrio(ap,bp)
  -- TODO: loadTileDeck( path, w, h, fil, wrp )
  -- TODO: loadTileDeck2( path, w, h, sz, fullxsz, fullysz, fil, wrp )
  -- TODO: loadTex( path )
  -- TODO: loadGfxQuad( path )
  -- TODO: loadImage(path)
  -- TODO: loadWav( fn ,v)
end

c = Counter(3)
assert( c:put() == false )
assert( c:get() )
assert( c:get() )
assert( c:get() )
assert( c:get() == false )
assert( c:put() )
assert( c:get() )
assert( c:get() == false )

-- moai test
if MOAISim then
  print("moai net")
  local net = _G.LuvitNetEmu
  net.createConnection( 64444, "127.0.0.1", function(cli)
    cli:on("error", function(e)  end)
    cli:on("data", function(e) end)
    cli:write("hello world")
    
  end)
end


xpm = XPMImage(10,10)
c1 = xpm:addColor(255,0,0)
c2 = xpm:addColor(0,255,0)
xpm:set(1,1,c1)
xpm:set(2,2,c1)
xpm:set(7,7,c2)
xpm:set(8,8,c2)
out = xpm:out( "hoge") 
print( out )



_G.normalOK = true

function checkEverythingOK()
  local result = 1
  if uv then
    if htok and normalOK and latecall > 0 then
      result = 0
    end
  else
    if normalOK and latecall > 0 then
      result = 0
    end
  end
  if result == 1 then
    print("test failed. htok:",htok,"normalOK:",normalOK, "latecall:", latecall )
  else
    print("test ok")
  end
  exit(result)
end

if every then 
  every(0.1,function()
      checkEverythingOK()
    end)
else
  checkEverythingOK()
end


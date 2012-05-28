-- Copyright github.com/kengonakajima 2012
-- License: Apache 2.0

require("./lumino")


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
assert( int(0.5)==0)
assert( int(1.5)==1)
assert( int(true)==1)
assert( int(false)==0)
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
t1 = {a=1,b=2,c=3}
t2 = {d=4,e=5,f=6}
out = merge(t1,t2)
assert(out.d==4 and out.a==1 and out.e==5 and out.f==6 )
t1 = {10,15,6,8}
s = sort(t1, function(a,b) return a<b end )
assert( s[1] == 6 and s[2] == 8 and s[3] ==10 and s[4] == 15 )
shuffle(t1)
for i=1,100 do
  local out = choose(t1)
  assert(out==10 or out==15 or out==6 or out==8)
end

assert( find(t1,10) == 10 )
assert( find(t1,595) == nil )
assert( find(t1,function(v) return(v==10) end) == 10 )
assert( find(t1,function(v) return(v==595) end) == nil )

tot=0
scan(t1,function(v)
    tot = tot + v
  end)
assert(tot==(6+8+10+15))
out = filter(t1, function(v) if v~= 15 then return v end end)
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


assert( nearer( 1,2,3) == 2 )
assert( nearer( 2,2,3) == 2 )
assert( nearer( 1,3,2) == 2 )

dump1( "dump1caption", {a=1,b=2,c=3})
xpcall( function()
    not_defined()
  end,
  function(e)
    print("printing trace:")
    printTrace(e)
  end
)
printf("%02x", 1 )
assert(sprintf("%02x", 1 ) == "01" )

for i=1,20 do prt(".") end
prt("\n")
t = {a=1,b=2,c=3}
table.insert(t,1)
table.insert(t,2)
dump(t)
print( num2digitString(50))
print( num2digitString(150))

path = "./_test.log"
writeFile(path,"")

for i=1,100 do
  appendLog( path, "hoge" .. i )
end

tt = TextTable(5,5,".")
assert( tt:getChar(1,1) == "." )
tt:setChar(2,2,"x")
assert( tt:getChar(2,2) == "x" )
s = tt:toString()
print(s)

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
later(0.05, function()
    print("deferred func called")
  end)
while true do
  local nt = now()
  if nt > st + 0.2 then
    break
  end
  pollLater()
end
s = readFile(path)
ary = s:split("\n")
assert( #ary == 100+1) -- last line is empty
writeFile(path, "hello\n")
assert(existFile(path))
s=readFile(path)
assert(s=="hello\n")

t={a=1,b=2,c=3}
saveTableToCSV(path,t)
tl=loadTableFromCSV(path)
for k,v in pairs(t) do
  assert( tonumber( tl[k] ) == v )
end


-- 2D/3D
for i=1,100 do
  local x,y = randomize2D(5,5,2)
  assert( len(x,y,5,5) <= 2*1.415 )
end
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


-- TODO: sendmail( from, to, subj, msg )

assert( isUsableInName( "ringoRINGO_01-83" ) )
assert( not isUsableInName( "ringo:RINGO/01-83" ) )

assert( generateNewId() == 1)
assert( generateNewId() == 2)

-- UNIX funcs
if ffi and net then
  pid1 = getpid()
  pid2 = getpid()
  assert( pid1 == pid2 )
  savePidFile(path)
  ignoreSIGPIPE()
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



print( "test done\n")

WIDTH = 480
HEIGHT = 480

class Player
  @w = 48
  @h = 48
  @v_norm = 4
  constructor: ->
    @x = WIDTH/2 - Player.w/2
    @y = HEIGHT - Player.h
    @vx = Player.v_norm
  move: ->
    @x += @vx
    if @x+Player.w>=WIDTH
      @vx = -Player.v_norm
    else if @x<=0
      @vx = Player.v_norm
  draw: (ctx)->
    ctx.drawImage unko, @x, @y

class Unko
  @w = 48
  @h = 48
  @v_norm = 8
  constructor: ->
    @x = Math.random()*(WIDTH-Unko.w)
    @y = -Unko.h
    @vy = Unko.v_norm
  move: ->
    @y += @vy
    if @y>=HEIGHT
      return false
    else
      return true
  draw: (ctx)->
    ctx.drawImage unko, @x, @y

collide = (a,b)->
  dx = a.x-b.x
  dx *= dx
  dy = a.y-b.y
  dy *= dy
  return (dx+dy)<=30*30

# unko sprite
unko = null

# variables
player = null
unkolist = []

_ctx = null
main = ->
  # canvas context
  cvs = document.getElementById "cvs"
  if !cvs or !cvs.getContext
    return
  _ctx = cvs.getContext "2d"
  touchevent = ""
  canTouch = ("ontouchstart" in window)
  if "ontouchstart" in window
    touchevent = "touchstart"
  else
    touchevent = "mousedown"
  cvs.addEventListener touchevent, onClick, false
  # create instances
  player = new Player()
  # load unko
  unko = new Image()
  unko.onload = ->
    # start loop
    do mainloop
  unko.src = "./unko.png?#{new Date().getTime()}"

timecnt = 0
cnt = 0
prob = 0.0
diff = 0.996
mainloop = ->
  # init
  _ctx.fillStyle = "#ccf"
  _ctx.fillRect 0,0,WIDTH,HEIGHT
  ++ timecnt
  # generate unko
  prob *= diff
  if prob <= Math.random()
    prob = 1.0
    unkolist.push new Unko()
  ++cnt
  if cnt>=1200
    diff *= 0.995
    console.log diff
    cnt = 0
  # move
  goflag = false
  player.move()
  deletelist = []
  for i in [0...unkolist.length]
    flag = unkolist[i].move()
    if !flag
      deletelist.push i
    else
      goflag |= collide(player,unkolist[i])
  for i in [0...deletelist.length]
    id = deletelist[deletelist.length-1-i]
    unkolist.splice id,1
  # draw
  player.draw(_ctx)
  for i in [0...unkolist.length]
    unkolist[i].draw(_ctx)
  if goflag
    # gameover
    cnt = 114514
    do gameoverloop
    return
  setTimeout mainloop,16

rnd = -> Math.floor(Math.random()*256)

gameoverloop = ->
  ++cnt
  if cnt>=30
    cnt = 0
    lasttime = Math.floor(timecnt/60.0*10000.0)/10000.0
    _ctx.drawImage unko, (Math.random()*(WIDTH-Unko.w)),(Math.random()*(HEIGHT-Unko.h))
    _ctx.fillStyle = "rgba(#{rnd()},#{rnd()},#{rnd()},0.3)"
    _ctx.fillRect 0,200-44,WIDTH,96
    _ctx.fillStyle = "rgb(#{rnd()},#{rnd()},#{rnd()})"
    _ctx.font = "48px serif"
    _ctx.fillText "#{lasttime}秒ぐらい",0,200
    _ctx.fillText "💩を回避したよ💩💩💩💩💩💩💩💩💩💩💩💩",0,248
  setTimeout gameoverloop,16

onClick = (e)->
  player.vx *= -1

window.onload = main

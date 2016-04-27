WIDTH = 480
HEIGHT = 480
APPEND_HEIGHT = 100
RESTART_WIDTH = 40

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
  cvs.addEventListener "touchstart", (e)->
    onClick.call this,e
    e.stopPropagation()
    e.preventDefault()
  cvs.addEventListener "mousedown", (e)->
    onClick.call this,e
  # create instances
  player = new Player()
  # load unko
  unko = new Image()
  unko.onload = ->
    # start loop
    do init
  unko.src = "./unko.png?#{new Date().getTime()}"

timecnt = 0
cnt = 0
prob = 0.0
diff = 0.996

currentID = 0

init = ->
  timecnt = 0
  cnt = 0
  prob = 0.0
  diff = 0.996
  player = new Player();
  unkolist = []
  loc_id = (new Date()).getMilliseconds()
  currentID = loc_id
  mainloop loc_id

mainloop = (runningID)->
  return if currentID isnt runningID
  # init
  _ctx.fillStyle = "#ccf"
  _ctx.fillRect 0,0,WIDTH,HEIGHT+APPEND_HEIGHT
  ++ timecnt
  # generate unko
  prob *= diff
  if prob <= Math.random()
    prob = 1.0
    unkolist.push new Unko()
  ++cnt
  if cnt>=600
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
  lasttime = (timecnt/60.0).toFixed 4
  _ctx.font = "24px serif"
  _ctx.fillStyle = "#000"
  _ctx.fillText "#{lasttime}秒",10,10+24
  _ctx.fillStyle = "#ffc"
  _ctx.fillRect 0,HEIGHT,WIDTH,APPEND_HEIGHT
  _ctx.fillStyle = "#f99"
  _ctx.fillRect 0,HEIGHT,RESTART_WIDTH,APPEND_HEIGHT
  _ctx.font = "14px serif"
  _ctx.fillStyle = "#000"
  _ctx.fillText "restart",0,HEIGHT+48+14
  if goflag
    # gameover
    cnt = 114514
    gameoverloop runningID
    return
  else
    setTimeout mainloop,16,runningID

rnd = -> Math.floor(Math.random()*256)

gameoverloop = (runningID)->
  return if currentID isnt runningID
  ++cnt
  if cnt>=30
    cnt = 0
    lasttime = (timecnt/60.0).toFixed 4
    _ctx.drawImage unko, (Math.random()*(WIDTH-Unko.w)),(Math.random()*(HEIGHT-Unko.h))
    _ctx.fillStyle = "rgba(#{rnd()},#{rnd()},#{rnd()},0.3)"
    _ctx.fillRect 0,200-44,WIDTH,96
    _ctx.fillStyle = "rgb(#{rnd()},#{rnd()},#{rnd()})"
    _ctx.font = "48px serif"
    _ctx.fillText "#{lasttime}秒ぐらい",0,200
    _ctx.fillText "💩を回避したよ💩💩💩💩💩💩💩💩💩💩💩💩",0,248
  setTimeout gameoverloop,16,runningID

onClick = (e)->
  player.vx *= -1
  if e.clientX < RESTART_WIDTH && e.clientY >= HEIGHT
    do init

window.onload = main

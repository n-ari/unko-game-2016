// Generated by CoffeeScript 1.10.0
var APPEND_HEIGHT, HEIGHT, Player, RESTART_WIDTH, Unko, WIDTH, _ctx, cnt, collide, currentID, diff, gameoverloop, init, main, mainloop, onClick, player, prob, rnd, timecnt, unko, unkolist;

WIDTH = 480;

HEIGHT = 480;

APPEND_HEIGHT = 100;

RESTART_WIDTH = 100;

Player = (function() {
  Player.w = 48;

  Player.h = 48;

  Player.v_norm = 4;

  function Player() {
    this.x = WIDTH / 2 - Player.w / 2;
    this.y = HEIGHT - Player.h;
    this.vx = Player.v_norm;
  }

  Player.prototype.move = function() {
    this.x += this.vx;
    if (this.x + Player.w >= WIDTH) {
      return this.vx = -Player.v_norm;
    } else if (this.x <= 0) {
      return this.vx = Player.v_norm;
    }
  };

  Player.prototype.draw = function(ctx) {
    return ctx.drawImage(unko, this.x, this.y);
  };

  return Player;

})();

Unko = (function() {
  Unko.w = 48;

  Unko.h = 48;

  Unko.v_norm = 8;

  function Unko() {
    this.x = Math.random() * (WIDTH - Unko.w);
    this.y = -Unko.h;
    this.vy = Unko.v_norm;
  }

  Unko.prototype.move = function() {
    this.y += this.vy;
    if (this.y >= HEIGHT) {
      return false;
    } else {
      return true;
    }
  };

  Unko.prototype.draw = function(ctx) {
    return ctx.drawImage(unko, this.x, this.y);
  };

  return Unko;

})();

collide = function(a, b) {
  var dx, dy;
  dx = a.x - b.x;
  dx *= dx;
  dy = a.y - b.y;
  dy *= dy;
  return (dx + dy) <= 30 * 30;
};

unko = null;

player = null;

unkolist = [];

_ctx = null;

main = function() {
  var cvs;
  cvs = document.getElementById("cvs");
  if (!cvs || !cvs.getContext) {
    return;
  }
  _ctx = cvs.getContext("2d");
  cvs.addEventListener("touchstart", function(e) {
    onClick.call(this, e);
    e.stopPropagation();
    return e.preventDefault();
  });
  cvs.addEventListener("mousedown", function(e) {
    return onClick.call(this, e);
  });
  player = new Player();
  unko = new Image();
  unko.onload = function() {
    return init();
  };
  return unko.src = "./unko.png?" + (new Date().getTime());
};

timecnt = 0;

cnt = 0;

prob = 0.0;

diff = 0.996;

currentID = 0;

init = function() {
  var loc_id;
  timecnt = 0;
  cnt = 0;
  prob = 0.0;
  diff = 0.996;
  player = new Player();
  unkolist = [];
  loc_id = (new Date()).getMilliseconds();
  currentID = loc_id;
  return mainloop(loc_id);
};

mainloop = function(runningID) {
  var deletelist, flag, goflag, i, id, j, k, l, lasttime, ref, ref1, ref2;
  if (currentID !== runningID) {
    return;
  }
  _ctx.fillStyle = "#ccf";
  _ctx.fillRect(0, 0, WIDTH, HEIGHT + APPEND_HEIGHT);
  ++timecnt;
  prob *= diff;
  if (prob <= Math.random()) {
    prob = 1.0;
    unkolist.push(new Unko());
  }
  ++cnt;
  if (cnt >= 600) {
    diff *= 0.995;
    console.log(diff);
    cnt = 0;
  }
  goflag = false;
  player.move();
  deletelist = [];
  for (i = j = 0, ref = unkolist.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
    flag = unkolist[i].move();
    if (!flag) {
      deletelist.push(i);
    } else {
      goflag |= collide(player, unkolist[i]);
    }
  }
  for (i = k = 0, ref1 = deletelist.length; 0 <= ref1 ? k < ref1 : k > ref1; i = 0 <= ref1 ? ++k : --k) {
    id = deletelist[deletelist.length - 1 - i];
    unkolist.splice(id, 1);
  }
  player.draw(_ctx);
  for (i = l = 0, ref2 = unkolist.length; 0 <= ref2 ? l < ref2 : l > ref2; i = 0 <= ref2 ? ++l : --l) {
    unkolist[i].draw(_ctx);
  }
  lasttime = (timecnt / 60.0).toFixed(4);
  _ctx.font = "24px serif";
  _ctx.fillStyle = "#000";
  _ctx.fillText(lasttime + "秒", 10, 10 + 24);
  _ctx.fillStyle = "#ffc";
  _ctx.fillRect(0, HEIGHT, WIDTH, APPEND_HEIGHT);
  _ctx.fillStyle = "#f99";
  _ctx.fillRect(0, HEIGHT, RESTART_WIDTH, APPEND_HEIGHT);
  _ctx.font = "20px serif";
  _ctx.fillStyle = "#000";
  _ctx.fillText("restart", 16, HEIGHT + 32 + 20);
  if (goflag) {
    cnt = 114514;
    gameoverloop(runningID);
  } else {
    return setTimeout(mainloop, 16, runningID);
  }
};

rnd = function() {
  return Math.floor(Math.random() * 256);
};

gameoverloop = function(runningID) {
  var lasttime;
  if (currentID !== runningID) {
    return;
  }
  ++cnt;
  if (cnt >= 30) {
    cnt = 0;
    lasttime = (timecnt / 60.0).toFixed(4);
    _ctx.drawImage(unko, Math.random() * (WIDTH - Unko.w), Math.random() * (HEIGHT - Unko.h));
    _ctx.fillStyle = "rgba(" + (rnd()) + "," + (rnd()) + "," + (rnd()) + ",0.3)";
    _ctx.fillRect(0, 200 - 44, WIDTH, 96);
    _ctx.fillStyle = "rgb(" + (rnd()) + "," + (rnd()) + "," + (rnd()) + ")";
    _ctx.font = "48px serif";
    _ctx.fillText(lasttime + "秒ぐらい", 0, 200);
    _ctx.fillText("💩を回避したよ💩💩💩💩💩💩💩💩💩💩💩💩", 0, 248);
  }
  return setTimeout(gameoverloop, 16, runningID);
};

onClick = function(e) {
  player.vx *= -1;
  if (e.clientX < RESTART_WIDTH && e.clientY >= HEIGHT) {
    return init();
  }
};

window.onload = main;

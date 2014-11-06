// Generated by CoffeeScript 1.8.0
var Ball, Game, Rect, game;

Rect = (function() {
  function Rect(context, color, x, y, width, height) {
    this.context = context;
    this.color = color;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }

  Rect.prototype.draw = function() {
    this.context.fillStyle = this.color;
    return this.context.fillRect(this.x, this.y, this.width, this.height);
  };

  return Rect;

})();

Ball = (function() {
  function Ball(context, color, x, y, radius, vx, vy) {
    this.context = context;
    this.color = color;
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.vx = vx;
    this.vy = vy;
  }

  Ball.prototype.draw = function() {
    this.context.beginPath();
    this.context.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
    this.context.stroke();
    this.context.fillStyle = this.color;
    return this.context.fill();
  };

  Ball.prototype.move = function(vx, vy, width, height) {
    var checkBorder, dv, dvx, dvy, getMin;
    checkBorder = function(x, vx, radius, border) {
      var dvx;
      dvx = vx + 1;
      if ((x + radius + vx > border) && (vx > 0)) {
        dvx = border - x - radius;
      }
      if ((x - radius + vx < 0) && (vx < 0)) {
        dvx = x - radius;
      }
      return dvx;
    };
    getMin = function(x, y) {
      var min;
      if (x < y) {
        min = x;
      } else {
        min = y;
      }
      return min;
    };
    dvx = checkBorder(this.x, vx, this.radius, width);
    dvy = checkBorder(this.y, vy, this.radius, height);
    dv = getMin(dvx / vx, dvy / vy);
    this.x += vx * dv;
    this.y += vy * dv;
    if (dvx < dvy) {
      this.vx = -this.vx;
    }
    if (dvy < dvx) {
      this.vy = -this.vy;
    }
    return console.log("Size " + width, height + " x&y " + this.x, this.y + " vx&vy " + this.vx, this.vy);
  };

  return Ball;

})();

Game = (function() {
  function Game() {}

  Game.prototype.init = function() {
    var canvas;
    canvas = document.getElementById("ballpool");
    canvas.width = 800;
    canvas.height = 600;
    this.context = canvas.getContext("2d");
    this.simpleBall = new Ball(this.context, "#FF0000", 500, 500, 10, 10, 10);
    return this.gameField = new Rect(this.context, "#AAAAAA", 0, 0, 800, 600);
  };

  Game.prototype.draw = function() {
    this.gameField.draw();
    this.simpleBall.draw();
    return console.log(this.simpleBall.vx, this.simpleBall.vy);
  };

  Game.prototype.update = function() {
    this.context.clearRect(0, 0, 800, 600);
    this.updatePosition();
    return this.draw();
  };

  Game.prototype.animate = function() {
    var animation;
    animation = function(obj) {
      return obj.update();
    };
    return animation(this);
  };

  Game.prototype.updatePosition = function() {
    var height, width;
    width = game.gameField.width;
    height = game.gameField.height;
    return this.simpleBall.move(this.simpleBall.vx, this.simpleBall.vy, width, height);
  };

  return Game;

})();

game = new Game();

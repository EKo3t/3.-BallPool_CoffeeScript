class Rect
  constructor: (@context, @color, @x, @y, @width, @height) ->

  draw: ->
    @context.fillStyle = @color
    @context.fillRect @x, @y, @width, @height

	
class Ball
  constructor: (@context, @color, @x, @y, @radius, @vx, @vy) ->
  
  draw: ->
    @context.beginPath()
    @context.arc(@x, @y, @radius, 0, Math.PI*2)
    @context.stroke()
    @context.fillStyle = @color
    @context.fill()

  move: (@vx, @vy, width, height) ->
    checkBorder: (x, vx, border) ->
      dvx = Infinity
      if Math.abs(border - x) < vx
        dvx = Math.abs(border - x)
      return
    getMin: (x, y) ->
      if x < y
        min = x
      else
        min = y
      return
    if (@vx == 0)&&(@vy == 0)
      return
    dvx = checkBorder(@x, @vx, width)
    dvy = checkBorder(@y, @vy, height)
    dv = getMin(dvx, dvy)
    if dv < Infinity
      @x += @vx * dv
      @y += @vy * dv
      console.log(@x, @y)
    if (dvx < dvy)
      @vx = -@vx
    if (dvy < dvx)
      @vy = -@vy

class Game
  init: ->
    canvas = document.getElementById("ballpool")
    canvas.width = 800
    canvas.height = 600
    @context = canvas.getContext("2d")

    @simpleBall = new Ball(@context, "#FF0000", 500, 500, 10, 10, 10)
    @gameField = new Rect(@context, "#AAAAAA", 0, 0, 800, 600)

  draw: ->
    @gameField.draw()
    @simpleBall.draw()

  update: ->
    @context.clearRect(0,0, 800, 600)
    @updatePosition()
    @draw()

  animate: ->    
    animation = (obj) ->
      obj.update()
      setTimeout((-> animation obj),700)
    animation(this)

  updatePosition: () ->
    width = game.gameField.width
    height = game.gameField.height
    @simpleBall.move(@simpleBall.vx, @simpleBall.vy, width, height)

game = new Game()

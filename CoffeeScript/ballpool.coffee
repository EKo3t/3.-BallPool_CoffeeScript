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

  move: (vx, vy, width, height) ->
    checkBorder = (x, vx, radius, border) ->
      dvx = vx + 1
      if (x + radius + vx > border) && (vx > 0)
        dvx = border - x - radius
      if (x - radius + vx < 0) && (vx < 0)
        dvx = x - radius
      return dvx
    getMin = (x, y) ->
      if x < y
        min = x
      else
        min = y
      return min
    dvx = checkBorder(@x, vx, @radius, width)
    dvy = checkBorder(@y, vy, @radius, height)
    dv = getMin(dvx / vx, dvy / vy)
    @x += vx * dv
    @y += vy * dv
    if (dvx < dvy)
      @vx = -@vx
    if (dvy < dvx)
      @vy = -@vy
    console.log("Size " + width, height + " x&y " + @x, @y + " vx&vy " + @vx, @vy)

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
    console.log(@simpleBall.vx, @simpleBall.vy)

  update: ->
    @context.clearRect(0,0, 800, 600)
    @updatePosition()
    @draw()

  animate: ->    
    animation = (obj) ->
      obj.update()
      ##setTimeout((-> animation obj),700)##
    animation(this)

  updatePosition: () ->
    width = game.gameField.width
    height = game.gameField.height
    @simpleBall.move(@simpleBall.vx, @simpleBall.vy, width, height)

game = new Game()

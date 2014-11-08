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

  move: (vx, vy, width, height) =>
    checkBorder = (x, vx, radius, border) ->
      dvx = Infinity
      if (x + radius + vx >= border) && (vx > 0)
        dvx = border - x - radius
      if (x - radius + vx <= 0) && (vx < 0)
        dvx = x - radius
      return dvx

    getMin = (x, y) ->
      min = y
      if x < y
        min = x
      return min

    dvx = checkBorder(@x, vx, @radius, width)
    dvy = checkBorder(@y, vy, @radius, height)
    dv = Math.abs(getMin(dvx / vx, dvy / vy))
    console.log(@x, @y, vx, vy, width, height, dv, dvx, dvy)
    if dv == Infinity
      @x = @x + vx
      @y = @y + vy
    else
      @x += vx * dv
      @y += vy * dv
    if (Math.abs(dvx / vx) <= 1)
      @vx = -@vx
    if (Math.abs(dvy / vy) <= 1)
      @vy = -@vy

class Game
  init: ->
    @canvas = document.getElementById("ballpool")
    @canvas.width = 800
    @canvas.height = 600
    @context = @canvas.getContext("2d")
    @gameField = new Rect(@context, "#AAAAAA", 0, 0, 800, 600)
    @gameField.draw()

  getClickPosition = (e) ->
    parentPosition = getPosition(e.currentTarget)
    xPosition = e.clientX - parentPosition.x
    yPosition = e.clientY - parentPosition.y
    console.log(xPosition, yPosition)
    @simpleBall = new Ball(@context, "red", xPosition, yPosition, 10, 2, 2)

  getPosition = (element) ->
    xPosition = 0
    yPosition = 0
    while element
      xPosition += (element.offsetLeft - element.scrollLeft + element.clientLeft)
      yPosition += (element.offsetTop - element.scrollTop + element.clientTop)
      element = element.offsetParent
    x: xPosition
    y: yPosition

  createBallButton: ->
    @canvas.addEventListener "click", getClickPosition, false

  draw: ->
    @simpleBall.draw()

  update: ->
    @context.clearRect(0,0, 800, 600)
    @updatePosition()
    @draw()

  animate: ->    
    animation = (obj) ->
      obj.update()
      setTimeout((-> animation obj),10)
    animation(this)

  updatePosition: () ->
    width = game.gameField.width
    height = game.gameField.height
    @simpleBall.move(@simpleBall.vx, @simpleBall.vy, width, height)

game = new Game()

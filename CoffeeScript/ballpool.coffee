Vector = (x, y) ->
  @x = x
  @y = y
  return

Vector::dot = (v) ->
  @x * v.x + @y * v.y

Vector::length = ->
  Math.sqrt @x * @x + @y * @y

Vector::normalize = ->
  s = 1 / @length()
  @x *= s
  @y *= s
  this

Vector::multiply = (s) ->
  new Vector(@x * s, @y * s)

Vector::addVector = (v) ->
  @x += v.x
  @y += v.y
  this

class Rect
  constructor: (@context, @color, @x, @y, @width, @height) ->

  draw: ->
    @context.fillStyle = @color
    @context.fillRect @x, @y, @width, @height


class Ball
  constructor: (@context, @color, x, y, @radius, vx, vy) ->
    @m = 10
    @point = new Vector(x, y)
    @movVector = new Vector(vx, vy)

  draw: ->
    @context.beginPath()
    @context.arc(@point.x, @point.y, @radius, 0, Math.PI*2)
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

    dvx = checkBorder(@point.x, @movVector.vx, @radius, width)
    dvy = checkBorder(@point.y, @movVector.vy, @radius, height)
    dv = Math.abs(getMin(dvx / vx, dvy / vy))
    if dv == Infinity
      @point.x = @point.x + vx
      @point.y = @point.y + vy
    else
      @point.x += vx * dv
      @point.y += vy * dv
    if (Math.abs(dvx / vx) <= 1)
      @movVector.vx = -@movVector.vx
    if (Math.abs(dvy / vy) <= 1)
      @movVector.vy = -@movVector.vy

 ### checkBallCollision: (ball) ->
    dt = undefined
    mT = undefined
    v1 = undefined
    v2 = undefined
    cr = undefined
    massSum = undefined
    coorDifference = new Vector(@x - ball.x, @y - ball.y)
    radiusSum = @radius + ball.radius
    distance = coorDifference.length()
    return  if distance > radiusSum
    massSum = @m + ball.m
    coorDifference.normalize()
    dt = new Vector(coorDifference.y, -coorDifference.x)
    mT = coorDifference.multiply(@radius + ball.radius - distance)
    @p.addVector mT.multiply(ball.m / massSum)
    ball.p.addVector mT.multiply(-@m / massSum)
    v1 = distance.multiply(@v.dot(coorDifference)).length()
    v2 = distance.multiply(ball.v.dot(coorDifference)).length()
    @v = dt.multiply(@v.dot(dt))
    @v.tx coorDifference.multiply((ball.m * (v2 - v1) + @m * v1 + ball.m * v2) / massSum)
    ball.v = dt.multiply(ball.v.dot(dt))
    ball.v.addVector coorDifference.multiply((@m * (v1 - v2) + ball.m * v2 + @m * v1) / massSum)###

class Game
  init: ->
    @canvas = document.getElementById("ballpool")
    @canvas.width = 800
    @canvas.height = 600
    @context = @canvas.getContext("2d")
    @gameField = new Rect(@context, "#AAAAAA", 0, 0, 800, 600)
    @gameField.draw()
    @simpleBalls = []

  getClickPosition: (e) ->
    parentPosition = getPosition(e.currentTarget)
    xPosition = e.clientX - parentPosition.x
    yPosition = e.clientY - parentPosition.y
    newBall = new Ball(game.context, "red", xPosition, yPosition, 10, 2, 2)
    game.simpleBalls.push newBall
    newBall.draw()

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
    @canvas.addEventListener "mousedown", @getClickPosition, false

  draw: ->
    for ball in @simpleBalls
      ball.draw()

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
    for ball in @simpleBalls
      ###for ball2 in @simpleBalls
        if ball != ball2
          ball.checkBallCollision(ball2)###
      ball.move(ball.movVector.vx, ball.movVector.vy, width, height)

game = new Game()

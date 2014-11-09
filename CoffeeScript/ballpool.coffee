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
    @mass = 1
    @point = new Vector(x, y)
    @movVector = new Vector(vx, vy)

  draw: ->
    @context.beginPath()
    @context.arc(@point.x, @point.y, @radius, 0, Math.PI*2)
    @context.stroke()
    @context.fillStyle = @color
    @context.fill()

  checkBallAndBorder: (vx, vy, width, height) ->
    checkBorder = (x, vx, radius, border) ->
      dvx = Infinity
      if (x + radius + vx >= border)
        dvx = Math.abs(border - x - radius)
      if (x - radius + vx <= 0)
        dvx = Math.abs(x - radius)
      return dvx
    getMin = (x, y) ->
      min = y
      if x < y
        min = x
      return min
    dvx = checkBorder(@point.x, @movVector.x, @radius, width)
    dvy = checkBorder(@point.y, @movVector.y, @radius, height)
    dv = Math.abs(getMin(dvx / vx, dvy / vy))
    if dv == Infinity
      console.log("maybe shit")
      yRatio: dvy / vy
      xRatio: dvx / vx
      minRatio: 1
    else
      yRatio: dvy / vy
      xRatio: dvx / vx
      minRatio: dv

  move: (vx, vy, ratio) ->
    @point.x += vx * ratio
    @point.y += vy * ratio

  checkInvertMove: (xRatio, yRatio) ->
    if (Math.abs(xRatio / @movVector.x) <= 1)
      @movVector.x = -@movVector.x
    if (Math.abs(yRatio / @movVector.y) <= 1)
      @movVector.y = -@movVector.y

  addGravity: (gravity) ->
    @movVector.y += gravity

  checkBallCollision: (ball, width, height) ->
    coorDifference = new Vector(@point.x - ball.point.x, @point.y - ball.point.y)
    radiusSum = @radius + ball.radius
    distance = coorDifference.length()
    return  if distance > radiusSum
    massSum = @mass + ball.mass
    coorDifference.normalize()
    dt = new Vector(coorDifference.y, -coorDifference.x)
    mT = coorDifference.multiply(@radius + ball.radius - distance)
    mtMul = mT.multiply(ball.mass / massSum)
    @checkBorderMoveAndInvert(mtMul.x, mtMul.y, width, height)
    mtMul = mT.multiply(-@mass / massSum)
    @checkBorderMoveAndInvert(mtMul.x, mtMul.y, width, height)
    dotTemp = @movVector.dot(coorDifference)
    v1 = coorDifference.multiply(dotTemp).length()
    v2 = coorDifference.multiply(ball.movVector.dot(coorDifference)).length()
    @movVector = dt.multiply(@movVector.dot(dt))
    @movVector.addVector coorDifference.multiply((ball.mass * (v2 - v1) + @mass * v1 + ball.mass * v2) / massSum)
    ball.movVector = dt.multiply(ball.movVector.dot(dt))
    ball.movVector.addVector coorDifference.multiply((@mass * (v1 - v2) + ball.mass * v2 + @mass * v1) / massSum)

  checkBorderMoveAndInvert: (vx, vy, width, height) ->
    ratio = @checkBallAndBorder(vx, vy, width, height)
    @move(vx, vy, ratio.minRatio)
    @checkInvertMove(ratio.xRatio, ratio.yRatio)

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

  getObstaclePosition: () ->


  createObstacleButton: ->
    beginPoint = undefined
    endPoint = undefined
    flag = 0
    @canvas.addEventListener "mousedown", (->
      flag = 0
      return
    ), false
    @canvas.addEventListener "mousemove", (->
      flag = 1
      return
    ), false
    @canvas.addEventListener "mouseup", (->
      if flag == 0
        console.log "click"
      else
        console.log "drag"
        if flag == 1
          return
    ), false


  deleteFieldObjects: ->

  draw: ->
    for ball1 in @simpleBalls
      ball1.draw()

  update: ->
    @context.clearRect(0,0, 800, 600)
    @updatePosition()
    @draw()

  animate: ->
    animation = (obj) ->
      obj.update()
      setTimeout((-> animation obj),1)
    animation(this)

  updatePosition: () ->
    width = game.gameField.width
    height = game.gameField.height
    for ball in @simpleBalls
      for ball2 in @simpleBalls
        if ball != ball2
          ball.checkBallCollision(ball2, width, height)
      ball.addGravity(0.098)
      ball.checkBorderMoveAndInvert(ball.movVector.x, ball.movVector.y, width, height)

game = new Game()

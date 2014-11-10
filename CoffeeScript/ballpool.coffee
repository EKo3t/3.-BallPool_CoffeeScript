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

class Obstacle
  constructor: (@context, @color, @xBegin, @yBegin, @xEnd, @yEnd) ->
    @beginPoint = new Vector(xBegin, yBegin)
    @endPoint = new Vector(xEnd, yEnd)

  draw: ->
    @context.beginPath()
    @context.moveTo(@beginPoint.x, @beginPoint.y)
    @context.lineTo(@endPoint.x, @endPoint.y)
    @context.lineWidth = 2
    @context.strokeStyle = @color
    @context.stroke()

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

  draw_arrow: ->
    @context.beginPath()
    headLen = 8
    angle = Math.atan2(@movVector.y, @movVector.x)
    @context.moveTo @point.x, @point.y
    @context.lineTo @point.x + @movVector.x, @point.y + @movVector.y
    @context.lineTo (@point.x + @movVector.x) - headLen * Math.cos(angle - Math.PI / 6),
                    (@point.y + @movVector.y) - headLen * Math.sin(angle - Math.PI / 6)
    @context.moveTo @point.x + @movVector.x, @point.y + @movVector.y
    @context.lineTo (@point.x + @movVector.x) - headLen * Math.cos(angle + Math.PI / 6),
                    (@point.y + @movVector.y) - headLen * Math.sin(angle + Math.PI / 6)
    @context.strokeStyle = "#09A948"
    @context.lineWidth = 2
    @context.stroke()
    return

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
    @gameField = new Rect(@context, "grey", 0, 0, 800, 600)
    @gameField.draw()
    @simpleBalls = []
    @obstacles = []

  getPosition = (element) ->
    xPosition = 0
    yPosition = 0
    while element
      xPosition += (element.offsetLeft - element.scrollLeft + element.clientLeft)
      yPosition += (element.offsetTop - element.scrollTop + element.clientTop)
      element = element.offsetParent
    x: xPosition
    y: yPosition

  mouseDownBall: (e) ->
    @mouseDownFlag = 1
    parentPosition = getPosition(e.currentTarget)
    xPosition = e.clientX - parentPosition.x
    yPosition = e.clientY - parentPosition.y
    @mouseVectorBegin = new Vector(xPosition, yPosition)
    newBall = new Ball(game.context, "red", xPosition, yPosition, 10, 0, 0)
    newBall.draw()

  mouseMoveBall: (e) ->
    if @mouseDownFlag == 0 || @mouseDownFlag == undefined 
      return
    @mouseDownFlag = 2
    parentPosition = getPosition(e.currentTarget)
    xPosition = e.clientX - parentPosition.x
    yPosition = e.clientY - parentPosition.y
    game.context.clearRect(0,0, 800, 600)
    game.draw()
    newBall = new Ball(game.context, "red", @mouseVectorBegin.x, @mouseVectorBegin.y, 10,
      xPosition - @mouseVectorBegin.x, yPosition - @mouseVectorBegin.y)
    newBall.draw()
    newBall.draw_arrow()
    return

  mouseUpBall: (e) ->
    if @mouseDownFlag < 2 || @mouseDownFlag == undefined
      return
    @mouseDownFlag = 0
    parentPosition = getPosition(e.currentTarget)
    xPosition = e.clientX - parentPosition.x
    yPosition = e.clientY - parentPosition.y
    game.context.clearRect(0,0, 800, 600)
    game.draw()
    newBall = new Ball(game.context, "red", @mouseVectorBegin.x, @mouseVectorBegin.y, 10,
      (xPosition - @mouseVectorBegin.x) / 20, (yPosition - @mouseVectorBegin.y) / 20)
    game.simpleBalls.push newBall
    newBall.draw()
    return

  createBallButton: ->
    @canvas.removeEventListener "mousedown", @getObstacleBeginPosition, false
    @canvas.removeEventListener "mousemove", mousemove = ->
        @mouseDownFlag = 1
        return
    , false
    @canvas.removeEventListener "mouseup", @getObstacleEndPosition, false
    @canvas.addEventListener "mousedown", @mouseDownBall, false
    @canvas.addEventListener "mousemove", @mouseMoveBall, false
    @canvas.addEventListener "mouseup", @mouseUpBall, false

  getObstacleBeginPosition: (e) ->
    @mouseDownFlag = 1
    parentPosition = getPosition(e.currentTarget)
    xPosition = e.clientX - parentPosition.x
    yPosition = e.clientY - parentPosition.y
    @mouseVectorBegin = new Vector(xPosition, yPosition)

  getObstacleEndPosition: (e) ->
    if @mouseDownFlag < 2 || @mouseDownFlag == undefined
      return
    @mouseDownFlag = 0
    parentPosition = getPosition(e.currentTarget)
    xPosition = e.clientX - parentPosition.x
    yPosition = e.clientY - parentPosition.y
    @mouseVectorEnd = new Vector(xPosition, yPosition)
    coorDifference = new Vector(@mouseVectorEnd.x - @mouseVectorBegin.x,
                                @mouseVectorEnd.y - @mouseVectorBegin.y)
    if coorDifference.length() < 15
      return
    obstacle = new Obstacle(game.context, "blue", @mouseVectorBegin.x, @mouseVectorBegin.y,
      @mouseVectorEnd.x, @mouseVectorEnd.y)
    game.obstacles.push obstacle
    obstacle.draw()
    return

  createObstacleButton: ->
    @canvas.removeEventListener "mousedown", @mouseDownBall, false
    @canvas.removeEventListener "mousemove", @mouseMoveBall, false
    @canvas.removeEventListener "mouseup", @mouseUpBall, false
    @mouseDownFlag = 0
    @canvas.addEventListener "mousedown", @getObstacleBeginPosition, false
    @canvas.addEventListener "mousemove", mousemove = ->
      if @mouseDownFlag == 1
        @mouseDownFlag = 2
      return
    , false
    @canvas.addEventListener "mouseup", @getObstacleEndPosition, false

  deleteFieldObjects: ->
    @canvas.removeEventListener "mousedown", @mouseDownBall, false
    @canvas.removeEventListener "mousemove", @mouseMoveBall, false
    @canvas.removeEventListener "mouseup", @mouseUpBall, false
    @canvas.removeEventListener "mousedown", @getObstacleBeginPosition, false
    @canvas.removeEventListener "mousemove", mousemove = ->
        if @mouseDownFlag == 1
          @mouseDownFlag = 2
        return
    , false
    @canvas.removeEventListener "mouseup", @getObstacleEndPosition, false
    clearTimeout(@timer)
    @simpleBalls = []
    @obstacles = []
    @gameField.draw()

  draw: ->
    @gameField.draw()
    for ball1 in @simpleBalls
      ball1.draw()
    for obstacle in @obstacles
      obstacle.draw()

  update: ->
    @context.clearRect(0,0, 800, 600)
    @updatePosition()
    @draw()

  animate: ->
    animation = (obj) ->
      obj.update()
      @timer = setTimeout((-> animation obj),1)
    animation(this)

  updatePosition: () ->
    width = game.gameField.width
    height = game.gameField.height
    for ball in @simpleBalls
      for ball2 in @simpleBalls
        if ball != ball2
          ball.checkBallCollision(ball2, width, height)
      ball.checkBorderMoveAndInvert(ball.movVector.x, ball.movVector.y, width, height)

game = new Game()

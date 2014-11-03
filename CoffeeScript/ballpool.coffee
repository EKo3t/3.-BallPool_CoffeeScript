init = ->
  document.getElementById("btn").onclick = ->
    alert "click!"

  canvas = document.getElementById("ballpool")
  canvas.width = 800
  canvas.height = 600
  context = canvas.getContext("2d")
  simpleBall = ball(context, "#F00", 0, 0, 10)
  gameField = rect(context, "#555", 0, 0, 800, 600)

draw = ->
  simpleBall.draw()
  gameField.draw()


rect = (context, color, x, y, width, height) ->
  @context = context
  @color = color
  @x = x
  @y = y
  @width = width
  @height = height
  @draw = ->
    @context.fillStyle = @color
    @context.fillRect @x, @y, @width, @height
  return this

ball = (context, color, x, y, radius) ->
  @context = context
  @color = color
  @x = x
  @y = y
  @radius = radius
  @draw = ->
    @context.beginPath()
    @context.fillStyle="#0000ff"
    @context.arc(x,y,radius,0,Math.PI*2,true)
    @context.closePath()
    @context.fill()
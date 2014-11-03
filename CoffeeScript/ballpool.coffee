init = ->
  document.getElementById("btn").onclick = ->
    alert "click!"

  canvas = document.getElementById("ballpool")
  canvas.width = 800
  canvas.height = 600
  context = canvas.getContext("2d")

  gameField = rect(context, "#555", 0, 0, 800, 600)
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

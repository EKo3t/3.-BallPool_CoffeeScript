init = ->
  gameField = new rect("#555", 0, 0, 800, 600)
  canvas = document.getElementById("ballpool")
  canvas.width = gameField.width
  canvas.height = gameField.height
  context = canvas.getContext("2d")
  gameField.draw()

rect = (color, x, y, width, height) ->
  @color = color
  @x = x
  @y = y
  @width = width
  @height = height
  @draw = ->
    context.fillStyle = @color
    context.fillRect @x, @y, @width, @height

document.getElementById("btn").onclick = ->
  alert "click!"

init()

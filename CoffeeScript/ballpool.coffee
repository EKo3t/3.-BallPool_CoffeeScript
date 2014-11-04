class Rect
  constructor: (@context, @color, @x, @y, @width, @height) ->

  draw: ->
    @context.fillStyle = @color
    @context.fillRect @x, @y, @width, @height

	
class Ball
  constructor: (@context, @color, @x, @y, @radius) ->
  
  draw: ->
    @context.beginPath()
    @context.arc(@x, @y, @radius, 0, Math.PI*2)
    @context.stroke()
    @context.fillStyle = @color
    @context.fill()
	
	
class Game
  init: ->
    canvas = document.getElementById("ballpool")
    canvas.width = 800
    canvas.height = 600
    @context = canvas.getContext("2d")

    @simpleBall = new Ball(@context, "#FF0000", 100, 100, 10)
    @gameField = new Rect(@context, "#AAAAAA", 0, 0, 800, 600)

  draw: ->
    @gameField.draw()
    @simpleBall.draw()

	
game = new Game()

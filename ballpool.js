function init() 
{
    gameField = new rect("#555", 0, 0, 800, 600);
    canvas = document.getElementById("ballpool");
    canvas.width = gameField.width;
    canvas.height = gameField.height;
    context = canvas.getContext("2d");
    gameField.draw();
}

function rect(color, x, y, width, height)
{
	this.color = color;
	this.x = x;
	this.y = y;
	this.width = width;
	this.height = height;
	this.draw = function()
	{
        context.fillStyle = this.color;
        context.fillRect(this.x, this.y, this.width, this.height);		
	}
}

init();

document.getElementById('btn').onclick = function() 
{
   	alert('click!');
}

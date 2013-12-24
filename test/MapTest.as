package  
{
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
/**
 * ...地图测试
 * @author Kanon
 */
public class MapTest extends Sprite 
{
	private var mapEditor:MapEditor;
    //线段的宽度 一般为球的半径
    private var lineMinWidth:int = 16;
	public function MapTest() 
	{
		this.mapEditor = new MapEditor(this.lineMinWidth * 2);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
	}
	
	private function mouseDownHandler(event:MouseEvent):void 
	{
        this.graphics.clear();
		this.graphics.lineStyle(2, 0xFF0000);
		this.graphics.moveTo(mouseX, mouseY);
		this.mapEditor.init();
		if (this.hasEventListener(Event.ENTER_FRAME)) 
			this.removeEventListener(Event.ENTER_FRAME, loop);
		this.addEventListener(Event.ENTER_FRAME, loop);
	}
	
	private function mouseUpHandler(event:MouseEvent):void 
	{
		this.removeEventListener(Event.ENTER_FRAME, loop);
		var arr:Array;
		var length:int = this.mapEditor.mapList.length;
		trace(this.mapEditor.mapToString());
		for (var i:int = 0; i < length; i += 1) 
		{
			arr = this.mapEditor.mapList[i];
			this.drawCircle(arr[0], arr[1]);
		}
	}
	
	private function loop(event:Event):void 
	{
		this.graphics.lineTo(mouseX, mouseY);
		this.mapEditor.createMapByPos(mouseX, mouseY);
	}
	
	/**
	 * 绘制圆圈
	 */
	private function drawCircle(x:Number, y:Number):void
	{
		this.graphics.lineStyle(1, 0xFF0000);
		this.graphics.beginFill(0xFFF000, .5);
		this.graphics.drawCircle(x, y, this.lineMinWidth);
		this.graphics.endFill();
	}
}
}
package  
{
import utils.MathUtil;
/**
 * ...地图编辑
 * @author Kanon
 */
public class MapEditor 
{
	//地图列表
	private var _mapList:Array
	//线最小宽度
	private var lineMinWidth:Number;
	public function MapEditor(lineMinWidth:Number) 
	{
		this.lineMinWidth = lineMinWidth;
		this.init();
	}
	
	/**
	 * 初始数据
	 */
	public function init():void
	{
		this._mapList = [];
	}
	
	/**
	 * 根据输入的坐标创建地图
	 * @param	posX	x坐标
	 * @param	posY	y坐标
	 */
	public function createMapByPos(posX:Number, posY:Number):void
	{
		if (!this._mapList) return;
		//存入第一个点
		if (this._mapList.length == 0) this._mapList.push([posX, posY, 0]);
		var prevDataAry:Array = this._mapList[this._mapList.length - 1];
		var prevX:Number = prevDataAry[0];
		var prevY:Number = prevDataAry[1];
		var dx:Number = posX - prevX;
		var dy:Number = posY - prevY;
		var dis:Number = MathUtil.distance(prevX, prevY, posX, posY);
		if (dis >= this.lineMinWidth)
		{
			var dataAry:Array;
			var x:int;
			var y:int;
			//求出线段的角度
			var angle:Number = Math.atan2(dy, dx);
			//分割当前线段宽度
			var linePointNum:int = Math.floor(dis / this.lineMinWidth);
			for (var i:int = 0; i < linePointNum; i += 1)
			{
				//以最小线段距离和角度求出，最小线段所在的坐标位置
				x = Math.round(prevX + this.lineMinWidth * Math.cos(angle));
				y = Math.round(prevY + this.lineMinWidth * Math.sin(angle));
				//将上一个位置赋值给最小线段所在的坐标位置并保存进列表
				prevX = x;
				prevY = y;
				dataAry = [x, y, 0];
				//更改上一次数据列表中的角度
				prevDataAry[2] = int(MathUtil.rds2dgs(angle));
				prevDataAry = dataAry;
				this._mapList.push(dataAry);
			}
		}
	}
	
	/**
	 * 地图列表
	 */
	public function get mapList():Array { return _mapList; }
	
	/**
	 * 地图数据以字符串形式
	 * @return		字符串形式
	 */
	public function mapToString():String
	{
		if (!this._mapList) return "";
		var ary:Array;
		var length:int = this._mapList.length;
		var str:String = "[";
		for (var i:int = 0; i < length; i += 1) 
		{
			ary = this._mapList[i];
			str += "[" + ary[0] + "," + ary[1] + "," + ary[2] +"], ";
		}
		str += "]";
		return str;
	}
}
}
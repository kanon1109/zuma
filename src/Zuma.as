package  
{
import data.BallVo;
import events.ZumaEvent;
import flash.events.EventDispatcher;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import utils.Random;
/**
 * ...祖玛算法
 * @author Kanon
 */
public class Zuma extends EventDispatcher 
{
    //最小链接数
    private var minLinkNum:uint;
    //滚入数量
    private var rollInCount:uint
    //球的半径
    private var radius:Number;
    //地图列表
    private var mapList:Array;
    //球列表的数组
    private var ballList:Array;
    //颜色种类
    private var colorType:uint;
    //存放所有球的字典
    private var _ballDict:Dictionary;
    //运动范围
    private var range:Rectangle;
    //销毁球事件
    private var removeBallEvent:ZumaEvent;
    /**
     * @param	mapList         地图坐标列表 二维数组
     * @param	rollInCount     滚入数量
     * @param	radius          半径
     * @param	colorType       颜色种类
     * @param	range           运动范围
     * @param	minLinkNum      最小链接数（多少个相同颜色消除）
     */
    public function Zuma(mapList:Array, rollInCount:uint, radius:uint, colorType:uint, range:Rectangle, minLinkNum:uint = 3)
    {
        this.mapList = mapList;
        this.rollInCount = rollInCount;
        this.radius = radius;
        this.colorType = colorType;
        this.range = range;
        this.minLinkNum = minLinkNum;
        this.initData();
        this.initEvent();
    }
    
    /**
     * 初始化数据
     */
    private function initData():void
    {
        this.ballList = [];
        this._ballDict = new Dictionary();
    }
    
    /**
	 * 初始化事件
	 */
	private function initEvent():void 
	{
		this.removeBallEvent = new ZumaEvent(ZumaEvent.REMOVE);
	}
    
    /**
     * 创建滚入球
     */
    private function createRollBall():void
    {
        if (this.ballList.length < this.rollInCount)
        {
            var posX:Number;
            var posY:Number;
            if (this.ballList.length == 0)
            {
                posX = this.mapList[0][0];
                posY = this.mapList[0][1];
                this.addBall(posX, posY, 0, 0, Random.randint(1, this.colorType));
            }
        }
    }
    
    /**
     * 判断范围
     */
    private function checkRange():void
    {
        if (!this._ballDict) return;
        var bVo:BallVo;
        for each (bVo in this._ballDict)
        {
            if (bVo.x < this.range.left - this.radius || 
                bVo.x > this.range.right + this.radius ||
                bVo.y < this.range.top - this.radius ||
                bVo.y > this.range.bottom + this.radius)
                this.removeBall(bVo);
        }
    }
    
    /**
     * 销毁球
     * @param	bVo     球数据
     */
    private function removeBall(bVo:BallVo):void
    {
        delete this._ballDict[bVo];
        this.removeBallEvent.bVo = bVo;
        this.dispatchEvent(this.removeBallEvent);
    }
    
    //***********public function***********
    /**
     * 数据更新
     */
    public function update():void
    {
        this.checkRange();
        //this.createRollBall();
    }
    
    /**
     * 添加一个球
     * @param	x       位置
     * @param	y       位置
     * @param	vx      横向速度
     * @param	vy      纵向速度
     * @param	color   颜色
     * @return  球数据
     */
    public function addBall(x:Number, y:Number, vx:Number, vy:Number, color:uint):BallVo
    {
        var bVo:BallVo = new BallVo();
        bVo.radius = this.radius;
        bVo.x = x;
        bVo.y = y;
        bVo.vx = vx;
        bVo.vy = vy;
        bVo.color = color;
        this._ballDict[bVo] = bVo;
        return bVo;
    }
    
    /**
     * 销毁
     */
    public function destroy():void
    {
        this.ballList = null;
        this._ballDict = null;
    }
    
    /**
     * 球的字典
     */
    public function get ballDict():Dictionary { return _ballDict; }
}
}
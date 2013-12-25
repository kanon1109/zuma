package  
{
import data.BallVo;
import events.ZumaEvent;
import flash.events.EventDispatcher;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import utils.MathUtil;
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
    //地图列表[[x, y, angle], [x, y, angle]]
    private var mapList:Array;
    //球列表的数组
    private var ballList:Array;
    //存放所有球的字典
    private var _ballDict:Dictionary;
    //射出的球的字典
    private var shootBallDict:Dictionary;
    //颜色种类
    private var colorType:uint;
    //运动范围
    private var range:Rectangle;
    //销毁球事件
    private var removeBallEvent:ZumaEvent;
    //添加球事件
    private var addBallEvent:ZumaEvent;
    //速度
    private var speed:Number;
    //滚入滚出速度
    private const ROLL_SPEED:Number = 2;
	//普通速度 普通速度一般为滚入速度的1/2
	private const GENERAL_SPEED:Number = 1;
    //滚入距离 最后一个球大于距离则创建球
    private var rollDis:Number;
	//进入下一个地图索引需要的最小距离
    private var minDis:Number;
    //是否滚入完成
    private var rollInited:Boolean;
	//游戏失败
	private var fail:Boolean;
    /**
     * @param	mapList         地图坐标列表 二维数组 [[x, y, angle], [x, y, angle]]
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
        this.speed = ROLL_SPEED;
		this.fail = false;
        this.rollDis = this.radius * 2;
        this.minDis = 0;
        this.ballList = [];
        this._ballDict = new Dictionary();
        this.shootBallDict = new Dictionary();
    }
    
    /**
	 * 初始化事件
	 */
	private function initEvent():void 
	{
		this.removeBallEvent = new ZumaEvent(ZumaEvent.REMOVE);
		this.addBallEvent = new ZumaEvent(ZumaEvent.ADD);
	}
    
    /**
     * 初始化滚入球
     */
    private function initRollBall():void
    {
        if (!this.mapList || this.mapList.length == 0) return;
        if (this.rollInited) return;
        var bVo:BallVo;
		var dataAry:Array = this.mapList[0];
        var startX:Number = dataAry[0];
        var startY:Number = dataAry[1];
		var angle:Number = MathUtil.dgs2rds(dataAry[2]);
        //上一个球的数据
        var prevBall:BallVo;
        if (this.ballList.length < this.rollInCount)
        {
            //一个个滚入球
            if (this.ballList.length == 0)
            {
                bVo = this.createBall(0, 0, 0, 0, Random.randint(1, this.colorType));
                bVo.mapIndex = 0;
                bVo.x = startX;
                bVo.y = startY;
                bVo.vx = Math.cos(angle) * this.speed;;
                bVo.vy = Math.sin(angle) * this.speed;;
                bVo.next = null;
                this.ballList.unshift(bVo);
                this.addBallEvent.bVo = bVo;
                this.dispatchEvent(this.addBallEvent);
            }
            else
            {
                //当前最后一个滚入的球的数据
                bVo = this.ballList[0];
                //大于滚入距离则创建新球
                if (MathUtil.distance(bVo.x, bVo.y, startX, startY) >= this.rollDis)
                {
                    prevBall = bVo;
                    bVo = this.createBall(startX, startY, 0, 0, Random.randint(1, this.colorType));
                    bVo.next = prevBall;
                    bVo.mapIndex = 0;
                    bVo.vx = Math.cos(angle) * this.speed;;
                    bVo.vy = Math.sin(angle) * this.speed;;
                    prevBall.prev = bVo;
                    this.ballList.unshift(bVo);
                    this.addBallEvent.bVo = bVo;
                    this.dispatchEvent(this.addBallEvent);
                }
            }
        }
        else 
        {
            //滚入结束 设置为普通速度
			this.speed = GENERAL_SPEED;
            var length:int = this.ballList.length;
            for (var i:int = 0; i < length; i += 1) 
            {
                bVo = this.ballList[i];
				angle = this.mapList[bVo.mapIndex][2];
				angle = MathUtil.dgs2rds(angle);
                bVo.vx = Math.cos(angle) * this.speed;
                bVo.vy = Math.sin(angle) * this.speed;
            }
            this.rollInited = true;
        }
    }
    
    /**
     * 判断范围
     */
    private function checkRange():void
    {
        if (!this.shootBallDict) return;
        var bVo:BallVo;
        for each (bVo in this.shootBallDict)
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
        delete this.shootBallDict[bVo];
        this.removeBallEvent.bVo = bVo;
        this.dispatchEvent(this.removeBallEvent);
    }
    
    /**
     * 创建一个球
     * @param	x       位置
     * @param	y       位置
     * @param	vx      横向速度
     * @param	vy      纵向速度
     * @param	color   颜色
     * @return  球
     */
    private function createBall(x:Number, y:Number, vx:Number, vy:Number, color:uint):BallVo
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
	 * 判断当前球地图索引
	 * @param	bVo 球数据
	 */
	private function checkMapIndex(bVo:BallVo):void
	{
		if (bVo.mapIndex >= this.mapList.length - 1) 
		{
			this.fail = true;
			return;
		}
		var dataAry:Array = this.mapList[bVo.mapIndex + 1];
		var x:Number = dataAry[0];
		var y:Number = dataAry[1];
		var angle:Number = MathUtil.dgs2rds(dataAry[2]);
		//TODO怎样正确计算出 所在的地图索引
		if (Math.floor(MathUtil.distance(x, y, bVo.x, bVo.y)) <= this.minDis)
		{
			bVo.mapIndex++;
			bVo.vx = Math.cos(angle) * this.speed;
			bVo.vy = Math.sin(angle) * this.speed;
			bVo.x = x;
			bVo.y = y;
		}
	}
    
    /**
     * 移动
     */
    private function move():void 
    {
        if (!this._ballDict) return;
        var bVo:BallVo;
        for each (bVo in this._ballDict) 
        {
			this.checkMapIndex(bVo);
			bVo.x += bVo.vx;
			bVo.y += bVo.vy;
        }
    }
    
    /**
     * 碰撞检测
     */
    private function hitTest():void
    {
        var shootBVo:BallVo;
        var bVo:BallVo;
        var length:int = this.ballList.length;
        for each (shootBVo in this.shootBallDict)
        {
            for (var i:int = 0; i < length; i += 1) 
            {
                bVo = this.ballList[i];
                if (MathUtil.distance(shootBVo.x, shootBVo.y, 
                                      bVo.x, bVo.y) <= this.radius * 2)
                {
					delete this.shootBallDict[shootBVo];
					/*shootBVo.vx = bVo.vx;
					shootBVo.vy = bVo.vy;
                    shootBVo.x = bVo.x;
                    shootBVo.y = bVo.y;
                    shootBVo.mapIndex = bVo.mapIndex;*/
                    
                    var dataAry:Array = this.mapList[bVo.mapIndex];
                    var x:int = dataAry[0];
                    var y:int = dataAry[1];
                    var angle:int = dataAry[2];
                    var dis:Number = this.radius * 2;
                    var len:int = dis / this.speed;
                    var dx:Number;
                    var dy:Number;
                    //循环线段线路
                    trace("----------in-----------")
                    for (var j:int = 0; j <=len; j += 1) 
                    {
                        dx = x + Math.round(Math.cos(MathUtil.dgs2rds(angle)) * j);
                        dy = y + Math.round(Math.sin(MathUtil.dgs2rds(angle)) * j);
                        trace("x, dx", Math.round(bVo.x), dx);
                        trace("y, dy", Math.round(bVo.y), dy);
                        if (Math.round(bVo.x) == dx && 
                            Math.round(bVo.y) == dy)
                        {
                            //trace("************J**************",  j);
                            bVo.mapIndex++;
                            var ary:Array = this.mapList[bVo.mapIndex];
                            var lx:int = ary[0];
                            var ly:int = ary[1];
                            var a:int = ary[2];
                            var cos:Number = Math.cos(MathUtil.dgs2rds(a));
                            var sin:Number = Math.sin(MathUtil.dgs2rds(a));
                            bVo.x = lx + Math.round(cos * j);
                            bVo.y = ly + Math.round(sin * j);
                            bVo.vx = cos * this.speed;
                            bVo.vy = sin * this.speed;
                            break;
                        }
                    }
                    if (j == len)
                    {
                        trace("----------漏-----------")
                    }
                    break;
                }
            }
        }
    }
    
    //***********public function***********
    /**
     * 数据更新
     */
    public function update():void
    {
		if (this.fail) return;
        this.initRollBall();
        this.checkRange();
        this.hitTest();
        this.move();
    }
    
    /**
     * 添加一个球
     * @param	x       位置
     * @param	y       位置
     * @param	vx      横向速度
     * @param	vy      纵向速度
     * @param	color   颜色
     */
    public function addBall(x:Number, y:Number, vx:Number, vy:Number, color:uint):void
    {
        var bVo:BallVo = this.createBall(x, y, vx, vy, color);
        this.shootBallDict[bVo] = bVo;
        this.addBallEvent.bVo = bVo;
        this.dispatchEvent(this.addBallEvent);
    }
    
    /**
     * 销毁
     */
    public function destroy():void
    {
        this.ballList = null;
        this._ballDict = null;
        this.shootBallDict = null;
    }
    
    /**
     * 球的字典
     */
    public function get ballDict():Dictionary { return _ballDict; }
}
}
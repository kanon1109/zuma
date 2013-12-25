package  
{
import data.BallVo;
import events.ZumaEvent;
import flash.events.EventDispatcher;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import flash.utils.getTimer;
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
    private var _shootBallDict:Dictionary;
    //颜色种类
    private var colorType:uint;
    //运动范围
    private var range:Rectangle;
    //销毁球事件
    private var removeBallEvent:ZumaEvent;
    //添加球事件
    private var addBallEvent:ZumaEvent;
    //步长速度
    private var stepSpeed:int;
    //滚入滚出速度
    private const ROLL_STEP:int = 2;
	//普通速度 普通速度一般为滚入速度的1/2
	private const GENERAL_STEP:int = 1;
	//一个球所占的步长
	private var ballStep:int;
    //滚入距离 最后一个球大于距离则创建球
    private var rollDis:Number;
	//进入下一个地图索引需要的最小距离
    private var minDis:Number;
    //是否滚入完成
    private var rollInited:Boolean;
	//游戏失败
	private var fail:Boolean;
	//位置坐标
	private var posList:Array;
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
		this.ballStep = radius * 2;
        this.initData();
        this.initEvent();
    }
    
    /**
     * 初始化数据
     */
    private function initData():void
    {
        this.stepSpeed = ROLL_STEP;
		this.fail = false;
        this.rollDis = this.radius * 2;
        this.minDis = 0;
        this.ballList = [];
        this._ballDict = new Dictionary();
        this._shootBallDict = new Dictionary();
		this.posList = [];
		
		var dataAry:Array;
		var length:int = this.mapList.length;
		var x:int;
		var y:int;
		var angle:int;
		var dis:Number = this.radius * 2;
		var len:int = dis / GENERAL_STEP;
		var dx:Number;
		var dy:Number;
		var t:Number = getTimer();
		for (var i:int = 0; i < length; i += 1) 
		{
			dataAry = this.mapList[i];
			x = dataAry[0];
			y = dataAry[1];
			angle = dataAry[2];
			this.posList.push([x, y]);
			//循环线段线路
			for (var j:int = 1; j < len; j += 1)
			{
				dx = x + Math.round(Math.cos(MathUtil.dgs2rds(angle)) * j);
				dy = y + Math.round(Math.sin(MathUtil.dgs2rds(angle)) * j);
				this.posList.push([dx, dy]);
			}
		}
		trace("t", getTimer() - t);
		trace(this.posList.length);
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
                bVo = this.createBall(0, 0, 0, 0, Random.randint(1, this.colorType), this.radius);
				this._ballDict[bVo] = bVo;
                bVo.x = startX;
                bVo.y = startY;
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
                    bVo = this.createBall(startX, startY, 0, 0, Random.randint(1, this.colorType), this.radius);
					this._ballDict[bVo] = bVo;
                    bVo.next = prevBall;
                    prevBall.prev = bVo;
                    this.ballList.unshift(bVo);
                    this.addBallEvent.bVo = bVo;
                    this.dispatchEvent(this.addBallEvent);
                }
            }
        }
        else 
        {
            //滚入结束 设置为普通步长速度
			this.stepSpeed = GENERAL_STEP;
            this.rollInited = true;
        }
    }
    
    /**
     * 判断范围
     */
    private function checkRange(bVo:BallVo):void
    {
		if (!bVo) return;
        if (bVo.x < this.range.left - this.radius || 
			bVo.x > this.range.right + this.radius ||
			bVo.y < this.range.top - this.radius ||
			bVo.y > this.range.bottom + this.radius)
			this.removeBall(bVo);
    }
    
    /**
     * 销毁球
     * @param	bVo     球数据
     */
    private function removeBall(bVo:BallVo):void
    {
        delete this._ballDict[bVo];
        delete this._shootBallDict[bVo];
        this.removeBallEvent.bVo = bVo;
        this.dispatchEvent(this.removeBallEvent);
    }
    
    /**
     * 创建一个球
     * @param	x        位置
     * @param	y        位置
     * @param	vx       横向速度
     * @param	vy       纵向速度
     * @param	color    颜色
     * @param	radius   半径
     * @return  球
     */
    private function createBall(x:Number, y:Number, vx:Number, vy:Number, color:uint, radius:Number):BallVo
    {
        var bVo:BallVo = new BallVo();
        bVo.radius = radius;
        bVo.x = x;
        bVo.y = y;
        bVo.vx = vx;
        bVo.vy = vy;
        bVo.color = color;
        return bVo;
    }
	
	/**
	 * 射击移动
	 */
	private function shootMove():void
	{
		if (!this._shootBallDict) return;
		var bVo:BallVo;
        for each (bVo in this._shootBallDict) 
        {
			bVo.x += bVo.vx;
			bVo.y += bVo.vy;
			this.checkRange(bVo);
        }
	}
    
    /**
     * 移动
     */
    private function move():void 
    {
        if (!this._ballDict) return;
        var bVo:BallVo;
		var arr:Array;
        for each (bVo in this._ballDict) 
        {
			arr = this.posList[bVo.posIndex];
			bVo.x = arr[0];
			bVo.y = arr[1];
			bVo.posIndex += this.stepSpeed;
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
        for each (shootBVo in this._shootBallDict)
        {
            for (var i:int = 0; i < length; i += 1) 
            {
                bVo = this.ballList[i];
                if (MathUtil.distance(shootBVo.x, shootBVo.y, 
                                      bVo.x, bVo.y) <= this.radius * 2)
                {
					shootBVo.vx = 0;
					shootBVo.vy = 0;
                    shootBVo.x = bVo.x;
                    shootBVo.y = bVo.y;
					shootBVo.posIndex = bVo.posIndex;
					delete this._shootBallDict[shootBVo];
					var posAry:Array = this.getInsertPos(bVo, shootBVo);	
					bVo.x = posAry[0];
					bVo.y = posAry[1];
					bVo.posIndex += this.ballStep; 
                    break;
                }
            }
        }
    }
	
	/**
	 * 获取插入位置
	 * @param	hitBVo		碰撞球数据
	 * @param	shootBVo	射出的球数据
	 * @return	
	 */
	private function getInsertPos(hitBVo:BallVo, shootBVo:BallVo):Array
	{
		//上一个位置的索引
		var nextPosIndex:int;
		//下一个位置的索引
		var prevPosIndex:int;
		var posAry:Array;
		var x:Number;
		var y:Number;
		nextPosIndex = hitBVo.posIndex + this.ballStep;
		prevPosIndex = hitBVo.posIndex - this.ballStep;
		if (prevPosIndex < 0) 
		{
			//右边坐标
			posAry = this.posList[nextPosIndex];
			return posAry;
		}
		if (nextPosIndex >= this.posList.length) 
		{
			//左边坐标
			posAry = this.posList[prevPosIndex];
			return posAry;
		}
		//下一个坐标的距离
		posAry = this.posList[nextPosIndex];
		x = posAry[0];
		y = posAry[1];
		var nextDis:Number = MathUtil.distance(x, y, shootBVo.x, shootBVo.y);
		//上一个坐标的距离
		posAry = this.posList[prevPosIndex];
		x = posAry[0];
		y = posAry[1];
		var prevDis:Number = MathUtil.distance(x, y, shootBVo.x, shootBVo.y);
		if (nextDis < prevDis)
		{
			posAry = this.posList[nextPosIndex];
			return posAry;
		}
		posAry = this.posList[prevPosIndex];
		return posAry;
	}
    
    //***********public function***********
    /**
     * 数据更新
     */
    public function update():void
    {
		if (this.fail) return;
        this.initRollBall();
        this.shootMove();
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
        var bVo:BallVo = this.createBall(x, y, vx, vy, color, this.radius);
        this._shootBallDict[bVo] = bVo;
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
        this._shootBallDict = null;
    }
    
    /**
     * 球的字典
     */
    public function get ballDict():Dictionary { return _ballDict; }
	
	/**
	 * 射出球的字典
	 */
	public function get shootBallDict():Dictionary{ return _shootBallDict; }
}
}
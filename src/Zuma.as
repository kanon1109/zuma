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
    //地图列表
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
    private var rollSpeed:Number;
    //滚入距离 最后一个球大于距离则创建球
    private var rollDis:Number;
    //是否滚入完成
    private var rollInited:Boolean;
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
        this.rollSpeed = 2;
        this.speed = 0;
        this.rollDis = this.radius * 2;
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
        var vx:Number;
        var vy:Number;
        var angle:Number;
        var startX:Number = this.mapList[0][0];
        var startY:Number = this.mapList[0][1];
        //上一个球的数据
        var prevBall:BallVo;
        if (this.ballList.length < this.rollInCount)
        {
            //一个个滚入球
            if (this.ballList.length == 0)
            {
                bVo = this.createBall(0, 0, 0, 0, Random.randint(1, this.colorType));
                bVo.mapIndex = 0;
                angle = this.getMapNodeAngle(bVo.mapIndex);
                bVo.x = startX;
                bVo.y = startY;
                vx = Math.cos(angle) * this.rollSpeed;
                vy = Math.sin(angle) * this.rollSpeed;
                bVo.vx = vx;
                bVo.vy = vy;
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
                    angle = this.getMapNodeAngle(bVo.mapIndex);
                    vx = Math.cos(angle) * this.rollSpeed;
                    vy = Math.sin(angle) * this.rollSpeed;
                    bVo.vx = vx;
                    bVo.vy = vy;
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
            var length:int = this.ballList.length;
            for (var i:int = 0; i < length; i += 1) 
            {
                bVo = this.ballList[i];
                angle = this.getMapNodeAngle(bVo.mapIndex);
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
     * 获取2个地图节点的夹角
     * @param	index   当前地图节点索引
     * @return  地图节点的夹角   
     */
    private function getMapNodeAngle(index:int):Number
    {
        if (!this.mapList || this.mapList.length == 0) return 0;
        if (index >= this.mapList.length - 1) return 0;
        var posX:Number = this.mapList[index][0];
        var posY:Number = this.mapList[index][1];
        var nextPosX:Number = this.mapList[index + 1][0];
        var nextPosY:Number = this.mapList[index + 1][1];
        return Math.atan2(nextPosY - posY, nextPosX - posX);
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
                if (MathUtil.distance(shootBVo.x,
                                      shootBVo.y, 
                                      bVo.x, 
                                      bVo.y) <= this.radius * 2)
                {
                    
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
        this.initRollBall();
        this.checkRange();
        this.move();
        this.hitTest();
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
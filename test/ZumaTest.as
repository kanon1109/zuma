package  
{
import data.BallVo;
import events.ZumaEvent;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.ui.Keyboard;
import utils.MathUtil;
import utils.Random;
/**
 * ...祖玛测试
 * @author Kanon
 */
public class ZumaTest extends Sprite 
{
    private var aimMc:Sprite;
    //祖玛对象
    private var zuma:Zuma;
    //炮
    private var cannon:Cannon;
    //颜色类型
    private var colorType:int = 5;
    //颜色列表
    private var colorAry:Array = [null, 0xFF00FF, 0xFFFF00, 0x0000FF/*, 0xCCFF00, 0x00CCFF*/];
    //地图列表
    private var mapList:Array;
    public function ZumaTest() 
    {
        this.colorType = colorAry.length - 1;
        stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
        this.addEventListener(Event.ENTER_FRAME, loop);
        this.initMap();
        this.initUI();
    }
    
    private function onKeyDownHandler(event:KeyboardEvent):void 
    {
        if (event.keyCode == Keyboard.S) this.removeEventListener(Event.ENTER_FRAME, loop);
        else if (event.keyCode == Keyboard.A) this.addEventListener(Event.ENTER_FRAME, loop);
    }
    
    /**
     * 初始化地图
     */
    private function initMap():void
    {
		this.mapList = [[49, 85, 324], [75, 66, 333], [104, 52, 337], [134, 40, 342], [164, 30, 352], [196, 26, 0], [228, 26, 0], [260, 26, 3], [292, 28, 6], [324, 32, 7], [356, 36, 8], [388, 41, 21], [418, 53, 26], [447, 67, 27], [475, 82, 38], [500, 102, 52], [520, 127, 64], [534, 156, 72], [544, 187, 76], [552, 218, 83], [556, 250, 88], [557, 282, 98], [552, 314, 103], [545, 345, 106], [536, 376, 124], [518, 402, 132], [496, 426, 148], [469, 443, 148], [442, 460, 157], [412, 472, 171], [380, 477, 178], [348, 478, 180], [316, 478, 178], [284, 479, 180], [252, 479, 190], [220, 473, 205], [191, 459, 213], [164, 441, 222], [140, 419, 225], [117, 396, 234], [98, 370, 243], [84, 341, 253], [75, 310, 268], [74, 278, 278], [79, 246, 288], [89, 216, 295], [103, 187, 301], [120, 160, 306], [139, 134, 319], [164, 113, 332], [192, 98, 334], [221, 84, 345], [252, 76, 356], [284, 74, 7], [316, 78, 14], [347, 86, 18], [377, 96, 30], [405, 112, 36], [431, 131, 42], [455, 153, 52], [475, 178, 77], [482, 209, 85], [485, 241, 90], [485, 273, 90], [485, 305, 108], [475, 335, 123], [457, 362, 139], [432, 383, 157], [402, 395, 157], [372, 407, 171], [340, 412, 174], [308, 415, 180], [276, 415, 190], [245, 409, 217], [220, 389, 228], [199, 365, 236], [181, 338, 254], [173, 307, 266], [171, 275, 281], [177, 244, 288], [187, 214, 300], [203, 186, 312], [225, 162, 327], [252, 145, 351], [284, 140, 3], [316, 142, 14], [347, 150, 32], [374, 167, 37], [399, 187, 36], [425, 206, 67], [437, 236, 88], [438, 268, 117], [423, 296, 128], [403, 321, 152], [375, 336, 166], [344, 344, 172], [312, 348, 0]];
		var length:int = this.mapList.length;
        trace("length", length);
		this.graphics.lineStyle(2, 0xFF0000);
		this.graphics.moveTo(this.mapList[0][0], this.mapList[0][1]);
		for (var i:int = 0; i < length; i += 1)
        {
			if (i > 0) this.graphics.lineTo(this.mapList[i][0], this.mapList[i][1]);
        }
    }
    
    /**
     * 初始化
     */
    private function initUI():void
    {
        this.cannon = new Cannon(300, 250, 10);
        this.zuma = new Zuma(this.mapList, 4, 16, this.colorType, 
                                new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), 3);
        this.zuma.addEventListener(ZumaEvent.REMOVE, removeBallHandler);
        this.zuma.addEventListener(ZumaEvent.ADD, addBallHandler);
        this.aimMc = this.getChildByName("aim_mc") as Sprite;
    }
    
    private function addBallHandler(event:ZumaEvent):void 
    {
        var bVo:BallVo = event.bVo as BallVo;
        this.drawBall(bVo);
    }
    
    private function removeBallHandler(event:ZumaEvent):void 
    {
        var bVo:BallVo = event.bVo as BallVo;
        this.removeBall(bVo);
    }
    
    /**
     * 销毁一个球的显示对象
     * @param	bVo     球数据
     */
    private function removeBall(bVo:BallVo):void
    {
        if (!bVo) return;
        if (bVo.userData && bVo.userData is Sprite)
        {
            Sprite(bVo.userData).graphics.clear();
            if (Sprite(bVo.userData).parent)
                Sprite(bVo.userData).parent.removeChild(Sprite(bVo.userData));
            bVo.userData = null;
        }
    }
    
    /**
     * 绘制一个球显示对象
     * @param	bVo    泡泡数据
     */
    private function drawBall(bVo:BallVo):void
    {
        if (!bVo) return;
		if (bVo.userData && bVo.userData is Sprite) Sprite(bVo.userData).graphics.clear();
		else bVo.userData = new Sprite();
        Sprite(bVo.userData).graphics.lineStyle(1, 0);
        Sprite(bVo.userData).graphics.beginFill(this.colorAry[bVo.color]);
        Sprite(bVo.userData).graphics.drawCircle(0, 0, bVo.radius);
        Sprite(bVo.userData).graphics.endFill();
        Sprite(bVo.userData).x = bVo.x;
        Sprite(bVo.userData).y = bVo.y;
        this.addChild(Sprite(bVo.userData));
    }
    
    private function mouseDownHandler(event:MouseEvent):void 
    {
        var vx:Number = Math.cos(this.cannon.angle) * this.cannon.power;
        var vy:Number = Math.sin(this.cannon.angle) * this.cannon.power;
        this.zuma.addBall(this.cannon.startX, this.cannon.startY, vx, vy, Random.randint(1, this.colorType));
    }
    
    /**
     * 渲染
     */
    private function render():void
    {
        var bVo:BallVo;
		for each (bVo in this.zuma.allBallDict) 
		{
			if (bVo.userData && bVo.userData is DisplayObject)
            {
                Sprite(bVo.userData).x = bVo.x;
                Sprite(bVo.userData).y = bVo.y;
            }
		}
    }
    
    private function loop(event:Event):void 
    {
        this.cannon.aim(mouseX, mouseY);
        this.aimMc.rotation = MathUtil.rds2dgs(this.cannon.angle); 
        this.zuma.update();
        this.render();
    }
}
}
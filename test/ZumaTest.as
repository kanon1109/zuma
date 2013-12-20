package  
{
import data.BallVo;
import events.ZumaEvent;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
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
    private var colorAry:Array = [null, 0xFF00FF, 0xFFFF00, 0x0000FF, 0xCCFF00, 0x00CCFF];
    public function ZumaTest() 
    {
        stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        this.addEventListener(Event.ENTER_FRAME, loop);
        this.initUI();
    }
    
    /**
     * 初始化
     */
    private function initUI():void
    {
        this.cannon = new Cannon(300, 250, 10);
        this.zuma = new Zuma([], 10, 15, this.colorType, new Rectangle(0, 0, stage.stageWidth, stage.stageHeight), 3);
        this.zuma.addEventListener(ZumaEvent.REMOVE, removeBallHandler);
        this.aimMc = this.getChildByName("aim_mc") as Sprite;
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
        var bVo:BallVo = this.zuma.addBall(this.cannon.startX, this.cannon.startY, vx, vy, Random.randint(1, this.colorType));
        this.drawBall(bVo);
    }
    
    /**
     * 渲染
     */
    private function render():void
    {
        var bVo:BallVo;
		for each (bVo in this.zuma.ballDict) 
		{
			bVo.x += bVo.vx;
			bVo.y += bVo.vy;
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
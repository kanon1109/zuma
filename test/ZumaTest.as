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
    //地图列表
    private var mapList:Array;
    public function ZumaTest() 
    {
        stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
        this.addEventListener(Event.ENTER_FRAME, loop);
        this.initMap();
        this.initUI();
    }
    
    /**
     * 初始化地图
     */
    private function initMap():void
    {
		this.mapList = [[82,40,334], [96,34,340], [110,29,349], [125,26,357], [140,25,0], [155,25,355], [170,24,357], [185,23,0], [200,23,356], [215,22,357], [230,21,0], [245,21,0], [260,21,0], [275,21,3], [290,22,0], [305,22,3], [320,23,1], [335,24,0], [350,24,0], [365,24,0], [380,24,7], [395,26,8], [410,28,7], [425,30,11], [440,33,7], [455,35,20], [469,40,37], [481,49,38], [493,58,46], [503,69,45], [514,80,50], [524,92,51], [533,104,47], [543,115,55], [552,127,69], [557,141,69], [562,155,72], [567,169,70], [572,183,77], [575,198,79], [578,213,90], [578,228,87], [579,243,90], [579,258,90], [579,273,90], [579,288,90], [579,303,90], [579,318,90], [579,333,105], [575,347,110], [570,361,113], [564,375,112], [558,389,122], [550,402,138], [539,412,139], [528,422,149], [515,430,144], [503,439,147], [490,447,140], [478,456,143], [466,465,151], [453,472,153], [440,479,157], [426,485,158], [412,491,165], [397,495,180], [382,495,180], [367,495,180], [352,495,187], [337,493,191], [322,490,191], [307,487,193], [292,483,194], [277,479,197], [263,474,194], [248,470,194], [233,466,194], [218,462,194], [203,458,198], [189,453,196], [175,449,199], [161,444,203], [147,438,197], [133,434,205], [119,428,212], [106,420,210], [93,412,214], [81,404,217], [69,395,232], [60,383,243], [53,370,244], [47,356,246], [41,342,255], [37,327,266], [36,312,270], [36,297,270], [36,282,270], [36,267,270], [36,252,272], [37,237,273], [38,222,278], [40,207,287], [45,193,281], [48,178,291], [54,164,297], [61,151,302], [69,138,312], [79,127,320], [91,117,322], [103,108,319], [114,98,327], [127,90,333], [140,83,348], [155,80,345], [169,76,0], [184,76,0], [199,76,0], [214,76,0], [229,76,0], [244,76,0], [259,76,0], [274,76,0], [289,76,0], [304,76,0], [319,76,3], [334,77,0], [349,77,0], [364,77,3], [379,78,0], [394,78,0], [409,78,14], [424,82,31], [437,90,51], [446,102,57], [454,115,61], [461,128,52], [470,140,63], [477,153,57], [485,166,63], [492,179,66], [498,193,74], [502,207,77], [505,222,83], [507,237,90], [507,252,90], [507,267,90], [507,282,90], [507,297,102], [504,312,107], [500,326,116], [493,339,115], [487,353,121], [479,366,110], [474,380,109], [469,394,113], [463,408,129], [453,420,148], [440,428,161], [426,433,174], [411,434,176], [396,435,180], [381,435,180], [366,435,183], [351,434,180], [336,434,185], [321,433,183], [306,432,187], [291,430,183], [276,429,192], [261,426,200], [247,421,206], [234,414,205], [220,408,212], [207,400,211], [194,392,222], [183,382,222], [172,372,235], [164,360,241], [157,347,255], [153,333,237], [145,320,241], [138,307,255], [134,293,270], [134,278,273], [135,263,277], [137,248,288], [142,234,298], [149,221,299], [156,208,317], [167,198,327], [180,190,330], [193,183,323], [205,174,0], ]
		var length:int = this.mapList.length;
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
        this.zuma = new Zuma(this.mapList, 10, 15, this.colorType, 
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
		for each (bVo in this.zuma.ballDict) 
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
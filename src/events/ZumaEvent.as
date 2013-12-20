package events 
{
import data.BallVo;
import flash.events.Event;
/**
 * ...祖玛事件
 * @author Kanon
 */
public class ZumaEvent extends Event 
{
    /**销毁事件*/
    public static const REMOVE:String = "remove";
    /**球数据*/
    public var bVo:BallVo;
    public function ZumaEvent(type:String, bVo:BallVo = null, bubbles:Boolean = false, cancelable:Boolean = false)
    {
        this.bVo = bVo;
        super(type, bubbles, cancelable);
    } 
    
    public override function clone():Event 
    { 
        return new ZumaEvent(type, bVo, bubbles, cancelable);
    } 
    
    public override function toString():String 
    { 
        return formatToString("ZumaEvent", "type", "bubbles", "cancelable", "eventPhase"); 
    }
    
}
}
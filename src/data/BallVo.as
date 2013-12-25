package data 
{
/**
 * ...球数据
 * @author Kanon
 */
public class BallVo 
{
    /**钻石类型*/
    public var color:int;
    /**x坐标位置*/
    public var x:Number;
    /**y坐标位置*/
    public var y:Number;
    /**横向速度*/
    public var vx:Number;
    /**纵向速度*/
    public var vy:Number;
    /**半径*/
    public var radius:Number;
	/**位置索引*/
    public var posIndex:int;
    /**用户数据*/
    public var userData:*;
    /**下一个球数据*/
    public var next:BallVo;
    /**上一个球数据*/
    public var prev:BallVo;
}
}
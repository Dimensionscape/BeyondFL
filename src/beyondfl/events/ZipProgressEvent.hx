package beyondfl.events;

import beyondfl.zip.ZipObject;
import openfl.events.Event;

/**
 * ...
 * @author Christopher Speciale
 */
class ZipProgressEvent extends Event 
{

	public static inline var PROGRESS_OUT:String = "progressOut";
	
	public var zipObject(default, null):ZipObject;
	public var bytesTotal(default, null):Float;
	public var bytesPending(default, null):Float;
	
	public function new(type:String, zipObject:ZipObject, bytesTotal:Float, bytesPending:Float):Void 
	{
		super(type);
		
		this.zipObject = zipObject;
		this.bytesTotal = bytesTotal;
		this.bytesPending = bytesPending;		
	}
	
}

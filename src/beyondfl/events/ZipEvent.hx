package beyondfl.events;

import beyondfl.zip.ZipFile;
import openfl.events.Event;

/**
 * ...
 * @author Christopher Speciale
 */
class ZipEvent extends Event 
{
	public static inline var COMPLETE:String = "complete";
	
	public var zipFile:ZipFile;
	public function new(type:String, zipFile:ZipFile) 
	{
		super(type);
		this.zipFile = zipFile;
	}
	
}

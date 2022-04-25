package beyondfl.zip;
import beyondfl.events.ZipEvent;
import beyondfl.zip.ZipFile;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;


/**
 * ...
 * @author Christopher Speciale
 */
@:access(beyondfl.zip.ZipFile)
class ZipLoader extends EventDispatcher
{

	private var __loader:URLLoader;
	
	public function new() 
	{
		super();
	}
	
	public function load(request:URLRequest):Void{
		__loader = new URLLoader();
		__loader.dataFormat = BINARY;
		__loader.addEventListener(ZipEvent.COMPLETE, loader_onComplete);
		__loader.load(request);
	}
	
	private function loader_onComplete(e:Event):Void{
		loadBytes(__loader.data);
	}
	
	public function loadBytes(bytes:ByteArray):Void
	{
		var file:ZipFile = new ZipFile();
		file.__unpack(bytes);
		
		dispatchEvent(new ZipEvent(ZipEvent.COMPLETE, file));
	}
	
	
}

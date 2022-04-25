package beyondfl.zip;
import haxe.io.Path;
import haxe.zip.Entry;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Christopher Speciale
 */
class ZipObject 
{
	
	public var name:String;
	public var path:String;
	public var extension:String;
	public var parent(get, never):String;
	public var creationDate:Date;
	public var isDirectory:Bool;
	public var data:ByteArray;
	public var size:UInt;
	public var crc32:Null<Int>;
	public var compressed:Bool;
		
	private function new(entry:Entry) 
	{
		path = entry.fileName;
		isDirectory = path.charAt(path.length - 1) == "/";			
		name = isDirectory ? __getDirectoryName() : Path.withoutDirectory(path);
		extension = Path.extension(name);
		creationDate = entry.fileTime;			
		data = entry.data;
		size = entry.dataSize;
		crc32 = entry.crc32;
		compressed = entry.compressed;
	}
	
	private function get_parent():String {
		var path:String = Path.removeTrailingSlashes(path);

		var lastIndex:Int = path.lastIndexOf("/");
		if (lastIndex == path.indexOf("/"))
		{
			lastIndex += 1;
		}
		return lastIndex > 0 ? path.substring(0, (lastIndex - path.length) + path.length) : "";
	}
	
	private function __getDirectoryName():String{
		var path:String = Path.removeTrailingSlashes(path);

		var lastIndex:Int = path.lastIndexOf("/");
		if (lastIndex == path.indexOf("/"))
		{
			lastIndex += 1;
		}
		return path.substring(lastIndex, path.length);
	}
}

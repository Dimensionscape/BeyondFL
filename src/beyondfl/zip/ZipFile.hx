package beyondfl.zip;
import haxe.ds.StringMap;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesInput;
import haxe.io.Path;
import haxe.zip.Entry;
import haxe.zip.InflateImpl;
import haxe.zip.Reader;
import beyondfl.events.ZipProgressEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.OutputProgressEvent;
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
import openfl.utils.ByteArray;
import openfl.utils.Function;

/**
 * ...
 * @author Christopher Speciale
 */
@:access(beyondfl.zip.ZipObject)
class ZipFile extends EventDispatcher
{
	public var data(get, never):ByteArray;
	private var __data:ByteArray = null;
	public var iterator(get, never):Iterator<ZipObject>;
	public var length(get, never):Int;
	private var __contents:Array<ZipObject>;
	private var __contentsMap:StringMap<ZipObject>;
	private function new()
	{
		super();

		__contents = [];
		__contentsMap = new StringMap();

	}

	public function getZipObject(path:String):ZipObject
	{
		if (__contentsMap.exists(path))
		{
			return __contentsMap.get(path);
		}
		return null;
	}

	public function saveAs(filepath:String):Void
	{
		__writeZipFile(filepath);
	}

	public function unzipTo(path:String, async:Bool = false):Void
	{
		if (async)
		{
			__unzipAsync(path);

		}
		else {
			for (zipObject in iterator)
			{
				__writeObject(path, zipObject);
			}
		}

	}

	private function __unzipAsync(path:String):Void
	{
		var index:Int = 0;
		__writeObjectAsync(index, path);
	}

	private function __writeObjectAsync(i:Int, path:String):Void
	{
		if (i == __contents.length){
			dispatchEvent(new Event(Event.COMPLETE));
			return;
		}
		var zipObject:ZipObject = __contents[i];
		var currentPath = path + zipObject.path;
		var file:File = new File(currentPath);
		if (zipObject.isDirectory)
		{
			file.createDirectory();			
			dispatchEvent(new ZipProgressEvent(ZipProgressEvent.PROGRESS_OUT, __contents[i], 0, 0)); 
			
			i++;
			__writeObjectAsync(i, path);
			return;
		}
		else {
			var filestream:FileStream = new FileStream();
			filestream.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS, __onAsyncWriteProgress(i, path));

			filestream.openAsync(file, WRITE);

			var fileBytes:ByteArray = zipObject.data;

			if (zipObject.compressed)
			{
				try{
					fileBytes = decompress(fileBytes);
				} catch (e){
					trace(e, zipObject.path);
				}
			}
			filestream.writeBytes(fileBytes);

		}
	}

	private function __onAsyncWriteProgress(i:Int, path:String, ?ret:Dynamic):Dynamic
	{
		return ret = function(e:OutputProgressEvent):Void{			
			
			dispatchEvent(new ZipProgressEvent(ZipProgressEvent.PROGRESS_OUT, __contents[i], e.bytesTotal, e.bytesPending)); 
			
			if (e.bytesPending == 0)
			{
				
				
				var filestream:FileStream = cast e.currentTarget;
				filestream.removeEventListener(OutputProgressEvent.OUTPUT_PROGRESS, ret);
				filestream.close();				
				
				i++;			
				
				__writeObjectAsync(i, path);
				
			}
		}
	}

	private function __writeZipFile(path:String):Void
	{
		var file:File = new File(path);

		var filestream:FileStream = new FileStream();
		filestream.open(file, WRITE);
		filestream.writeBytes(__data);
		filestream.close();
	}

	private function __writeObject(path:String, zipObject:ZipObject):Void
	{
		path = path + zipObject.path;
		var file:File = new File(path);
		if (zipObject.isDirectory)
		{
			file.createDirectory();
		}
		else {
			var filestream:FileStream = new FileStream();
			filestream.open(file, WRITE);
			var fileBytes:ByteArray = zipObject.data;
			if (zipObject.compressed)
			{
				fileBytes = decompress(fileBytes);
			}
			filestream.writeBytes(fileBytes);
			filestream.close();
		}
	}

	private function get_iterator():Iterator<ZipObject>
	{
		return __contents.iterator();
	}
	
	private function get_length():Int{
		return __contents.length;
	}
	private function __unpack(bytes:ByteArray):Void
	{
		__data = bytes;
		var input:BytesInput = new BytesInput(bytes);
		var reader:Reader = new Reader(input);

		var fileList:List<Entry> = reader.read();

		for (entry in fileList)
		{
			var zipObject:ZipObject = new ZipObject(entry);
			__contents.push(zipObject);
			__contentsMap.set(zipObject.path, zipObject);
		}
	}

	public static function decompress(data:ByteArray):ByteArray
	{
		return ByteArray.fromBytes(__rawUncompress(new BytesInput(cast data)));
	}

	private static function __rawUncompress(input:BytesInput):Bytes
	{

		var p = input.position;

		var bufSize = 65536;
		var tmp = Bytes.alloc(bufSize);

		var out = new BytesBuffer();
		var z = new InflateImpl(input, false, false);

		while ( true )
		{
			var n = z.readBytes(tmp, 0, bufSize);
			out.addBytes(tmp, 0, n);

			if (n < bufSize) break;
		}

		input.position = p;
		tmp = null;
		return out.getBytes();
	}

	private function get_data():ByteArray
	{
		var dataBytes:ByteArray = new ByteArray(__data.length);
		dataBytes.writeBytes(dataBytes);
		dataBytes.position = 0;
		return dataBytes;
	}

}

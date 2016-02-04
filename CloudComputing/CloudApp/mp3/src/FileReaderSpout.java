
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Map;

import backtype.storm.spout.SpoutOutputCollector;
import backtype.storm.task.TopologyContext;
import backtype.storm.topology.IRichSpout;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Values;
import backtype.storm.utils.Utils;

public class FileReaderSpout implements IRichSpout {
  private SpoutOutputCollector _collector;
  private TopologyContext context;
  
  private BufferedReader bufReader;

  /* Option 2
  private String inputFilePath;
  public FileReaderSpout(String inputFilePath) {
	this.inputFilePath = inputFilePath;
  }
  */
  
  @Override
  public void open(Map conf, TopologyContext context,
                   SpoutOutputCollector collector) {
    /*
    ----------------------TODO-----------------------
    Task: initialize the file reader
    ------------------------------------------------- */
	// Get input file path
	String inputFilePath = (String)conf.get("MY_CONF_INPUTFILEPATH");
	
	// Open input file
	try {
		bufReader = new BufferedReader(new FileReader(inputFilePath));
	} catch (FileNotFoundException e) {
		//System.out.println("File not exists!");
	} catch (IOException e) {
		//System.out.println("Failed to open text file!");
	}
	//-------------------------------------------------

    this.context = context;
    this._collector = collector;
  }

  @Override
  public void nextTuple() {
    /*
    ----------------------TODO-----------------------
    Task:
    1. read the next line and emit a tuple for it
    2. don't forget to sleep when the file is entirely read to prevent a busy-loop

    ------------------------------------------------- */
	if (bufReader != null) {
		String strLine;
		try {
			if ((strLine = bufReader.readLine()) != null) {
				_collector.emit(new Values(strLine));
				return;
			}
		} catch(IOException e) {
			//System.out.println("Failed to read text file!");
		}			
	}
	Utils.sleep(100);
	//-------------------------------------------------
  }

  @Override
  public void declareOutputFields(OutputFieldsDeclarer declarer) {

    declarer.declare(new Fields("word"));

  }

  @Override
  public void close() {
   /*
    ----------------------TODO-----------------------
    Task: close the file
    ------------------------------------------------- */
	try {
		if (bufReader != null) {
			bufReader.close();
		}
	} catch (IOException e) {
		//System.out.println("Failed to close file!");
	}
	//-------------------------------------------------
  }


  @Override
  public void activate() {
  }

  @Override
  public void deactivate() {
  }

  @Override
  public void ack(Object msgId) {
  }

  @Override
  public void fail(Object msgId) {
  }

  @Override
  public Map<String, Object> getComponentConfiguration() {
    return null;
  }
}


import backtype.storm.Config;
import backtype.storm.LocalCluster;
import backtype.storm.StormSubmitter;
import backtype.storm.topology.BasicOutputCollector;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.topology.TopologyBuilder;
import backtype.storm.topology.base.BaseBasicBolt;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Tuple;
import backtype.storm.tuple.Values;

/**
 * This topology reads a file and counts the words in that file
 */
public class TopWordFinderTopologyPartB {

  public static void main(String[] args) throws Exception {


    TopologyBuilder builder = new TopologyBuilder();

    Config config = new Config();
    config.setDebug(true);


    /*
    ----------------------TODO-----------------------
    Task: wire up the topology

    NOTE:make sure when connecting components together, using the functions setBolt(name,…) and setSpout(name,…),
    you use the following names for each component:
    FileReaderSpout -> "spout"
    SplitSentenceBolt -> "split"
    WordCountBolt -> "count"
    ------------------------------------------------- */
	// Get the path of input file
	String inputFilePath = "data.txt";
	if (args != null && args.length > 0) {
		inputFilePath = args[0];
	}
	// Put the file path into config, another option is to pass it as a parameter of FileReaderSpout()
	config.put("MY_CONF_INPUTFILEPATH", inputFilePath);
	
	//builder.setSpout("spout", new FileReaderSpout(inputFilePath), 1);
	builder.setSpout("spout", new FileReaderSpout(), 1);		// Limit the number of executors to 1 to ensure the input file is read only once
	builder.setBolt("split", new SplitSentenceBolt(), 8).shuffleGrouping("spout");
	builder.setBolt("count", new WordCountBolt(), 12).fieldsGrouping("split", new Fields("word"));
	//-------------------------------------------------
	
    config.setMaxTaskParallelism(3);

    LocalCluster cluster = new LocalCluster();
    cluster.submitTopology("word-count", config, builder.createTopology());

    //wait for 2 minutes and then kill the job
    Thread.sleep( 2 * 60 * 1000);

    cluster.shutdown();
  }
}

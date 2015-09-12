import backtype.storm.topology.BasicOutputCollector;
import backtype.storm.topology.OutputFieldsDeclarer;
import backtype.storm.topology.base.BaseBasicBolt;
import backtype.storm.tuple.Fields;
import backtype.storm.tuple.Tuple;
import backtype.storm.tuple.Values;

import java.util.HashMap;
import java.util.*;

/**
 * a bolt that finds the top n words.
 */
public class TopNFinderBolt extends BaseBasicBolt {
  private HashMap<String, Integer> currentTopWords = new HashMap<String, Integer>();
  private int N;

  private long intervalToReport = 20;
  private long lastReportTime = System.currentTimeMillis();

  public TopNFinderBolt(int N) {
    this.N = N;
  }

  @Override
  public void execute(Tuple tuple, BasicOutputCollector collector) {
 /*
    ----------------------TODO-----------------------
    Task: keep track of the top N words
    ------------------------------------------------- */
	String newWord = tuple.getString(0);
	Integer newCount = tuple.getInteger(1);
	if (currentTopWords.containsKey(newWord) || currentTopWords.size() < this.N) {
		currentTopWords.put(newWord, newCount);
	} else {
		// find the minimum value from the map, if it is smaller than the newCount, then replace its position with the new k-v pair
		String minKey = null;
		Integer minValue = newCount;
		Iterator iter = currentTopWords.entrySet().iterator();
		while (iter.hasNext()) {
			Map.Entry<String, Integer> entry = (Map.Entry <String, Integer>)iter.next();
			String word = (String)entry.getKey();
			Integer value = (Integer)entry.getValue();
			if (value < minValue) {
				minKey = word;
				minValue = value;
			}
		}
		
		if (null != minKey) {
			currentTopWords.remove(minKey);
			currentTopWords.put(newWord, newCount);
		}
	}
	//-------------------------------------------------

    //reports the top N words periodically
    if (System.currentTimeMillis() - lastReportTime >= intervalToReport) {
      collector.emit(new Values(printMap()));
      lastReportTime = System.currentTimeMillis();
    }
  }

  @Override
  public void declareOutputFields(OutputFieldsDeclarer declarer) {

     declarer.declare(new Fields("top-N"));

  }

  public String printMap() {
    StringBuilder stringBuilder = new StringBuilder();
    stringBuilder.append("top-words = [ ");
    for (String word : currentTopWords.keySet()) {
      stringBuilder.append("(" + word + " , " + currentTopWords.get(word) + ") , ");
    }
    int lastCommaIndex = stringBuilder.lastIndexOf(",");
    stringBuilder.deleteCharAt(lastCommaIndex + 1);
    stringBuilder.deleteCharAt(lastCommaIndex);
    stringBuilder.append("]");
    return stringBuilder.toString();

  }
}

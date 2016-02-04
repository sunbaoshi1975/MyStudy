import org.apache.log4j.Logger;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.ArrayWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.io.WritableComparator;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.Partitioner;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.KeyValueTextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import java.io.BufferedReader;
import java.io.DataInput;
import java.io.DataOutput;
import java.io.InputStreamReader;
import java.io.IOException;
import java.lang.Double;
import java.lang.Integer;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Arrays;
import java.util.List;
import java.util.TreeSet;

// >>> Don't Change
public class TopHopFlights extends Configured implements Tool {

    private static Logger theLogger = Logger.getLogger(TopHopFlights.class);
    private static String delimiters = ",";

    public static void main(String[] args) throws Exception {
        // Make sure there are exactly 2 parameters
        if (args.length < 2) {
            theLogger.warn("TopHopFlights <input-dir> <output-dir>");
            throw new IllegalArgumentException("TopHopFlights <input-dir> <output-dir>");
        }

        int res = ToolRunner.run(new Configuration(), new TopHopFlights(), args);
        theLogger.info("returnStatus=" +res);
        System.exit(res);
    }

    @Override
    public int run(String[] args) throws Exception {
        Configuration conf = this.getConf();
        FileSystem fs = FileSystem.get(conf);
        Path tmpPath = new Path("/data/tmp");
        fs.delete(tmpPath, true);

        Job jobA = Job.getInstance(conf, "Delay Count");
        jobA.setOutputKeyClass(Text.class);
        jobA.setOutputValueClass(Text.class);

        jobA.setMapOutputKeyClass(Text.class);
        jobA.setMapOutputValueClass(Text.class);

        jobA.setMapperClass(DelayCountMap.class);
        jobA.setReducerClass(DelayCountReduce.class);
        //jobA.setNumReduceTasks(10);

        FileInputFormat.setInputPaths(jobA, new Path(args[0]));
        FileOutputFormat.setOutputPath(jobA, tmpPath);

        jobA.setJarByClass(TopHopFlights.class);
        jobA.waitForCompletion(true);

        Job jobB = Job.getInstance(conf, "Top Ontime Arrival Carriers");
        jobB.setOutputKeyClass(Text.class);
        jobB.setOutputValueClass(Text.class);

        jobB.setMapOutputKeyClass(Text.class);
        jobB.setMapOutputValueClass(Text.class);

        jobB.setMapperClass(TopHopFlightsMap.class);
        jobB.setReducerClass(TopHopFlightsReduce.class);
        //jobB.setPartitionerClass(CustPartitioner.class);
        //jobB.setGroupingComparatorClass(CustGroupingComparator.class);
        jobB.setNumReduceTasks(100);

        FileInputFormat.setInputPaths(jobB, tmpPath);
        FileOutputFormat.setOutputPath(jobB, new Path(args[1]));

        jobB.setInputFormatClass(KeyValueTextInputFormat.class);
        jobB.setOutputFormatClass(TextOutputFormat.class);

        jobB.setJarByClass(TopHopFlights.class);
        boolean status = jobB.waitForCompletion(true);
        theLogger.info("run(): status="+status);
        return  status ? 0 : 1;
    }

    public static String readHDFSFile(String path, Configuration conf) throws IOException{
        Path pt=new Path(path);
        FileSystem fs = FileSystem.get(pt.toUri(), conf);
        FSDataInputStream file = fs.open(pt);
        BufferedReader buffIn=new BufferedReader(new InputStreamReader(file));

        StringBuilder everything = new StringBuilder();
        String line;
        while( (line = buffIn.readLine()) != null) {
            everything.append(line);
            everything.append("\n");
        }
        return everything.toString();
    }

    public static class TextArrayWritable extends ArrayWritable {
        public TextArrayWritable() {
            super(Text.class);
        }

        public TextArrayWritable(String[] strings) {
            super(Text.class);
            Text[] texts = new Text[strings.length];
            for (int i = 0; i < strings.length; i++) {
                texts[i] = new Text(strings[i]);
            }
            set(texts);
        }
    }

    public static class CustPartitioner
            extends Partitioner<WritableIntPair, Text> {

        @Override
        public int getPartition(WritableIntPair pair,
                                Text text,
                                int numberOfPartitions) {
            // make sure that partitions are non-negative
            return Math.abs(pair.getKey().hashCode() % numberOfPartitions);
        }
    }

    public static class CustGroupingComparator
            extends WritableComparator {

        public CustGroupingComparator() {
            super(WritableIntPair.class, true);
        }

        @Override
        /**
         * @param wc1 a WritableComparable object, which represnts a WritableIntPair
         * @param wc2 a WritableComparable object, which represnts a WritableIntPair
         * @return 0, 1, or -1 (depending on the comparsion of two WritableIntPair objects).
         */
        public int compare(WritableComparable wc1, WritableComparable wc2) {
            WritableIntPair pair = (WritableIntPair) wc1;
            WritableIntPair pair2 = (WritableIntPair) wc2;
            return pair.getKey().compareTo(pair2.getKey());
            //return pair.compareTo(pair2);
        }
    }
// <<< Don't Change

    public static class DelayCountMap extends Mapper<Object, Text, Text, Text> {
        @Override
        protected void setup(Context context) throws IOException,InterruptedException {

            Configuration conf = context.getConfiguration();
        }


        @Override
        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            // TODO
            String line = value.toString();
            String[] tokens = line.split(delimiters);

            // 0:FlightDate; 2: Carrier; 3: FlightNum; 4: Origin; 5:Dest; 7:DepTime; 11:ArrDelay; 12: Cancelled (0 - based)
            if (tokens[0].compareToIgnoreCase("FlightDate") == 0) {
                // Header
                return;
            }
            String fdate = tokens[0];
            if (fdate.substring(0, 4).compareTo("2008") != 0) {
                // Only 2008
                return;
            }
            Double cancelled = (tokens[12].isEmpty() ? 0 : Double.parseDouble(tokens[12]));
            if (cancelled >= 1) {
                // Don't count cancelled flight
                return;
            }

            String carrier = tokens[2];
            String fNum = tokens[3];
            String airport = tokens[4];
            String dest = tokens[5];
            String depTime = tokens[7];
            Double arrDelay = (tokens[11].isEmpty() ? 0 : Double.parseDouble(tokens[11]));
            String tripID = "1";        // Afternoon or the second trip
            if (depTime.trim().compareTo("1200") <= 0) {
                // Could be the first trip (ID=0)
                tripID = "0";           // Morning or the first trip
            }

            String airportDest = airport + delimiters + dest + delimiters + fdate + delimiters + tripID;
            String countValue = carrier + fNum + delimiters + depTime + delimiters + arrDelay.toString();
            context.write(new Text(airportDest), new Text(countValue));
        }
    }

    public static class DelayCountReduce extends Reducer<Text, Text, Text, Text> {
        @Override
        public void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
            // TODO
            // key = "airport", "dest", "fdate", "tripID(0|1)"
            String keys = key.toString();
            String[] tokey = keys.split(",");
            String airport = tokey[0];
            String dest = tokey[1];
            String fdate = tokey[2];
            String tripID = tokey[3];

            // values = "carrier&fNum", "depTime", "arrDelay"
            String fNum = "", depTime = "";
            Double minArrDelay = 6000.0;      // Big enough
            for (Text val : values) {
                String strings = val.toString();
                String[] tovalue = strings.split(",");
                Double nDelay = Double.parseDouble(tovalue[2]);
                if (nDelay < minArrDelay) {
                    minArrDelay = nDelay;
                    fNum = tovalue[0];
                    depTime = tovalue[1];
                }
            }

            if (minArrDelay < 6000.0) {
                Integer intValue = minArrDelay.intValue();
                String airportDest = airport + delimiters + dest + delimiters + fdate + delimiters + tripID;
                String countValue = fNum + delimiters + depTime + delimiters + intValue.toString();
                context.write(new Text(airportDest), new Text(countValue));
            }
        }
    }

    public static class TopHopFlightsMap extends Mapper<Text, Text, Text, Text> {
        Integer N;
        //private Text thePerformance = new Text();
        //private WritableIntPair pair = new WritableIntPair();

        // TODO
        @Override
        protected void setup(Context context) throws IOException,InterruptedException {
            Configuration conf = context.getConfiguration();
            this.N = conf.getInt("N", 1);
        }

        @Override
        public void map(Text key, Text value, Context context) throws IOException, InterruptedException {
            // TODO
            // key = "airport", "dest", "fdate", "tripID(0|1)"
            String keys = key.toString();
            String[] tokey = keys.split(",");
            String airport = tokey[0];
            String dest = tokey[1];
            String fdate = tokey[2];
            String tripID = tokey[3];

            // value = "fNum", "depTime", "arrDelay"
            String[] strings = value.toString().split(",");
            String midWay = "";
            String fNum = strings[0];
            String depTime = strings[1];
            Integer arrDelay = Integer.parseInt(strings[2]);

            String countValue = tripID + delimiters + fNum + delimiters + depTime + delimiters + arrDelay.toString() + delimiters;
            Integer flag = Integer.parseInt(tripID);
            if (flag == 0) {
                //pair.setKey(dest);          // destination airport is Y for the first trip
                midWay = dest + delimiters + fdate;
                countValue += airport;      // X
            }
            else {
                //pair.setKey(airport);       // original airport is Y for the second trip
                // should only match the date of two days before
                try {
                    SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
                    Date date2 = simpleDateFormat.parse(fdate);
                    Date date1 = new Date(date2.getTime() - 1000 * 60 * 60 * 24 * 2);
                    midWay = airport + delimiters + simpleDateFormat.format(date1);
                    countValue += dest;         // Z
                } catch(ParseException ex) {
                    theLogger.warn("TopHopFlightsMap unreported exception ParseException");
                }
            }
            //pair.setLabel(tripID);
            //pair.setData(arrDelay);
            //thePerformance.set(countValue);

            context.write(new Text(midWay), new Text(countValue));
        }
    }

    public static class TopHopFlightsReduce extends Reducer<Text, Text, Text, Text> {
        Integer N;
        List<String> valList = new ArrayList<String>();

        // TODO
        @Override
        protected void setup(Context context) throws IOException,InterruptedException {
            Configuration conf = context.getConfiguration();
            this.N = conf.getInt("N", 1);
        }

        @Override
        public void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
            // TODO
            // values = flight list where the key is the midway airport & date
            //SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
            //SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
            String keys = key.toString();
            String[] tokey = keys.split(",");
            String airport = tokey[0];
            String fDate = tokey[1];

            // For multiple iteration
            valList.clear();
            for (Text val : values) {
                valList.add(val.toString());
            }

            for(String inVal : valList){
                // val = tripID,fNum,depTime,arrDelay,X/Z airport;
                String[] inLeg = inVal.split(",");
                Integer flag = Integer.parseInt(inLeg[0]);
                if (flag == 0) {    // in-leg: first trip
                    for(String outVal : valList){
                        String[] outLeg = outVal.split(",");
                        Integer flag2 = Integer.parseInt(outLeg[0]);
                        //if (flag2 == 1 && outLeg[4].compareTo(inLeg[4]) != 0) {
                        if (flag2 == 1) {
                            // Found a In-leg & Out-leg pair (different airport)
                            // The date of outleg should be two days after the first leg
                            //try {
                                //Date date1 = simpleDateFormat.parse(fDate);
                                String newDateFmt = fDate.substring(8) + "/" + fDate.substring(5, 7) + "/"+ fDate.substring(0, 4);
                                String trip = inLeg[4] + delimiters + airport.toString() + delimiters + outLeg[4] + delimiters + newDateFmt;               // sdf.format(date1);
                                String desc = inLeg[1] + delimiters + inLeg[2] + delimiters + inLeg[3] + delimiters + outLeg[1] + delimiters + outLeg[2] + delimiters + outLeg[3];
                                context.write(new Text(trip), new Text(desc));
                            //} catch(ParseException ex) {
                            //    theLogger.warn("TopHopFlightsReduce unreported exception ParseException");
                            //}
                        }
                    }
                }
            }
        }
    }

}

// >>> Don't Change
class Pair<A extends Comparable<? super A>,
        B extends Comparable<? super B>>
        implements Comparable<Pair<A, B>> {

    public final A first;
    public final B second;

    public Pair(A first, B second) {
        this.first = first;
        this.second = second;
    }

    public static <A extends Comparable<? super A>,
            B extends Comparable<? super B>>
    Pair<A, B> of(A first, B second) {
        return new Pair<A, B>(first, second);
    }

    @Override
    public int compareTo(Pair<A, B> o) {
        int cmp = o == null ? 1 : (this.first).compareTo(o.first);
        return cmp == 0 ? (this.second).compareTo(o.second) : cmp;
    }

    @Override
    public int hashCode() {
        return 31 * hashcode(first) + hashcode(second);
    }

    private static int hashcode(Object o) {
        return o == null ? 0 : o.hashCode();
    }

    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof Pair))
            return false;
        if (this == obj)
            return true;
        return equal(first, ((Pair<?, ?>) obj).first)
                && equal(second, ((Pair<?, ?>) obj).second);
    }

    private boolean equal(Object o1, Object o2) {
        return o1 == o2 || (o1 != null && o1.equals(o2));
    }

    @Override
    public String toString() {
        return "(" + first + ", " + second + ')';
    }
}

// Writable Pair
class WritableIntPair
        implements Writable, WritableComparable<WritableIntPair> {

    private Text key = new Text();
    private Text label = new Text();
    private IntWritable data = new IntWritable();

    public WritableIntPair() {
    }

    public WritableIntPair(String key, String label, int data) {
        this.key.set(key);
        this.label.set(label);
        this.data.set(data);
    }

    public static WritableIntPair read(DataInput in) throws IOException {
        WritableIntPair pair = new WritableIntPair();
        pair.readFields(in);
        return pair;
    }

    @Override
    public void write(DataOutput out) throws IOException {
        key.write(out);
        label.write(out);
        data.write(out);
    }

    @Override
    public void readFields(DataInput in) throws IOException {
        key.readFields(in);
        label.readFields(in);
        data.readFields(in);
    }

    @Override
    public int compareTo(WritableIntPair pair) {
        int compareValue = this.key.compareTo(pair.getKey());
        if (compareValue == 0) {
            compareValue = data.compareTo(pair.getData());
        }
        //return compareValue; 		// to sort ascending
        return -1*compareValue;     // to sort descending
    }

    public Text getKeyLabel() {
        return new Text(key.toString()+label.toString());
    }

    public Text getKey() {
        return key;
    }

    public Text getLabel() {
        return label;
    }

    public IntWritable getData() {
        return data;
    }

    public void setKey(String keyAsString) {
        key.set(keyAsString);
    }

    public void setLabel(String labelAsString) {
        label.set(labelAsString);
    }

    public void setData(int dataAsInt) {
        data.set(dataAsInt);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        WritableIntPair that = (WritableIntPair) o;
        if (data != null ? !data.equals(that.data) : that.data != null) {
            return false;
        }
        if (key != null ? !key.equals(that.key) : that.key != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = key != null ? key.hashCode() : 0;
        result = 31 * result + (data != null ? data.hashCode() : 0);
        return result;
    }

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("WritableIntPair{key=");
        builder.append(key);
        builder.append(", label=");
        builder.append(label);
        builder.append(", data=");
        builder.append(data);
        builder.append("}");
        return builder.toString();
    }
}
// <<< Don't Change
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
import java.util.*;
import java.util.Arrays;
import java.util.List;
import java.util.TreeSet;

// >>> Don't Change
public class TopAirportAirport extends Configured implements Tool {

    private static Logger theLogger = Logger.getLogger(TopAirportAirport.class);

    public static void main(String[] args) throws Exception {
        // Make sure there are exactly 2 parameters
        if (args.length < 2) {
            theLogger.warn("TopAirportAirport <input-dir> <output-dir>");
            throw new IllegalArgumentException("TopAirportAirport <input-dir> <output-dir>");
        }

        int res = ToolRunner.run(new Configuration(), new TopAirportAirport(), args);
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

        FileInputFormat.setInputPaths(jobA, new Path(args[0]));
        FileOutputFormat.setOutputPath(jobA, tmpPath);

        jobA.setJarByClass(TopAirportAirport.class);
        jobA.waitForCompletion(true);

        Job jobB = Job.getInstance(conf, "Top Ontime Destination Airports");
        jobB.setOutputKeyClass(Text.class);
        jobB.setOutputValueClass(Text.class);

        jobB.setMapOutputKeyClass(WritableIntPair.class);
        jobB.setMapOutputValueClass(Text.class);

        jobB.setMapperClass(TopAirportAirportMap.class);
        jobB.setReducerClass(TopAirportAirportReduce.class);
        jobB.setPartitionerClass(CustPartitioner.class);
        jobB.setGroupingComparatorClass(CustGroupingComparator.class);
        //jobB.setNumReduceTasks(1);

        FileInputFormat.setInputPaths(jobB, tmpPath);
        FileOutputFormat.setOutputPath(jobB, new Path(args[1]));

        jobB.setInputFormatClass(KeyValueTextInputFormat.class);
        jobB.setOutputFormatClass(TextOutputFormat.class);

        jobB.setJarByClass(TopAirportAirport.class);
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
        String delimiters = ",";

        @Override
        protected void setup(Context context) throws IOException,InterruptedException {

            Configuration conf = context.getConfiguration();
        }


        @Override
        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            // TODO
            String line = value.toString();
            String[] tokens = line.split(delimiters);

            // 4: Origin; 5:Dest; 8:DepDelay; 12: Cancelled (0 - based)
            if (tokens[0].compareToIgnoreCase("FlightDate") == 0) {
                // Header
                return;
            }

            String airport = tokens[4];
            String dest = tokens[5];
            Double depDelay = (tokens[8].isEmpty() ? 0 : Double.parseDouble(tokens[8]));
            Double cancelled = (tokens[12].isEmpty() ? 0 : Double.parseDouble(tokens[12]));
            String airportDest = airport + delimiters + dest;
            String countValue = "1,0";

            if (depDelay > 15 || cancelled >= 1) {
                // delay > 15 min or cancelled
                //String[] strings = {"0", "1"};
                //TextArrayWritable val = new TextArrayWritable(strings);
                //context.write(theKey, val);
                countValue = "0,1";
            }
            context.write(new Text(airportDest), new Text(countValue));
        }
    }

    public static class DelayCountReduce extends Reducer<Text, Text, Text, Text> {
        @Override
        public void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
            // TODO
            // key = "airport", "dest"
            String keys = key.toString();
            String[] tokey = keys.split(",");
            String airport = tokey[0];
            String dest = tokey[1];

            // values = "normalcount", "delaycount"
            Integer sumNormal = 0;
            Integer sumDelay = 0;
            for (Text val : values) {
                String strings = val.toString();
                String[] tovalue = strings.split(",");
                Integer countNormal = Integer.parseInt(tovalue[0]);
                Integer countDelay = Integer.parseInt(tovalue[1]);
                sumNormal += countNormal;
                sumDelay += countDelay;
            }

            StringBuilder builder = new StringBuilder();
            builder.append(dest);
            builder.append(",");
            builder.append(sumNormal.toString());
            builder.append(",");
            builder.append(sumDelay.toString());
            context.write(new Text(airport), new Text(builder.toString()));
        }
    }

    public static class TopAirportAirportMap extends Mapper<Text, Text, WritableIntPair, Text> {
        Integer N;
        private Text thePerformance = new Text();
        private WritableIntPair pair = new WritableIntPair();

        // TODO
        @Override
        protected void setup(Context context) throws IOException,InterruptedException {
            Configuration conf = context.getConfiguration();
            this.N = conf.getInt("N", 10);
        }

        @Override
        public void map(Text key, Text value, Context context) throws IOException, InterruptedException {
            // TODO
            String airport = key.toString();
            // value = "dest", "normalcount", "delaycount"
            String[] strings = value.toString().split(",");
            String dest = strings[0];
            Integer countNormal = Integer.parseInt(strings[1]);
            Integer countDelay = Integer.parseInt(strings[2]);
            Double dblRate = countNormal * 10000d / (countNormal + countDelay);
            Integer nRate = (int)(dblRate + 0.5);

            String perform = String.format("%s(%5.2f%%)", dest, nRate/100d);
            thePerformance.set(perform);
            pair.setKey(airport);
            pair.setLabel(dest);
            pair.setData(nRate);

            context.write(pair, thePerformance);
        }
    }

    public static class TopAirportAirportReduce extends Reducer<WritableIntPair, Text, Text, Text> {
        Integer N;
        // TODO
        @Override
        protected void setup(Context context) throws IOException,InterruptedException {
            Configuration conf = context.getConfiguration();
            this.N = conf.getInt("N", 10);
        }

        @Override
        public void reduce(WritableIntPair key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
            // TODO
            // values = ordered destination airport list
            StringBuilder builder = new StringBuilder();
            int index = 0;
            for (Text val : values) {
                builder.append(val.toString());
                builder.append(",");
                if (++index >= this.N)
                    break;
            }
            context.write(key.getKey(), new Text(builder.toString()));
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
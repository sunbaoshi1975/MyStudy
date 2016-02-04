import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.ArrayWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.KeyValueTextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.*;

public class PopularityLeague extends Configured implements Tool {

    public static void main(String[] args) throws Exception {
        int res = ToolRunner.run(new Configuration(), new PopularityLeague(), args);
        System.exit(res);
    }

    @Override
    public int run(String[] args) throws Exception {
        // TODO
        Configuration conf = this.getConf();
        FileSystem fs = FileSystem.get(conf);
        Path tmpPath = new Path("/mp2/tmp");
        fs.delete(tmpPath, true);

        Job jobA = Job.getInstance(conf, "Link Count");
        jobA.setOutputKeyClass(IntWritable.class);
        jobA.setOutputValueClass(IntWritable.class);

        jobA.setMapOutputKeyClass(IntWritable.class);
        jobA.setMapOutputValueClass(IntWritable.class);
        
        jobA.setMapperClass(LinkCountMap.class);
        jobA.setReducerClass(LinkCountReduce.class);

        FileInputFormat.setInputPaths(jobA, new Path(args[0]));
        FileOutputFormat.setOutputPath(jobA, tmpPath);

        jobA.setJarByClass(PopularityLeague.class);
        jobA.waitForCompletion(true);

        Job jobB = Job.getInstance(conf, "League Rank");
        jobB.setOutputKeyClass(IntWritable.class);
        jobB.setOutputValueClass(IntWritable.class);

        jobB.setMapOutputKeyClass(NullWritable.class);
        jobB.setMapOutputValueClass(IntArrayWritable.class);

        jobB.setMapperClass(LeagueRankMap.class);
        jobB.setReducerClass(LeagueRankReduce.class);
        jobB.setNumReduceTasks(1);

        FileInputFormat.setInputPaths(jobB, tmpPath);
        FileOutputFormat.setOutputPath(jobB, new Path(args[1]));

        jobB.setInputFormatClass(KeyValueTextInputFormat.class);
        jobB.setOutputFormatClass(TextOutputFormat.class);

        jobB.setJarByClass(PopularityLeague.class);
        return jobB.waitForCompletion(true) ? 0 : 1;
    }

    // TODO
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
    
    public static class IntArrayWritable extends ArrayWritable {
        public IntArrayWritable() {
            super(IntWritable.class);
        }

        public IntArrayWritable(Integer[] numbers) {
            super(IntWritable.class);
            IntWritable[] ints = new IntWritable[numbers.length];
            for (int i = 0; i < numbers.length; i++) {
                ints[i] = new IntWritable(numbers[i]);
            }
            set(ints);
        }
    }
    
    public static class LinkCountMap extends Mapper<Object, Text, IntWritable, IntWritable> {
        public static final Log log = LogFactory.getLog(LinkCountMap.class);
        List<Integer> league = new ArrayList<>();

        @Override
        protected void setup(Context context) throws IOException,InterruptedException {

            Configuration conf = context.getConfiguration();
            String leaguePath = conf.get("league");

            String leagueFile = readHDFSFile(leaguePath, conf);
            //StringTokenizer tokenizer = new StringTokenizer(leagueFile, " \n\t,;.?!-:@[](){}_*/");
            StringTokenizer tokenizer = new StringTokenizer(leagueFile, "\n");
            while (tokenizer.hasMoreTokens()) {
                String nextToken = tokenizer.nextToken();
                Integer link = Integer.parseInt(nextToken.trim());
                if (link > 0)
                    this.league.add(link);
            }
            
            // write Hadoop log
            log.info("leagueCount: " + this.league.size());
        }

        @Override
        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            String line = value.toString();
            StringTokenizer tokenizer = new StringTokenizer(line, ":");
            if (tokenizer.hasMoreTokens()) {
                String nextToken = tokenizer.nextToken();
                Integer fromPage = Integer.parseInt(nextToken);
                if (this.league.contains(fromPage)) {
                    context.write(new IntWritable(fromPage), new IntWritable(0));
                }
                
                if (tokenizer.hasMoreTokens()) {
                    nextToken = tokenizer.nextToken().trim();
                    StringTokenizer token2 = new StringTokenizer(nextToken, " ");
                    while (token2.hasMoreTokens()) {
                        String nextT2 = token2.nextToken();
                        Integer toPage = Integer.parseInt(nextT2.trim());
                        if (toPage > 0) {
                            if (this.league.contains(toPage)) {
                                context.write(new IntWritable(toPage), new IntWritable(1));
                            }
                        }
                    }
                }
            }
        }
    }        

    public static class LinkCountReduce extends Reducer<IntWritable, IntWritable, IntWritable, IntWritable> {
        @Override
        public void reduce(IntWritable key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
            int sum = 0;
            for (IntWritable val : values) {
                sum += val.get();
            }
            context.write(key, new IntWritable(sum));
        }
    }

    public static class LeagueRankMap extends Mapper<Text, Text, NullWritable, IntArrayWritable> {
        private List<List> linkToCountList = new ArrayList<>();
    
        @Override
        protected void setup(Context context) throws IOException,InterruptedException {
            //Configuration conf = context.getConfiguration();
        }
        
        @Override
        public void map(Text key, Text value, Context context) throws IOException, InterruptedException {
            Integer count = Integer.parseInt(value.toString());
            Integer link = Integer.parseInt(key.toString());
            
            List<Integer> item = new ArrayList<>();
            item.add(link);
            item.add(count);
            linkToCountList.add(item);
        }

        @Override
        protected void cleanup(Context context) throws IOException, InterruptedException {
            for (List<Integer> item : linkToCountList) {
                Integer[] integers = {item.get(0), item.get(1)};
                IntArrayWritable val = new IntArrayWritable(integers);
                context.write(NullWritable.get(), val);
            }
        }
    }

    public static class LeagueRankReduce extends Reducer<NullWritable, IntArrayWritable, IntWritable, IntWritable> {
        private List<List> linkToCountList = new ArrayList<>();

        @Override
        protected void setup(Context context) throws IOException,InterruptedException {
            //Configuration conf = context.getConfiguration();
        }

        public void reduce(NullWritable key, Iterable<IntArrayWritable> values, Context context) throws IOException, InterruptedException {
            for (IntArrayWritable val : values) {
                IntWritable[] pair = (IntWritable[]) val.toArray();
                
                Integer link = (Integer)(pair[0].get());
                Integer count = (Integer)(pair[1].get());
                
                List<Integer> item = new ArrayList<>();
                item.add(link);
                item.add(count);
                linkToCountList.add(item);
            }

            for (List<Integer> itemA : linkToCountList) {
                Integer nPopuparity = itemA.get(1);
                int nRank = 0;
                for (List<Integer> itemB : linkToCountList) {
                    if (nPopuparity > itemB.get(1))
                        nRank++;
                }
                IntWritable link = new IntWritable(itemA.get(0));
                IntWritable rank = new IntWritable(nRank);
                context.write(link, rank);
            }
        }
    }
}
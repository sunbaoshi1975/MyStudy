#
# This is a simple makefile to assist with quickly building the Exercises of MP2.
#
# To build and execute a particular exercise:
#    - For a single exercise, type 'make runA' to run exercise A.
#    - For all exercises, 'make'.
#
#
HADOOP_CLASSPATH := ${JAVA_HOME}/lib/tools.jar
export HADOOP_CLASSPATH

OBJDIR=build

JAR := MP2.jar
TARGETS := $(addprefix run, A B C D E F)

.PHONY: final $(TARGETS) clean

final: $(TARGETS)

runA: $(OBJDIR)/TitleCount.class
	jar -cvf $(JAR) -C $(OBJDIR)/ ./
	hadoop fs -rm -r -f /mp2/A-output/
	hadoop jar $(JAR) TitleCount -D stopwords=/mp2/misc/stopwords.txt -D delimiters=/mp2/misc/delimiters.txt /mp2/titles /mp2/A-output

runB: $(OBJDIR)/TopTitles.class
	jar -cvf $(JAR) -C $(OBJDIR)/ ./
	hadoop fs -rm -r -f /mp2/B-output/
	hadoop jar $(JAR) TopTitles -D stopwords=/mp2/misc/stopwords.txt -D delimiters=/mp2/misc/delimiters.txt -D N=5 /mp2/titles /mp2/B-output

runC: $(OBJDIR)/TopTitleStatistics.class
	jar -cvf $(JAR) -C $(OBJDIR)/ ./
	hadoop fs -rm -r -f /mp2/C-output/
	hadoop jar $(JAR) TopTitleStatistics -D stopwords=/mp2/misc/stopwords.txt -D delimiters=/mp2/misc/delimiters.txt -D N=5 /mp2/titles /mp2/C-output

runD: $(OBJDIR)/OrphanPages.class
	jar -cvf $(JAR) -C $(OBJDIR)/ ./
	hadoop fs -rm -r -f /mp2/D-output/
	hadoop jar $(JAR) OrphanPages /mp2/links /mp2/D-output

runE: $(OBJDIR)/TopPopularLinks.class
	jar -cvf $(JAR) -C $(OBJDIR)/ ./
	hadoop fs -rm -r -f /mp2/E-output/
	hadoop jar $(JAR) TopPopularLinks -D N=5 /mp2/links/mp2/E-output

runF: $(OBJDIR)/PopularityLeague.class
	jar -cvf $(JAR) -C $(OBJDIR)/ ./
	hadoop fs -rm -r -f /mp2/F-output/
	hadoop jar $(JAR) PopularityLeague -D league=/mp2/misc/league.txt /mp2/links /mp2/F-output

$(OBJDIR)/%.class: %.java | $(OBJDIR)
	hadoop com.sun.tools.javac.Main $< -d $(OBJDIR)

$(OBJDIR):
	mkdir $@

.PHONY: clean
clean:
	rm -f $(OBJDIR)/* $(JAR)
	hadoop fs -rm -r -f /mp2/*-output/
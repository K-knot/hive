FROM centos:7

ARG java_version="1.8.0"
ARG hadoop_version="3.2.2"
ARG hive_version="3.1.2"

RUN yum -y upgrade
RUN yum -y groupinstall 'Development tools'
RUN yum -y install wget

RUN yum -y install java-${java_version}-openjdk
RUN mv $(rpm -ql java-${java_version}-openjdk | grep jre | head -n 1 | sed 's/\/jre.*//') /usr/lib/jvm/java-${java_version}
ENV JAVA_HOME /usr/lib/jvm/java-${java_version}/jre

RUN wget https://dlcdn.apache.org/hadoop/common/hadoop-${hadoop_version}/hadoop-${hadoop_version}.tar.gz
RUN mv hadoop-${hadoop_version}.tar.gz /tmp/
RUN tar -xzvf /tmp/hadoop-${hadoop_version}.tar.gz -C /usr/
ENV HADOOP_HOME /usr/hadoop-${hadoop_version}
ENV PATH $HADOOP_HOME/bin:$HADOOP_HOME/sbin:$JAVA_HOME/bin:$PATH

RUN wget http://ftp.riken.jp/net/apache/db/derby/db-derby-10.14.2.0/db-derby-10.14.2.0-bin.tar.gz
RUN mv db-derby-10.14.2.0-bin.tar.gz /tmp/
RUN tar -xzvf /tmp/db-derby-10.14.2.0-bin.tar.gz -C /tmp/
RUN mv /tmp/db-derby-10.14.2.0-bin /usr/derby
ENV DERBY_HOME /usr/derby
ENV PATH $PATH:$DERBY_HOME/bin
ENV CLASSPATH $CLASSPATH:$DERBY_HOME/lib/derby.jar:$DERBY_HOME/lib/derbytools.jar

RUN wget https://dlcdn.apache.org/hive/hive-${hive_version}/apache-hive-${hive_version}-bin.tar.gz
RUN mv apache-hive-${hive_version}-bin.tar.gz /tmp/
RUN tar -xzvf /tmp/apache-hive-${hive_version}-bin.tar.gz -C /tmp/
RUN mv /tmp/apache-hive-${hive_version}-bin /usr/hive-${hive_version}
RUN cp /usr/hive-${hive_version}/conf/hive-default.xml.template /usr/hive-${hive_version}/conf/hive-site.xml
ENV HIVE_HOME /usr/hive-${hive_version}
ENV PATH $PATH:$HIVE_HOME/bin

RUN echo "Delete some sentence to avoid errors"
RUN sed -i -e 's/&#8;//' /usr/hive-${hive_version}/conf/hive-site.xml
RUN echo "Add Configuration"
RUN sed -i -e 's/<\/configuration>//' /usr/hive-${hive_version}/conf/hive-site.xml
COPY hive-site.xml /tmp/hive-template
RUN cat /tmp/hive-template >> /usr/hive-${hive_version}/conf/hive-site.xml
RUN cp /usr/hadoop-${hadoop_version}/share/hadoop/hdfs/lib/guava-27.0-jre.jar /usr/hive-${hive_version}/lib/
RUN rm -f /usr/hive-${hive_version}/lib/guava-19.0.jar
RUN $HIVE_HOME/bin/schematool -dbType derby -initSchema

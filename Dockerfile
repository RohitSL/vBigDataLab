FROM centos:7
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
ENTRYPOINT ["/usr/sbin/init"]
MAINTAINER Rohit <rohitsabharwal@hotmail.com>


RUN yum update -y
RUN yum install -y java-1.8.0-openjdk
RUN yum install -y which
RUN yum install -y wget
RUN yum install -y openssh-server
RUN yum install -y openssh-clients

COPY inputfiles/* /tmp/

#Installing Hadoop Remote
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.2.0/hadoop-3.2.0.tar.gz -P ~/Downloads
RUN tar zxvf ~/Downloads/hadoop-3.2.0.tar.gz  -C /usr/local
RUN ln -sd /usr/local/hadoop-3.2.0 /usr/local/hadoop
RUN rm ~/Downloads/hadoop-3.2.0.tar.gz

RUN mkdir /var/hadoop
RUN mkdir /var/hadoop/tmp
RUN mkdir /var/hadoop/tmp/hive
#Setting write permissions on folders
RUN chmod 0777 /var/hadoop/tmp/hive
RUN chmod 0777 /var/hadoop/tmp
RUN chmod 0777 /var/hadoop

#Installing scala
RUN wget https://scala-lang.org/files/archive/scala-2.13.0.rpm -P ~/Downloads
RUN yum install -y ~/Downloads/scala-2.13.0.rpm
RUN rm ~/Downloads/scala-2.13.0.rpm

#Installing spark
RUN wget https://www-us.apache.org/dist/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz -P ~/Downloads
RUN tar zxvf ~/Downloads/spark-2.4.4-bin-hadoop2.7.tgz  -C /usr/local
RUN ln -sd /usr/local/spark-2.4.4-bin-hadoop2.7 /usr/local/spark
RUN rm ~/Downloads/spark-2.4.4-bin-hadoop2.7.tgz

#Installing zeppelin
RUN wget http://archive.apache.org/dist/zeppelin/zeppelin-0.8.1/zeppelin-0.8.1-bin-all.tgz -P ~/Downloads
RUN tar zxvf ~/Downloads/zeppelin-0.8.1-bin-all.tgz  -C /usr/local
RUN ln -sd /usr/local/zeppelin-0.8.1-bin-all /usr/local/zeppelin
RUN rm ~/Downloads/zeppelin-0.8.1-bin-all.tgz

#Environment configs
#Ports
ENV ZEPPELIN_PORT 3000
ENV ZEPPELIN_HOME /usr/local/zeppelin

ENV  JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.222.b10-1.el7_7.x86_64/jre
ENV  PATH $PATH:$JAVA_HOME/bin

ENV  HADOOP_HOME /usr/local/hadoop
ENV  PATH $PATH:$HADOOP_HOME/bin
ENV  HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop

ENV  PATH=$PATH:/usr/local/spark/bin
ENV  SPARK_HOME /usr/local/spark

#Generating SSH keys
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mv /tmp/ssh_config ~/.ssh/config
#Copying hadoop configs
RUN cp /tmp/core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
RUN cp /tmp/mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
RUN cp /tmp/hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
RUN cp /tmp/yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml
RUN cp /tmp/masters /usr/local/hadoop/etc/hadoop/masters
RUN cp /tmp/slaves /usr/local/hadoop/etc/hadoop/slaves

RUN cp /tmp/zeppelin-site.xml /usr/local/zeppelin/conf/zeppelin-site.xml
RUN cp /tmp/zeppelin-env.sh /usr/local/zeppelin/conf/zeppelin-env.sh
RUN cp /tmp/shiro.ini /usr/local/zeppelin/conf/shiro.ini


RUN cp /tmp/core-site.xml /usr/local/spark/conf/core-site.xml
RUN cp /tmp/mapred-site.xml /usr/local/spark/conf/mapred-site.xml
RUN cp /tmp/hdfs-site.xml /usr/local/spark/conf/hdfs-site.xml
RUN cp /tmp/yarn-site.xml /usr/local/spark/conf/yarn-site.xml
RUN cp /tmp/masters /usr/local/spark/conf/masters
RUN cp /tmp/slaves /usr/local/spark/conf/slaves

RUN /tmp/env.sh
#Starting SSH
WORKDIR /usr/local
CMD [ "sh", "-c", "service ssh start; bash"]

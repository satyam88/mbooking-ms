FROM tomcat:9.0.52-jre11-openjdk-slim

# Install dependencies and Java 21 from Adoptium
RUN apt-get update && \
    apt-get install -y wget tar ca-certificates && \
    mkdir -p /opt/java && \
    wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.6%2B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.6_7.tar.gz -O /tmp/java21.tar.gz && \
    tar -xzf /tmp/java21.tar.gz -C /opt/java && \
    rm /tmp/java21.tar.gz && \
    ln -s /opt/java/jdk-21.0.6+7 /opt/java/latest

# Set JAVA_HOME and update PATH
ENV JAVA_HOME=/opt/java/latest
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Set Java 21 as the default
RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 1 && \
    update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 1 && \
    update-alternatives --set java $JAVA_HOME/bin/java && \
    update-alternatives --set javac $JAVA_HOME/bin/javac

# Create non-root user
RUN useradd -m mbooking-ms

# Copy the WAR file into the Tomcat webapps directory
COPY ./target/mbooking-ms*.war /usr/local/tomcat/webapps

# Fix permissions for non-root user
RUN chown -R mbooking-ms:mbooking-ms /usr/local/tomcat

# Switch to non-root user
USER mbooking-ms

# Set the working directory
WORKDIR /usr/local/tomcat/webapps

# Expose port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

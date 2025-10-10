# Tomcat 10.1 running on JDK 21 (Temurin)
FROM tomcat:10.1-jdk21-temurin

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR built by Maven to ROOT.war
# (Our GitHub Action runs "mvn -DskipTests package" first, so target/*.war exists)
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]

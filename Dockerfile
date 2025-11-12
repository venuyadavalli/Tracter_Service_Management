# Use the official Tomcat image with Java 17
FROM tomcat:9.0-jdk17

# Remove default ROOT app
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy your WAR file and rename it to ROOT.war
COPY TractorServiceTracker.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080 (Render uses this)
EXPOSE 8080

# Health check for Render
HEALTHCHECK CMD curl --fail http://localhost:8080/health.jsp || exit 1

# Start Tomcat
CMD ["catalina.sh", "run"]

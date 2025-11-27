FROM alpine:latest AS downloader

RUN apk add --no-cache ca-certificates wget tar

RUN wget -O /tomcat.tar.gz https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.14/bin/apache-tomcat-11.0.14.tar.gz

RUN mkdir /opt/tomcat

RUN tar xvzf tomcat.tar.gz --strip-components 1 --directory /opt/tomcat

RUN wget -O /structurizr-onpremises.war https://github.com/structurizr/onpremises/releases/download/v2025.11.09/structurizr-onpremises.war

FROM bellsoft/liberica-runtime-container:jre-21-glibc

ENV PORT=3000

RUN apk add --no-cache graphviz

COPY --from=downloader /opt/tomcat/ /opt/tomcat/

WORKDIR /opt/tomcat

ENV STRUCTURIZR_DATA_DIRECTORY=/usr/local/structurizr

COPY --from=downloader /structurizr-onpremises.war ./webapps/ROOT.war

RUN sed -i 's/port="8080"/port="${http.port}" maxPostSize="10485760"/' ./conf/server.xml \
    && echo 'export CATALINA_OPTS="-Xms512M -Xmx512M -Dhttp.port=$PORT"' > ./bin/setenv.sh

EXPOSE ${PORT}

CMD ["./bin/catalina.sh", "run"]
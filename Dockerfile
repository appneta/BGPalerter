FROM ubuntu

COPY install_nodejs.sh /app/install_nodejs.sh
RUN /app/install_nodejs.sh
WORKDIR /app


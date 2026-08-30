FROM swipl:stable

WORKDIR /app
COPY src /app/src
COPY web /app/web

ENV PORT=8080
EXPOSE 8080

CMD ["swipl", "-q", "--no-tty", "-s", "src/web_server.pl"]

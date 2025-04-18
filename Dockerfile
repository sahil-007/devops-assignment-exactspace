# Stage 1: Scraping
FROM node:18-slim as scraper

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Install Chromium
RUN apt-get update && \
    apt-get install -y chromium && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json .
RUN npm install

COPY scrape.js .

ENV SCRAPE_URL=https://example.com
RUN node scrape.js

# Stage 2: Python Flask Server
FROM python:3.10-slim

WORKDIR /app

COPY --from=scraper /app/scraped_data.json /app/
COPY server.py requirements.txt /app/

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

CMD ["python", "server.py"]

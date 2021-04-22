# BaseX Transformer
XML Transform service built on BaseX for transforming XML using XSLT via REST endpoints.

## Getting Started

Build and run the docker container image using:

```
docker build . --tag basex-transformer
docker run -p 1984:1984 -p 8984:8984 basex-transformer
```

You can then interact with the service on port 8984 for example using cURL...

Sending XML file:

```
curl -F xml=@test-xml-file.xml http://localhost:8984/v1tov2
```

Sending XML as string with `Content-Type: text/plain`:
```
curl -d "<?xml version=\"1.0\" encoding=\"UTF-8\"?><article article-type=\"article-commentary\" dtd-version=\"1.2\" xmlns:ali=\"http://www.niso.org/schemas/ali/1.0/\" xmlns:xlink=\"http://www.w3.org/1999/xlink\"><some-content /></article>" -H "Content-Type: text/plain" http://localhost:8984/v2tov1
```




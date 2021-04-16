# BaseX Transformer
XML Transform service built on BaseX for transforming XML using XSLT via REST endpoints.

## Getting Started

Build and run the docker container image using:

```
docker build . --tag basex-transformer
docker run -p 1984:1984 -p 8984:8984 basex-transformer
```

You can then interact with the service on port 8984 for example using cURL...

```
curl -F xml=@test-xml-file.xml http://localhost:8984/v1tov2
```


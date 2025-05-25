# aqualog

## backend

```bash
$ grpcurl -format text -d 'id: 23254' -plaintext localhost:50051  'marine.Catalogue.GetByID'
$ grpcurl -format text -d 'name: "turtle"' -plaintext 127.0.0.1:50051  'marine.Catalogue.GetByCommonName'
$ grpcurl -plaintext \
  -d '{
    "record": {
      "comments": "Great Barrier Reef"
    }
  }' \
  localhost:50051 \
  'records.Storage.CreateRecord'
```

## fishbase/sealifebase 

```bash
$ go install github.com/minio/mc@latest
$ mc alias set fishbase https://fishbase.ropensci.org
$ mc ls fishbase/sealifebase
$ mc get 'fishbase/sealifebase/comnames_all.parquet' comnames_all.parquet
$ duckdb
DESCRIBE SELECT * FROM 'comnames_all.parquet';
```

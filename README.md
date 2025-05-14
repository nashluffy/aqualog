# aqualog

## backend

```bash
$ grpcurl -format text -d 'id: 23254' -plaintext localhost:50051  'life.Life.GetByID'
$ grpcurl -format text -d 'name: "turtle"' -plaintext 127.0.0.1:50051  'life.Life.GetByCommonName'
```

## fishbase/sealifebase 

```bash
$ mc alias set fishbase https://fishbase.ropensci.org
$ mc ls fishbase/sealifebase
$ mc get 'fishbase/sealifebase/comnames_all.parquet' comnames_all.parquet
$ duckdb
DESCRIBE SELECT * FROM 'comnames_all.parquet';
```

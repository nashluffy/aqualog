# aqualog

## backend

```bash
$ grpcurl -format text -d 'id: 23254' -plaintext localhost:50051  'life.Life.GetByID'
$ grpcurl -format text -d 'name: "turtle"' -plaintext 127.0.0.1:50051  'life.Life.GetByCommonName'
```

## fishbase/sealifebase 

```bash
$ make deps
$ duckdb
DESCRIBE SELECT * FROM 'bin/comnames_all.parquet';
```

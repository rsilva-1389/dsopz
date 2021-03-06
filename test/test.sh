#!/bin/bash -xe

DS=${1:-cloudcontainerz}
NS=${2:-dsopz_test}

EF=target/dsopz_test

rm -rf "$EF" || true
mkdir -p "$EF"
python -m dsopz.dsopz 'export' -d "$DS" -n "$NS" -o true | python -m dsopz.dsopz 'import' -d "$DS" -n "$NS" -o remove

python -m dsopz.dsopz 'import' -d "$DS" -n "$NS" -o upsert < "test/entities.json"
python -m dsopz.dsopz 'export' -d "$DS" -n "$NS" > "$EF/bak.json"
diff test/entities.json "$EF/bak.json"

python -m dsopz.dsopz 'gql' -d "$DS" -n "$NS" -q "select * from dsopz_test order by c2" > "$EF/other.json"
if [ "x$(wc -l < $EF/other.json | tr -d ' ')" != "x0" ]; then
    echo "FAIL"
    exit 1
fi
python -m dsopz.dsopz 'index' -k "dsopz_test" -c c2 -i true > "$EF/processed.json" < "$EF/bak.json"
python -m dsopz.dsopz 'import' -d "$DS" -n "$NS" -o upsert < "$EF/processed.json"
python -m dsopz.dsopz 'gql' -d "$DS" -n "$NS" -q "select * from dsopz_test order by c2" > "$EF/other.json"
if [ "x$(wc -l < $EF/other.json | tr -d ' ')" != "x2" ]; then
    echo "FAIL"
    exit 1
fi

python -m dsopz.dsopz 'gql' -d "$DS" -n "$NS" -q "select * from dsopz_test order by c3" > "$EF/other.json"
if [ "x$(wc -l < $EF/other.json | tr -d ' ')" != "x0" ]; then
    echo "FAIL"
    exit 1
fi
python -m dsopz.dsopz 'index' -k "dsopz_test" -c c3 -i true > "$EF/processed.json" < "$EF/bak.json"
python -m dsopz.dsopz 'import' -d "$DS" -n "$NS" -o upsert < "$EF/processed.json"
python -m dsopz.dsopz 'gql' -d "$DS" -n "$NS" -q "select * from dsopz_test where c3 = 'a1'" > "$EF/other.json"
if [ "x$(wc -l < $EF/other.json | tr -d ' ')" != "x2" ]; then
    echo "FAIL"
    exit 1
fi
python -m dsopz.dsopz 'gql' -d "$DS" -n "$NS" -q "select * from dsopz_test where c3 = 'a2'" > "$EF/other.json"
if [ "x$(wc -l < $EF/other.json | tr -d ' ')" != "x1" ]; then
    echo "FAIL"
    exit 1
fi
python -m dsopz.dsopz 'gql' -d "$DS" -n "$NS" -q "select * from dsopz_test where c3 = 'a3'" > "$EF/other.json"
if [ "x$(wc -l < $EF/other.json | tr -d ' ')" != "x1" ]; then
    echo "FAIL"
    exit 1
fi


echo "SUCCESS"

python -m dsopz.dsopz 'export' -d "$DS" -n "$NS" -o true | python -m dsopz.dsopz 'import' -d "$DS" -n "$NS" -o remove

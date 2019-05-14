#/bin/bash

SRC_DIR="$1"

files=($(grep -rlI "import .*'\.\." $SRC_DIR))

for file in "${files[@]}"
do
  old_ifs=${IFS}
  IFS="
"
  imports=($(grep "import .*'\.\." "$file"))
  IFS=${old_ifs}

  echo "file: $file"
  echo "imports: "
  file_location=$(dirname "$file")
  for import in "${imports[@]}"
  do
    clean_import=$(echo "$import" | sed "s/.*from '//" | sed "s/\(.*\)\/.*'/\1/")
    import_loc=$(cd "$file_location/$clean_import";pwd | sed "s/.*src\///")
    old_safe_import=$(echo "$import" | sed "s~/~\\\/~g" | sed "s/\./\\\./g")
    replace_with=$(echo "$import" | sed "s~\(.*\)\'.*\(\/.*\)~\1'$import_loc\2~")

    echo "  import: $import"
    echo "  clean_import: $clean_import"
    echo "  import_loc: $import_loc"
    echo "  old_safe_import: $old_safe_import"
    echo "  replace_with: $replace_with"
    sed -i '' "s~$old_safe_import~$replace_with~" "$file"
  done
done

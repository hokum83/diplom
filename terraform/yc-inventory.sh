#!/bin/bash

#Ключ тега по-умолчанию
tkey="type"

while getopts ":k:" flag; do
  case "${flag}" in
  k) tkey=${OPTARG} ;;
  ?) 2>/dev/null ;;
  esac
done

yc_list() {
  yc compute instance list --format json
}

#Сбор массива из значений ключа тега
tvals=$(
  yc_list |
    jq --arg k $tkey '.[].labels | select(has($k)) | .[]' |
    uniq | sed 's/"//g' | tr '\n' ' ' | sed 's/[[:blank:]]*$//'
)

#Вывод ВМ, входящих в группы
print_group_hosts() {
  echo "  \"$tval\": {"
  echo "    \"hosts\": ["
  yc_list |
    jq --arg k "$tkey" --arg v "$tval" '.[] | select(.labels | has($k) and (.[]==$v)) | .fqdn' |
    sed '$!s/$/,/;s/^/      /'
  echo "    ]"
  echo "  }"
}

#Вывод ВМ, не входящих в группы массива
print_ungrouped_hosts() {
  echo "  \"hosts\": ["
  yc_list |
    jq --arg k "$tkey" '.[] | select(.labels | has($k) | not) | .fqdn' |
    sed '$!s/$/,/;s/^/      /'
  echo "  ]"
}

#Вывод всей инфы
print_all() {
  echo "{"
  for tval in $tvals; do
    print_group_hosts
  done
  print_ungrouped_hosts
  echo "}"
}

#Выводим, добавляем запятые
print_all | sed -z 's/}\n  "/},\n  "/g'

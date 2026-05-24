#!/usr/bin/env bash

name="jane doe"
name_fixed=""
for word in $name;do
    name_fixed+="${word^} "
done
name="${name_fixed% }"
echo "$name"

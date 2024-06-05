#!/bin/sh
 
LICENSE_FILE="LICENSE"
YEAR=$(date +"%Y")
GEMATIK_COPYRIGHT_STATEMENT_TEXT="Copyright (c) ${YEAR} gematik GmbH

Licensed under the EUPL, Version 1.2 or – as soon they will be approved by
the European Commission - subsequent versions of the EUPL (the "Licence");
You may not use this work except in compliance with the Licence.
You may obtain a copy of the Licence at:

    https://joinup.ec.europa.eu/software/page/eupl

Unless required by applicable law or agreed to in writing, software
distributed under the Licence is distributed on an \"AS IS\" basis,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the Licence for the specific language governing permissions and
limitations under the Licence.
"
if [ ! -f "${LICENSE_FILE}" ] || grep "EUPL" "${LICENSE_FILE}" -q ; then
  echo "$GEMATIK_COPYRIGHT_STATEMENT_TEXT" > ${LICENSE_FILE}
fi

for file in $(git grep -l GEMATIK_COPYRIGHT_STATEMENT)
do
    awk -F '\\$\\{GEMATIK_COPYRIGHT_STATEMENT\\}' "{if (\$0 ~ /(.*) \\$\{GEMATIK_COPYRIGHT_STATEMENT\}/) {while((getline line<\"${LICENSE_FILE}\")>0 ) {print \$1 line} close ("${LICENSE_FILE}")} else {print \$0}}"  "$file" > ./tempFile && mv ./tempFile "$file"
done

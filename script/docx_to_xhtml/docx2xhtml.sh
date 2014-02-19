#!/bin/bash

TMP_DIR=`mktemp -d --suffix=kreatio` || exit 1

echo $TMP_DIR

DOCX=$1

unzip "$DOCX" -d $TMP_DIR >/dev/null || exit 2

cp kr-docx2html.xslt $TMP_DIR

xsltproc $TMP_DIR/kr-docx2html.xslt $TMP_DIR/word/document.xml | tee $TMP_DIR/stage1.xhtml \
	|xsltproc finish-up.xslt - > $TMP_DIR/out.xhtml

exit $?

#!/bin/bash

lang="$1"
validLanguages="fr"
htmlDest="drgeoHtml"
infoDest="drgeoInfo"
textDest="drgeoText"
masterDoc="programmer-avec-drgeo.texinfo"


chapters="expandDrgeo handlingError introduction numbers geometry functions smalltalk syntax tools SmalltalkFigure Tools"

imgPath="./expandDrgeo/figures:./firstSketches/figures:./handlingError/figures:./introduction/figures:./numbers/figures:./geometry/figures:./functions/figures:./SmalltalkFigure/figures:./syntax/figures:./Tools/figures"

imgPath=""
for chapter in $chapters
do
   imgPath="$imgPath:./$chapter/figures"
done

function doPdf {
    cd $lang
    makeinfo -I $imgPath --pdf $masterDoc
    cd -
    clean_all
}

function doText {
    cleanupDestination $textDest
    cd $lang
    texi2any --output=$textDest/ --transliterate-file-names --split=node \
	     --no-number-sections --plaintext $masterDoc 
    cd -
}

function doInfo {
    prepareDestination $infoDest
    cd $lang
    makeinfo -I $imgPath --output=$infoDest/ $masterDoc
    cd -
}

function doHtml {
    prepareDestination $htmlDest
    cp ../userGuide/style.css $lang/$htmlDest
    cd $lang
    texi2any -I $imgPath --output=$htmlDest/ --html --css-ref=style.css $masterDoc
    cd -
}

function cleanupDestination {
    # Clean up dest $1
    cd $lang
    rm -rf "$1"
    mkdir "$1"
    cd -
}
function prepareDestination {
    # Clean up dest $1 and copy all bitmaps there
    cleanupDestination "$1"
    cd $lang
    for dir in $chapters
    do
	if [ -d $dir/figures ]; then
	    cp $dir/figures/*.png "$1"
   	    cp $dir/figures/*.jpg "$1"
	fi
    done
    cp ./figures/*.png "$1"
    cd -
}

function package_html {
    doHtml
    cd $lang/$drgeoHtml
    tar cfz ../drgeo-html-$lang.tgz *
    cd -
}

function clean_all {
    cd $lang
    rm   *.log *.toc  *.aux  *.cp *.cps *.fn *.ky *.tp *.vr *.fns *.pg
    cd -
}

function checkForValidLanguage
{
okLang="0"
for valid in $validLanguages; do
    if [[ $lang = $valid ]]; then
	okLang="1"
    fi
done

if [[ $okLang = "0" ]]; then
    usage
    exit
fi
}


function usage {
    echo "Usage: $0 ($validLanguages) (txt|html|pdf|package|clean)"
}

checkForValidLanguage

case "$2" in 
    txt)
	echo "Build documentation in text."
	doText
	;;
    html) 
	echo 'Build documentation in html.'
	doHtml
	;;
    pdf)
	echo 'Build documentation in PDF.'
	doPdf
	;;
    info)
	echo 'Build documentation for Texinfo.'
	doInfo
	;;
    package)
	echo 'Build html documentation and archive it.'
	doHtml
	package_html
	;;
    clean)
	echo "Delete all the intermediate files."
	clean_all
	;;
    *)
	usage
	exit
esac
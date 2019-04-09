#!/bin/bash

function absp(){

        SCRIPT=`basename $1`
        pushd `dirname $1` > /dev/null
        SCRIPTPATH=`pwd -P`
        popd > /dev/null
        echo $SCRIPTPATH/$SCRIPT
}


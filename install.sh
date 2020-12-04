#!/bin/bash

./script/install.pl mode=scorm start=test rebuild=1 path=../temp_freee.conf
./script/install.pl mode=test start=test rebuild=1 path=../temp_freee.conf
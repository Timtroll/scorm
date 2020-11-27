#!/bin/bash

../scorm/script/install.pl mode=scorm start=test rebuild=1 path=../temp_freee.conf
../scorm/script/install.pl mode=test start=test rebuild=1 path=../temp_freee.conf
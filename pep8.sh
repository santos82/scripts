#!/bin/bash
autopep8 --in-place --recursive .
isort -rc .
@echo off
if "%~3"=="" (
    echo Usage: %0 ^<stack-name^> ^<template-file^> ^<parameters-file^> [region]
    echo Example: %0 my-network templates\network.yml parameters\dev\network.json
    exit /b 1
)

set REGION=%4
if "%REGION%"=="" set REGION=us-east-1

aws cloudformation create-stack --stack-name %1 --template-body file://%2 --parameters file://%3 --capabilities "CAPABILITY_IAM" "CAPABILITY_NAMED_IAM" --region %REGION%

echo Creating stack: %1 in %REGION%...
aws cloudformation wait stack-create-complete --stack-name %1 --region %REGION%
echo Stack %1 created successfully.

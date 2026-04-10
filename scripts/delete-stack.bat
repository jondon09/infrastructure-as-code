@echo off
if "%~1"=="" (
    echo Usage: %0 ^<stack-name^> [region]
    echo Example: %0 my-network
    exit /b 1
)

set REGION=%2
if "%REGION%"=="" set REGION=us-east-1

echo Deleting stack: %1 in %REGION%...
aws cloudformation delete-stack --stack-name %1 --region %REGION%

echo Waiting for stack deletion to complete...
aws cloudformation wait stack-delete-complete --stack-name %1 --region %REGION%
echo Stack %1 deleted successfully.

#!/bin/bash

echo "Verificando portas para PID: 92051"
output=$(sudo lsof -Pan -p 92051 -i)
echo "$output"
echo "-----------------------------"
sleep 1

echo "Verificando portas para PID: 92052"
output=$(sudo lsof -Pan -p 92052 -i)
echo "$output"
echo "-----------------------------"
sleep 1

echo "Verificando portas para PID: 92085"
output=$(sudo lsof -Pan -p 92085 -i)
echo "$output"
echo "-----------------------------"
sleep 1

echo "Verificando portas para PID: 92086"
output=$(sudo lsof -Pan -p 92086 -i)
echo "$output"
echo "-----------------------------"
sleep 1

echo "Verificando portas para PID: 92119"
output=$(sudo lsof -Pan -p 92119 -i)
echo "$output"
echo "-----------------------------"
sleep 1

echo "Verificando portas para PID: 92120"
output=$(sudo lsof -Pan -p 92120 -i)
echo "$output"
echo "-----------------------------"
sleep 1

echo "Verificando portas para PID: 92153"
output=$(sudo lsof -Pan -p 92153 -i)
echo "$output"
echo "-----------------------------"
sleep 1

echo "Verificando portas para PID: 92154"
output=$(sudo lsof -Pan -p 92154 -i)
echo "$output"
echo "-----------------------------"
sleep 1

echo "Verificando portas para PID: 92187"
output=$(sudo lsof -Pan -p 92187 -i)
echo "$output"
echo "-----------------------------"
sleep 1

echo "Verificando portas para PID: 92188"
output=$(sudo lsof -Pan -p 92188 -i)
echo "$output"
echo "-----------------------------"
sleep 1

echo "Verificando portas para PID: 2736"
output=$(sudo lsof -Pan -p 2736 -i)
echo "$output"
echo "-----------------------------"
sleep 1


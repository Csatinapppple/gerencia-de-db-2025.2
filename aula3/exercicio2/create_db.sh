#!/bin/sh

sqlite3 veterinaria.db < 20_exercicios.sql
sqlite3 veterinaria.db < insercoes.sql
sqlite3 veterinaria.db < respostas.sql

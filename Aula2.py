# -*- coding: utf-8 -*-
"""Aula2.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1Dgb7jS6MqYypjvJC_PXWHx8IdlivgKbu
"""

#definir o input
n1 = int(input('Digite o primeiro valor: '))
n2 = int(input('Digite o segundo valor: '))
n3 = int(input('Digite o terceiro valor: '))

#função
def triangulo(n1, n2, n3):
  if (n1 == n2) and (n2 == n3):
    print('Triangulo equilatero')
  elif (n1 == n2) and (n1 != n2 or n1 != n3):
    print('Triangulo isoceles')
  else:
    print('Triangulo escaleno')

#chamar função
triangulo(n1, n2, n3)

#Tipos de dados

#Int - tipo inteiro
#Float - tipo ponto flutuante (decimais)
#Boolean - True|False
#String - Texto

#array - lista
alunos = ['Silas', 'Andressa', 'Guilherme']
print(alunos)

#loop - for
for i in alunos:
  print(i)

# sinal / - obtem o divisor
# sinal % - obtem o resto

lista_numeros = [10,5,8,44,9,11,33,20,24]
for i in lista_numeros:
  if (i%2 == 0):
    print('Número par: ', i)

#contar a quantidade de caracteres na string usando for

exercicio = 'oi classe tudo bem?'

x = 0
for i in exercicio:
  x = x +1 # outra forma x += 1

print(x)

# outra maneira de saber o tamanho da string é usar a função pronta "len(exercicio)"

#matriz - atentar-se que o índice sempre começa com 0(zero)
variavel = [[5,2,3], [4,5,6], [7,8,9]]

# ler a linha 1 coluna 2
# variáveis i | j = muito utilizado em programação
# variáveis n | m = utilizado para matriz

print(variavel[1][2])

#somatorio da matriz
matriz = [[5,5,5], [6,7,8], [6,5,4]]

soma = 0
for i in matriz:
  for j in i:
    soma = soma + j
  #print(soma) - se o print for nessa identação, vai imprimir 3 vezes (1x para a somatória de cada linha)
print(soma)

import numpy as np

teste = np.array([[1,2,3,4], [4,5,6,7]])
teste.shape #mostra a estrutura do array
teste.shape[0] #mostra a primeira estrurua - quantidade de linhas
teste.shape[1] #mostra a primeira estrurua - quantidade de colunas
#isso porque o array é bidimensional

a = np.arange(12).reshape((3,4))
print(a)

teste.sum() #maneira mais fácil de somar (com o import da library numpy)
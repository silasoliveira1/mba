# -*- coding: utf-8 -*-

#definir o input
n1 = float(input("Digite o primeiro valor: "))
n2 = float(input("Digite o segundo valor: "))
op = input("Digite o operador: ")

#função
def calculadora(n1, n2, op):

    if(n2 == 0):
        print("O segundo valor não pode ser 0(zero)")
    else:
        if op == "+":
            print("A soma é = ", n1 + n2)
        if op == "-":
            print("A subtração é = ", n1 - n2)
        if op == "*":
            print("A multiplicação é = ", n1 * n2)
        if op == "/":
            print("A divisão é = ", n1 / n2)
        if op == "**":
            print("O expoente é = ", n1 ** n2)

#chamar a função
calculadora(n1, n2, op)
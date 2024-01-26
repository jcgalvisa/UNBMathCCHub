### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 2756200a-497c-44ac-be31-c4047bb2312f
using PlutoUI

# ╔═╡ 8afc9c45-0681-479e-b3f4-75dac7461d15
using LinearAlgebra

# ╔═╡ 42df22ae-471b-40f2-9f1c-ffdb7ae48caf
PlutoUI.TableOfContents(title="Conceptos básicos", aside=true)

# ╔═╡ 71f6b680-20cb-4ce2-9ae3-dbc1fbf96844
md"""Elaborado por Juan Galvis, Francisco Gómez y Yessica Trujillo."""

# ╔═╡ 63dc3073-9454-4077-820f-1afe5b3486fb
md"""# Introducción a las matrices"""

# ╔═╡ b785eeba-828b-4bc2-a5bb-afba2b68a1cf
md"""Una matriz es un conjunto rectangular de números, símbolos o expresiones, acomodados en filas y columnas. Se representa comúnmente con letras mayúsculas, y sus elementos se identifican mediante índices que indican la posición de cada elemento en la matriz. La dimensión de una matriz se expresa como el número de filas y columnas que contiene.

Por ejemplo, una matriz $A$ de dimensión $m \times n$ se denota como:

$A = \begin{bmatrix} a_{11} & a_{12} & \cdots & a_{1n} \\ a_{21} & a_{22} & \cdots & a_{2n} \\ \vdots & \vdots & \ddots & \vdots \\ a_{m1} & a_{m2} & \cdots & a_{mn} \end{bmatrix}$

Donde $a_{ij}$ representa el elemento en la fila $i$ y columna $j$ de la matriz.

La $i$-ésima fila de la matriz $A$ se representa como $(a_{i1}, a_{i2}, \ldots, a_{in})$, y la $j$-ésima columna se representa como $\begin{bmatrix} a_{1j} \\ a_{2j} \\ \vdots \\ a_{mj} \end{bmatrix}$.
"""

# ╔═╡ 6dac350c-58a9-41e1-8241-11ecd2704a34
md"""Las matrices se utilizan en diversas áreas de las matemáticas y en aplicaciones prácticas, como la resolución de sistemas de ecuaciones lineales, transformaciones lineales, en el análisis de datos, procesamiento de imágenes."""

# ╔═╡ 77ed0616-5a19-4c07-aaa8-121ac80f987a
md"""Por ejemplo, una matriz real de tamaño $3\times 3$ es la que se muestra a continuación

$B = \begin{bmatrix} 0.5 & 1.2 & 3.8 \\ -2.1 & 7.0 & 6.3 \\ 4.9 & -0.2 & 2.4 \end{bmatrix}.$
Pero tal como se mencionó anteriormente, el siguiente arreglo de símbolos también es una matriz (de tamaño $3 \times 3$):

$C = \begin{bmatrix} a & b & c \\ d & e & f \\ g & h & i \end{bmatrix}.$
Al igual que lo es el siguiente arreglo de números complejos:

$F = \begin{bmatrix} 2 + 3i & -1 - 2i \\ 4i & 1 \end{bmatrix},$
observe que $F$ es una matriz de tamaño $2\times 2$.
"""

# ╔═╡ 9a15f141-ef47-4fc3-b6e3-5bb49ed4e47e
md"""Ahora, consideremos la siguiente matriz de tamaño $3\times 4$ y veamos algunas cosas sobre ella. Sea 

$D=\begin{bmatrix} 1 & 2 & 3 & 4 \\ -1 & 4 & 1 & 4 \\ 0 & 0 & 1 & -2 \end{bmatrix}.$"""

# ╔═╡ 651e717d-579d-40fe-a963-2a6d53abd825
D=[1 2 3 4; -1 4 1 4; 0 0 1 -2] #Construimos la matriz

# ╔═╡ a1852040-890c-4ec4-9a54-835b1cf9c257
md"""El elemento $d_{34}$ de la anterior matriz es el siguiente

$\begin{bmatrix} 1 & 2 & 3 & 4 \\ -1 & 4 & 1 & 4 \\ 0 & 0 & 1 & \textcolor{red}{-2} \end{bmatrix}.$ Y lo podemos hallar de la siguiente forma:"""

# ╔═╡ f2403e65-ea26-4571-8662-200298d01e32
D[3,4] #Se busca el elemento en la fila 3 y columna 4

# ╔═╡ 16af7a1d-9aef-428c-adac-fd724d552b01
md"""El elemento $d_{13}$ 

$\begin{bmatrix} 1 & 2 & \textcolor{red}{3} & 4 \\ -1 & 4 & 1 & 4 \\ 0 & 0 & 1 & -2 \end{bmatrix}$
es el que se muestra a continuación"""

# ╔═╡ c2e55f5a-0b58-4ccf-b29e-03c47bcd90a9
D[1,3] #Se busca el elemento en la fila 1 y columna 3

# ╔═╡ d002116c-dc11-4333-bdba-7de5429c055c
md"""La segunda columna de D 

$\begin{bmatrix} 1 & \textcolor{red}{2} & 3 & 4 \\ -1 & \textcolor{red}{4} & 1 & 4 \\ 0 & \textcolor{red}{0} & 1 & -2 \end{bmatrix}$
se puede vizualizar con el siguiente comando:"""

# ╔═╡ b1478f42-2b47-425a-9e7a-f5f55bf3cdff
D[:,2] #Muestra la segunda columna

# ╔═╡ 4caa7c9d-a185-4403-aa17-960e5cba8b07
md"""Al igual que la tercera fila de la matriz,

$\begin{bmatrix} 1 & 2 & 3 & 4 \\ -1 & 4 & 1 & 4 \\ \textcolor{red}{0} & \textcolor{red}{0} & \textcolor{red}{1} & \textcolor{red}{-2} \end{bmatrix}$
se puede mostrar de la siguiente manera"""

# ╔═╡ aeec8449-dfc8-4559-a811-130e553f716c
D[3,:] #Muesta la tercera fila

# ╔═╡ 8c90caa6-0bca-43b3-84f5-0ffc864a0ced
md"""También podemos simplemente mostrar submatrices contiguas de la matriz dada. Recordemos que una submatriz contigua es una matriz obtenida al seleccionar un conjunto rectangular de elementos de la matriz original sin interrumpir la secuencia natural de filas y columnas. Por ejemplo, podemos mostrar desde la fila 2 hasta la 3 y desde la columna 1 hasta la 3 de la matriz $D$:

$\begin{bmatrix} 1 & 2 & 3 & 4 \\ \textcolor{red}{-1} & \textcolor{red}{4} & \textcolor{red}{1} & 4 \\ \textcolor{red}{0} & \textcolor{red}{0} & \textcolor{red}{1} & -2 \end{bmatrix},$

tal como se sigue.
"""

# ╔═╡ 2fba9cd4-337e-49dd-86e8-3a6ca158e6c7
D[2:3,1:3]

# ╔═╡ 12e6f5fb-7a0a-44b0-9ed8-4e7e00e34283
md"""Mostremos ahora desde la fila 1 a la 2 y desde la columna 3 a la 4 de la matriz $D$

$\begin{bmatrix} 1 & 2 & \textcolor{red}{3} & \textcolor{red}{4} \\ -1 & 4 & \textcolor{red}{1} & \textcolor{red}{4} \\ 0 & 0 & 1 & -2 \end{bmatrix}.$"""

# ╔═╡ 59ff5012-241b-404a-96b9-6e27a7b29c0b
D[1:2,3:4]

# ╔═╡ ad5ac9be-de8a-4e36-8719-07f271293384
md"""Podemos pensar también en seleccionar elementos arbitrarios de la matriz sin seguir un patrón continuo de filas y columnas; a este tipo de matrices se les conoce como no contiguas. Para que esto quede más claro, veamos un ejemplo. Recordemos que $D$ es la siguiente matriz:

$\begin{bmatrix} 1 & 2 & 3 & 4 \\ -1 & 4 & 1 & 4 \\ 0 & 0 & 1 & -2 \end{bmatrix}.$

Y seleccionamos los siguientes elementos:

$\begin{bmatrix} 1 & 2 & 3 & 4 \\ \textcolor{red}{-1} & 4 & \textcolor{red}{1} & 4 \\ \textcolor{red}{0} & 0 & \textcolor{red}{1} & -2 \end{bmatrix}.$

Esto se realiza de la siguiente forma:"""

# ╔═╡ 5176dfb0-ca55-4c3b-9758-25da336a1068
D[2:1:end, 1:2:end]

# ╔═╡ 134e30fc-65f6-4869-9e61-f946a5c1a4b3
md"""Ahora, si seleccionamos los siguientes elementos:

$\begin{bmatrix} 1 & 2 & \textcolor{red}{3} & \textcolor{red}{4} \\ -1 & 4 & 1 & 4 \\ 0 & 0 & \textcolor{red}{1} & \textcolor{red}{-2} \end{bmatrix}.$

Esto lo podemos visualizar con ayuda del siguiente código:"""

# ╔═╡ d7a30d33-921c-477c-bc03-54600fa4aae3
D[1:2:end, 3:1:end]

# ╔═╡ 305c334a-d343-45ea-83e4-99375d014c48
md"""Las matrices menores son submatrices obtenidas eliminando una fila y una columna específicas de una matriz dada. Supongamos que tenemos una matriz $A$ de tamaño $n \times m$. Entonces, la matriz menor correspondiente a eliminar la $i$-ésima fila y la $j$-ésima columna de $A$ se denota como $M_{ij}$.

Si deseamos eliminar la fila 2 y la columna 4 de la matriz $D$:

$\begin{bmatrix} 1 & 2 & 3 & \textcolor{red}{4} \\ \textcolor{red}{-1} & \textcolor{red}{4} & \textcolor{red}{1} & \textcolor{red}{4} \\ 0 & 0 & 1 & \textcolor{red}{-2} \end{bmatrix}$
para obtener el menor $M_{24}$, lo podemos hacer de la siguiente forma:
"""

# ╔═╡ 0a644a7b-3bbc-4736-98d6-c5246e505332
D₁=vcat(D[1:1, :], D[3:end, :]) #Elimina la fila 2

# ╔═╡ 50895892-4420-4c43-93b5-7af2cc3c19c8
M₂₄=hcat(D₁[:, 1:3]) #Del resultado anterior se elimina la columna 4

# ╔═╡ 01bc6da9-91c3-44d8-bdf5-007c850fddad
md"""Ahora hallemos el menor $M_{22}$ de la matriz $D$

$\begin{bmatrix} 1 & \textcolor{red}{2} & 3 & 4 \\ \textcolor{red}{-1} & \textcolor{red}{4} & \textcolor{red}{1} & \textcolor{red}{4} \\ 0 & \textcolor{red}{0} & 1 & -2 \end{bmatrix}.$

Esto lo podemos hacer de la siguiente forma:"""

# ╔═╡ a1cf3408-0854-45d3-94c3-ea735a33531f
D₂=vcat(D[1:1, :], D[3:end, :]) #Elimina la fila 1

# ╔═╡ fd74b310-343f-4343-b416-c0c79245b790
M₂₂=hcat(D₂[:, 1:1], D₂[:, 3:end]) #Del resultado anterior se elimina la columna 2

# ╔═╡ 7ddea5a7-47c0-4a5d-9a9f-cb7961892cd8
md"""Podemos crear una función que nos ayude a calcular la matriz menor $M_{ij}$:"""

# ╔═╡ 4a2811f4-1a7b-44cd-a00d-bbb6fc7eb8fb
function Menor(Matriz,i,j)
	Mᵢⱼ = Matriz[setdiff(1:end, i), setdiff(1:end, j)]
end

# ╔═╡ 76d160d9-2582-454a-bde1-0fadfeab85c2
md"""Con nuestra nueva función calculemos nuevamente $M_{22}$ para la matriz $D$"""

# ╔═╡ 56b90154-3a83-4cd9-9a98-08aa87d5e9ab
Menor(D,2,2)

# ╔═╡ e4907b7e-a9c1-4391-a155-61e8a24b8d8a
md"""En efecto, se verifica la igualdad."""

# ╔═╡ 0d48f6c8-68c5-4bdc-a563-f490f578b20f
M₂₂==Menor(D,2,2)

# ╔═╡ 5b15c17c-f3a2-494e-a28e-ad8a7220db83
md"""Una matriz por bloques es una matriz que está compuesta por bloques más pequeños en lugar de elementos individuales, es decir,  una matriz por bloques tiene submatrices (bloques) en lugar de elementos individuales.

Una matriz por bloques generalmente se representa de la siguiente manera:

$A = \begin{bmatrix} A_{11} & A_{12} & \cdots & A_{1k} \\ A_{21} & A_{22} & \cdots & A_{2k} \\ \vdots & \vdots & \ddots & \vdots \\ A_{k1} & A_{k2} & \cdots & A_{kk} \end{bmatrix}$

Donde cada $A_{ij}$ es un bloque que puede ser una submatriz rectangular o incluso otra matriz por bloques.

Veamos ahora un ejemplo de esto. Consideremos  

$E = \begin{bmatrix} E_{11} & E_{12} \\ E_{21} & E_{22} \end{bmatrix}$

Donde:

$E_{11} = \begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix}, \quad
E_{12} = \begin{bmatrix} 5 & 6 \\ 7 & 8 \end{bmatrix},$

$E_{21} = \begin{bmatrix} 9 & 10 \\ 11 & 12 \end{bmatrix}, \quad
E_{22} = \begin{bmatrix} 13 & 14 \\ 15 & 16 \end{bmatrix}$

Implementemos esto:
"""

# ╔═╡ d5540b51-1143-4fdb-8fb2-662156540ef2
begin
	E₁₁=[1 2; 3 4]
	E₁₂=[5 6; 7 8]
	E₂₁=[9 10; 11 12]
	E₂₂=[13 14; 15 16]
end

# ╔═╡ 2fb0a25a-0320-4645-b68e-64d051a3baf6
md"""Ensamblemos la matriz $E$"""

# ╔═╡ f281cc2f-daef-4cf1-87ec-784739203d53
E = [E₁₁ E₁₂; E₂₁ E₂₂]

# ╔═╡ 5bfe837c-1ed4-4f1b-85dc-a454e633940f
md"""**Nota:** $\texttt{let}$ y $\texttt{begin}$ son construcciones que se utilizan para agrupar múltiples expresiones o declaraciones en un solo bloque de código.

Para crear variables locales y limitar su alcance a un bloque específico se pueden definir las variables dentro de un $\texttt{let}$ y estas solo serán accesibles dentro de ese bloque. A continuación vemos un ejemplo"""

# ╔═╡ e7766586-64a3-4ccc-be2c-babce844aa72
let
	local₁ = [1 0]
	local₂ = [2 3 6]
end

# ╔═╡ eb74257e-3bbd-42e2-b00b-ee2a3c11b600
md"""Y si tratamos de usar alguna de estas variables Julia nos dira que no estan definidas."""

# ╔═╡ bc28d6d9-1e4d-454f-8090-ba4d841a939b
local₁

# ╔═╡ 8c30e76d-9d8d-4408-b92f-2a1041942471
md"""A diferencia de $\texttt{let}$, las variables definidas en un bloque $\texttt{begin}$ son visibles fuera del bloque. Por ejemplo, consideremos las siguientes variables"""

# ╔═╡ f0dbe476-7ea9-4a63-9023-0afffce31870
begin
	def₁ = [2 3 4 5; 12 3 5 0]
	def₂ = [0 3]
	def₃ = [2; 4; 5]
end

# ╔═╡ 782795c9-593a-40fa-86b8-27cec874a5ac
md"""Podemos acceder a cualquiera de estas variables simplemente llamándolas."""

# ╔═╡ 03f7fd11-ebf8-4e78-866b-1f50cd674f31
def₂

# ╔═╡ 413a74dd-39fe-44a9-99ae-9891af29d53d
md"""# Tipos de matrices"""

# ╔═╡ f450c7d8-29e0-47dd-9516-49306bf54450
md"""Usaremos las siguientes librerias para ejecutar los ejemplos presentados."""

# ╔═╡ 6f4c7a27-1071-4979-9b6a-9eac50950e64
md""" ### $\cdot$ Matriz cuadrada

Una matriz cuadrada es aquella que tiene el mismo número de filas y columnas. Así, una matriz cuadrada tiene la siguiente forma:

$A=\begin{bmatrix} a_{11} & a_{12} & \cdots & a_{1n} \\ a_{21} & a_{22} & \cdots & a_{2n} \\ \vdots & \vdots & \ddots & \vdots \\ a_{n1} & a_{n2} & \cdots & a_{nn} \end{bmatrix}$

Ejemplo:
Se presenta una matriz cuadrada $A_1$ de tamaño $3\times 3$."""

# ╔═╡ 80550e96-8f59-4429-9dc6-b93f7b4706db
A₁=[1 2 3; 4 5 6; 7 8 9]

# ╔═╡ cff445ca-7554-47ee-b410-fbec0b552a7e
md"""Otro ejemplo de una matriz cuadrada es la que se sigue a continuación (tamaño $4\times 4$), esta matriz es generada de manera aleatoria"""

# ╔═╡ 06003fa7-8a62-4f5e-bf16-8e9d167193a6
A₂=rand(4,4) #Genera aleatoriamente una matriz de tamaño 4x4

# ╔═╡ 446244b7-5043-4928-b82e-de2ee7fc95a1
md""" ### $\cdot$ Matriz diagonal

Una matriz diagonal es una matriz cuadrada en la que todos los elementos fuera de la diagonal principal son cero. La diagonal principal es la secuencia de elementos que va desde la esquina superior izquierda hasta la esquina inferior derecha de la matriz.
Es decir, una matriz cuadrada $A$ de orden $n \times n$ es diagonal si: $a_{ij} = 0 \text{ para } i \neq j$. Así, una matriz diagonal tiene la siguiente forma:

$\begin{bmatrix}  a_{11} & 0 & \cdots & 0 \\  0 & a_{22} & \cdots & 0 \\  \vdots & \vdots & \ddots & \vdots \\  0 & 0 & \cdots & a_{nn} \end{bmatrix}$

Ejemplo: A continuación se muestra una matriz diagonal de tamaño $4\times 4$"""

# ╔═╡ 18a3a569-8afc-4d7c-9a3b-126e436d5295
begin
	a = [1,2,3,4] #Se ingresan los elementos de la diagonal
	A₃ = diagm(a) #Se representan dichos elementos de forma matricial (matriz diagonal)
end

# ╔═╡ 755968e9-e37c-49f5-a9cd-3b697f4a7870
md""" ### $\cdot$ Matriz identidad

La matriz identidad, denotada comúnmente por $I$ o $I_n$, donde $n$ es el tamaño de la matriz, es una matriz cuadrada especial que tiene unos en su diagonal principal y ceros en todos los demás elementos. Así, la matriz identidad de orden $n \times n$ se define como:

$\begin{bmatrix}  1 & 0 & \cdots & 0 \\  0 & 1 & \cdots & 0 \\  \vdots & \vdots & \ddots & \vdots \\  0 & 0 & \cdots & 1 \end{bmatrix}$

Ejemplo:"""

# ╔═╡ b65e75d7-fba8-4648-9726-5be5f1b776af
I₄=Matrix(I, 4, 4) #Se genera la matriz I₄

# ╔═╡ 71823790-277a-4ef2-9e32-ca5e681b23e3
md""" ### $\cdot$ Matriz nula

La matriz nula, también conocida como matriz de ceros, es una matriz en la que todos sus elementos son iguales a cero. La matriz nula de tamaño $m \times n$ se denota como $\mathbf{0}_{m \times n}$ y $\mathbf{0}_{ij} = 0$, es decir


$\mathbf{0}_{m \times n}=\begin{bmatrix}  0 & 0 & \cdots & 0 \\  0 & 0 & \cdots & 0 \\  \vdots & \vdots & \ddots & \vdots \\  0 & 0 & \cdots & 0 \end{bmatrix}$

Ejemplo: A continuación se genera una matriz nula de tamaño $2\times 3$."""

# ╔═╡ 4056d2ed-2039-46aa-940b-b2fb120033df
A₅=zeros((2, 3)) #Matriz nula de tamaño 2x3

# ╔═╡ f46ee269-bb92-4ce8-9305-53d36abd7cfc
md"""# Operaciones con matrices"""

# ╔═╡ d2838702-dc29-4c40-aad7-32399f52582f
md""" ### $\cdot$ Suma de matrices

Dadas dos matrices $A$ y $B$ del mismo tamaño $( m \times n )$, la suma $C = A + B$ es otra matriz $m \times n$ donde cada elemento $c_{ij}$ se obtiene sumando los elementos correspondientes de $a_{ij}$ y $b_{ij}$: $c_{ij} = a_{ij} + b_{ij}$. De la siguiente forma

$\begin{align}A+B &= \begin{bmatrix} a_{11} & a_{12} & \cdots & a_{1n} \\ a_{21} & a_{22} & \cdots & a_{2n} \\ \vdots & \vdots & \ddots & \vdots \\ a_{m1} & a_{m2} & \cdots & a_{mn} \end{bmatrix}+\begin{bmatrix} b_{11} & b_{12} & \cdots & b_{1n} \\ b_{21} & b_{22} & \cdots & b_{2n} \\ \vdots & \vdots & \ddots & \vdots \\ b_{m1} & b_{m2} & \cdots & b_{mn} \end{bmatrix}\\

&= \begin{bmatrix} a_{11}+b_{11} & a_{12}+b_{12} & \cdots & a_{1n}+b_{1n} \\ a_{21}+b_{21} & a_{22}+b_{22} & \cdots & a_{2b}+b_{2n} \\ \vdots & \vdots & \ddots & \vdots \\ a_{m1}+b_{m1} & a_{m2}+b_{m2} & \cdots & a_{mn}+b_{mn} \end{bmatrix}\\

&=\begin{bmatrix} c_{11} & c_{12} & \cdots & c_{1n} \\ c_{21} & c_{22} & \cdots & c_{2n} \\ \vdots & \vdots & \ddots & \vdots \\ c_{m1} & c_{m2} & \cdots & c_{mn} \end{bmatrix}\\

&=C\end{align}$

Ejemplo: Se generan dos matrices aleatorias de tamaño $3\times 4$ y se suman."""

# ╔═╡ 7b374f89-adb1-4328-8bd8-5adb1531459e
begin
	A₇,B₇=rand(3,4),rand(3,4)
end

# ╔═╡ 59baf0c7-fcdd-418c-8681-202b8c3f5482
A₇+B₇

# ╔═╡ 759394ed-d2ea-4698-b5c8-67ed80bd0c03
md"""Mostremos otro ejemplo, generemos dos matrices aleatorias de tamaño $5\times 2$ y realicemos su resta."""

# ╔═╡ ab73a8f1-5fe9-4a3c-9a8e-66622f83c1c6
begin
	A₈,B₈=rand(5,2),rand(5,2)
end

# ╔═╡ 5d996f53-1edd-44f5-8cef-b1926aa6497c
A₈-B₈

# ╔═╡ da0b3214-9d7d-4b2a-9d18-980ba142d5d8
md""" ### $\cdot$ Multiplicación por un escalar

Dada una matriz $A$ de tamaño $m \times n$ y un escalar $k$, la multiplicación por escalar $B = k \cdot A$ es otra matriz $m \times n$ donde cada elemento $b_{ij}$se obtiene multiplicando $a_{ij}$ por $k$: $b_{ij} = k \cdot a_{ij}$. Tal como se muestra a continuación:

$\begin{align}B&=k\cdot A \\

&= k\cdot \begin{bmatrix} a_{11} & a_{12} & \cdots & a_{1n} \\ a_{21} & a_{22} & \cdots & a_{2n} \\ \vdots & \vdots & \ddots & \vdots \\ a_{m1} & a_{m2} & \cdots & a_{mn} \end{bmatrix}\\

&= \begin{bmatrix} k\cdot a_{11} &k\cdot a_{12} & \cdots &k\cdot a_{1n} \\ k\cdot a_{21} &k\cdot a_{22} & \cdots &k\cdot a_{2n} \\ \vdots & \vdots & \ddots & \vdots \\k\cdot a_{m1} &k\cdot a_{m2} & \cdots &k\cdot a_{mn} \end{bmatrix}\end{align}$

Ejemplo: Se genera una matriz aleatoria de tamaño $3\times 5$ y se realiza el producto con el escalar 2."""

# ╔═╡ cd9ea07b-1bff-4f76-b6b8-722a7fe9d457
A₉=rand(3,5)

# ╔═╡ 96a56893-71b2-4a63-b601-b77ac784998e
B₉=2*A₉

# ╔═╡ 660f41ae-dfc8-4edd-9280-e00b721d255c
md""" ### $\cdot$ Producto de matriz con vector
Supongamos que tienes una matriz $A$ de tamaño $m \times n$ y un vector columna $v$ de tamaño $n \times 1$. La multiplicación de la matriz por el vector se realiza multiplicando cada fila de la matriz por el vector correspondiente y sumando los resultados. De la siguiente manera. Sea 
$A =
\begin{bmatrix}
a_{11} & a_{12} & \ldots & a_{1n} \\
a_{21} & a_{22} & \ldots & a_{2n} \\
\vdots & \vdots & \ddots & \vdots \\
a_{m1} & a_{m2} & \ldots & a_{mn}
\end{bmatrix}$ y $v =
\begin{bmatrix}
v_1 \\
v_2 \\
\vdots \\
v_n
\end{bmatrix}.$

Entonces, el producto de la matriz por el vector $(Av$) es un nuevo vector de tamaño $m \times 1$ definido como:

$\begin{align}A\cdot v &= \begin{bmatrix}
a_{11} & a_{12} & \ldots & a_{1n} \\
a_{21} & a_{22} & \ldots & a_{2n} \\
\vdots & \vdots & \ddots & \vdots \\
a_{m1} & a_{m2} & \ldots & a_{mn}
\end{bmatrix}\cdot \begin{bmatrix}
v_1 \\
v_2 \\
\vdots \\
v_n
\end{bmatrix}\\

&=\begin{bmatrix}
a_{11}v_1 + a_{12}v_2 + \ldots + a_{1n}v_n \\
a_{21}v_1 + a_{22}v_2 + \ldots + a_{2n}v_n \\
\vdots \\
a_{m1}v_1 + a_{m2}v_2 + \ldots + a_{mn}v_n
\end{bmatrix}.\end{align}$

Ejemplo: Se genera una matriz aleatoria de tamaño $3\times 5$ y se realiza el producto con un vector aleatorio de tamaño $5\times 1$.
"""

# ╔═╡ 9c59a4e8-2c8b-42cc-941e-b94c25db48a4
begin
	A₁₀,v=rand(3,5),rand(5,1)
end

# ╔═╡ 2c7a27bc-8d0c-4029-97e8-480608e2e101
A₁₀*v

# ╔═╡ 36c438e1-d975-4991-a897-c8a6bf7d9ffd
md""" ### $\cdot$ Producto de matrices
Dadas dos matrices $A$ de tamaño $m \times p$ y $B$ de tamaño $p \times n$, el producto $C = A \cdot B$ es otra matriz $m \times n$ donde cada elemento $c_{ij}$ se obtiene sumando el producto de los elementos correspondientes de la fila $i$ de $A$ y la columna $j$ de $B$: $c_{ij} = \sum_{k=1}^{p} a_{ik} \cdot b_{kj}$. Así

$\begin{align}A\cdot B &= \begin{bmatrix}
a_{11} & a_{12} & \ldots & a_{1p} \\
a_{21} & a_{22} & \ldots & a_{2p} \\
\vdots & \vdots & \ddots & \vdots \\
a_{m1} & a_{m2} & \ldots & a_{mp}
\end{bmatrix}\cdot\begin{bmatrix}
b_{11} & b_{12} & \ldots & b_{1n} \\
b_{21} & b_{22} & \ldots & b_{2n} \\
\vdots & \vdots & \ddots & \vdots \\
b_{p1} & b_{p2} & \ldots & b_{pn}
\end{bmatrix}\\

&= \begin{bmatrix}
a_{11} \cdot b_{11} + a_{12} \cdot b_{21} + \ldots + a_{1p} \cdot b_{p1} & \ldots & a_{i1} \cdot b_{1n} + a_{12} \cdot b_{2n} + \ldots + a_{1p} \cdot b_{pn} \\
a_{21} \cdot b_{11} + a_{22} \cdot b_{21} + \ldots + a_{2p} \cdot b_{p1} & \ldots & a_{21} \cdot b_{1n} + a_{22} \cdot b_{2n} + \ldots + a_{2p} \cdot b_{pn} \\
\vdots & \ddots & \vdots \\
a_{m1} \cdot b_{11} + a_{m2} \cdot b_{21} + \ldots + a_{mp} \cdot b_{p1} & \ldots & a_{m1} \cdot b_{1n} + a_{m2} \cdot b_{2n} + \ldots + a_{mp} \cdot b_{pn}
\end{bmatrix}\\

&=\begin{bmatrix}
c_{11} & c_{12} & \ldots & c_{1n} \\
c_{21} & c_{22} & \ldots & c_{2n} \\
\vdots & \vdots & \ddots & \vdots \\
c_{m1} & c_{m2} & \ldots & c_{mn}
\end{bmatrix}\\

&=C\end{align}$

Ejemplo: Se genera una matriz aleatoria $A$ de tamaño $3\times 4$ y una matriz aleatoria $B$ de tamaño $4\times 2$ y se realiza el producto $A\cdot B$.
"""

# ╔═╡ 409ccdfe-6308-4a73-a7f5-bc6838c23955
begin
	A₁₁,B₁₁=rand(3,4),rand(4,2)
end

# ╔═╡ 20a16db4-f2d4-4f87-aaf9-b55e156b6e9a
A₁₁*B₁₁

# ╔═╡ 0284b0da-694f-4ce9-ba50-316a9e440634
md"""Nota: El producto de matrices es no conmutativo. Consideremos $J$ una matriz de tamaño $2\times 3$ y la matriz $H$ de tamaño $3\times 2$."""

# ╔═╡ 3a5350ea-8f5e-4112-9257-ba7a0cc21c33
J,H=rand(2,3),rand(3,2)

# ╔═╡ 77162bb3-2b02-4185-80c5-84ed8eca3030
md"""Ahora realicemos los productos $J\cdot H$ y $H\cdot J$, y observe que nos dan matrices de tamaño $2\times 2$ y $3\times 3$, respectivamente"""

# ╔═╡ f4dae8c7-a5bd-45a5-aebb-a8ad77ad97e1
J*H

# ╔═╡ aff665ef-9406-45a9-860b-892b780c4635
H*J

# ╔═╡ ddebb105-dccc-4608-9b24-5c52b01ce4a1
md"""Con el operador $\texttt{!=}$ podemos ver si dos valores son diferentes. Devuelve $\texttt{true}$ si los valores comparados no son iguales y $\texttt{false}$ si son iguales. Puede ser usado para comparar valores de cualquier tipo, incluyendo números, cadenas de texto, booleanos y matrices.

Por ejemplo, verifiquemos la no igualdad de los anteriores productos matriciales."""

# ╔═╡ cfbf482b-b544-42ad-bcfd-0a19c045cae2
J*H != H*J

# ╔═╡ 1c7da86e-fee8-4b0f-8096-3cbeeb4b9991
md""" ### $\cdot$ Producto de Kronecker

Sea $A$ una matriz de tamaño $m \times n$ y $B$ una matriz de tamaño $p \times q$, entonces el producto de Kronecker $A \otimes B$ es una matriz de bloque de tamaño $mp \times nq$ definida como:

$A \otimes B = \begin{bmatrix}
a_{11}B & \cdots & a_{1n}B \\
\vdots & \ddots & \vdots \\
a_{m1}B & \cdots & a_{mn}B
\end{bmatrix}$

donde $a_{ij}$ es el elemento en la fila $i$, columna $j$ de $A$.
"""

# ╔═╡ f168e458-c1d0-4c64-95da-33142ffaab2f
md"""*Ejemplo:*

Sea $A = \begin{bmatrix}
1 & 2 \\
3 & 4
\end{bmatrix}, B=\begin{bmatrix}
5 & 6 \\
7 & 8
\end{bmatrix}$, entonces el producto de Kronecker $A \otimes B$ es el siguiente

$A \otimes B = \begin{bmatrix}
1 \cdot\begin{bmatrix}
5 & 6 \\
7 & 8
\end{bmatrix} & 2\cdot\begin{bmatrix}
5 & 6 \\
7 & 8
\end{bmatrix}\\
3\cdot\begin{bmatrix}
5 & 6 \\
7 & 8
\end{bmatrix} & 4\cdot\begin{bmatrix}
5 & 6 \\
7 & 8
\end{bmatrix} 
\end{bmatrix} =\begin{bmatrix} 1\cdot5 & 1\cdot6 & 2\cdot5 & 2\cdot6\\
  1\cdot7  & 1\cdot8 & 2\cdot7 & 2\cdot8\\
 3\cdot5 & 3\cdot6 & 4\cdot5 & 4\cdot6\\
 3\cdot7 & 3\cdot8 & 4\cdot7 & 4\cdot8\end{bmatrix}= \begin{bmatrix} 5 & 6 & 10 & 12\\
  7  & 8 & 14 & 16\\
 15 & 18 & 20 & 24\\
 21 & 24 & 28 & 32\end{bmatrix}.$"""

# ╔═╡ a1ffd274-0fe6-4fc8-98a0-f1908e3763c9
md"""Esto se puede realizar con la función $\texttt{kron}$, primero definimos las matrices $A$ y $B$"""

# ╔═╡ 33b0243a-64b4-4a2f-bcdf-d19dcf32671d
begin
	A₁₄ = [1 2; 3 4]
	B₁₄ = [5 6; 7 8]
end

# ╔═╡ 4ade03c0-8bba-4e39-b1bb-4216621cb560
md"""Y ahora realizamos el producto de Kronecker de $A$ con $B$."""

# ╔═╡ 1e169308-7388-4490-91f0-1f92dc408229
kron(A₁₄, B₁₄)

# ╔═╡ dca9311b-8ee9-4eef-b658-df9011f9393a
md"""**Nota:** El producto de Kronecker es no conmutativo, aquí se tiene un ejemplo de esto"""

# ╔═╡ 168af4ed-8d9d-4076-8d1f-910ecbdd9daa
kron(B₁₄, A₁₄)

# ╔═╡ d82dab49-3cec-4269-94ae-e7b97d1a8b16
kron(A₁₄, B₁₄) == kron(B₁₄, A₁₄)

# ╔═╡ 93b7fbbf-f130-41f7-a126-26d2a423a3b2
md"""*Ejemplo:* Si realizamos el producto de Kronecker con una matriz de unos el resultado será una matriz de bloque ampliada. Consideremos la matriz $A$ anterior y definamos la matriz $C$ de unos de tamaño $r\times r$, y realicemos el producto de Kronecker de $A$ con $C$."""

# ╔═╡ 6e4bc8fc-38fd-46f7-a31d-519f166c60f7
A₁₄ #Mostramos A

# ╔═╡ 8c8e4794-f46a-4d05-b182-485ad85b5e8f
@bind r Slider(1:20, show_value=true) #elegimos r

# ╔═╡ 31f9367a-88d3-466b-a3bf-299b5c6df316
C₁₄ = ones(r, r) #Creamos la matriz de unos de tamaño rxr

# ╔═╡ 46617d7f-931a-4ce8-9f8a-05b726ef9a41
kron(A₁₄, C₁₄) #Efectuamos el producto de Kronecker

# ╔═╡ 4b10de39-8878-4298-869b-f7ef6585a132
md""" ### $\cdot$ Transpuesta de una matriz

Dada una matriz $A$ de tamaño $m \times n$, la transpuesta $A^T$ es otra matriz $n \times m$ donde cada elemento $(A^T)_{ij}$ es igual al elemento $a_{ji}$: $(A^T)_{ij} = a_{ji}$. Es decir, si

$A=\begin{bmatrix}  a_{11} & a_{12} & \cdots & a_{1n} \\  a_{21} & a_{22} & \cdots & a_{2n} \\  \vdots & \vdots & \ddots & \vdots \\  a_{m1} & a_{m2} & \cdots & a_{mn} \end{bmatrix}$
entonces 

$A^T=\begin{bmatrix}  a_{11} & a_{21} & \cdots & a_{m1} \\  a_{12} & a_{22} & \cdots & a_{m2} \\  \vdots & \vdots & \ddots & \vdots \\  a_{1n} & a_{2n} & \cdots & a_{mn} \end{bmatrix}$

Ejemplo: Considere la siguiente matriz de tamaño $2\times 2$."""

# ╔═╡ 19fc8142-4a0b-4dda-8046-d57840ee9e7b
A₁₂=[2 3; 4 7]

# ╔═╡ eedd241f-5e81-49e2-83ca-3c3cfff77555
md"""Su transpuesta se muestra a continuación."""

# ╔═╡ 4731e33d-5f40-4ded-86c7-e7ff241ce205
A₁₃=transpose(A₁₂)

# ╔═╡ 925ae3f7-7d14-4964-80a1-339b8425c399
md"""# Referencias"""

# ╔═╡ d7e332be-fb7c-4de0-8eb6-ec60c035d1b3
md"""[1] Martínez R., H. J., & Sanabria R., A. M. (2014). Álgebra Lineal. Programa Editorial Universidad del Valle.

[2] Boyd, S., & Vandenberghe, L. (2018). Introduction to Applied Linear Algebra: Vectors, Matrices, and Least Squares. Cambridge University Press.

[3] Boyd, S., & Vandenberghe, L. (2021). Introduction to Applied Linear Algebra: Vectors, Matrices, and Least Squares - Julia Language Companion. Cambridge University Press.

[4] Grossman, S. I., & Flores Godoy, J. J. (2012). Álgebra Lineal (7a ed.). McGraw-Hill."""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.54"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "3731524a0be8981c0b3969f8e7511b0d5e2849dc"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "793501dcd3fa7ce8d375a2c878dca2296232686e"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "a935806434c9d4c506ba941871b327b96d41f2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "bd7c69c7f7173097e7b5e1be07cee2b8b7447f51"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.54"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─2756200a-497c-44ac-be31-c4047bb2312f
# ╟─42df22ae-471b-40f2-9f1c-ffdb7ae48caf
# ╟─71f6b680-20cb-4ce2-9ae3-dbc1fbf96844
# ╟─63dc3073-9454-4077-820f-1afe5b3486fb
# ╟─b785eeba-828b-4bc2-a5bb-afba2b68a1cf
# ╟─6dac350c-58a9-41e1-8241-11ecd2704a34
# ╟─77ed0616-5a19-4c07-aaa8-121ac80f987a
# ╟─9a15f141-ef47-4fc3-b6e3-5bb49ed4e47e
# ╠═651e717d-579d-40fe-a963-2a6d53abd825
# ╟─a1852040-890c-4ec4-9a54-835b1cf9c257
# ╠═f2403e65-ea26-4571-8662-200298d01e32
# ╟─16af7a1d-9aef-428c-adac-fd724d552b01
# ╠═c2e55f5a-0b58-4ccf-b29e-03c47bcd90a9
# ╟─d002116c-dc11-4333-bdba-7de5429c055c
# ╠═b1478f42-2b47-425a-9e7a-f5f55bf3cdff
# ╟─4caa7c9d-a185-4403-aa17-960e5cba8b07
# ╠═aeec8449-dfc8-4559-a811-130e553f716c
# ╟─8c90caa6-0bca-43b3-84f5-0ffc864a0ced
# ╠═2fba9cd4-337e-49dd-86e8-3a6ca158e6c7
# ╟─12e6f5fb-7a0a-44b0-9ed8-4e7e00e34283
# ╠═59ff5012-241b-404a-96b9-6e27a7b29c0b
# ╟─ad5ac9be-de8a-4e36-8719-07f271293384
# ╠═5176dfb0-ca55-4c3b-9758-25da336a1068
# ╟─134e30fc-65f6-4869-9e61-f946a5c1a4b3
# ╠═d7a30d33-921c-477c-bc03-54600fa4aae3
# ╟─305c334a-d343-45ea-83e4-99375d014c48
# ╠═0a644a7b-3bbc-4736-98d6-c5246e505332
# ╠═50895892-4420-4c43-93b5-7af2cc3c19c8
# ╟─01bc6da9-91c3-44d8-bdf5-007c850fddad
# ╠═a1cf3408-0854-45d3-94c3-ea735a33531f
# ╠═fd74b310-343f-4343-b416-c0c79245b790
# ╟─7ddea5a7-47c0-4a5d-9a9f-cb7961892cd8
# ╠═4a2811f4-1a7b-44cd-a00d-bbb6fc7eb8fb
# ╟─76d160d9-2582-454a-bde1-0fadfeab85c2
# ╠═56b90154-3a83-4cd9-9a98-08aa87d5e9ab
# ╟─e4907b7e-a9c1-4391-a155-61e8a24b8d8a
# ╠═0d48f6c8-68c5-4bdc-a563-f490f578b20f
# ╟─5b15c17c-f3a2-494e-a28e-ad8a7220db83
# ╠═d5540b51-1143-4fdb-8fb2-662156540ef2
# ╟─2fb0a25a-0320-4645-b68e-64d051a3baf6
# ╠═f281cc2f-daef-4cf1-87ec-784739203d53
# ╟─5bfe837c-1ed4-4f1b-85dc-a454e633940f
# ╠═e7766586-64a3-4ccc-be2c-babce844aa72
# ╟─eb74257e-3bbd-42e2-b00b-ee2a3c11b600
# ╠═bc28d6d9-1e4d-454f-8090-ba4d841a939b
# ╟─8c30e76d-9d8d-4408-b92f-2a1041942471
# ╠═f0dbe476-7ea9-4a63-9023-0afffce31870
# ╟─782795c9-593a-40fa-86b8-27cec874a5ac
# ╠═03f7fd11-ebf8-4e78-866b-1f50cd674f31
# ╟─413a74dd-39fe-44a9-99ae-9891af29d53d
# ╟─f450c7d8-29e0-47dd-9516-49306bf54450
# ╠═8afc9c45-0681-479e-b3f4-75dac7461d15
# ╟─6f4c7a27-1071-4979-9b6a-9eac50950e64
# ╠═80550e96-8f59-4429-9dc6-b93f7b4706db
# ╟─cff445ca-7554-47ee-b410-fbec0b552a7e
# ╠═06003fa7-8a62-4f5e-bf16-8e9d167193a6
# ╟─446244b7-5043-4928-b82e-de2ee7fc95a1
# ╠═18a3a569-8afc-4d7c-9a3b-126e436d5295
# ╟─755968e9-e37c-49f5-a9cd-3b697f4a7870
# ╠═b65e75d7-fba8-4648-9726-5be5f1b776af
# ╟─71823790-277a-4ef2-9e32-ca5e681b23e3
# ╠═4056d2ed-2039-46aa-940b-b2fb120033df
# ╟─f46ee269-bb92-4ce8-9305-53d36abd7cfc
# ╟─d2838702-dc29-4c40-aad7-32399f52582f
# ╠═7b374f89-adb1-4328-8bd8-5adb1531459e
# ╠═59baf0c7-fcdd-418c-8681-202b8c3f5482
# ╟─759394ed-d2ea-4698-b5c8-67ed80bd0c03
# ╠═ab73a8f1-5fe9-4a3c-9a8e-66622f83c1c6
# ╠═5d996f53-1edd-44f5-8cef-b1926aa6497c
# ╟─da0b3214-9d7d-4b2a-9d18-980ba142d5d8
# ╠═cd9ea07b-1bff-4f76-b6b8-722a7fe9d457
# ╠═96a56893-71b2-4a63-b601-b77ac784998e
# ╟─660f41ae-dfc8-4edd-9280-e00b721d255c
# ╠═9c59a4e8-2c8b-42cc-941e-b94c25db48a4
# ╠═2c7a27bc-8d0c-4029-97e8-480608e2e101
# ╟─36c438e1-d975-4991-a897-c8a6bf7d9ffd
# ╠═409ccdfe-6308-4a73-a7f5-bc6838c23955
# ╠═20a16db4-f2d4-4f87-aaf9-b55e156b6e9a
# ╟─0284b0da-694f-4ce9-ba50-316a9e440634
# ╠═3a5350ea-8f5e-4112-9257-ba7a0cc21c33
# ╟─77162bb3-2b02-4185-80c5-84ed8eca3030
# ╠═f4dae8c7-a5bd-45a5-aebb-a8ad77ad97e1
# ╠═aff665ef-9406-45a9-860b-892b780c4635
# ╟─ddebb105-dccc-4608-9b24-5c52b01ce4a1
# ╠═cfbf482b-b544-42ad-bcfd-0a19c045cae2
# ╟─1c7da86e-fee8-4b0f-8096-3cbeeb4b9991
# ╟─f168e458-c1d0-4c64-95da-33142ffaab2f
# ╟─a1ffd274-0fe6-4fc8-98a0-f1908e3763c9
# ╠═33b0243a-64b4-4a2f-bcdf-d19dcf32671d
# ╟─4ade03c0-8bba-4e39-b1bb-4216621cb560
# ╠═1e169308-7388-4490-91f0-1f92dc408229
# ╟─dca9311b-8ee9-4eef-b658-df9011f9393a
# ╠═168af4ed-8d9d-4076-8d1f-910ecbdd9daa
# ╠═d82dab49-3cec-4269-94ae-e7b97d1a8b16
# ╟─93b7fbbf-f130-41f7-a126-26d2a423a3b2
# ╠═6e4bc8fc-38fd-46f7-a31d-519f166c60f7
# ╠═8c8e4794-f46a-4d05-b182-485ad85b5e8f
# ╠═31f9367a-88d3-466b-a3bf-299b5c6df316
# ╠═46617d7f-931a-4ce8-9f8a-05b726ef9a41
# ╟─4b10de39-8878-4298-869b-f7ef6585a132
# ╠═19fc8142-4a0b-4dda-8046-d57840ee9e7b
# ╟─eedd241f-5e81-49e2-83ca-3c3cfff77555
# ╠═4731e33d-5f40-4ded-86c7-e7ff241ce205
# ╟─925ae3f7-7d14-4964-80a1-339b8425c399
# ╟─d7e332be-fb7c-4de0-8eb6-ec60c035d1b3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

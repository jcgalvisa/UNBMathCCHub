### A Pluto.jl notebook ###
# v0.19.39

using Markdown
using InteractiveUtils

# ╔═╡ 191f2f52-f7f5-4b1b-85d1-883d40afbc50
using PlutoUI

# ╔═╡ 39ed3381-b89d-40a0-ab27-764982180e55
begin
	using Plots, LinearAlgebra, Optim, DifferentialEquations
	using HypertextLiteral, Distributions, Latexify, SpecialFunctions
	using Random, Roots,Statistics
end

# ╔═╡ 3d867eb9-6348-4f3b-813d-029884312c36
using SymPy;

# ╔═╡ 2cc6c5db-dae9-4056-8e86-c2cdd5413fd2
PlutoUI.TableOfContents(title="Ajuste de parámetros", aside=true)

# ╔═╡ 9a904b84-2c70-444d-a673-4327560d1226
md"""Este cuaderno esta en construcción y puede ser modificado en el futuro para mejorar su contenido. En caso de comentarios o sugerencias por favor escribir a jcgalvisa@unal.edu.co

Tu participación es fundamental para hacer de este curso una experiencia aún mejor."""

# ╔═╡ 3db89cf8-58b3-42e5-a1a7-a5ac40a78fdb
md"""Elaborado por Juan Galvis, Carlos Nosa y Yessica Trujillo. 
"""

# ╔═╡ c96c27e6-efbb-4ae4-ad1f-71a19af1a971
md"""Usaremos las siguientes librerías:"""

# ╔═╡ e263bad6-deb8-4dca-b147-57a9d4dd39bb
md"""# Introducción  
El ajuste de curvas o ajuste de datos consiste en buscar una relación entre ellos. Es decir, si tenemos datos correspondientes a dos variables, la idea es encontrar una relación que describa de manera precisa y concisa el comportamiento de dichos datos.

Para optimizar los valores de los parámetros del modelo, creamos una función que calcule el tamaño del desajuste entre los datos observados y los generados por los posibles modelos. Esta función recibe los datos y los valores válidos de los parámetros del modelo, y devuelve la norma del residuo. Podemos utilizar, por ejemplo, la medida de desajuste de mínimos cuadrados (norma Euclidiana). Posteriormente, empleamos una biblioteca de optimización para calcular el valor del parámetro óptimo aproximado.
"""

# ╔═╡ 33842891-3dbb-4b08-8160-346ffafe8619
md"""# Ajuste mediante mínimos cuadrados"""

# ╔═╡ c4c29fc7-5611-4b30-b15e-90f3fb86450a
md"""
Consideremos el siguiente ejemplo, donde tenemos datos sobre el crecimiento de un tumor en ratones. Estos datos y más información se encuentran en el trabajo "Modeling Cancer Growth with Differential Equations" de Jue Wang, del Departamento de Matemáticas de Union College, Schenectady NY 12308, USA.
"""

# ╔═╡ ba732df6-5923-4e4e-8b2d-35fe0d35e398
begin
	# Datos tomados del documento,  
	#Modeling Cancer Growth with Differential Equations
	# de Jue Wang, Department of Mathematics
	#Union College, Schenectady NY 12308 USA
	#wangj@union.edu
	
	Datos=[
	3.46	0.0158
	4.58	0.0264
	5.67	0.0326
	6.64	0.0445
	7.63	0.0646
	8.41	0.0933
	9.32	0.1454
	10.27	0.2183
	11.19	0.2842
	12.39	0.4977
	13.42	0.6033
	15.19	0.8441
	16.24	1.2163
	17.23	1.447
	18.18	2.3298
	19.29	2.5342
	21.23	3.0064
	21.99	3.4044
	24.33	3.2046
	25.58	4.5241
	26.43	4.3459
	27.44	5.1374
	28.43	5.5376
	30.49	4.8946
	31.34	5.066
	32.34	6.1494
	33.00	6.8548
	35.20	5.9668
	36.34	6.6945
	37.29	6.6395
	38.50	6.8971
	39.67	7.2966
	41.37	7.2268
	42.58	6.8815
	45.39	8.0993
	46.38	7.2112
	48.29	7.0694
	49.24	7.4971
	50.19	6.9974
	51.14	6.7219
	52.10	7.0523
	54.00	7.1095
	56.33	7.0694
	57.33	8.0562
	59.38	7.2268];
	
	tiempo=Datos[:,1];
	volumen=Datos[:,2];
	Datos
end

# ╔═╡ f44497fb-d866-4649-bd62-f19f1d2bc811
md"""Visualicemos dichos datos."""

# ╔═╡ 1394bd94-9e28-444a-b358-ea487ad06420
scatter(tiempo,volumen,ls=:dash,label="Volumen",lw=4, xlabel = "Tiempo",yaxis="Volumen")

# ╔═╡ 1f0dba89-0aad-4ede-a4a6-d005aad2b897
md"""## Modelo de von Bertalanffy"""

# ╔═╡ 172eb728-c084-4311-b75a-6177a36fb847
md"""
Para ilustrar el procedimiento, ajustaremos los datos a un modelo de ecuaciones diferenciales, el Modelo de von Bertalanffy, dicho modelo es usado para mostrar el crecimiento de tumores en el cuerpo. En lugar de crecer de manera constante, este modelo dice que el crecimiento del tumor se desacelera a medida que se hace más grande. 

El modelo es el siguiente 

$$V'= aV^\frac{2}{3}-bV,$$
donde $V$ es el tamaño del tumor en el tiempo $t$, $a$ es la velocidad máxima de crecimiento y $b$ es la tasa de muerte celular o retroceso del tumor.

Consideremos dicho modelo con la condición inicial $V_0=V(0)=0.0158$. Recordemos que deseamos hallar los valores óptimos de $a$ y $b$.
"""

# ╔═╡ 519ca1e3-ea1b-4d1b-af2d-d074531b502b
md"""Creamos una función para el modelo de Bertalanffy:"""

# ╔═╡ 1358c859-a74e-4738-bf50-4e4aca06770d
modeloBF(V,par,t)=par[1]*V.^(2/3)-par[2]*V

# ╔═╡ 21b98c71-3aa2-4438-ba4f-c830cfc6d709
md"""
Si queremos resolver la EDO para determinados valores de los parámetros, usamos, 
"""

# ╔═╡ 64281d01-c1dd-4f11-8397-21d01ecadd5f
begin
	tspan=(3.26,80)
	V₀=0.0158
	par=[1.0,1.0]
	EDO=ODEProblem(modeloBF,V₀,tspan,par)
	V=solve(EDO)
	plot(V)
#	VI=[V(t) for t in tiempo] # Evaluación de la solución en los tiempos dados (datos)
#	scatter!(tiempo,VI)
end

# ╔═╡ 5ac22392-143f-4531-a611-d8533610d07c
md"""
Ahora podemos escribir la función residuo del modelo de EDO. Es decir, cacular la norma entre el pronostico de una EDO con parametros dados y los datos. 
"""

# ╔═╡ 043dd8fc-da87-453b-ae29-10d72b933e06
function residuoBF(par,V,t)
  
  tspan=(3.26,80)
  V₀=0.0158
  EDO=ODEProblem(modeloBF,V₀,tspan,par)
  VSOL=solve(EDO)
  VI=[VSOL(t) for t in tiempo]
  res=V-VI
  nres=norm(res)
return nres
end

# ╔═╡ 7161401c-f87a-4939-9fa9-479c24931f06
md"""La función residuo arriba mide el desajuste (o tamaño del residuo) de la simulación de la EDO con respecto a los datos usando mínimos cuadrados, es decir, la norma euclidiana de la diferencia o residuo. 
**Asumimos que nuestro modelo de observación mide directamente el tamaño del tumor.  Es decir, el desajuste se mide directamente con la diferencia del modelo contra los datos.**


Por ejemplo el desajuste de usar $a=1$ y $b=1$ en el modelo es de:"""

# ╔═╡ 1a3a16df-b51e-4125-a895-fcaa02ad2403
residuoBF([1 1],volumen,tiempo)

# ╔═╡ ea1b3ecc-fa84-4ee0-8609-91b0106362f3
md"""
Como antes, escribimos una función solo del parámetro, 
"""

# ╔═╡ 5d4734ca-9c04-4c07-bc5b-6629b66a9c91
rBF(par) = residuoBF(par, volumen, tiempo)

# ╔═╡ d9bd8b60-858e-44fc-a510-cae1b865111e
md"""
Y podemos optimizar el valor de los parámetros
"""

# ╔═╡ 02be56ff-3585-4b7a-b0bc-ab42c43c773f
oBF=Optim.optimize(rBF, [.01,.01], NelderMead())

# ╔═╡ c4a90f6b-ba92-41d6-ae4b-e16f303c1bdd
oBF.minimizer

# ╔═╡ 3cf10c6c-05af-4508-b3f3-70de4d537acb
md"""
De esto se obtiene que da la EDO optima es
$V'=  0.396V^\frac{2}{3}- 0.194V.$

Después de calcular el valor del parámetro óptimo podemos mostrar el ajuste final de nuestro modelo. Como antes, podemos visualizar el ajuste comparandolo con los datos. Para esto tenemos, 
"""

# ╔═╡ 43eb9fc5-b762-4bd7-a540-ad35da34d7b9
md"""## Modelo Logistic Growth
 
Teniendo en cuenta los datos sobre el crecimiento de un tumor en ratones. Ajustemos dichos datos siguiendo el modelo Logistic Growth.
El modelo es el siguiente

$V'= aV\left(1-\frac{V}{b}\right),$

este modelo describe el crecimiento de poblaciones bajo ciertas condiciones. $V$ representa la población en el instante $t$, así $V'$ representa la tasa de cambio de la población con respecto al tiempo, $a$ es la tasa de crecimiento intrínseca de la población y $b$ es la capacidad de carga del entorno, es decir, el máximo tamaño de la población que el entorno puede soportar de manera sostenible. Así, la ecuación describe cómo la tasa de crecimiento de una población cambia a medida que la población se acerca a su capacidad máxima de carga en un entorno dado.

Consideremos dicho modelo con la condición inicial $V_0=V(0)=0.0158$. Recordemos que deseamos hallar los valores óptimos de $a$ y $b$.
"""

# ╔═╡ 79990d4e-08e1-4c75-896e-f4d9b9e7fefc
modeloLG(V,par,t)=par[1]*V*(1-V/par[2])

# ╔═╡ 280c6e4b-8db1-42c2-b157-dca7ed01965a
md"""Si deseamos encontrar la solución de la ecuación diferencial ordinaria para ciertos valores específicos de los parámetros, empleamos"""

# ╔═╡ d0290ed3-64bc-4b8b-9e4f-665e33c33014
begin
	tspan₂=(3.26,80)
	V0₂=0.0158
	par₂=[1.0,1.0]
	EDO₂=ODEProblem(modeloLG,V0₂,tspan₂,par₂)
	V₂=solve(EDO₂)
	plot(V₂)
end

# ╔═╡ 9cbe41df-cfd5-4e04-980e-c5bb60865a6d
md"""La función residuo mide el desajuste (o tamaño del residuo) de la simulación de la ecuación diferencial ordinaria con respecto a los datos usando mínimos cuadrados, es decir, la norma euclidiana de la diferencia o residuo."""

# ╔═╡ 1bd9636d-5006-47db-835e-4bed32a33753
function residuoLG(par₂,V₂,t₂)
   	tspan₂=(3.26,80)
  	V0₂=0.0158
 	EDO₂=ODEProblem(modeloLG,V0₂,tspan₂,par₂)
  	VSOL₂=solve(EDO₂)
  	VI₂=[VSOL₂(t) for t in tiempo]
  	res₂=V₂-VI₂
  	nres₂=norm(res₂)
	return nres₂
end

# ╔═╡ 8ae541e7-951f-455e-8b33-f1966941a775
md"""Por ejemplo el desajuste de usar $a=1$ y $b=1$ en el modelo es de:"""

# ╔═╡ 471bd66e-5032-4de9-b99a-e38eb675f641
residuoLG([1 1],volumen,tiempo)

# ╔═╡ 6502f975-7542-405f-8013-d0662bfcff32
md"""Ahora, usemos optimización para calcular el valor del parámetro óptimo aproximado. Para esto creamos una función solo del parámetro,"""

# ╔═╡ d98fa069-d933-4ee4-94a6-7f33512c39cf
rLG(par₂) = residuoLG(par₂, volumen, tiempo)

# ╔═╡ 63aa2cc1-8f73-4efb-91c7-a1a73321dc6e
md"""y, optimizamos su valor"""

# ╔═╡ afd8e5f0-9088-4364-98e6-e2573c207f31
oLG=Optim.optimize(rLG, [.01,.01], NelderMead())

# ╔═╡ 57422995-5a2f-4990-a90a-48571ebc0db5
oLG.minimizer

# ╔═╡ 819d0789-c0c2-40ab-87ab-c9ad7c87538d
md"""Obteniendo así que los valores optimos para $a$ y $b$ son $0.297$ y $7.012$, respectivamente. 

Luego 
$V'= 0.3V\left(1-\frac{V}{7.01}\right).$
Después de calcular el valor del parámetro óptimo podemos mostrar el ajuste final de nuestro modelo. """

# ╔═╡ 565b66b9-ed1b-4013-a6c0-77038dd09530
begin
	oLGm=oLG.minimizer
	EDOoptima₂=ODEProblem(modeloLG,V0₂,tspan,oLGm)
	VEDOoptima₂=solve(EDOoptima₂)
	plot(VEDOoptima₂,lw=5,label="EDO optima")
	scatter!(tiempo,volumen,ls=:dash,label="Volumen",lw=4, xlabel = "Tiempo",yaxis="Volumen",legend=:bottomright)
end

# ╔═╡ 681946a2-a574-4a3d-aa94-87fad31aa6a8
md""" # Estimación de parámetros usando técnicas bayesianas"""

# ╔═╡ b1c5a491-c18e-4f1c-af08-b9988813bebe
md""" ## Introducción a la estimación de parámetros


A continuación, se introducirán algunos conceptos importantes relacionados con probabilidad y estadística que son necesarios para el entendimiento de los ejemplos realizados para  el modelo logístico. Para ello, se supondrá que el lector tiene ya algunos conocimientos previos de probabilidad.

En primer lugar, recordemos algunas de las nociones básicas definidas en el curso de probabilidad. Estas se desarrollarán desde los eventos probabilísticos para dar una primera idea, y después se procederá a dar su definición desde las variables aleatorias.

**$\bullet$ Probabilidad condicional:** Sea $(\Omega,\mathfrak{F},P)$ un espacio de probabilidad, si $A,B\in\mathfrak{F}$ tales que $P(B)>0$ entonces se define la probabilidad de $A$ bajo la condición de $B$ como:

$$P(A|B):=\frac{P(A\cap B)}{P(B)}$$

Es decir, se mide la probabilidad que tiene un evento $A$ dado que se ha observado la ocurrencia de un evento $B$.

*Ejemplo:* 

Suponga que se quiere estudiar la probabilidad de que una persona fume dado que tiene menos de 25 años, para ello se realiza lo siguiente: """

# ╔═╡ 261d27e2-6240-4047-afa7-f2f9a4af396c
begin
##Generamos una muestra aleatoria.
	
num_muestra=1000
edad=rand(10:80,num_muestra) #Edades de las personas.
fuman=rand([true,false],num_muestra) #Si fuman o no.

#Se cuentan el número de personas que fuman y que tienen menos de 25 años y se hallan las probabilidades.
	
p_25yfum=count(x->x[1]<25 && x[2]==true,zip(edad,fuman))/num_muestra
p_25=sum(edad.<25)/num_muestra

#Se halla la probabilidad condicional.

pfum_dado_25=p_25yfum/p_25	
println("Entonces la probabilidad de que una persona fume dado que tiene menos de 25 años es $pfum_dado_25. ")	

end

# ╔═╡ 913ad931-b08c-47df-ae0d-5d1f6f216453
md""" **$\bullet$ Regla de Bayes:** Sea $\{A_1,A_2,\cdots,A_n\}$ un conjunto de eventos mutuamente excluyentes que conforman una partición del conjunto $\Omega$, tales que $P(A_i)>0$ y sea $B$ un evento tal que $P(B)>0$, entonces se tiene que:

$$P(A_i|B):=\frac{P(A_i)\cdot P(B|A_i)}{\sum_{i=1}^{n}P(B|A_i)\cdot P(A_i)}$$

En este punto, pasamos a definir lo que sigue basándonos en las variables aleatorias. Con este proposito, recordemos que un vector aleatorio es simplemente un vector de variables aleatorias definidas sobre el mismo espacio de probabilidad. Con esto en mente se define lo siguiente.

**$\bullet$ Función de densidad conjunta de un vector aleatorio (bajo independencia):**  Sea $\textbf{X}=(X_1,X_2,\cdots,X_n)$ un vector aleatorio, si dicho vector aleatorio está conformado por variables aleatorias independientes dos a dos, se tiene que su función de densidad conjunta está dada por:

$$f_{\textbf{X}}(\textbf{x})=f_{X_1}(x_1)\cdot f_{X_2}(x_2)\cdots f_{X_n}(x_n)$$ 

En donde $f_{X_{i}}(x_i)$ denota la función de densidad  de la variables aleatorias $X_i$.

En general, se notará a la función den densidad conjunta de un vector aleatorio discreto como $p_{\textbf{X}}(\textbf{x})$ y de un vector aleatorio continuo como $f_{\textbf{X}}(\textbf{x})$. Además, recuerde que la función de densidad conjunta no solo está definida para vectores con variables aleatorias independientes; sin embargo, para los propositos de este notebook, se realiza dicha suposición.

*Ejemplo:* 

Tome un vector aleatorio de $3$ variables que son independientes dos a dos, suponga que la primera variable se distribuye normal estandar, la segunda se distribuye de manera exponencial con parámetro $\lambda$ y la tercera tiene una distribución beta con parámetros $\alpha,\beta$.

Entonces su función de densidad conjunta está dada por:
"""

# ╔═╡ 10c4a587-b0db-4a73-b42f-14c9621815e0
begin
@syms x y z

#Se definen los parámetros de las distribuciones	
λ=rand()
α=rand()*10
β=rand()*10

#funciones de densidad	
f_X=1/sqrt(2*π)*exp((-1/2)*(x^2))
f_Y=λ*exp(-λ*y)
f_Z=(z^(α-1)*(1-z)^(β-1))/beta(α,β)


#funcion de densidad conjunta	
fconj=f_X*f_Y*f_Z
str1="f(X,Y,Z)=$fconj"
latex_Ex=latexify(str1)
	
end

# ╔═╡ ab3bc822-3432-4598-8191-01e20f63ca1c
md""" 
Teniendo en cuenta las definiciones anteriores, podemos introducir la noción de función de densidad condicional para las  variables aleatorias $X$ y $Y$. Este concepto se fundamentará principalmente en lo previamente establecido sobre probabilidad condicional. Nótese así que, esta es solo una generalización a las variables aleatorias.

**$\bullet$ Función de densidad condicional:** 

Sean $X$ y $Y$ dos variables aleatorias, si estas son variables aleatorias discretas, se define la función de densidad condicional de $X$ dado $Y=y$ (claramente $y$ se encuentra dentro del rango de $Y$, es decir, $P(Y=y)>0$) como se sigue,

$$f_{X|Y}(x|y)=P(X=x|Y=y)=\frac{P(X=X,Y=y)}{P(Y=y)}$$

Donde, se entiende que $P(X=x,Y=y)$ es la función de densidad conjunta de $X,Y$.

Ahora, para el caso en el que $X$ y $Y$ son variables aleatorias continuas, se define la función de densidad condicional de $X$ dado $Y=y$ como

$$f_{X|Y}(x|y)=\frac{f(x,y)}{f_{Y}(y)}$$

En donde, se entiende que $f(x,y)$ es la función de densidad conjunta de $X,Y$ y $f_{Y}(y)$ es la función de densidad de la variable aleatoria $Y$.

Siendo así, también se puede generalizar la regla de Bayes para funciones de densidad condicionales como se realizaba en el caso de los eventos probabilisticos.

**$\bullet$ Regla de Bayes:**

La función de densidad condicional de la variable aleatoria $Y$ dado $X=x$ está dada por 

$$f_{X|Y}(x|y)=\frac{f(y,x)}{f_{Y}(y)}$$ 

Pero, también se tiene que 

$$f_{Y|X}(y|x)=\frac{f(x,y)}{f_{X}(x)}\hspace{3mm}\Rightarrow \hspace{3mm} f(x,y)=f_{Y|X}(y|x)f_{X}(x)$$

Adicionalmente, observe que $f_{Y}(y)$ se puede escribir como una función de densidad marginal mediante:

$$f_{Y}(y)=\int_{-\infty}^{\infty} f(x,y)dx$$ 

Por lo tanto, al reemplazar en la definición dada anteriormente, se obtiene que 

$$f_{X|Y}(x|y)=\frac{f_{Y|X}(y|x)f_{X}(x)}{\int_{-\infty}^{\infty}f_{Y|X}(y|x)f_{X}(x)}$$

Para visualizarlo de mejor manera, observe el siguiente ejemplo. Suponga que quiere hallar la función de densidad condicional  $P(X_1| X_2=0.4)$  en donde el vector aleatorio tiene función de densidad conjunta normal-bivariada.
"""

# ╔═╡ c8922fad-0123-42ea-94d7-81379b4ff3ad
begin
# Se definen los parámetros, la media y la matriz de covarianza
μ₁=rand(0:10)
μ₂=rand(0:10)	
media = [μ₁, μ₂]
covarianza = [2 1; 1 3]

# Distribuciones
distribucion_bivariante = MvNormal(media, covarianza)
dist_marginal=Normal(μ₂,3)	

# Función de densidad conjunta
pdf_conjunta(x1, x2) = pdf(distribucion_bivariante, [x1, x2])

# Función de densidad condicional f(X1 | X2 = 0.4)
function densidad_condicional(x1)
	pdf_conjunta(x1, 0.4) / pdf(dist_marginal,0.4)
end 

# Crear un rango de valores para X1
rango_x1 = range(-5, stop=10, length=100)

# Calcular la función de densidad condicional para cada valor de x_1
pdf_condicional = [densidad_condicional(x1) for x1 in rango_x1]

# Graficar la función de densidad condicional
plot(rango_x1, pdf_condicional, xlabel="X1", ylabel="f(X1 | X2=0.4)", label="Densidad condicional", legend=:topleft)

end

# ╔═╡ dafdb4f3-f49e-4645-b58c-16eb63954b1b
md"""En este punto, concluye la introducción necesaria, que junto con algunas bases previas vistas en el curso de probabilidad, proporcionan el fundamento necesario para entender la siguiente parte: la estimación de los parámetros. En este contexto, entra en juego la estadística, en este caso, nos interesa la estimación de ciertos parámetros $\theta$ de manera puntual, por esto, se enuncian las siguientes definiciones.

**$\bullet$ Función de verosimilitud**

Sean $X_1,X_2,X_3,\cdots,X_n$ una sucesión de variables aleatorias identicamente distribuidas, pero no necesariamente independientes. La función de verosimilitud es una función del vector de parámetros relacionada con la función de densidad conjunta de la muestra mediante la siguiente expresión:

$$L(\theta|x)=\left\{\begin{matrix}f_{X}(x,\theta) &\text{ Si \textbf{X} es continuo}\\ p_{X}(x,\theta)=p_{x}(x,\theta) &\text{ Si \textbf{X} es discreto}\\\end{matrix}\right.$$

Ahora, recordemos que una muestra aleatoria no es más que una sucesión de variables aleatorias independientes dos a dos, definidas en el mismo espacio de probabilidad e identicamente distribuidas. Así, se puede definir la función de verosimilitud de la muestra como se sigue,

$$L(\theta|x_1,x_2,\cdots,x_n)=\prod_{i=1}^{n}f_{X_{i}}(x_i,\theta)$$

Adicionalmente, observe que si se conocen los datos muestrales $x_i$ entonces la probabilidad condicional $P(x|\theta)$ puede ser considerada como una función de $\theta$, esta función se toma precisamente como la función de verosimilitud de $\theta$ dado $x$ que se escribe como $L(\theta|x)$  y por tanto se puede usar la regla de bayes, en donde se tendrá que:

$$P(\theta|x)= \frac{ L(x|\theta)\cdot P_{\Theta}(\theta)}{\int_{\theta}L(x|\theta)\cdot P_{\Theta}(\theta)}$$

Así;

$$P(\theta|x)\propto L(x|\theta)\cdot P_{\Theta}(\theta)$$


¡Ahora si! Se entra en el campo de la estimación. El siguiente método es bastante frecuente en la estadistica frecuentista, puesto que el estimador generado tiene unas propiedades bastante deseables, estas son; la consistencia, la eficiencia y una distribución normal asintótica. Esto quiere decir que a medida que aumenta el tamaño de la muestra, el estimador tiende a acercarse al valor verdadero del parámetro con una varianza mínima.

**$\bullet$ Estimanción frecuentista (Máximo verosimil-MLE):** Se dice que un estimador $\hat{\theta}=\hat{\theta}(X_1,\cdots,X_n)$ del parámetro $\theta$ es el estimador máximo verosimil si $\hat{\theta}(x_1,\cdots,x_n)$ es el valor que máximiza a la función $L(\theta,x_1,\cdots,x_n)$. En este caso, por propiedades de la función logaritmo, se suele máximizar la log-verosimilitud, que es simplemente la aplicación del logaritmo a la función $L(\theta)$. 

Suponga que tenemos una muestra y que se tiene la creencia que esta se distribuye de forma normal, entonces queremos estimar el valor de los parámetros asociados a esta, es decir, la media ($\mu$) y la varianza($\sigma$), para estimarlos utilizaremos el MLE , no es dificil ver que en este caso $\hat{\mu}_{MLE}=\bar{x}$ y que $\hat{\sigma}_{MLE}=s$ (tome el vector aleatorio de variables aleatorias normales e independientes, halle su función de densidad conjunta, apliquele logaritmo y seguido a esto derive con respecto a $\mu$ e iguale a $0$, haga el mismo proceso con $\sigma$). 

"""

# ╔═╡ 1f733c09-b663-49df-a68f-fc5ecf5f06c5
begin
#Datos de la muestra	
Random.seed!(123)  
muestra₁= rand(100) 	

# Función de log-verosimilitud para una distribución normal

@syms mu, sigma	

n=length(muestra₁)
suma_cuadrados = sum((x - mu)^2 for x in muestra₁)
log_verosimil=-n/2 * log(2π) - n/2 * log(sigma^2) - 1/(2*sigma^2) *suma_cuadrados

# Puntos criticos candidatos para máximo.	
log_x=diff(log_verosimil,mu)
log_y=diff(log_verosimil,sigma)	

puntos_criticos = solve([log_x, log_y], [mu, sigma])	

println("Estimador MLE para para los parámetros: ", puntos_criticos) 
	
end

# ╔═╡ 8612f130-8559-41ae-bf4f-c7b22800bce5
md"""Podemos comparar dichas estimaciones con los valores de la media muestral y la desviación estandar muestral para darnos cuenta que en efecto, estos son los valores de los  parámetros."""

# ╔═╡ 3f42f911-825d-458e-a4a1-2bffc0bd3b46
begin
#Ya conociamos que los MLE son la media y la desviación estandar muestrales:
function estimador_maxverosimil(datos)
    mu_hat= mean(datos)
    sigma_hat = std(datos)
    return mu_hat, sigma_hat
end

# Calcular los estimadores de máxima verosimilitud para la muestra de datos
mu_mle, sigma_mle = estimador_maxverosimil(muestra₁)

# Mostrar los resultados
println("Estimador MLE para la media (mu): ", mu_mle)
println("Estimador MLE para la desviación estándar (sigma): ", sigma_mle)
end

# ╔═╡ c33e2bfb-798c-4e15-a9ba-0e1404f6eb34
md"""
Sin embargo, el enfoque utilizado en los ejemplos predecesores, no es unicamente el enfoque frecuentista de la estimación. De hecho también se realizan estimaciones con el enfoque Bayesiano, así se pasa a definir el segundo estimador.


**$\bullet$ Enfoque Bayesiano:**

Sea $X_1,X_2,\cdots,X_n$ una muestra aleatoria de una población con función de densidad $f(X,\Theta)$ y función de densidad conocida (a priori) $f_{\Theta}(\theta)$. El estimador bayesiano para la imagen de $\theta$ bajo una función $g$, respecto a la función a priori de $\theta$ está dado por:

$$E[g(\theta)|X_1,\cdots,X_n]=\frac{\int_{-\infty}^{\infty}g(\theta)L(x|\theta)f_{\Theta}(\theta)}{\int_{-\infty}^{\infty}L(x|\theta)f_{\Theta}(\theta)}$$

Finalizamos así esta pequeña introducción a la estimación de parámetros.
"""

# ╔═╡ 97435cc8-95ca-45eb-abeb-8fee0db7d651
md"""## Modelo de Von Bertanlanffy

Recordemos que el modelo es el siguiente 

$$V'= aV^\frac{2}{3}-bV,$$
donde $V$ es el tamaño del tumor en el tiempo $t$, $a$ es la velocidad máxima de crecimiento y $b$ es la tasa de muerte celular o retroceso del tumor.

La condición inicial del problema es $V_0=V(0)=0.0158$. Recordemos que deseamos hallar los valores óptimos de $a$ y $b$."""

# ╔═╡ baeb53bb-cc5a-4e34-a560-8ee87198bfab
md"""
La solución exacta a este problema de valor inicial es:

$$V(t) = V(t;a,b),$$
es decir, la solución a este problema que cambia a lo largo del tiempo $t$ y tiene como parámetro a un valor fijo de $a$ y $b$.

Vamos a suponer que los datos tomados $\{z_{\ell}\}_{\ell=1}^{45}$ a lo largo del tiempo $\{t_{\ell}\}_{\ell=1}^{45}$ son realizaciones aleatorias de una distribución $Normal(\mu,\sigma^2)$ con media $\mu$ y varianza $\sigma^2 \mu^2$. Como queremos comparar el ajuste del modelo en los datos $\{z_{\ell}\}_{\ell=1}^{45}$ asumimos que la $\mu= V(t;a,b)$ y $\sigma^2=1$.
Para los parámetros suponemos que a priori $a\sim Normal(0.5,1)$ y $b\sim Normal(0.5,1)$
"""

# ╔═╡ 4851cddc-4f29-426e-a940-b0f955dd2152
md"""La siguiente función resuelve ecuaciones diferenciales ordinarias usando el método de Euler."""

# ╔═╡ 9f379a94-fab6-4e9f-8a6c-45326f9ba041
begin
	function MetEuler(f, p, y0, t0, tn, h)
	    # f: función que define la EDO dy/dt = f(t, y; p)
	    # y0: condición inicial
	    # t0: tiempo inicial
	    # tn: tiempo final
	    # h: tamaño del paso
	    # p: parámetros de la función f
	
	    # Número de pasos
	    n_steps = Int((tn - t0) / h)
	    
	    t_values = zeros(n_steps + 1)
	    y_values = zeros(n_steps + 1)
	
	    # Condiciones iniciales
	    t_values[1] = t0
	    y_values[1] = y0
	
	    # Método de Euler
	    for i in 1:n_steps
	        t_values[i + 1] = t_values[i] + h
	        y_values[i + 1] = y_values[i] + h * f(t_values[i], y_values[i],p)
	    end
	
	    return t_values, y_values
	end
	
	function MetEulerT(f, p, y0, t)
	    # f: función que define la EDO dy/dt = f(t, y; p)
	    # y0: condición inicial
	    # t: arreglo que para el tiempo
	    # p: parámetros de la función f
	
	    # Número de pasos
	    n_steps = size(t)[1]-1
	    
	    t_values = t
	    y_values = zeros(n_steps + 1)
	
	    # Condiciones iniciales
	    y_values[1] = y0
	
	    # Método de Euler
	    for i in 1:n_steps
	        h = t[i+1]-t[i]
	        y_values[i + 1] = y_values[i] + h * f(t_values[i], y_values[i],p)
	    end
	
	    return y_values
	end
	
	#Lado derecho de la ecuación diferencial
	function rhs_ED(t,x,p)
	    a = p[1]
	    b = p[2]
	    return a*(abs(x)^(2/3))-b*x
	end
	#Punto inicial del volumen
	V0=0.0158
	#Solución numérica
	function sol_num_ED(p)
	    a = p[1]
	    b = p[2]
	    return MetEulerT(rhs_ED, [a, b], V0, tiempo)
	end
end

# ╔═╡ 4c41dfed-ca3e-4515-a0e7-40e7489d1faf
begin
#	tspan=(3.26,80)
#	V0=0.0158
	oBFm=oBF.minimizer
	EDOoptima=ODEProblem(modeloBF,V0,tspan,oBFm)
	VEDOoptima=solve(EDOoptima)
	plot(VEDOoptima,lw=5,label="EDO optima")
	scatter!(tiempo,volumen,ls=:dash,label="Volumen",lw=4, xlabel = "Tiempo",yaxis="Volumen",legend=:bottomright)
end

# ╔═╡ 04edbbc3-041d-45ea-b770-46eb127419aa
md""" En el siguiente fragmento de código se ejecuta el algoritmo de MH. Se hace una pequeña modificación para tener en cuenta la condición del soporte en que deben estar los parámetros $a$ y $b$."""

# ╔═╡ 6acfd215-a4e3-4f1b-b2c4-91461377e706
begin
	function MHRW0(np,logenergia,soporte,puntoincial,sd=0.1,iteraciones=10000)
    #np es el número de parámetros a estimar
    #Se usa logenergia para controlar posibles errores numéricos 
    #log energía solo debe depender del vector de parámetros 
    #sd: desviación estándar del camino aleatorio
    samples = rand(np) 
    probabilities = [exp(logenergia(samples[:,end]))]

    Alpha = [0] # tasa de aceptación
    #sd: desviación estándar del camino aleatorio

    # MHRW
    for i in 1:iteraciones
        # Construcción de nuevas muestras con un camino aleatorio normal
        theta = samples[:,end]+ sd*randn(np)
        # Condición del soporte
        if soporte(theta) == false
            alpha = 0
            p2 = exp(logenergia(samples[:,end]))
        else
            p1 = exp(logenergia(theta))
            p2 = exp(logenergia(samples[:,end]))
            alpha = min(1, p1/p2)
        end 

        
        Alpha = hcat(Alpha,alpha)
        u = rand()
        #Selección de muestras
        if u < alpha
            samples = hcat(samples, theta)
            probabilities = hcat(probabilities,p1)
        else
            samples = hcat(samples, samples[:,end])
            probabilities = hcat(probabilities,p2)
        end
    end
    #Sistematic sampling
    initial_position = floor(100*rand())
    leap = 20
    samples_ss = samples[:, Int(initial_position):leap:end]
    probabilities_ss = probabilities[Int(initial_position):leap:end];

    #Estimations
    max_prob, position_ss = findmax(probabilities_ss)
    Max_likelihood = samples_ss[:, position_ss]
    Mean = mean(samples_ss, dims=2)
    return (Max_likelihood,max_prob,Mean,samples_ss,probabilities_ss,Alpha)
	end
end

# ╔═╡ f24cc905-c0af-482c-8add-eddb80607dc1
#Energía
	function energiaEDO(p) #log de la posterior
	    a = p[1]
	    b = p[2]
		mu = sol_num_ED(p)
	    #logverosimilitud gaussiana
		log_likelihood = sum(logpdf.(Normal.(mu,0.05),volumen))
		
	    #log a priori
	    log_priori = logpdf(Normal(0.5,1), a) + logpdf(Normal(0.5,1), b)
	
	    return  (log_likelihood + log_priori)*1E-3 
	end

# ╔═╡ 9a0dd382-0e83-46c0-85b9-efe10dba5a75
md""" Para que en el algoritmo de Metropolis-Hastings sea 'más sencillo' ejecutar el camino aleatorio que seguirán los parámetros serán los siguientes: """

# ╔═╡ a482eac4-ac19-437a-905d-441064c6c678
function support₂(pa)
	    # soporte de los parametros ""
	    rt = true
	    rt &= (0.0 < pa[1] < 1.0)
	    rt &= (0.0 < pa[2] < 1.0)
	    return rt
	end

# ╔═╡ f4468684-2f96-42b0-96a0-90639f0e4ebe
md"""Los contornos de la función de energía son mostrados a continuación."""

# ╔═╡ ad5879a7-e89d-4fd8-b31a-770e5419260c
begin
	f₂(x, y) = energiaEDO((x,y))
	
	x_range0 = 0.01:0.01:1
	y_range0 = 0.01:0.01:1
	
	# Inicializar matrices para la malla
	mesh_x0 = zeros(length(x_range0), length(y_range0))
	mesh_y0 = zeros(length(x_range0), length(y_range0))
	# Llenar las matrices de la malla con valores de x e y
	for i in 1:length(x_range0)
	    for j in 1:length(y_range0)
	        mesh_x0[i, j] = x_range0[i]
	        mesh_y0[i, j] = y_range0[j]
	    end
	end
	# Evaluar la función en cada punto de la malla
	z_values0 = f₂.(mesh_y0, mesh_x0)
	# Crear el gráfico de contornos
	contour(x_range0, y_range0, exp.(z_values0), levels=200, color=:viridis, xlabel="a", ylabel="b", title="Contornos de energía")	     
end

# ╔═╡ 8d550296-d82e-4949-9421-01354d63425e
begin
	Max_likelihood0,max_prob0,Mean0,samples0,probabilities0,Alpha0 = MHRW0(2,energiaEDO,support₂,rand(2),0.005,20000);
	println("Máximo a posteriori: ",Max_likelihood0)
	println("Media condicional: ", Mean0)
end

# ╔═╡ 9e087ad2-9bc7-4b66-9a7c-0200731853f6
md"""
La distribución de cada uno de los parámetros se muestra a continuación.
"""

# ╔═╡ f59b9534-1051-4f15-bed5-13488dfe6d62
begin
	p10 = histogram(samples0[1,:],bins=50,label=false,color="red",xlim=(0,1),title="Histograma para a")
	p10 = plot!([Mean0[1], Mean0[1]], [0,100],linewidth=2,color="orange", label="Media Condicional")
	p10 = plot!([Max_likelihood0[1], Max_likelihood0[1]], [0,100],linewidth=2,color="green", label="Max a Posteriori")
	
	p20 = histogram(samples0[2,:],bins=50,label=false,color="blue",xlim=(0,1),title="Histograma para b")
	p20 = plot!([Mean0[2], Mean0[2]], [0,100],linewidth=2,color="orange", label="Media condicional")
	p20 = plot!([Max_likelihood0[2], Max_likelihood0[2]], [0,100],linewidth=2,color="green", label="Max a Posteriori")

	plot(p10,p20, layout=(1,2),size=(900,400))
end

# ╔═╡ 90ce15a3-304c-45a7-afaf-a9ff914fe07a
md"""La siguiente gráfica muestra el camino aleatorio."""

# ╔═╡ 798291b8-9488-44db-9aad-9dc557931c3d
begin
	p60 = contour(x_range0, y_range0, exp.(z_values0), levels=200, color=:viridis, xlabel="a", ylabel="b",title="Camino aleatorio")
	p60 = plot!(samples0[1,:],samples0[2,:],label=false)
end

# ╔═╡ a50b3a49-4b81-4843-bfaa-e6273a2835a4
md"""El ajuste de los parámetros se muestra en el siguiente gráfico. En este caso, la variabilidad del modelo es baja, ya que las muestras (mostradas por las gráficas grises) de cada uno de los parámetros están cerca de los datos. Además, los valores del máximo a posteriori y de la media condicional se encuentran cercanos, lo que indica que los datos se ajustan de manera óptima al modelo y existe una baja variabilidad en la predicción."""

# ╔═╡ 7c231cf4-d2e6-4819-86f7-d7b0231d45f9
begin
	p80 = plot(tiempo,sol_num_ED(samples0[end-1,:]),
	    color="gray82",title="MHRW",label="Muestras",z=1,size=(1000, 600),ylim= (0,10))
	for j=1:10:(size(samples0)[2]-1)
	   p80 = plot!(tiempo,sol_num_ED((samples0[:,j][1],samples0[:,j][2])),color="gray82",label=false,z=1)
	end
	p80 = scatter!(tiempo, volumen,label="Datos")
	p80 = plot!(tiempo, sol_num_ED((Max_likelihood0[1],Max_likelihood0[2])),color="green",label="X_MAP")
	p80 = plot!(tiempo, sol_num_ED((Mean0[1],Mean0[2])),color="orange",label="X_CM")
end

# ╔═╡ 1a52f2b3-9aaf-402d-8d4c-b1a6b1a65e45
md"""
# Referencias

[1] Driscoll, T. A., & Braun, R. J. (Year). Fundamentals of Numerical Computation. Retrieved from https://tobydriscoll.net/fnc-julia/frontmatter.html

[2] Sullivan, E. (2020). Numerical Methods: An Inquiry-Based Approach With Python.

[3] Bulirsch, R., Stoer, J., & Stoer, J. (2002). Introduction to Numerical Analysis (Vol. 3). Heidelberg: Springer.

[4] Stewart, G. W. (1996). Afternotes on Numerical Analysis. Society for Industrial and Applied Mathematics.

[5] Quarteroni, A., Saleri, F., & Gervasio, P. (2006). Scientific Computing with MATLAB and Octave (Vol. 3). Berlin: Springer.

[6] Last name, Initials. (Year). Machine Learning and Data Mining [Lecture Notes]. Retrieved from http://www.dgp.toronto.edu/~hertzman/411notes.pdf

[7] Last name, Initials. (Year). Deep Learning [Lecture Slides]. Retrieved from https://www.deeplearningbook.org/lecture_slides.html

[8] Mayorga, A. J. H. (2004). Inferencia estadística. Universidad Nacional de Colombia.

[9] Blanco Castañeda, L. (2004). Probabilidad. Universidad Nacional de Colombia.

[10] Kaipio, J., & Somesalo, E. (2004). Statistical and Computational Inverse Problems. Springer.

[11] Häggström, O. (2002). Finite Markov Chains and Algorithmic Applications. Cambridge University Press."""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DifferentialEquations = "0c46a032-eb83-5123-abaf-570d42b7fbaa"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
Latexify = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Optim = "429524aa-4258-5aef-a3af-852621145aeb"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Roots = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"

[compat]
DifferentialEquations = "~7.10.0"
Distributions = "~0.25.107"
HypertextLiteral = "~0.9.5"
Latexify = "~0.16.2"
Optim = "~1.9.2"
Plots = "~1.39.0"
PlutoUI = "~0.7.58"
Roots = "~2.1.2"
SpecialFunctions = "~2.3.1"
SymPy = "~2.0.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "71cbc2c94e0fa561dc05d106344f1ca650cc8a54"

[[deps.ADTypes]]
git-tree-sha1 = "016833eb52ba2d6bea9fcb50ca295980e728ee24"
uuid = "47edcb42-4c32-4615-8424-f2b9edc5f35b"
version = "0.2.7"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0f748c81756f2e5e6854298f11ad8b2dfae6911a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.0"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "LinearAlgebra", "MacroTools", "Markdown", "Requires", "Test"]
git-tree-sha1 = "c0d491ef0b135fd7d63cbc6404286bc633329425"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.36"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cde29ddf7e5726c9fb511f340244ea3481267608"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.7.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra", "Requires", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "16267cf279190ca7c1b30d020758ced95db89cd0"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.5.1"

[[deps.ArrayLayouts]]
deps = ["FillArrays", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "2aeaeaff72cdedaa0b5f30dfb8c1f16aefdac65d"
uuid = "4c555306-a7a7-4459-81d9-ec55ddd5c99a"
version = "1.7.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.BandedMatrices]]
deps = ["ArrayLayouts", "FillArrays", "LinearAlgebra", "PrecompileTools", "SparseArrays"]
git-tree-sha1 = "0b816941273b5b162be122a6c94d706e3b3125ca"
uuid = "aae01518-5342-5314-be14-df237901396f"
version = "0.17.38"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "f1dff6729bc61f4d49e140da1af55dcd1ac97b2f"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.5.0"

[[deps.BitFlags]]
git-tree-sha1 = "2dc09997850d68179b69dafb58ae806167a32b1b"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.8"

[[deps.BitTwiddlingConvenienceFunctions]]
deps = ["Static"]
git-tree-sha1 = "0c5f81f47bbbcf4aea7b2959135713459170798b"
uuid = "62783981-4cbd-42fc-bca8-16325de8dc4b"
version = "0.1.5"

[[deps.BoundaryValueDiffEq]]
deps = ["ArrayInterface", "BandedMatrices", "DiffEqBase", "FiniteDiff", "ForwardDiff", "LinearAlgebra", "NonlinearSolve", "Reexport", "SciMLBase", "Setfield", "SparseArrays", "TruncatedStacktraces", "UnPack"]
git-tree-sha1 = "f7392ce20e6dafa8fee406142b1764de7d7cd911"
uuid = "764a87c0-6b3e-53db-9096-fe964310641d"
version = "4.0.1"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9e2a6b69137e6969bab0152632dcb3bc108c8bdd"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+1"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CPUSummary]]
deps = ["CpuId", "IfElse", "PrecompileTools", "Static"]
git-tree-sha1 = "601f7e7b3d36f18790e2caf83a882d88e9b71ff1"
uuid = "2a0fbf3d-bb9c-48f3-b0a9-814d99fd7ab9"
version = "0.2.4"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "a4c43f59baa34011e303e76f5c8c91bf58415aaf"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.0+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "575cd02e080939a33b6df6c5853d14924c08e35b"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.23.0"

[[deps.ChangesOfVariables]]
deps = ["InverseFunctions", "LinearAlgebra", "Test"]
git-tree-sha1 = "2fba81a302a7be671aefe194f0525ef231104e7f"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.8"

[[deps.CloseOpenIntervals]]
deps = ["Static", "StaticArrayInterface"]
git-tree-sha1 = "70232f82ffaab9dc52585e0dd043b5e0c6b714f1"
uuid = "fb6a15b2-703c-40df-9091-08a04967cfa9"
version = "0.1.12"

[[deps.CodecBzip2]]
deps = ["Bzip2_jll", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "9b1ca1aa6ce3f71b3d1840c538a8210a043625eb"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.8.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "59939d8a997469ee05c4b4944560a820f9ba0d73"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.4"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "67c1f244b991cad9b0aa4b7540fb758c2488b129"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.24.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.CommonEq]]
git-tree-sha1 = "6b0f0354b8eb954cdba708fb262ef00ee7274468"
uuid = "3709ef60-1bee-4518-9f2f-acd86f176c50"
version = "0.2.1"

[[deps.CommonSolve]]
git-tree-sha1 = "0eee5eb66b1cf62cd6ad1b460238e60e4b09400c"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.4"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "TOML", "UUIDs"]
git-tree-sha1 = "c955881e3c981181362ae4088b35995446298b80"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.14.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"

[[deps.ConcreteStructs]]
git-tree-sha1 = "f749037478283d372048690eb3b5f92a79432b34"
uuid = "2569d6c7-a4a2-43d3-a901-331e8e4be471"
version = "0.2.3"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "6cbbd4d241d7e6579ab354737f4dd95ca43946e1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.1"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "51cab8e982c5b598eea9c8ceaced4b58d9dd37c9"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.10.0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "260fd2400ed2dab602a7c15cf10c1933c59930a2"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.5"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.CpuId]]
deps = ["Markdown"]
git-tree-sha1 = "fcbb72b032692610bfbdb15018ac16a36cf2e406"
uuid = "adafc99b-e345-5852-983c-f28acb93d879"
version = "0.3.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "0f4b5d62a88d8f59003e43c25a8a90de9eb76317"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.18"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelayDiffEq]]
deps = ["ArrayInterface", "DataStructures", "DiffEqBase", "LinearAlgebra", "Logging", "OrdinaryDiffEq", "Printf", "RecursiveArrayTools", "Reexport", "SciMLBase", "SimpleNonlinearSolve", "SimpleUnPack"]
git-tree-sha1 = "e40378efd2af7658d0a0579aa9e15b17137368f4"
uuid = "bcd4f6db-9728-5f36-b5f7-82caef46ccdb"
version = "5.44.0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.DiffEqBase]]
deps = ["ArrayInterface", "ChainRulesCore", "DataStructures", "Distributions", "DocStringExtensions", "EnumX", "FastBroadcast", "ForwardDiff", "FunctionWrappers", "FunctionWrappersWrappers", "LinearAlgebra", "Logging", "Markdown", "MuladdMacro", "Parameters", "PreallocationTools", "PrecompileTools", "Printf", "RecursiveArrayTools", "Reexport", "Requires", "SciMLBase", "SciMLOperators", "Setfield", "SparseArrays", "Static", "StaticArraysCore", "Statistics", "Tricks", "TruncatedStacktraces", "ZygoteRules"]
git-tree-sha1 = "0d9982e8dee851d519145857e79a17ee33ede154"
uuid = "2b5f629d-d688-5b77-993f-72d75c75574e"
version = "6.130.0"

[[deps.DiffEqCallbacks]]
deps = ["DataStructures", "DiffEqBase", "ForwardDiff", "Functors", "LinearAlgebra", "Markdown", "NLsolve", "Parameters", "RecipesBase", "RecursiveArrayTools", "SciMLBase", "StaticArraysCore"]
git-tree-sha1 = "d0b94b3694d55e7eedeee918e7daee9e3b873399"
uuid = "459566f4-90b8-5000-8ac3-15dfb0a30def"
version = "2.35.0"

[[deps.DiffEqNoiseProcess]]
deps = ["DiffEqBase", "Distributions", "GPUArraysCore", "LinearAlgebra", "Markdown", "Optim", "PoissonRandom", "QuadGK", "Random", "Random123", "RandomNumbers", "RecipesBase", "RecursiveArrayTools", "Requires", "ResettableStacks", "SciMLBase", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "57ed4597a309c5b2a10cab5f9813adcb78f92117"
uuid = "77a26b50-5914-5dd7-bc55-306e6241c503"
version = "5.19.0"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.DifferentialEquations]]
deps = ["BoundaryValueDiffEq", "DelayDiffEq", "DiffEqBase", "DiffEqCallbacks", "DiffEqNoiseProcess", "JumpProcesses", "LinearAlgebra", "LinearSolve", "NonlinearSolve", "OrdinaryDiffEq", "Random", "RecursiveArrayTools", "Reexport", "SciMLBase", "SteadyStateDiffEq", "StochasticDiffEq", "Sundials"]
git-tree-sha1 = "96a19f498504e4a3b39524196b73eb60ccef30e9"
uuid = "0c46a032-eb83-5123-abaf-570d42b7fbaa"
version = "7.10.0"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "66c4c81f259586e8f002eacebc177e1fb06363b0"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.11"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "7c302d7a5fec5214eb8a5a4c466dcf7a51fcf169"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.107"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EnumX]]
git-tree-sha1 = "bdb1942cd4c45e3c678fd11569d5cccd80976237"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.4"

[[deps.EnzymeCore]]
git-tree-sha1 = "59c44d8fbc651c0395d8a6eda64b05ce316f58b4"
uuid = "f151be2c-9106-41f4-ab19-57ee4f262869"
version = "0.6.5"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8e9441ee83492030ace98f9789a654a6d0b1f643"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "dcb08a0d93ec0b1cdc4af184b26b591e9695423a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.10"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4558ab818dcceaab612d1bb8c19cee87eda2b83c"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.5.0+0"

[[deps.ExponentialUtilities]]
deps = ["Adapt", "ArrayInterface", "GPUArraysCore", "GenericSchur", "LinearAlgebra", "PrecompileTools", "Printf", "SparseArrays", "libblastrampoline_jll"]
git-tree-sha1 = "602e4585bcbd5a25bc06f514724593d13ff9e862"
uuid = "d4d017d3-3776-5f7e-afef-a10c40355c18"
version = "1.25.0"

[[deps.ExprTools]]
git-tree-sha1 = "27415f162e6028e81c72b82ef756bf321213b6ec"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.10"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "466d45dc38e15794ec7d5d63ec03d776a9aff36e"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.4+1"

[[deps.FastBroadcast]]
deps = ["ArrayInterface", "LinearAlgebra", "Polyester", "Static", "StaticArrayInterface", "StrideArraysCore"]
git-tree-sha1 = "a6e756a880fc419c8b41592010aebe6a5ce09136"
uuid = "7034ab61-46d4-4ed7-9d0f-46aef9175898"
version = "0.2.8"

[[deps.FastClosures]]
git-tree-sha1 = "acebe244d53ee1b461970f8910c235b259e772ef"
uuid = "9aa1b823-49e4-5ca5-8b0f-3971ec8bab6a"
version = "0.3.2"

[[deps.FastLapackInterface]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "0a59c7d1002f3131de53dc4568a47d15a44daef7"
uuid = "29a986be-02c6-4525-aec4-84b980013641"
version = "2.0.2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "PDMats", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "5b93957f6dcd33fc343044af3d48c215be2562f1"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.9.3"

[[deps.FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Requires", "Setfield", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "73d1214fec245096717847c62d389a5d2ac86504"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.22.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Format]]
git-tree-sha1 = "f3cf88025f6d03c194d73f5d13fee9004a108329"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.6"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "cf0fe81336da9fb90944683b8c41984b08793dad"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.36"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d8db6a5a2fe1381c1ea4ef2cab7c69c2de7f9ea0"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.1+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.FunctionWrappers]]
git-tree-sha1 = "d62485945ce5ae9c0c48f124a84998d755bae00e"
uuid = "069b7b12-0de2-55c6-9aab-29f3d0a68a2e"
version = "1.1.3"

[[deps.FunctionWrappersWrappers]]
deps = ["FunctionWrappers"]
git-tree-sha1 = "b104d487b34566608f8b4e1c39fb0b10aa279ff8"
uuid = "77dc65aa-8811-40c2-897b-53d922fa7daf"
version = "0.1.3"

[[deps.Functors]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "8ae30e786837ce0a24f5e2186938bf3251ab94b2"
uuid = "d9f16b24-f501-4c13-a1f2-28368ffc5196"
version = "0.4.8"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "ff38ba61beff76b8f4acad8ab0c97ef73bb670cb"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.9+0"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "2d6ca471a6c7b536127afccfa7564b5b39227fe0"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.5"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "27442171f28c952804dede8ff72828a96f2bfc1f"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.10"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "025d171a2847f616becc0f84c8dc62fe18f0f6dd"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.10+0"

[[deps.GenericSchur]]
deps = ["LinearAlgebra", "Printf"]
git-tree-sha1 = "fb69b2a645fa69ba5f474af09221b9308b160ce6"
uuid = "c145ed77-6b09-5dd9-b285-bf645a82121e"
version = "0.5.3"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "359a1ba2e320790ddbe4ee8b4d54a305c0ea2aff"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.80.0+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "899050ace26649433ef1af25bc17a815b3db52b7"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.9.0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "995f762e0182ebc50548c434c171a5bb6635f8e4"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.4"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HostCPUFeatures]]
deps = ["BitTwiddlingConvenienceFunctions", "IfElse", "Libdl", "Static"]
git-tree-sha1 = "eb8fed28f4994600e29beef49744639d985a04b2"
uuid = "3e5b6fbb-0976-4d2c-9146-d79de83f2fb0"
version = "0.1.16"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "f218fe3736ddf977e0e772bc9a586b2383da2685"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.23"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "8b72179abc660bfab5e28472e019392b97d0985c"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.4"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.Inflate]]
git-tree-sha1 = "ea8031dea4aff6bd41f1df8f2fdfb25b33626381"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.4"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "5fdf2fe6724d8caabf43b557b84ce53f3b7e2f6b"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2024.0.2+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Dates", "Test"]
git-tree-sha1 = "896385798a8d49a255c398bd49162062e4a4c435"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.13"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "a53ebe394b71470c7f97c2e7e170d51df21b17af"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.7"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3336abae9a713d2210bb57ab484b1e065edd7d23"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.2+0"

[[deps.JumpProcesses]]
deps = ["ArrayInterface", "DataStructures", "DiffEqBase", "DocStringExtensions", "FunctionWrappers", "Graphs", "LinearAlgebra", "Markdown", "PoissonRandom", "Random", "RandomNumbers", "RecursiveArrayTools", "Reexport", "SciMLBase", "StaticArrays", "UnPack"]
git-tree-sha1 = "c451feb97251965a9fe40bacd62551a72cc5902c"
uuid = "ccbc3e58-028d-4f4c-8cd5-9ae44345cda5"
version = "9.10.1"

[[deps.KLU]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse_jll"]
git-tree-sha1 = "884c2968c2e8e7e6bf5956af88cb46aa745c854b"
uuid = "ef3ab10e-7fda-4108-b977-705223b18434"
version = "0.4.1"

[[deps.Krylov]]
deps = ["LinearAlgebra", "Printf", "SparseArrays"]
git-tree-sha1 = "8a6837ec02fe5fb3def1abc907bb802ef11a0729"
uuid = "ba0b0d4f-ebba-5204-a429-3ac8c609bfb7"
version = "0.9.5"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d986ce2d884d49126836ea94ed5bfb0f12679713"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "cad560042a7cc108f5a4c24ea1431a9221f22c1b"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.2"

[[deps.LayoutPointers]]
deps = ["ArrayInterface", "LinearAlgebra", "ManualMemory", "SIMDTypes", "Static", "StaticArrayInterface"]
git-tree-sha1 = "62edfee3211981241b57ff1cedf4d74d79519277"
uuid = "10f19ff3-798f-405d-979b-55457f8fc047"
version = "0.1.15"

[[deps.Lazy]]
deps = ["MacroTools"]
git-tree-sha1 = "1370f8202dac30758f3c345f9909b97f53d87d3f"
uuid = "50d2b5c4-7a5e-59d5-8109-a42b560f39c0"
version = "0.15.1"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LevyArea]]
deps = ["LinearAlgebra", "Random", "SpecialFunctions"]
git-tree-sha1 = "56513a09b8e0ae6485f34401ea9e2f31357958ec"
uuid = "2d8b4e74-eb68-11e8-0fb9-d5eb67b50637"
version = "1.0.0"

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

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "dae976433497a2f841baadea93d27e68f1a12a97"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.39.3+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "2da088d113af58221c52828a80378e16be7d037a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.5.1+1"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0a04a1318df1bf510beb2562cf90fb0c386f58c4"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.39.3+1"

[[deps.LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "7bbea35cec17305fc70a0e5b4641477dc0789d9d"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.2.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LinearSolve]]
deps = ["ArrayInterface", "ConcreteStructs", "DocStringExtensions", "EnumX", "EnzymeCore", "FastLapackInterface", "GPUArraysCore", "InteractiveUtils", "KLU", "Krylov", "Libdl", "LinearAlgebra", "MKL_jll", "PrecompileTools", "Preferences", "RecursiveFactorization", "Reexport", "Requires", "SciMLBase", "SciMLOperators", "Setfield", "SparseArrays", "Sparspak", "SuiteSparse", "UnPack"]
git-tree-sha1 = "9f807ca41005f9a8f092716e48022ee5b36cf5b1"
uuid = "7ed4a6bd-45f5-4d41-b270-4a48e9bafcae"
version = "2.14.1"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "18144f3e9cbe9b15b070288eef858f71b291ce37"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.27"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.LoopVectorization]]
deps = ["ArrayInterface", "CPUSummary", "ChainRulesCore", "CloseOpenIntervals", "DocStringExtensions", "ForwardDiff", "HostCPUFeatures", "IfElse", "LayoutPointers", "LinearAlgebra", "OffsetArrays", "PolyesterWeave", "PrecompileTools", "SIMDTypes", "SLEEFPirates", "SpecialFunctions", "Static", "StaticArrayInterface", "ThreadingUtilities", "UnPack", "VectorizationBase"]
git-tree-sha1 = "0f5648fbae0d015e3abe5867bca2b362f67a5894"
uuid = "bdcacae8-1622-11e9-2a5c-532679323890"
version = "0.12.166"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "72dc3cf284559eb8f53aa593fe62cb33f83ed0c0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2024.0.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.ManualMemory]]
git-tree-sha1 = "bcaef4fc7a0cfe2cba636d84cda54b5e4e4ca3cd"
uuid = "d125e4d3-2237-4719-b19c-fa641b8a4667"
version = "0.1.8"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MathOptInterface]]
deps = ["BenchmarkTools", "CodecBzip2", "CodecZlib", "DataStructures", "ForwardDiff", "JSON", "LinearAlgebra", "MutableArithmetics", "NaNMath", "OrderedCollections", "PrecompileTools", "Printf", "SparseArrays", "SpecialFunctions", "Test", "Unicode"]
git-tree-sha1 = "679c1aec6934d322783bd15db4d18f898653be4f"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "1.27.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.MuladdMacro]]
git-tree-sha1 = "cac9cc5499c25554cba55cd3c30543cff5ca4fab"
uuid = "46d2c3a1-f734-5fdb-9937-b9b9aeba4221"
version = "0.2.4"

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "302fd161eb1c439e4115b51ae456da4e9984f130"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "1.4.1"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "a0b464d183da839699f4c79e7606d9d186ec172c"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.3"

[[deps.NLsolve]]
deps = ["Distances", "LineSearches", "LinearAlgebra", "NLSolversBase", "Printf", "Reexport"]
git-tree-sha1 = "019f12e9a1a7880459d0173c182e6a99365d7ac1"
uuid = "2774e3e8-f4cf-5e23-947b-6d7e65073b56"
version = "4.5.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.NonlinearSolve]]
deps = ["ArrayInterface", "DiffEqBase", "EnumX", "FiniteDiff", "ForwardDiff", "LinearAlgebra", "LinearSolve", "PrecompileTools", "RecursiveArrayTools", "Reexport", "SciMLBase", "SimpleNonlinearSolve", "SparseArrays", "SparseDiffTools", "StaticArraysCore", "UnPack"]
git-tree-sha1 = "e10debcea868cd6e51249e8eeaf191c25f68a640"
uuid = "8913a72c-1f9b-4ce2-8d82-65094dcecaec"
version = "1.10.1"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "6a731f2b5c03157418a20c12195eb4b74c8f8621"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.13.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "af81a32750ebc831ee28bdaaba6e1067decef51e"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.2"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "60e3045590bd104a16fefb12836c00c0ef8c7f8c"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.13+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Optim]]
deps = ["Compat", "FillArrays", "ForwardDiff", "LineSearches", "LinearAlgebra", "MathOptInterface", "NLSolversBase", "NaNMath", "Parameters", "PositiveFactorizations", "Printf", "SparseArrays", "StatsBase"]
git-tree-sha1 = "d024bfb56144d947d4fafcd9cb5cafbe3410b133"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "1.9.2"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.OrdinaryDiffEq]]
deps = ["ADTypes", "Adapt", "ArrayInterface", "DataStructures", "DiffEqBase", "DocStringExtensions", "ExponentialUtilities", "FastBroadcast", "FastClosures", "FiniteDiff", "ForwardDiff", "FunctionWrappersWrappers", "IfElse", "InteractiveUtils", "LineSearches", "LinearAlgebra", "LinearSolve", "Logging", "LoopVectorization", "MacroTools", "MuladdMacro", "NLsolve", "NonlinearSolve", "Polyester", "PreallocationTools", "PrecompileTools", "Preferences", "RecursiveArrayTools", "Reexport", "SciMLBase", "SciMLNLSolve", "SciMLOperators", "SimpleNonlinearSolve", "SimpleUnPack", "SparseArrays", "SparseDiffTools", "StaticArrayInterface", "StaticArrays", "TruncatedStacktraces"]
git-tree-sha1 = "f0f43037c0ba045e96f32d65858eb825a211b817"
uuid = "1dea7af3-3e70-54e6-95c3-0bf5283fa5ed"
version = "6.58.2"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "949347156c25054de2db3b166c52ac4728cbad65"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.31"

[[deps.PackageExtensionCompat]]
deps = ["Requires", "TOML"]
git-tree-sha1 = "fb28e33b8a95c4cee25ce296c817d89cc2e53518"
uuid = "65ce6f38-6b18-4e1d-a461-8949797d7930"
version = "1.0.2"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "64779bc4c9784fee475689a1752ef4d5747c5e87"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.42.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "7b1a9df27f072ac4c9c7cbe5efb198489258d1f5"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.1"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "ccee59c6e48e6f2edf8a5b64dc817b6729f99eb5"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.39.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "71a22244e352aa8c5f0f2adde4150f62368a3f2e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.58"

[[deps.PoissonRandom]]
deps = ["Random"]
git-tree-sha1 = "a0f1159c33f846aa77c3f30ebbc69795e5327152"
uuid = "e409e4f3-bfea-5376-8464-e040bb5c01ab"
version = "0.4.4"

[[deps.Polyester]]
deps = ["ArrayInterface", "BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "ManualMemory", "PolyesterWeave", "Requires", "Static", "StaticArrayInterface", "StrideArraysCore", "ThreadingUtilities"]
git-tree-sha1 = "8df43bbe60029526dd628af7e9951f5af680d4d7"
uuid = "f517fe37-dbe3-4b94-8317-1923a5111588"
version = "0.7.10"

[[deps.PolyesterWeave]]
deps = ["BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "Static", "ThreadingUtilities"]
git-tree-sha1 = "240d7170f5ffdb285f9427b92333c3463bf65bf6"
uuid = "1d0040c9-8b98-4ee7-8388-3f51789ca0ad"
version = "0.2.1"

[[deps.PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

[[deps.PreallocationTools]]
deps = ["Adapt", "ArrayInterface", "ForwardDiff", "Requires"]
git-tree-sha1 = "f739b1b3cc7b9949af3b35089931f2b58c289163"
uuid = "d236fae5-4411-538c-8e31-a6e3d9e00b46"
version = "0.4.12"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "9816a3826b0ebf49ab4926e2b18842ad8b5c8f04"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.96.4"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "37b7bb7aabf9a085e0044307e1717436117f2b3b"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.5.3+1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9b23c31e76e333e6fb4c1595ae6afa74966a729e"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.9.4"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Random123]]
deps = ["Random", "RandomNumbers"]
git-tree-sha1 = "4743b43e5a9c4a2ede372de7061eed81795b12e7"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.7.0"

[[deps.RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.RecursiveArrayTools]]
deps = ["Adapt", "ArrayInterface", "DocStringExtensions", "GPUArraysCore", "IteratorInterfaceExtensions", "LinearAlgebra", "RecipesBase", "Requires", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface", "Tables"]
git-tree-sha1 = "d7087c013e8a496ff396bae843b1e16d9a30ede8"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "2.38.10"

[[deps.RecursiveFactorization]]
deps = ["LinearAlgebra", "LoopVectorization", "Polyester", "PrecompileTools", "StrideArraysCore", "TriangularSolve"]
git-tree-sha1 = "8bc86c78c7d8e2a5fe559e3721c0f9c9e303b2ed"
uuid = "f2c3362d-daeb-58d1-803e-2bc74f2840b4"
version = "0.2.21"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.ResettableStacks]]
deps = ["StaticArrays"]
git-tree-sha1 = "256eeeec186fa7f26f2801732774ccf277f05db9"
uuid = "ae5879a3-cd67-5da8-be7f-38c6eb64a37b"
version = "1.1.1"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[deps.Roots]]
deps = ["Accessors", "ChainRulesCore", "CommonSolve", "Printf"]
git-tree-sha1 = "1ab580704784260ee5f45bffac810b152922747b"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.1.5"

[[deps.RuntimeGeneratedFunctions]]
deps = ["ExprTools", "SHA", "Serialization"]
git-tree-sha1 = "6aacc5eefe8415f47b3e34214c1d79d2674a0ba2"
uuid = "7e49a35a-f44a-4d26-94aa-eba1b4ca6b47"
version = "0.5.12"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMDTypes]]
git-tree-sha1 = "330289636fb8107c5f32088d2741e9fd7a061a5c"
uuid = "94e857df-77ce-4151-89e5-788b33177be4"
version = "0.1.0"

[[deps.SLEEFPirates]]
deps = ["IfElse", "Static", "VectorizationBase"]
git-tree-sha1 = "3aac6d68c5e57449f5b9b865c9ba50ac2970c4cf"
uuid = "476501e8-09a2-5ece-8869-fb82de89a1fa"
version = "0.6.42"

[[deps.SciMLBase]]
deps = ["ADTypes", "ArrayInterface", "ChainRulesCore", "CommonSolve", "ConstructionBase", "Distributed", "DocStringExtensions", "EnumX", "FillArrays", "FunctionWrappersWrappers", "IteratorInterfaceExtensions", "LinearAlgebra", "Logging", "Markdown", "PrecompileTools", "Preferences", "RecipesBase", "RecursiveArrayTools", "Reexport", "RuntimeGeneratedFunctions", "SciMLOperators", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface", "Tables", "TruncatedStacktraces", "ZygoteRules"]
git-tree-sha1 = "916b8a94c0d61fa5f7c5295649d3746afb866aff"
uuid = "0bca4576-84f4-4d90-8ffe-ffa030f20462"
version = "1.98.1"

[[deps.SciMLNLSolve]]
deps = ["DiffEqBase", "LineSearches", "NLsolve", "Reexport", "SciMLBase"]
git-tree-sha1 = "765b788339abd7d983618c09cfc0192e2b6b15fd"
uuid = "e9a6253c-8580-4d32-9898-8661bb511710"
version = "0.1.9"

[[deps.SciMLOperators]]
deps = ["ArrayInterface", "DocStringExtensions", "Lazy", "LinearAlgebra", "Setfield", "SparseArrays", "StaticArraysCore", "Tricks"]
git-tree-sha1 = "51ae235ff058a64815e0a2c34b1db7578a06813d"
uuid = "c0aeaf25-5076-4817-a8d5-81caf7dfa961"
version = "0.3.7"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimpleNonlinearSolve]]
deps = ["ArrayInterface", "DiffEqBase", "FiniteDiff", "ForwardDiff", "LinearAlgebra", "PackageExtensionCompat", "PrecompileTools", "Reexport", "SciMLBase", "StaticArraysCore"]
git-tree-sha1 = "15ff97fa4881133caa324dacafe28b5ac47ad8a2"
uuid = "727e6d20-b764-4bd8-a329-72de5adea6c7"
version = "0.1.23"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.SimpleUnPack]]
git-tree-sha1 = "58e6353e72cde29b90a69527e56df1b5c3d8c437"
uuid = "ce78b400-467f-4804-87d8-8f486da07d0a"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SparseDiffTools]]
deps = ["ADTypes", "Adapt", "ArrayInterface", "Compat", "DataStructures", "FiniteDiff", "ForwardDiff", "Graphs", "LinearAlgebra", "PackageExtensionCompat", "Random", "Reexport", "SciMLOperators", "Setfield", "SparseArrays", "StaticArrayInterface", "StaticArrays", "Tricks", "UnPack", "VertexSafeGraphs"]
git-tree-sha1 = "a616ac46c38da60ac05cecf52064d44732edd05e"
uuid = "47a9eef4-7e08-11e9-0b38-333d64bd3804"
version = "2.17.0"

[[deps.Sparspak]]
deps = ["Libdl", "LinearAlgebra", "Logging", "OffsetArrays", "Printf", "SparseArrays", "Test"]
git-tree-sha1 = "342cf4b449c299d8d1ceaf00b7a49f4fbc7940e7"
uuid = "e56a9233-b9d6-4f03-8d0f-1825330902ac"
version = "0.3.9"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "b366eb1eb68075745777d80861c6706c33f588ae"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.8.9"

[[deps.StaticArrayInterface]]
deps = ["ArrayInterface", "Compat", "IfElse", "LinearAlgebra", "PrecompileTools", "Requires", "SparseArrays", "Static", "SuiteSparse"]
git-tree-sha1 = "5d66818a39bb04bf328e92bc933ec5b4ee88e436"
uuid = "0d7ed370-da01-4f52-bd93-41d350b8b718"
version = "1.5.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "bf074c045d3d5ffd956fa0a461da38a44685d6b2"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.3"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "1d77abd07f617c4868c33d4f5b9e1dbb2643c9cf"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.2"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "cef0472124fab0695b58ca35a77c6fb942fdab8a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.1"

[[deps.SteadyStateDiffEq]]
deps = ["DiffEqBase", "DiffEqCallbacks", "LinearAlgebra", "NLsolve", "Reexport", "SciMLBase"]
git-tree-sha1 = "2ca69f4be3294e4cd987d83d6019037d420d9fc1"
uuid = "9672c7b4-1e72-59bd-8a11-6ac3964bc41f"
version = "1.16.1"

[[deps.StochasticDiffEq]]
deps = ["Adapt", "ArrayInterface", "DataStructures", "DiffEqBase", "DiffEqNoiseProcess", "DocStringExtensions", "FillArrays", "FiniteDiff", "ForwardDiff", "JumpProcesses", "LevyArea", "LinearAlgebra", "Logging", "MuladdMacro", "NLsolve", "OrdinaryDiffEq", "Random", "RandomNumbers", "RecursiveArrayTools", "Reexport", "SciMLBase", "SciMLOperators", "SparseArrays", "SparseDiffTools", "StaticArrays", "UnPack"]
git-tree-sha1 = "b341540a647b39728b6d64eaeda82178e848f76e"
uuid = "789caeaf-c7a9-5a7d-9973-96adeb23e2a0"
version = "6.62.0"

[[deps.StrideArraysCore]]
deps = ["ArrayInterface", "CloseOpenIntervals", "IfElse", "LayoutPointers", "ManualMemory", "SIMDTypes", "Static", "StaticArrayInterface", "ThreadingUtilities"]
git-tree-sha1 = "d6415f66f3d89c615929af907fdc6a3e17af0d8c"
uuid = "7792a7ef-975c-4747-a70f-980b88e8d1da"
version = "0.5.2"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+0"

[[deps.Sundials]]
deps = ["CEnum", "DataStructures", "DiffEqBase", "Libdl", "LinearAlgebra", "Logging", "PrecompileTools", "Reexport", "SciMLBase", "SparseArrays", "Sundials_jll"]
git-tree-sha1 = "71dc65a2d7decdde5500299c9b04309e0138d1b4"
uuid = "c3572dad-4567-51f8-b174-8c6c989267f4"
version = "4.20.1"

[[deps.Sundials_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "OpenBLAS_jll", "Pkg", "SuiteSparse_jll"]
git-tree-sha1 = "04777432d74ec5bc91ca047c9e0e0fd7f81acdb6"
uuid = "fb77eaff-e24c-56d4-86b1-d163f2edb164"
version = "5.2.1+0"

[[deps.SymPy]]
deps = ["CommonEq", "CommonSolve", "LinearAlgebra", "PyCall", "SpecialFunctions", "SymPyCore"]
git-tree-sha1 = "8d727c118eb31ffad73cce569b7bb29eef5fb9ad"
uuid = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
version = "2.0.1"

[[deps.SymPyCore]]
deps = ["CommonEq", "CommonSolve", "Latexify", "LinearAlgebra", "Markdown", "RecipesBase", "SpecialFunctions"]
git-tree-sha1 = "4c5a53625f0e53ce1e726a6dab1c870017303728"
uuid = "458b697b-88f0-4a86-b56b-78b75cfb3531"
version = "0.1.16"

[[deps.SymbolicIndexingInterface]]
deps = ["DocStringExtensions"]
git-tree-sha1 = "f8ab052bfcbdb9b48fad2c80c873aa0d0344dfe5"
uuid = "2efcf032-c050-4f8e-a9bb-153293bab1f5"
version = "0.2.2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.ThreadingUtilities]]
deps = ["ManualMemory"]
git-tree-sha1 = "eda08f7e9818eb53661b3deb74e3159460dfbc27"
uuid = "8290d209-cae3-49c0-8002-c8c24d57dab5"
version = "0.5.2"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "a09c933bebed12501890d8e92946bbab6a1690f1"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.5"

[[deps.TriangularSolve]]
deps = ["CloseOpenIntervals", "IfElse", "LayoutPointers", "LinearAlgebra", "LoopVectorization", "Polyester", "Static", "VectorizationBase"]
git-tree-sha1 = "fadebab77bf3ae041f77346dd1c290173da5a443"
uuid = "d5829a12-d9aa-46ab-831f-fb7c9ab06edf"
version = "0.1.20"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.TruncatedStacktraces]]
deps = ["InteractiveUtils", "MacroTools", "Preferences"]
git-tree-sha1 = "ea3e54c2bdde39062abf5a9758a23735558705e1"
uuid = "781d530d-4396-4725-bb49-402e4bee1e77"
version = "1.4.0"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["ConstructionBase", "Dates", "InverseFunctions", "LinearAlgebra", "Random"]
git-tree-sha1 = "3c793be6df9dd77a0cf49d80984ef9ff996948fa"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.19.0"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "e2d817cc500e960fdbafcf988ac8436ba3208bfd"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.3"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.VectorizationBase]]
deps = ["ArrayInterface", "CPUSummary", "HostCPUFeatures", "IfElse", "LayoutPointers", "Libdl", "LinearAlgebra", "SIMDTypes", "Static", "StaticArrayInterface"]
git-tree-sha1 = "7209df901e6ed7489fe9b7aa3e46fb788e15db85"
uuid = "3d5dd08c-fd9d-11e8-17fa-ed2836048c2f"
version = "0.21.65"

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

[[deps.VertexSafeGraphs]]
deps = ["Graphs"]
git-tree-sha1 = "8351f8d73d7e880bfc042a8b6922684ebeafb35c"
uuid = "19fa3120-7c27-5ec5-8db8-b0b0aa330d6f"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "7558e29847e99bc3f04d6569e82d0f5c54460703"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+1"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "93f43ab61b16ddfb2fd3bb13b3ce241cafb0e6c9"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.31.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "07e470dabc5a6a4254ffebc29a1b3fc01464e105"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.12.5+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "31c421e5516a6248dfb22c194519e37effbf1f30"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.6.1+0"

[[deps.Xorg_libICE_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "e5becd4411063bdcac16be8b66fc2f9f6f1e8fe5"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.0.10+1"

[[deps.Xorg_libSM_jll]]
deps = ["Libdl", "Pkg", "Xorg_libICE_jll"]
git-tree-sha1 = "4a9d9e4c180e1e8119b5ffc224a7b59d3a7f7e18"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.3+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "b4bfde5d5b652e22b9c790ad00af08b6d042b97d"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.15.0+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "730eeca102434283c50ccf7d1ecdadf521a765a4"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "330f955bc41bb8f5270a369c473fc4a5a4e4d3cb"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.ZygoteRules]]
deps = ["ChainRulesCore", "MacroTools"]
git-tree-sha1 = "27798139afc0a2afa7b1824c206d5e87ea587a00"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.5"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a68c9655fbe6dfcab3d972808f1aafec151ce3f8"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.43.0+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3516a5630f741c9eecb3720b1ec9d8edc3ecc033"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d7015d2e18a5fd9a4f47de711837e980519781a4"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.43+1"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
"""

# ╔═╡ Cell order:
# ╟─191f2f52-f7f5-4b1b-85d1-883d40afbc50
# ╟─2cc6c5db-dae9-4056-8e86-c2cdd5413fd2
# ╟─9a904b84-2c70-444d-a673-4327560d1226
# ╟─3db89cf8-58b3-42e5-a1a7-a5ac40a78fdb
# ╟─c96c27e6-efbb-4ae4-ad1f-71a19af1a971
# ╠═39ed3381-b89d-40a0-ab27-764982180e55
# ╠═3d867eb9-6348-4f3b-813d-029884312c36
# ╟─e263bad6-deb8-4dca-b147-57a9d4dd39bb
# ╟─33842891-3dbb-4b08-8160-346ffafe8619
# ╟─c4c29fc7-5611-4b30-b15e-90f3fb86450a
# ╟─ba732df6-5923-4e4e-8b2d-35fe0d35e398
# ╟─f44497fb-d866-4649-bd62-f19f1d2bc811
# ╠═1394bd94-9e28-444a-b358-ea487ad06420
# ╟─1f0dba89-0aad-4ede-a4a6-d005aad2b897
# ╟─172eb728-c084-4311-b75a-6177a36fb847
# ╟─519ca1e3-ea1b-4d1b-af2d-d074531b502b
# ╠═1358c859-a74e-4738-bf50-4e4aca06770d
# ╟─21b98c71-3aa2-4438-ba4f-c830cfc6d709
# ╠═64281d01-c1dd-4f11-8397-21d01ecadd5f
# ╟─5ac22392-143f-4531-a611-d8533610d07c
# ╠═043dd8fc-da87-453b-ae29-10d72b933e06
# ╟─7161401c-f87a-4939-9fa9-479c24931f06
# ╠═1a3a16df-b51e-4125-a895-fcaa02ad2403
# ╟─ea1b3ecc-fa84-4ee0-8609-91b0106362f3
# ╠═5d4734ca-9c04-4c07-bc5b-6629b66a9c91
# ╟─d9bd8b60-858e-44fc-a510-cae1b865111e
# ╠═02be56ff-3585-4b7a-b0bc-ab42c43c773f
# ╠═c4a90f6b-ba92-41d6-ae4b-e16f303c1bdd
# ╟─3cf10c6c-05af-4508-b3f3-70de4d537acb
# ╠═4c41dfed-ca3e-4515-a0e7-40e7489d1faf
# ╟─43eb9fc5-b762-4bd7-a540-ad35da34d7b9
# ╠═79990d4e-08e1-4c75-896e-f4d9b9e7fefc
# ╟─280c6e4b-8db1-42c2-b157-dca7ed01965a
# ╠═d0290ed3-64bc-4b8b-9e4f-665e33c33014
# ╟─9cbe41df-cfd5-4e04-980e-c5bb60865a6d
# ╠═1bd9636d-5006-47db-835e-4bed32a33753
# ╟─8ae541e7-951f-455e-8b33-f1966941a775
# ╟─471bd66e-5032-4de9-b99a-e38eb675f641
# ╟─6502f975-7542-405f-8013-d0662bfcff32
# ╠═d98fa069-d933-4ee4-94a6-7f33512c39cf
# ╟─63aa2cc1-8f73-4efb-91c7-a1a73321dc6e
# ╠═afd8e5f0-9088-4364-98e6-e2573c207f31
# ╠═57422995-5a2f-4990-a90a-48571ebc0db5
# ╟─819d0789-c0c2-40ab-87ab-c9ad7c87538d
# ╠═565b66b9-ed1b-4013-a6c0-77038dd09530
# ╟─681946a2-a574-4a3d-aa94-87fad31aa6a8
# ╟─b1c5a491-c18e-4f1c-af08-b9988813bebe
# ╠═261d27e2-6240-4047-afa7-f2f9a4af396c
# ╟─913ad931-b08c-47df-ae0d-5d1f6f216453
# ╠═10c4a587-b0db-4a73-b42f-14c9621815e0
# ╟─ab3bc822-3432-4598-8191-01e20f63ca1c
# ╠═c8922fad-0123-42ea-94d7-81379b4ff3ad
# ╟─dafdb4f3-f49e-4645-b58c-16eb63954b1b
# ╠═1f733c09-b663-49df-a68f-fc5ecf5f06c5
# ╟─8612f130-8559-41ae-bf4f-c7b22800bce5
# ╠═3f42f911-825d-458e-a4a1-2bffc0bd3b46
# ╟─c33e2bfb-798c-4e15-a9ba-0e1404f6eb34
# ╟─97435cc8-95ca-45eb-abeb-8fee0db7d651
# ╟─baeb53bb-cc5a-4e34-a560-8ee87198bfab
# ╟─4851cddc-4f29-426e-a940-b0f955dd2152
# ╠═9f379a94-fab6-4e9f-8a6c-45326f9ba041
# ╟─04edbbc3-041d-45ea-b770-46eb127419aa
# ╠═6acfd215-a4e3-4f1b-b2c4-91461377e706
# ╠═f24cc905-c0af-482c-8add-eddb80607dc1
# ╟─9a0dd382-0e83-46c0-85b9-efe10dba5a75
# ╠═a482eac4-ac19-437a-905d-441064c6c678
# ╟─f4468684-2f96-42b0-96a0-90639f0e4ebe
# ╟─ad5879a7-e89d-4fd8-b31a-770e5419260c
# ╟─8d550296-d82e-4949-9421-01354d63425e
# ╟─9e087ad2-9bc7-4b66-9a7c-0200731853f6
# ╟─f59b9534-1051-4f15-bed5-13488dfe6d62
# ╟─90ce15a3-304c-45a7-afaf-a9ff914fe07a
# ╟─798291b8-9488-44db-9aad-9dc557931c3d
# ╟─a50b3a49-4b81-4843-bfaa-e6273a2835a4
# ╟─7c231cf4-d2e6-4819-86f7-d7b0231d45f9
# ╟─1a52f2b3-9aaf-402d-8d4c-b1a6b1a65e45
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002

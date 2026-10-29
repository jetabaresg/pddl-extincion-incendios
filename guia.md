```
.\lpg-td.exe -o dominio.pddl -f problema.pddl -n 2 -out plan.txt

```
Metricica Real = total-time + (10 x acciones de votar) 

### **Decisiones Importantes de Diseño en el Código**

* **Jerarquía de Tipos (** **:types** **)**:
  * Se separó `terrestre` en `jeep` y `camion_cuba` para obligar en la acción `atacar-fuego-terrestre` a que intervengan **un 4x4 y un camión cuba al mismo tiempo**.
  * Se dividió `aereo` en `avioneta` (solo agua) y `helicoptero` (solo retardante).
* **Semáforos / Banderas de Exclusión Mutua (** **:predicates** **)**:
  * `(repostando-en ?l)`: Evita que dos aeronaves reposten simultáneamente en la base.
  * `(recargando-agua-en ?l)`: Evita que dos avionetas carguen agua a la vez en la misma localización.
  * `(atacando-terrestre-en ?l)`: Candado que **impide descargas aéreas (agua/retardante) en una zona mientras el equipo terrestre está actuando allí**.
* **Funciones Numéricas y Duraciones**:
  * Duración de desplazamientos calculada dinámicamente: `distancia / velocidad`.
  * Duración de repostaje: `capacidad_deposito - combustible_actual`.
  * **Distancias bidireccionales**: En PDDL las funciones numéricas no son simétricas por defecto. Es obligatorio declarar tanto la ida como la vuelta (`base -&gt; loc1` y `loc1 -&gt; base`).

  1. **Añadir las nuevas metas en la sección** **(:goal ...)**:

```
 (:goal
    (and
      ;; Fuegos actuales (loc1, loc2, loc3)
      (fuego-atacado loc1) (agua-descargada loc1)
      (fuego-atacado loc2) (agua-descargada loc2)
      (fuego-atacado loc3) (agua-descargada loc3) (retardante-descargado loc3)

      ;; nuevo incendio  LOC4 (Añadir estas líneas):
      fuego-atacado loc4)
            (agua-descargada loc4)
            ;; (Si especifican que también requiere retardante, añade):
            ;; (retardante-descargado loc4)

            ;;  EL RETORNO BASE
            (en jeep1 base) (en jeep2 base)
            (en camion1 base) (en camion2 base) (en camion3 base)
            (en avion1 base) (en avion2 base)
            (en helic1 base) (en helic2 base)
 )
 Incendio nuevo 
 (:objects base loc1 loc2 loc3 loc4 loc5 embalse mar - localizacion ... )
  ;; Conexiones para loc5 (Ida y Vuelta)
   (= (distancia loc4 loc5) 400) (= (distancia loc5 loc4) 400) (transitable loc4 loc5) (transitable loc5 loc4)
   (= (distancia base loc5) 1600) (= (distancia loc5 base) 1600) (transitable base loc5) (transitable loc5 base)
   (= (distancia loc5 embalse) 800) (= (distancia embalse loc5) 800)
   (= (distancia loc5 mar) 600) (= (distancia mar loc5) 600)
   1. **Añadir las metas en** **(:goal ...)**:
  (fuego-atacado loc5)
  (agua-descargada loc5)


  ### **1\. Cambios en** **dominio.pddl**

Cambia el tipo de parámetro de `?a - aereo` a `?e - equipo` para que aplique tanto a aeronaves como a vehículos terrestres [10]:

```
  (:functions
    (velocidad ?e - equipo)
    (distancia ?origen ?destino - localizacion)
    (combustible ?e - equipo)           Cambiar ?a - aereo por ?e - equipo
    (capacidad-deposito ?e - equipo)     Cambiar ?a - aereo por ?e - equipo
    (num-movimientos-aereos)
  )
Añade la condición de combustible suficiente al inicio y la reducción al final [10]:
  (:durative-action moverse
    :parameters (?t - terrestre ?origen ?destino - localizacion)
    :duration (= ?duration
      (/ (distancia ?origen ?destino) (velocidad ?t)))
    :condition (and
      (at start (en ?t ?origen))
      (over all (transitable ?origen ?destino))
      (at start (&gt;= (combustible ?t) (distancia ?origen ?destino))) ;; &lt;-- NUEVO
    )
    :effect (and
      (at start (not (en ?t ?origen)))
      (at end (en ?t ?destino))
      (at end (decrease (combustible ?t) (distancia ?origen ?destino))) ;; &lt;-- NUEVO
    )
  )

```

#### **C. Generalizar la acción** **repostar**

Cambia el parámetro `?a - aereo` por `?e - equipo` para que cualquier vehículo pueda usar el punto de suministro de combustible en la base [10]:

```
  (:durative-action repostar
    :parameters (?e - equipo ?l - localizacion) ;; &lt;-- Cambiar ?a por ?e
    :duration (= ?duration
      (- (capacidad-deposito ?e) (combustible ?e)))
    :condition (and
      (over all (en ?e ?l))
      (over all (suministro-combustible ?l))
      (at start (not (repostando-en ?l)))
    )
    :effect (and
      (at start (repostando-en ?l))
      (at end (not (repostando-en ?l)))
      (at end (assign (combustible ?e) (capacidad-deposito ?e)))
    )
  )

```

---

### **2\. Cambios en** **problema.pddl**

En la sección `(:init ...)`, debes definir el **combustible inicial** y la **capacidad del depósito** para cada jeep y camión cuba [4]:

```
    ;; Combustible inicial y capacidad para equipos terrestres
    (= (combustible jeep1) 1000) (= (capacidad-deposito jeep1) 1000)
    (= (combustible jeep2) 1000) (= (capacidad-deposito jeep2) 1000)
    (= (combustible camion1) 2000) (= (capacidad-deposito camion1) 2000)
    (= (combustible camion2) 2000) (= (capacidad-deposito camion2) 2000)
    (= (combustible camion3) 2000) (= (capacidad-deposito camion3) 2000)
```



```
```
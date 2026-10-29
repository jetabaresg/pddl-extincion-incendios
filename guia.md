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
    ;; Fuegos existentes...
    (agua-descargada loc1) (fuego-atacado loc1)
    ...
    ;; NUEVO FUEGO EN LOC4:
    (agua-descargada loc4)
    (fuego-atacado loc4)
    ;; (Si también pidieran retardante en loc4, añadirías: (retardante-descargado loc4))

    ;; Mantener siempre el retorno a la base de todos los equipos
    (en jeep1 base) ...
  )
)
```
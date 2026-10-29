(define (domain extincion-incendio)
  (:requirements :typing :durative-actions :fluents)

  (:types
    localizacion equipo - object
    aereo terrestre - equipo
    avioneta helicoptero - aereo
    jeep camion-cuba - terrestre
  )

  (:predicates
    ;; Dónde está cada equipo y que rutas hace.
    (en ?e - equipo ?l - localizacion)
    (transitable ?origen ?destino - localizacion)

    ;; La carga se consume al descargarla y se recupera en una base.
    (cargado-agua ?a - avioneta)
    (cargado-retardante ?h - helicoptero)

    ;; Una localización puede tener varios suministros.
    (suministro-agua ?l - localizacion)
    (suministro-retardante ?l - localizacion)
    (suministro-combustible ?l - localizacion)

    ;; Marcas para saber qué se ha hecho en cada zona.
    (fuego-atacado ?l - localizacion)
    (agua-descargada ?l - localizacion)
    (retardante-descargado ?l - localizacion)

    ;; para que no hayan operaciones incompatibles.
    (repostando-en ?l - localizacion)
    (recargando-agua-en ?l - localizacion)
    (atacando-terrestre-en ?l - localizacion)
  )

  (:functions
    (velocidad ?e - equipo)
    (distancia ?origen ?destino - localizacion)
    (combustible ?a - aereo)
    (capacidad-deposito ?a - aereo)
    (num-movimientos-aereos)
  )

  (:durative-action volar
    :parameters (?a - aereo ?origen ?destino - localizacion)
    :duration (= ?duration
      (/ (distancia ?origen ?destino) (velocidad ?a)))
    :condition (and
      (at start (en ?a ?origen))
      (at start (>= (combustible ?a) (distancia ?origen ?destino)))
    )
    :effect (and
      (at start (not (en ?a ?origen)))
      (at end (en ?a ?destino))
      (at end (decrease (combustible ?a) (distancia ?origen ?destino)))
      (at end (increase (num-movimientos-aereos) 1))
    )
  )

  (:durative-action moverse
    :parameters (?t - terrestre ?origen ?destino - localizacion)
    :duration (= ?duration
      (/ (distancia ?origen ?destino) (velocidad ?t)))
    :condition (and
      (at start (en ?t ?origen))
      (over all (transitable ?origen ?destino))
    )
    :effect (and
      (at start (not (en ?t ?origen)))
      (at end (en ?t ?destino))
    )
  )

  (:durative-action rellenar-agua
    :parameters (?a - avioneta ?l - localizacion)
    :duration (= ?duration 40)
    :condition (and
      (over all (en ?a ?l))
      (over all (suministro-agua ?l))
      (at start (not (recargando-agua-en ?l)))
    )
    :effect (and
      (at start (recargando-agua-en ?l))
      (at end (not (recargando-agua-en ?l)))
      (at end (cargado-agua ?a))
    )
  )

  ;;  varias cargas de retardante  pueden coincidir.
  (:durative-action rellenar-retardante
    :parameters (?h - helicoptero ?l - localizacion)
    :duration (= ?duration 50)
    :condition (and
      (over all (en ?h ?l))
      (over all (suministro-retardante ?l))
    )
    :effect (at end (cargado-retardante ?h))
  )

  ;; El punto de combustible solo puede atender a un equipo aéreo a la vez.
  (:durative-action repostar
    :parameters (?a - aereo ?l - localizacion)
    :duration (= ?duration
      (- (capacidad-deposito ?a) (combustible ?a)))
    :condition (and
      (over all (en ?a ?l))
      (over all (suministro-combustible ?l))
      (at start (not (repostando-en ?l)))
    )
    :effect (and
      (at start (repostando-en ?l))
      (at end (not (repostando-en ?l)))
      (at end (assign (combustible ?a) (capacidad-deposito ?a)))
    )
  )

  ;; La descarga aérea se bloquea mientras los equipos terrestres trabajan allí.
  (:durative-action descargar-agua
    :parameters (?a - avioneta ?l - localizacion)
    :duration (= ?duration 8)
    :condition (and
      (over all (en ?a ?l))
      (at start (cargado-agua ?a))
      (over all (not (atacando-terrestre-en ?l)))
    )
    :effect (and
      (at start (not (cargado-agua ?a)))
      (at end (agua-descargada ?l))
    )
  )

  (:durative-action descargar-retardante
    :parameters (?h - helicoptero ?l - localizacion)
    :duration (= ?duration 10)
    :condition (and
      (over all (en ?h ?l))
      (at start (cargado-retardante ?h))
      (over all (not (atacando-terrestre-en ?l)))
    )
    :effect (and
      (at start (not (cargado-retardante ?h)))
      (at end (retardante-descargado ?l))
    )
  )

  ;; El ataque terrestre necesita un jeep y un camión cuba en la misma zona.
  (:durative-action atacar-fuego-terrestre
    :parameters (?j - jeep ?c - camion-cuba ?l - localizacion)
    :duration (= ?duration 10)
    :condition (and
      (over all (en ?j ?l))
      (over all (en ?c ?l))
      (at start (not (atacando-terrestre-en ?l)))
    )
    :effect (and
      (at start (atacando-terrestre-en ?l))
      (at end (not (atacando-terrestre-en ?l)))
      (at end (fuego-atacado ?l))
    )
  )
)

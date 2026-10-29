(define (problem incendio-escenario1)
  (:domain extincion-incendio)

  (:objects
    ;; La base y los puntos de actuación forman la red del escenario.
    base loc1 loc2 loc3 loc4 embalse mar - localizacion

    ;; Equipos terrestres y aéreos disponibles desde el inicio.
    jeep1 jeep2 - jeep
    camion1 camion2 camion3 - camion-cuba
    avion1 avion2 - avioneta
    helic1 helic2 - helicoptero
  )

  (:init
    ;; Todos los equipos parten de la base.
    (en jeep1 base)
    (en jeep2 base)
    (en camion1 base)
    (en camion2 base)
    (en camion3 base)
    (en avion1 base)
    (en avion2 base)
    (en helic1 base)
    (en helic2 base)

    ;; La base repone combustible y retardante; el agua se obtiene del embalse o del mar.
    (suministro-agua embalse)
    (suministro-agua mar)
    (suministro-retardante base)
    (suministro-combustible base)

    ;; El contador se utiliza para penalizar los desplazamientos aéreos.
    (= (num-movimientos-aereos) 0)

    ;; Velocidades de los equipos terrestres.
    (= (velocidad jeep1) 80)
    (= (velocidad jeep2) 80)
    (= (velocidad camion1) 40)
    (= (velocidad camion2) 40)
    (= (velocidad camion3) 40)

    ;; Velocidad, combustible inicial y capacidad de cada aeronave.
    (= (velocidad avion1) 200)
    (= (combustible avion1) 0)
    (= (capacidad-deposito avion1) 3000)
    (= (velocidad avion2) 160)
    (= (combustible avion2) 1000)
    (= (capacidad-deposito avion2) 4000)
    (= (velocidad helic1) 120)
    (= (combustible helic1) 50)
    (= (capacidad-deposito helic1) 2000)
    (= (velocidad helic2) 120)
    (= (combustible helic2) 160)
    (= (capacidad-deposito helic2) 1600)

    ;; Distancias y trayectos terrestres entre la base y las zonas de trabajo.
    (= (distancia base loc1) 480)
    (= (distancia loc1 base) 480)
    (transitable base loc1)
    (transitable loc1 base)
    (= (distancia base loc2) 520)
    (= (distancia loc2 base) 520)
    (transitable base loc2)
    (transitable loc2 base)
    (= (distancia base loc3) 800)
    (= (distancia loc3 base) 800)
    (transitable base loc3)
    (transitable loc3 base)
    (= (distancia base loc4) 1200)
    (= (distancia loc4 base) 1200)
    (transitable base loc4)
    (transitable loc4 base)

    ;; Distancias aéreas hacia los puntos de suministro.
    (= (distancia base embalse) 1200)
    (= (distancia embalse base) 1200)
    (= (distancia base mar) 1320)
    (= (distancia mar base) 1320)

    ;; Conexiones entre las zonas de trabajo.
    (= (distancia loc1 loc2) 400)
    (= (distancia loc2 loc1) 400)
    (transitable loc1 loc2)
    (transitable loc2 loc1)
    (= (distancia loc1 loc3) 800)
    (= (distancia loc3 loc1) 800)
    (transitable loc1 loc3)
    (transitable loc3 loc1)
    (= (distancia loc1 loc4) 1200)
    (= (distancia loc4 loc1) 1200)
    (transitable loc1 loc4)
    (transitable loc4 loc1)
    (= (distancia loc2 loc3) 400)
    (= (distancia loc3 loc2) 400)
    (transitable loc2 loc3)
    (transitable loc3 loc2)
    (= (distancia loc2 loc4) 800)
    (= (distancia loc4 loc2) 800)
    (transitable loc2 loc4)
    (transitable loc4 loc2)
    (= (distancia loc3 loc4) 400)
    (= (distancia loc4 loc3) 400)
    (transitable loc3 loc4)
    (transitable loc4 loc3)

    ;; Distancias aéreas adicionales entre zonas y puntos de agua.
    (= (distancia loc1 embalse) 1600)
    (= (distancia embalse loc1) 1600)
    (= (distancia loc1 mar) 1400)
    (= (distancia mar loc1) 1400)
    (= (distancia loc2 embalse) 1200)
    (= (distancia embalse loc2) 1200)
    (transitable loc2 embalse)
    (transitable embalse loc2)
    (= (distancia loc2 mar) 1000)
    (= (distancia mar loc2) 1000)
    (= (distancia loc3 embalse) 800)
    (= (distancia embalse loc3) 800)
    (= (distancia loc3 mar) 800)
    (= (distancia mar loc3) 800)
    (= (distancia loc4 embalse) 400)
    (= (distancia embalse loc4) 400)
    (= (distancia loc4 mar) 500)
    (= (distancia mar loc4) 500)
    (= (distancia embalse mar) 600)
    (= (distancia mar embalse) 600)
  )

  (:goal
    (and
      ;; Cada zona debe tener su tratamiento .
      (fuego-atacado loc1)
      (agua-descargada loc1)
      (fuego-atacado loc2)
      (agua-descargada loc2)
      (fuego-atacado loc3)
      (agua-descargada loc3)
      (retardante-descargado loc3)

      ;; Al terminar, todos los equipos deben volver a la base.
      (en jeep1 base)
      (en jeep2 base)
      (en camion1 base)
      (en camion2 base)
      (en camion3 base)
      (en avion1 base)
      (en avion2 base)
      (en helic1 base)
      (en helic2 base)
    )
  )

  ;; Se prioriza terminar pronto y, en segundo lugar, usar menos vuelos.
  (:metric minimize (+ (total-time) (* 10 (num-movimientos-aereos))))
)

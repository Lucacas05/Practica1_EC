#import "uc3mreport.typ": conf

#show: conf.with(
  degree: "Grado en ingeniería informática",
  subject: "Estructura de Computadores",
  year: (24, 25),
  project: "Práctica 1",
  title: "La mejor memoria de la historia",
  group: 84,
  authors: (
    (
      name: "Lucas",
      surname: "Sotomayor Barrios",
      nia: 100538813
    ),
    (
      name: "Mario",
      surname: "Torrente",
      nia: 100429022
    ),
  ),
  professor: "Perico de los Palotes",
  toc: true,
  logo: "old",
  language: "es"
)



= Introducción
#lorem(90)


== Motivación
#lorem(140)

== Problem Statement
#lorem(50)

= Related Work
#lorem(200)

#figure(
  image("img/old_uc3m_logo.svg", width: 70%),
  caption: [El mejor logo de la UC3M, con diferencia]
) <logo>
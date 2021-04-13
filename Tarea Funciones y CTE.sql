-- Tarea 1

-- 1
with t as ( -- sacamos todos los pagos hechos y los empezamos desde el segundo para así poder hacer las diferencias
	select p.payment_id as id1, p.payment_date as fecha
	from payment p
	where p.payment_id>1  
), s as( -- agrupamos en los diferentes clientes y sacamos su diferencia entre los pagos (-1) y sumamos cuantos pagos hizo cada uno
	select p1.customer_id as id2, sum(age(t.fecha, p1.payment_date)) as tiempo, count(p1.payment_id) as suma 
	from payment p1 join t on (p1.payment_id = t.id1-1)
	where age(t.fecha, p1.payment_date)>'00:00'::interval
	group by p1.customer_id 
) 
-- sacamos el promedio por cliente e imprimimos su nombre
select p2.customer_id,  (c.first_name || ' ' || c.last_name) as full_name, (s.tiempo/s.suma) as dias_prom_pago
from payment p2 join s on (p2.customer_id = s.id2)
join customer c using (customer_id)
group by p2.customer_id, (c.first_name || ' ' || c.last_name), (s.tiempo/s.suma)
order by p2.customer_id;

--2

with t as ( -- sacamos todos los pagos hechos y los empezamos desde el segundo para así poder hacer las diferencias
	select p.payment_id as id1, p.payment_date as fecha
	from payment p
	where p.payment_id>1  
), s as( -- agrupamos en los diferentes clientes y sacamos su diferencia entre los pagos (-1) y sumamos cuantos pagos hizo cada uno
	select p1.customer_id as id2, sum(age(t.fecha, p1.payment_date)) as tiempo, count(p1.payment_id) as suma 
	from payment p1 join t on (p1.payment_id = t.id1-1)
	where age(t.fecha, p1.payment_date)>'00:00'::interval
	group by p1.customer_id 
) , r as ( -- sacamos el promedio por cliente e imprimimos su nombre
	select p2.customer_id,  (c.first_name || ' ' || c.last_name) as full_name, (s.tiempo/s.suma) as dias_prom_pago
	from payment p2 join s on (p2.customer_id = s.id2)
	join customer c using (customer_id)
	group by p2.customer_id, (c.first_name || ' ' || c.last_name), (s.tiempo/s.suma)
	order by p2.customer_id
)

-- sabemos que la media es 4 .27
-- select avg(extract(days FROM r.dias_prom_pago)::numeric) as media from r  

select round(stddev(extract(days FROM r.dias_prom_pago)::numeric)) as desviacion_estandar from r  

-- Nos da una desviación estandar de 3, etnonces significa que no es una distribución normal tomando como base a su media



--3

with a as ( -- sacamos todos las rentas hechos y los empezamos desde el segundo para así poder hacer las diferencias
	select r.rental_id as id1, r.rental_date as fecha1
	from rental r
	where r.rental_id >1  
), b as( -- agrupamos en los diferentes clientes y sacamos su diferencia entre las rentas (-1) y sumamos cuantas rentas hizo cada uno
	select r1.customer_id as id2, sum(age(a.fecha1, r1.rental_date)) as tiempo1, count(r1.rental_id) as suma1 
	from rental r1 join a on (r1.rental_id = a.id1-1)
	where age(a.fecha1, r1.rental_date)>'00:00'::interval
	group by r1.customer_id 
), c as ( -- sacamos el promedio por cliente e imprimimos su nombre
	select r2.customer_id,  (c1.first_name || ' ' || c1.last_name) as full_name, (b.tiempo1/b.suma1) as dias_prom_renta
	from rental r2 join b on (r2.customer_id = b.id2)
	join customer c1 using (customer_id)
	group by r2.customer_id, (c1.first_name || ' ' || c1.last_name), (b.tiempo1/b.suma1)
	order by r2.customer_id
), t as ( -- sacamos todos los pagos hechos y los empezamos desde el segundo para así poder hacer las diferencias
	select p.payment_id as id3, p.payment_date as fecha2
	from payment p
	where p.payment_id>1  
), s as( -- agrupamos en los diferentes clientes y sacamos su diferencia entre los pagos (-1) y sumamos cuantos pagos hizo cada uno
	select p1.customer_id as id4, sum(age(t.fecha2, p1.payment_date)) as tiempo2, count(p1.payment_id) as suma2
	from payment p1 join t on (p1.payment_id = t.id3-1)
	where age(t.fecha2, p1.payment_date)>'00:00'::interval
	group by p1.customer_id 
) , r as ( -- sacamos el promedio por cliente e imprimimos su nombre
	select p2.customer_id,  (c2.first_name || ' ' || c2.last_name) as full_name, (s.tiempo2/s.suma2) as dias_prom_pago
	from payment p2 join s on (p2.customer_id = s.id4)
	join customer c2 using (customer_id)
	group by p2.customer_id, (c2.first_name || ' ' || c2.last_name), (s.tiempo2/s.suma2)
	order by p2.customer_id
)

select r.customer_id, r.full_name, r.dias_prom_pago, c.dias_prom_renta
from c join r on c.customer_id = r.customer_id

-- Concluimos
-- podemos ver que los tiempo de pago son mucho mayores en casi todos los casos que los tiempos de renta
-- el dia promedio de renta rara vez llega al día, mientras que el de pago ronda alrededor de los cuatro días








-- Tarea 2


with t as (
-- Calculamos el número de Blue-Rays por tienda
	select i.store_id as id, count(i.inventory_id) as cant_Peli
	from inventory i
	group by i.store_id 
	order by i.store_id
), s as ( 
-- Calculamos el número de películas que pueden caben dentro de un cilindro
-- tomando como restricción el peso 
	select 50000/500 as cantPeliculasEnCilindro  -- Resultado es 100 películas
)

-- El número de cilindros que debe ver por tienda
select t.id, ceil((t.cant_Peli :: float / s.cantPeliculasEnCilindro :: float)) as cant_Cilindros
from t, s



-- Las peliculas iran acomodadas de forma horizontal
-- Supondremos que el robot encargado de agarrar las películas del cilindro solo se puede mover
-- dentro de un cilindro interior las dimensiones de estre robot es de 60x60x60

with a as (
-- Calculamos el espacio que ocupa el robot
	select 60*60*60 as tamanoRobot  -- Resultado 216,000 cm^3
), b as ( 
-- Calculamos el espacio que debe cubrir el cilindro para tener 100 pelícuulas
	select 5040*100 as tamanoPeliculas -- Resultado es 504,000 cm^3
), c as (
-- Calculamos el radio del cilindro interior el radio será la distancia de equina a esquina entre dos
	select round(sqrt(2*(60^2))/2) as radioCilindroInt -- Resultado 42

), d as (
-- Calculamo la cantidad de peliculas que pueden ir en un mismo nivel con el perimetro del cilindro interior
-- entre lo largo de la pelicula que es 21 (esto da 12, pero como hay un 100 peliculas en el cilindro total 
-- le resto 2 para tener 10 niveles con 10 peliculas en cada uno
	select trunc(((pi() * 2 * c.radioCilindroInt)/21)- 2) as cantPeliPorNivel --Resultado 10
	from c
-- Sabemos que hay 10 niveles 
),e as (
-- Calculamos altura del cilindro total, ya que la altura por pelicula es de 8 y dejaremos un 1 cm entre peliculas
	select 9 * 10 as alturaCilindro -- Resultado 90
), f as (
-- Calculamos volumen del cilindro de interior con la altura de 90 y radio de 42
	select round(pi() * (c.radioCilindroInt^2) * e.alturaCilindro ) as areaCilindroInt  -- Resultado 498,759
	from c, e
), g as ( 
-- Área disponible para películas
	select b.tamanoPeliculas + f.areaCilindroInt as areaTotal --Resultado 1,002,759
	from b,f
), h as (
-- Entonces el radio del cilindro total es la suma del radio del cilindro interior mas lo largo de la pelicula 30 cm
	select round(c.radioCilindroInt + 30) as radioTotal --Resultado 72
	from c
)

-- 10 peliculas en cada nivel
-- 10 niveles
-- Radio = 72
-- Altura = 90

select round( (h.radioTotal^2) * pi() * e.alturaCilindro) as comprobacion, h.radioTotal, e.alturaCilindro
from e,h;
-- hay errores debido a los décimales y redondeos que utilizamos, asimismo, 
-- debido a que estamos metiendo peliculas en cilindros y le robot también hay espacio extra 
-- y como se calcularon dos áreas al mismo tiempo (ambos cilindros) es por eso que hay varios espacios
-- Area = 1,002,759









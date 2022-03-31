-- Selezionare fra i cliente quelli che hanno un abbonamento

-- Query con aggregazione e join a 3 tabelle
-- Per ogni Produttore, stampa delle sue informazioni e del quantitativo di tipologia di contenitori originali
-- (ovvero realizzate dallo stesso produttore della macchina)
select produttore.nome as nome,produttore.partita_iva as p_iva,produttore.anno_di_fondazione as anno,count(contenitore.produttore) as N°Contenitore
from produttore,macchina,contenitore 
where produttore.nome=macchina.produttore and macchina.formato=contenitore.formato and macchina.produttore=contenitore.produttore
group by(produttore.nome,produttore.partita_iva);

-- Query Nidificata con Interpretazione Complessa
-- Per ogni Cliente, stampa del numero degli ordini effettuati prima dell'anno corrente
-- Questo allo scopo di inviare promozioni per i clienti con un minimo di ordini
select cliente.cf,cliente.nome,cliente.cognome,count(cliente.codice_cliente) as N°Ordini from cliente,ordine 
where cliente.codice_cliente=ordine.cliente and ordine.numero not in 
(select ordine.numero
from ordine where cliente.codice_cliente=ordine.cliente and extract(year from ordine.data_inizio_ordine)=extract(year from CURRENT_DATE))
group by (cliente.cf,cliente.nome,cliente.cognome);
 
-- Query Insiemistica
-- Per Ogni Cliente, stampa di tutte le spedizioni ad esso relative
select cl.codice_cliente as codice_cliente,cl.cf,cl.nome,cl.cognome,sped.numero as n°spedizione, 'Spedizione_Abbonamento' as Tipologia from cliente as cl,spedizione_abbonamento as sped
where cl.codice_cliente=sped.codice_cliente
union
select cl.codice_cliente as codice_cliente,cl.cf,cl.nome,cl.cognome,sped.numero as n°spedizione, 'Spedizione_Ordine' as Tipologia from cliente as cl,spedizione_ordine as sped
where cl.codice_cliente=sped.ordine_cliente
order by codice_cliente;

-- Viste
-- Trovare il numero medio di ordini effettuato dal generico cliente
-- Risulta essere utile in vista di un'analisi aziendale riguardante l' ottimizzazione delle risorse
-- e lo spazio ad esse associate

create view Num_Ordini as
select cliente.codice_cliente as codice,COUNT(ordine.numero) as N_ordini from cliente,ordine
where cliente.codice_cliente=ordine.cliente
group by (cliente.codice_cliente);


select CAST(AVG(Num_Ordini.N_ordini) as numeric(5,1)) as N°Medio_Ordini_per_Cliente from Num_Ordini,cliente,ordine
where cliente.codice_cliente=ordine.cliente;

-- Operazione 6 ==> Stampa dei contenitori, ordinati per intensità delle miscele e filtrati per formato
-- Siccome il formato non può essere inserito dinamicamente, lo abbiamo fissato
create view contenitori_intensita as
select contenitore.codice as contenitore,miscela_di_caffe.intensita as intensita,formato.codice as formato from contenitore,miscela_di_caffe,formato
where contenitore.miscela_di_caffe=miscela_di_caffe.nome and contenitore.formato=formato.codice
order by(miscela_di_caffe.intensita);

select contenitore.codice,contenitore.produttore,contenitore.miscela_di_caffe,contenitore.prezzo_unitario,contenitore.tipologia,intensita from contenitore,contenitori_intensita
where contenitore.formato=5 and contenitore.codice=contenitore; 

-- Trovare nome e cognome dei clienti che non hanno ordinato dopo il 2019
-- Quest'operazione potrebbe servire all'azienda per rendersi conto dei clienti 
-- che non acquistano più con assiduità
select distinct cliente.codice_cliente,cliente.nome, cliente.cognome from cliente
where not exists (select * from ordine 
where ordine.cliente=cliente.codice_cliente and extract(year from ordine.data_inizio_ordine)>extract(year from to_date('01 Jan 2019', 'DD Mon YYYY')));

-- Per ogni Macchina, stampa delle caratteristiche del formato compatibile per la stessa e dell'eventuale rata mensile
-- nel caso di un comodato d'uso a pagamento
select mac.codice as macchina,mac.nome,mac.costo,form.codice as formato,form.nome,form.tipologia,como.rata_mensile
from macchina as mac,formato as form,comodato_d_uso_a_pagamento as como
where mac.formato=form.codice and como.macchina=mac.codice
order by(como.rata_mensile);

-- Vista
-- Trovare il produttore che rifornisce la nostra azienda di un solo tipo di contenitore
-- Può servire all'azienda per vedere da quale produttore si riforisce di meno, in modo da eventualmente aumentare il rifornimento
create view num_contenitori as
select produttore,count(codice) as N_contenitori from contenitore
group by(produttore);

select num_contenitori.produttore,n_contenitori as contenitori_disponibili,miscela_di_caffe.nome as nome,contenitore.grammi,contenitore.quantita,contenitore.prezzo_unitario as prezzo 
from num_contenitori,contenitore,miscela_di_caffe
where num_contenitori.produttore=contenitore.produttore and contenitore.miscela_di_caffe=miscela_di_caffe.nome and n_contenitori=1;


-- Per ogni macchina, stampa delle sue caratteristiche tecniche e dei contenitore originali/compatibili ad essa.

select mac.codice,mac.nome,mac.costo,car.pressione,car.grandezza_vaschetta,car.N°_erogatori,form.nome as formato,form.tipologia as tipologia,cont.produttore as produttore_contenitore,
misc.nome as miscela_contenitore,cont.grammi,cont.prezzo_unitario
from macchina as mac,caratteristiche_tecniche as car,contenitore as cont,miscela_di_caffe as misc,formato as form
where mac.caratteristiche_tecniche=car.codice and cont.formato=mac.formato and cont.miscela_di_caffe=misc.nome and mac.formato=form.codice;

--create database progetto_gruppo_02_ah;

drop table if exists sede_legale cascade;
drop table if exists produttore cascade;
drop table if exists macchina cascade;
drop table if exists caratteristiche_tecniche cascade;
drop table if exists contenitore cascade;
drop table if exists miscela_di_caffe cascade;
drop table if exists miscela cascade;
drop table if exists composto cascade;
drop table if exists formato cascade;
drop table if exists dimensione cascade;
drop table if exists misura cascade;
drop table if exists disponibilità cascade;
drop table if exists ordine cascade;
drop table if exists cliente cascade;
drop table if exists descrizione cascade;
drop table if exists ordine_concluso cascade;
drop table if exists spedizione_abbonamento cascade;
drop table if exists spedizione_ordine cascade;
drop table if exists abbonamento cascade;
drop table if exists comodato_d_uso_a_pagamento cascade;
drop table if exists comodato_d_uso_gratuito cascade;

-- prima creo le tabelle esterne

create table produttore (
	nome varchar(30) primary key,
	partita_iva bigint unique not null,
	anno_di_fondazione date not null,
	constraint check_p_iva check(partita_iva>9999999999 and partita_iva<100000000000)
);

create table formato(
	codice integer primary key check (codice > 0),
	forma varchar(30) not null,
	peso numeric(4,2) not null check (peso > 0),
	nome varchar(30) not null,
	tipologia varchar(7) not null,
    constraint check_tipologia_formato check(tipologia='cialda' or tipologia='capsula')
);

create table caratteristiche_tecniche (
	codice integer primary key check (codice > 0),
	pressione integer not null check (pressione > 0),
	grandezza_vaschetta numeric(2,1) not null check (grandezza_vaschetta > 0),
	N°_erogatori integer not null check (N°_erogatori > 0)
);

create table miscela_di_caffe (
	nome varchar(30) primary key,
	intensita integer not null check (intensita>0 and intensita<=10),
	decaffeinato boolean not null
);

create table miscela (
	nome varchar(30),
	percentuale integer check (percentuale > 0),
	primary key(nome,percentuale)
);

create table dimensione(
	dimensione integer primary key check (dimensione > 0)
);

create table cliente (
	codice_cliente integer primary key check (codice_cliente > 0),
	cf char(16) unique not null check(char_length(cf)=16),
	nome varchar(30) not null,
	cognome varchar(30) not null,
	via varchar(30) not null,
	cap integer not null,
	numero_civico integer not null check (numero_civico > 0),
	citta varchar(30) not null,
	constraint check_cap check(cap>9999 and cap<100000)
);

-- creo le tabelle interne e definisco i vincoli d'integrità referenziale

create table sede_legale (
	produttore varchar(30) primary key,
	via varchar(30) not null,
	cap integer not null,
	numero_civico integer not null check (numero_civico > 0),
	citta varchar(30) not null,
	constraint check_cap check(cap>9999 and cap<100000),
	constraint fk_sede_legale_produttore foreign key(produttore) 
	references produttore(nome) on update cascade on delete restrict
);

create table macchina (
	codice integer primary key check (codice > 0),
	nome varchar(30) not null,
	costo numeric(5,2) not null check (costo > 0),
	quantita integer not null check (quantita > 0),
	caratteristiche_tecniche integer not null,
	produttore varchar(30) unique not null,
	formato integer not null,
	constraint fk_macchina_caratteristiche_tecniche foreign key(caratteristiche_tecniche) 
	references caratteristiche_tecniche(codice) on update cascade on delete restrict,
	constraint fk_macchina_produttore foreign key(produttore) 
	references produttore(nome) on update cascade on delete restrict,
	constraint fk_macchina_formato foreign key(formato) 
	references formato(codice) on update cascade on delete restrict
);

create table contenitore (
	codice integer primary key check (codice > 0),
	grammi numeric(4,2) not null check (grammi > 0),
	quantita integer not null check (quantita > 0),
	prezzo_unitario numeric(4,2) not null check (prezzo_unitario > 0),
	tipologia varchar(7) not null,
	produttore varchar(30) not null,
	miscela_di_caffe varchar(30) not null,
	formato integer not null,
	constraint check_tipologia_contenitore check(tipologia='cialda' or tipologia='capsula'),
	constraint fk_contenitore_produttore foreign key(produttore) 
	references produttore(nome) on update cascade on delete restrict,
	constraint fk_contenitore_miscela_di_caffe foreign key(miscela_di_caffe) 
	references miscela_di_caffe(nome) on update cascade on delete restrict,
	constraint fk_contenitore_formato foreign key(formato) 
	references formato(codice) on update cascade on delete restrict
);

create table composto(
	miscela_nome varchar(30),
	miscela_percentuale integer,
	miscela_di_caffe varchar(30),
	primary key(miscela_nome,miscela_percentuale,miscela_di_caffe),
	constraint fk_composto_miscela foreign key(miscela_nome,miscela_percentuale) 
	references miscela(nome,percentuale) on update cascade on delete restrict,
	constraint fk_composto_miscela_di_caffe foreign key(miscela_di_caffe) 
	references miscela_di_caffe(nome) on update cascade on delete restrict
);

create table misura (
	formato integer,
	dimensione integer,
	primary key(formato,dimensione),
	constraint fk_misura_formato foreign key(formato) 
	references formato(codice) on update cascade on delete restrict,
	constraint fk_misura_dimensione foreign key(dimensione) 
	references dimensione(dimensione) on update cascade on delete restrict
);

create table ordine (
	numero integer check (numero > 0),
	cliente integer,
	data_inizio_ordine date not null,
	pagato boolean not null,
	prezzo numeric(6,2) not null check (prezzo > 0),
	primary key(numero,cliente),
	constraint fk_ordine_cliente foreign key(cliente) 
	references cliente(codice_cliente) on update cascade on delete restrict
);

create table disponibilità (
	contenitore integer, 
	ordine_numero integer,
	ordine_cliente integer,
	primary key(contenitore,ordine_numero,ordine_cliente),
	constraint fk_disponibilità_contenitore foreign key(contenitore) 
	references contenitore(codice) on update cascade on delete restrict,
	constraint fk_disponibilità_ordine foreign key(ordine_numero,ordine_cliente) 
	references ordine(numero,cliente) on update cascade on delete restrict
);

create table descrizione (
	ordine_numero integer,
	ordine_cliente integer,
	codice_contenitore integer not null,
	numero_pezzi integer not null check (numero_pezzi > 0),
	numero_confezioni integer not null check (numero_confezioni > 0),
	prezzo_prodotto numeric(5,2) not null check (prezzo_prodotto > 0),
	primary key(ordine_numero,ordine_cliente),
	constraint fk_descrizione_ordine foreign key(ordine_numero,ordine_cliente) 
	references ordine(numero,cliente) on update cascade on delete restrict,
	constraint fk_descrizione_contenitore foreign key(codice_contenitore) 
	references contenitore(codice) on update cascade on delete restrict
);

create table ordine_concluso (
	ordine_numero integer,
	ordine_cliente integer,
	primary key(ordine_numero,ordine_cliente),
	data_fine_ordine date not null,
	constraint fk_ordine_concluso_ordine foreign key(ordine_numero,ordine_cliente) 
	references ordine(numero,cliente) on update cascade on delete restrict
);

create table abbonamento (
	codice integer primary key check (codice > 0),
	codice_cliente integer unique not null,
	data_inizio date not null,
	data_fine date not null,
	valido boolean null,
	codice_contenitore integer not null,
	n_cialde integer not null check (n_cialde > 0),
	tariffa integer not null check (tariffa > 0),
	constraint fk_abbonamento_contenitore foreign key(codice_contenitore) 
	references contenitore(codice) on update cascade on delete restrict,
	constraint fk_abbonamento_cliente foreign key(codice_cliente) 
	references cliente(codice_cliente) on update cascade on delete restrict
);

create table spedizione_abbonamento (
	numero integer primary key check (numero > 0),
	abbonamento integer not null,
	codice_cliente integer not null,
	constraint fk_spedizione_abbonamento_abbonamento_codice foreign key(abbonamento) 
	references abbonamento(codice) on update cascade on delete restrict,
	constraint fk_spedizione_abbonamento_abbonamento_codice_cliente foreign key(codice_cliente) 
	references abbonamento(codice_cliente) on update cascade on delete restrict
);

create table spedizione_ordine (
	numero integer primary key check (numero > 0),
	ordine_numero integer not null,
	ordine_cliente integer not null,
	constraint fk_spedizione_ordine_ordine foreign key(ordine_numero,ordine_cliente) 
	references ordine(numero,cliente) on update cascade on delete restrict
);

create table comodato_d_uso_a_pagamento (
	codice integer check (codice > 0),
	cliente integer,
	rata_mensile numeric(5,2) not null check (rata_mensile > 0),
	data_inizio date not null,
	data_fine date not null,
	macchina integer not null,
	primary key(codice,cliente),
	constraint fk_comodato_d_uso_a_pagamento_cliente foreign key(cliente) 
	references cliente(codice_cliente) on update cascade on delete restrict,
	constraint fk_comodato_d_uso_a_pagamento_macchina foreign key(macchina) 
	references macchina(codice) on update cascade on delete restrict
);

create table comodato_d_uso_gratuito (
	codice integer check (codice > 0),
	cliente integer,
	data_inizio date not null,
	data_fine date not null,
	macchina integer not null,
	primary key(codice,cliente),
	constraint fk_comodato_d_uso_gratuito_cliente foreign key(cliente) 
	references cliente(codice_cliente) on update cascade on delete restrict,
	constraint fk_comodato_d_uso_gratuito_macchina foreign key(macchina) 
	references macchina(codice) on update cascade on delete restrict
);

-- effettuo il popolamento del database

insert into produttore values('Lavazza',45632147852,'2000-07-15'),
('Borbone',78923216535,'1990-05-25'),('Nespresso',78924512358,'2005-06-15'),('Kimbo',21308492594,'1999-03-12'),
('DeLonghi',15648962078,'2002-03-20');

insert into formato values(1,'circolare',0.25,'ESE','cialda'),(2,'quadrata',0.5,'Quadrata','cialda'),
(3,'trapezoidale',0.6,'Trapezoidale','cialda'),(4,'cilindrica',2,'Capsula Dolce Gusto','capsula')
,(5,'cilindrica',2.2,'Capsula Nespresso','capsula');

insert into caratteristiche_tecniche values (1,15,0.6,1),(2,17,1,2),(3,16,1.3,1),(4,20,1.7,2);

insert into miscela_di_caffe values ('Blu',5,false),('Rossa',10,false),
('Verde',2,true),('Oro',5,false);

insert into miscela values ('Arabica',80),('Robusta',20),('Arabica',100),('Liberica',50),
('Robusta',80),('Liberica',100),('Arabica',20);

insert into dimensione values (44),(50),(54),(62);

insert into cliente values (1,'SPSMRA80A01H703G','Mario','Esposito','Manzoni',80100,15,'Napoli'),
(2,'CTRDNC90R14I422Q','Domenico','Cetrangolo','Poseidonia',84073,7,'Sapri'),(3,'RSSSFN97C07I978F','Stefano','Rossi','Dante Alighieri',80040,6,'Striano'),
(4,'CSTPQL81P05E919W','Pasquale','Costantino','Francesco Petrarca',85046,3,'Maratea');

insert into sede_legale values ('Lavazza','Via Bologna',10152,32,'Torino'),('Borbone','Via Napoleone',80023,10,'Caivano'),
('Nespresso','Via del Mulino',20090,6,'Milano'),('Kimbo','Via Nazionale',80010,4,'Napoli');

insert into macchina values (1,'Lavazza A Modo Mio',74.99,5,2,'Lavazza',4),(2,'Kimbo Minicup',68.90,7,2,'Kimbo',5),
(3,'Nespresso Inissia',150,3,4,'Nespresso',1),(4,'De Longhi Dedica',243.99,5,3,'DeLonghi',1);

insert into contenitore values (1,7,1000,0.16,'cialda','Borbone','Blu',1),(2,7,1200,0.15,'cialda','Borbone','Rossa',1),
(3,6.1,1300,0.23,'capsula','Lavazza','Rossa',4),(4,5.7,1250,0.74,'capsula','Lavazza','Oro',5)
,(5,6.1,120,0.13,'capsula','Lavazza','Blu',4),(6,7,500,0.20,'cialda','Kimbo','Blu',2);

insert into composto values ('Arabica',20,'Blu'),('Robusta',80,'Blu'),('Robusta',80,'Rossa'),('Arabica',20,'Rossa');

insert into misura values (1,44),(2,50),(3,54),(4,62);

begin transaction;
insert into ordine values (1,2,'2010-05-23',true,100),(2,2,'2020-03-12',true,62.50),
(3,3,'2018-05-15',false,30.70),(4,4,'2021-02-20',true,52.30),(5,2,'2021-03-12',false,63.52);

insert into disponibilità values (1,1,2),(2,4,4),(3,2,2),(3,3,3),(2,5,2);

commit;

insert into descrizione values (1,2,2,100,2,30),(2,2,1,50,3,24),(3,3,3,150,2,69),(4,4,4,50,4,148);

insert into ordine_concluso values (1,2,'2010-05-23'),(2,2,'2020-03-13'),(3,3,'2018-05-17'),(4,4,'2021-02-21');

insert into abbonamento values (1,2,'2020-05-15','2021-05-15',null,2,50,20),(2,3,'2019-03-15','2020-03-15',null,1,100,40),
(3,1,'2019-05-15','2020-05-15',null,4,150,60),(4,4,'2016-03-15','2017-03-15',null,3,50,20);

insert into spedizione_abbonamento values (1,2,1),(2,3,2),(3,2,3),(4,4,4);

insert into spedizione_ordine values (1,1,2),(2,1,2),(3,2,2),(4,3,3),(5,4,4);

insert into comodato_d_uso_a_pagamento values (1,2,6.88,'2020-05-12','2021-05-12',1),(2,1,6.33,'2019-03-12','2020-03-12',2),
(3,2,13.75,'2020-05-10','2021-05-10',3),(4,4,22.37,'2015-08-20','2016-08-20',4);

insert into comodato_d_uso_gratuito values (6,2,'2020-05-1','2021-05-1',2),(7,1,'2011-05-1','2012-05-1',3),
(8,4,'2002-02-12','2003-02-12',2),(9,3,'2013-05-23','2014-05-23',3);

--select * from sede_legale;
--select * from produttore;
--select * from macchina;
--select * from caratteristiche_tecniche;
--select * from contenitore;
--select * from miscela_di_caffe;
--select * from miscela;
--select * from composto;
--select * from formato;
--select * from dimensione;
--select * from misura;
--select * from disponibilità;
--select * from ordine;
--select * from cliente;
--select * from descrizione;
--select * from ordine_concluso;
--select * from spedizione;
--select * from abbonamento;
--select * from comodato_d_uso_a_pagamento;
--select * from comodato_d_uso_gratuito;
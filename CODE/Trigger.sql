-- Trigger creazione/popolamento
create function check_codice() returns trigger as $$
BEGIN
if (exists (select * from comodato_d_uso_gratuito where codice = new.codice)) then
		raise exception 'Codice presente in Comodato Gratuito';
end if;
if (exists (select * from comodato_d_uso_a_pagamento where codice = new.codice)) then
		raise exception 'Codice presente in Comodato A Pagamento';
end if;
RETURN new;
END $$ LANGUAGE plpgsql;

create trigger check_codice
before insert or update of codice on comodato_d_uso_gratuito 
for each row execute procedure check_codice();

create trigger check_codice
before insert or update of codice on comodato_d_uso_a_pagamento
for each row execute procedure check_codice();

-- Cardinalità Minima (Stesso ragionamento per tutte le cardinalità minime presenti nel progetto)

create function check_disponibilità() returns trigger as $$
declare 
	riga record;
begin
	FOR riga in (select * from ordine) LOOP
		if (not exists (select * from disponibilità where ordine_numero=riga.numero and ordine_cliente=riga.cliente)) then
			raise exception 'Disponibilità non modificabile: Ordine % sarebbe poi assente',riga.numero;
		end if;
	END LOOP;
return null;
end $$ LANGUAGE PLPGSQL;

create trigger check_disponibilità
after delete or update on disponibilità
for each statement
execute procedure check_disponibilità();

create or replace function insertOrdine() returns trigger as $$
begin
	if (not exists (select * from disponibilità where ordine_numero=New.numero and ordine_cliente=New.cliente)) then
		raise exception 'Nessun Ordine % in Disponibilità',New.numero;
	end if;	
return null;
end $$ LANGUAGE plpgsql;

create constraint trigger insertOrdine
after insert on ordine
deferrable initially deferred
for each row
execute procedure insertOrdine();

-- Trigger Vincoli Aziendali

create function check_cliente() returns trigger as $$
BEGIN
if (exists (select * from comodato_d_uso_gratuito where cliente = new.cliente)) then
		raise exception 'Un Cliente Può Richiedere al Massimo un Comodato Gratuito';
end if;
RETURN new;
END $$ LANGUAGE plpgsql;

create trigger check_cliente
before insert or update of cliente on comodato_d_uso_gratuito
for each row execute procedure check_cliente();


create function check_abbonamento() returns trigger as $$
BEGIN
if (new.n_cialde>=100 and (new.valido=false or new.valido IS NULL)) then
		UPDATE abbonamento set valido = true
		where codice=new.codice;
		RETURN new;
end if;
if (new.n_cialde<100 and (new.valido=true or new.valido IS NULL)) then
		UPDATE abbonamento set valido = false
		where codice=new.codice;
		RETURN new;
end if;
RETURN old;
END $$ LANGUAGE plpgsql;

create trigger check_abbonamento
after insert or update of n_cialde on abbonamento
for each row execute procedure check_abbonamento();

create function check_contenitore() returns trigger as $$
DECLARE
	app varchar(7);
BEGIN
select formato.tipologia into app from formato
where new.formato=formato.codice;
if (new.tipologia NOT LIKE app) then
	raise exception 'Formato Non Compatibile';
end if;
RETURN new;
END $$ LANGUAGE plpgsql;

create trigger check_contenitore
before insert or update of formato on contenitore
for each row execute procedure check_contenitore();
--use sgn
Create table BNV01
( 
  codcred char(11) null, 
  coddesem char(3) null, 
  cctacod char(15) null, 
  nomcli char(35) null,
  dircli char(35) null, 	 
  dni char(3) null,
  numdocide char(13) null, 
  fecdes char(8) null, --FORMATO  AAAAMMDD
  fecven char(8) null, --FORMATO  AAAAMMDD
  fecultamor char(8) null, --FORMATO AAAAMMDD
  impdes char(11) null,
  salactdes char(11) null,
  valcuo char(11) null,
  tasa char(7) null,
  numcuo char (3) null,
  numcuogra char(3) null,
  numcuovig char(3) null,
  perpag char(3) null, 
  codubigeo char(6) null,
  indgar char(1) null,
  calcli char(1) null,  	
  codclisbs char(10)
)

drop table BNV01
select * from BNV01
delete from BNV01

insert into BNV01
	select * from BN
	--drop table BN
	select * from BNV01

	select len(numdocide) as 'cant'
	from BN 
	GROUP BY numdocide
	
	select calcli    
	from BN 
	GROUP BY calcli

	select * from FINAL order by codigo
	DROP TABLE FINAL
	
	drop table #tv01
	drop table #tv02
	drop table #tv03
	drop table #tv04
	drop table #tv05

SELECT * into #tv01 FROM  (
  select codigo as 'codigo',
	rtrim(codcred) as 'codcred', rtrim(coddesem) as 'coddesem', substring(rtrim(cctacod),4,15) as 'cctacod' 
	,replace(rtrim(nomcli),',','') as 'nomcli', replace(rtrim(dircli),'#','') as 'dircli'
	,rtrim(dni) as 'dni',rtrim(numdocide) as 'numdocide'
	,rtrim(fecdes) as 'fecdes'
	,rtrim(fecven) as 'fecven'
	,rtrim(fecultamor) as 'fecultamor'
	,rtrim(impdes)+'00' as 'impdes'
	,left(replace(rtrim(salactdes),'.',''),11) as 'salactdes'
	,left(replace(rtrim(valcuo),'.',''),11) as 'valcuo'
	,replace(tasa,'.','') as 'tasa'
	,rtrim(numcuo) as 'numcuo', rtrim(numcuogra) as 'numcuogra', rtrim(numcuovig) as 'numcuovig'
	, rtrim(perpag) as 'perpag', rtrim(codubigeo) as 'codubigeo', rtrim(indgar) as 'indgar'
	,rtrim(calcli)  as 'calcli',rtrim(codclisbs) as 'codclisbs'
 from FINAL
 --order by codigo 
) as tmp
		
		select * from #tv01 order by codigo

SELECT * into #tv02 FROM  (
  select codigo as 'codigo',
	rtrim(codcred) as 'codcred', rtrim(coddesem) as 'coddesem', rtrim(cctacod) as 'cctacod', 
	replace(rtrim(nomcli),'Ñ','N') as 'nomcli', replace(rtrim(dircli),'/','') as 'dircli'
	,rtrim(dni) as 'dni',rtrim(numdocide) as 'numdocide'
	,rtrim(fecdes) as 'fecdes'
	,rtrim(fecven) as 'fecven'
	,rtrim(fecultamor) as 'fecultamor'
	,rtrim(impdes) as 'impdes'
	,rtrim(salactdes) as 'salactdes'
	,rtrim(valcuo) as 'valcuo'
	,rtrim(tasa) as 'tasa'
	,rtrim(numcuo) as 'numcuo', rtrim(numcuogra) as 'numcuogra', rtrim(numcuovig) as 'numcuovig'
	, rtrim(perpag) as 'perpag', rtrim(codubigeo) as 'codubigeo', rtrim(indgar) as 'indgar'
	, '0' as 'calcli',rtrim(codclisbs) as 'codclisbs'
 from #tv01
 --order by codigo 
) as tmp02

		select * from #tv02 order by codigo

SELECT * into #tv03 FROM  (
  select codigo as 'codigo',
	rtrim(codcred) as 'codcred', rtrim(coddesem) as 'coddesem', rtrim(cctacod) as 'cctacod', 
	left(rtrim(nomcli),35) as 'nomcli', replace(rtrim(dircli),'.','') as 'dircli'
	,rtrim(dni) as 'dni',rtrim(numdocide) as 'numdocide'
	,rtrim(fecdes) as 'fecdes'
	,rtrim(fecven) as 'fecven'
	,rtrim(fecultamor) as 'fecultamor'
	,rtrim(impdes) as 'impdes'
	,rtrim(salactdes) as 'salactdes'
	,rtrim(valcuo) as 'valcuo'
	,rtrim(tasa) as 'tasa'
	,rtrim(numcuo) as 'numcuo', rtrim(numcuogra) as 'numcuogra', rtrim(numcuovig) as 'numcuovig'
	, rtrim(perpag) as 'perpag', rtrim(codubigeo) as 'codubigeo', rtrim(indgar) as 'indgar'
	, '0' as 'calcli',rtrim(codclisbs) as 'codclisbs'
 from #tv02
 --order by codigo 
) as tmp03

		select * from #tv03 order by codigo

	SELECT * into #tv04 FROM  (
  select codigo as 'codigo',
	rtrim(codcred) as 'codcred', rtrim(coddesem) as 'coddesem', rtrim(cctacod) as 'cctacod', 
	rtrim(nomcli) as 'nomcli', replace(rtrim(dircli),'-','') as 'dircli'
	,rtrim(dni) as 'dni',rtrim(numdocide) as 'numdocide'
	,rtrim(fecdes) as 'fecdes'
	,rtrim(fecven) as 'fecven'
	,rtrim(fecultamor) as 'fecultamor'
	,rtrim(impdes) as 'impdes'
	,rtrim(salactdes) as 'salactdes'
	,rtrim(valcuo) as 'valcuo'
	,rtrim(tasa) as 'tasa'
	,rtrim(numcuo) as 'numcuo', rtrim(numcuogra) as 'numcuogra', rtrim(numcuovig) as 'numcuovig'
	, rtrim(perpag) as 'perpag', rtrim(codubigeo) as 'codubigeo', rtrim(indgar) as 'indgar'
	, '0' as 'calcli',rtrim(codclisbs) as 'codclisbs'
 from #tv03
 --order by codigo 
) as tmp04

	select * from #tv04 order by codigo 

SELECT * into #tv05 FROM  (
  select codigo as 'codigo',
	rtrim(codcred) as 'codcred', rtrim(coddesem) as 'coddesem', rtrim(cctacod) as 'cctacod', 
	rtrim(nomcli) as 'nomcli', left(replace(rtrim(dircli),'Ñ','N'),35) as 'dircli'
	,rtrim(dni) as 'dni',rtrim(numdocide) as 'numdocide'
	,rtrim(fecdes) as 'fecdes'
	,rtrim(fecven) as 'fecven'
	,rtrim(fecultamor) as 'fecultamor'
	,rtrim(impdes) as 'impdes'
	,rtrim(salactdes) as 'salactdes'
	,rtrim(valcuo) as 'valcuo'
	,rtrim(tasa) as 'tasa'
	,rtrim(numcuo) as 'numcuo', rtrim(numcuogra) as 'numcuogra', rtrim(numcuovig) as 'numcuovig'
	, rtrim(perpag) as 'perpag', rtrim(codubigeo) as 'codubigeo', rtrim(indgar) as 'indgar'
	, '0' as 'calcli',rtrim(codclisbs) as 'codclisbs'
 from #tv04
 --order by codigo 
) as tmp05

	select dircli,  len(dircli)
	from #tv05
	group by dircli
	having  len(dircli) >35

	select nomcli,  len(nomcli)
	from #tv05
	group by nomcli
	having  len(nomcli) >35
	
	select * from #tv05 order by codigo

SELECT * into #FINAL FROM  (
  select codigo as 'codigo',
	rtrim(codcred) as 'codcred', rtrim(coddesem) as 'coddesem', rtrim(cctacod) as 'cctacod', 
	rtrim(nomcli) as 'nomcli', rtrim(dircli) as 'dircli'
	,rtrim(dni) as 'dni',rtrim(numdocide) as 'numdocide'
	,rtrim(fecdes) as 'fecdes'
	,rtrim(fecven) as 'fecven'
	,rtrim(fecultamor) as 'fecultamor'
	,rtrim(impdes) as 'impdes'
	,rtrim(salactdes) as 'salactdes'
	,rtrim(valcuo) as 'valcuo'
	,rtrim(tasa) as 'tasa'
	,rtrim(numcuo) as 'numcuo', rtrim(numcuogra) as 'numcuogra', rtrim(numcuovig) as 'numcuovig'
	, rtrim(perpag) as 'perpag', rtrim(codubigeo) as 'codubigeo', rtrim(indgar) as 'indgar'
	, '0' as 'calcli',rtrim(codclisbs) as 'codclisbs'
 from #tv05
 --order by codigo 
) as tmp99

	--drop table #FINAL
	select * from #FINAL order by codigo

	select dircli,  len(dircli)
	from #FINAL
	group by dircli
	having  len(dircli) >35

	select nomcli,  len(nomcli)
	from #FINAL
	group by nomcli
	having  len(nomcli) >35
--drop table #FINAL
/*
SELECT * into #tmpv01 FROM  (
select numdocide ,len(numdocide) as 'cant'
from #FINAL
) as tmp80

select * from #tmpv01
drop table #tmpv01

alter table #tmpv01
add numdocide01 char(13) null


update #tmpv01
Set numdocide01 = '0000000000000'
where numdocide ='19846129'

declare @a int, @b int, @c int, @d char(13)
set @a= (select len(impdes) from #tmpv01 where numdocide = '19846129')
set @b= (select len(impdes01) from #tmpv01 where numdocide = '19846129')
set @c= (@b - @a ) + 1
select @c, @b, @a
set @d = (select STUFF (impdes01,@c,@a,impdes) from #tmpv01 where numdocide = '19846129')
select @d

Update #tmpv01
Set impdes01 = @d
where numdocide = '19846129'

select * from #tmpv01
where numdocide = '19846129'
*/
select * from #FINAL 
where valcuo is not NULL and fecultamor is not NULL
order by codigo

CREATE NONCLUSTERED INDEX #FINAL_codigo_IXN ON #FINAL(codigo)

--CURSOR #TMP_CREMICRO
Declare @codigo int 		--@numdocide varchar(13)
Declare cRellenar CURSOR FOR
	select codigo from #FINAL where valcuo is not NULL and fecultamor is not NULL order by codigo
OPEN cRellenar
FETCH cRellenar into @codigo--@cctacod --@numdocide
WHILE (@@FETCH_STATUS=0)
BEGIN		
		declare @a int, @b int, @c int, @d char(13)
	
		set @a= (select len(codubigeo) from #FINAL where codigo = @codigo)--cctacod = @cctacod) --numdocide = @numdocide)
		set @b= (select len(codubigeo01) from #FINAL where codigo = @codigo)--cctacod = @cctacod) --numdocide = @numdocide)
		set @c= (@b - @a) + 1
		set @d = (select STUFF (codubigeo01,@c,@a,codubigeo) from #FINAL where codigo = @codigo)--cctacod = @cctacod) --numdocide = @numdocide)
		--select @d

		Update #FINAL--#tmpv01
		Set codubigeo01 = @d
		where codigo = @codigo --numdocide = @numdocide	

FETCH cRellenar INTO @codigo--@cctacod --@numdocide
END
CLOSE cRellenar
DEALLOCATE cRellenar

---------**********verificando
--select * from #tmpv01 

--01
select * from #FINAL order by codigo
 --(1773 row(s) affected) 
select * from #FINAL
where cctacod = '023101001199373'--'024101000449818' --

select cctacod,count(cctacod)
from #FINAL
group by cctacod
having count(cctacod) > 1

select cctacod,count(cctacod)
from #FINAL
group by cctacod
having count(cctacod) > 1

--023101001199373	2
--024101000449818	2
	--codcred,coddesem,cctacod,nomcli,dircli,	dni,numdocide,	fecdes	,fecven	,fecultamor	,impdes	
	--,salactdes,	valcuo	,tasa,	numcuo	,numcuogra	,numcuovig,	perpag,	codubigeo,	indgar,	calcli	,codclisbs
--from #FINAL
select * from #FINAL order by codigo

update #FINAL--#tmpv01
Set numdocide01 = '0000000000000'

update #FINAL
Set impdes01 = '00000000000'

update #FINAL
Set salactdes01 = '00000000000'

update #FINAL
Set valcuo01 = '00000000000'

update #FINAL
Set tasa01 = '0000000'

update #FINAL
Set numcuo01 = '000'

update #FINAL
Set numcuogra01 = '000'

update #FINAL
Set numcuovig01 = '000'

update #FINAL
Set perpag01 = '000'

update #FINAL
Set codubigeo01 = '000000'

--where numdocide ='19846129'
/*
alter table #FINAL
add numdocide01 char(13) null

alter table #FINAL
add impdes01 char(11) null

alter table #FINAL
add salactdes01 char(11) null

alter table #FINAL
add valcuo01 char(11) null

alter table #FINAL
add tasa01 char(7) null

alter table #FINAL
add numcuo01 char (3) null

alter table #FINAL
add numcuogra01 char (3) null
  
alter table #FINAL
add numcuovig01 char(3) null

alter table #FINAL
add perpag01 char(3) null

alter table #FINAL
add codubigeo01 char(6) null

*/


--drop table #FINAL
insert into BNV01
select 
	rtrim(codcred) as 'codcred',rtrim(coddesem) as 'coddesem',	rtrim(cctacod) as 'cctacod',	
	rtrim(nomcli) as 'nomcli'	,rtrim(dircli) as 'dircli',	rtrim(dni) as 'dni'
	,rtrim(numdocide01) as 'numdocide01' --numdocide	
	,rtrim(fecdes) as 'fecdes',	rtrim(fecven) as 'fecven', rtrim(fecultamor) as 'fecultamor'
	,rtrim(impdes01) as 'impdes01' --impdes
	,rtrim(salactdes01) as 'salactdes01'--	salactdes
	,rtrim(valcuo01) as 'valcuo01' --	valcuo
	,rtrim(tasa01) as 'tasa01' --tasa	
	,rtrim(numcuo01) as 'numcuo01'--numcuo	
	,rtrim(numcuogra01) as 'numcuogra01' --numcuogra	
	, rtrim(numcuovig01) as 'numcuovig01'--numcuovig	
	,rtrim(perpag01) as 'perpag01' -- perpag
	,rtrim(codubigeo01) as 'codubigeo',	rtrim(indgar) as 'indgar',	rtrim(calcli) as 'calcli'
	,rtrim(codclisbs) as 'codclisbs'
from #FINAL
--where valcuo is not NULL and fecultamor is not NULL
order by codigo

select * from BNV01 WHERE perpag IS NULL
select * from BNV01 WHERE perpag IS not NULL

select LEN(impdes) from BNV01
GROUP BY impdes
HAVING LEN(impdes) <= 11


delete from BNV01

select * from BNV01 WHERE nomcli like 'aguirre%capcha%'

select --concat        
		codcred +	coddesem +	cctacod +	nomcli +	dircli +	dni + numdocide +	fecdes +	fecven +
		fecultamor + impdes +	salactdes	+ valcuo	+ tasa	+ numcuo	+ numcuogra	+ numcuovig	 + perpag +
		codubigeo + indgar	+ calcli +	codclisbs   
from BNV01

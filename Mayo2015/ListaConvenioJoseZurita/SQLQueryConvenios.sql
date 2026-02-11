--drop table #tmpv01
SELECT * into #tmpv01 FROM  (
	SELECT 	
			CLIM.cCodSbs AS 'CodSbs'
			,CLI.cCodCliente AS 'CodigoCliente'
			,CLIM.cNomCliente AS 'NombreCliente'
			,CLIM.cNroDocIde as 'NroDocumento1'
			, (YEAR(GETDATE()) - YEAR(PN.dFecNacCli)) AS 'EDAD' 
			,PR.cDesProfes AS 'PROFESION'
			,B.cDesConven AS cDesConven
			,A.cCodConven
			,isnull(GGC.cDesGruCon,'NoRegistra') AS 'SECTOR'
			--DATOS DEL CREDITO
			,A.cCodCtaCre AS 'CodigoCredito'				
			,A.nMonCapDes as 'MontoDesembol' 	
			,(A.nMonCapDes - A.nMonCapPag) AS 'Saldo'		
			,CASE A.cCodTipMon
			 WHEN '1' THEN 'SOLES' 
			 WHEN '2' THEN 'DOLARES'			 
			 END AS 'MONEDA'
			,A.cCodTipCre,STC.cDesTipCre AS 'TipoCredito'
			,A.cCodProduc, STC.cDesProCre
			 ,A.cCodSubPro ,STC.cDesSubcRE AS 'SubProducto'
			,EC.cDescriEst							
			,C.cDirCliente AS 'DireccionCliente' 
			,isnull(C.cDirCliRef,'') as 'DireccionReferencia'
			,dis.cNomDistri AS 'DistritoCliente'
			,pro.cNomProvin AS 'Provincia'
			,DEP.cNomDepart AS 'Departamento'					
			,O.cDesOficin AS 'Agencia'
			,zo.cNomZona as 'Detalle_Zona', zon.cDesZona as 'Zona'				
		
	FROM [KPYMCreConven] A 
		INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = A.cCodCtaCre
		INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
				ON CLIM.cCodCliente = CLI.cCodCliente
		INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMPerNat] PN
				ON PN.cCodCliente = CLIM.cCodCliente 
		left JOIN [GENTPROFESIONES] PR
				ON PN.cCodProfes = PR.cCodProfes
		INNER JOIN KPYTEstCreCon EC 
		    	ON EC.cEstCreCon = A.cEstCreCon
		INNER JOIN [KPYTSUBTIPCRE] STC
			ON A.cCodTipCre = STC.cCodTipCre AND A.cCodProduc = STC.cCodProduc 
			AND A.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
		
		--UBIGEO DEL CLIENTE
		LEFT JOIN CMACHYOCLI_MANIANA.DBO.[CLIMDirecc] C
				ON CLI.cCodCliente = C.cCodCliente AND C.bDirPredet = 1	 
		INNER JOIN [GenTDepartame] dep
				ON DEP.cCodDepart = C.cCodDepart
		INNER JOIN [GentProvincia] pro
				ON pro.cCodProvin = C.cCodProvin and pro.cCodDepart = C.cCodDepart 
		INNER JOIN [GentDistrito] dis
				ON dis.cCodDistri = C.cCodDistri and DIS.cCodProvin = C.cCodProvin 
				and dis.cCodDepart = C.cCodDepart

		INNER JOIN KPYMConvenios B 
				ON A.cCodConven = B.cCodConven 
		INNER JOIN GENTOficinas O
				ON A.cCodOficin = O.cCodOficin
		left JOIN gentgruconv GGC
				ON GGC.cCodGruCon =  B.cSectorCon

		INNER JOIN [GentZona] zo
				ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
				and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
		INNER JOIN [Gentofizonas] goz
				ON goz.cCodOficin = O.cCodOficin
		INNER JOIN [GentZonas] zon
				ON goz.nCodZona = zon.nCodZona
	WHERE A.cEstCreCon = 'F'--IN ('F','I','H')   
			AND A.cCodConven <> 'XXXXXX'
			AND (A.cCodTipCre = '03' and A.cCodProduc = '05' AND A.cCodSubPro = '13' 
				and STC.lEstado = '1')	
	--ORDER BY CLI.cCodCliente 
) as tmp99
--(7,769 row(s) affected)

select * from #tmpv01 where NroDocumento1 is null

--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #tmpv01_CodigoCliente_IXN ON #tmpv01(CodigoCliente)
CREATE NONCLUSTERED INDEX #tmpv01_CodigoCredito_IXN ON #tmpv01(CodigoCredito)
CREATE NONCLUSTERED INDEX #tmpv01_CodSbs_IXN ON #tmpv01(CodSbs)
--------------------****************************************************************************

/*
SELECT TOP 1 * FROM CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
SELECT TOP 1 * FROM CMACHYOCLI_MANIANA.dbo.[CLIAMPerNat] 
SELECT * FROM CMACHYOCLI_MANIANA.dbo.[CLIAMPerNat] PN WHERE PN.cCodCliente = '107100014887'


SELECT * FROM CMACHYOCLI_MANIANA.dbo.[CLIMPerNat] WHERE cCodCliente = '107100014887'

select * from gentgruconv
cCodGruCon	cDesGruCon	cDesCorGru	lEstado
E	EDUCACION	SEC. EDUC.	1
SELECT TOP 1 * FROM GENTPROFESIONES
SELECT * FROM KPYMConvenios where cCodGruCon is not null
*/

alter table #tmpv01
add DiasAtraso int

select * from #tmpv01

SELECT * into #tmpv02 FROM  ( select * from #tmpv01) as tmp98
delete from #tmpv02
drop table #tmpv02
select * from #tmpv02

--CURSOR #TMP_CREMICRO
Declare @cCodCtaCre varchar(18), @diasatraso int
Declare cCursor99 CURSOR FOR
	select CodigoCredito from #tmpv01
OPEN cCursor99
FETCH cCursor99 into @cCodCtaCre
WHILE (@@FETCH_STATUS=0)
BEGIN
	set @diasatraso = (SELECT nDiaVenCuo FROM [KPYDPLANPAGCRE] 
						where cCodCtaCre=@cCodCtaCre and cCodEstPla ='E' 
							and cCodEstCuo ='P' 
							and cNumCuoPla = (select max(cNumCuoPla) 
												FROM [KPYDPLANPAGCRE] 
												where cCodCtaCre=@cCodCtaCre
												and cCodEstPla ='E' and cCodEstCuo ='P'))		

		Update #tmpv02 			 										
		Set DiasAtraso = @diasatraso
		where CodigoCredito = @cCodCtaCre	

FETCH cCursor99 INTO @cCodCtaCre
END
CLOSE cCursor99
DEALLOCATE cCursor99
-------------------------------------------------------
Select * from #tmpv02
Select * from #tmpv02 where CodSbs is null
Select * from #tmpv02 where DiasAtraso is null

Update #tmpv02
Set DiasAtraso = '0'
where DiasAtraso is null

alter table #tmpv02
add Cali varchar (15)

alter table #tmpv02
add NroEntidades int 

alter table #tmpv02
add Entidad varchar(50)

alter table #tmpv02
add DeudaTotal money

----RCC------------
select top 5 * from CRICMACHYO_DIARIO.DBO.urirccmae --CCLAFIN
select top 5 * from CRICMACHYO_DIARIO.DBO.urirccsal --CCALEMP
select top 5 * from CRICMACHYO_DIARIO.DBO.urirccmifi

Select * from #tmpv02

Select * from #tmpv02 where CodSbs !=''

Select len(CodSbs)--len(NroDocumento1) --* 
from #tmpv02 where CodSbs !=''

Select CCLAFIN,* from CRICMACHYO_DIARIO.DBO.urirccmae where CCODSBS = '0029038457'
Select CCLAFIN,* from CRICMACHYO_DIARIO.DBO.urirccmae_1 where CCODSBS = '0029038457'

Select --sum(NSALDOS) as 'DeudaTotal'
		* 
from CRICMACHYO_DIARIO.DBO.urirccsal_1  
where CCODSBS = '0029038457' and left(CCTACON,4) 
	in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426')

--26938.38
0067560817
0028744692           
--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #tmpv02_CodigoCliente_IXN ON #tmpv02(CodigoCliente)
CREATE NONCLUSTERED INDEX #tmpv02_CodigoCredito_IXN ON #tmpv02(CodigoCredito)
CREATE NONCLUSTERED INDEX #tmpv02_CodSbs_IXN ON #tmpv02(CodSbs)
--------------------****************************************************************************

		--CURSOR 
		Declare @codsbs varchar(10) , @cali varchar(15), @nroentidades int, @deudat money
		Declare cCursor98 CURSOR FOR
			select CodSbs from #tmpv02 where CodSbs != ''
		OPEN cCursor98
		FETCH cCursor98 into @codsbs
		WHILE (@@FETCH_STATUS=0)
		BEGIN
		  set @cali = (select CCLAFIN
					   from CRICMACHYO_DIARIO.DBO.urirccmae_1
					   where CCODSBS = @codsbs)		
		  set @nroentidades = (select NCANENT
					   from CRICMACHYO_DIARIO.DBO.urirccmae_1
					   where CCODSBS = @codsbs)

		 set @deudat = (Select sum(NSALDOS)
					from CRICMACHYO_DIARIO.DBO.urirccsal_1  
					where CCODSBS = @codsbs and left(CCTACON,4) 
						in ('1411','1413','1414','1415','1416','1421','1423','1424','1425','1426'))

		  Update #tmpv02 			 										
		  Set Cali = @cali
		  where CodSbs = @codsbs

		  Update #tmpv02 			 										
		  Set NroEntidades = @nroentidades
		  where CodSbs = @codsbs

		  Update #tmpv02 			 										
		  Set DeudaTotal = @deudat
		  where CodSbs = @codsbs

		FETCH cCursor98 INTO @codsbs
		END
		CLOSE cCursor98
		DEALLOCATE cCursor98
------------------------------------------------------------------------------------
Select * from #tmpv02

/*
- Categoría Normal ( 0 ) 
- Categoría con problemas Potenciales (1) 
- Categoría Deficiente ( 2 ) 
- Categoría Dudoso ( 3 ) 
- Categoría Pérdida ( 4 )
*/
Update #tmpv02
Set Cali = 'NORMAL'
where Cali = '0'

Update #tmpv02
Set Cali = 'CPP'
where Cali = '1'

Update #tmpv02
Set Cali = 'DEFICIENTE'
where Cali = '2'

Update #tmpv02
Set Cali = 'DUDOSO'
where Cali = '3'

Update #tmpv02
Set Cali = 'PERDIDA'
where Cali = '4'
---------------------------------------------------
	select * from #tmpv02 where CodSbs = ''

	uPDATE #tmpv02
	sET NroEntidades = 0
	where CodSbs = ''

	uPDATE #tmpv02
	sET Cali = 'NoRegistra'
	where CodSbs = ''

	uPDATE #tmpv02
	sET DeudaTotal = 0
	where CodSbs = ''

-----------------------------------------------------
select * from #tmpv02


drop table #tmpv02
drop table #tmpv01

	


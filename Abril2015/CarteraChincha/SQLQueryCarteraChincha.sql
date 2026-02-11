USE SOFCMACHYO_DIARIO_NOCHE

SELECT * into #cartchincha01 FROM  (
--CLIENTES DESERTORES creditos microempresa : #TMP_CREMICRO
SELECT --TOP 900000
	/*
	ROW_NUMBER() 
	OVER(PARTITION BY CLI.cCodCliente 
			ORDER BY CRE.dFecDesCre ) AS Secuencia,
	*/
	--Datos del Cliente
	CLIM.cCodSbs AS 'COD_SBS1'
	,CLIM.cNroDocIde as 'NroDocumento1'

	,CLI.cCodCliente AS 'CODIGO_CLIENTE'
	,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
	
	,C.cDirCliente AS 'Direccion_Cliente' 
	,isnull(C.cDirCliRef,'') as 'Direccion_Referencia_Cliente'
	,DEP.cNomDepart AS 'Departamento_Cliente'
	,pro.cNomProvin AS 'Provincia_Cliente'
	,dis.cNomDistri AS 'Distrito_Cliente'
	,isnull(CLIM.cNroTelPer,'') AS 'Nro_Telefono_Personal'
	,YEAR(CAST(GETDATE() AS DATE)) - YEAR(CAST(CLIPN.dFecNacCli AS DATE)) AS 'EDAD' 
	/*
	--FUENTES DE INGRESO
	,Case FI.cCodTipFin 
	 WHEN 'D' THEN 'DEPENDIENTE'
	 WHEN 'I' THEN 'INDEPENDIENTE'
	 END AS 'Tipo_Fuente_d_Ingreso'
	,isnull(CLIE.cDesRasSoc,FI.cNomEmp) AS 'Fuente_d_Ingreso'
	*/
	--DATOS DEL CREDITO
	,CRE.cCodCtaCre AS 'CODIGO_CREDITO' --smalldatetime, 
	--,CONVERT(smalldatetime ,CRE.dFecDesCre, 103 ) as 'Fecha_Desembolso_Credito'--FECHA DESEMBOLSO DEL CREDITO
	,CRE.dFecDesCre as 'Fecha_Desembolso_Credito'--FECHA DESEMBOLSO DEL CREDITO
	--,isnull(CRE.dFecCulCre,' ') as 'Fecha_Culminacion_Credito'--FECHA DE CULMINACION DEL CREDITO
	,case CRE.cCodPlazo
	 when '1' THEN 'CORTO PLAZO'
	 when '2' THEN 'LARGO PLAZO'
	 END AS 'PLAZO' 
	,CRE.nMonCapDes as 'MONTO_DESEMBOLSADO' 
	,case CRE.cCodTipMon 
	 When '1' then 'SOLES'
	 WHEN '2' THEN 'DOLARES'
	 END as 'MONEDA'
	,CRE.nMonCapPag as 'CAPITAL_PAGADO' 
	,(CRE.nMonCapDes - CRE.nMonCapPag)  AS 'SALDO_CAPITAL'
	,CRE.nSalCapDia AS 'SALDO_CAPITAL_AL_DIA'
	,EC.cDescriEst AS 'ESTADO_DEL_CREDITO'
	,CRE.cEstCreCon
	
	 ,CRE.cCodTipCre
	 ,STC.cDesTipCre AS 'TIPO_DE_CREDITO'	 
	 ,CRE.cCodProduc
	 ,STC.cDesProCre AS 'PRODUCTO_CREDITICIO' 
	 ,CRE.cCodSubPro	 
	 ,STC.cDesSubcRE AS 'SUBPRODUCTO_CREDITICIO'		 

	 --DATOS AGENCIA
	,O.cDesOficin AS 'NOMBRE_AGENCIA'
	,O.cCodOficin
	,O.cDirOficin AS 'DIRECCION_AGENCIA' 	
	,DEP1.cNomDepart AS 'Departamento_Agencia'			 
	,pro1.cNomProvin AS 'Provincia_Agencia' 
	,dis1.cNomDistri as 'Distrito_Agencia'
	,zo.cNomZona as 'Detalle_Zona', zon.cDesZona as 'Zona'
	,CRE.cCodUsuAna AS 'COD_ANALISTA_ACTUAL'--COD ANALISTA
	,SP.cNomPerson AS 'NOMBRE_ANALISTA_ACTUAL'--NOMBRE ANALISTA 	
	,SOLI.cCodUsuAna AS 'COD_ANALISTA_ORIGEN'
	,SP1.cNomPerson AS 'NOMBRE_ANALISTA_ORIGEN'--NOMBRE ANALISTA 	
	
FROM [KPYMCRECONVEN] CRE (NOLOCK)		
	INNER JOIN [GENMCRECLI] CLI 
			ON CLI.cCodCtaCre = CRE.cCodCtaCre
	INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
		    ON CLIM.cCodCliente = CLI.cCodCliente
	INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMPERNAT] CLIPN 
			ON  CLIPN.cCodCliente = CLIM.cCodCliente
	
	inner JOIN [sipmpersonal] SP 
	        ON SP.cCodPerson = CRE.cCodUsuAna
	INNER JOIN [GENTOficinas] O 
	        ON O.cCodOficin = CRE.cCodOficin
	INNER JOIN [KPYDPRODUCTO] PROD
			ON CRE.cCodProduc =  PROD.cCodProduc and CRE.cCodTipCre = PROD.cCodTipCre
	INNER JOIN [KPYDSUBPRODUC] SPRO
			ON CRE.cCodSubPro = SPRO.cCodSubPro AND CRE.cCodTipCre = SPRO.cCodTipCre
			AND CRE.cCodProduc =  SPRO.cCodProduc
	INNER JOIN [KPYTSUBTIPCRE] STC
			ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
			AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = 1
	INNER JOIN KPYTEstCreCon EC 
			ON EC.cEstCreCon = CRE.cEstCreCon
	
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
		
	---UBIGEO DEL CREDITO
	INNER JOIN [GenTDepartame] dep1
		ON DEP1.cCodDepart = O.cCodDepart
	INNER JOIN [GentProvincia] pro1
		ON pro1.cCodProvin = O.cCodProvin and pro1.cCodDepart = O.cCodDepart 
	INNER JOIN [GentDistrito] dis1
		ON dis1.cCodDistri = O.cCodDistri and dis1.cCodProvin = O.cCodProvin 
			and dis1.cCodDepart = O.cCodDepart
			
	INNER JOIN [GentZona] zo
		ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
		and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
	INNER JOIN [Gentofizonas] goz
		ON goz.cCodOficin = O.cCodOficin
	INNER JOIN [GentZonas] zon
		ON goz.nCodZona = zon.nCodZona
		/*
	--FUENTES DE INGRESO
	LEFT JOIN CMACHYOCLI_MANIANA.dbo.[CLIDFueIngreso] FI
		on FI.cCodCliente = CLI.cCodCliente	
	LEFT JOIN  CMACHYOCLI_MANIANA.dbo.[CLIMEMPEMPLEA] CLIE
		ON CLIE.nNumEmp = FI.nNumEmp
	--INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIDSucEmpEmp] CLISUC
		--ON CLIE.nNumEmp = CLISUC.nNumEmp AND FI.nNumSucEmp = CLISUC.nNumSucEmp
	*/
	--ANALISTA ORIGEN
	 INNER JOIN [kpymsolicitud] SOLI	
		ON SOLI.cCodSolCre = CRE.cCodSolCre
	 Inner JOIN [sipmpersonal] SP1 
	        ON SP1.cCodPerson = SOLI.cCodUsuAna
	
	 --DIAS DE ATRASO
	 --INNER JOIN [KPYDPLANPAGCRE] PLA
		--ON PLA.ccodctacre = CRE.cCodCtaCre
WHERE CRE.cEstCreCon in  ('F','H','I') --ESTADO DEL CREDITO ES VIGENTE F
		and  CRE.cCodOficin = '059'  --O.cCodOficin = '059'
		--and PLA.nDiaVenCuo > 15
	  	
) AS Tmp

--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #cartchincha01_COD_CLIENTE_IXN ON #cartchincha01(CODIGO_CLIENTE)
CREATE NONCLUSTERED INDEX #cartchincha01_COD_SBS1_IXN ON #cartchincha01(COD_SBS1)
CREATE NONCLUSTERED INDEX #cartchincha01_CODIGO_CREDITO_IXN ON #cartchincha01(CODIGO_CREDITO)
--------------------****************************************************************************
/*
--FUENTES DE INGRESO
	CLIE.cDesRasSoc AS 'Fuente_d_Ingreso'
		--FUENTES DE INGRESO
	LEFT JOIN CMACHYOCLI_MANIANA.dbo.[CLIDFueIngreso] FI
		on FI.cCodCliente = CLI.cCodCliente	
	LEFT JOIN  CMACHYOCLI_MANIANA.dbo.[CLIMEMPEMPLEA] CLIE
		ON CLIE.nNumEmp = FI.nNumEmp

Select top 2 * from CMACHYOCLI_MANIANA.dbo.[CLIDFueIngreso] FI
		--Select FI.cCodFueIng from CMACHYOCLI_MANIANA.dbo.[CLIDFueIngreso] FI GROUP BY FI.cCodFueIng
Select top 2 * from CMACHYOCLI_MANIANA.dbo.[CLIMEMPEMPLEA] CLIE
Select top 2 * from CMACHYOCLI_MANIANA.dbo.[CLIDSucEmpEmp] CLISUC

SELECT top 5 * from CMACHYOCLI_MANIANA.dbo.[CLIHFUEINGRESO] FI
WHERE FI.cCodCliente = '107020571888' AND FI.cCodTipFin = 'I'

Select FI.cCodCliente, FI.cCodFueIng, FI.nNumEmp	, FI.nNumSucEmp, CLIE.nNumEmp
		, CLIE.cDesRasSoc
		--, CLISUC.cNomSucEmp
from CMACHYOCLI_MANIANA.dbo.[CLIDFueIngreso] FI
		LEFT JOIN  CMACHYOCLI_MANIANA.dbo.[CLIMEMPEMPLEA] CLIE
			ON CLIE.nNumEmp = FI.nNumEmp
		--LEFT JOIN CMACHYOCLI_MANIANA.dbo.[CLIDSucEmpEmp] CLISUC
			--ON CLIE.nNumEmp = CLISUC.nNumEmp AND FI.nNumSucEmp = CLISUC.nNumSucEmp
WHERE FI.cCodCliente = '107020571888'

SELECT top 5 * FROM [kpymsolicitud] SOLI
SELECT top 5 SOLI.cCodCtaCre, SOLI.cCodClient, SOLI.cCodActAna, SOLI.cCodUsuAna, SOLI.cCodUsuIng 
FROM [kpymsolicitud] SOLI
		INNER JOIN [KPYMCRECONVEN] CRE 
			ON CRE.cCodCtaCre = SOLI.cCodCtaCre

SELECT TOP 5 cCodSolCre FROM [KPYMCRECONVEN] CRE 

SELECT cCodPlazo FROM [KPYMCRECONVEN] CRE  group by cCodPlazo

SELECT TOP 5 * FROM CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 

SELECT TOP 5 
		YEAR(CAST(GETDATE() AS DATE)) - YEAR(CAST(dFecNacCli AS DATE)) AS 'EDAD'
		,* 
FROM CMACHYOCLI_MANIANA.dbo.[CLIMPERNAT] CLIPN 

SELECT CAST(GETDATE() AS DATE)
*/
drop table #cartchincha01

select * from #cartchincha01 
--(3488 row(s) affected)

alter table #cartchincha01
add nDiaVenCuo int 

		SELECT * into #cartchincha02 FROM  (select top 1 * from #cartchincha01) as tmp99
		select * from #cartchincha02
		delete from #cartchincha02
		--drop table #cartchincha02

select * from #cartchincha01 where CODIGO_CREDITO = ''

SELECT max(PLA.nDiaVenCuo)
FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
WHERE PLA.cCodCtaCre = ''		
		AND PLA.cCodEstPla = 'E'

SELECT PLA.nDiaVenCuo, PLA.*
FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
WHERE PLA.cCodCtaCre = '107059101000614755'		
		AND PLA.cCodEstPla = 'E'

SELECT top 1 PLA.cNumCuoPla,PLA.*
FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
WHERE PLA.cCodCtaCre = '107059101000556091'		
		AND PLA.cCodEstPla = 'E' AND cCodEstCuo ='E'
		and PLA.dFecVenPag < GETDATE()


SELECT round(avg(cast(nDiaVenCuo as float)),0)
FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
WHERE PLA.cCodCtaCre = '107059101000628481'--@ccodcred

-----------------dias de atraso-----------------
		Declare @ccodcred varchar(18), @diaatr int		
			Declare cDiaAtraso CURSOR FOR	
			SELECT CODIGO_CREDITO FROM #cartchincha01 (NOLOCK) 	
			OPEN cDiaAtraso
				FETCH cDiaAtraso into @ccodcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN	

				set @diaatr =  (SELECT max(PLA.nDiaVenCuo)
								FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
								WHERE PLA.cCodCtaCre = @ccodcred	
										AND PLA.cCodEstPla = 'E')																																																	

				if @diaatr >= 15
				begin 

				INSERT INTO #cartchincha02
					SELECT * FROM #cartchincha01 (NOLOCK) 
					WHERE CODIGO_CREDITO = @ccodcred

				UPDATE #cartchincha02
				SET nDiaVenCuo = @diaatr
				WHERE CODIGO_CREDITO = @ccodcred
				
				END

				FETCH cDiaAtraso INTO @ccodcred
				END
				CLOSE cDiaAtraso
				DEALLOCATE cDiaAtraso

----------------VERIFICANDO---------------------------
			
			SELECT * FROM #cartchincha02 (NOLOCK)--DATA FILTRADA
			DELETE FROM #cartchincha02
	
--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #cartchincha02_COD_CLIENTE_IXN ON #cartchincha02(CODIGO_CLIENTE)
CREATE NONCLUSTERED INDEX #cartchincha02_COD_SBS1_IXN ON #cartchincha02(COD_SBS1)
CREATE NONCLUSTERED INDEX #cartchincha02_CODIGO_CREDITO_IXN ON #cartchincha02(CODIGO_CREDITO)
--------------------****************************************************************************

	alter table #cartchincha02
	add NumCuota CHAR(3)

	select * from #cartchincha02

-----------------cUOTA ATRASADA-----------------
		Declare @ccodcred varchar(18), @numcuota char(3)		
			Declare cDiaAtraso CURSOR FOR	
			SELECT CODIGO_CREDITO FROM #cartchincha02 (NOLOCK) 	
			OPEN cDiaAtraso
				FETCH cDiaAtraso into @ccodcred
				WHILE (@@FETCH_STATUS=0)
				BEGIN	

				set @numcuota =  (SELECT top 1 PLA.cNumCuoPla
								FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
								WHERE PLA.cCodCtaCre = @ccodcred		
										AND PLA.cCodEstPla = 'E' AND cCodEstCuo ='E'
										and PLA.dFecVenPag < GETDATE())																																								
												
				UPDATE #cartchincha02
				SET NumCuota = @numcuota
				WHERE CODIGO_CREDITO = @ccodcred		
			
				FETCH cDiaAtraso INTO @ccodcred
				END
				CLOSE cDiaAtraso
				DEALLOCATE cDiaAtraso
-----------------------------------------------------------------
select * from #cartchincha02
-----------------------------------------------------------------
SELECT top 1 PLA.cNumCuoPla,PLA.*
FROM [KPYDPLANPAGCRE] PLA (NOLOCK)
WHERE PLA.cCodCtaCre = '107059101000556091'		
		AND PLA.cCodEstPla = 'E' AND cCodEstCuo ='E'
		and PLA.dFecVenPag < GETDATE()

select CODIGO_CREDITO from #cartchincha02
select * from #cartchincha02 where NumCuota is NULL 
select * from #cartchincha02

Update #cartchincha02
set NumCuota = '---'
where NumCuota is NULL 

ALTER TABLE #cartchincha02
ADD RCC_MAR2014 VARCHAR(12)

ALTER TABLE #cartchincha02
ADD TIPO_FUENTE_INGRESO VARCHAR(25)

ALTER TABLE #cartchincha02
ADD FUENTE_INGRESO VARCHAR(100)

select * from #cartchincha02 (NOLOCK) --(752 row(s) affected)
select len(CODIGO_CLIENTE) from #cartchincha02 (NOLOCK)
---------------------------FUENTE DE INGRESO---------------------------------------
Declare @ccodcli varchar(12), @tfi char(50)	, @fi char(100)			
			Declare cFuenteIngreso CURSOR FOR	
			select CODIGO_CLIENTE from #cartchincha02 (NOLOCK)
			OPEN cFuenteIngreso
				FETCH cFuenteIngreso into @ccodcli
				WHILE (@@FETCH_STATUS=0)
				BEGIN	

		set @tfi =  (
				Select top 1	Case FI.cCodTipFin 
								 WHEN 'D' THEN 'DEPENDIENTE'
								 WHEN 'I' THEN 'INDEPENDIENTE'
								 END 								
				from CMACHYOCLI_MANIANA.dbo.[CLIDFueIngreso] FI
						left jOIN  CMACHYOCLI_MANIANA.dbo.[CLIMEMPEMPLEA] CLIE
							ON CLIE.nNumEmp = FI.nNumEmp		
				WHERE FI.cCodCliente = @ccodcli
				)																																							
				UPDATE #cartchincha02
				SET TIPO_FUENTE_INGRESO = @tfi
				WHERE CODIGO_CLIENTE = @ccodcli		
			
		set @fi =  (
				Select top 1 isnull(CLIE.cDesRasSoc,FI.cNomEmp) 		
				from CMACHYOCLI_MANIANA.dbo.[CLIDFueIngreso] FI
						left jOIN  CMACHYOCLI_MANIANA.dbo.[CLIMEMPEMPLEA] CLIE
							ON CLIE.nNumEmp = FI.nNumEmp		
				WHERE FI.cCodCliente = @ccodcli
				)																																															
				UPDATE #cartchincha02
				SET FUENTE_INGRESO = @fi
				WHERE CODIGO_CLIENTE = @ccodcli		

				FETCH cFuenteIngreso INTO @ccodcli
				END
				CLOSE cFuenteIngreso
				DEALLOCATE cFuenteIngreso
----------------------------------------------------------
select * from #cartchincha02 (NOLOCK) --(752 row(s) affected)
----------------------------------------------------------

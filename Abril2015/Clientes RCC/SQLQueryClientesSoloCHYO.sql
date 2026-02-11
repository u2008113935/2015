--/*
SELECT * into TMPCLICAJA FROM  (
SELECT --TOP 30
	   --ROW_NUMBER() 
	   --OVER(PARTITION BY year(CRE.dFecDesCre)--CLI.cCodCliente 
	   --ORDER BY left(cast(CRE.dFecDesCre as date),10)) AS Secuencia,
	   CASE  
	   WHEN A.CTIPPER = '1' THEN 'Persona Natural'
	   WHEN A.CTIPPER = '2' THEN 'Persona Juridica'
	   END as TipoPersona,
	   CASE  
	   WHEN A.CTIDOTR = '3' THEN A.CNUDOTR
	   WHEN A.CTIDOCI = '1' THEN A.CNUDOCI
	   END as NroDocumento,
	   B.CCODSBS as CodSBS,
	   (rtrim(A.CAPEPAT) + space(2) + rtrim(A.CAPEMAT) + space(2) + rtrim(A.CAPECAS) + space (2) 
	   + rtrim(A.CPRINOM) + space(2) + rtrim(A.CSEGNOM) ) as Apellidos_Nombres_Cliente,
	   --B.CCODEMP, 
	   CASE B.CTIPCRE
	   WHEN '01' THEN 'Créditos Soberanos' 
	   WHEN '02' THEN 'Créditos a Entidades del Sector Público' 
	   WHEN '03' THEN 'Créditos a Bancos Multilaterales de Desarrollo' 
	   WHEN '04' THEN 'Créditos a Empresas del Sistema Financiero' 
	   WHEN '05' THEN 'Créditos a Empresas de Valores' 
	   WHEN '06' THEN 'Créditos Corporativos' 	   
	   WHEN '07' THEN 'Créditos a Grandes Empresas' 
	   WHEN '08' THEN 'Créditos a Medianas Empresas' 
	   WHEN '09' THEN 'Créditos a Pequeña Empresas' 
	   WHEN '10' THEN 'Créditos a Microempresas' 
	   WHEN '11' THEN 'Créditos Consumo Revolventes' 
	   WHEN '12' THEN 'Créditos Consumo No Revolventes' 
	   WHEN '13' THEN 'Créditos Hipotecarios para Vivienda'
	   ELSE ' '
	   END AS 'Tipo_de_Credito',
	   CASE  
	   WHEN SUBSTRING(B.CCTACON,3,1) = '1' THEN 'Soles'
	   WHEN SUBSTRING(B.CCTACON,3,1) = '2' THEN 'Dólares'
	   END AS 'Moneda',
	   CASE  
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '1' 
	   THEN 'Créditos Vigente'
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '3' 
	   THEN 'Créditos Reestructurados'
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '4' 
	   THEN 'Créditos Refinanciados'
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '5' 
	   THEN 'Créditos Vencidos'
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '6' 
	   THEN 'Créditos en Cobranza Judicial'
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '8' 
	   THEN 'Rendimientos Devengados de Créditos Vigentes'
	   WHEN SUBSTRING(B.CCTACON,1,2) = '14' AND SUBSTRING(B.CCTACON,4,1) = '9' 
	   THEN 'Provisiones para Créditos'
	   ---72
	   WHEN SUBSTRING(B.CCTACON,1,2) = '72' AND SUBSTRING(B.CCTACON,4,1) = '5' 
	   THEN 'LÍNEAS DE CRÉDITO NO UTILIZADAS Y CRÉDITOS CONCEDIDOS NO DESEMBOLSADOS'
	   --81
	   WHEN SUBSTRING(B.CCTACON,1,2) = '81' AND SUBSTRING(B.CCTACON,4,3) = '923' 
	   THEN 'LÍNEAS DE CRÉDITO EN TARJETAS DE CRÉDITO DE CONSUMO'
	   --84
	   WHEN SUBSTRING(B.CCTACON,1,2) = '84' AND SUBSTRING(B.CCTACON,4,3) = '409' 
	   THEN 'OTRAS GARANTIAS NO PREFERIDAS'
	   --84
	   WHEN SUBSTRING(B.CCTACON,1,2) = '84' AND SUBSTRING(B.CCTACON,4,3) = '402' 
	   THEN 'GARANTIAS PREFERIDAS'
	   ELSE ''
	   END AS 'Estado_del_Credito',
	   B.CCTACON
	   , B.NCONDIA AS 'Dias', B.NSALDOS AS 'Saldo', 
	   --B.CCALEMP AS 'Cod_Clasif_del_Cliente',
	   CASE B.CCALEMP
	   WHEN '0' THEN 'NORMAL'
	   WHEN '1' THEN 'CPP'
	   WHEN '2' THEN 'DEFICIENTE'
	   WHEN '3' THEN 'DUDOSO'
	   WHEN '4' THEN 'PERDIDA'
	   WHEN '8' THEN 'SIN SALDOS EN LAS CUENTAS DE DEUDA DIRECTA, CONTINGENTES, CRÉDITOS CASTIGADOS'
	   ELSE ' '
	   END AS 'Clasificacion_del_Cliente',
	   C.cNomEmpSisFin as 'Nombre_Entidad_Financiera' 
	   --,C.ccodempsisfin,C.cGruEmpSisFin, C.cConEmpSisFin
	   --,D.cDirCliente AS 'Direccion'
 --INTO #TMPCLICAJA
FROM URIRCCMAE808 A (NOLOCK)
       INNER JOIN URIRCCSAL808 B
             ON A.CCODSBS = B.CCODSBS
       INNER JOIN GENCODSBSEMPSISFIN C
             ON B.CCODEMP = C.ccodempsisfin
       --INNER JOIN CLIMClientes D
		--	 ON A.CCODSBS = D.cCodSbs
WHERE --A.CCODSBS = '0076639469'--'0140542385'
		C.ccodempsisfin = '00107'
		and B.CCALEMP = '0'
		and SUBSTRING(B.CCTACON,1,2) = '14' 
		and SUBSTRING(B.CCTACON,4,1) <> '8' 
	    and SUBSTRING(B.CCTACON,4,1) <> '9' 
--ORDER BY B.CCODSBS
) AS Tmp
--*/

--SELECT * FROM #TMPCLICAJA -- (165282 row(s) affected)
--DROP TABLE #TMPCLICAJA

--CREATE NONCLUSTERED INDEX #TMPCLI_cCodcliente_IXN ON #TMPCLI(cCodCliente)

--INDEXANDO
		--CREATE NONCLUSTERED INDEX #TMPCLICAJA_CodSBS_IXN ON #TMPCLICAJA(CodSBS)



--SELECT TOP 10 *
--FROM URIRCCMAE808 --TABLA MAESTRO DE IDENTIFICACION (A)


------******************TRABAJANDO LA BD HISTORICA*************************---------------------

/*
SELECT TOP 50
	/*
	ROW_NUMBER() 
	OVER(PARTITION BY year(CRE.dFecDesCre)--CLI.cCodCliente 
	ORDER BY left(cast(CRE.dFecDesCre as date),10)) 
	AS Secuencia
	*/
	CRE.cCodUsuAna--COD ANALISTA
	,SP.cNomPerson AS 'ANALISTA'--NOMBRE ANALISTA 
	--,SC.cDesCarPer--CARGO ANALISTA                                                                                                                         
	,CRE.cCodOficin--CODIGO OFICINA
	--,SP.cCodOficin--CODIGO OFICINA
	,O.cDesOficin
	,CLI.cCodCliente
	,CLIM.cNomCliente
	,CRE.cCodCtaCre
	,CRE.cEstCreCon
	--,CRE.dFecGenCre--FECHA ASIGNACION
	--,CRE.dFecDesRef--FECHA DESEMBOLSO REF
	,year(CRE.dFecDesCre) as AÑO
	,Case month(CRE.dFecDesCre) 
	 when '1' then 'ENERO' 
	 when '2' then 'FEBRERO' 
	 when '3' then 'MARZO' 
	 when '4' then 'ABRIL' 
	 when '5' then 'MAYO' 
	 when '6' then 'JUNIO' 
	 when '7' then 'JULIO' 
	 when '8' then 'AGOSTO' 
	 when '9' then 'SEPTIEMBRE' 
	 when '10' then 'OCTUBRE' 
	 when '11' then 'NOVIEMBRE' 
	 when '12' then 'DICIEMBRE' 
	 END AS MES
	,left(cast(CRE.dFecDesCre as date),10) as FecDeseCred--FECHA DESEMBOLSO DEL CREDITO
	,isnull(left(cast(CRE.dFecCulCre as date),10),'') as FecCulmCred--FECHA DE CULMINACION DEL CREDITO
	,CRE.cIndNueRep--INDICADOR DE NUEVO O REPRESTAMO
	,left(cast(CLI.dFecAsiCre as date),10) as FecAsigCred--FECHA DE ASIGNACION DEL CREDITO
	--,CLI.cCodUltDes--CODIGO DEL ULTIMO DESEMBOLSO REGISTRADO
	,CASE CRE.cEstCreCon
	  WHEN 'F' THEN 'VIGENTE'
	  WHEN 'H' THEN 'JUDICIAL'
	  WHEN 'I' THEN 'CASTIGADO'
	  WHEN 'G' THEN 'CANCELADO'
      WHEN 'E' THEN 'PENDIENTE'
	  END AS ESTADOCRE
	--,CLIM.dFecIniSisF
	--,CLIM.dFecIniCmac
FROM SOFCMACHYO_201502.dbo.[KPYMCRECONVEN] CRE		
	INNER JOIN SOFCMACHYO_201502.dbo.[GENMCRECLI] CLI 
			ON CLI.cCodCtaCre = CRE.cCodCtaCre
	INNER JOIN CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
		    ON CLIM.cCodCliente = CLI.cCodCliente
	inner JOIN SOFCMACHYO_201502.dbo.[sipmpersonal] SP 
	        ON SP.cCodPerson = CRE.cCodUsuAna
	INNER JOIN SOFCMACHYO_201502.dbo.[GENTOficinas] O 
	        ON O.cCodOficin = CRE.cCodOficin
	--LEFT JOIN SIPTCAPCARORG SC ON SC.cCodGruPer = SP.cCodGruPer                                
WHERE CRE.cEstCreCon IN ('F','G')--ESTADO DEL CREDITO ES VIGENTE F
		--AND 
		--CRE.cIndNueRep = 'N'
		--AND 
		--CRE.dFecDesCre >= '20130101' 
		--AND CRE.dFecDesCre <= '20130131'
		--and CRE.cCodUsuAna = 'AHUAYN'
		--AND SC.cCodGruCar = 'NEG'
--ORDER BY CRE.dFecDesCre

*/
/*
-----------------------------------------------------
SELECT top 1 *
FROM CMACHYOCLI..CLIMCLIENTES
--WHERE CCODCLIENTE = '107017328754'

select top 20 * from KPYTCTARELCLI
-----------------------------------------------------
SELECT top 1 * FROM GENMCreCli
SELECT top 20 * FROM GENMCreCli 

SELECT cCodOficin,* FROM KPYMCRECONVEN CRE
where CRE.cCodUsuAna = 'AHUAYN'
		AND CRE.dFecDesCre >= '20130101' 
		AND CRE.dFecDesCre <= '20130131'

select top 2 * FROM CMACHYOCLI..CLIMCliente
select top 20 cCodGruPer,* from sipmpersonal

select cCodGruPer,* from sipmpersonal 
WHERE cCodPerson IN  ('AHUAYN')
--('NCASTI','KVALGA','RAYLLO','WSOTOA','MPILCO','ACAJAN')
AND cCodGruPer IN ('013','057') 

select * from SIPTCAPCARORG WHERE cDesCarPer LIKE '%AFC%'
select * from SIPTCAPCARORG WHERE cCodGruPer IN ('013','057') 
AND cCodGruCar = 'NEG'

select * from GENTOficinas

select top 5 * from KPYHSALCARTOT

SELECT * FROM sipmpersonal WHERE  cCodPerson = 'JHUAMS'

/*
-------------------------CREDITOS NUEVOS N Y PREFERENCIAL P---------

	------------------------------
	--ANALIZANDO LOS CREDITOS NUEVOS
	select top 5 * 
	from kpytctarelcli RC
		--INNER JOIN GENMCRECLI CLI ON CLI.cCodCliente = RC.cCodCliente
	where RC.cCodCliente = (select CLI.cCodCliente,* from GENMCRECLI CLI)
		
	------------------------------

	Select 
			O.cDesOficin,CLI.cCodCliente
		   ,CLIM.cNomCliente,SC.ccodctacre
			,SC.ccodusuana,SC.cIndNueRep,SC.cEstCreCon,SC.ccodctacre
			,SC.cCodModCre--modalidad de credito
			,SC.dFecDesCre --Fecha Desembolso
	from KPYHSALCARTOT SC
		INNER JOIN GENMCRECLI CLI ON CLI.cCodCtaCre = SC.cCodCtaCre
		INNER JOIN CMACHYOCLI..CLIMCLIENTES CLIM ON CLIM.cCodCliente = CLI.cCodCliente
		INNER JOIN GENTOficinas O ON O.cCodOficin = SC.cCodOficin
	where ccodusuana = 'AHUAYN'
			AND dFecProces = '20130131' --AL CIERRE
			AND dFecDesCre >= '20130101'
			and dFecDesCre <= '20130131'
	Order By dFecDesCre
*/
----------------------------------------------------------------

	Select cIndNueRep,cEstCreCon,COUNT(*) as CantidadCreditos
		INTO #CANTCRED
	from KPYHSALCARTOT
	where ccodusuana = 'AHUAYN'
			AND dFecProces = '20130131' --AL CIERRE
			AND dFecDesCre >= '20130101'
			and dFecDesCre <= '20130131'
	group by cIndNueRep,cEstCreCon

	SELECT * FROM #CANTCRED
	------CREDITOS CANCELADOS HACE MAS DE UN AÑO
    
	SELECT 
	        O.cDesOficin,CLI.cCodCliente
		   ,CLIM.cNomCliente,SC.ccodctacre
		   ,datediff(day,SC.dFecDesCre,CRE.dFecCulCre) as Dias
		   ,left(cast(SC.dFecDesCre as date),10) as FecDes
		   ,left(cast(SC.dFecProces as date),10) as dFecProces
		   ,left(cast(CRE.dFecCulCre as date),10) as FecCulCre
		   ,CASE SC.cEstCreCon
		    WHEN 'F' THEN 'VIGENTE'
			WHEN 'H' THEN 'JUDICIAL'
			WHEN 'I' THEN 'CASTIGADO'
			WHEN 'G' THEN 'CANCELADO'
			WHEN 'E' THEN 'PENDIENTE'
			END AS ESTADOSAL
		   ,CASE CRE.cEstCreCon
		    WHEN 'F' THEN 'VIGENTE'
			WHEN 'H' THEN 'JUDICIAL'
			WHEN 'I' THEN 'CASTIGADO'
			WHEN 'G' THEN 'CANCELADO'
			WHEN 'E' THEN 'PENDIENTE'
			END AS ESTADOCRE, SC.cCodUsuAna
		INTO #CREDCANC	
	from KPYHSALCARTOT SC
		inner join KPYMCRECONVEN CRE ON CRE.cCodCtaCre = SC.ccodctacre
		INNER JOIN GENMCRECLI CLI ON CLI.cCodCtaCre = CRE.cCodCtaCre
		INNER JOIN CMACHYOCLI..CLIMCLIENTES CLIM ON CLIM.cCodCliente = CLI.cCodCliente
		INNER JOIN GENTOficinas O ON O.cCodOficin = SC.cCodOficin
	where SC.dFecProces = '20130131'
		AND SC.cCodUsuAna = 'AHUAYN'
		AND SC.cEstCreCon = 'G'
		AND datediff(day,SC.dFecDesCre,CRE.dFecCulCre) >= 365		
	order by SC.dFecDesCre
	---395-111, 365-186
		/*
		SI NO MUESTRA NINGUN REGISTRO QUIERE DECIR QUE LOS CREDITOS EN LA CARTERA DEL ANALISTA
		SIGUEN VIGENTES, PARA QUE SEAN CONSIDERADOS COMO CREDITOS NUEVOS EL CLIENTE DEBE 
		TENER CREDITOS CANCELADOS HACE UN AÑO.
		*/
		SELECT * FROM #CREDCANC
		SELECT COUNT(*) AS CANTCREDCANC FROM #CREDCANC
	------------------------------------------------------------------


--------------------CLIENTES NUEVOS NUEVOS------------------
SELECT --TOP 5000 
	/*
	ROW_NUMBER() 
	OVER(PARTITION BY year(CRE.dFecDesCre)--CLI.cCodCliente 
	ORDER BY left(cast(CRE.dFecDesCre as date),10)) 
	AS Secuencia
	*/
	CRE.cCodUsuAna--COD ANALISTA
	,SP.cNomPerson AS 'ANALISTA'--NOMBRE ANALISTA 
	--,SC.cDesCarPer--CARGO ANALISTA                                                                                                                         
	,CRE.cCodOficin--CODIGO OFICINA
	--,SP.cCodOficin--CODIGO OFICINA
	,O.cDesOficin
	,CLI.cCodCliente
	,CLIM.cNomCliente
	,CRE.cCodCtaCre
	,CRE.cEstCreCon
	--,CRE.dFecGenCre--FECHA ASIGNACION
	--,CRE.dFecDesRef--FECHA DESEMBOLSO REF
	,year(CRE.dFecDesCre) as AÑO
	,Case month(CRE.dFecDesCre) 
	 when '1' then 'ENERO' 
	 when '2' then 'FEBRERO' 
	 when '3' then 'MARZO' 
	 when '4' then 'ABRIL' 
	 when '5' then 'MAYO' 
	 when '6' then 'JUNIO' 
	 when '7' then 'JULIO' 
	 when '8' then 'AGOSTO' 
	 when '9' then 'SEPTIEMBRE' 
	 when '10' then 'OCTUBRE' 
	 when '11' then 'NOVIEMBRE' 
	 when '12' then 'DICIEMBRE' 
	 END AS MES
	,left(cast(CRE.dFecDesCre as date),10) as FecDeseCred--FECHA DESEMBOLSO DEL CREDITO
	,isnull(left(cast(CRE.dFecCulCre as date),10),'') as FecCulmCred--FECHA DE CULMINACION DEL CREDITO
	,CRE.cIndNueRep--INDICADOR DE NUEVO O REPRESTAMO
	,left(cast(CLI.dFecAsiCre as date),10) as FecAsigCred--FECHA DE ASIGNACION DEL CREDITO
	,CLI.cCodUltDes--CODIGO DEL ULTIMO DESEMBOLSO REGISTRADO
	--,CLIM.dFecIniSisF
	--,CLIM.dFecIniCmac
FROM KPYMCRECONVEN CRE
	INNER JOIN GENMCRECLI CLI ON CLI.cCodCtaCre = CRE.cCodCtaCre
	INNER JOIN CMACHYOCLI..CLIMCLIENTES CLIM ON CLIM.cCodCliente = CLI.cCodCliente
	inner JOIN sipmpersonal SP ON SP.cCodPerson = CRE.cCodUsuAna
	INNER JOIN GENTOficinas O ON O.cCodOficin = CRE.cCodOficin
	--LEFT JOIN SIPTCAPCARORG SC ON SC.cCodGruPer = SP.cCodGruPer                                
WHERE --CRE.cEstCreCon= 'F'--ESTADO DEL CREDITO ES VIGENTE F
		--AND 
		--CRE.cIndNueRep = 'N'
		--AND 
		CRE.dFecDesCre >= '20130101' 
		AND CRE.dFecDesCre <= '20130131'
		and CRE.cCodUsuAna = 'AHUAYN'
		--AND SC.cCodGruCar = 'NEG'
--ORDER BY CRE.dFecDesCre

--------------------CLIENTES QUE NO REGISTRARON OPERACIONES MENORES A UN AÑO------------------
SELECT TOP 100 
	cCodCtaCre, cEstCreCon
	,dFecGenCre--FECHA ASIGNACION
	,dFecDesRef--FECHA DESEMBOLSO REF
	,dFecDesCre--FECHA DESEMBOLSO DEL CREDITO
	,dFecCulCre--FECHA DE CULMINACION DEL CREDITO
	,cCodUsuAna--COD ANALISTA
	,cCodOficin--CODIGO OFICINA
	,cIndNueRep--INDICADOR DE NUEVO O REPRESTAMO
FROM KPYMCRECONVEN
WHERE dFecCulCre <= '2014-02-28'

*/
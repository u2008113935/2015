
	/*

	Se solicita data de los creditos desembolsados de los siguuientes:
	rangos mayor a S/. 40 000 y menor igual a S/. 50 000 , 
	que hayan sido aprobados por el jefe regional , 
	desde el 2008 hasta la fecha . 
		con los siguientes datos : calificacion , dias de atraso , numeros de cuotas , monto desembolsado 
		
	*/
	

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-08-01' )	
	
	Select * into #tab01 from (
	Select 
		ROW_NUMBER() 
					OVER(PARTITION BY year(A.dFecRegApr)
							ORDER BY MONTH (A.dFecRegApr) ) AS Secuencia 
		,Anio= year(A.dFecRegApr), Mes = MONTH (A.dFecRegApr),NombreMes =DATENAME(month, A.dFecRegApr)
		--A.cCodSolCre, A.lEstOpiFav, A.lEstOpiDes, A.cOpiComApr, A.cCodTipAct ,
		,FechaRegistro = left(cast(A.dFecRegApr as date),10) --, A.cCodOrdVot, A.dFecHorReg
		,A.cCodUsuReg --A.cCodPerson
		,P.cNomPerson, C.cDesCarPer  	

		,CodigoCredito = CRE.cCodCtaCre, MontoDesembolso = CRE.nMonCapDes 
		,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SaldoCapital'		
		,case cre.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'
		,MontoDesembolsadoenSoles = 
		case cre.cCodTipMon
			WHEN '1' THEN CRE.nMonCapDes
			WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
			END			
		,SaldoCapitalenSoles = 
		case cre.cCodTipMon
			WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
			WHEN '2' THEN @nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag)
			END				
		,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'				
		,left(cast(CRE.dFecCulCre as date),10) as 'FechaCancelacionCredito'
		,TEM=CRE.nTasintCom	
		,PlazoInicial = CRE.nNumDiaApr
		,NumeroCuotas=CRE.nNumCuoApr					 					
		,DiasGracia = CRE.nNumDiaGra
		,FormaPago= ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)					
		,SituacionCredito =
			Case CRE.cEstCreCon
			when 'G' then 'CANCELADO' 
			ELSE D.cDesConCre
			END
		,DiasAtraso = Case when CRE.nDiaAtrCre < 0 then 0 else CRE.nDiaAtrCre end 					
		,STC.cDesTipCre AS 'TipoCredito'
		,STC.cDesSubTip AS 'SubTipoCredito'		
		,STC.cDesProCre AS 'ProductoCrediticio' 		
		,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
		,Oficina = O.cDesOficin								
		,Zona = ZON.cDesZona				
		--,CRE.cCodUsuAna AS 'CodAsesorActual'
		--,P.cNomPerson AS 'NombreAsesorActual'		
		
	From kpydComaprCre A
		inner join sipmpersonal P 
			on A.cCodUsuReg = P.cCodPerson
		inner join SIPTCARGOPER C
			on C.cCodGruPer = P.cCodGruPer 
		INNER JOIN KPYMSolicitud S
			ON S.cCodSolCre = A.cCodSolCre 
		INNER JOIN [GENMCRECLI] CLI 
			ON CLI.cCodLinCre = S.cCodLinCre
		inner join [KPYMCRECONVEN] CRE (NOLOCK)	
			on CRE.cCodCtaCre = CLI.cCodCtaCre

		INNER JOIN [KPYTSUBTIPCRE] STC 
			ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
				AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'		
		INNER JOIN [GENTOficinas] O 
			ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
		INNER JOIN [Gentofizonas] GOZ
			ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
		INNER JOIN [GentZonas] ZON
			ON ZON.nCodZona = GOZ.nCodZona			
		--condicion credito 
		INNER JOIN [KPYTConCredit] D
			ON D.cCondicCon = CLI.cCondicCon				

	Where left(cast(A.dFecRegApr as date),10) > '2008-01-01'
		and C.cCodGruPer = 'JNR'
		--and CRE.nMonCapDes >= 40000 and CRE.nMonCapDes <= 50000
		--and @nTipCambio * CRE.nMonCapDes >= 12543.12 and @nTipCambio * CRE.nMonCapDes <= 15678.90
		and A.lEstOpiFav = '1'
	--Order By A.dFecRegApr
	 ) as tmp

	
	/*
	 
	 Select * from #tab01
	 Drop table #tab01

	*/
		-- (78,309 row(s) affected)
	
	Select * into #tab02 from (
			Select * from #tab01 
			where Moneda = 'SOLES' and MontoDesembolso > 40000 and MontoDesembolso <= 50000 		
		
			Union all

			Select * from #tab01 
			where Moneda = 'DOLARES' and MontoDesembolso > 12543.12 and MontoDesembolso <= 15678.90
			) as tmp

		Select * from #tab02 Order By Anio, Mes
		
	/*
		SELECT TOP 1 * FROM [GENMCRECLI] CLI 
		SELECT TOP 1 * FROM KPYMSolicitud

	Select top 10 *  from sipmpersonal

	Select *  from sipmpersonal where cNumDocIde = '43111949'

	-- SIPMPERSONAL P01  	ON P01.cCodPerson = B.cCodUsuApr
	-- SIPTCARGOPER P02 		ON P02.cCodGruPer = P01.cCodGruPer 
	-- Select * from SIPTCARGOPER
	
	Select * from SIPTCARGOPER where cDesCarPer like '%regio%'


	SELECT top 100
			sol.cCodOficin
			--,CAST(YEAR(@x_dFecSis) AS CHAR(4)) + RIGHT('00' + RTRIM(CAST(MONTH(@x_dFecSis) as CHAR(2))),2) as cmes
			--,@x_dFecSis as dfecproces,
			,cli.cCodSbs, ccodsolcre, ccodclient, replace(cnomcliente,',','') as cnomcli, 
			null, null, '107' as cCodIfi, sol.cCodOficin,
			cDesOficin, cCodClaPer, cCodTipDocId, cli.cnrodocide,
			case when isnull(cNroDocTri,'') <> '' THEN '5' ELSE null END, cNroDocTri, cCodMoneda, '70218',
			NULL, cCodExpCli, nMonSolCre, cClaFin,
			null, 'A', sol.cCodOficin, --	@x_cCodUsu,
			sol.cCodOficin, null, null, null,
			ccodUsuana
		FROM kpymsolicitud sol (nolock) 
			INNER JOIN CMACHYOCLI_MANIANA..climclientes cli (nolock)
				on sol.ccodclient = cli.ccodcliente
			INNER JOIN gentoficinas ofi
				on sol.ccodoficin = ofi.ccodoficin
			LEFT JOIN CRICMACHYO_DIARIO..URIRCCMAE rie
				on cli.cnrodocide = rie.cnudoci
		WHERE cCodSolCre = @x_cCodSolCre

	*/





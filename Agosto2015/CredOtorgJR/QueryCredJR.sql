
	/*	
	Créditos hasta 40000 otorgados en la Ag. Cañete que han sido aprobados por el
	Jefe Jegional Jhon Cubas (jcubas)
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
		,cre.cCodOficin
		,Oficina = O.cDesOficin								
		,Zona = ZON.cDesZona
		,CLI.cCodCliente				
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
		and CRE.cEstCreCon in ('G','F','H','I')
	--Order By A.dFecRegApr
	 ) as tmp

	
	/*
	 
	 Select * from #tab01	-- (45,509 row(s) affected)
	 Drop table #tab01

	*/
		-- (78,309 row(s) affected)
	
	/*
	Select * from #tab01

	Select cCodOficin,Oficina
	From #tab01
	where Oficina like '%ca%'
	Group By cCodOficin,Oficina

	Select cCodUsuReg,cNomPerson
	From #tab01
	Group By cCodUsuReg,cNomPerson
	*/

	Select A.*, C.cNomCliente 
	from #tab01 A
		inner join [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C 
			on C.cCodCliente = A.cCodCliente
	Where A.cCodUsuReg = 'JCUBAS'
		and A.cCodOficin = '043'
		and A.MontoDesembolsadoenSoles <= 40000.00
	Order By A.MontoDesembolsadoenSoles desc


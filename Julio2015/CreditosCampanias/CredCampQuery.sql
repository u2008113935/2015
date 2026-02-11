
	/*
	Buenas tardes, sirva la presente para solicitar data de créditos otorgados mediante campañas,
	por montos, TAP y plazo. de la campaña 2014 y campañas 2015.
	*/

	/*
	SELECT *
	FROM KPYMConvenios
	WHERE --cCodEstCon = 'A'
		cObsConven LIKE '%campa%'		
		AND cCodConven <> 'XXXXXX'
		and year(dFecRegCon) >= '2014'
	*/

	Select 
			CodigoCliente = CLI.cCodCliente 	
			--Datos del credito
			,CodigoCredito = CRE.cCodCtaCre			
			,CRE.cCodTipCre
			,TipoCredito=STC.cDesTipCre
			,SubTipoCredito=STC.cDesSubTip 
			,CRE.cCodProduc
			,ProductoCrediticio=STC.cDesProCre 
			,CRE.cCodSubPro	
			,SubProductoCrediticio=STC.cDesSubcRE 						
			,Moneda =
			 case cre.cCodTipMon
			 when '1' then  'SOLES'
			 when '2' then  'DOLARES'
			 end 
			,MontoDesemb= CRE.nMonCapDes 		 			 
			,CRE.nTasintCom
			,dFecDesCre=left(cast(CRE.dFecDesCre as date),10)
			,PlazoInicial = CRE.nNumDiaApr
			,CuotasAprobadas = CRE.nNumCuoApr
			,DiasGracia = CRE.nNumDiaGra
			,FormaPago= ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)
			,dFecCulCre=isnull(left(cast(CRE.dFecCulCre as date),10),'')
			,PlazoHastaLaCanc=
			isnull(DATEDIFF(day,left(cast(CRE.dFecDesCre as date),10),left(cast(CRE.dFecCulCre as date),10)),'')			
			,SaldoSoles=
			 case cre.cCodTipMon
			 when '1' then (CRE.nMonCapDes - CRE.nMonCapPag)  --'SOLES'
			 when '2' then (CRE.nMonCapDes - CRE.nMonCapPag)  --'DOLARES'
			 end 		
			,CRE.cEstCreCon
			,EC.cDescriEst AS 'EstadoCredito'
			,cDesConCre = Case CRE.cEstCreCon
								when 'G' then 'CANCELADO' 
								ELSE D.cDesConCre
								END 
			,CRE.cCodConven, C.cDesConven			
			,O.cCodOficin, O.cDesOficin, ZON.nCodZona, ZON.cDesZona				
		From [KPYMCRECONVEN] CRE (NOLOCK)
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN [KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
					AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			INNER JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'				
			INNER JOIN Gentofizonas GOZ
				ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
			INNER JOIN GentZonas ZON
				ON ZON.nCodZona = GOZ.nCodZona	
					
			inner join KPYMConvenios C
				on C.cCodConven = CRE.cCodConven
			INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon
		Where CRE.cEstCreCon in ('G','F','H','I')
			and left(cast(CRE.dFecDesCre as date),10) >= '2014-01-01'			
			and C.cObsConven LIKE '%campa%'		
			AND C.cCodConven <> 'XXXXXX'
			and year(C.dFecRegCon) >= '2014'
		Order by CLI.cCodCliente 
		
		-- (169,320 row(s) affected)


	/*
	select *
	from 
	*/
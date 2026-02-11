
	/*
	Buenas noches por medio de la presente se require la data para calzar la linea 
	adeuda de cofide que tenga las siguientes caracteristicas : 
		personas naturales o jurídicas que tengan créditos Micro y pequeña empresa, 
		bajo el Sub producto: empresarial, agropecuario, credivip , 
		en modalidad principal, cuyos plazos de créditos sean máximo para 36 meses 
		( incluido el periodo de gracia ) y en el caso de libre amortización , 
		paralelos y por campaña el plazo menor a 01 año , 
		a partir del 24 de Julio hasta el 31 de Julio del 2015.
	*/

	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-08-01'				
				)
	
	-- drop table #tab01
	Select * into #tab01 from (
			Select 		
					ROW_NUMBER() 
					OVER(PARTITION BY year(CRE.DFECDESCRE)
							ORDER BY MONTH (CRE.DFECDESCRE) ) AS Secuencia 
					,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
					,NombreMes =DATENAME(month, CRE.DFECDESCRE)
					--,CRE.cCodTipCre
					,STC.cDesTipCre AS 'TipoCredito'
					,STC.cDesSubTip AS 'SubTipoCredito'
					--,CRE.cCodProduc
					,STC.cDesProCre AS 'ProductoCrediticio' 
					--,CRE.cCodSubPro	
					,STC.cDesSubcRE AS 'SubProductoCrediticio' 							
					--Datos del credito			
					,CRE.nMonCapDes as 'MontoDesembolso' 
					,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SaldoCapital'
					,case cre.cCodTipMon
					when '1' then 'SOLES'
					when '2' then 'DOLARES'
					end AS 'Moneda'
					,SaldoCapitalenSoles = 
						case cre.cCodTipMon
						WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
						WHEN '2' THEN @nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag)
						END					
			
					,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'				
					,TEM=CRE.nTasintCom	
					,NumeroCuotas=CRE.nNumCuoApr
					,DiasAprobados=CRE.nNumDiaApr
					,DiasGracia = CRE.nNumDiaGra
					,FormaPagoDias= ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)												 
					,CRE.cCodModCre, M.cDesModCre, CRE.cLibAmoCre
					--,CRE.cEstCreCon
					--,EC.cDescriEst AS 'EstadoCredito'
					,EstadoCredito =
					 Case CRE.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END			
					--,FechaConstitGarantRRPP = ISNULL(left(cast(C.dFecConsGar as date),10),'') 
					--,B.cCodGarCli
					--,O.cCodOficin
					,Oficina = O.cDesOficin							
					--,ZON.nCodZona
					,Zona = ZON.cDesZona			
					--Datos del Cliente			
					,CLI.cCodCliente AS 'CodigoCliente'		
					,CLIM.cNomCliente AS 'NombreCliente'
					,CRE.cCodCtaCre AS 'CodigoCredito'
					,CLI.cCodLinCre
					,CRE.cCodUsuAna AS 'CodAsesorActual'
					,SP.cNomPerson AS 'NombreAsesorActual'			
				FROM [KPYMCRECONVEN] CRE (NOLOCK)		
					INNER JOIN [GENMCRECLI] CLI 
						ON CLI.cCodCtaCre = CRE.cCodCtaCre
					INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
						ON CLIM.cCodCliente = CLI.cCodCliente
					INNER JOIN [KPYTSUBTIPCRE] STC
						ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
						AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
					INNER JOIN KPYTEstCreCon EC 
						ON EC.cEstCreCon = CRE.cEstCreCon
					INNER JOIN [GENTOficinas] O 
						ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
					INNER JOIN [Gentofizonas] GOZ
						ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
					INNER JOIN [GentZonas] ZON
						ON ZON.nCodZona = GOZ.nCodZona	
					inner JOIN [sipmpersonal] SP 
						ON SP.cCodPerson = CRE.cCodUsuAna	
					--condicion credito 
					 INNER JOIN [KPYTConCredit] D
						ON D.cCondicCon = CLI.cCondicCon			 
					inner join KPYTModCredit M
						on CRE.cCodModCre = M.cCodModCre
			
					/*
					inner join KPYMLinFinCre L
						on L.cCodTipRec	= CRE.cCodTipRec and L.cCodRecurs = CRE.cCodRecurs
					*/						
				WHERE --CRE.cEstCreCon = 'F' and -- in ('F','H','I','G')					
					 ((CRE.cCodTipCre = '02' 
						  and STC.cDesSubCre in ('EMPRESARIAL','AGROPECUARIO','CREDIVIP EMPRESA') 
						  and STC.lEstado = '1') 
							or
						 (CRE.cCodTipCre = '13' 
						 and STC.cDesSubCre in ('EMPRESARIAL','AGROPECUARIO','CREDIVIP EMPRESA') 
						 and STC.lEstado = '1'))			
					and left(cast(CRE.dFecDesCre as date),10) >= '2015-07-24'
					and left(cast(CRE.dFecDesCre as date),10) <= '2015-07-31'			
			
		) as tmp

		-- empresarial, agropecuario, credivip ,
		-- a partir del 24 de Julio hasta el 31 de Julio del 2015.			

		/*
		en modalidad principal, cuyos plazos de créditos sean máximo para 36 meses 
		( incluido el periodo de gracia ) y en el caso de libre amortización , 
		paralelos y por campaña el plazo menor a 01 año , 
		*/

		Select * from #tab01
		Where cCodModCre = '01' and FormaPagoDias <= 1080



		/*
		Select * from [KPYTSUBTIPCRE] STC
		Where STC.lEstado = '1' and STC.cCodTipCre in ('02','13')

		 
		SELECT cCodTipRec,cCodRecurs,cCodModCre ,*
		FROM KPYMCRECONVEN 
		WHERE cCodCtaCre = '107002101008854894' 
 
 
		SELECT * FROM KPYTModCredit
		

		Select cCodTipRec,cCodRecurs,* from KPYMLinFinCre where cDesLinFin like '%cofide%'
		Select cCodTipRec,cCodRecurs,* from KPYHLinFinCre where cDesLinFin like '%cofide%'
		Select * from KPYDRecurso

		Select cCodTipRec,* from KPYTTipRecurs
		
		*/
		
		
		
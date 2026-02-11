
	/*
		NUMERO DE CREDITOS DESEMBOLSADOS A TRAVES DEL CREDICASA HABITACIONAL, 
		DE LAS AGENCIAS DETALLADAS EN EL ARCHIVO ADJUNTO.

		El promedio del Monto Desembolsado.
		De los tres últimos meses. 

		Agencia	Número de créditos desembolsados	Promedio 	
		 	 
	*/
	
	SET LANGUAGE spanish;
		--Tipo cambio a junio 2015
	DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
		set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-11-01'				
				)

	Select * into #tab01 from (

	Select 		
			/*
			ROW_NUMBER() 
			OVER(PARTITION BY CRE.cCodUsuAna
					ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 		
			*/			
			--Datos del credito			
			CRE.cCodCtaCre AS 'CodigoCredito'
			,CLI.cCodLinCre			
			,STC.cDesTipCre AS 'TipoCredito'
			,STC.cDesSubTip AS 'SubTipoCredito'			 
			,STC.cDesProCre AS 'ProductoCrediticio' 			 
			,STC.cDesSubcRE AS 'SubProductoCrediticio' 										
			,CRE.nMonCapDes as 'MontoDesembolso' 
			,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'SaldoCapital'
			,case cre.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'
			,TipoCambio = @nTipCambio
			,MontoDesembolsoenSoles = 
				case cre.cCodTipMon
				WHEN '1' THEN CRE.nMonCapDes
				WHEN '2' THEN @nTipCambio * CRE.nMonCapDes
				END					
			,SaldoCapitalenSoles = 
				case cre.cCodTipMon
				WHEN '1' THEN (CRE.nMonCapDes - CRE.nMonCapPag)
				WHEN '2' THEN @nTipCambio * (CRE.nMonCapDes - CRE.nMonCapPag)
				END								
			,TEM=CRE.nTasintCom	
			,NumeroCuotas=CRE.nNumCuoApr
			,EstadoCredito =
			 Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END														 
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
			,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
			,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
			--,CRE.cEstCreCon
			--,EC.cDescriEst AS 'EstadoCredito'			
			,CRE.cCodOficin
			,Oficina = O.cDesOficin										
												
	FROM [KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = CRE.cCodCtaCre	
			INNER JOIN [KPYTSUBTIPCRE] STC
				ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
				AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			INNER JOIN KPYTEstCreCon EC 
				ON EC.cEstCreCon = CRE.cEstCreCon
			INNER JOIN [GENTOficinas] O 
				ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'	
			--condicion credito 
			 INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon			 
					 								

		WHERE CRE.cEstCreCon in ('F','G')				
				and cDesSubCre like '%credi%casa%habi%'
				and left(cast(CRE.dFecDesCre as date),10) >= '2015-08-01'
				and CRE.cCodOficin in ('050','016','022','056','082','023','058','004','014','075','013','021'
				,'002','035','078','007','064','012','040','076','017','018','054','009','067','077','010','071'
				,'052','003','005','025','061','011','044','036','008','048','084','006','066','024'
				)
	
		) as tmp 	 				 	 		 	 	 	 	 	  	 	 	   	 	  	 					 	 			 
		 	
		Select * From #tab01

		Select CodigoCredito, count(CodigoCredito) From #tab01
		Group By  CodigoCredito
		Having count(CodigoCredito) > 1

		Select Oficina, CantidadCreditos = count(CodigoCredito)
		,PromedioMontoDesembolso = avg(MontoDesembolsoenSoles)
		From #tab01
		Group By Oficina
		Order By Oficina

		-- Drop table #tab01	
					 
		/*
				Select * from GENTOficinas
				Where cDesOficin like '%santa%an%'	
				
				Select * from KPYTSUBTIPCRE
				Where lEstado = '1' and cDesSubCre like '%credi%casa%habi%'

				Select * from KPYTEstCreCon
				Select * from [KPYTConCredit]
		*/

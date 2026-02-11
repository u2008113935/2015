

		SELECT 
			--Datos del Cliente	
			CLIM.cNroDocIde as 'NroDocumento'
			,CLI.cCodCliente AS 'CodigoCliente'
			,CLIM.cNomCliente AS 'NombreCliente'
			--DATOS DEL CREDITO
			,CRE.cCodCtaCre AS 'CodigoCredito'
			,CRE.nMonCapDes as 'MontoDesembolso' 
			,CRE.nTasIntCom as 'TasaInteres'
			,CRE.nCosEfeAct as 'TasaCostoEfectivoAnual'
			,case CRE.cCodTipMon 
			 When '1' then 'SOLES'
			 WHEN '2' THEN 'DOLARES'
			 END as 'Moneda'
			,CRE.nMonintPro as 'MontoInteresAprobado'
			,CRE.nMonintFec as 'MontoInteresAlaFecha'
			,CRE.nMonintPag as 'MontoInteresPagado'
			,EC.cDescriEst AS 'EstadoCredito'
			,left(cast(CRE.dFecDesCre as date),10) as 'FecDesembCredito'
			,isnull(left(cast(CRE.dFecCulCre as date),10),'') as 'FecCulminacionCredito'
			,CRE.nNumCuoApr as 'NroCuotasAprobadas'
			,CRE.cTipPeriodo
			,case CRE.cCodPlazo				
			 when '1' then 'CORTO PLAZO'
			 when '2' then 'LARGO PLAZO'
			 END as 'Plazo'
			 ,CRE.cCodTipCre
			 ,STC.cDesTipCre AS 'TipoCredito'
			 ,STC.cDesSubTip AS 'SubTipoCredito'
			 ,CRE.cCodProduc
			 ,STC.cDesProCre AS 'ProductoCrediticio' 
			 ,CRE.cCodSubPro	
			 ,STC.cDesSubcRE AS 'SubProductoCrediticio'
			 ,CLI.cCondicCon, D.cDesConCre 
			 ,O.cDesOficin AS 'NombreAgencia'
			,CRE.cCodOficin
			,zo.cNomZona as 'DetalleZona', zon.cDesZona as 'Zona'
			,CRE.cCodUsuAna AS 'CodigoAanalista'--COD ANALISTA
			,SP.cNomPerson AS 'NombreAnalista'--NOMBRE ANALISTA  
			---NOVACION
			,N.cCodCreVig, N.nCodSalOpe, N.cCodCreCan, N.cCodUsuReg
			,N.dFecRegVin, N.lEstVinNov

		FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] CLI 
					ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
					ON CLIM.cCodCliente = CLI.cCodCliente
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTEstCreCon] EC 
					ON EC.cEstCreCon = CRE.cEstCreCon
			inner JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[sipmpersonal] SP 
					ON SP.cCodPerson = CRE.cCodUsuAna
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENTOficinas] O 
					ON O.cCodOficin = CRE.cCodOficin
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTSUBTIPCRE] STC
					ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
					AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GentZona] zo
				ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
				and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[Gentofizonas] goz
				ON goz.cCodOficin = O.cCodOficin
			INNER JOIN  [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GentZonas] zon
				ON goz.nCodZona = zon.nCodZona	
			INNER JOIN [KPYTConCredit] D
				ON D.cCondicCon = CLI.cCondicCon
			left JOIN KPYDCreCanNov N
			on N.cCodCreVig =  CRE.cCodCtaCre
		
		WHERE   --CLI.cCodCliente  COLLATE SQL_Latin1_General_CP1_CI_AS	
				--in (select cCodCliente from PROSPECTOV02 )
				--AND CRE.cEstCreCon = 'F'
				CLIM.cNomCliente    like '%RICRA%VILCHEZ%MARGARITA%TEODORA' 
				or CLIM.cNomCliente like '%ALARCON%ALANIA%CELINA%' 			
		ORDER BY CLI.cCodCliente

		
		--SELECT TOP 1 *  FROM KPYDCreCanNov
		/*
		select *
		from kpyamcreconven
		where cCodCtaCre = '107048101001735619'
		*/
				
		select * from KPYTEstCreCon where cEstCreCon in ('H','F','E')

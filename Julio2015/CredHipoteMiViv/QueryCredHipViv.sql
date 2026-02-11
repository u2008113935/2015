	/*
	POR FAVOR SE REQUIERE LA RELACIÓN DE CRÉDITOS HIPOTECARIOS MI VIVIENDA Y MI CONSTRUCCIÓN
	DESEMBOLSADOS DESDE 01.06.2014 HASTA EL 30.06.2015 CONSIGNANDO FECHA DE DESEMBOLSO, 
	NOMBRE DEL CLEINTE, MONTO DE DESEMBOLSO, AGENCIA, ASESOR DE NEGOCIOS, PLAZO. 
	*/

	Select 		
			 --Datos del Cliente	
			CLI.cCodCliente AS 'CodigoCliente'	
			,CLIM.cNomCliente AS 'NombreCliente'	
			--Datos del credito
			,CRE.cCodCtaCre AS 'CodigoCredito'	
			,CRE.nMonCapDes as 'MontoDesembolso' 
			,case cre.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'
			,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'Saldo'	
			,TEM=CRE.nTasintCom	
			,NumeroCuotas=CRE.nNumCuoApr	
			,CRE.cCodTipCre
			 ,STC.cDesTipCre AS 'TipoCredito'
			 ,STC.cDesSubTip AS 'SubTipoCredito'
			 ,CRE.cCodProduc
			 ,STC.cDesProCre AS 'ProductoCrediticio' 
			 ,CRE.cCodSubPro	
			 ,STC.cDesSubcRE AS 'SubProductoCrediticio' 			
			,CRE.cEstCreCon
			,EC.cDescriEst AS 'EstadoCredito'
			,Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END cDesConCre																									
			,O.cCodOficin, O.cDesOficin			
			,CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'				
			,ZON.nCodZona, ZON.cDesZona	
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

		WHERE CRE.cEstCreCon in ('F','H','I')					
			and (CRE.cCodTipCre = '04' and STC.cDesSubcRE in ('MIVIVIENDA','MICONSTRUCCION'))			
			AND left(cast(CRE.dFecDesCre as date),10) >='2014-06-01'
			AND left(cast(CRE.dFecDesCre as date),10) <='2015-06-30'			
		ORDER BY cEstCreCon 		
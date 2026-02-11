	/*
	CREDITOS UNICUOTA

	*/
	
	SET LANGUAGE spanish;

	DECLARE @nTipCambio MONEY,	@dFecTipCam CHAR(7)	
	SET @nTipCambio =
	   (SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCamFij
		FROM GENTTipCambio
		WHERE left(cast(dFecTipCam as date),7) = '2015-06' --left(cast(GETDATE() as date),7)			
		Group by left(cast(dFecTipCam as date),7),nTipCamFij )
	--SELECT @nTipCambio

	SET @dFecTipCam =
		(SELECT left(cast(dFecTipCam as date),7)
			--,nTipCambio = nTipCamFij
		FROM GENTTipCambio
		WHERE left(cast(dFecTipCam as date),7) = '2015-06' --left(cast(GETDATE() as date),7)			
		Group by left(cast(dFecTipCam as date),7),nTipCamFij )
	--SELECT @dFecTipCam			

	Select 		
			 ROW_NUMBER() 
			OVER(PARTITION BY year(CRE.DFECDESCRE)
					ORDER BY MONTH (CRE.DFECDESCRE) ) AS Secuencia 
			,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE),NombreMes =DATENAME(month, CRE.DFECDESCRE)
			--,CRE.cCodTipCre
			 ,STC.cDesTipCre AS 'TipoCredito'
			 ,STC.cDesSubTip AS 'SubTipoCredito'
			 --,CRE.cCodProduc
			 ,STC.cDesProCre AS 'ProductoCrediticio' 
			 --,CRE.cCodSubPro	
			 ,STC.cDesSubcRE AS 'SubProductoCrediticio' 			
			--Datos del Cliente
			,CLI.cCodCliente AS 'CodigoCliente'			
			,CLIM.cNomCliente AS 'NombreCliente'	
			--Datos del credito			
			,CRE.cCodCtaCre AS 'CodigoCredito'						
			,CRE.nMonCapDes as 'MontoDesembolso' 
			,case cre.cCodTipMon
			when '1' then 'SOLES'
			when '2' then 'DOLARES'
			end AS 'Moneda'
			,FechaTipoCambio = @dFecTipCam
			,TipoCambio = @nTipCambio			
			,MontoDesembolsadoSoles =
			case cre.cCodTipMon
			when '1' then CRE.nMonCapDes --'SOLES'
			when '2' then CRE.nMonCapDes * @nTipCambio --'DOLARES'
			end 
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'				
			,TEM=CRE.nTasintCom	
			,NumeroCuotas=CRE.nNumCuoApr				
			,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'Saldo'
			,SaldoSoles =
			case cre.cCodTipMon
			when '1' then (CRE.nMonCapDes - CRE.nMonCapPag) --'SOLES'
			when '2' then (CRE.nMonCapDes - CRE.nMonCapPag) * @nTipCambio --'DOLARES'
			end 
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

		WHERE CRE.cEstCreCon in ('F','H')					
			and CRE.nNumCuoApr = 1
			--and (CRE.cCodTipCre = '04' and STC.cDesSubcRE in ('MIVIVIENDA','MICONSTRUCCION'))			
			--AND left(cast(CRE.dFecDesCre as date),10) >='2014-06-01'
			--AND left(cast(CRE.dFecDesCre as date),10) <='2015-06-30'			
	
		
		/*
		SELECT * FROM [KPYTSUBTIPCRE] STC
		WHERE STC.lEstado = '1'  AND cDesSubCre LIKE '%UNI%' 
		*/
				
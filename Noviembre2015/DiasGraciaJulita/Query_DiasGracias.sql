

	SET LANGUAGE spanish;
	
	Select 		
			ROW_NUMBER() 
			OVER(PARTITION BY MONTH (CRE.DFECDESCRE)
					ORDER BY left(cast(CRE.dFecDesCre as date),10) ) AS Secuencia 
			,Anio= year(CRE.DFECDESCRE), Mes = MONTH (CRE.DFECDESCRE)
			,NombreMes =DATENAME(month, CRE.DFECDESCRE)	
			-------------------------------------------------------------
			,CodigoCliente = CLI.cCodCliente 
			,CLIM.cNomCliente
			--Datos del credito
			,CodigoCredito = CRE.cCodCtaCre			
			,CRE.cCodTipCre
			,TipoCredito=STC.cDesTipCre
			,SubTipoCredito=STC.cDesSubTip 
			,CRE.cCodProduc
			,ProductoCrediticio=STC.cDesProCre 
			,CRE.cCodSubPro	
			,SubProductoCrediticio=STC.cDesSubcRE 						
			,MontoDesemb= CRE.nMonCapDes 		 			 
			,Moneda =
			 case cre.cCodTipMon
			 when '1' then  'SOLES'
			 when '2' then  'DOLARES'
			 end 			
			,TEM= CRE.nTasintCom
			,TipoTasa = CRE.cTipTasCom
			,DetalleTipoTasa =
				Case CRE.cTipTasCom
				When 'TM' THEN 'ESPECIAL MAYOR'
				When 'TT' THEN 'DE TABLA'
				When 'TM' THEN 'DE ADMINISTRAC'
				When 'TJ' THEN 'DE JEFATURA'
				When 'TG' THEN 'DE GERENCIA'
				When 'ES' THEN 'GER OPE/FINAN'
				ELSE CRE.cTipTasCom END			
			,FechaDesembolsoCredito = left(cast(CRE.dFecDesCre as date),10)
			,FechaCancelacionCredito = isnull(left(cast(CRE.dFecCulCre as date),10),'') 	
			,PlazoInicial = CRE.nNumDiaApr
			,CuotasAprobadas = CRE.nNumCuoApr
			,DiasGracia = CRE.nNumDiaGra
			,FormaPago= ((CRE.nNumDiaApr * CRE.nNumCuoApr) + CRE.nNumDiaGra)			
			,PlazoHastaLaCanc=
				ISNULL(
				DATEDIFF(day,left(cast(CRE.dFecDesCre as date),10),left(cast(CRE.dFecCulCre as date),10)),'')
			--,DescripcionMotivoSalidaOperacion=ISNULL(M.cDesCotSalOpe,'')
			,SaldoSoles=
			 case cre.cCodTipMon
			 when '1' then (CRE.nMonCapDes - CRE.nMonCapPag)  --'SOLES'
			 when '2' then (CRE.nMonCapDes - CRE.nMonCapPag)  --'DOLARES'
			 end 		
			,SituacionCredito =
			 Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END
			,EC.cDescriEst AS 'EstadoCredito'			
			,O.cDesOficin, Zona = ZON.cDesZona	
		
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
						 				
										
		WHERE  	CRE.cCodCtaCre in (
			'107009101005980832',
'107030101000115986',
'107045101001013013',
'107045101001013619',
'107045101001017477',
'107045101001021470',
'107044101001277466',
'107015101001979865'
		)			
		

	/*
		RELACION DE CREDITOS DE ASESORES CESADOS

	Castagnetto Lemos, Fiorella                                       ICASTAGNETTO
	Castañeda Berrospi, Wilmer Alison                              WCASTANEDA
	Caysahuana Amarillo, Vicente                                     VCAYSAHUANA
	Chamorro Victorio, Hubert Iván                                   ICHAMORRO
	Galindo Retamozo, Yovana                                         YGALINDO
	Guzman Maldonado, Flor de Maria                               FGUZMAN
	Marcos Orellana, C nthia Victoria                                CMARCOS
	Ñahui Crispin, Danny David                                        DNAHUI
	Ñique Apolinario, Jean Carlos                                     CNIQUE
	Poma Yapias, Nilton Daygoro                                      NPOMAY
	Ramirez Perez, Criss Wendy                                      SRAMIREZ
	Ramos Galvan, Jhon Alexander                                  HRAMOS
	Sipiran Suarez, Maruxa Geraldine                                MSIPIRAN
	*/

	SET LANGUAGE spanish;

	Select 		
			ROW_NUMBER() 
			OVER(PARTITION BY CRE.cCodUsuAna--year(CRE.DFECDESCRE)
					ORDER BY year(CRE.DFECDESCRE) ) AS Secuencia
			,CRE.cCodUsuAna AS 'CodAsesorActual'
			,SP.cNomPerson AS 'NombreAsesorActual'	
			--,SOLI.cCodUsuAna AS 'CodAnalistaOrigen'
			--,SP1.cNomPerson AS 'NombreAnalistaOrigen'--NOMBRE ANALISTA 	 			
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
			,left(cast(CRE.dFecDesCre as date),10) as 'FechaDesembolsoCredito'				
			,TEM=CRE.nTasintCom	
			,NumeroCuotas=CRE.nNumCuoApr				
			,(CRE.nMonCapDes - CRE.nMonCapPag) AS 'Saldo'
			,CRE.cEstCreCon
			,EC.cDescriEst AS 'EstadoCredito'
			,Case CRE.cEstCreCon
			 when 'G' then 'CANCELADO' 
			 ELSE D.cDesConCre
			 END cDesConCre																									
			--,O.cCodOficin
			,O.cDesOficin
			--,ZON.nCodZona
			,ZON.cDesZona														
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

			--ANALISTA ORIGEN
			/*
			 INNER JOIN [kpymsolicitud] SOLI	
				ON SOLI.cCodSolCre = CRE.cCodSolCre
			 Inner JOIN [sipmpersonal] SP1 
					ON SP1.cCodPerson = SOLI.cCodUsuAna
			*/
		WHERE 
			CRE.cEstCreCon IN ('G','F','H','I')			
			AND CRE.cCodUsuAna in ('CMARCO','CNIQUE','DNAHUI','FGUZMA','HRAMOS','ICASTA','ICHAMO','MSIPIR','NPOMAY'
			,'SRAMIR','VCAYSA','WCASTA','YGALIN')												

			/*
			Select * from [sipmpersonal] SP
			where SP.cCodPerson in ('ICASTAGNETTO','WCASTANEDA','VCAYSAHUANA','ICHAMORRO','YGALINDO','FGUZMAN','CMARCOS'
			,'DNAHUI','CNIQUE','NPOMAY','SRAMIREZ','HRAMOS','MSIPIRAN')		
			
			Select * from [kpymsolicitud] SOLI
			where SOLI.cCodUsuAna in ('ICASTAGNETTO','WCASTANEDA','VCAYSAHUANA','ICHAMORRO','YGALINDO','FGUZMAN','CMARCOS'
			,'DNAHUI','CNIQUE','NPOMAY','SRAMIREZ','HRAMOS','MSIPIRAN')
			
			Select * from [sipmpersonal] SP where cNomPerson like '%Sipiran%Suarez%Maruxa%Geraldine%'			
                                                   
				
				CASTAGNETTO/LEMOS,FIORELLA - ICASTA                           ICASTAGNETTO
				CASTAÑEDA/BERROSPI,WILMER ALISON - WCASTA                       WCASTANEDA
				Caysahuana Amarillo, Vicente - VCAYSA                           VCAYSAHUANA
				Chamorro Victorio, Hubert Iván - ICHAMO                         ICHAMORRO
				Galindo Retamozo, Yovana - YGALIN                                 YGALINDO
				Guzman Maldonado, Flor de Maria - FGUZMA                          FGUZMAN
				Marcos Orellana, C nthia Victoria - CMARCO                       CMARCOS
				Ñahui Crispin, Danny David - DNAHUI                              DNAHUI
				Ñique Apolinario, Jean Carlos - CNIQUE                          CNIQUE
				Poma Yapias, Nilton Daygoro - NPOMAY                           NPOMAY
				Ramirez Perez, Criss Wendy - SRAMIR                          SRAMIREZ
				Ramos Galvan, Jhon Alexander - HRAMOS                         HRAMOS
				Sipiran Suarez, Maruxa Geraldine - MSIPIR                    MSIPIRAN
				*/	
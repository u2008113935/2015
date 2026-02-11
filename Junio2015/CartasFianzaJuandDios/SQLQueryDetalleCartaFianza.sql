		/*
		EXEC KPY_REPCARFIA_SP  
				@x_dFecIni = '2005-04-01',  
				@x_dFecFin = '2005-10-30',  
				@x_cOpcion = '2'
		*/

	
		-- CMACHYOCLI_MANIANA_MANIANA
			--=========================================================================
			-- CARTAS FIANZAS VIGENTES A LA FECHA 
			--=========================================================================
	--SELECT * into #tmpv01 FROM  (
			SELECT 
				ISNULL(EXPE.CCODEXPCLI, '') AS CCODEXPCLI, 
				FIA.CCODCTACRE, CNROCARFIA, GEN.CCODCLIENTE AS CCODCLISOL
				, CLITIT.CNOMCLIENTE AS CNOMCLISOL,
				FIA.CCODCLIENTE AS CCODCLIFAV, CLIFAV.CNOMCLIENTE AS CNOMCLIFAV, 
				MON.CDESCORTA AS CTIPMONFIA, MON.CDESTIPMON, NVALCARFIA
				, DFECINIFIA = left(cast(FIA.DFECINIFIA as date),10)
				, DFECCANFIA = left(cast(FIA.DFECCANFIA as date),10), 
				FIA.NPLAOTOFIA, MODCF.CDESMODFIA,
				ISNULL(TIPOGAR.CCODGARCLI, '') AS CCODGARCLI
				--, ISNULL(TIPOGAR.CCODCUENTA, '') AS CCODCUENTA
				,ISNULL(TIPOGAR.CDESTIPGAR, '') AS CDESTIPGAR, 
				ISNULL(TIPOGAR.CTIPMONGAR, '') AS CTIPMONGAR
				, ISNULL(TIPOGAR.NMONGARORI, 0.00) AS NMONGARORI
				--, S.cCodOficin
				--,O.cDesOficin,ZON.nCodZona, ZON.cDesZona
				--,CLITIT.cCodCiiu
				--,B.ccodciiu, B.cdesactivi
				--,CLITIT.cCodCiuDet
				--,C.ccodciudet ,c.cdesactivi
			FROM KPYMCRECARFIA FIA (NOLOCK)
				inner JOIN GENMCRECLI GEN (NOLOCK) 
					ON(FIA.CCODCTACRE = GEN.CCODCTACRE)
				LEFT JOIN KPYTMODCARFIA MODCF (NOLOCK) 
					ON(FIA.cCodModFia = MODCF.cCodModFia)
				inner JOIN CMACHYOCLI_MANIANA.DBO.CLIMClienteS CLITIT (NOLOCK) 						
					ON(CLITIT.CCODCLIENTE = GEN.CCODCLIENTE)
				LEFT JOIN CMACHYOCLI_MANIANA.DBO.CLIDExpediente EXPE (NOLOCK) 
					ON(EXPE.CCODCLIENT = CLITIT.CCODCLIENTE AND EXPE.CTIPEXPCLI = 'K' AND EXPE.LCONESTADO = 1) 
				inner JOIN CMACHYOCLI_MANIANA.DBO.CLIMClienteS CLIFAV (NOLOCK) 
					ON(CLIFAV.CCODCLIENTE = FIA.CCODCLIENTE)
				LEFT JOIN 
					(SELECT CLIMGAR.CCODGARCLI, CLIMGAR.CCODCUENTA, GARLIN.CCODLINCRE, TIPGAR.CDESTIPGAR, MON.CDESCORTA AS CTIPMONGAR, NMONGARORI
					 FROM KPYDGARLINCRE GARLIN (NOLOCK) 
						INNER JOIN CMACHYOCLI_MANIANA.DBO.CLIMGarCliente CLIMGAR (NOLOCK) 
							ON(CLIMGAR.CCODGARCLI = GARLIN.CCODGARCLI AND CLIMGAR.CCODCLIENTE = GARLIN.CCODCLIENTE
								AND CLIMGAR.CCODESTGAR = 'A' AND GARLIN.CCODESTGAR = 'A')
						LEFT JOIN GENDGARANTIA TIPGAR (NOLOCK)
							ON(TIPGAR.CCODgarant = CLIMGAR.CCODTIPGAR)
						LEFT JOIN GENTMONEDA MON (NOLOCK) 
							ON(MON.CCODTIPMON = CLIMGAR.CCODTIPMON)
					) AS TIPOGAR
					ON(TIPOGAR.CCODLINCRE = GEN.CCODLINCRE )
				LEFT JOIN GENTMONEDA MON (NOLOCK) 
					ON(MON.CCODTIPMON  = FIA.CCODTIPMON)
				--left JOIN KPYMSolicitud S
					--ON FIA.cCodSolCre = S.cCodSolCre 
				/*
				INNER JOIN GENTOficinas O
					on O.cCodOficin = S.cCodOficin
				INNER JOIN [Gentofizonas] GOZ
					ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [GentZonas] ZON
					ON ZON.nCodZona = GOZ.nCodZona
					*/
				--inner join GENTCodCiiu B
					--on CLITIT.cCodCiiu = B.ccodciiu	
				--inner join GENDCodCiiu C
					--on C.ccodciudet = CLITIT.cCodCiuDet					

			WHERE CESTCARFIA = 'K'
			ORDER BY FIA.CCODTIPMON, FIA.CNROCARFIA
		 --) as tmp99

		 -- (1,106 row(s) affected)
		/*
		select * from  #tmpv01
		ORDER BY CNROCARFIA
		*/

		-- Drop table #tmpv01

				/*
				select top 1 * from KPYMSolicitud


				select top 10 --* 
					A.cCodCIIUSol, A.cCodSolCre
					,B.ccodciiu, B.cdesactivi
				from KPYMSolicitud A
					inner join GENTCodCiiu B
						on A.cCodCIIUSol = B.ccodciiu
					inner join GENDCodCiiu C
						on C.ccodciiu = B.ccodciiu

				
				---grupo
				select *
				from  GENTCodCiiu
				--where ccodciiu = '6022'
				--detalle
				select *
				from  GENDCodCiiu
				where ccodciiu = '6022'

				select cCodCiiu, cCodCiuDet,*
				from  CMACHYOCLI_MANIANA.DBO.CLIMClienteS CLITIT
				where cnrodocide='42652624'
				*/
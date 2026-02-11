		/*
			Requeriminto de información para Equilibrium:
				Se requiere la data segun archivo adjunto desde el mes de junio2014 
				hasta el mes de junio del 2015, de manera mensual.
		*/
			
		/*
			SELECT TOP 10 
				B.CCODCLIENTE, A.ccodctacre, A.dFecDesCre, A.nmonsalcap, A.cCodClaUri
			INTO #DATOS
			FROM KPYHSALCARTOT A
				   INNER JOIN GENMCRECLI B
						 ON A.CCODCTACRE = B.CCODCTACRE
			WHERE DFECPROCES = '20140731'
				   AND CESTCRECON IN ('F','H')

			SELECT A.*, B.CCODSBS FROM #DATOS A
				   INNER JOIN CMACHYOCLI.DBO.CLIMCLIENTES B
						 ON A.CCODCLIENTE = B.CCODCLIENTE

			DROP TABLE #DATOS		

				Código del Cliente (en la Caja),Código SBS,	Código del Crédito,
				Fecha de Desembolso,Mora Máxima del Crédito en el mes (Dias de Atraso),
				Saldo Capital,Clasificación del cliente RCC

		*/
		
		/*

		Select  A.cCodClaUri --* 
		FROM KPYHSALCARTOT A		
		WHERE DFECPROCES = '20140731' --AND CESTCRECON IN ('F','H')
		group by A.cCodClaUri

		Select * from 

		Select * from [KPYTConCredit] D
		CESTCRECON

		Select * from KPYTEstCreCon

		*/


		-- Drop table #tab01
		Select * into #tab01 from (
			SELECT  
				CodigoCliente = B.CCODCLIENTE
				,CodigoSBS = C.cCodSbs
				,CodigoCredito = A.ccodctacre
				,FechaDesembolso = left(cast(A.dFecDesCre as date),10)
				,MoraMax = 
					Case when A.nDiaAtrCre <= 0 then  0
					else A.nDiaAtrCre end
				,SaldoCapitalenSoles = 
					Case A.ccodtipmon 
					when '1' then A.nmonsalcap
					when '2' then A.nmonsalcap * A.nTipCamFij
					End
				,ClasifRCC = 
					Case A.cCodClaUri			
					when '00' then 'NORMAL' 
					when '01' then 'CPP'
					when '02' then 'DEFICIENTE'
					when '03' then 'DUDOSO' 
					when '04' then 'PERDIDA'
					ELSE 'NO REGISTRA'
					END
			FROM KPYHSALCARTOT A
				INNER JOIN GENMCRECLI B
					ON A.CCODCTACRE = B.CCODCTACRE
				inner join [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C 
					ON C.cCodCliente = B.cCodCliente 
			WHERE DFECPROCES = '20150630'
				   AND CESTCRECON IN ('F','H')
				   ) as tmp

			
			Select sum(SaldoCapitalenSoles) from #tab01

			Select * from #tab01
			Order By CodigoCliente
			--Order By MoraMax asc
			--where CodigoCredito = '107035101002875952'	
			-- 107035101002875952 148

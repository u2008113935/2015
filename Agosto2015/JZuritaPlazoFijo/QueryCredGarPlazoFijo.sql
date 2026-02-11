
	/*
	LISTA DE CREDITOS CON GARANTIA DE PLAZO FIJO, EN RANGOS DE MONTOS.

		Se requiere la data de los créditos con garantía de plazo fijo bajo 
		el siguiente rango. 

		N° 	Montos menores a S/. 20,000	Desde S/. 20,001 hasta S/. 50,000	
			Desde S/. 50,001 hasta S/. 100,000	Mayores a S/. 100.001	
			Total
	*/
		       	 
			-- Drop table #tab01
			SET LANGUAGE spanish;
			--Tipo cambio a junio 2015
			DECLARE @nTipCambio MONEY,	@dFecTipCam DATE					
			set @nTipCambio = (
			SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
				nTipCambio = nTipCamFij
			FROM GENTTipCambio
			WHERE left(cast(dFecTipCam as date),10) ='2015-08-01' 
					) 

			Select * into #tab01 from (
				Select 
						/*
						ROW_NUMBER() 
						OVER(PARTITION BY year(C.DFECDESCRE)
							ORDER BY MONTH (C.DFECDESCRE) ) AS Secuencia, 
						*/
					Anio= year(C.DFECDESCRE), Mes = MONTH (C.DFECDESCRE)
					,NombreMes =DATENAME(month, C.DFECDESCRE)
					,C.cCodCtaCre, cCodLinCre01 = B.cCodLinCre , cCodLinCre02 = G.cCodLinCre 
					,G.cCodCliente
					,C.cCodTipCre
					 ,S.cDesTipCre AS 'TipoCredito'
					 ,S.cDesSubTip AS 'SubTipoCredito'
					 ,C.cCodProduc
					 ,S.cDesProCre AS 'ProductoCrediticio' 
					 ,C.cCodSubPro	
					 ,S.cDesSubcRE AS 'SubProductoCrediticio' 							
					--Datos del credito			
					,C.nMonCapDes as 'MontoDesembolso' 
					,(C.nMonCapDes - C.nMonCapPag) AS 'SaldoCapital'
					,case C.cCodTipMon
					when '1' then 'SOLES'
					when '2' then 'DOLARES'
					end AS 'Moneda'
					,MontoDesembolsadoenSoles = 
						case C.cCodTipMon
						WHEN '1' THEN C.nMonCapDes
						WHEN '2' THEN @nTipCambio * C.nMonCapDes
						END					
					,SaldoCapitalenSoles = 
						case C.cCodTipMon
						WHEN '1' THEN (C.nMonCapDes - C.nMonCapPag)
						WHEN '2' THEN @nTipCambio * (C.nMonCapDes - C.nMonCapPag)
						END									
					,left(cast(C.dFecDesCre as date),10) as 'FechaDesembolsoCredito'				
					,TEM=C.nTasintCom	
					,NumeroCuotas=C.nNumCuoApr										 
					,EstadoCredito =
					 Case C.cEstCreCon
					 when 'G' then 'CANCELADO' 
					 ELSE D.cDesConCre
					 END
					,B.cCodTipGar
				FROM [KPYMCRECONVEN] C (NOLOCK)
					INNER JOIN [GENMCRECLI] G 
						ON G.cCodCtaCre = C.cCodCtaCre	
					INNER JOIN KPYDGarLinCre B
						on B.cCodLinCre = G.cCodLinCre 
					INNER JOIN [KPYTSUBTIPCRE] S
						ON C.cCodTipCre = S.cCodTipCre AND C.cCodProduc = S.cCodProduc 
							AND C.cCodSubPro = S.cCodSubPro and S.lEstado = '1'
					INNER JOIN [KPYTConCredit] D
						ON D.cCondicCon = G.cCondicCon			 
				Where B.cCodTipGar = 'RPDPF' AND B.cCodEstGar = 'A'
					and left(cast(C.dFecDesCre as date),10) > '2013-01-01'
					AND (C.cCodTipCre = '03' and S.cDesSubcRE = 'PLAZO FIJO')
					) as tmp

			-- (36,339 row(s) affected)

				Select cCodGarCli,* from [GENMCRECLI] G where G.cCodCtaCre = '107024101002205343'
				and G.cCodLinCre = '0240023124'

				Select * from KPYDGarLinCre B Where B.cCodLinCre = '0240023124'


			/*
			N° 	Montos menores a S/. 20,000	Desde S/. 20,001 hasta S/. 50,000	
			Desde S/. 50,001 hasta S/. 100,000	Mayores a S/. 100.001	
			Total
			*/			

				Select cCodCtaCre,cCodCliente,cCodLinCre01, count(cCodCtaCre)  from #tab01
				Group By cCodCtaCre,cCodCliente,cCodLinCre01
				Having count(cCodCtaCre) > 1
				Order by count(cCodCtaCre) desc
				
				Select * from #tab01
				Where cCodCtaCre = '107024101002205343'


			Select * from #tab01
			Where MontoDesembolsadoenSoles <= 20000
			Order By cCodCliente
			 --(35,743 row(s) affected)

			--	N° 	Montos menores a S/. 20,000				
			Select count(distinct cCodCtaCre) from #tab01
			Where MontoDesembolsadoenSoles <= 20000
			
			--Desde S/. 20,001 hasta S/. 50,000	
			Select count(distinct cCodCtaCre) from #tab01
			Where MontoDesembolsadoenSoles >= 20001 
				and MontoDesembolsadoenSoles <=50000 

			--Desde S/. 50,001 hasta S/. 100,000
			Select count(distinct cCodCtaCre) from #tab01
			Where MontoDesembolsadoenSoles >= 50001 
				and MontoDesembolsadoenSoles <=100000

			--Mayores a S/. 100.001	
			Select count(distinct cCodCtaCre) from #tab01
			Where MontoDesembolsadoenSoles >= 100001 				
			
			--Total

			--Select * into #tab02 from (Select top )

			/*
			Select top 1 * from [GENMCRECLI] 
			Select * from KPYDGarLinCre B
			Where cCodTipGar = 'RPDPF' 	AND B.cCodEstGar = 'A'
				and B.cCodLinCre = '0040071334' 


			Select B.cCodTipGar, B.cCodGarCli,left(cast(C.dFecConsGar as date),10), B.*, C.*
			From KPYDGarLinCre B				
				inner join CMACHYOCLI_MANIANA.DBO.CliMGarFisHipCli C
					on C.cCodCliente = B.cCodCliente
						and C.cCodGarCli = B.cCodGarCli 
					and C.dFecConsGar is not NULL
			WHERE  -- B.cCodLinCre = '0210014097' -- @codlincre1
				B.cCodEstGar = 'A'


			
			Select top 1 * from KPYDGarLinCre B
				Select B.* from KPYDGarLinCre B				
				Where cCodTipGar = 'RPDPF' 	AND B.cCodEstGar = 'A'

			Select top 1 * from CMACHYOCLI_MANIANA.DBO.CliMGarFisHipCli C

			Select top 1 * from GENDGARANTIA TIPGAR (NOLOCK)
						ON TIPGAR.CCODgarant = GARLIN.CCODTIPGAR and TIPGAR.lconestado = 1
			
			Select * from GENDGARANTIA GG (NOLOCK)
				--where cdestipgar like '%plazo%' and lconestado = '1'
				Where GG.ccodgarant = 'RPDPF' and lconestado = '1'

			ccodgarant = RPDPF

			Select top 1 * FROM KPYMCRECARFIA FIA (NOLOCK)
			Select top 1 * from GENMCRECLI GEN (NOLOCK) 
						ON (FIA.CCODCTACRE = GEN.CCODCTACRE)	
			Select top 1 * from KPYDGARLINCRE GARLIN (NOLOCK) 
			*/
			
			






 	 	 	 	 	 
 	 	 	 	 	 
 	 	 	 	 	 
 	 	 	 	 	 

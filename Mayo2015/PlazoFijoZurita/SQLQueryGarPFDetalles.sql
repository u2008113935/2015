/*
select cNomCliente, isnull(cNroDocIde, cNroDocTri) as 'Nrodocumento'
from [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C
where --cNomCliente like '%Terrazos%Guerra%Carmen%Heidi%'
	cCodCliente in 
(
'107014385118',
'107014449218',
'107014528511',
'107011820632',
'107014140559',
'107019428067',
'107010799313' )
 order by cNomCliente
 */

	/*
	select top 1 *  from CMACHYOCLI_MANIANA.DBO.CLIMGarCliente A
	select top 1 *  from CMACHYOCLI_MANIANA.DBO.CliMGarTitValCli B
	*/

 	SELECT C.cNomCliente,A.cCodTipGar,A.CCODCLIENTE
	,isnull(cNroDocIde, cNroDocTri) as 'Nrodocumento',B.cCodCuenta
	INTO #detCta --Drop table #detCta
	FROM CMACHYOCLI_MANIANA.DBO.CLIMGarCliente A
		INNER JOIN CMACHYOCLI_MANIANA.DBO.CliMGarTitValCli B
			ON A.CCODCLIENTE = B.CCODCLIENTE
				AND A.CCODGARCLI = B.CCODGARCLI
		INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] C
			ON C.cCodCliente = A.CCODCLIENTE
	WHERE A.CCODCLIENTE --= @x_cCodCliente 
		in (
			'107014385118',
			'107014449218',
			'107014528511',
			'107011820632',
			'107014140559',
			'107019428067',
			'107010799313'
		)
		AND A.cCodEstGar = 'A'
		AND ISNULL(B.ccodcuenta,'') <> '' 
		AND A.cCodIndTipGar = '2' 
	order by A.CCODCLIENTE


SELECT G.cCodCuenta, G.dFecKardex, G.cCodTipOpe, 
		'nmonape' = CASE WHEN G.cCodTipOpe = '0001'
						THEN G.nMonTotKar
						ELSE 0.00
					END,
		'nmoncap' = CASE WHEN G.cCodTipOpe IN ('0005','0002')
						THEN G.nMonTotKar
						ELSE 0.00
					END,
		'nmonpag' = CASE WHEN G.cCodTipOpe = '0013'
							THEN G.nMonTotKar*(-1)
							ELSE 0.00
						END
	INTO #DetKarAho
	FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMKardex] G 
		INNER JOIN #detCta D
			ON G.cCodCuenta = D.cCodCuenta
	WHERE G.cCodTipKar = 'AHO'
			AND G.cCodTipOpe IN ('0001','0005','0013','0002')
			AND (G.cCodKarExt = '' OR G.cCodKarExt IS NULL)	
			AND cCodTipGar <> 'NPCTS'
						
	select * from #DetKarAho
	
	SELECT	D.cCodCuenta , 
			nmonape = SUM(D.nmonape) , 
			nmoncap = SUM(D.nmoncap) , 
			nmonpag = SUM(D.nmonpag) ,
			P.nPlaOtorga ,
			DFECINI = A.dFecApeCta ,
			DFECFIN = A.dFecApeCta + P.nPlaOtorga,
			P.cCodTipSub
	INTO #CurDatGarAut
	FROM #DetKarAho D
		LEFT JOIN AHODCtaPlaFij P
			ON D.ccodcuenta = P.ccodcuenta
		LEFT JOIN AHOMCuenta A
			ON A.cCodCuenta = P.cCodCuenta 
	GROUP BY D.cCodCuenta, P.nPlaOtorga, A.dFecApeCta, P.cCodTipSub
/*
se solicita data de la cartera no minorista de la agencia Real , vigentes al 22-05-2015.
debe contemplar: Nombre de cliente , código de expediente , tipo de crédito : mediana empresa, 
grande empresa, corporativos , ifis , moneda , saldo de deuda convertido a soles , 
agencia : real 
*/

SELECT * into #v01 FROM  (
	SELECT 	
			CLIM.cCodSbs AS 'CodSbs'
			,CLI.cCodCliente AS 'CodigoCliente'
			,CLIM.cNomCliente AS 'NombreCliente'
			,isnull(CLIM.cNroDocIde,CLIM.cNroDocTri) as 'NroDocumento1'
			
			--DATOS DEL CREDITO
			,A.cCodCtaCre AS 'CodigoCredito'	--107002101006736320			
			,CASE A.cCodTipMon
			 WHEN '1' THEN A.nMonCapDes --2000000.00
			 WHEN '2' THEN A.nMonCapDes * 3.14			 
			 END AS 'MontoDesembol'				
			,CASE A.cCodTipMon
			 WHEN '1' THEN (A.nMonCapDes - A.nMonCapPag) --565434.72
			 WHEN '2' THEN (A.nMonCapDes - A.nMonCapPag) * 3.14			 
			 END AS 'Saldo'			
			,A.cCodTipCre,STC.cDesTipCre AS 'TipoCredito'
			,A.cCodProduc, STC.cDesProCre
			 ,A.cCodSubPro ,STC.cDesSubcRE AS 'SubProducto'
			,EC.cDescriEst							
					
			,O.cDesOficin AS 'Agencia'
			,zo.cNomZona as 'Detalle_Zona', zon.cDesZona as 'Zona'				
		
	FROM [KPYMCreConven] A 
		INNER JOIN [GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = A.cCodCtaCre
		INNER JOIN CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
				ON CLIM.cCodCliente = CLI.cCodCliente		
		INNER JOIN KPYTEstCreCon EC 
		    	ON EC.cEstCreCon = A.cEstCreCon
		INNER JOIN [KPYTSUBTIPCRE] STC
			ON A.cCodTipCre = STC.cCodTipCre AND A.cCodProduc = STC.cCodProduc 
			AND A.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			
		INNER JOIN GENTOficinas O
				ON A.cCodOficin = O.cCodOficin		

		INNER JOIN [GentZona] zo
				ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
				and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
		INNER JOIN [Gentofizonas] goz
				ON goz.cCodOficin = O.cCodOficin
		INNER JOIN [GentZonas] zon
				ON goz.nCodZona = zon.nCodZona

	WHERE A.cEstCreCon = 'F' 
			AND A.cCodOficin IN ('001','002')
			AND (A.cCodTipCre in ('10','11','12','05','06','07','08','09')
				and STC.lEstado = '1')	
	--ORDER BY CLI.cCodCliente 
) as tmp99
--(7,769 row(s) affected)

select * from #tmpv01 where NroDocumento1 is null

select * from [KPYTSUBTIPCRE] STC where STC.lEstado = '1' 
order by cCodTipCre asc

--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX #tmpv01_CodigoCliente_IXN ON #tmpv01(CodigoCliente)
CREATE NONCLUSTERED INDEX #tmpv01_CodigoCredito_IXN ON #tmpv01(CodigoCredito)
CREATE NONCLUSTERED INDEX #tmpv01_CodSbs_IXN ON #tmpv01(CodSbs)
--------------------****************************************************************************

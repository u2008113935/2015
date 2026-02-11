--select len(cCodCtaCred) from tb01

SELECT 	
			CLI.cCodCliente AS 'CodigoCliente'
			,CLIM.cNomCliente AS 'NombreCliente'
			,isnull(CLIM.cNroDocIde, CLIM.cNroDocTri) as 'NroDocumento1'			
			--DATOS DEL CREDITO
			,A.cCodCtaCre AS 'CodigoCredito'				
			,A.nMonCapDes as 'MontoDesembol' 	
			,(A.nMonCapDes - A.nMonCapPag) AS 'Saldo'		
			,CASE A.cCodTipMon
			 WHEN '1' THEN 'SOLES' 
			 WHEN '2' THEN 'DOLARES'			 
			 END AS 'MONEDA'
			,A.cCodTipCre,STC.cDesTipCre AS 'TipoCredito'
			,A.cCodProduc, STC.cDesProCre
			 ,A.cCodSubPro ,STC.cDesSubcRE AS 'SubProducto'
			,EC.cDescriEst														
			,O.cDesOficin AS 'Agencia'
			,zo.cNomZona as 'Detalle_Zona', zon.cDesZona as 'Zona'
			,A.cCodUsuAna AS 'COD_ANALISTA'--COD ANALISTA
			,SP.cNomPerson AS 'NOMBRE_ANALISTA'--NOMBRE ANALISTA 				
		
	FROM HYO00402.SOFCMACHYO_DIARIO_MANIANA.DBO.[KPYMCreConven] A 
		INNER JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.DBO.[GENMCRECLI] CLI 
				ON CLI.cCodCtaCre = A.cCodCtaCre
		INNER JOIN HYO00402.CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
				ON CLIM.cCodCliente = CLI.cCodCliente
		INNER JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.DBO.KPYTEstCreCon EC 
		    	ON EC.cEstCreCon = A.cEstCreCon
		INNER JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.DBO.[KPYTSUBTIPCRE] STC
			ON A.cCodTipCre = STC.cCodTipCre AND A.cCodProduc = STC.cCodProduc 
			AND A.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
		INNER JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.DBO.GENTOficinas O
				ON A.cCodOficin = O.cCodOficin
		INNER JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.DBO.[GentZona] zo
				ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
				and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
		INNER JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.DBO.[Gentofizonas] goz
				ON goz.cCodOficin = O.cCodOficin
		INNER JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.DBO.[GentZonas] zon
				ON goz.nCodZona = zon.nCodZona
		inner JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.DBO.[sipmpersonal] SP 
	        ON SP.cCodPerson = A.cCodUsuAna
	WHERE --A.cEstCreCon = 'F'
			A.cCodCtaCre COLLATE SQL_Latin1_General_CP1_CI_AS  
					in (select cCodCtaCred from tb01)
			



--DELETE FROM tb01
--select cCodCtaCred from tb01
--INSERT INTO Tb01 VALUES (107012101003973892)




use SOFCMACHYO_201503

SELECT * into #TMP_CREMICRO FROM  (
--CLIENTES DESERTORES creditos microempresa : #TMP_CREMICRO
SELECT --TOP 900000
	
	ROW_NUMBER() 
	OVER(PARTITION BY STC.cDesSubcRE 
			ORDER BY CLI.cCodCliente ) AS Secuencia
	 /*
	 ,CRE.cCodTipCre
	 ,STC.cDesTipCre AS 'TIPO_DE_CREDITO'
	 --,STC.cDesSubTip AS 'SUB_TIPO_DE_PRESTAMO'
	 ,CRE.cCodProduc
	 ,STC.cDesProCre AS 'PRODUCTO_CREDITICIO' 
	 ,CRE.cCodSubPro
	 */
	 ,STC.cDesSubcRE AS 'SUBPRODUCTO_CREDITICIO'	  
	--Datos del Cliente
	/*
	,CLIM.cNroDocIde as 'NroDocumento1'
	,CLI.cCodCliente AS 'CODIGO_CLIENTE'
	*/
	,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
	,CLIM.cCodSbs AS 'COD_SBS1'
	,'' as 'PERIODO'
	,O.cDesOficin AS 'NOMBRE_AGENCIA'
	,'' AS 'NroResolucion'
	,CRE.dFecDesCre as 'Fecha_Desembolso_Credito'
	,case cre.cCodTipMon
	when '1' then (CRE.nMonCapDes - CRE.nMonCapPag)
	when '2' then (CRE.nMonCapDes - CRE.nMonCapPag) * 3.34
	end AS 'SALDO_CAPITAL'
	/*
	,C.cDirCliente AS 'Direccion_Cliente' 
	,isnull(C.cDirCliRef,'') as 'Direccion_Referencia_Cliente'
	,DEP.cNomDepart AS 'Departamento_Cliente'
	,pro.cNomProvin AS 'Provincia_Cliente'
	,dis.cNomDistri AS 'Distrito_Cliente'
	,isnull(CLIM.cNroTelPer,'') AS 'Nro_Telefono_Personal'
	*/
	--DATOS DEL CREDITO

	--,CRE.cCodCtaCre AS 'CODIGO_CREDITO' --smalldatetime, 
	--,CONVERT(smalldatetime ,CRE.dFecDesCre, 103 ) as 'Fecha_Desembolso_Credito'--FECHA DESEMBOLSO DEL CREDITO
	--FECHA DESEMBOLSO DEL CREDITO
	--,isnull(CRE.dFecCulCre,'') as 'Fecha_Culminacion_Credito'--FECHA DE CULMINACION DEL CREDITO
	--,round(avg(cast(nDiaVenCuo as float)),0) as 'Promedio_Nro_Dias_Atraso'
	--,CRE.nDiaAtrCre as 'Nro_Dias_Atraso_Cuota'
	--,CRE.nDiaAtrAcu as 'Nro_Dias_Atraso_Acumulado'
	--,CRE.nDiaAtrMax as 'Nro_Dias_Atraso_Maximo'
	/*
	,CRE.nMonCapDes as 'MONTO_DESEMBOLSADO' 
	,case CRE.cCodTipMon 
	 When '1' then 'SOLES'
	 WHEN '2' THEN 'DOLARES'
	 END as 'MONEDA'
	--,CRE.nMonCapPag as 'CAPITAL_PAGADO' 
	*/
		
	--,EC.cDescriEst AS 'ESTADO_DEL_CREDITO'	 

	 --DATOS AGENCIA
	
	--,O.cCodOficin
	/*
	,O.cDirOficin AS 'DIRECCION_AGENCIA' 	
	,DEP1.cNomDepart AS 'Departamento_Agencia'			 
	,pro1.cNomProvin AS 'Provincia_Agencia' 
	,dis1.cNomDistri as 'Distrito_Agencia'
	,zo.cNomZona as 'Detalle_Zona', zon.cDesZona as 'Zona'
	,CRE.cCodUsuAna AS 'COD_ANALISTA'--COD ANALISTA
	,SP.cNomPerson AS 'NOMBRE_ANALISTA'--NOMBRE ANALISTA 	
	*/
	
FROM [KPYMCRECONVEN] CRE (NOLOCK)		
	INNER JOIN [GENMCRECLI] CLI 
			ON CLI.cCodCtaCre = CRE.cCodCtaCre
	INNER JOIN CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
		    ON CLIM.cCodCliente = CLI.cCodCliente
	
	inner JOIN [sipmpersonal] SP 
	        ON SP.cCodPerson = CRE.cCodUsuAna
	INNER JOIN [GENTOficinas] O 
	        ON O.cCodOficin = CRE.cCodOficin
	INNER JOIN [KPYDPRODUCTO] PROD
			ON CRE.cCodProduc =  PROD.cCodProduc and CRE.cCodTipCre = PROD.cCodTipCre
	INNER JOIN [KPYDSUBPRODUC] SPRO
			ON CRE.cCodSubPro = SPRO.cCodSubPro AND CRE.cCodTipCre = SPRO.cCodTipCre
			AND CRE.cCodProduc =  SPRO.cCodProduc
	INNER JOIN [KPYTSUBTIPCRE] STC
			ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
			AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
	INNER JOIN KPYTEstCreCon EC 
			ON EC.cEstCreCon = CRE.cEstCreCon
	/*
	--UBIGEO DEL CLIENTE
	LEFT JOIN CMACHYOCLI.[CLIMDirecc] C
			ON CLI.cCodCliente = C.cCodCliente AND C.bDirPredet = 1	 
	INNER JOIN [GenTDepartame] dep
			ON DEP.cCodDepart = C.cCodDepart
	INNER JOIN [GentProvincia] pro
			ON pro.cCodProvin = C.cCodProvin and pro.cCodDepart = C.cCodDepart 
	INNER JOIN [GentDistrito] dis
			ON dis.cCodDistri = C.cCodDistri and DIS.cCodProvin = C.cCodProvin 
			and dis.cCodDepart = C.cCodDepart
	*/
	/*	
	---UBIGEO DEL CREDITO
	INNER JOIN [GenTDepartame] dep1
		ON DEP1.cCodDepart = O.cCodDepart
	INNER JOIN [GentProvincia] pro1
		ON pro1.cCodProvin = O.cCodProvin and pro1.cCodDepart = O.cCodDepart 
	INNER JOIN [GentDistrito] dis1
		ON dis1.cCodDistri = O.cCodDistri and dis1.cCodProvin = O.cCodProvin 
			and dis1.cCodDepart = O.cCodDepart
			
	INNER JOIN [GentZona] zo
		ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
		and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
	INNER JOIN [Gentofizonas] goz
		ON goz.cCodOficin = O.cCodOficin
	INNER JOIN  [GentZonas] zon
		ON goz.nCodZona = zon.nCodZona	
	*/	
WHERE 
		( 
	(CRE.cCodTipCre = '02' and CRE.cCodProduc = '02' and CRE.cCodSubPro in ('04','10','14') and STC.lEstado = 1) 
						or 
	(CRE.cCodTipCre = '03' and CRE.cCodProduc in ('02','03','13') and CRE.cCodSubPro in ('14','01','04','06','16','10')
						and STC.lEstado = 1 ) 
						or
	(CRE.cCodTipCre = '04' and CRE.cCodProduc in ('01','02','23','24','25') and CRE.cCodSubPro 
							in ('03','06','07','08','10','11','13','14') and STC.lEstado = 1)		
						or
	(CRE.cCodTipCre = '11' and CRE.cCodProduc = '02' and CRE.cCodSubPro in ('10','13','16') and STC.lEstado = 1)
						or
	(CRE.cCodTipCre = '12' and CRE.cCodProduc = '02' and CRE.cCodSubPro in ('04','12','15') and STC.lEstado = 1)
				       or
    (CRE.cCodTipCre = '13' and CRE.cCodProduc = '02' and CRE.cCodSubPro in ('04','10','14') and STC.lEstado = 1)
				)	
				
		and CRE.dFecDesCre >='2014-06-15' and CRE.dFecDesCre <= '2014-10-15'
	
) AS Tmp

/*
(Personales, CrediCasa Habitacional, Plazo Fijo, Credi Joyas, Solidario, Crediruedas, Mi Vivienda, 
CrediCasa Habitacional y Comercial, Techo Propio) 
*/

--Sacando los productos indicados de consumo
			--02
		--	SELECT * into #tmp_sacar FROM  ( 
			Select cCodTipCre,cCodProduc,cCodSubPro,cDesTipCre,cDesSubTip,cDesProCre,cDesSubCre,lEstado
			from  [KPYTSUBTIPCRE]--[KPYMCRECONVEN] CRE (NOLOCK)
			Where  
				(cCodTipCre = '03' and cCodProduc = '13' and cCodSubPro = '16' and lEstado = 1)
			( 
			(cCodTipCre = '02' and cCodProduc = '02' and cCodSubPro in ('04','10','14') and lEstado = 1) 
						or 
			(cCodTipCre = '03' and cCodProduc in ('02','03','13') and cCodSubPro in ('14','01','04','06','16','10')
						and lEstado = 1 ) 
						or
			(cCodTipCre = '04' and cCodProduc in ('01','02','23','24','25') and cCodSubPro 
							in ('03','06','07','08','10','11','13','14') and lEstado = 1)		
						or
				(cCodTipCre = '11' and cCodProduc = '02' and cCodSubPro in ('10','13','16') and lEstado = 1)
						or
				(cCodTipCre = '12' and cCodProduc = '02' and cCodSubPro in ('04','12','15') and lEstado = 1)
				       or
                (cCodTipCre = '13' and cCodProduc = '02' and cCodSubPro in ('04','10','14') and lEstado = 1)
				)				
				--(474 row(s) affected)
		--	) as tmp02
			
		SELECT  --PREN.* --count(DISTINCT CLI1.cCodCliente)
			/*
			ROW_NUMBER() 
				OVER(PARTITION BY STC.cDesSubcRE 
			ORDER BY CLI.cCodCliente ) AS Secuencia
		    */
			'CREDIJOYAS' AS 'SUBPRODUCTO_CREDITICIO'	  	
			,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
			,CLIM.cCodSbs AS 'COD_SBS1'
			,'' as 'PERIODO'
			,O.cDesOficin AS 'NOMBRE_AGENCIA'
			,'' AS 'NroResolucion'
			,PREN.dFecCreKpr as 'Fecha_Desembolso_Credito'
			,case PREN.cCodTipMon 
			when '1' then PREN.nMonSalAct
			when '2' then PREN.nMonSalAct * 3.34
			end  AS 'SALDO_CAPITAL'
		FROM [KPRMCREPRENDA] PREN (NOLOCK)				
				INNER JOIN 	[GENMCRECLI] CLI 
					ON CLI.cCodCtaCre = PREN.cCodCtaKpr
				INNER JOIN CMACHYOCLI.dbo.[CLIMCLIENTES] CLIM 
					ON CLIM.cCodCliente = CLI.cCodCliente
				INNER JOIN [GENTOficinas] O 
					ON O.cCodOficin = PREN.cCodOficin
		WHERE  --PREN.cCodEstKpr in ('D','A','R','G','H')
				--AND (PREN.nMonCreKpr - PREN.nMonPagKpr) > 0
				PREN.dFecCreKpr >='2014-06-15' and PREN.dFecCreKpr <= '2014-10-15' 


	SELECT *  FROM [KPRMCREPRENDA] PREN (NOLOCK) WHERE PREN.cCodEstKpr in ('D','A','R','G','H')
		
	SELECT PREN.cCodCtaKpr,	PREN.dFecCreKpr , PREN.dFecIngCre, PREN.cCodEstKpr, EST.cDesEstKpr,
			(PREN.nMonCreKpr - PREN.nMonPagKpr) as 'SALDO'
	FROM [KPRMCREPRENDA] PREN (NOLOCK) 
		INNER JOIN [KPRTESTCREDITO] EST ON EST.cCodEstKpr = PREN.cCodEstKpr
	WHERE --PREN.cCodEstKpr in ('D','A','R','G','H') 
		PREN.dFecCreKpr >='2014-06-15' and PREN.dFecCreKpr <= '2014-10-15' 
				
SELECT PREN.cCodEstKpr FROM [KPRMCREPRENDA] PREN (NOLOCK) GROUP BY PREN.cCodEstKpr
	--H, A, E, R, X, J, C, M, D, P, I, K, Z
Select  * from KPRTESTCREDITO WHERE cCodEstKpr IN ('H', 'A', 'E', 'R', 'X', 'J', 'C', 'M', 'D', 'P', 'I', 'K', 'Z')
Select  * from KPRTESTCREDITO WHERE cCodEstKpr in ('D','A','R','G','H')
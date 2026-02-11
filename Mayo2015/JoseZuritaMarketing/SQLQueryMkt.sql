SELECT * FROM PROSPECTOV02

	--CURSOR COMPLETANDO CODIGO cliente de la tabla clientes
		Declare @dni varchar(10), @cCodCliente varchar(20) 
		Declare cCursor95 CURSOR FOR
			select NumDoc from PROSPECTOV02
				where cCodCliente is null
		OPEN cCursor95
		FETCH cCursor95 into @dni
		WHILE (@@FETCH_STATUS=0)
		BEGIN			  

		  set @cCodCliente = (select cCodCliente
						   from [HYO00402].CMACHYOCLI_MANIANA.DBO.[CLIMCLIENTES]   
						   where cNroDocIde = @dni)	

		  Update PROSPECTOV02 			 										
		  Set cCodCliente = @cCodCliente
		  where NumDoc = @dni		  		  
		  
		FETCH cCursor95 INTO @dni
		END
		CLOSE cCursor95
		DEALLOCATE cCursor95
------------------------------------------------------------------------------------

SELECT * FROM PROSPECTOV02 where cCodCliente is null
SELECT * FROM PROSPECTOV02 where cCodCliente is not null

SELECT NumDoc, count(NumDoc) 
FROM PROSPECTOV02
group by NumDoc
having count(NumDoc) >1 

SELECT NumDoc, len(NumDoc) 
FROM PROSPECTOV02
group by NumDoc
having len(NumDoc) = 8

----*******************************--GESTIONANDO CARTERA--------------------------------

	--*********************************INDEXANDO****************************************************
	CREATE NONCLUSTERED INDEX PROSPECTOV02_cCodCliente_IXN ON PROSPECTOV02(cCodCliente)
	CREATE NONCLUSTERED INDEX PROSPECTOV02_NumDoc_IXN ON PROSPECTOV02(NumDoc)
	--------------------****************************************************************************

		SELECT 
			--Datos del Cliente	
			CLIM.cNroDocIde as 'NroDocumento'
			,CLI.cCodCliente AS 'CODIGO_CLIENTE'
			,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
			--DATOS DEL CREDITO
			,CRE.cCodCtaCre AS 'CODIGO_CREDITO'
			,CRE.nMonCapDes as 'MONTO_DESEMBOLSADO' 
			,CRE.nTasIntCom as 'TasaInteres'
			,CRE.nCosEfeAct as 'TasaCostoEfectivoAnual'
			,case CRE.cCodTipMon 
			 When '1' then 'SOLES'
			 WHEN '2' THEN 'DOLARES'
			 END as 'MONEDA'
			,CRE.nMonintPro as 'MontoInteresAprobado'
			,CRE.nMonintFec as 'MontoInteresAlaFecha'
			,CRE.nMonintPag as 'MontoInteresPagado'
			,EC.cDescriEst AS 'ESTADO_DEL_CREDITO'
			,CRE.dFecDesCre as 'Fecha_Desembolso_Credito'
			,isnull(CRE.dFecCulCre,'') as 'Fecha_Culminacion_Credito'
			,CRE.nNumCuoApr as 'NroCuotasAprobadas'
			,CRE.cTipPeriodo
			,case CRE.cCodPlazo				
			 when '1' then 'CORTO PLAZO'
			 when '2' then 'LARGO PLAZO'
			 END 
			 ,CRE.cCodTipCre
			 ,STC.cDesTipCre AS 'TIPO_DE_CREDITO'
			 ,STC.cDesSubTip AS 'SUB_TIPO_DE_PRESTAMO'
			 ,CRE.cCodProduc
			 ,STC.cDesProCre AS 'PRODUCTO_CREDITICIO' 
			 ,CRE.cCodSubPro	
			 ,STC.cDesSubcRE AS 'SUBPRODUCTO_CREDITICIO'
			,O.cDesOficin AS 'NOMBRE_AGENCIA'
			,CRE.cCodOficin
			,zo.cNomZona as 'Detalle_Zona', zon.cDesZona as 'Zona'
			,CRE.cCodUsuAna AS 'COD_ANALISTA'--COD ANALISTA
			,SP.cNomPerson AS 'NOMBRE_ANALISTA'--NOMBRE ANALISTA  
		FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMCRECONVEN] CRE (NOLOCK)		
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] CLI 
					ON CLI.cCodCtaCre = CRE.cCodCtaCre
			INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CLIM 
					ON CLIM.cCodCliente = CLI.cCodCliente
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTEstCreCon] EC 
					ON EC.cEstCreCon = CRE.cEstCreCon
			inner JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[sipmpersonal] SP 
					ON SP.cCodPerson = CRE.cCodUsuAna
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENTOficinas] O 
					ON O.cCodOficin = CRE.cCodOficin
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYTSUBTIPCRE] STC
					ON CRE.cCodTipCre = STC.cCodTipCre AND CRE.cCodProduc = STC.cCodProduc 
					AND CRE.cCodSubPro = STC.cCodSubPro and STC.lEstado = '1'
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GentZona] zo
				ON ZO.cCodZona = O.cCodZona and zo.cCodDepart = O.cCodDepart
				and zo.cCodProvin = O.cCodProvin  and zo.cCodDistri = O.cCodDistri
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[Gentofizonas] goz
				ON goz.cCodOficin = O.cCodOficin
			INNER JOIN  [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GentZonas] zon
				ON goz.nCodZona = zon.nCodZona	
		WHERE   --CLI.cCodCliente  COLLATE SQL_Latin1_General_CP1_CI_AS	
				--in (select cCodCliente from PROSPECTOV02 )
				--AND CRE.cEstCreCon = 'F'
				CLIM.cNroDocIde COLLATE SQL_Latin1_General_CP1_CI_AS	
				IN (select NumDoc from PROSPECTOV02 )
				AND CRE.dFecDesCre >= '2015-03-27'
		ORDER BY CLI.cCodCliente
			
/*
NroDocumento			CODIGO_CLIENTE	NOMBRE_CLIENTE
15447185            	107015755611	GUEVARA NAVARRO, CATALINA JUNETT
15864666            	107017802601	JARA RAMOS, SANDRA PAOLA
23262811            	107019266685	MENESES QUISPE, ANASTO
06578690            	107022392740	AYALA GUTIERREZ, DOMINGO
06558627            	107022541579	LARA CALDERON, ZENON
10439336            	107022599662	FLORES ORTIZ, ARTURO CELESTINO
10132841            	107022674701	CRUZ ATAHUALPA, JOHNNY
*/

		SELECT * 
		FROM PROSPECTOV02 
		where NumDoc IN (
		'15447185',            
		'15864666',            
		'23262811',            
		'06578690',            
		'06558627',            
		'10439336',            
		'10132841'            
		)
 

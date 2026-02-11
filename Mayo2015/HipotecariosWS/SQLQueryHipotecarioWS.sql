select * from NMV
where cCodCli = ''
--drop table NMV

Alter table NMV
Add cCodCli varchar(20) 

		--CURSOR COMPLETANDO CODIGO cliente de la tabla clientes
		Declare @dociden varchar(10), @cCodCli varchar(20) 
		Declare cCursor70 CURSOR FOR
			select DocIdentidad from NMV				
		OPEN cCursor70
		FETCH cCursor70 into @dociden
		WHILE (@@FETCH_STATUS=0)
		BEGIN			  

		  set @cCodCli = (select cCodCliente
						   from [HYO00402].CMACHYOCLI_MANIANA.DBO.[CLIMCLIENTES]   
						   where cNroDocIde = @dociden)	

		  Update NMV 			 										
		  Set cCodCli = @cCodCli
		  where DocIdentidad = @dociden		  		  
		  
		FETCH cCursor70 INTO @dociden
		END
		CLOSE cCursor70
		DEALLOCATE cCursor70
------------------------------------------------------------------------------------

Select * from NMV

--*********************************INDEXANDO****************************************************
CREATE NONCLUSTERED INDEX NMV_DocIdentidad_IXN ON NMV(DocIdentidad)
CREATE NONCLUSTERED INDEX NMV_cCodCli_IXN ON NMV(cCodCli)

--------------------****************************************************************************

	--01
	-- DROP TABLE NMV02
SELECT * into NMV02 FROM  (
	SELECT 
		--Datos del Cliente	
		CLIM.cNroDocIde as 'NroDocumento'
		,CLI.cCodCliente AS 'CODIGO_CLIENTE'
		,CLIM.cNomCliente AS 'NOMBRE_CLIENTE'
		--DATOS DEL CREDITO
		,CRE.cCodCtaCre AS 'CODIGO_CREDITO'		
		,EC.cDescriEst AS 'ESTADO_DEL_CREDITO'		
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
		--/*
		,DGAR.CCODLINCRE, B.CCODCTACRE, CX.cCodCliente --, A.cCodCliente
		,CX.cNomCliente AS 'DUENIO'
		,ISNULL(AA.ccodficreg,' ') as 'ccodficreg', A.cCodGarCli, CG.cDirDomGar
		,CG.cCodTipGar, N.cdestipgar
				
		 --*/

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
		
		--Garantias
		--/*
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] B
				ON CRE.cCodCtaCre = B.CCODCTACRE --and B.cCodCliente = Z.CODIGO_CLIENTE
		INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYDGARLINCRE] DGAR 
				ON DGAR.CCODLINCRE = B.cCodLinCre AND DGAR.cCodEstGar = 'A'					
		INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CX 
				ON CX.cCodCliente = DGAR.cCodCliente	
		INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMGarCliente] CG
				ON CG.cCodCliente = CX.cCodCliente	
					and CG.cCodGarCli = DGAR.cCodGarCli  --AND CG.cCodTipGar = 'RPHIP'						

		inner JOIN [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMGarCliente] A			
				ON A.cCodCliente = CX.cCodCliente AND A.cCodGarCli = CG.cCodGarCli
		left JOIN [HYO00402].CMACHYOCLI_MANIANA.DBO.[CliMGarFisHipCli] AA			
				ON AA.cCodCliente = CX.cCodCliente AND AA.cCodGarCli = CG.cCodGarCli
		inner join [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENDGarantia] N
				on N.ccodgarant = CG.cCodTipGar and  N.lconestado = 1
		--*/
	WHERE CLI.cCodCliente  --COLLATE SQL_Latin1_General_CP1_CI_AS	
			in (
			
						)  --(select cCodCli from NMV )
			AND CRE.cEstCreCon IN ('F','I','H','G')
			AND (CRE.cCodTipCre = '04' and STC.lEstado = '1' 
					and STC.cDesSubTip = 'FONDO MI VIVIENDA' ) 
				/*
			AND DGAR.cCodEstGar = 'A'
			AND DGAR.cCodTipGar = 'RPHIP'
				*/
			--and CLIM.cNroDocIde = '40160228' --'40874136'	
	--ORDER BY CLIM.cNroDocIde --CLI.cCodCliente

	) as tmp

	Select * from NMV02
	where CODIGO_CLIENTE ='107010584822'

	select CODIGO_CLIENTE, count(CODIGO_CLIENTE)	
	from NMV02
	group by CODIGO_CLIENTE
	having count(CODIGO_CLIENTE) = 1
	
	--02

	select CODIGO_CLIENTE, count(CODIGO_CLIENTE)	
	from NMV02
	group by CODIGO_CLIENTE
	having count(CODIGO_CLIENTE) > 3

	Select * from NMV02 where NroDocumento = '40501516'
	Select * from NMV02 where CODIGO_CLIENTE = '107010902164'
 
	Select * from NMV02
	 
	Select * from NMV02 where ccodficreg = ''


	Select A.cCodCli, A.* 
	from NMV A
	where cCodCli COLLATE SQL_Latin1_General_CP1_CI_AS	
			not in ( Select CODIGO_CLIENTE from NMV02) 
		
	--03
	
	Select A.* , B.*
	from [NMV] A
		inner join [NMV02] B
			on A.DocIdentidad COLLATE SQL_Latin1_General_CP1_CI_AS 
				= B.NroDocumento
	 order by A.DocIdentidad

		

	-------------------------------------------------------------
	/*
	SELECT B.*
		,B.CCODLINCRE , A.nMonCapDes , A.nMonCapPag,A.nMonCapDes - A.nMonCapPag  , A.*
		FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMCRECONVEN] A
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] B
				ON A.CCODCTACRE = B.CCODCTACRE
		WHERE A.CESTCRECON = 'F' 
			--AND B.cCodLinCre = '0020056190'
			AND A.CCODCTACRE = '107002101007324885'

			--SUAREZ CONTRERAS, ADRIANA RAFAELA	107002101007324885

		SELECT *
		FROM KPYDGARLINCRE DGAR 
		WHERE DGAR.CCODLINCRE = '0020073453'--@cCodLinCre  
			AND DGAR.cCodEstGar = 'A'
			AND DGAR.cCodTipGar = 'RPHIP'

	Select * from [HYO00402].CMACHYOCLI_MANIANA.DBO.[CLIMGARCLIENTE] B 
	Where cCodCliente = '107021935072'




	------------------------validando listado de garantias-----------------------------------------------------
	Select --top 1 
		* From [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[GENMCRECLI] B
	Where B.cCodCliente	=  '107021935072' --'107010499435' 
		--and B.cCodLinCre = '0020073453'
		and B.cCodCtaCre = '107002101007324885'
			
				--ON CRE.CCODCTACRE = B.CCODCTACRE
	Select --top 1 
		* from [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYDGARLINCRE] DGAR 
	Where DGAR.cCodLinCre = '0430011015'
			and DGAR.cCodCliente = '' --'107011247503'
		-- and DGAR.cCodGarCli = '001'         
	
	SELECT *
	FROM [HYO00402].CMACHYOCLI_MANIANA.dbo.CLIMGarCliente
	WHERE cCodCliente  = '107011247503'
		--and cCodTipGar = 'RPHIP'
		AND cCodGarCli = '013'
				--ON DGAR.CCODLINCRE = B.cCodLinCre AND DGAR.cCodEstGar = 'A'
	
	select --top 2 
		*
	from [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] CX 
	where CX.cCodCliente = '107011247503'
				--ON CX.cCodCliente = DGAR.cCodCliente	
	select --top 2 
	*
	from  [HYO00402].CMACHYOCLI_MANIANA.DBO.[CliMGarFisHipCli] A			
	where cCodCliente = '107011247503'
		AND cCodGarCli = '013'
				--ON A.cCodCliente = CX.cCodCliente

	select top 2 * from [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYMLinCreCli]
	
	select --top 2 
		* 
	from [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYDAMPGARCRE]
	where cCodCliente  = '107011247503'

	
	SELECT A.cCodCliente,A.cCodGarCli,B.nMonGraGar , B.nMonGarOri , B.nMonGarOriSol 
			, B.nMonTasGar , B.nMonTasGarSol , B.nTipCamTas, B.cCodTipMon
	FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.dbo.[KPYDGarLinCre] A
		INNER JOIN [HYO00402].CMACHYOCLI_MANIANA.DBO.[CLIMGARCLIENTE] B
			ON A.CCODCLIENTE = B.CCODCLIENTE 	
			AND A.CCODGARCLI = B.CCODGARCLI 		 
	WHERE	cCodLinCre = '0020073453'--@cCodLinCre
			AND A.cCodEstGar = 'A'
	*/

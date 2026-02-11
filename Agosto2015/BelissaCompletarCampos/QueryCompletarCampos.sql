
	/*
	
	Se solicita agregar los siguientes campos a la relacion adjunta: 
	nMOnSalAnt 
	nMOnSalDes
	cCodIns
	dFecSis
	HoraTermin
	cCodUsuSis
	cCodUsuSOP
	cVenOperac
	cSerTermin
	cCodUsu
	cTipInsOri
	cMotCambio	
	
	*/

	Select * from Beneficiarios A -- (2,654 row(s) affected)

	Select A.* 	
		--nMOnSalAnt	nMOnSalDes	cCodIns	dFecSis	HoraTermin	cCodUsuSis	cCodUsuSOP	cVenOperac	cSerTermin	cCodUsu	cTipInsOri	cMotCambio
	from Beneficiarios A
		inner join HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.GENMKARDEX B
			on A.CodigoCredito COLLATE SQL_Latin1_General_CP1_CI_AS = B.cCodCuenta

			/*
			nMonTotKar,nSalCapita
			,cCodUsuSis, cCodUsuSOp, cVenOperac, cSerTermin,cCodUsuOpe,cCodInsDes
			*/

	Select * 
	from HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.GENMKARDEX B
	Where B.cCodCuenta = '107025101003790334'

	------------------------------------------------------------------------------------

	DECLARE @nTipCambio MONEY -- ,@dFecTipCam DATE					
	set @nTipCambio = (
		SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
			nTipCambio = nTipCamFij
		FROM HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.GENTTipCambio
		WHERE left(cast(dFecTipCam as date),10) ='2015-08-01')

	SELECT   
		A.*
		/*
		CRE.CCODTIPCRE, CRE.CCODPRODUC + TIP.cCodProEqu AS CCODPRODUC, CRE.CCODSUBPRO
		,CRE.CCODTIPREC, CRE.CCODRECURS,   
		CRE.NNROLINFIN, CRE.CCODMODCRE,cCodParCam , CRE.CCODTIPMON, CRE.CCODPLAZO,  
		CRE.CTIPTASCOM, CRE.CTIPTASMOR, CRE.NTASINTCOM, CRE.NTASINTMOR, CRE.CCODSOLCRE,  
		CRE.CLIBAMOCRE,   
		CON.CDESCONVEN,  
		CDESCRECON = DES.CDESCRIDES,   
		LIN.cdesLinFin,   
		GEN.cCodLinCre,    
		*/
		/*
		,nMOnSalCre =
		(nMOnCapDes + ISNULL(CRE.nMOnIntPro,0) + ISNULL(CRE.nMOnMorPro,0) + ISNULL(nMonGasPro,0))    
		- (ISNULL(CRE.nMonCapPag,0) + ISNULL(CRE.nMonIntPag,0) + ISNULL(CRE.nMOnMorPag,0) +     
		ISNULL(CRE.nMOnGasPag,0)) 
		*/
		--,dbo.Gen_ForCarFec_fx(dFecIngJud) AS dFecIngJud,    
		--dbo.Gen_ForCarFec_fx(dFecCasCre) AS dFecCasCre ,
		/*
		cre.ccodoficin ,cre.nnumcuoapr,cre.nnumdiaapr,cre.nnumdiagra
		*/	
		,pnMOnSalAnt = 
		 (nMOnCapDes + ISNULL(CRE.nMOnIntPro,0) + ISNULL(CRE.nMOnMorPro,0) + ISNULL(nMonGasPro,0))    
		 - (ISNULL(CRE.nMonCapPag,0) + ISNULL(CRE.nMonIntPag,0) + ISNULL(CRE.nMOnMorPag,0) +     
		 ISNULL(CRE.nMOnGasPag,0)) 
		,pnMOnSalDes = 
			Case CRE.CCODTIPMON when '2' then 
			((nMOnCapDes + ISNULL(CRE.nMOnIntPro,0) + ISNULL(CRE.nMOnMorPro,0) 
			+ ISNULL(nMonGasPro,0))   - (ISNULL(CRE.nMonCapPag,0) + ISNULL(CRE.nMonIntPag,0)
			 + ISNULL(CRE.nMOnMorPag,0) + ISNULL(CRE.nMOnGasPag,0)) ) / @nTipCambio
			else 
			((nMOnCapDes + ISNULL(CRE.nMOnIntPro,0) + ISNULL(CRE.nMOnMorPro,0) 
			+ ISNULL(nMonGasPro,0))   - (ISNULL(CRE.nMonCapPag,0) + ISNULL(CRE.nMonIntPag,0)
			 + ISNULL(CRE.nMOnMorPag,0) + ISNULL(CRE.nMOnGasPag,0)) ) * @nTipCambio			 
			end
		,cCodInsOri = '107'
		,dFecSis = left(cast(getdate() as date),10)
		,HoraTermin = ''
		,cCodUsuSis = 'BGUERR'
		,cCodUsuSOP = 'BGUERR'
		,cVenOperac = ''
		,cSerTermin = ''
		,cCodUsu = 'BGUERR'
		,cTipInsOri = ''
		,cMotCambio	= 'Calce de línea adeudada BN.'			

	FROM HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMCRECONVEN CRE 
		LEFT JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMSOLICITUD SOL
			ON CRE.CCODSOLCRE = SOL.CCODSOLCRE
		LEFT JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.GENMCRECLI GEN     
			ON (CRE.CCODCTACRE = GEN.CCODCTACRE)    
		INNER JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMLinFinCre LIN     
			ON (CRE.nNroLinFin = LIN.nNroLinFin)    
		INNER JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYTSubtipCre TIP
			ON CRE.cCodTipCre = TIP.cCodTipCre
				AND CRE.cCodProduc = TIP.cCodProduc
				AND CRE.cCodSubPro = TIP.cCodSubPro
				AND TIP.lEstado = CASE 
									WHEN CRE.cEstCreCon IN ('G') AND CRE.dFecCulCre <= '20100630'
									THEN 0
										ELSE 1 
									  END 
				LEFT JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KJUMCreJudici JUD    
					ON(CRE.CCODCTACRE = JUD.CCODCTACRE)    
				LEFT JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYTDESCRECON DES  
					ON(CRE.CCODDESCRE = DES.CCODDESCRE)  
				LEFT JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMCONVENIOS CON  
					ON(CON.CCODCONVEN = CRE.CCODCONVEN)  

				inner join Beneficiarios A
					on A.CodigoCredito COLLATE SQL_Latin1_General_CP1_CI_AS = CRE.cCodCtaCre
	--WHERE CRE.cCodCtaCre = '107025101003790334' -- @x_cCodCta  
		Order By Nro   
	



	DECLARE @nTipCambio MONEY -- ,@dFecTipCam DATE					
	Set @nTipCambio = (
		SELECT --dFecTipCam=rtrim(left(cast(dFecTipCam as date),7)),
			nTipCambio = nTipCamFij
		FROM HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.GENTTipCambio
		WHERE left(cast(dFecTipCam as date),10) ='2015-08-01')

	SELECT   
		A.*
		,nMOnSalCre =
		(nMOnCapDes + ISNULL(CRE.nMOnIntPro,0) + ISNULL(CRE.nMOnMorPro,0) + ISNULL(nMonGasPro,0))    
		- (ISNULL(CRE.nMonCapPag,0) + ISNULL(CRE.nMonIntPag,0) + ISNULL(CRE.nMOnMorPag,0) +     
		ISNULL(CRE.nMOnGasPag,0)) 
	
		,pnMOnSalAnt = 
		 (nMOnCapDes + ISNULL(CRE.nMOnIntPro,0) + ISNULL(CRE.nMOnMorPro,0) + ISNULL(nMonGasPro,0))    
		 - (ISNULL(CRE.nMonCapPag,0) + ISNULL(CRE.nMonIntPag,0) + ISNULL(CRE.nMOnMorPag,0) +     
		 ISNULL(CRE.nMOnGasPag,0)) 
		,pnMOnSalDes = 
			Case CRE.CCODTIPMON when '2' then 
			((nMOnCapDes + ISNULL(CRE.nMOnIntPro,0) + ISNULL(CRE.nMOnMorPro,0) 
			+ ISNULL(nMonGasPro,0))   - (ISNULL(CRE.nMonCapPag,0) + ISNULL(CRE.nMonIntPag,0)
			 + ISNULL(CRE.nMOnMorPag,0) + ISNULL(CRE.nMOnGasPag,0)) ) / @nTipCambio
			else 
			((nMOnCapDes + ISNULL(CRE.nMOnIntPro,0) + ISNULL(CRE.nMOnMorPro,0) 
			+ ISNULL(nMonGasPro,0))   - (ISNULL(CRE.nMonCapPag,0) + ISNULL(CRE.nMonIntPag,0)
			 + ISNULL(CRE.nMOnMorPag,0) + ISNULL(CRE.nMOnGasPag,0)) ) * @nTipCambio			 
			end 
	FROM HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMCRECONVEN CRE 
		LEFT JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMSOLICITUD SOL
			ON CRE.CCODSOLCRE = SOL.CCODSOLCRE
		LEFT JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.GENMCRECLI GEN     
			ON (CRE.CCODCTACRE = GEN.CCODCTACRE)    
		INNER JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMLinFinCre LIN     
			ON (CRE.nNroLinFin = LIN.nNroLinFin)    
		INNER JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYTSubtipCre TIP
			ON CRE.cCodTipCre = TIP.cCodTipCre
				AND CRE.cCodProduc = TIP.cCodProduc
				AND CRE.cCodSubPro = TIP.cCodSubPro
				AND TIP.lEstado = CASE 
									WHEN CRE.cEstCreCon IN ('G') AND CRE.dFecCulCre <= '20100630'
									THEN 0
										ELSE 1 
									  END 
		LEFT JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KJUMCreJudici JUD    
			ON(CRE.CCODCTACRE = JUD.CCODCTACRE)    
		LEFT JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYTDESCRECON DES  
			ON(CRE.CCODDESCRE = DES.CCODDESCRE)  
		LEFT JOIN HYO00402.SOFCMACHYO_DIARIO_MANIANA.dbo.KPYMCONVENIOS CON  
			ON(CON.CCODCONVEN = CRE.CCODCONVEN)  

		inner join Beneficiarios A
			on A.CodigoCredito COLLATE SQL_Latin1_General_CP1_CI_AS = CRE.cCodCtaCre
	WHERE CRE.cCodCtaCre = '107025101003790334' 
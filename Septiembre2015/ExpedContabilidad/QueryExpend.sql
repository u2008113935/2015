

	-- Select * from ExpedContabilidad

			Select B.cCodCliente,A.cNomCliente,B.cCodCtaCre, E.cCodExpCli 
				,CRE.cCodUsuAna AS 'CodAsesorActual',SP.cNomPerson AS 'NombreAsesorActual'	
				,Oficina = O.cDesOficin ,Zona = ZON.cDesZona
			FROM [HYO00402].CMACHYOCLI_MANIANA.dbo.[CLIMCLIENTES] A 				
				inner join [HYO00409\HISTORICO].SOFCMACHYO_201508.dbo.[GENMCRECLI] B
					on A.cCodCliente = B.cCodCliente 
				inner join [HYO00402].CMACHYOCLI_MANIANA.DBO.CLIDExpediente E
					on E.cCodClient = A.cCodCliente		
				
				inner join [HYO00409\HISTORICO].SOFCMACHYO_201508.dbo.[KPYMCRECONVEN] CRE (NOLOCK)	
					on CRE.cCodCtaCre = B.cCodCtaCre
				INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.dbo.[GENTOficinas] O 
					ON O.cCodOficin = CRE.cCodOficin and O.lConEstado = '1'			
				INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.dbo.[Gentofizonas] GOZ
					ON GOZ.cCodOficin = O.cCodOficin and GOZ.lEstZonOfi = '1'
				INNER JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.dbo.[GentZonas] ZON
					ON ZON.nCodZona = GOZ.nCodZona	
				inner JOIN [HYO00409\HISTORICO].SOFCMACHYO_201508.dbo.[sipmpersonal] SP 
					ON SP.cCodPerson = CRE.cCodUsuAna	
			where B.cCodCtaCre COLLATE SQL_Latin1_General_CP1_CI_AS	
					IN  (select rtrim(CodCredito) from ExpedContabilidad )
				AND E.CTIPEXPCLI='K' AND E.lconEstado = 1 
			order by B.cCodCliente
		
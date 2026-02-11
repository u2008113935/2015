
	Select * from TConsPequeMicro
		-- (48,103 row(s) affected)

	Select * into #tab01 from (
		Select A.* , CRE.cCodConven	-- ISNULL(C.cDesConven,'SIN CAMPAÑA')
		From TConsPequeMicro A
			INNER join [HYO00409\HISTORICO].SOFCMACHYO_201506.dbo.[KPYMCRECONVEN] CRE (NOLOCK)
			on A.CodigoCredito_00 COLLATE SQL_Latin1_General_CP1_CI_AS 
					= CRE.cCodCtaCre
							  ) as tmp

		Select * from #tab01

		Select A.* , Campaña = ISNULL(C.cDesConven,'SIN CAMPAÑA')
		from #tab01 A
			LEFT join [HYO00409\HISTORICO].SOFCMACHYO_201506.dbo.KPYMConvenios C
				on C.cCodConven = A.cCodConven						
		Where C.cObsConven LIKE '%campa%'		
			--AND C.cCodConven <> 'XXXXXX'

	-- (32,477 row(s) affected)

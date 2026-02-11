	USE SGN
	SELECT * FROM DescuentosDic	-- (556 row(s) affected)


	SELECT --C.cCodCtaCre, 
			CodAsesor	=	C.cCodUsuAna, NombreAsesor	=	P.cNomPerson, 	
			D.*
	FROM [HYO00402].SOFCMACHYO_DIARIO_MANIANA.DBO.[KPYMCRECONVEN] C
			INNER JOIN DescuentosDic D
				ON D.ccodctacre COLLATE SQL_Latin1_General_CP1_CI_AS = C.cCodCtaCre	
			INNER JOIN [HYO00402].SOFCMACHYO_DIARIO_MANIANA.DBO.[sipmpersonal] P 
				ON P.cCodPerson = C.cCodUsuAna
	WHERE C.cCodCtaCre COLLATE SQL_Latin1_General_CP1_CI_AS	 
			IN (SELECT ccodctacre FROM DescuentosDic)
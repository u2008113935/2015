		/*
		INNER JOIN SIPMPERSONAL P01
			ON P01.cCodPerson = A.cCodUsuApr
		INNER JOIN SIPTCARGOPER P02
			ON P02.cCodGruPer = P01.cCodGruPer 
		*/


		/*
		
		lista de Asesores Junior 1 y 2 con los siguientes datos:
		 • Apellidos y Nombres • Categoría • Agencia • Puntaje como asesor
		
		*/


		SELECT TOP 1 * FROM SIPMPERSONAL P01
		SELECT TOP 1 * FROM SIPTCARGOPER P02		
		
		SELECT dFecCesIns,cCodEstPer, cCodGruPer,cCodClasPer
				,* 
		FROM SIPMPERSONAL P01
		where  --lConEstado  cCodPerPer
			cNomPerson like 'Perez%juan%'--'Peña%garc%guille%'
			--cNomPerson like 'Peña%garc%guille%'
			---and dFecCesIns is not null
			cCodEstPer C
			cCodEstPer A
		cCodGruPer	char(3)	Código de Cargo del personal (SIPTCAPCARORG)
		cCodClasPer	char(3)	Codigo de Clasificación de personal (SIPTCLASIFPER)


		--ponderacion
		select *
		from  SIPDIncAsiPon
		where cCodPeriodo='2015/04'
		and cCodPerson='aapoli'

		---analisis ini fin res
		select *
		from SIPDIncAlcMen
		where cCodPeriodo='2015/04'
		and cCodPerson='aapoli'

		--nota final
		select *
		from SIPDIncPunAlc
		where cCodPeriodo='2015/04'
		and cCodPerson='aapoli'

		--pago de incentivos
		select *
		from SIPDIncCreCal
		where cCodPeriodo='2015/04'
		--and cCodPerson='aapoli'
		and cCodOficin='009'
	
		---nivel de colaboradores
		select *
		from SIPTClaSubNiv
		where nCodPAPApr=8
		and  cCodNivel='03'			
		--cCodNivAna = 03E

		--------------------------------------------------
		SELECT cCodGruPer,cDesCarPer,cDesCorta,lConEstado,cCAPCodCar
		FROM SIPTCARGOPER P02
		WHERE cDesCarPer like '%J%'
		group by cCodGruPer,cDesCarPer,cDesCorta,lConEstado,cCAPCodCar


		Select * From SIPTClaSubNiv WHERE --cCodNivel + cCodSubNiv = '03D'
				cCodNivel='03' and	cCodSubNiv='E' and cCodClaSub='02'
				and cDesClaSub LIKE '%J%'
		select * from SIPDIncCreCal
		select * from SIPDIncPunAlc where cCodPeriodo = '2015/04' --cCodNivAna 03D
			select cCodPeriodo from SIPDIncPunAlc GROUP BY  cCodPeriodo
		select * from SIPDIncAlcMen where cCodPeriodo = '2015/04'
		select * from SIPDIncAsiPon where cCodPeriodo = '2015/04' 
				and cCodNivel='03' and	cCodSubNiv='E' and cCodClaSub='02'

	---------------------------------------------------------------------------------------
		Select B.cCodPeriodo, A.cCodSubNiv,A.cDesClaSub,B.cCodPerson, P.cNomPerson, P.cCodOficin
			 ,P.nNotaFinal, O.cCodOficin, O.cDesOficin,ZON.nCodZona, ZON.cDesZona
			 ,P01.dFecCesIns, P01.cCodEstPer, P01.cCodGruPer,P01.cCodPerson,P01.cCodOficin
			 ,P01.cNomPerson
		from  [SIPDIncAsiPon] B 
				INNER JOIN SIPMPERSONAL P01
					ON P01.cCodPerson = B.cCodPerson
				INNER JOIN [SIPTClaSubNiv] A
					ON A.cCodNivel=B.cCodNivel and A.cCodSubNiv=B.cCodSubNiv 
						and A.cCodClaSub=B.cCodClaSub
				inner join SIPDIncPunAlc P
					on P.cCodPerson = B.cCodPerson 
				INNER JOIN[GENTOficinas] O 
					ON P.cCodOficin = O.cCodOficin AND O.lConEstado = '1'
				INNER JOIN [Gentofizonas] GOZ
					ON GOZ.cCodOficin = O.cCodOficin AND GOZ.lEstZonOfi = '1'
				INNER JOIN [GentZonas] ZON
					ON ZON.nCodZona = GOZ.nCodZona
	    where A.nCodPAPApr=8
			and A.cCodNivel='03'--nivel asesores
			and A.cCodSubNiv in('F','G') --junior 1 y junior 2
			--AND B.cCodPerson = 'AAPOLI'
			AND B.cCodPeriodo = '2015/05' 
			and P.cCodPeriodo ='2015/05'
			AND P01.cCodEstPer= 'A'
			AND dFecCesIns IS NULL
			and P.nNotaFinal is not null
		ORDER BY B.cCodPerson

